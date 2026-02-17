-- ============================================================================= 
-- ADMIN VIEWS
-- Purpose: Comprehensive views for system administrators
-- Access Level: Full access to all data including sensitive information
-- =============================================================================

-- View 1: Complete User Management View
CREATE OR REPLACE VIEW admin_user_management AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.country,
    u.birth_date,
    EXTRACT(YEAR FROM AGE(u.birth_date)) AS age,
    u.registration_date,
    u.role,
    u.account_status,
    u.is_premium,
    u.last_login,
    u.total_spent,
    COUNT(DISTINCT ul.game_id) AS games_owned,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours_played,
    COUNT(DISTINCT r.review_id) AS reviews_written,
    COUNT(DISTINCT ua.achievement_id) AS achievements_unlocked,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_review_rating
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
LEFT JOIN user_achievements ua ON u.user_id = ua.user_id
GROUP BY u.user_id, u.username, u.email, u.country, u.birth_date, 
         u.registration_date, u.role, u.account_status, u.is_premium, 
         u.last_login, u.total_spent;

-- View 2: Financial Overview
CREATE OR REPLACE VIEW admin_financial_overview AS
SELECT 
    pub.name AS publisher,
    g.title AS game,
    g.price AS listed_price,
    COUNT(ul.user_id) AS units_sold,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(ul.purchase_price)::numeric, 2) AS avg_sale_price,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours_played,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    g.metacritic_score
FROM games g
JOIN publishers pub ON g.publisher_id = pub.publisher_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY g.game_id, g.title, g.price, pub.name, g.metacritic_score
ORDER BY total_revenue DESC;

-- View 3: Platform Performance Analytics
CREATE OR REPLACE VIEW admin_platform_analytics AS
SELECT 
    p.name AS platform,
    p.manufacturer,
    p.generation,
    p.release_date,
    COUNT(DISTINCT gp.game_id) AS total_games,
    COUNT(DISTINCT ul.user_id) AS active_users,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS platform_revenue,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_game_score
FROM platforms p
LEFT JOIN game_platforms gp ON p.platform_id = gp.platform_id
LEFT JOIN games g ON gp.game_id = g.game_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
GROUP BY p.platform_id, p.name, p.manufacturer, p.generation, p.release_date;

-- View 4: Complete Game Catalog with All Metrics
CREATE OR REPLACE VIEW admin_complete_game_catalog AS
SELECT 
    g.game_id,
    g.title,
    g.release_date,
    pub.name AS publisher,
    dev.name AS developer,
    gen.name AS genre,
    g.rating AS esrb_rating,
    g.metacritic_score,
    g.price,
    COUNT(DISTINCT ul.user_id) AS owners,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_played,
    COUNT(DISTINCT r.review_id) AS review_count,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    COUNT(DISTINCT a.achievement_id) AS total_achievements,
    STRING_AGG(DISTINCT p.name, ', ') AS available_platforms
FROM games g
JOIN publishers pub ON g.publisher_id = pub.publisher_id
JOIN developers dev ON g.developer_id = dev.developer_id
JOIN genres gen ON g.genre_id = gen.genre_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
LEFT JOIN achievements a ON g.game_id = a.game_id
LEFT JOIN game_platforms gp ON g.game_id = gp.game_id
LEFT JOIN platforms p ON gp.platform_id = p.platform_id
GROUP BY g.game_id, g.title, g.release_date, pub.name, dev.name, 
         gen.name, g.rating, g.metacritic_score, g.price;

-- View 5: User Activity Monitoring
CREATE OR REPLACE VIEW admin_user_activity_monitor AS
SELECT 
    u.user_id,
    u.username,
    u.account_status,
    u.role,
    u.last_login,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - u.last_login)) AS days_since_last_login,
    u.registration_date,
    EXTRACT(DAY FROM (CURRENT_DATE - u.registration_date)) AS days_since_registration,
    COUNT(DISTINCT ul.game_id) AS games_owned,
    ROUND(u.total_spent::numeric, 2) AS total_spent,
    COUNT(DISTINCT r.review_id) AS reviews_count,
    MAX(ul.purchase_date) AS last_purchase_date
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
GROUP BY u.user_id, u.username, u.account_status, u.role, u.last_login, 
         u.registration_date, u.total_spent
ORDER BY u.last_login DESC;
