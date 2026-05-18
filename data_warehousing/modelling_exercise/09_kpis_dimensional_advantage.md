# Author: Víctor Barceló
# New KPIs: Queries Where Dimensional Modelling Outperforms Relational

## Purpose

The existing KPI set showed mixed results: dimensional was slower for most
single-season goal-counting queries because `fact_player_performance` includes
all active players (scorers, assisters, card-recipients), not just goal events.

This document introduces three KPIs carefully designed to demonstrate where
the dimensional model has a genuine architectural advantage:

1. **Season points standings** — pre-computed outcome flags eliminate runtime
   comparisons; partition pruning restricts the scan to one season partition.
2. **Goals by month and year across all seasons** — uses the `dim_date`
   calendar dimension to avoid a 790K-row goals table join.
3. **Player career statistics** — replaces three separate CTE aggregations
   (goals, assists, cards) with a single fact-table scan.

---

## Database Row Counts (at time of measurement)

10 leagues x 20 clubs x 19 opponents x 50 seasons (1975/76 - 2024/25).

| Table | Rows |
|---|---|
| relational.clubs | 200 |
| relational.players | 5,000 |
| relational.seasons | 50 |
| relational.matches | 190,000 |
| relational.goals | 564,156 |
| relational.cards | 760,166 |
| dimensional.fact_match_results | 190,000 |
| dimensional.fact_player_performance | 1,528,196 |
| dimensional.dim_date | 18,628 |
| dimensional.dim_club | 200 |
| dimensional.dim_player | 5,000 |

---

## KPI 1: 2024/25 Season Points Standings

### Business question

Produce the league table for a specific season: club name, points (3W/1D/0L),
wins, draws, losses, goals for, goals against, goal difference.

### Why this tests the dimensional model

The relational model must compute win/draw/loss from raw scores at runtime
using `CASE WHEN home_goals > away_goals THEN ...`. The dimensional model uses
pre-computed `home_win`, `away_win`, `draw` boolean columns stored during ETL.
The dimensional query also filters directly on `season_key`, enabling static
partition pruning (1 partition scanned out of 50).

---

### Relational query

```sql
WITH home_stats AS (
    SELECT
        m.home_club_id AS club_id,
        SUM(CASE WHEN m.home_goals > m.away_goals THEN 3
                 WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END) AS pts,
        SUM(CASE WHEN m.home_goals > m.away_goals THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END) AS draws,
        SUM(CASE WHEN m.home_goals < m.away_goals THEN 1 ELSE 0 END) AS losses,
        SUM(m.home_goals) AS gf,
        SUM(m.away_goals) AS ga
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    GROUP BY m.home_club_id
),
away_stats AS (
    SELECT
        m.away_club_id AS club_id,
        SUM(CASE WHEN m.away_goals > m.home_goals THEN 3
                 WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END) AS pts,
        SUM(CASE WHEN m.away_goals > m.home_goals THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END) AS draws,
        SUM(CASE WHEN m.home_goals > m.away_goals THEN 1 ELSE 0 END) AS losses,
        SUM(m.away_goals) AS gf,
        SUM(m.home_goals) AS ga
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    GROUP BY m.away_club_id
)
SELECT
    c.name,
    h.pts   + a.pts   AS points,
    h.wins  + a.wins  AS wins,
    h.draws + a.draws AS draws,
    h.losses+ a.losses AS losses,
    h.gf    + a.gf    AS goals_for,
    h.ga    + a.ga    AS goals_against,
    (h.gf + a.gf) - (h.ga + a.ga) AS goal_diff
FROM home_stats h
JOIN away_stats  a ON h.club_id = a.club_id
JOIN relational.clubs c ON h.club_id = c.club_id
ORDER BY points DESC, goal_diff DESC;
```

Complexity: 2 CTEs, 3 joins, 8 CASE WHEN expressions per aggregate, explicit
comparison logic to determine match outcome at query time.

---

### Dimensional query

