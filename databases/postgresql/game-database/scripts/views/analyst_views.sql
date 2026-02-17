-- ============================================================================= 
-- ANALYST VIEWS
-- Purpose: Statistical analysis and business intelligence views
-- Access Level: Aggregate data and trends (no sensitive personal information)
-- =============================================================================

-- View 1: Game Performance Metrics
CREATE OR REPLACE VIEW analyst_game_performance AS
SELECT 
    g.title,
    gen.name AS genre,
    pub.name AS publisher,
    dev.name AS developer,
    g.release_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, g.release_date)) AS years_since_release,
    g.price,
    g.metacritic_score,
    COUNT(DISTINCT ul.user_id) AS total_owners,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(ul.purchase_price)::numeric, 2) AS avg_purchase_price,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_played,
    ROUND(SUM(ul.hours_played)::numeric, 2) AS total_hours_played,
    COUNT(DISTINCT r.review_id) AS review_count,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    ROUND((COUNT(DISTINCT ul.user_id)::numeric / NULLIF(
        (SELECT COUNT(*) FROM users WHERE account_status = 'active'), 0
    ) * 100), 2) AS market_penetration_pct
FROM games g
JOIN genres gen ON g.genre_id = gen.genre_id
JOIN publishers pub ON g.publisher_id = pub.publisher_id
JOIN developers dev ON g.developer_id = dev.developer_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY g.game_id, g.title, gen.name, pub.name, dev.name, 
         g.release_date, g.price, g.metacritic_score;

-- View 2: Genre Popularity Trends
CREATE OR REPLACE VIEW analyst_genre_trends AS
SELECT 
    gen.name AS genre,
    COUNT(DISTINCT g.game_id) AS games_in_genre,
    COUNT(DISTINCT ul.user_id) AS unique_players,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_metacritic,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    ROUND(AVG(g.price)::numeric, 2) AS avg_price,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_per_game,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND((COUNT(DISTINCT ul.user_id)::numeric / 
           NULLIF(COUNT(DISTINCT g.game_id), 0)), 2) AS avg_players_per_game
FROM genres gen
LEFT JOIN games g ON gen.genre_id = g.genre_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY gen.genre_id, gen.name
ORDER BY total_revenue DESC;

-- View 3: Platform Market Share Analysis
CREATE OR REPLACE VIEW analyst_platform_market_share AS
SELECT 
    p.name AS platform,
    p.manufacturer,
    p.generation,
    COUNT(DISTINCT gp.game_id) AS available_games,
    COUNT(DISTINCT ul.user_id) AS active_users,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(g.price)::numeric, 2) AS avg_game_price,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_game_quality,
    ROUND((COUNT(DISTINCT gp.game_id)::numeric / 
           NULLIF((SELECT COUNT(*) FROM games), 0) * 100), 2) AS game_library_pct,
    ROUND((SUM(ul.purchase_price) / 
           NULLIF((SELECT SUM(purchase_price) FROM user_library), 0) * 100), 2) AS revenue_share_pct
FROM platforms p
LEFT JOIN game_platforms gp ON p.platform_id = gp.platform_id
LEFT JOIN games g ON gp.game_id = g.game_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
GROUP BY p.platform_id, p.name, p.manufacturer, p.generation
ORDER BY total_revenue DESC;

-- View 4: Publisher Performance Comparison
CREATE OR REPLACE VIEW analyst_publisher_comparison AS
SELECT 
    pub.name AS publisher,
    pub.country,
    pub.founded_year,
    EXTRACT(YEAR FROM CURRENT_DATE) - pub.founded_year AS years_in_business,
    COUNT(DISTINCT g.game_id) AS games_published,
    COUNT(DISTINCT dev.developer_id) AS unique_developers,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_metacritic,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    COUNT(DISTINCT ul.user_id) AS total_customers,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(ul.purchase_price)::numeric, 2) AS avg_revenue_per_sale,
    ROUND(SUM(ul.purchase_price) / NULLIF(COUNT(DISTINCT g.game_id), 0), 2) AS revenue_per_game,
    COUNT(DISTINCT CASE WHEN g.metacritic_score >= 90 THEN g.game_id END) AS critically_acclaimed_games
FROM publishers pub
LEFT JOIN games g ON pub.publisher_id = g.publisher_id
LEFT JOIN developers dev ON g.developer_id = dev.developer_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY pub.publisher_id, pub.name, pub.country, pub.founded_year
HAVING COUNT(DISTINCT g.game_id) > 0
ORDER BY total_revenue DESC;

