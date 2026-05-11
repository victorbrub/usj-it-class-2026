-- Author: Víctor Barceló
-- =============================================================================
-- KPI Queries on the RELATIONAL MODEL
-- =============================================================================
-- Each KPI block contains:
--   (a) The plain query - run this first to verify results look correct.
--   (b) EXPLAIN ANALYZE - run this to study the execution plan.
--
-- When examining EXPLAIN ANALYZE output, observe:
--   - Number of plan nodes (Hash Join, Seq Scan, Sort, Aggregate, etc.)
--   - "actual time" at each node
--   - Total planning time and execution time at the bottom
--   - Rows estimate vs actual rows (planner accuracy)
-- =============================================================================


-- =============================================================================
-- KPI 1: Top 10 goal scorers in the 2024/25 season
-- =============================================================================
-- Requires joining: goals -> players -> clubs -> matches -> seasons (5 tables)

-- (a) Plain query
SELECT
    p.first_name || ' ' || p.last_name  AS player_name,
    c.name                              AS club,
    p.nationality,
    p.position,
    COUNT(g.goal_id)                    AS goals
FROM relational.goals    g
JOIN relational.players  p ON g.scorer_id    = p.player_id
JOIN relational.clubs    c ON p.club_id       = c.club_id
JOIN relational.matches  m ON g.match_id      = m.match_id
JOIN relational.seasons  s ON m.season_id     = s.season_id
WHERE s.name = '2024/25'
GROUP BY p.player_id, p.first_name, p.last_name, c.name, p.nationality, p.position
ORDER BY goals DESC
LIMIT 10;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    p.first_name || ' ' || p.last_name  AS player_name,
    c.name                              AS club,
    p.nationality,
    p.position,
    COUNT(g.goal_id)                    AS goals
FROM relational.goals    g
JOIN relational.players  p ON g.scorer_id    = p.player_id
JOIN relational.clubs    c ON p.club_id       = c.club_id
JOIN relational.matches  m ON g.match_id      = m.match_id
JOIN relational.seasons  s ON m.season_id     = s.season_id
WHERE s.name = '2024/25'
GROUP BY p.player_id, p.first_name, p.last_name, c.name, p.nationality, p.position
ORDER BY goals DESC
LIMIT 10;


-- =============================================================================
-- KPI 2: League table (standings) for the 2024/25 season
-- =============================================================================
-- Requires a UNION ALL of home/away perspectives plus aggregation.
-- Notice the complexity of combining two sets of match data.

-- (a) Plain query
WITH match_points AS (
    -- Home team perspective
    SELECT
        m.home_club_id                                         AS club_id,
        CASE WHEN m.home_goals > m.away_goals THEN 3
             WHEN m.home_goals = m.away_goals THEN 1
             ELSE 0 END                                        AS points,
        (m.home_goals > m.away_goals)::INT                    AS wins,
        (m.home_goals = m.away_goals)::INT                    AS draws,
        (m.home_goals < m.away_goals)::INT                    AS losses,
        m.home_goals                                           AS scored,
        m.away_goals                                           AS conceded
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'

    UNION ALL

    -- Away team perspective
    SELECT
        m.away_club_id,
        CASE WHEN m.away_goals > m.home_goals THEN 3
             WHEN m.away_goals = m.home_goals THEN 1
             ELSE 0 END,
        (m.away_goals > m.home_goals)::INT,
        (m.away_goals = m.home_goals)::INT,
        (m.away_goals < m.home_goals)::INT,
        m.away_goals,
        m.home_goals
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
)
SELECT
    c.name                                AS club,
    COUNT(*)                              AS played,
    SUM(mp.wins)                          AS wins,
    SUM(mp.draws)                         AS draws,
    SUM(mp.losses)                        AS losses,
    SUM(mp.scored)                        AS goals_for,
    SUM(mp.conceded)                      AS goals_against,
    SUM(mp.scored) - SUM(mp.conceded)     AS goal_diff,
    SUM(mp.points)                        AS points
FROM match_points mp
JOIN relational.clubs c ON mp.club_id = c.club_id
GROUP BY c.club_id, c.name
ORDER BY points DESC, goal_diff DESC, goals_for DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
WITH match_points AS (
    SELECT
        m.home_club_id AS club_id,
        CASE WHEN m.home_goals > m.away_goals THEN 3
             WHEN m.home_goals = m.away_goals THEN 1
             ELSE 0 END AS points,
        (m.home_goals > m.away_goals)::INT AS wins,
        (m.home_goals = m.away_goals)::INT AS draws,
        (m.home_goals < m.away_goals)::INT AS losses,
        m.home_goals AS scored, m.away_goals AS conceded
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    UNION ALL
    SELECT
        m.away_club_id,
        CASE WHEN m.away_goals > m.home_goals THEN 3
             WHEN m.away_goals = m.home_goals THEN 1
             ELSE 0 END,
        (m.away_goals > m.home_goals)::INT,
        (m.away_goals = m.home_goals)::INT,
        (m.away_goals < m.home_goals)::INT,
        m.away_goals, m.home_goals
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
)
SELECT
    c.name, COUNT(*) AS played,
    SUM(mp.wins) AS wins, SUM(mp.draws) AS draws, SUM(mp.losses) AS losses,
    SUM(mp.scored) AS goals_for, SUM(mp.conceded) AS goals_against,
    SUM(mp.scored) - SUM(mp.conceded) AS goal_diff, SUM(mp.points) AS points
FROM match_points mp
JOIN relational.clubs c ON mp.club_id = c.club_id
GROUP BY c.club_id, c.name
ORDER BY points DESC, goal_diff DESC, goals_for DESC;


