-- ============================================================
-- generate_data.sql
-- Synthetic data generator for the GameVerse optimization exercises
-- ============================================================
--
-- Strategy: insert N users, then for each table cross-join users
-- with games / achievements and keep each pair with probability p.
-- This guarantees all FK references are valid (IDs come directly
-- from the real tables) and requires no temp tables or complex logic.
--
-- Approximate row counts with default probabilities
-- (based on 50,000 users, 37 games, 28 achievements):
--
--   user_library     : 50,000 * 37 * 0.108  ≈    200,000 rows
--   reviews          : 50,000 * 37 * 0.054  ≈    100,000 rows
--   user_achievements: 50,000 * 28 * 0.357  ≈    500,000 rows
--
-- Adjust the probabilities below to scale the dataset up or down.
-- ============================================================

-- Author: Víctor Barceló

SET app.num_users       = '100000';
SET app.p_library       = '0.108';
SET app.p_reviews       = '0.054';
SET app.p_achievements  = '0.357';

-- Performance settings for bulk loading.
-- synchronous_commit = off: skip WAL fsync after each statement (biggest speedup).
--   Data is still crash-safe once COMMIT completes.
-- work_mem: gives the CROSS JOIN hash join more memory to avoid disk spills.
SET synchronous_commit = off;
SET work_mem = '128MB';

-- Truncate all affected tables so this script can be re-run cleanly.
-- RESTART IDENTITY resets all SERIAL sequences back to 1.
-- CASCADE handles FK-dependent tables in the correct order automatically.
-- WARNING: this removes ALL existing rows, including the seed data from insert_data.sql.
-- Re-run insert_data.sql afterwards if you need the original seed rows back.
TRUNCATE users, user_library, reviews, user_achievements RESTART IDENTITY CASCADE;

-- Wrap all inserts in a single transaction: one fsync instead of four.
BEGIN;

-- ============================================================
-- 1. Users
-- ============================================================
INSERT INTO users (
    username, email, registration_date, country, birth_date,
    role, account_status, is_premium, last_login, total_spent
)
SELECT
    'user_' || i,
    'user_' || i || '@gameverse.com',
    DATE '2018-01-01' + (random() * 2557)::int,
    CASE (i % 6)
        WHEN 0 THEN 'ES' WHEN 1 THEN 'US' WHEN 2 THEN 'FR'
        WHEN 3 THEN 'DE' WHEN 4 THEN 'JP' ELSE 'BR'
    END,
    DATE '1980-01-01' + (random() * 15000)::int,
    CASE (i % 20) WHEN 0 THEN 'moderator' WHEN 1 THEN 'analyst' ELSE 'user' END,
    CASE (i % 30) WHEN 0 THEN 'suspended' ELSE 'active' END,
    (i % 4 = 0),
    NOW() - ((random() * 365)::int || ' days')::interval,
    (random() * 2000)::numeric(10,2)
FROM generate_series(1, current_setting('app.num_users')::int) i;

-- ============================================================
-- 2. User library  (random subset of games per user)
-- ============================================================
-- Each (user, game) pair is kept with probability p_library.
-- The WHERE random() < p filter is evaluated once per combination,
-- so every user ends up owning a different random selection of games.
INSERT INTO user_library (user_id, game_id, purchase_date, purchase_price, hours_played)
SELECT
    u.user_id,
    g.game_id,
    DATE '2018-01-01' + (random() * 2557)::int,
    (random() * 70 + 0.99)::numeric(6,2),
    (random() * 5000)::numeric(8,2)
FROM users  u
CROSS JOIN games g
WHERE random() < current_setting('app.p_library')::numeric;

-- ============================================================
-- 3. Reviews  (random subset of games per user)
-- ============================================================
INSERT INTO reviews (user_id, game_id, rating, review_text, review_date, helpful_count)
SELECT
    u.user_id,
    g.game_id,
    (random() * 9 + 1)::int,
    'Synthetic review by user ' || u.user_id || ' for game ' || g.game_id,
    DATE '2018-01-01' + (random() * 2557)::int,
    (random() * 500)::int
FROM users  u
CROSS JOIN games g
WHERE random() < current_setting('app.p_reviews')::numeric;

-- ============================================================
-- 4. User achievements  (random subset of achievements per user)
-- ============================================================
INSERT INTO user_achievements (user_id, achievement_id, unlocked_date)
SELECT
    u.user_id,
    a.achievement_id,
    NOW() - ((random() * 1000)::int || ' days')::interval
FROM users        u
CROSS JOIN achievements a
WHERE random() < current_setting('app.p_achievements')::numeric;

COMMIT;

-- Restore defaults.
SET synchronous_commit = on;
SET work_mem = '4MB';

-- ============================================================
-- 5. Refresh planner statistics
-- ============================================================
ANALYZE users, user_library, reviews, user_achievements;

-- ============================================================
-- 6. Verify row counts
-- ============================================================
SELECT 'users'            AS tbl, COUNT(*) FROM users
UNION ALL
SELECT 'user_library',           COUNT(*) FROM user_library
UNION ALL
SELECT 'reviews',                COUNT(*) FROM reviews
UNION ALL
SELECT 'user_achievements',      COUNT(*) FROM user_achievements;
