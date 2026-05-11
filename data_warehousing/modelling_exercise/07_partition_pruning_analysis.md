# Author: Víctor Barceló

# Partition Pruning Analysis

This document explains the expected output of each part of
`07_partition_pruning_demo.sql` and how to interpret it in the context of
dimensional modelling and data warehouse design.

---

## Background: Why partitioning matters in a DWH

A data warehouse fact table grows without bound.  Every new season, every new
day, every new event adds rows.  A KPI query almost always filters on a time
dimension (a season, a quarter, a calendar year).

Without partitioning, PostgreSQL must scan the entire fact table and discard
all rows that do not belong to the requested period.  This is called a
**full table scan**, and its cost scales linearly with the total number of rows
in the table.

With **RANGE partitioning on `season_key`**, the table is physically split into
one segment per season.  When the planner resolves a `WHERE ds.name = '2024/25'`
filter to `season_key = 15`, it knows that only the `_s15` partition can contain
matching rows and skips all others.  This is **partition pruning**.

The cost of the pruned query is therefore constant regardless of how many
seasons exist in the table.

---

## Part 1 - Partition architecture

### What the query does

Reads `pg_inherits`, `pg_class`, and `pg_namespace` to list all physical
child tables of `fact_match_results` and `fact_player_performance`.  No data
is read from the fact tables themselves.

### Expected output

```
fact_table                   | partition_name                        | live_rows | disk_size | bound
-----------------------------+---------------------------------------+-----------+-----------+------------------------------
fact_match_results           | fact_match_results_default            |         0 | 8192 bytes| DEFAULT
fact_match_results           | fact_match_results_s01                |       380 | 40 kB     | FOR VALUES FROM (1) TO (2)
fact_match_results           | fact_match_results_s02                |       380 | 40 kB     | FOR VALUES FROM (2) TO (3)
...
fact_match_results           | fact_match_results_s15                |       380 | 40 kB     | FOR VALUES FROM (15) TO (16)
fact_player_performance      | fact_player_performance_default       |         0 | 8192 bytes| DEFAULT
fact_player_performance      | fact_player_performance_s01           |      2500 | 200 kB    | FOR VALUES FROM (1) TO (2)
...
fact_player_performance      | fact_player_performance_s15           |      2500 | 200 kB    | FOR VALUES FROM (15) TO (16)
```

Actual row counts will differ slightly because the data generator uses
`random()`.  The numbers above are approximate.

### What to notice

- The `DEFAULT` partition contains 0 rows.  All rows from the ETL fall within
  a known season_key (1-15), so no rows overflow into the catch-all partition.
- Row counts are equal (or near-equal) across all 15 season partitions.  This
  is called **even data distribution** and is required for partitioning to be
  effective.  Uneven distribution (data skew) reduces the benefit because one
  large partition may dominate query time.
- The `bound` column shows the exact range each partition covers.
  `FOR VALUES FROM (1) TO (2)` means `season_key >= 1 AND season_key < 2`,
  i.e. only `season_key = 1`.  PostgreSQL RANGE partitioning uses
  half-open intervals (inclusive lower bound, exclusive upper bound).
- The `disk_size` values confirm that storage is spread evenly.  The parent
  table itself has size 0 because data lives only in the child partitions.

---

## Part 2 - Pruning on vs off

### What the two plans show

Both plans execute the same KPI 1 query (top 10 scorers in 2024/25).  The only
difference is the session-level GUC `enable_partition_pruning`.

#### 2a. Pruning disabled (`SET enable_partition_pruning = off`)

The planner must assume it cannot eliminate any partition at planning time.
The plan will contain an `Append` node with 15 (or 16) children, one per
partition plus the DEFAULT.  Example excerpt:

```
Append  (cost=... rows=37500 ...)
  ->  Seq Scan on fact_player_performance_s01  (cost=... rows=2500 ...)
  ->  Seq Scan on fact_player_performance_s02  (cost=... rows=2500 ...)
  ...
  ->  Seq Scan on fact_player_performance_s15  (cost=... rows=2500 ...)
Filter: (season_key = $1)
```

The key line that appears when partitions are not pruned:
```
Partitions selected: 16 out of 16
```

The filter `season_key = $1` is applied inside each partition scan.  PostgreSQL
still applies the filter and discards non-matching rows, but it had to open and
read every partition to do so.

#### 2b. Pruning enabled (`SET enable_partition_pruning = on`)

The planner evaluates the predicate at planning time, determines that only
`season_key = 15` can satisfy `ds.name = '2024/25'`, and eliminates all other
partitions before the query starts.  Example excerpt:

