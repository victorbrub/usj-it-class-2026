-- Author: Víctor Barceló
-- =============================================================================
-- Dimensional (Star Schema) Model - Football League Data Warehouse
-- =============================================================================
-- This schema represents a dimensional model (star schema) optimised for
-- analytical queries. Data is pre-aggregated and denormalised into:
--   - 4 dimension tables:  dim_date, dim_club, dim_player, dim_season
--   - 2 fact tables:       fact_match_results, fact_player_performance
--                          (both RANGE-partitioned by season_key, 15 partitions)
-- =============================================================================

DROP SCHEMA IF EXISTS dimensional CASCADE;
CREATE SCHEMA dimensional;

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- dim_date: one row per calendar day; date_key = YYYYMMDD integer
CREATE TABLE dimensional.dim_date (
    date_key     INT         PRIMARY KEY,  -- e.g. 20240815
    full_date    DATE        NOT NULL,
    day          SMALLINT,
    month        SMALLINT,
    month_name   VARCHAR(20),
    quarter      SMALLINT,
    year         SMALLINT,
    day_of_week  SMALLINT,   -- 0=Sunday .. 6=Saturday
    day_name     VARCHAR(20),
    is_weekend   BOOLEAN,
    week_of_year SMALLINT
);

-- dim_club: one row per club (Type 1 SCD - no history tracking for simplicity)
CREATE TABLE dimensional.dim_club (
    club_key        SERIAL       PRIMARY KEY,
    club_id         INT          NOT NULL,   -- source system key
    name            VARCHAR(100),
    city            VARCHAR(100),
    country         VARCHAR(50),
    stadium_name    VARCHAR(100),
    stadium_capacity INT
);
CREATE INDEX idx_dim_club_id ON dimensional.dim_club(club_id);

-- dim_player: one row per player
CREATE TABLE dimensional.dim_player (
    player_key  SERIAL       PRIMARY KEY,
    player_id   INT          NOT NULL,   -- source system key
    full_name   VARCHAR(100),
    nationality VARCHAR(50),
    position    VARCHAR(5),
    birth_year  SMALLINT,
    age_group   VARCHAR(20)  -- 'Under 23', '23-27', '28-32', 'Over 32'
);
CREATE INDEX idx_dim_player_id  ON dimensional.dim_player(player_id);
CREATE INDEX idx_dim_player_nat ON dimensional.dim_player(nationality);
CREATE INDEX idx_dim_player_pos ON dimensional.dim_player(position);

-- dim_season: one row per competition season
CREATE TABLE dimensional.dim_season (
    season_key SERIAL      PRIMARY KEY,
    season_id  INT         NOT NULL,   -- source system key
    name       VARCHAR(10),
    start_date DATE,
    end_date   DATE
);
CREATE INDEX idx_dim_season_id   ON dimensional.dim_season(season_id);
CREATE INDEX idx_dim_season_name ON dimensional.dim_season(name);

-- =============================================================================
-- FACT TABLES  (range-partitioned by season_key)
-- =============================================================================
-- Partitioning strategy:
--   Both fact tables are partitioned by RANGE on season_key.
--   season_key values 1-15 map to seasons 2010/11 through 2024/25 in the
--   order they were inserted into dim_season.
--
--   When a query filters on ds.name = '2024/25', the planner resolves the
--   matching season_key and accesses only the corresponding partition
--   (partition pruning), skipping all 14 other partitions entirely.
--
--   Indexes declared on the parent table are automatically created on every
--   partition (PostgreSQL 11+).
--
--   Note: a simple SERIAL PRIMARY KEY cannot be used on a partitioned table
--   unless the partition key is included in it.  Fact tables in a DWH do not
--   need a single-column surrogate PK, so it is omitted here.
-- =============================================================================