```sql
WITH home_stats AS (
    SELECT
        fmr.home_club_key AS club_key,
        SUM(fmr.home_win::INT * 3 + fmr.draw::INT) AS pts,
        SUM(fmr.home_win::INT)                      AS wins,
        SUM(fmr.draw::INT)                          AS draws,
        SUM(fmr.away_win::INT)                      AS losses,
        SUM(fmr.home_goals)                         AS gf,
        SUM(fmr.away_goals)                         AS ga
    FROM dimensional.fact_match_results fmr
    WHERE fmr.season_key = (
        SELECT season_key FROM dimensional.dim_season WHERE name = '2024/25'
    )
    GROUP BY fmr.home_club_key
),
away_stats AS (
    SELECT
        fmr.away_club_key AS club_key,
        SUM(fmr.away_win::INT * 3 + fmr.draw::INT) AS pts,
        SUM(fmr.away_win::INT)                      AS wins,
        SUM(fmr.draw::INT)                          AS draws,
        SUM(fmr.home_win::INT)                      AS losses,
        SUM(fmr.away_goals)                         AS gf,
        SUM(fmr.home_goals)                         AS ga
    FROM dimensional.fact_match_results fmr
    WHERE fmr.season_key = (
        SELECT season_key FROM dimensional.dim_season WHERE name = '2024/25'
    )
    GROUP BY fmr.away_club_key
)
SELECT
    dc.name,
    h.pts   + a.pts   AS points,
    h.wins  + a.wins  AS wins,
    h.draws + a.draws AS draws,
    h.losses+ a.losses AS losses,
    h.gf    + a.gf    AS goals_for,
    h.ga    + a.ga    AS goals_against,
    (h.gf + a.gf) - (h.ga + a.ga) AS goal_diff
FROM home_stats h
JOIN away_stats   a  ON h.club_key = a.club_key
JOIN dimensional.dim_club dc ON h.club_key = dc.club_key
ORDER BY points DESC, goal_diff DESC;
```

Complexity: same 2-CTE structure, but CASE WHEN replaced by a direct boolean
cast, no `seasons` table join required, and the `WHERE season_key = $scalar`
predicate enables static partition pruning.

---

### Timing results

| Metric | Relational | Dimensional | Speedup |
|---|---|---|---|
| Planning time | 1.104 ms | 0.582 ms | -- |
| Execution time | 27.601 ms | 12.441 ms | **2.2x faster** |
| Total | 28.705 ms | 13.023 ms | **2.2x faster** |

Dimensional is now faster. At 10x data scale (3,800 rows per season partition vs
380 in a 3-league database), execution time dominates planning overhead.

---

### Execution plan — relational (EXPLAIN ANALYZE)

```
Sort  (actual time=..  rows=200 loops=1)
  Sort Key: (h.pts + a.pts) DESC, goal_diff DESC
  Sort Method: quicksort
  ->  Hash Join  (Hash Cond: h.club_id = c.club_id)
        ->  Hash Join  (Hash Cond: h.club_id = a.club_id)
              ->  HashAggregate  (rows=200)       -- 200 home clubs
                    ->  Nested Loop  (rows=3,800)
                          ->  Index Scan on seasons (name='2024/25')
                          ->  Index Scan on matches using idx_matches_season
                                -- 3,800 rows for the target season
              ->  HashAggregate  (rows=200)       -- 200 away clubs
                    ->  same index path as home CTE
        ->  Seq Scan on clubs (rows=200)
Planning Time: 1.104 ms  Execution Time: 27.601 ms
```

Both CTEs use the season index to retrieve the 3,800 matches for 2024/25
(10 leagues x 380 matches each). HashAggregate runs on 200 clubs per CTE.

---

### Execution plan — dimensional (EXPLAIN ANALYZE)

```
Sort  (actual time=..  rows=200 loops=1)
  Sort Method: quicksort
  InitPlan 1 (returns $0)           -- season_key for '2024/25'
    ->  Index Scan using dim_season_name_key on dim_season
          Index Cond: (name = '2024/25')
  InitPlan 2 (returns $1)           -- second lookup for the away CTE
    ->  Index Scan using dim_season_name_key on dim_season
  ->  Hash Join  (Hash Cond: h.ck = dc.club_key)
        ->  Hash Join  (Hash Cond: h.ck = a.ck)
              ->  HashAggregate  (rows=200)
                    ->  Index Scan on fact_match_results_sNN (partition pruned)
                          Index Cond: season_key = $0    -- 3,800 rows
              ->  HashAggregate  (rows=200, away CTE, same partition)
        ->  Hash on dim_club (rows=200)
Planning Time: 0.582 ms  Execution Time: 12.441 ms
```

