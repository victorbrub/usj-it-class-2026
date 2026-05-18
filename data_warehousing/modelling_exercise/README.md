# Author: Víctor Barceló

# Dimensional Modelling Exercise: Relational vs Dimensional Models in PostgreSQL

## Overview

This exercise compares two database modelling approaches for the same football
league dataset and measures how each handles analytical queries. You will run
identical KPIs against a normalized relational model (3NF) and a dimensional
model (star schema) and compare the resulting execution plans.

---

## Learning Objectives

- Understand the structural difference between a normalized relational model and
  a dimensional star schema.
- Read and interpret PostgreSQL EXPLAIN ANALYZE output.
- Measure and compare query complexity (number of plan nodes, join types).
- Explain why dimensional models are the standard choice for analytical workloads.

---

## Domain: Football League (La Liga style)

The database covers 50 seasons across 10 European football leagues (200 clubs):

| Entity  | Volume |
|---------|--------|
| Clubs   | 200 (20 per league x 10 leagues) |
| Players | 5,000 (25 per club) |
| Seasons | 50 (1975/76 through 2024/25) |
| Matches | 190,000 (3,800 per season) |
| Goals   | 564,156 |
| Cards   | 760,166 |
| fact_player_performance rows | 1,528,196 |

---

## Model Descriptions

### Relational Model (schema: `relational`)

Fully normalized to third normal form (3NF). Each entity has its own table and
data is never duplicated. Relationships are enforced through foreign keys.

```
clubs
  |--- players (club_id)
  |--- matches (home_club_id, away_club_id)
         |--- goals (match_id, scorer_id, assist_id, club_id)
         |--- cards (match_id, player_id, club_id)
seasons
  |--- matches (season_id)
```

To answer an analytical question such as "how many goals did each player score
in a season?", the engine must traverse: goals -> players -> clubs -> matches
-> seasons. This is 5 tables and 4 joins.

### Dimensional Model (schema: `dimensional`)

Star schema with pre-aggregated fact tables. Analytical attributes are
denormalized into dimension tables. Measures are pre-computed and stored
directly in the fact row.

```
                     dim_date
                        |
dim_player --- fact_player_performance --- dim_club
                        |
                    dim_season


                     dim_date
                        |
dim_club (home) --- fact_match_results --- dim_club (away)
                        |
                    dim_season
```

Each fact table is **range-partitioned by `season_key`** into 15 partitions (one per
season, plus a default catch-all). When a query filters on a specific season,
PostgreSQL performs **partition pruning** and accesses only the single matching
partition, skipping the other 14. This is visible in EXPLAIN output as
`Partitions selected: 1 out of 16`.

The same "goals per player per season" question requires only:
fact_player_performance -> dim_player -> dim_season. That is 3 tables and
2 joins, and the goal count is already stored as a column in the fact row.

---

## KPIs Covered

| # | KPI | Relational joins | Dimensional joins |
|---|-----|-----------------|-------------------|
| 1 | Top 10 goal scorers in a season | 5 tables, 4 joins | 4 tables, 3 joins |
| 2 | League table (standings) | UNION ALL + 3 tables | 2 CTEs + 3 tables |
| 3 | Monthly goal trend (all 50 seasons) | 2 tables + date extraction | 2 tables, pre-computed date |
| 4 | Avg goals per player by nationality | 2 tables, LEFT JOIN | 2 tables |
| 5 | Cards per match by club | CTE + 4 tables | CTE + 3 tables, no cards join |

---

## Setup

### Prerequisites

- PostgreSQL 14 or later installed and running.
- A PostgreSQL user with CREATE DATABASE privileges.
- `psql` available on the command line.

### Run all scripts at once

```bash
cd data_warehousing/modelling_exercise
chmod +x run_all.sh
./run_all.sh
```

By default the script connects as user `postgres` to `localhost:5432` and
creates a database named `football_dw`. Override with arguments:

```bash
./run_all.sh football_dw localhost 5432 myuser
```

### Run scripts manually (step by step)

```bash
# Create the database (replace connection details as needed)
psql -U postgres -c "CREATE DATABASE football_dw;"

psql -U postgres -d football_dw -f 01_relational_schema.sql
psql -U postgres -d football_dw -f 02_relational_data.sql
psql -U postgres -d football_dw -f 03_dimensional_schema.sql
psql -U postgres -d football_dw -f 04_dimensional_etl.sql
```

After setup, open the KPI files in psql or any SQL client:

```bash
psql -U postgres -d football_dw -f 05_kpis_relational.sql
psql -U postgres -d football_dw -f 06_kpis_dimensional.sql
psql -U postgres -d football_dw -f 07_partition_pruning_demo.sql
```

---

## Exercise Tasks

### Part 1 - Explore the schemas (10 min)

1. Connect to `football_dw` and list all tables in both schemas:
   ```sql
   \dt relational.*
   \dt dimensional.*
   ```
2. Count the rows in each table and confirm the volumes match the table above.
3. Draw (on paper or a diagram tool) the ER diagram of the relational model and
   the star schema of the dimensional model.

### Part 2 - Verify KPI results match (10 min)

Run the plain queries (section `(a)`) from both `05_kpis_relational.sql` and
`06_kpis_dimensional.sql` for each KPI. Confirm the numbers are identical or
explain any small differences.

### Part 3 - Compare execution plans (30 min)

Run the EXPLAIN ANALYZE queries (section `(b)`) for each KPI in both files.
For each KPI fill in the comparison table below.

#### Comparison table template