-- fact_match_results: one row per match
-- Pre-aggregated card counts eliminate runtime joins to the cards table.
CREATE TABLE dimensional.fact_match_results (
    source_match_id     INT      NOT NULL,   -- degenerate dimension (no dim table needed)
    date_key            INT      NOT NULL REFERENCES dimensional.dim_date(date_key),
    home_club_key       INT      NOT NULL REFERENCES dimensional.dim_club(club_key),
    away_club_key       INT      NOT NULL REFERENCES dimensional.dim_club(club_key),
    season_key          INT      NOT NULL REFERENCES dimensional.dim_season(season_key),
    -- Measures
    home_goals          SMALLINT DEFAULT 0,
    away_goals          SMALLINT DEFAULT 0,
    attendance          INT,
    home_yellow_cards   SMALLINT DEFAULT 0,
    away_yellow_cards   SMALLINT DEFAULT 0,
    home_red_cards      SMALLINT DEFAULT 0,
    away_red_cards      SMALLINT DEFAULT 0,
    -- Pre-computed outcome flags (avoids CASE WHEN at query time)
    home_win            BOOLEAN,
    away_win            BOOLEAN,
    draw                BOOLEAN
) PARTITION BY RANGE (season_key);

-- Indexes on the parent propagate automatically to all partitions (PG11+)
CREATE INDEX idx_fmr_date       ON dimensional.fact_match_results(date_key);
CREATE INDEX idx_fmr_home_club  ON dimensional.fact_match_results(home_club_key);
CREATE INDEX idx_fmr_away_club  ON dimensional.fact_match_results(away_club_key);
CREATE INDEX idx_fmr_season     ON dimensional.fact_match_results(season_key);

-- One partition per season (season_key 1=2010/11, 15=2024/25)
DO $$
DECLARE i INT;
BEGIN
    FOR i IN 1..15 LOOP
        EXECUTE format(
            'CREATE TABLE dimensional.fact_match_results_s%s
             PARTITION OF dimensional.fact_match_results
             FOR VALUES FROM (%s) TO (%s)',
            LPAD(i::TEXT, 2, '0'), i, i + 1
        );
    END LOOP;
END;
$$;
-- Catch-all for any unexpected season_key values
CREATE TABLE dimensional.fact_match_results_default
    PARTITION OF dimensional.fact_match_results DEFAULT;


-- fact_player_performance: one row per player per match (only active players)
-- Pre-aggregated goal/assist/card counts eliminate runtime joins to goals/cards.
CREATE TABLE dimensional.fact_player_performance (
    source_match_id INT      NOT NULL,   -- degenerate dimension
    date_key        INT      NOT NULL REFERENCES dimensional.dim_date(date_key),
    player_key      INT      NOT NULL REFERENCES dimensional.dim_player(player_key),
    club_key        INT      NOT NULL REFERENCES dimensional.dim_club(club_key),
    season_key      INT      NOT NULL REFERENCES dimensional.dim_season(season_key),
    -- Measures
    goals           SMALLINT DEFAULT 0,
    assists         SMALLINT DEFAULT 0,
    yellow_cards    SMALLINT DEFAULT 0,
    red_cards       SMALLINT DEFAULT 0,
    penalty_goals   SMALLINT DEFAULT 0
) PARTITION BY RANGE (season_key);

CREATE INDEX idx_fpp_date    ON dimensional.fact_player_performance(date_key);
CREATE INDEX idx_fpp_player  ON dimensional.fact_player_performance(player_key);
CREATE INDEX idx_fpp_club    ON dimensional.fact_player_performance(club_key);
CREATE INDEX idx_fpp_season  ON dimensional.fact_player_performance(season_key);

DO $$
DECLARE i INT;
BEGIN
    FOR i IN 1..15 LOOP
        EXECUTE format(
            'CREATE TABLE dimensional.fact_player_performance_s%s
             PARTITION OF dimensional.fact_player_performance
             FOR VALUES FROM (%s) TO (%s)',
            LPAD(i::TEXT, 2, '0'), i, i + 1
        );
    END LOOP;
END;
$$;
CREATE TABLE dimensional.fact_player_performance_default
    PARTITION OF dimensional.fact_player_performance DEFAULT;
