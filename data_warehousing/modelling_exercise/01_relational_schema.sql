-- Author: Víctor Barceló
-- =============================================================================
-- Relational (Normalized) Schema - Football League Database
-- =============================================================================
-- This schema represents a fully normalized (3NF) relational model.
-- Data is split across multiple tables to eliminate redundancy, enforce
-- referential integrity, and support transactional workloads.
-- =============================================================================

DROP SCHEMA IF EXISTS relational CASCADE;
CREATE SCHEMA relational;

-- Clubs
CREATE TABLE relational.clubs (
    club_id     SERIAL       PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    city        VARCHAR(100),
    country     VARCHAR(50)  DEFAULT 'Spain',
    founded     INT,
    stadium     VARCHAR(100),
    capacity    INT
);

-- Players
CREATE TABLE relational.players (
    player_id   SERIAL      PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    birth_date  DATE,
    nationality VARCHAR(50),
    position    VARCHAR(5)  CHECK (position IN ('GK','DEF','MID','FWD')),
    club_id     INT         REFERENCES relational.clubs(club_id)
);
CREATE INDEX idx_players_club ON relational.players(club_id);
CREATE INDEX idx_players_pos  ON relational.players(position);

-- Seasons
CREATE TABLE relational.seasons (
    season_id  SERIAL     PRIMARY KEY,
    name       VARCHAR(10) NOT NULL UNIQUE,  -- e.g. '2023/24'
    start_date DATE,
    end_date   DATE
);

-- Matches
CREATE TABLE relational.matches (
    match_id     SERIAL PRIMARY KEY,
    season_id    INT    NOT NULL REFERENCES relational.seasons(season_id),
    home_club_id INT    NOT NULL REFERENCES relational.clubs(club_id),
    away_club_id INT    NOT NULL REFERENCES relational.clubs(club_id),
    match_date   DATE   NOT NULL,
    attendance   INT,
    home_goals   INT    DEFAULT 0 CHECK (home_goals >= 0),
    away_goals   INT    DEFAULT 0 CHECK (away_goals >= 0),
    CONSTRAINT different_clubs CHECK (home_club_id <> away_club_id)
);
CREATE INDEX idx_matches_season   ON relational.matches(season_id);
CREATE INDEX idx_matches_home     ON relational.matches(home_club_id);
CREATE INDEX idx_matches_away     ON relational.matches(away_club_id);
CREATE INDEX idx_matches_date     ON relational.matches(match_date);

-- Goals
CREATE TABLE relational.goals (
    goal_id   SERIAL      PRIMARY KEY,
    match_id  INT         NOT NULL REFERENCES relational.matches(match_id),
    scorer_id INT         NOT NULL REFERENCES relational.players(player_id),
    assist_id INT                  REFERENCES relational.players(player_id),
    club_id   INT         NOT NULL REFERENCES relational.clubs(club_id),
    minute    INT         CHECK (minute BETWEEN 1 AND 120),
    goal_type VARCHAR(15) CHECK (goal_type IN ('normal','penalty','free_kick'))
);
CREATE INDEX idx_goals_match  ON relational.goals(match_id);
CREATE INDEX idx_goals_scorer ON relational.goals(scorer_id);
CREATE INDEX idx_goals_assist ON relational.goals(assist_id);
CREATE INDEX idx_goals_club   ON relational.goals(club_id);

-- Cards (disciplinary actions)
CREATE TABLE relational.cards (
    card_id   SERIAL     PRIMARY KEY,
    match_id  INT        NOT NULL REFERENCES relational.matches(match_id),
    player_id INT        NOT NULL REFERENCES relational.players(player_id),
    club_id   INT        NOT NULL REFERENCES relational.clubs(club_id),
    card_type VARCHAR(10) CHECK (card_type IN ('yellow','red')),
    minute    INT        CHECK (minute BETWEEN 1 AND 120)
);
CREATE INDEX idx_cards_match  ON relational.cards(match_id);
CREATE INDEX idx_cards_player ON relational.cards(player_id);
CREATE INDEX idx_cards_club   ON relational.cards(club_id);
