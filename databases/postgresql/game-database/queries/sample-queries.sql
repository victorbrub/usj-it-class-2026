-- BASIC QUERIES
-- 1. Find all games with metacritic score above 90
SELECT title, metacritic_score FROM games WHERE metacritic_score > 90;

-- JOINS
-- 2. Get games with their publishers and developers
SELECT g.title, p.name as publisher, d.name as developer
FROM games g
JOIN publishers p ON g.publisher_id = p.publisher_id
JOIN developers d ON g.developer_id = d.developer_id;

-- AGGREGATIONS
-- 3. Average hours played per game
SELECT g.title, AVG(ul.hours_played) as avg_hours
FROM games g
JOIN user_library ul ON g.game_id = ul.game_id
GROUP BY g.game_id, g.title
ORDER BY avg_hours DESC;

-- SUBQUERIES
-- 4. Find users who own more than 2 games
SELECT username, 
       (SELECT COUNT(*) FROM user_library WHERE user_id = u.user_id) as game_count
FROM users u
WHERE (SELECT COUNT(*) FROM user_library WHERE user_id = u.user_id) > 2;

-- WINDOW FUNCTIONS
-- 5. Rank games by average user rating
SELECT g.title, 
       AVG(r.rating) as avg_rating,
       RANK() OVER (ORDER BY AVG(r.rating) DESC) as rank
FROM games g
JOIN reviews r ON g.game_id = r.game_id
GROUP BY g.game_id, g.title;

-- COMPLEX JOINS
-- 6. Games available on multiple platforms
SELECT g.title, COUNT(gp.platform_id) as platform_count,
       STRING_AGG(p.name, ', ') as platforms
FROM games g
JOIN game_platforms gp ON g.game_id = gp.game_id
JOIN platforms p ON gp.platform_id = p.platform_id
GROUP BY g.game_id, g.title
HAVING COUNT(gp.platform_id) > 2;