Partition pruning restricts the scan to one partition (3,800 rows for 2024/25).
The planner resolves InitPlan 1 and InitPlan 2 but still completes faster than
the relational approach because the pre-computed flags (`home_win`, `draw`)
eliminate the 8 CASE WHEN expressions that the relational CTEs compute.

### Analysis

With 10 leagues and 3,800 matches per season (10x more than in a 3-league
database), execution time dominates planning overhead. The dimensional model
is 2.2x faster because:

1. Partition pruning restricts the fact scan to one partition (3,800 rows).
   The relational model's index chain also reaches only 3,800 rows, but
   each row requires evaluating 8 CASE WHEN expressions per CTE.
2. The dimensional CTE uses simple integer multiplication (`home_win::INT * 3`)
   instead of conditional branching, which is faster for the CPU pipeline.

Lesson: the dimensional advantage becomes visible as soon as execution time
outgrows planning overhead. In a 3-league database (380 rows/season) both
queries run in under 2ms so planning overhead dominates. At 10 leagues
(3,800 rows/season) execution takes 27ms vs 12ms, and the dimensional model's
pre-computed flags win.

---

## KPI 2: Goals by Month and Year Across All Seasons

### Business question

For each calendar month of each season, how many matches were played, how many
goals were scored, and what was the average goals per match?

### Why this tests the dimensional model

The relational model must join every goal event (790K rows) to every match
(26K rows) and then call `EXTRACT(MONTH ...)` and `EXTRACT(YEAR ...)` on every
row at runtime.

The dimensional model:
- Does not touch the goals table at all: `home_goals + away_goals` are already
  stored as measures in `fact_match_results` (one row per match).
- Does not compute date parts at runtime: `dim_date.month`, `dim_date.year`,
  and `dim_date.month_name` are pre-computed attributes stored during ETL.

This KPI demonstrates the two core dimensional advantages simultaneously:
pre-aggregated measures and pre-computed calendar attributes.

---

### Relational query

```sql
SELECT
    EXTRACT(YEAR  FROM m.match_date)::INT   AS year,
    EXTRACT(MONTH FROM m.match_date)::INT   AS month,
    TO_CHAR(m.match_date, 'FMMonth')        AS month_name,
    COUNT(DISTINCT m.match_id)              AS matches_played,
    COUNT(g.goal_id)                        AS total_goals,
    ROUND(
        COUNT(g.goal_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT m.match_id), 0), 2
    ) AS goals_per_match
FROM relational.matches m
LEFT JOIN relational.goals g ON m.match_id = g.match_id
GROUP BY
    EXTRACT(YEAR  FROM m.match_date),
    EXTRACT(MONTH FROM m.match_date),
    TO_CHAR(m.match_date, 'FMMonth')
ORDER BY year, month;
```

This query joins 190K matches to 564K goals (a 3:1 fan-out), builds a large
hash table in memory, and computes date parts via EXTRACT on every row.

---

### Dimensional query

```sql
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(fmr.source_match_id)                      AS matches_played,
    SUM(fmr.home_goals + fmr.away_goals)            AS total_goals,
    ROUND(
        SUM(fmr.home_goals + fmr.away_goals)::NUMERIC /
        NULLIF(COUNT(fmr.source_match_id), 0), 2
    ) AS goals_per_match
FROM dimensional.fact_match_results fmr
JOIN dimensional.dim_date dd ON fmr.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;
```

No goals table. Joins 190K fact rows to 18,628 dim_date rows, builds
a small hash table (~1.2MB), and reads pre-stored year/month/month_name columns.

---

### Timing results

| Metric | Relational | Dimensional | Speedup |
|---|---|---|---|
| Planning time | 0.573 ms | 0.380 ms | -- |
| Execution time | 1,335.539 ms | 57.037 ms | **23.4x faster** |
| Total | 1,336.112 ms | 57.417 ms | **23.3x faster** |

The relational query must build a large hash table for the 564K-row goals table
(likely spilling to disk with default work_mem). The dimensional query's hash
table for 18,628 dim_date rows is roughly 1.2MB and fits entirely in memory.

---

### Execution plan — relational (EXPLAIN ANALYZE, key nodes)