-- View 5: User Demographics and Behavior
CREATE OR REPLACE VIEW analyst_user_demographics AS
SELECT 
    u.country,
    u.is_premium,
    COUNT(DISTINCT u.user_id) AS user_count,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(u.birth_date)))::numeric, 1) AS avg_age,
    ROUND(AVG(user_stats.games_owned)::numeric, 2) AS avg_games_owned,
    ROUND(AVG(user_stats.total_spent)::numeric, 2) AS avg_spending,
    ROUND(AVG(user_stats.total_hours)::numeric, 2) AS avg_hours_played,
    ROUND(AVG(user_stats.reviews_written)::numeric, 2) AS avg_reviews,
    ROUND(SUM(user_stats.total_spent)::numeric, 2) AS segment_revenue,
    ROUND((SUM(user_stats.total_spent) / 
           NULLIF((SELECT SUM(total_spent) FROM users), 0) * 100), 2) AS revenue_contribution_pct
FROM users u
LEFT JOIN (
    SELECT 
        ul.user_id,
        COUNT(DISTINCT ul.game_id) AS games_owned,
        SUM(ul.purchase_price) AS total_spent,
        SUM(ul.hours_played) AS total_hours,
        COUNT(DISTINCT r.review_id) AS reviews_written
    FROM user_library ul
    LEFT JOIN reviews r ON ul.user_id = r.user_id
    GROUP BY ul.user_id
) user_stats ON u.user_id = user_stats.user_id
WHERE u.account_status = 'active'
GROUP BY u.country, u.is_premium
ORDER BY segment_revenue DESC;

-- View 6: Pricing Strategy Analysis
CREATE OR REPLACE VIEW analyst_pricing_strategy AS
SELECT 
    CASE 
        WHEN g.price = 0 THEN 'Free-to-Play'
        WHEN g.price < 20 THEN 'Budget ($0-$19.99)'
        WHEN g.price < 40 THEN 'Mid-Range ($20-$39.99)'
        WHEN g.price < 60 THEN 'Standard ($40-$59.99)'
        ELSE 'Premium ($60+)'
    END AS price_category,
    COUNT(DISTINCT g.game_id) AS games_count,
    ROUND(AVG(g.price)::numeric, 2) AS avg_price,
    ROUND(AVG(g.metacritic_score)::numeric, 2) AS avg_metacritic,
    COUNT(DISTINCT ul.user_id) AS total_buyers,
    ROUND(SUM(ul.purchase_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(ul.hours_played)::numeric, 2) AS avg_hours_played,
    ROUND(AVG(r.rating)::numeric, 2) AS avg_user_rating,
    ROUND((SUM(ul.purchase_price) / NULLIF(COUNT(DISTINCT ul.user_id), 0)), 2) AS revenue_per_buyer
FROM games g
LEFT JOIN user_library ul ON g.game_id = ul.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY price_category
ORDER BY 
    CASE price_category
        WHEN 'Free-to-Play' THEN 1
        WHEN 'Budget ($0-$19.99)' THEN 2
        WHEN 'Mid-Range ($20-$39.99)' THEN 3
        WHEN 'Standard ($40-$59.99)' THEN 4
        ELSE 5
    END;

-- View 7: Achievement Engagement Analysis
CREATE OR REPLACE VIEW analyst_achievement_engagement AS
SELECT 
    g.title AS game_title,
    gen.name AS genre,
    COUNT(DISTINCT a.achievement_id) AS total_achievements,
    ROUND(AVG(a.points)::numeric, 2) AS avg_achievement_points,
    COUNT(DISTINCT ua.user_id) AS users_with_achievements,
    COUNT(DISTINCT ul.user_id) AS total_owners,
    ROUND((COUNT(DISTINCT ua.user_id)::numeric / 
           NULLIF(COUNT(DISTINCT ul.user_id), 0) * 100), 2) AS achievement_participation_pct,
    COUNT(ua.achievement_id) AS total_unlocks,
    ROUND((COUNT(ua.achievement_id)::numeric / 
           NULLIF((COUNT(DISTINCT a.achievement_id) * COUNT(DISTINCT ul.user_id)), 0) * 100), 2) AS completion_rate_pct
FROM games g
JOIN genres gen ON g.genre_id = gen.genre_id
LEFT JOIN achievements a ON g.game_id = a.game_id
LEFT JOIN user_achievements ua ON a.achievement_id = ua.achievement_id
LEFT JOIN user_library ul ON g.game_id = ul.game_id
GROUP BY g.game_id, g.title, gen.name
HAVING COUNT(DISTINCT a.achievement_id) > 0
ORDER BY achievement_participation_pct DESC;
