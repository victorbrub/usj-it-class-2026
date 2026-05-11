-- Author: Víctor Barceló
-- =============================================================================
-- ETL: Populate Dimensional Model from Relational Source
-- =============================================================================
-- Reads from the `relational` schema and loads:
--   1. dim_date         (calendar table, no relational source)
--   2. dim_club
--   3. dim_player
--   4. dim_season
--   5. fact_match_results   (aggregates cards per club per match)
--   6. fact_player_performance (aggregates goals/assists/cards per player/match)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. dim_date: generate every calendar day covering all three seasons
-- -----------------------------------------------------------------------------
INSERT INTO dimensional.dim_date
    (date_key, full_date, day, month, month_name, quarter,
     year, day_of_week, day_name, is_weekend, week_of_year)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT,
    d::DATE,
    EXTRACT(DAY     FROM d)::SMALLINT,
    EXTRACT(MONTH   FROM d)::SMALLINT,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(YEAR    FROM d)::SMALLINT,
    EXTRACT(DOW     FROM d)::SMALLINT,
    TO_CHAR(d, 'FMDay'),
    EXTRACT(DOW FROM d) IN (0, 6),
    EXTRACT(WEEK    FROM d)::SMALLINT
FROM generate_series('2010-01-01'::DATE, '2025-12-31'::DATE, '1 day'::INTERVAL) AS d;

-- -----------------------------------------------------------------------------
-- 2. dim_club: copy directly from relational source
-- -----------------------------------------------------------------------------
INSERT INTO dimensional.dim_club
    (club_id, name, city, country, stadium_name, stadium_capacity)
SELECT
    club_id, name, city, country, stadium, capacity
FROM relational.clubs;

-- -----------------------------------------------------------------------------
-- 3. dim_player: flatten name, compute age group at end of 2024/25 season
-- -----------------------------------------------------------------------------
INSERT INTO dimensional.dim_player
    (player_id, full_name, nationality, position, birth_year, age_group)
SELECT
    player_id,
    first_name || ' ' || last_name AS full_name,
    nationality,
    position,
    EXTRACT(YEAR FROM birth_date)::SMALLINT,
    CASE
        WHEN DATE_PART('year', AGE('2025-06-01', birth_date)) < 23  THEN 'Under 23'
        WHEN DATE_PART('year', AGE('2025-06-01', birth_date)) <= 27 THEN '23-27'
        WHEN DATE_PART('year', AGE('2025-06-01', birth_date)) <= 32 THEN '28-32'
        ELSE 'Over 32'
    END
FROM relational.players;

-- -----------------------------------------------------------------------------
-- 4. dim_season
-- -----------------------------------------------------------------------------
INSERT INTO dimensional.dim_season (season_id, name, start_date, end_date)
SELECT season_id, name, start_date, end_date
FROM relational.seasons;

-- -----------------------------------------------------------------------------
-- 5. fact_match_results
--    One row per match; card counts pre-aggregated from relational.cards
-- -----------------------------------------------------------------------------
INSERT INTO dimensional.fact_match_results (
    source_match_id,
    date_key, home_club_key, away_club_key, season_key,
    home_goals, away_goals, attendance,
    home_yellow_cards, away_yellow_cards,
    home_red_cards,    away_red_cards,
    home_win, away_win, draw
)
SELECT
    m.match_id,
    TO_CHAR(m.match_date, 'YYYYMMDD')::INT AS date_key,
    hdc.club_key,
    adc.club_key,
    ds.season_key,
    m.home_goals,
    m.away_goals,
    m.attendance,
    COALESCE(SUM(CASE WHEN c.club_id = m.home_club_id AND c.card_type = 'yellow' THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN c.club_id = m.away_club_id AND c.card_type = 'yellow' THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN c.club_id = m.home_club_id AND c.card_type = 'red'    THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN c.club_id = m.away_club_id AND c.card_type = 'red'    THEN 1 ELSE 0 END), 0),
    m.home_goals > m.away_goals,
    m.away_goals > m.home_goals,
    m.home_goals = m.away_goals
