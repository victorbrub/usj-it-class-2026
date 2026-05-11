-- Author: Víctor Barceló
-- =============================================================================
-- KPI Queries on the DIMENSIONAL MODEL
-- =============================================================================
-- Each KPI is IDENTICAL in intent to the corresponding query in
-- 05_kpis_relational.sql, so results can be cross-validated.
--
-- Key observations to make when comparing execution plans:
--   - Fewer JOIN nodes: facts already contain aggregated measures
--   - Dimension lookups are fast key lookups on small tables
--   - No subqueries needed for card counting (already in the fact row)
--   - Simpler GROUP BY because attributes sit directly on dimension tables
-- =============================================================================


-- =============================================================================
-- KPI 1: Top 10 goal scorers in the 2024/25 season
-- =============================================================================
-- Only 3 tables needed: fact + dim_player + dim_season (no matches/goals join)

-- (a) Plain query
SELECT
    dp.full_name    AS player_name,
    dc.name         AS club,
    dp.nationality,
    dp.position,
    SUM(fp.goals)   AS goals
FROM dimensional.fact_player_performance fp
JOIN dimensional.dim_player dp ON fp.player_key  = dp.player_key
JOIN dimensional.dim_club   dc ON fp.club_key    = dc.club_key
JOIN dimensional.dim_season ds ON fp.season_key  = ds.season_key
WHERE ds.name = '2024/25'
GROUP BY dp.full_name, dc.name, dp.nationality, dp.position
ORDER BY goals DESC
LIMIT 10;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dp.full_name    AS player_name,
    dc.name         AS club,
    dp.nationality,
    dp.position,
    SUM(fp.goals)   AS goals
FROM dimensional.fact_player_performance fp
JOIN dimensional.dim_player dp ON fp.player_key  = dp.player_key
JOIN dimensional.dim_club   dc ON fp.club_key    = dc.club_key
JOIN dimensional.dim_season ds ON fp.season_key  = ds.season_key
WHERE ds.name = '2024/25'
GROUP BY dp.full_name, dc.name, dp.nationality, dp.position
ORDER BY goals DESC
LIMIT 10;


-- =============================================================================
-- KPI 2: League table (standings) for the 2024/25 season
-- =============================================================================
-- Pre-computed home_win / away_win / draw flags eliminate all CASE WHEN logic.
-- Only 2 CTEs instead of the relational UNION ALL pattern.