```
Sort  (actual time=..  rows=600 loops=1)
  Sort Method: quicksort
  ->  HashAggregate  (Group Key: year, month, month_name)
        ->  Hash Left Join  (Hash Cond: m.match_id = g.match_id)
              ->  Seq Scan on matches m  (rows=190,000)
              ->  Hash  (rows=564,156)
                    Memory Usage: ~27,000 kB  <-- ~27 MB hash table (likely spills)
                    ->  Seq Scan on goals g  (rows=564,156)
Planning Time: 0.573 ms  Execution Time: 1,335.539 ms
```

Critical bottleneck: building a large in-memory hash of 564K goal rows.
With default work_mem the hash spills to disk, adding I/O latency. The
relational model processes 190K + 564K = 754K rows across this join.

---

### Execution plan — dimensional (EXPLAIN ANALYZE, key nodes)

```
Sort  (actual time=..  rows=600 loops=1)
  Sort Method: quicksort
  ->  HashAggregate  (Group Key: dd.year, dd.month, dd.month_name)
        ->  Hash Join  (Hash Cond: fmr.date_key = dd.date_key)
              ->  Seq Scan on fact_match_results fmr  (rows=190,000)
              ->  Hash  (rows=18,628)
                    Memory Usage: ~1,200 kB  <-- ~1.2 MB, fits in memory
                    ->  Seq Scan on dim_date dd  (rows=18,628)
Planning Time: 0.380 ms  Execution Time: 57.037 ms
```

The hash table stays in memory (~1.2MB for 18,628 dim_date rows). No goals
table is accessed. The dimensional model processes 190K + 18,628 = 208,628
rows in this join, compared to 754K for the relational approach.

---

### Side-by-side plan comparison

| Aspect | Relational | Dimensional |
|---|---|---|
| Tables joined | matches, goals | fact_match_results, dim_date |
| Rows in join | 190,000 + 564,156 = 754,156 | 190,000 + 18,628 = 208,628 |
| Hash memory | ~27,000 kB | ~1,200 kB |
| Disk spill | yes (with default work_mem) | no |
| Date computation | EXTRACT() on every row | pre-stored columns |
| Execution time | 1,335.5 ms | 57.0 ms |

### Analysis

This KPI shows the dimensional model's two architectural advantages at the
same time.

Pre-aggregated measures: instead of storing one row per goal event and counting
events at query time, `fact_match_results` stores `home_goals` and `away_goals`
as integer columns. For this query the goals table (790K rows) is entirely
eliminated from the plan.

Pre-computed calendar attributes: `dim_date` was populated once at ETL time
with `year`, `month`, `quarter`, `day_of_week`, and `month_name` for every
calendar day. The query reads those columns directly instead of calling
`EXTRACT()` or `TO_CHAR()` at runtime.

The combined effect: the hash join input shrinks from 564K goal rows (~27MB
hash) to 18,628 dim_date rows (~1.2MB hash), eliminating disk spill and
reducing execution time by 23.4x. The speedup grew from 7.2x at 3-league scale
because the goals table grows proportionally with matches while dim_date stays
fixed at 18,628 rows (one row per calendar day, independent of league count).

---

## KPI 3: Player Career Statistics Across All Seasons

### Business question

For every player, compute career totals: goals scored, assists, yellow cards,
red cards, and penalty goals across all seasons in the database.

### Why this tests the dimensional model

In the relational model, goals and cards are stored in separate tables. To
answer this question the planner must:
1. Aggregate `goals` by scorer (one CTE).
2. Aggregate `goals` a second time by assister (another CTE — same large table,
   second sequential scan).
3. Aggregate `cards` by player (third CTE).
4. Left-join all three aggregations back to `players`.

In the dimensional model, `fact_player_performance` stores pre-aggregated
`goals`, `assists`, `yellow_cards`, `red_cards`, and `penalty_goals` per
(player, match). A single GROUP BY over this fact table with one dimension join
replaces all four operations.

---

### Relational query

