-- ============================================================================= 
-- USER VIEWS
-- Purpose: Basic views for regular users (limited access)
-- Access Level: Own data and public game information only
-- Note: These views include WHERE clauses that should be parameterized with
--       the current user's ID in application code for security
-- =============================================================================

-- View 1: My Game Library
-- Usage: SELECT * FROM user_my_library WHERE user_id = [current_user_id]
CREATE OR REPLACE VIEW user_my_library AS
SELECT 
    u.user_id,
    g.game_id,
    g.title,
    gen.name AS genre,
    pub.name AS publisher,
    g.release_date,
    ul.purchase_date,
    ul.purchase_price,
    g.price AS current_price,
    (g.price - ul.purchase_price) AS price_difference,
    ul.hours_played,
    ROUND((ul.purchase_price / NULLIF(ul.hours_played, 0))::numeric, 2) AS cost_per_hour,
    COUNT(DISTINCT a.achievement_id) AS total_achievements,
    COUNT(DISTINCT ua.achievement_id) AS unlocked_achievements,
    ROUND((COUNT(DISTINCT ua.achievement_id)::numeric / 
           NULLIF(COUNT(DISTINCT a.achievement_id), 0) * 100), 2) AS completion_percentage
FROM users u
JOIN user_library ul ON u.user_id = ul.user_id
JOIN games g ON ul.game_id = g.game_id
JOIN genres gen ON g.genre_id = gen.genre_id
JOIN publishers pub ON g.publisher_id = pub.publisher_id
LEFT JOIN achievements a ON g.game_id = a.game_id
LEFT JOIN user_achievements ua ON a.achievement_id = ua.achievement_id 
                                AND ua.user_id = u.user_id
GROUP BY u.user_id, g.game_id, g.title, gen.name, pub.name, 
         g.release_date, ul.purchase_date, ul.purchase_price, 
         g.price, ul.hours_played;

-- View 2: My Gaming Statistics
-- Usage: SELECT * FROM user_my_statistics WHERE user_id = [current_user_id]
CREATE OR REPLACE VIEW user_my_statistics AS
SELECT 
    u.user_id,
    u.username,
    u.registration_date,
    u.is_premium,
    EXTRACT(DAY FROM (CURRENT_DATE - u.registration_date)) AS days_as_member,
    COUNT(DISTINCT ul.game_id) AS total_games,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_spent,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours_played,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_per_game,
    COUNT(DISTINCT r.review_id) AS reviews_written,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_rating_given,
    COUNT(DISTINCT ua.achievement_id) AS achievements_unlocked,
    COUNT(DISTINCT gen.genre_id) AS genres_played,
    STRING_AGG(DISTINCT gen.name, ', ' ORDER BY gen.name) AS favorite_genres
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
LEFT JOIN user_achievements ua ON u.user_id = ua.user_id
LEFT JOIN games g ON ul.game_id = g.game_id
LEFT JOIN genres gen ON g.genre_id = gen.genre_id
GROUP BY u.user_id, u.username, u.registration_date, u.is_premium;

-- View 3: Public Game Catalog
-- Available to all users for browsing
CREATE OR REPLACE VIEW user_game_catalog AS
SELECT 
    g.game_id,
    g.title,
    gen.name AS genre,
    pub.name AS publisher,
    dev.name AS developer,
    g.release_date,
    g.rating AS esrb_rating,
    g.price,
    g.metacritic_score,
    COUNT(DISTINCT r.review_id) AS review_count,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    COUNT(DISTINCT ul.user_id) AS owners,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_playtime,
    STRING_AGG(DISTINCT p.name, ', ' ORDER BY p.name) AS platforms
FROM games g
JOIN genres gen ON g.genre_id = gen.genre_id
JOIN publishers pub ON g.publisher_id = pub.publisher_id
JOIN developers dev ON g.developer_id = dev.developer_id
LEFT JOIN reviews r ON g.game_id = r.game_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN game_platforms gp ON g.game_id = gp.game_id
LEFT JOIN platforms p ON gp.platform_id = p.platform_id
GROUP BY g.game_id, g.title, gen.name, pub.name, dev.name, 
         g.release_date, g.rating, g.price, g.metacritic_score;

-- View 4: My Reviews and Ratings
-- Usage: SELECT * FROM user_my_reviews WHERE user_id = [current_user_id]
CREATE OR REPLACE VIEW user_my_reviews AS
SELECT 
    u.user_id,
    r.review_id,
    g.title AS game_title,
    g.game_id,
    r.rating,
    r.review_text,
    r.review_date,
    r.helpful_count,
    COUNT(DISTINCT other_r.review_id) AS total_game_reviews,
    ROUND(AVG(other_r.rating)::numeric, 2) AS avg_game_rating,
    CASE 
        WHEN r.rating > AVG(other_r.rating) THEN 'Above Average'
        WHEN r.rating < AVG(other_r.rating) THEN 'Below Average'
        ELSE 'Average'
    END AS rating_comparison
