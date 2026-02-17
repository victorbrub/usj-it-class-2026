-- USEFUL QUERIES FOR GAME DATABASE
-- These queries provide valuable insights for different business needs

-- =============================================================================
-- QUERY 1: Top Rated Games by Genre (LOW LEVEL)
-- Purpose: Find highly-rated games grouped by genre for recommendations
-- =============================================================================
SELECT 
    g.name AS genre,
    gm.title,
    gm.metacritic_score,
    p.name AS publisher,
    gm.price
FROM games gm
JOIN genres g ON gm.genre_id = g.genre_id
JOIN publishers p ON gm.publisher_id = p.publisher_id
WHERE gm.metacritic_score >= 90
ORDER BY g.name, gm.metacritic_score DESC;


-- =============================================================================
-- QUERY 2: User Engagement Analysis (MID LEVEL)
-- Purpose: Analyze user library size, spending, and playtime
-- =============================================================================
SELECT 
    u.username,
    u.country,
    u.role,
    u.is_premium,
    COUNT(ul.game_id) AS games_owned,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_spent,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_per_game
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
WHERE u.account_status = 'active'
GROUP BY u.user_id, u.username, u.country, u.role, u.is_premium
ORDER BY total_spent DESC;


-- =============================================================================
-- QUERY 3: Game Performance by Platform (MID LEVEL)
-- Purpose: Compare game availability and pricing across different platforms
-- =============================================================================
SELECT 
    p.name AS platform,
    p.manufacturer,
    COUNT(DISTINCT gp.game_id) AS games_available,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_metacritic_score,
    ROUND(AVG(g.price)::numeric, 2) AS avg_game_price,
    COUNT(DISTINCT CASE WHEN g.metacritic_score >= 90 THEN g.game_id END) AS highly_rated_games
FROM platforms p
LEFT JOIN game_platforms gp ON p.platform_id = gp.platform_id
LEFT JOIN games g ON gp.game_id = g.game_id
GROUP BY p.platform_id, p.name, p.manufacturer
ORDER BY games_available DESC;


-- =============================================================================
-- QUERY 4: Publisher Revenue and User Satisfaction Analysis (MID-HIGH LEVEL)
-- Purpose: Evaluate publisher performance based on revenue and reviews
-- =============================================================================
SELECT 
    pub.name AS publisher,
    pub.country,
    COUNT(DISTINCT g.game_id) AS games_published,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    COUNT(DISTINCT ul.user_id) AS unique_customers,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_metacritic
FROM publishers pub
JOIN games g ON pub.publisher_id = g.publisher_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY pub.publisher_id, pub.name, pub.country
HAVING COUNT(DISTINCT g.game_id) > 0
ORDER BY total_revenue DESC;


-- =============================================================================
-- QUERY 5: Premium vs Regular User Behavior Comparison (MID LEVEL)
-- Purpose: Compare spending and engagement between premium and regular users
-- =============================================================================
SELECT 
    u.is_premium,
    COUNT(DISTINCT u.user_id) AS user_count,
    ROUND(AVG(user_stats.games_owned)::numeric, 2) AS avg_games_owned,
    ROUND(AVG(user_stats.total_spent)::numeric, 2) AS avg_spent_per_user,
    ROUND(AVG(user_stats.total_hours)::numeric, 2) AS avg_hours_played,
    ROUND(AVG(user_stats.reviews_written)::numeric, 2) AS avg_reviews_written,
    ROUND(AVG(user_stats.achievements_unlocked)::numeric, 2) AS avg_achievements
FROM users u
LEFT JOIN (
    SELECT 
        ul.user_id,
        COUNT(DISTINCT ul.game_id) AS games_owned,
        SUM(ul.purchase_price) AS total_spent,
        SUM(ul.hours_played) AS total_hours,
        COUNT(DISTINCT r.review_id) AS reviews_written,
        COUNT(DISTINCT ua.achievement_id) AS achievements_unlocked
    FROM user_library ul
    LEFT JOIN reviews r ON ul.user_id = r.user_id
    LEFT JOIN user_achievements ua ON ul.user_id = ua.user_id
    GROUP BY ul.user_id
) user_stats ON u.user_id = user_stats.user_id
WHERE u.account_status = 'active'
GROUP BY u.is_premium
ORDER BY u.is_premium DESC;


-- =============================================================================
-- BONUS QUERIES
-- =============================================================================

-- Most Played Games Overall
SELECT 
    g.title,
    COUNT(ul.user_id) AS owners,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours
FROM games g
JOIN user_library ul ON g.game_id = ul.game_id
GROUP BY g.game_id, g.title
ORDER BY total_hours DESC
LIMIT 10;

-- Games with Best Price-to-Quality Ratio
SELECT 
    g.title,
    g.price,
    g.metacritic_score,
    ROUND((g.metacritic_score / NULLIF(g.price, 0))::numeric, 2) AS value_score
FROM games g
WHERE g.price > 0
ORDER BY value_score DESC
LIMIT 15;