-- =============================================================================
-- KPI 3: Monthly goal trend across all seasons
-- =============================================================================
-- Requires joining goals -> matches to access match_date, then date arithmetic.

-- (a) Plain query
SELECT
    EXTRACT(YEAR  FROM m.match_date)::INT          AS year,
    EXTRACT(MONTH FROM m.match_date)::INT          AS month,
    TO_CHAR(m.match_date, 'Mon YYYY')              AS period,
    COUNT(g.goal_id)                               AS total_goals,
    COUNT(DISTINCT m.match_id)                     AS matches_played,
    ROUND(COUNT(g.goal_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT m.match_id), 0), 2) AS avg_goals_per_match
FROM relational.matches m
LEFT JOIN relational.goals g ON m.match_id = g.match_id
GROUP BY
    EXTRACT(YEAR  FROM m.match_date),
    EXTRACT(MONTH FROM m.match_date),
    TO_CHAR(m.match_date, 'Mon YYYY')
ORDER BY year, month;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    EXTRACT(YEAR  FROM m.match_date)::INT          AS year,
    EXTRACT(MONTH FROM m.match_date)::INT          AS month,
    TO_CHAR(m.match_date, 'Mon YYYY')              AS period,
    COUNT(g.goal_id)                               AS total_goals,
    COUNT(DISTINCT m.match_id)                     AS matches_played,
    ROUND(COUNT(g.goal_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT m.match_id), 0), 2) AS avg_goals_per_match
FROM relational.matches m
LEFT JOIN relational.goals g ON m.match_id = g.match_id
GROUP BY
    EXTRACT(YEAR  FROM m.match_date),
    EXTRACT(MONTH FROM m.match_date),
    TO_CHAR(m.match_date, 'Mon YYYY')
ORDER BY year, month;


-- =============================================================================
-- KPI 4: Average goals per player by nationality (all seasons combined)
-- =============================================================================
-- Requires joining goals -> players (plus a LEFT JOIN to include players with 0 goals).

-- (a) Plain query
SELECT
    p.nationality,
    COUNT(DISTINCT p.player_id)                         AS total_players,
    COUNT(g.goal_id)                                    AS total_goals,
    ROUND(COUNT(g.goal_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT p.player_id), 0), 2)    AS avg_goals_per_player,
    SUM(CASE WHEN g.goal_type = 'penalty' THEN 1 ELSE 0 END) AS penalty_goals
FROM relational.players p
LEFT JOIN relational.goals g ON p.player_id = g.scorer_id
GROUP BY p.nationality
HAVING COUNT(DISTINCT p.player_id) >= 5
ORDER BY avg_goals_per_player DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    p.nationality,
    COUNT(DISTINCT p.player_id)                         AS total_players,
    COUNT(g.goal_id)                                    AS total_goals,
    ROUND(COUNT(g.goal_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT p.player_id), 0), 2)    AS avg_goals_per_player,
    SUM(CASE WHEN g.goal_type = 'penalty' THEN 1 ELSE 0 END) AS penalty_goals
FROM relational.players p
LEFT JOIN relational.goals g ON p.player_id = g.scorer_id
GROUP BY p.nationality
HAVING COUNT(DISTINCT p.player_id) >= 5
ORDER BY avg_goals_per_player DESC;


-- =============================================================================
-- KPI 5: Discipline ranking (cards per match) by club in 2024/25
-- =============================================================================
-- Requires joining clubs -> matches (as home OR away) -> seasons -> cards.
-- Notice the OR condition in the join, which is expensive for the planner.

-- (a) Plain query
WITH club_matches AS (
    SELECT m.match_id, m.home_club_id AS club_id
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    UNION ALL
    SELECT m.match_id, m.away_club_id
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
)
SELECT
    c.name                                          AS club,
    COUNT(DISTINCT cm.match_id)                     AS matches_played,
    SUM(CASE WHEN ca.card_type = 'yellow' THEN 1 ELSE 0 END) AS yellow_cards,
    SUM(CASE WHEN ca.card_type = 'red'    THEN 1 ELSE 0 END) AS red_cards,
    COUNT(ca.card_id)                               AS total_cards,
    ROUND(COUNT(ca.card_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT cm.match_id), 0), 2) AS cards_per_match
FROM club_matches cm
JOIN relational.clubs c  ON cm.club_id   = c.club_id
LEFT JOIN relational.cards ca
    ON cm.match_id = ca.match_id AND cm.club_id = ca.club_id
GROUP BY c.club_id, c.name
ORDER BY cards_per_match DESC;

-- (b) Execution plan
EXPLAIN (ANALYZE, BUFFERS)
WITH club_matches AS (
    SELECT m.match_id, m.home_club_id AS club_id
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    UNION ALL
    SELECT m.match_id, m.away_club_id
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
)
SELECT
    c.name,
    COUNT(DISTINCT cm.match_id)                      AS matches_played,
    SUM(CASE WHEN ca.card_type = 'yellow' THEN 1 ELSE 0 END) AS yellow_cards,
    SUM(CASE WHEN ca.card_type = 'red'    THEN 1 ELSE 0 END) AS red_cards,
    COUNT(ca.card_id)                                AS total_cards,
    ROUND(COUNT(ca.card_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT cm.match_id), 0), 2)  AS cards_per_match
FROM club_matches cm
JOIN relational.clubs c  ON cm.club_id   = c.club_id
LEFT JOIN relational.cards ca
    ON cm.match_id = ca.match_id AND cm.club_id = ca.club_id
GROUP BY c.club_id, c.name
ORDER BY cards_per_match DESC;