FROM relational.matches m
JOIN dimensional.dim_club   hdc ON m.home_club_id = hdc.club_id
JOIN dimensional.dim_club   adc ON m.away_club_id = adc.club_id
JOIN dimensional.dim_season ds  ON m.season_id    = ds.season_id
LEFT JOIN relational.cards  c   ON m.match_id     = c.match_id
GROUP BY
    m.match_id, m.match_date,
    hdc.club_key, adc.club_key, ds.season_key,
    m.home_goals, m.away_goals, m.attendance;

-- -----------------------------------------------------------------------------
-- 6. fact_player_performance
--    One row per (player, match) pair for any player who scored, assisted,
--    or received a card.  Counts pre-aggregated from goals + cards tables.
-- -----------------------------------------------------------------------------
WITH player_matches AS (
    -- All (player, match) combinations with any recorded activity
    SELECT scorer_id AS player_id, match_id FROM relational.goals
    UNION
    SELECT assist_id,              match_id FROM relational.goals  WHERE assist_id IS NOT NULL
    UNION
    SELECT player_id,              match_id FROM relational.cards
),
goal_agg AS (
    SELECT scorer_id, match_id,
           COUNT(*)                                                   AS goals,
           SUM(CASE WHEN goal_type = 'penalty' THEN 1 ELSE 0 END)    AS penalty_goals
    FROM relational.goals
    GROUP BY scorer_id, match_id
),
assist_agg AS (
    SELECT assist_id, match_id,
           COUNT(*) AS assists
    FROM relational.goals
    WHERE assist_id IS NOT NULL
    GROUP BY assist_id, match_id
),
card_agg AS (
    SELECT player_id, match_id,
           SUM(CASE WHEN card_type = 'yellow' THEN 1 ELSE 0 END) AS yellow_cards,
           SUM(CASE WHEN card_type = 'red'    THEN 1 ELSE 0 END) AS red_cards
    FROM relational.cards
    GROUP BY player_id, match_id
)
INSERT INTO dimensional.fact_player_performance (
    source_match_id,
    date_key, player_key, club_key, season_key,
    goals, assists, yellow_cards, red_cards, penalty_goals
)
SELECT
    m.match_id,
    TO_CHAR(m.match_date, 'YYYYMMDD')::INT,
    dp.player_key,
    dc.club_key,
    ds.season_key,
    COALESCE(ga.goals,         0)::SMALLINT,
    COALESCE(aa.assists,       0)::SMALLINT,
    COALESCE(ca.yellow_cards,  0)::SMALLINT,
    COALESCE(ca.red_cards,     0)::SMALLINT,
    COALESCE(ga.penalty_goals, 0)::SMALLINT
FROM player_matches pm
JOIN relational.matches m     ON pm.match_id  = m.match_id
JOIN relational.players p     ON pm.player_id = p.player_id
JOIN dimensional.dim_player dp ON p.player_id  = dp.player_id
JOIN dimensional.dim_club   dc ON p.club_id    = dc.club_id
JOIN dimensional.dim_season ds ON m.season_id  = ds.season_id
LEFT JOIN goal_agg   ga ON pm.player_id = ga.scorer_id AND pm.match_id = ga.match_id
LEFT JOIN assist_agg aa ON pm.player_id = aa.assist_id AND pm.match_id = aa.match_id
LEFT JOIN card_agg   ca ON pm.player_id = ca.player_id AND pm.match_id = ca.match_id;

-- -----------------------------------------------------------------------------
-- Update statistics for the query planner
-- -----------------------------------------------------------------------------
ANALYZE dimensional.dim_date;
ANALYZE dimensional.dim_club;
ANALYZE dimensional.dim_player;
ANALYZE dimensional.dim_season;
ANALYZE dimensional.fact_match_results;
ANALYZE dimensional.fact_player_performance;

-- Quick row count summary
SELECT 'dim_date'                 AS table_name, COUNT(*) AS rows FROM dimensional.dim_date
UNION ALL
SELECT 'dim_club',                               COUNT(*)         FROM dimensional.dim_club
UNION ALL
SELECT 'dim_player',                             COUNT(*)         FROM dimensional.dim_player
UNION ALL
SELECT 'dim_season',                             COUNT(*)         FROM dimensional.dim_season
UNION ALL
SELECT 'fact_match_results',                     COUNT(*)         FROM dimensional.fact_match_results
UNION ALL
SELECT 'fact_player_performance',                COUNT(*)         FROM dimensional.fact_player_performance
ORDER BY table_name;
