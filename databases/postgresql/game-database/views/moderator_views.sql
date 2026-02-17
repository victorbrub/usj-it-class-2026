-- ============================================================================= 
-- MODERATOR VIEWS
-- Purpose: Views for content moderation and user management
-- Access Level: Limited to user management, reviews, and content moderation
-- =============================================================================

-- View 1: User Moderation Dashboard
CREATE OR REPLACE VIEW moderator_user_dashboard AS
SELECT 
    u.user_id,
    u.username,
    u.country,
    u.registration_date,
    u.account_status,
    u.last_login,
    COUNT(DISTINCT r.review_id) AS reviews_written,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_rating_given,
    SUM(r.helpful_count) AS total_helpful_votes,
    COUNT(DISTINCT ul.game_id) AS games_owned,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours
FROM users u
LEFT JOIN reviews r ON u.user_id = r.user_id
LEFT JOIN user_library ul ON u.user_id = ul.user_id
GROUP BY u.user_id, u.username, u.country, u.registration_date, 
         u.account_status, u.last_login
ORDER BY u.registration_date DESC;

-- View 2: Review Moderation Queue
CREATE OR REPLACE VIEW moderator_review_queue AS
SELECT 
    r.review_id,
    r.review_date,
    u.username,
    u.user_id,
    u.account_status,
    g.title AS game_title,
    r.rating,
    r.review_text,
    r.helpful_count,
    LENGTH(r.review_text) AS review_length,
    COUNT(ur.review_id) AS user_total_reviews
FROM reviews r
JOIN users u ON r.user_id = u.user_id
JOIN games g ON r.game_id = g.game_id
LEFT JOIN reviews ur ON u.user_id = ur.user_id
GROUP BY r.review_id, r.review_date, u.username, u.user_id, 
         u.account_status, g.title, r.rating, r.review_text, r.helpful_count
ORDER BY r.review_date DESC;

-- View 3: Suspicious Activity Monitor
CREATE OR REPLACE VIEW moderator_suspicious_activity AS
SELECT 
    u.user_id,
    u.username,
    u.account_status,
    u.registration_date,
    COUNT(DISTINCT r.review_id) AS reviews_in_short_time,
    MIN(r.review_date) AS first_review,
    MAX(r.review_date) AS last_review,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_rating,
    CASE 
        WHEN COUNT(r.review_id) > 10 
             AND MAX(r.review_date)::date - MIN(r.review_date)::date < 7 
        THEN 'High Review Velocity'
        WHEN AVG(r.rating) = 10 AND COUNT(r.review_id) > 5 
        THEN 'Suspiciously Positive'
        WHEN AVG(r.rating) <= 2 AND COUNT(r.review_id) > 3 
        THEN 'Suspiciously Negative'
        ELSE 'Normal'
    END AS suspicion_flag
FROM users u
LEFT JOIN reviews r ON u.user_id = r.user_id
GROUP BY u.user_id, u.username, u.account_status, u.registration_date
HAVING COUNT(r.review_id) > 0
ORDER BY reviews_in_short_time DESC;

-- View 4: Most Helpful Reviews
CREATE OR REPLACE VIEW moderator_top_reviews AS
SELECT 
    r.review_id,
    u.username,
    g.title AS game_title,
    r.rating,
    LEFT(r.review_text, 150) AS review_preview,
    r.helpful_count,
    r.review_date,
    ROUND((r.helpful_count::numeric / NULLIF(
        (SELECT COUNT(*) FROM user_library WHERE game_id = r.game_id), 0
    ) * 100), 2) AS helpful_percentage
FROM reviews r
JOIN users u ON r.user_id = u.user_id
JOIN games g ON r.game_id = g.game_id
WHERE r.helpful_count > 0
ORDER BY r.helpful_count DESC;

-- View 5: User Behavior Patterns
CREATE OR REPLACE VIEW moderator_user_patterns AS
SELECT 
    u.user_id,
    u.username,
    u.country,
    u.account_status,
    u.is_premium,
    COUNT(DISTINCT ul.game_id) AS games_owned,
    COUNT(DISTINCT r.review_id) AS reviews_written,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_per_game,
    COUNT(DISTINCT ua.achievement_id) AS achievements_unlocked,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'Non-Reviewer'
        WHEN COUNT(r.review_id) >= 10 THEN 'Prolific Reviewer'
        WHEN COUNT(r.review_id) BETWEEN 5 AND 9 THEN 'Active Reviewer'
        ELSE 'Casual Reviewer'
    END AS reviewer_type,
    CASE 
        WHEN AVG(ul.hours_played) > 100 THEN 'Hardcore Gamer'
        WHEN AVG(ul.hours_played) BETWEEN 50 AND 100 THEN 'Dedicated Player'
        WHEN AVG(ul.hours_played) BETWEEN 20 AND 49 THEN 'Regular Player'
        ELSE 'Casual Player'
    END AS player_type
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
LEFT JOIN user_achievements ua ON u.user_id = ua.user_id
GROUP BY u.user_id, u.username, u.country, u.account_status, u.is_premium
ORDER BY reviews_written DESC;

-- View 6: Content Report Summary
CREATE OR REPLACE VIEW moderator_content_summary AS
SELECT 
    g.title AS game_title,
    pub.name AS publisher,
    gen.name AS genre,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    SUM(r.helpful_count) AS total_helpful_votes,
    COUNT(DISTINCT CASE WHEN r.rating <= 3 THEN r.review_id END) AS negative_reviews,
    COUNT(DISTINCT CASE WHEN r.rating >= 8 THEN r.review_id END) AS positive_reviews,
    MAX(r.review_date) AS last_review_date
FROM games g
JOIN publishers pub ON g.publisher_id = pub.publisher_id
JOIN genres gen ON g.genre_id = gen.genre_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY g.game_id, g.title, pub.name, gen.name
HAVING COUNT(r.review_id) > 0
ORDER BY total_reviews DESC;