FROM users u
JOIN reviews r ON u.user_id = r.user_id
JOIN games g ON r.game_id = g.game_id
LEFT JOIN reviews other_r ON g.game_id = other_r.game_id
GROUP BY u.user_id, r.review_id, g.title, g.game_id, r.rating, 
         r.review_text, r.review_date, r.helpful_count
ORDER BY r.review_date DESC;

-- View 5: My Achievements Progress
-- Usage: SELECT * FROM user_my_achievements WHERE user_id = [current_user_id]
CREATE OR REPLACE VIEW user_my_achievements AS
SELECT 
    u.user_id,
    g.game_id,
    g.title AS game_title,
    a.achievement_id,
    a.name AS achievement_name,
    a.description,
    a.points,
    ua.unlocked_date,
    CASE 
        WHEN ua.unlocked_date IS NOT NULL THEN TRUE 
        ELSE FALSE 
    END AS is_unlocked,
    COUNT(DISTINCT all_ua.user_id) AS users_who_unlocked,
    COUNT(DISTINCT ul.user_id) AS total_game_owners,
    ROUND((COUNT(DISTINCT all_ua.user_id)::numeric / 
           NULLIF(COUNT(DISTINCT ul.user_id), 0) * 100), 2) AS rarity_percentage
FROM users u
CROSS JOIN games g
JOIN achievements a ON g.game_id = a.game_id
LEFT JOIN user_achievements ua ON a.achievement_id = ua.achievement_id 
                                AND ua.user_id = u.user_id
LEFT JOIN user_achievements all_ua ON a.achievement_id = all_ua.achievement_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN user_library my_ul ON g.game_id = my_ul.game_id 
                              AND my_ul.user_id = u.user_id
WHERE my_ul.user_id IS NOT NULL
GROUP BY u.user_id, g.game_id, g.title, a.achievement_id, 
         a.name, a.description, a.points, ua.unlocked_date
ORDER BY g.title, 
         CASE WHEN ua.unlocked_date IS NOT NULL THEN 0 ELSE 1 END,
         a.points DESC;

-- View 6: Game Recommendations
-- Usage: SELECT * FROM user_game_recommendations WHERE user_id = [current_user_id]
CREATE OR REPLACE VIEW user_game_recommendations AS
SELECT DISTINCT
    u.user_id,
    g.game_id,
    g.title,
    gen.name AS genre,
    pub.name AS publisher,
    g.price,
    g.metacritic_score,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    COUNT(DISTINCT r.review_id) AS review_count,
    'Based on your genre preferences' AS recommendation_reason
FROM users u
CROSS JOIN games g
JOIN genres gen ON g.genre_id = gen.genre_id
JOIN publishers pub ON g.publisher_id = pub.publisher_id
LEFT JOIN reviews r ON g.game_id = r.game_id
WHERE g.game_id NOT IN (
    SELECT ul.game_id 
    FROM user_library ul 
    WHERE ul.user_id = u.user_id
)
AND gen.genre_id IN (
    SELECT DISTINCT g2.genre_id
    FROM user_library ul2
    JOIN games g2 ON ul2.game_id = g2.game_id
    WHERE ul2.user_id = u.user_id
)
GROUP BY u.user_id, g.game_id, g.title, gen.name, pub.name, 
         g.price, g.metacritic_score
HAVING AVG(r.rating) >= 7 OR g.metacritic_score >= 80
ORDER BY g.metacritic_score DESC, avg_user_rating DESC;

-- View 7: Popular Reviews (Public)
-- Shows most helpful reviews for games
CREATE OR REPLACE VIEW user_popular_reviews AS
SELECT 
    r.review_id,
    u.username,
    g.title AS game_title,
    g.game_id,
    r.rating,
    r.review_text,
    r.review_date,
    r.helpful_count,
    COUNT(DISTINCT ul.user_id) AS game_owners,
    ROUND((r.helpful_count::numeric / 
           NULLIF(COUNT(DISTINCT ul.user_id), 0) * 100), 2) AS helpful_percentage
FROM reviews r
JOIN users u ON r.user_id = u.user_id
JOIN games g ON r.game_id = g.game_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
WHERE u.account_status = 'active'
GROUP BY r.review_id, u.username, g.title, g.game_id, 
         r.rating, r.review_text, r.review_date, r.helpful_count
HAVING r.helpful_count > 10
ORDER BY r.helpful_count DESC;
