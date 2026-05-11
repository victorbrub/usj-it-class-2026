-- Author: Víctor Barceló
-- =============================================================================
-- Partition Pruning Demo
-- =============================================================================
-- This file demonstrates how RANGE partitioning on season_key improves
-- query performance for single-season filters, and projects how that benefit
-- grows with scale.
--
-- Three techniques are used:
--
--   1. Partition architecture view  - query pg_class to show the physical
--                                     layout and actual row counts per partition
--
--   2. Pruning on vs off            - run the same KPI 1 plan with pruning
--                                     disabled, then re-enabled, so you can
--                                     compare the "Partitions selected" line
--                                     and the estimated cost in the plan
--
--   3. Scaling extrapolation        - arithmetic projection of rows scanned
--                                     and I/O cost at 100 and 1000 seasons,
--                                     expressed in a plain SELECT result set
-- =============================================================================


-- =============================================================================
-- PART 1: Partition architecture
-- =============================================================================
-- Shows every partition of both fact tables with its estimated live row count
-- and disk size, so students can see that data is evenly spread across seasons.

SELECT
    parent.relname                          AS fact_table,
    child.relname                           AS partition_name,
    pg_stat_get_live_tuples(child.oid)      AS live_rows,
    pg_size_pretty(pg_relation_size(child.oid)) AS disk_size,
    -- Show the partition bound definition
    pg_get_expr(child.relpartbound, child.oid, true) AS bound
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
JOIN pg_namespace ns ON parent.relnamespace   = ns.oid
WHERE ns.nspname   = 'dimensional'
  AND parent.relname IN ('fact_match_results', 'fact_player_performance')
ORDER BY parent.relname, child.relname;


-- =============================================================================
-- PART 2: Partition pruning on vs off
-- =============================================================================
-- KPI 1 (top 10 scorers in 2024/25) is used as the reference query because:
--   - It filters on a single season (WHERE ds.name = '2024/25')
--   - The planner resolves that filter to season_key = 15 early
--   - With pruning ON  → only fact_player_performance_s15 is scanned
--   - With pruning OFF → all 15 partitions are scanned
--
-- What to look for in the output:
--   - "Partitions selected: X out of 16"   (key line)
--   - The "rows=" estimate on the Seq Scan node
--   - The "cost=" at the top-level Append node
-- =============================================================================

-- ---- 2a. PRUNING DISABLED (simulates a full-table scan) ------------------
SET enable_partition_pruning = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dp.full_name    AS player_name,
    dc.name         AS club,
    dp.nationality,
    dp.position,
    SUM(fp.goals)   AS goals
FROM  dimensional.fact_player_performance fp
JOIN  dimensional.dim_player dp ON fp.player_key = dp.player_key
JOIN  dimensional.dim_club   dc ON fp.club_key   = dc.club_key
JOIN  dimensional.dim_season ds ON fp.season_key = ds.season_key
WHERE ds.name = '2024/25'
GROUP BY dp.full_name, dc.name, dp.nationality, dp.position
ORDER BY goals DESC
LIMIT 10;

-- ---- 2b. PRUNING ENABLED (default, production behaviour) -----------------
SET enable_partition_pruning = on;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dp.full_name    AS player_name,
    dc.name         AS club,
    dp.nationality,
    dp.position,
    SUM(fp.goals)   AS goals
FROM  dimensional.fact_player_performance fp
JOIN  dimensional.dim_player dp ON fp.player_key = dp.player_key
JOIN  dimensional.dim_club   dc ON fp.club_key   = dc.club_key
JOIN  dimensional.dim_season ds ON fp.season_key = ds.season_key
WHERE ds.name = '2024/25'
GROUP BY dp.full_name, dc.name, dp.nationality, dp.position
ORDER BY goals DESC
LIMIT 10;


-- =============================================================================
-- PART 3: Scaling extrapolation
-- =============================================================================
-- The actual dataset is small (15 seasons), so the absolute times are tiny.
-- This query uses the CURRENT row counts as a baseline and projects what
-- would happen with 100 or 1000 seasons.
--
-- Formula:
--   projected_total_rows  = current_rows_per_season * N_seasons
--   rows_scanned_pruned   = current_rows_per_season * 1        (always 1 season)
--   rows_scanned_no_prune = projected_total_rows
--   pruning_benefit_%     = (1 - 1/N_seasons) * 100
--
-- The "relative I/O" column models sequential I/O cost, which grows linearly
-- with rows scanned.  It is expressed as a ratio: pruned / no-prune.
-- =============================================================================

WITH baseline AS (
    -- Measure the actual average rows per season from the live partitions
    SELECT
        ROUND(AVG(pg_stat_get_live_tuples(child.oid)))::BIGINT AS rows_per_season
    FROM pg_inherits
    JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
    JOIN pg_namespace ns ON parent.relnamespace   = ns.oid
    WHERE ns.nspname     = 'dimensional'
      AND parent.relname = 'fact_player_performance'
      -- Exclude the DEFAULT partition (no bound → no rows under normal load)
      AND pg_get_expr(child.relpartbound, child.oid) != 'DEFAULT'
)
SELECT
    scenario.n_seasons                                              AS seasons,
    b.rows_per_season                                               AS rows_per_season,
    b.rows_per_season * scenario.n_seasons                          AS total_rows_in_table,
    b.rows_per_season                                               AS rows_scanned_with_pruning,
    b.rows_per_season * scenario.n_seasons                          AS rows_scanned_without_pruning,
    ROUND((1.0 - 1.0 / scenario.n_seasons) * 100, 1)               AS pct_rows_skipped,
    -- Relative cost ratio: pruned cost / full-scan cost (lower = better)
    ROUND(1.0 / scenario.n_seasons, 4)                              AS relative_io_cost_ratio
FROM baseline b
CROSS JOIN (VALUES (15), (50), (100), (500), (1000)) AS scenario(n_seasons)
ORDER BY scenario.n_seasons;

-- Expected result shape (actual numbers depend on your row counts):
--
--  seasons | rows_per_season | total_rows | scanned_pruned | scanned_no_prune | pct_skipped | relative_io
-- ---------+-----------------+------------+----------------+------------------+-------------+------------
--       15 |           ~2500 |     ~37500 |          ~2500 |            ~37500|        93.3 |      0.0667
--       50 |           ~2500 |    ~125000 |          ~2500 |           ~125000|        98.0 |      0.0200
--      100 |           ~2500 |    ~250000 |          ~2500 |           ~250000|        99.0 |      0.0100
--      500 |           ~2500 |   ~1250000 |          ~2500 |          ~1250000|        99.8 |      0.0020
--     1000 |           ~2500 |   ~2500000 |          ~2500 |          ~2500000|        99.9 |      0.0010
--
-- Interpretation:
--   At 1000 seasons the pruned query reads < 0.1% of the data compared to
--   a full scan.  Without partitioning the cost scales linearly with seasons;
--   with partitioning it is constant (always one season's worth of rows).