-- (a) Plain query
WITH home_stats AS (
    SELECT
        fmr.home_club_key                                          AS club_key,
        COUNT(*)                                                   AS played,
        SUM(fmr.home_goals)                                        AS scored,
        SUM(fmr.away_goals)                                        AS conceded,
        SUM(CASE WHEN fmr.home_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS points,
        SUM(fmr.home_win::INT)                                     AS wins,
        SUM(fmr.draw::INT)                                         AS draws,
        SUM(fmr.away_win::INT)                                     AS losses
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_stats AS (
    SELECT
        fmr.away_club_key                                          AS club_key,
        COUNT(*)                                                   AS played,
        SUM(fmr.away_goals)                                        AS scored,
        SUM(fmr.home_goals)                                        AS conceded,
        SUM(CASE WHEN fmr.away_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS points,
        SUM(fmr.away_win::INT)                                     AS wins,
        SUM(fmr.draw::INT)                                         AS draws,
        SUM(fmr.home_win::INT)                                     AS losses
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT
    dc.name                                                   AS club,
    hs.played    + as2.played                                 AS played,
    hs.wins      + as2.wins                                   AS wins,
    hs.draws     + as2.draws                                  AS draws,
    hs.losses    + as2.losses                                 AS losses,
    hs.scored    + as2.scored                                 AS goals_for,
    hs.conceded  + as2.conceded                               AS goals_against,
    (hs.scored + as2.scored) - (hs.conceded + as2.conceded)  AS goal_diff,
    hs.points    + as2.points                                 AS points
FROM home_stats hs
JOIN away_stats as2      ON hs.club_key  = as2.club_key
JOIN dimensional.dim_club dc ON hs.club_key = dc.club_key
ORDER BY points DESC, goal_diff DESC, goals_for DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
WITH home_stats AS (
    SELECT fmr.home_club_key AS club_key, COUNT(*) AS played,
           SUM(fmr.home_goals) AS scored, SUM(fmr.away_goals) AS conceded,
           SUM(CASE WHEN fmr.home_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS points,
           SUM(fmr.home_win::INT) AS wins, SUM(fmr.draw::INT) AS draws,
           SUM(fmr.away_win::INT) AS losses
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_stats AS (
    SELECT fmr.away_club_key AS club_key, COUNT(*) AS played,
           SUM(fmr.away_goals) AS scored, SUM(fmr.home_goals) AS conceded,
           SUM(CASE WHEN fmr.away_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS points,
           SUM(fmr.away_win::INT) AS wins, SUM(fmr.draw::INT) AS draws,
           SUM(fmr.home_win::INT) AS losses
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT dc.name AS club,
       hs.played + as2.played AS played,
       hs.wins   + as2.wins   AS wins,
       hs.draws  + as2.draws  AS draws,
       hs.losses + as2.losses AS losses,
       hs.scored + as2.scored AS goals_for,
       hs.conceded + as2.conceded AS goals_against,
       (hs.scored + as2.scored) - (hs.conceded + as2.conceded) AS goal_diff,
       hs.points + as2.points AS points
FROM home_stats hs
JOIN away_stats as2       ON hs.club_key  = as2.club_key
JOIN dimensional.dim_club dc ON hs.club_key = dc.club_key
ORDER BY points DESC, goal_diff DESC, goals_for DESC;


-- =============================================================================
-- KPI 3: Monthly goal trend across all seasons
-- =============================================================================
-- Date attributes are pre-computed in dim_date; no EXTRACT() on raw dates needed.

-- (a) Plain query
SELECT
    dd.year,
    dd.month,
    dd.month_name                                                   AS period,
    SUM(fmr.home_goals + fmr.away_goals)                           AS total_goals,
    COUNT(*)                                                        AS matches_played,
    ROUND(SUM(fmr.home_goals + fmr.away_goals)::NUMERIC /
          NULLIF(COUNT(*), 0), 2)                                   AS avg_goals_per_match
FROM dimensional.fact_match_results fmr
JOIN dimensional.dim_date dd ON fmr.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dd.year,
    dd.month,
    dd.month_name                                                   AS period,
    SUM(fmr.home_goals + fmr.away_goals)                           AS total_goals,
    COUNT(*)                                                        AS matches_played,
    ROUND(SUM(fmr.home_goals + fmr.away_goals)::NUMERIC /
          NULLIF(COUNT(*), 0), 2)                                   AS avg_goals_per_match
FROM dimensional.fact_match_results fmr
JOIN dimensional.dim_date dd ON fmr.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;


-- =============================================================================
-- KPI 4: Average goals per player by nationality (all seasons combined)
-- =============================================================================
-- Nationality is a column on dim_player; no join to players + goals needed.

-- (a) Plain query
SELECT
    dp.nationality,
    COUNT(DISTINCT dp.player_key)                                   AS total_players,
    SUM(fp.goals)                                                   AS total_goals,
    ROUND(SUM(fp.goals)::NUMERIC /
          NULLIF(COUNT(DISTINCT dp.player_key), 0), 2)              AS avg_goals_per_player,
    SUM(fp.penalty_goals)                                           AS penalty_goals
FROM dimensional.fact_player_performance fp
JOIN dimensional.dim_player dp ON fp.player_key = dp.player_key
GROUP BY dp.nationality
HAVING COUNT(DISTINCT dp.player_key) >= 5
ORDER BY avg_goals_per_player DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dp.nationality,
    COUNT(DISTINCT dp.player_key)                                   AS total_players,
    SUM(fp.goals)                                                   AS total_goals,
    ROUND(SUM(fp.goals)::NUMERIC /
          NULLIF(COUNT(DISTINCT dp.player_key), 0), 2)              AS avg_goals_per_player,
    SUM(fp.penalty_goals)                                           AS penalty_goals
FROM dimensional.fact_player_performance fp
JOIN dimensional.dim_player dp ON fp.player_key = dp.player_key
GROUP BY dp.nationality
HAVING COUNT(DISTINCT dp.player_key) >= 5
ORDER BY avg_goals_per_player DESC;


-- =============================================================================
-- KPI 5: Discipline ranking (cards per match) by club in 2024/25
-- =============================================================================
-- Card counts are pre-aggregated in the fact row; no join to a cards table.

-- (a) Plain query
WITH home_cards AS (
    SELECT
        fmr.home_club_key                  AS club_key,
        COUNT(*)                           AS matches,
        SUM(fmr.home_yellow_cards)         AS yellow_cards,
        SUM(fmr.home_red_cards)            AS red_cards
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_cards AS (
    SELECT
        fmr.away_club_key                  AS club_key,
        COUNT(*)                           AS matches,
        SUM(fmr.away_yellow_cards)         AS yellow_cards,
        SUM(fmr.away_red_cards)            AS red_cards
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT
    dc.name                                                          AS club,
    hc.matches   + ac.matches                                        AS matches_played,
    hc.yellow_cards + ac.yellow_cards                                AS yellow_cards,
    hc.red_cards    + ac.red_cards                                   AS red_cards,
    (hc.yellow_cards + ac.yellow_cards +
     hc.red_cards    + ac.red_cards)                                 AS total_cards,
    ROUND((hc.yellow_cards + ac.yellow_cards +
           hc.red_cards    + ac.red_cards)::NUMERIC /
          NULLIF(hc.matches + ac.matches, 0), 2)                     AS cards_per_match
FROM home_cards hc
JOIN away_cards ac          ON hc.club_key = ac.club_key
JOIN dimensional.dim_club dc ON hc.club_key = dc.club_key
ORDER BY cards_per_match DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
WITH home_cards AS (
    SELECT fmr.home_club_key AS club_key, COUNT(*) AS matches,
           SUM(fmr.home_yellow_cards) AS yellow_cards,
           SUM(fmr.home_red_cards)    AS red_cards
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_cards AS (
    SELECT fmr.away_club_key AS club_key, COUNT(*) AS matches,
           SUM(fmr.away_yellow_cards) AS yellow_cards,
           SUM(fmr.away_red_cards)    AS red_cards
    FROM dimensional.fact_match_results fmr
    JOIN dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT dc.name AS club,
       hc.matches + ac.matches AS matches_played,
       hc.yellow_cards + ac.yellow_cards AS yellow_cards,
       hc.red_cards    + ac.red_cards    AS red_cards,
       (hc.yellow_cards + ac.yellow_cards + hc.red_cards + ac.red_cards) AS total_cards,
       ROUND((hc.yellow_cards + ac.yellow_cards + hc.red_cards + ac.red_cards)::NUMERIC /
             NULLIF(hc.matches + ac.matches, 0), 2) AS cards_per_match
FROM home_cards hc
JOIN away_cards ac           ON hc.club_key = ac.club_key
JOIN dimensional.dim_club dc ON hc.club_key = dc.club_key
ORDER BY cards_per_match DESC;