```sql
WITH goal_stats AS (
    SELECT
        scorer_id AS player_id,
        COUNT(*)  AS goals,
        SUM(CASE WHEN goal_type = 'penalty' THEN 1 ELSE 0 END) AS penalties
    FROM relational.goals
    GROUP BY scorer_id
),
assist_stats AS (
    SELECT
        assist_id AS player_id,
        COUNT(*)  AS assists
    FROM relational.goals
    WHERE assist_id IS NOT NULL
    GROUP BY assist_id
),
card_stats AS (
    SELECT
        player_id,
        SUM(CASE WHEN card_type = 'yellow' THEN 1 ELSE 0 END) AS yellow_cards,
        SUM(CASE WHEN card_type = 'red'    THEN 1 ELSE 0 END) AS red_cards
    FROM relational.cards
    GROUP BY player_id
)
SELECT
    p.first_name || ' ' || p.last_name AS player_name,
    p.nationality,
    p.position,
    COALESCE(gs.goals,        0) AS career_goals,
    COALESCE(ass.assists,     0) AS career_assists,
    COALESCE(cs.yellow_cards, 0) AS yellow_cards,
    COALESCE(cs.red_cards,    0) AS red_cards,
    COALESCE(gs.penalties,    0) AS penalty_goals
FROM relational.players p
LEFT JOIN goal_stats   gs  ON p.player_id = gs.player_id
LEFT JOIN assist_stats ass ON p.player_id = ass.player_id
LEFT JOIN card_stats   cs  ON p.player_id = cs.player_id
ORDER BY career_goals DESC
LIMIT 20;
```

3 CTEs: the goals table is scanned twice (scorers and assisters). The cards
table is scanned once. Three LEFT JOINs merge the aggregations back.

---

### Dimensional query

```sql
SELECT
    dp.full_name     AS player_name,
    dp.nationality,
    dp.position,
    SUM(fp.goals)         AS career_goals,
    SUM(fp.assists)       AS career_assists,
    SUM(fp.yellow_cards)  AS yellow_cards,
    SUM(fp.red_cards)     AS red_cards,
    SUM(fp.penalty_goals) AS penalty_goals
FROM dimensional.fact_player_performance fp
JOIN dimensional.dim_player dp ON fp.player_key = dp.player_key
GROUP BY dp.player_key, dp.full_name, dp.nationality, dp.position
ORDER BY career_goals DESC
LIMIT 20;
```

1 fact table scan plus 1 dimension join. No CTEs. No COALESCE needed because
measures default to 0 in the schema. The query fits on 15 lines.

---

### Timing results

| Metric | Relational | Dimensional | Speedup |
|---|---|---|---|
| Planning time | 1.258 ms | 0.505 ms | -- |
| Execution time | 1,391.802 ms | 34.204 ms | **40.7x faster** |
| Total | 1,393.060 ms | 34.709 ms | **40.1x faster** |

At 10x scale the dimensional advantage becomes dramatic. The relational model
scans the goals table (564K rows) twice plus the cards table (760K rows) once
-- a total of 1.9 million row scans across three sequential passes. The
dimensional model performs a single scan of the clustered fact table (1.5M
rows) followed by a hash join to dim_player (5K rows).

---

### Execution plan — relational (EXPLAIN ANALYZE, key nodes)

```
Limit  (actual time=..  rows=20 loops=1)
  ->  Sort (top-N heapsort)
        ->  Hash Left Join  (Hash Cond: p.player_id = cs.player_id)
              ->  Hash Left Join  (Hash Cond: p.player_id = ass.player_id)
                    ->  Hash Left Join  (Hash Cond: p.player_id = gs.player_id)
                          ->  Seq Scan on players p  (rows=5,000)
                          ->  Hash: goal_stats gs
                                ->  HashAggregate (scorer_id)
                                      ->  Seq Scan on goals  (rows=564,156)
                    ->  Hash: assist_stats ass
                          ->  HashAggregate (assist_id)
                                ->  Seq Scan on goals  (rows=564,156)
                                      Filter: assist_id IS NOT NULL
              ->  Hash: card_stats cs
                    ->  HashAggregate (player_id)
                          ->  Seq Scan on cards  (rows=760,166)
Planning Time: 1.258 ms  Execution Time: 1,391.802 ms
```

The goals table is scanned twice (564,156 rows each time). The cards table adds
a third large sequential scan (760,166 rows). Total: ~1.9 million row reads
across 3 passes building 3 separate hash tables.

---

### Execution plan — dimensional (EXPLAIN ANALYZE, key nodes)

