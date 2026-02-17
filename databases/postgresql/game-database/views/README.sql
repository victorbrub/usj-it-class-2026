-- =============================================================================
-- VIEWS OVERVIEW AND USAGE GUIDE
-- Game Database - Role-Based Views
-- =============================================================================

/*
This file provides an overview of all views available in the game database,
organized by user role. Each role has access to different levels of information
based on their responsibilities and authorization level.

ROLES HIERARCHY:
1. Admin - Full system access
2. Moderator - Content and user management
3. Analyst - Data analysis and reporting
4. User - Personal data and public information

To create all views, run the view files in this order:
1. admin_views.sql
2. moderator_views.sql
3. analyst_views.sql
4. user_views.sql
*/

-- =============================================================================
-- ADMIN VIEWS (5 views)
-- =============================================================================

/*
1. admin_user_management
   - Complete user profiles with activity metrics
   - Includes email, role, status, spending, and engagement data
   - Use for: User account management, identifying inactive users

2. admin_financial_overview
   - Revenue analysis per game and publisher
   - Shows sales units, average prices, and user ratings
   - Use for: Financial reporting, pricing strategy

3. admin_platform_analytics
   - Platform performance and market metrics
   - Includes game library size, active users, and revenue
   - Use for: Platform strategy, partnership decisions

4. admin_complete_game_catalog
   - Comprehensive game information with all metrics
   - Aggregates ownership, playtime, reviews, achievements
   - Use for: Complete game analysis, catalog management

5. admin_user_activity_monitor
   - User login patterns and engagement tracking
   - Identifies inactive users and purchase behavior
   - Use for: User retention analysis, reactivation campaigns
*/

-- Example Admin Queries:
-- Find users who haven't logged in for 30+ days
SELECT * FROM admin_user_activity_monitor 
WHERE days_since_last_login > 30 
ORDER BY total_spent DESC;

-- Top revenue-generating games
SELECT * FROM admin_financial_overview 
WHERE total_revenue > 1000 
ORDER BY total_revenue DESC;


-- =============================================================================
-- MODERATOR VIEWS (6 views)
-- =============================================================================

/*
1. moderator_user_dashboard
   - User activity overview for moderation
   - Shows review activity, helpful votes, account status
   - Use for: Monitoring user behavior, account management

2. moderator_review_queue
   - All reviews with user and game context
   - Includes review metrics and user history
   - Use for: Content moderation, spam detection

3. moderator_suspicious_activity
   - Flags unusual user behavior patterns
   - Detects review manipulation, spam patterns
   - Use for: Fraud detection, quality control

4. moderator_top_reviews
   - Most helpful reviews across platform
   - Shows helpful percentage and engagement
   - Use for: Featuring quality content, rewarding contributors

5. moderator_user_patterns
   - User behavior classification
   - Categorizes users by review and play patterns
   - Use for: Understanding user segments, targeted moderation

6. moderator_content_summary
   - Review statistics per game
   - Shows positive/negative review distribution
   - Use for: Identifying controversial games, community sentiment
*/

-- Example Moderator Queries:
-- Find potentially suspicious reviewers
SELECT * FROM moderator_suspicious_activity 
WHERE suspicion_flag != 'Normal' 
ORDER BY reviews_in_short_time DESC;

-- Most active reviewers this month
SELECT * FROM moderator_user_dashboard 
WHERE reviews_written > 5 
ORDER BY reviews_written DESC;


-- =============================================================================
-- ANALYST VIEWS (7 views)
-- =============================================================================

/*
1. analyst_game_performance
   - Comprehensive game metrics and KPIs
   - Revenue, engagement, ratings, market penetration
   - Use for: Game performance analysis, trend identification

2. analyst_genre_trends
   - Genre-level aggregated statistics
   - Popularity, revenue, player engagement by genre
   - Use for: Market research, genre strategy

3. analyst_platform_market_share
   - Platform comparison and market share
   - Library size, revenue contribution, game quality
   - Use for: Platform partnership decisions, market analysis

4. analyst_publisher_comparison
   - Publisher performance benchmarking
   - Revenue, game quality, customer reach
   - Use for: Publisher evaluation, partnership decisions

5. analyst_user_demographics
   - User segmentation by country and premium status
   - Spending patterns, behavior metrics, revenue contribution
   - Use for: Marketing strategy, user acquisition planning

6. analyst_pricing_strategy
   - Price category analysis and effectiveness
   - Revenue, engagement, and quality by price point
   - Use for: Pricing optimization, revenue modeling

7. analyst_achievement_engagement
   - Achievement system effectiveness
   - Participation rates, completion metrics
   - Use for: Gamification strategy, engagement optimization
*/

-- Example Analyst Queries:
-- Best performing genre by revenue
SELECT * FROM analyst_genre_trends 
ORDER BY total_revenue DESC 
LIMIT 5;

-- Premium vs regular user comparison
SELECT * FROM analyst_user_demographics 
ORDER BY is_premium DESC, avg_spending DESC;

-- Price vs quality analysis
SELECT * FROM analyst_pricing_strategy 
ORDER BY revenue_per_buyer DESC;