| KPI | Model | Plan nodes | Total execution time (ms) | Tables scanned |
|-----|-------|-----------|--------------------------|----------------|
| 1   | Relational |  |  |  |
| 1   | Dimensional |  |  |  |
| 2   | Relational |  |  |  |
| 2   | Dimensional |  |  |  |
| 3   | Relational |  |  |  |
| 3   | Dimensional |  |  |  |
| 4   | Relational |  |  |  |
| 4   | Dimensional |  |  |  |
| 5   | Relational |  |  |  |
| 5   | Dimensional |  |  |  |

#### How to count plan nodes

In the EXPLAIN output, count every indented operation on a separate line
(Seq Scan, Index Scan, Hash, Hash Join, Sort, Aggregate, CTE Scan, etc.).

### Part 5 - Visualize the comparison (15 min)

After completing Part 3, generate the performance chart so you can see all
metrics at a glance:

```bash
pip install psycopg2-binary matplotlib numpy   # only needed once
cd data_warehousing/modelling_exercise
python3 08_plot_performance.py
```

Open `relational_vs_dimensional.png` and examine each of the five panels:

| Panel | What it shows | Key observation |
|-------|--------------|------------------|
| 1 (Execution time) | Milliseconds per KPI for both models | Green bars should be shorter across all five KPIs. The percentage label on the right shows the time reduction. |
| 2 (Plan nodes) | Number of operations in the execution plan | Dimensional plans have fewer nodes because facts are pre-aggregated. |
| 3 (Tables scanned) | Relation scans performed at runtime | The relational model scans more tables because normalization requires joining many entities. |
| 4 (Speedup factor) | How many times faster the dimensional model is | Values above 1x confirm the dimensional model is faster. Higher bars indicate queries that benefit most from pre-aggregation. |
| 5 (Partition pruning) | Rows scanned vs number of seasons (log scale) | The red line grows linearly with data volume; the green line stays flat. At 1,000 seasons the pruned query scans 1/1,000th of the rows a full scan would touch. |

Discuss with your group:
- Which KPI shows the largest speedup? Why?
- Which panel best illustrates the partition pruning benefit?
- Would the speedup increase or decrease if the database contained 100 seasons?

### Part 4 - Reflection questions (20 min)

Answer the following questions individually or in groups:

1. Which model produces simpler execution plans? Explain why in terms of the
   schema design.

2. For KPI 5 (cards per match), the relational model must join to the `cards`
   table at query time. The dimensional model stores card counts directly in
   the fact row. What is this technique called? What is the trade-off?

3. The fact_match_results table stores `home_win`, `away_win`, and `draw` as
   pre-computed boolean columns. Could you compute them at query time instead?
   Why might you choose to store them?

4. The relational model uses `EXTRACT(YEAR FROM match_date)` to derive year
   and month. The dimensional model reads `dim_date.year` and `dim_date.month`.
   What advantage does the dim_date approach offer beyond performance?

5. Run `07_partition_pruning_demo.sql` and read the scaling projection table.
   At 1,000 seasons, what fraction of the fact table is scanned by a pruned
   query vs a full scan? What does the `relative_io_cost_ratio` column tell
   you about how the gap changes as scale increases?

6. Identify one type of query where the relational model would be more
   appropriate than the dimensional model. Explain why.

---

## Expected Observations

- The relational queries for KPI 1 show at least 4 hash-join nodes because
  each FK relationship requires a join at execution time.
- The dimensional KPI 1 query typically shows 2-3 join nodes and the fact
  table scan directly sums the pre-stored `goals` column.
- KPI 5 in the relational model requires scanning the entire `cards` table and
  aggregating it with GROUP BY on (match_id, club_id). The dimensional query
  reads pre-summed columns from `fact_match_results` with no access to a
  separate cards table.
- The `dim_date` table transforms date-arithmetic expressions into simple
  equality predicates, which the planner can satisfy with an index lookup.
- Both models return identical result sets, confirming that the ETL preserved
  data correctness.
- Running `07_partition_pruning_demo.sql` with `enable_partition_pruning = off`
  shows the planner selecting all 16 partitions (15 + DEFAULT); re-enabling it
  collapses the Append node to a single-partition scan. The scaling projection
  shows that at 1,000 seasons a pruned query reads less than 0.1% of the rows
  a full scan would touch.

---

## File Structure

```
modelling_exercise/
├── README.md                  This file
├── run_all.sh                 Automated setup script
├── 01_relational_schema.sql   Relational schema (tables + indexes)
├── 02_relational_data.sql     Data population via PL/pgSQL
├── 03_dimensional_schema.sql  Dimensional schema (star schema)
├── 04_dimensional_etl.sql     ETL from relational to dimensional
├── 05_kpis_relational.sql     5 KPI queries on the relational model
├── 06_kpis_dimensional.sql    5 KPI queries on the dimensional model
├── 07_partition_pruning_demo.sql      Partition pruning demo + scaling projection
├── 07_partition_pruning_analysis.md   Annotated analysis of the three demo parts
├── 08_plot_performance.py             Python script — generates the performance chart
├── 09_kpis_dimensional_advantage.md   3 new KPIs designed to favour dimensional, with queries,
│                                      EXPLAIN ANALYZE plans, and timing comparison for both models
└── relational_vs_dimensional.png      Generated chart (run 08_plot_performance.py)
```

To regenerate the chart after installing the database:
```bash
python3 08_plot_performance.py
```
Requires `psycopg2-binary`, `matplotlib`, and `numpy`:
```bash
pip install psycopg2-binary matplotlib numpy
```
Optional overrides (host, port, user, dbname, output path):
```bash
python3 08_plot_performance.py --host localhost --port 5432 \
                               --user postgres --dbname football_dw \
                               --output relational_vs_dimensional.png
```