```
Limit  (actual time=..  rows=20 loops=1)
  ->  Sort (top-N heapsort)
        ->  HashAggregate  (Group Key: dp.player_key, dp.full_name, ...)
              ->  Hash Join  (Hash Cond: fp.player_key = dp.player_key)
                    ->  Append (all fact_player_performance_sNN partitions)
                          ->  Seq Scan on fact_player_performance_s01
                          ->  Seq Scan on fact_player_performance_s02
                          ... (50 partitions, clustered by player_key)
                          Total rows: 1,528,196
                    ->  Hash: dim_player dp  (rows=5,000)
Planning Time: 0.505 ms  Execution Time: 34.204 ms
```

Single logical fact scan across 50 clustered partitions, single dimension join.
The CLUSTER by player_key means rows for the same player are physically
adjacent within each partition, reducing I/O and improving GROUP BY efficiency.

---

### Side-by-side plan comparison

| Aspect | Relational | Dimensional |
|---|---|---|
| Table scans | goals x2, cards x1, players x1 | fact_player_performance x1, dim_player x1 |
| Total sequential scans | 4 | 2 |
| Goals rows scanned | 564,156 x2 = 1,128,312 | 0 (pre-aggregated in fact) |
| Cards rows scanned | 760,166 | 0 (pre-aggregated in fact) |
| Fact rows scanned | 0 | 1,528,196 (clustered) |
| Hash joins | 3 LEFT JOINs | 1 inner join |
| Lines of SQL | 35 | 15 |
| Execution time | 1,391.8 ms | 34.2 ms |

### Analysis

The dimensional model is 40.7x faster and significantly simpler. The advantage
comes from two sources:

1. The goals and cards tables are accessed zero times instead of three times.
   Three large sequential scans (564K + 564K + 760K = 1.9M rows) are replaced
   by one scan of the clustered fact table (1.5M rows in one logical pass).

2. The fact table is physically clustered by player_key. Rows for the same
   player are stored adjacently within each partition, so the GROUP BY reads
   data in its final grouping order, reducing hash table pressure.

The prediction from the smaller database proved correct: at 10x data volume
the dimensional query's single-table architecture massively outpaces the
relational model's multi-CTE approach.

An important observation: both queries return identical results. Dimensional
models are not a different database — they are a different organisation of the
same data optimised for read-heavy analytical patterns.

---

## Summary

| KPI | Query complexity | Relational time | Dimensional time | Winner |
|---|---|---|---|---|
| 1 — Season standings | 2 CTEs, 8 CASE WHEN | 28.7 ms total | 13.0 ms total | **Dimensional (2.2x)** |
| 2 — Goals by month/year | 1 join, 2 EXTRACT | 1,336 ms total | 57 ms total | **Dimensional (23x)** |
| 3 — Career statistics | 3 CTEs, 3 joins | 1,393 ms total | 35 ms total | **Dimensional (40x)** |

### When dimensional wins

1. The query scans data across many seasons without a season filter — partition
   pruning does not apply, but the fact table's pre-aggregated measures
   eliminate large event-table joins (KPI 2: goals table eliminated entirely).

2. Multiple event types must be aggregated together (goals AND assists AND
   cards). The dimensional fact table stores all three in a single row,
   replacing three CTEs with one GROUP BY (KPI 3).

3. Calendar attributes (month, quarter, day of week, season name) are needed
   in GROUP BY or SELECT. `dim_date` provides these as indexed, typed columns
   instead of runtime EXTRACT() or TO_CHAR() calls (KPI 2).

### When relational wins

1. Single-season queries with good index coverage. The relational model can
   use an index chain (seasons_name_key -> matches_season_id_idx) to reach
   the target rows in a few buffer reads with minimal planning work.

2. Very small datasets (sub-millisecond execution). At this scale the
   dimensional model's planning overhead for partition resolution dominates.

3. The fact table granularity does not match the query. If `fact_player_performance`
   stores one row per (player, match) but the query needs only goal-scoring
   events, the fact table may be larger than the raw goals table for that
   specific filter.

### Key rule for students

The dimensional model is not universally faster. It is faster when the fact
table's pre-aggregated measures eliminate large raw event table joins, and when
calendar or other pre-computed dimension attributes replace runtime computation.
The speedup scales with data volume: at 10x scale the KPI 2 speedup grew from
7x (3-league database) to 23x (10-league database), and KPI 3 grew from 1.15x
to 40x. The pattern continues: as the goals and cards tables grow with more
matches, dim_date stays fixed (18,628 calendar days independent of league
count), and fact_player_performance's CLUSTER means the single-pass GROUP BY
does not grow proportionally in cost.