-- =============================================================================
-- USER VIEWS (7 views)
-- =============================================================================

/*
1. user_my_library
   - Personal game collection with detailed stats
   - Shows purchase info, playtime, achievement progress
   - Use for: Personal library management, cost analysis
   - FILTER: WHERE user_id = [current_user_id]

2. user_my_statistics
   - Personal gaming statistics dashboard
   - Lifetime metrics, spending, preferences
   - Use for: Personal insights, gamification
   - FILTER: WHERE user_id = [current_user_id]

3. user_game_catalog (PUBLIC)
   - Browsable game catalog with ratings
   - All games with aggregate user data
   - Use for: Game discovery, purchase decisions

4. user_my_reviews
   - Personal review history with context
   - Shows how reviews compare to others
   - Use for: Managing personal reviews, tracking opinions
   - FILTER: WHERE user_id = [current_user_id]

5. user_my_achievements
   - Achievement tracking across owned games
   - Shows progress, rarity, completion status
   - Use for: Achievement hunting, progress tracking
   - FILTER: WHERE user_id = [current_user_id]

6. user_game_recommendations
   - Personalized game suggestions
   - Based on owned games and preferences
   - Use for: Discovery, purchase suggestions
   - FILTER: WHERE user_id = [current_user_id]

7. user_popular_reviews (PUBLIC)
   - Community's most helpful reviews
   - Quality content for decision making
   - Use for: Reading reviews, making informed purchases
*/

-- Example User Queries (replace 1 with actual user_id):
-- My game library sorted by playtime
SELECT * FROM user_my_library 
WHERE user_id = 1 
ORDER BY hours_played DESC;

-- My gaming stats
SELECT * FROM user_my_statistics 
WHERE user_id = 1;

-- Games I might like
SELECT * FROM user_game_recommendations 
WHERE user_id = 1 
LIMIT 10;

-- My achievement progress in a specific game
SELECT * FROM user_my_achievements 
WHERE user_id = 1 AND game_id = 4 
ORDER BY is_unlocked DESC, points DESC;


-- =============================================================================
-- VIEW MAINTENANCE NOTES
-- =============================================================================

/*
MATERIALIZED VIEWS (Optional Performance Optimization):
For high-traffic scenarios, consider converting some views to materialized views:

-- Example: Create materialized view for game catalog
CREATE MATERIALIZED VIEW user_game_catalog_mat AS
SELECT * FROM user_game_catalog;

-- Refresh periodically (e.g., hourly via cron job)
REFRESH MATERIALIZED VIEW user_game_catalog_mat;

RECOMMENDED FOR MATERIALIZATION:
- user_game_catalog (high read, low write frequency)
- analyst_genre_trends (aggregate data, can be cached)
- analyst_platform_market_share (updated less frequently)

INDEXES FOR VIEW PERFORMANCE:
Create indexes on frequently joined/filtered columns:
- user_library(user_id, game_id)
- reviews(user_id, game_id)
- user_achievements(user_id, achievement_id)
- game_platforms(game_id, platform_id)

SECURITY NOTES:
- User views with user_id filters should be secured at application level
- Never expose admin/moderator views to unauthorized roles
- Implement row-level security (RLS) in PostgreSQL for additional protection
- Log access to sensitive views (admin_user_management, admin_financial_overview)
*/

-- =============================================================================
-- QUICK REFERENCE: View Access Matrix
-- =============================================================================

/*
View Name                          | Admin | Moderator | Analyst | User
-----------------------------------|-------|-----------|---------|------
admin_user_management              |   ✓   |           |         |
admin_financial_overview           |   ✓   |           |         |
admin_platform_analytics           |   ✓   |           |         |
admin_complete_game_catalog        |   ✓   |           |         |
admin_user_activity_monitor        |   ✓   |           |         |
moderator_user_dashboard           |   ✓   |     ✓     |         |
moderator_review_queue             |   ✓   |     ✓     |         |
moderator_suspicious_activity      |   ✓   |     ✓     |         |
moderator_top_reviews              |   ✓   |     ✓     |         |
moderator_user_patterns            |   ✓   |     ✓     |         |
moderator_content_summary          |   ✓   |     ✓     |         |
analyst_game_performance           |   ✓   |     ✓     |    ✓    |
analyst_genre_trends               |   ✓   |     ✓     |    ✓    |
analyst_platform_market_share      |   ✓   |     ✓     |    ✓    |
analyst_publisher_comparison       |   ✓   |     ✓     |    ✓    |
analyst_user_demographics          |   ✓   |           |    ✓    |
analyst_pricing_strategy           |   ✓   |           |    ✓    |
analyst_achievement_engagement     |   ✓   |           |    ✓    |
user_my_library                    |   ✓   |           |         |   ✓
user_my_statistics                 |   ✓   |           |         |   ✓
user_game_catalog                  |   ✓   |     ✓     |    ✓    |   ✓
user_my_reviews                    |   ✓   |           |         |   ✓
user_my_achievements               |   ✓   |           |         |   ✓
user_game_recommendations          |   ✓   |           |         |   ✓
user_popular_reviews               |   ✓   |     ✓     |    ✓    |   ✓
*/