```
Append  (cost=... rows=2500 ...)
  ->  Seq Scan on fact_player_performance_s15  (cost=... rows=2500 ...)
Partitions selected: 1 out of 16
```

### How to read the cost numbers

The `cost=A..B` values in the plan header represent the planner's estimate:
- `A` = cost to return the first row (startup cost)
- `B` = cost to return all rows (total cost)

The unit is arbitrary (it represents disk I/O pages + CPU cycles weighted by
cost parameters), but the ratio between the two plans is meaningful.

With 15 seasons and even distribution the pruned total cost should be
approximately **1/15 of the unpruned total cost** on the Append node.

### Why the actual execution time may not differ much at this scale

With only ~37,500 rows in `fact_player_performance`, the entire table fits in
PostgreSQL's shared_buffers after the first run.  Subsequent runs read
everything from memory (buffer cache), so I/O time approaches zero and the
CPU overhead dominates.  At this scale the difference between pruned and
unpruned is measurable in the plan costs but may not be visible in wall-clock
milliseconds.

At real data-warehouse scale (millions or billions of rows), the table does not
fit in memory.  I/O cost then dominates and the pruning benefit becomes directly
visible in execution time.

---

## Part 3 - Scaling extrapolation

### What the query computes

The query reads the actual average rows per season from `pg_stat_get_live_tuples`
(a live catalog function) and applies the following formulas:

| Column | Formula |
|--------|---------|
| `total_rows_in_table` | `rows_per_season * n_seasons` |
| `rows_scanned_with_pruning` | `rows_per_season * 1` (constant) |
| `rows_scanned_without_pruning` | `rows_per_season * n_seasons` |
| `pct_rows_skipped` | `(1 - 1/n_seasons) * 100` |
| `relative_io_cost_ratio` | `1 / n_seasons` |

### Expected output (approximate, based on ~2,500 rows/season)

| seasons | rows_per_season | total_rows | scanned_pruned | scanned_no_prune | pct_skipped | relative_io |
|--------:|----------------:|-----------:|---------------:|-----------------:|------------:|------------:|
|      15 |            2500 |      37500 |           2500 |            37500 |        93.3 |      0.0667 |
|      50 |            2500 |     125000 |           2500 |           125000 |        98.0 |      0.0200 |
|     100 |            2500 |     250000 |           2500 |           250000 |        99.0 |      0.0100 |
|     500 |            2500 |    1250000 |           2500 |          1250000 |        99.8 |      0.0020 |
|    1000 |            2500 |    2500000 |           2500 |          2500000 |        99.9 |      0.0010 |

### How to interpret the table

**`rows_scanned_with_pruning` is constant.**
No matter how many seasons exist in the table, a pruned single-season query
always reads exactly one partition.  The work does not grow with scale.

**`rows_scanned_without_pruning` grows linearly.**
Every additional season doubles, triples, ... the work needed.  At 1,000
seasons a full scan reads 2.5 million rows to answer a question about one
season containing 2,500 rows.

**`relative_io_cost_ratio` is the key metric.**
It expresses the pruned cost as a fraction of the full-scan cost.  At 1,000
seasons the ratio is 0.001, meaning the pruned query does 1/1,000th of the
I/O.  Real data warehouses routinely have hundreds or thousands of time
partitions.

**`pct_rows_skipped` approaches 100% asymptotically.**
Even at only 15 seasons the planner already skips 93% of rows.  This is why
partition pruning delivers measurable gains even at modest scales once rows
stop fitting in memory.

### The asymptotic limit

As $n \to \infty$:

$$\text{relative\_io} = \frac{1}{n} \to 0$$

$$\text{pct\_skipped} = \left(1 - \frac{1}{n}\right) \times 100 \to 100\%$$

The pruned query cost is $O(1)$ with respect to $n$ (number of seasons).
The unpruned query cost is $O(n)$.

This is the formal justification for why partitioned dimensional models are
the standard architecture for analytical systems at scale.

---

## Summary: three views of the same optimization

| Technique | What it shows | Audience |
|-----------|--------------|---------|
| Part 1 - Partition layout | Physical structure, row distribution | Visual learners, confirms setup is correct |
| Part 2 - Pruning on vs off | Actual planner behaviour, concrete cost numbers | Students who read EXPLAIN output |
| Part 3 - Scaling projection | Why it matters beyond the current dataset | Anyone thinking about production systems |

Together the three parts answer:
1. How is the data physically organized? (Part 1)
2. What does the planner actually do differently? (Part 2)
3. How does the benefit grow as the system scales? (Part 3)
