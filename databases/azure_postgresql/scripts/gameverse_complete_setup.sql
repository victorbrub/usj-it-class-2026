-- ========================================
-- GAMEVERSE DATABASE - COMPLETE SETUP
-- ========================================
-- This script contains all SQL needed to set up the GameVerse database
-- including database creation, table schemas, and sample data.
--
-- FOR AZURE POSTGRESQL:
-- 1. First create the database through pgAdmin or Azure Portal
-- 2. Connect to the 'gameverse' database
-- 3. Execute the CREATE TABLES and INSERT DATA sections below
--
-- Last Updated: March 1, 2026
-- ========================================


-- ========================================
-- SECTION 1: CREATE DATABASE
-- ========================================
-- Note: In Azure, you may create this through pgAdmin GUI or Query Tool
-- If using this script, execute while connected to the 'postgres' database

CREATE DATABASE gameverse
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TEMPLATE = template0;

-- After creating the database, connect to it before running the rest of this script


-- ========================================
-- SECTION 2: CREATE TABLES
-- ========================================
-- Execute the following while connected to the 'gameverse' database


-- 1. PUBLISHERS TABLE
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    founded_year INT,
    website VARCHAR(200)
);

-- 2. DEVELOPERS TABLE
CREATE TABLE IF NOT EXISTS developers (
    developer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    founded_year INT,
    employee_count INT
);

-- 3. GENRES TABLE
CREATE TABLE IF NOT EXISTS genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 4. PLATFORMS TABLE
CREATE TABLE IF NOT EXISTS platforms (
    platform_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50),
    release_date DATE,
    generation INT
);

-- 5. GAMES TABLE
CREATE TABLE IF NOT EXISTS games (
    game_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_date DATE,
    publisher_id INT REFERENCES publishers(publisher_id),
    developer_id INT REFERENCES developers(developer_id),
    genre_id INT REFERENCES genres(genre_id),
    rating VARCHAR(10),
    metacritic_score DECIMAL(4,2),
    price DECIMAL(6,2)
);

-- 6. GAME_PLATFORMS (Many-to-Many relationship)
CREATE TABLE IF NOT EXISTS game_platforms (
    game_id INT REFERENCES games(game_id),
    platform_id INT REFERENCES platforms(platform_id),
    release_date DATE,
    platform_specific_features TEXT,
    PRIMARY KEY (game_id, platform_id)
);

-- 7. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE,
    country VARCHAR(50),
    birth_date DATE,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'moderator', 'analyst', 'admin')),
    account_status VARCHAR(20) DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'banned')),
    is_premium BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    total_spent DECIMAL(10,2) DEFAULT 0.00
);

-- 8. USER_LIBRARY (Games owned by users)
CREATE TABLE IF NOT EXISTS user_library (
    user_id INT REFERENCES users(user_id),
    game_id INT REFERENCES games(game_id),
    purchase_date DATE,
    purchase_price DECIMAL(6,2),
    hours_played DECIMAL(8,2) DEFAULT 0,
    PRIMARY KEY (user_id, game_id)
);

-- 9. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    game_id INT REFERENCES games(game_id),
    rating INT CHECK (rating >= 1 AND rating <= 10),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE,
    helpful_count INT DEFAULT 0
);

-- 10. ACHIEVEMENTS TABLE
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id SERIAL PRIMARY KEY,
    game_id INT REFERENCES games(game_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    points INT DEFAULT 10
);

-- 11. USER_ACHIEVEMENTS
CREATE TABLE IF NOT EXISTS user_achievements (
    user_id INT REFERENCES users(user_id),
    achievement_id INT REFERENCES achievements(achievement_id),
    unlocked_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, achievement_id)
);


-- ========================================
-- SECTION 3: INSERT SAMPLE DATA
-- ========================================


-- Insert Publishers
INSERT INTO publishers (name, country, founded_year, website) VALUES
('Nintendo', 'Japan', 1889, 'www.nintendo.com'),
('Sony Interactive', 'Japan', 1993, 'www.playstation.com'),
('Microsoft Gaming', 'USA', 2001, 'www.xbox.com'),
('Electronic Arts', 'USA', 1982, 'www.ea.com'),
('Ubisoft', 'France', 1986, 'www.ubisoft.com'),
('Activision Blizzard', 'USA', 2008, 'www.activisionblizzard.com'),
('Bandai Namco', 'Japan', 1955, 'www.bandainamco.com'),
('Capcom', 'Japan', 1979, 'www.capcom.com'),
('Square Enix', 'Japan', 2003, 'www.square-enix.com'),
('Take-Two Interactive', 'USA', 1993, 'www.take2games.com'),
('Bethesda Softworks', 'USA', 1986, 'www.bethesda.net'),
('Epic Games', 'USA', 1991, 'www.epicgames.com'),
('Sega', 'Japan', 1960, 'www.sega.com'),
('THQ Nordic', 'Austria', 2011, 'www.thqnordic.com'),
('Devolver Digital', 'USA', 2009, 'www.devolverdigital.com');

-- Insert Developers
INSERT INTO developers (name, country, founded_year, employee_count) VALUES
('Nintendo EPD', 'Japan', 2015, 800),
('Naughty Dog', 'USA', 1984, 400),
('CD Projekt Red', 'Poland', 1994, 1200),
('FromSoftware', 'Japan', 1986, 350),
('Rockstar Games', 'USA', 1998, 2000),
('Valve', 'USA', 1996, 360),
('Insomniac Games', 'USA', 1994, 275),
('Santa Monica Studio', 'USA', 1999, 300),
('Guerrilla Games', 'Netherlands', 1997, 400),
('Bungie', 'USA', 1991, 900),
('BioWare', 'Canada', 1995, 800),
('Bethesda Game Studios', 'USA', 2001, 420),
('Larian Studios', 'Belgium', 1996, 450),
('Respawn Entertainment', 'USA', 2010, 315),
('Mojang Studios', 'Sweden', 2009, 600),
('Supergiant Games', 'USA', 2009, 30),
('Riot Games', 'USA', 2006, 3500),
('Team Cherry', 'Australia', 2014, 3);

-- Insert Genres
INSERT INTO genres (name, description) VALUES
('Action', 'Fast-paced gameplay with physical challenges'),
('RPG', 'Role-playing games with character development'),
('Adventure', 'Exploration and story-driven gameplay'),
('Strategy', 'Tactical and strategic thinking required'),
('Sports', 'Simulation of physical sports'),
('Puzzle', 'Problem-solving focused gameplay'),
('Shooter', 'Combat with ranged weapons'),
('Racing', 'Vehicle racing competitions'),
('Fighting', 'One-on-one combat gameplay'),
('Platformer', 'Jumping and climbing focused gameplay'),
('Simulation', 'Realistic simulation of real-world activities'),
('Horror', 'Suspense and fear-based gameplay'),
('Stealth', 'Avoiding detection and sneaking'),
('MOBA', 'Multiplayer online battle arena'),
('Battle Royale', 'Last-player-standing multiplayer'),
('Roguelike', 'Procedurally generated with permadeath'),
('Survival', 'Resource management and staying alive'),
('MMO', 'Massively multiplayer online games');

-- Insert Platforms
INSERT INTO platforms (name, manufacturer, release_date, generation) VALUES
('PlayStation 5', 'Sony', '2020-11-12', 9),
('Xbox Series X', 'Microsoft', '2020-11-10', 9),
('Nintendo Switch', 'Nintendo', '2017-03-03', 8),
('PC', 'Various', '1980-01-01', NULL),
('PlayStation 4', 'Sony', '2013-11-15', 8),
('Xbox One', 'Microsoft', '2013-11-22', 8),
('PlayStation 3', 'Sony', '2006-11-11', 7),
('Xbox 360', 'Microsoft', '2005-11-22', 7),
('Nintendo Wii', 'Nintendo', '2006-11-19', 7),
('Nintendo 3DS', 'Nintendo', '2011-02-26', 8),
('PlayStation Vita', 'Sony', '2011-12-17', 8),
('Steam Deck', 'Valve', '2022-02-25', 9),
('iOS', 'Apple', '2007-06-29', NULL),
('Android', 'Google', '2008-09-23', NULL);

-- Insert Games
INSERT INTO games (title, release_date, publisher_id, developer_id, genre_id, rating, metacritic_score, price) VALUES
('The Legend of Zelda: Breath of the Wild', '2017-03-03', 1, 1, 3, 'E10+', 97.00, 59.99),
('The Last of Us Part II', '2020-06-19', 2, 2, 3, 'M', 93.00, 69.99),
('Cyberpunk 2077', '2020-12-10', 3, 3, 2, 'M', 86.00, 49.99),
('Elden Ring', '2022-02-25', 3, 4, 2, 'M', 96.00, 59.99),
('Red Dead Redemption 2', '2018-10-26', 2, 5, 3, 'M', 97.00, 59.99),
('Half-Life: Alyx', '2020-03-23', 6, 6, 1, 'M', 93.00, 59.99),
('God of War Ragnarök', '2022-11-09', 2, 8, 1, 'M', 94.00, 69.99),
('Spider-Man: Miles Morales', '2020-11-12', 2, 7, 1, 'T', 85.00, 49.99),
('Horizon Forbidden West', '2022-02-18', 2, 9, 3, 'T', 88.00, 69.99),
('Dark Souls III', '2016-04-12', 7, 4, 2, 'M', 89.00, 39.99),
('The Witcher 3: Wild Hunt', '2015-05-19', 3, 3, 2, 'M', 92.00, 39.99),
('Halo Infinite', '2021-12-08', 3, 10, 7, 'T', 87.00, 59.99),
('Minecraft', '2011-11-18', 3, 15, 11, 'E10+', 93.00, 29.99),
('Baldur''s Gate 3', '2023-08-03', 12, 13, 2, 'M', 96.00, 59.99),
('Starfield', '2023-09-06', 11, 12, 2, 'M', 83.00, 69.99),
('Resident Evil 4 Remake', '2023-03-24', 8, 8, 12, 'M', 93.00, 59.99),
('Final Fantasy XVI', '2023-06-22', 9, 9, 2, 'M', 87.00, 69.99),
('Street Fighter 6', '2023-06-02', 8, 8, 9, 'T', 92.00, 59.99),
('Apex Legends', '2019-02-04', 4, 14, 15, 'T', 89.00, 0.00),
('Hollow Knight', '2017-02-24', 15, 18, 10, 'E10+', 90.00, 14.99),
('Hades', '2020-09-17', 15, 16, 16, 'T', 93.00, 24.99),
('League of Legends', '2009-10-27', 12, 17, 14, 'T', 78.00, 0.00),
('Fortnite', '2017-07-25', 12, 12, 15, 'T', 81.00, 0.00),
('Animal Crossing: New Horizons', '2020-03-20', 1, 1, 11, 'E', 90.00, 59.99),
('Super Mario Odyssey', '2017-10-27', 1, 1, 10, 'E10+', 97.00, 59.99);

-- Insert Game-Platform relationships
INSERT INTO game_platforms (game_id, platform_id, release_date) VALUES
(1, 3, '2017-03-03'),
(2, 5, '2020-06-19'),
(2, 1, '2020-06-19'),
(3, 4, '2020-12-10'),
(3, 1, '2020-12-10'),
(3, 2, '2020-12-10'),
(4, 4, '2022-02-25'),
(4, 1, '2022-02-25'),
(4, 2, '2022-02-25'),
(5, 4, '2018-11-05'),
(5, 5, '2018-10-26'),
(5, 6, '2018-10-26'),
(6, 4, '2020-03-23'),
(7, 1, '2022-11-09'),
(7, 5, '2022-11-09'),
(8, 1, '2020-11-12'),
(8, 5, '2020-11-12'),
(8, 4, '2020-11-12'),
(9, 1, '2022-02-18'),
(9, 5, '2022-02-18'),
(9, 4, '2024-03-21'),
(10, 4, '2016-04-12'),
(10, 5, '2016-04-12'),
(10, 6, '2016-04-12'),
(11, 4, '2015-05-19'),
(11, 5, '2015-05-19'),
(11, 6, '2015-05-19'),
(11, 3, '2019-10-15'),
(12, 2, '2021-12-08'),
(12, 6, '2021-12-08'),
(12, 4, '2021-12-08'),
(13, 4, '2011-11-18'),
(13, 1, '2011-11-18'),
(13, 2, '2011-11-18'),
(13, 3, '2018-06-21'),
(13, 13, '2011-11-18'),
(13, 14, '2011-10-07'),
(14, 4, '2023-08-03'),
(14, 1, '2024-09-05'),
(15, 4, '2023-09-06'),
(15, 2, '2023-09-06'),
(16, 1, '2023-03-24'),
(16, 5, '2023-03-24'),
(16, 2, '2023-03-24'),
(16, 4, '2023-03-24'),
(17, 1, '2023-06-22'),
(17, 5, '2023-06-22'),
(18, 1, '2023-06-02'),
(18, 2, '2023-06-02'),
(18, 4, '2023-06-02'),
(19, 4, '2019-02-04'),
(19, 1, '2019-02-04'),
(19, 2, '2019-02-04'),
(19, 3, '2021-03-09'),
(20, 4, '2017-02-24'),
(20, 1, '2018-09-25'),
(20, 2, '2019-06-13'),
(20, 3, '2018-06-12'),
(21, 4, '2020-09-17'),
(21, 1, '2021-08-13'),
(21, 2, '2021-08-13'),
(21, 3, '2021-08-13'),
(22, 4, '2009-10-27'),
(23, 4, '2017-07-25'),
(23, 1, '2017-07-25'),
(23, 2, '2017-07-25'),
(23, 3, '2018-06-12'),
(23, 13, '2018-04-02'),
(23, 14, '2018-06-09'),
(24, 3, '2020-03-20'),
(25, 3, '2017-10-27');

-- Insert Users
INSERT INTO users (username, email, registration_date, country, birth_date, role, account_status, is_premium, last_login, total_spent) VALUES
('gamer_pro123', 'gamer@email.com', '2020-01-15', 'USA', '1995-05-20', 'user', 'active', TRUE, '2026-02-15 18:30:00', 119.98),
('zelda_fan', 'zelda@email.com', '2019-03-10', 'Canada', '1998-11-12', 'user', 'active', TRUE, '2026-02-16 20:15:00', 309.96),
('rpg_master', 'rpg@email.com', '2021-06-22', 'UK', '1992-08-30', 'analyst', 'active', TRUE, '2026-02-17 09:45:00', 209.97),
('speed_runner', 'speed@email.com', '2018-12-01', 'Japan', '2000-02-14', 'user', 'active', FALSE, '2026-02-14 22:10:00', 124.97),
('casual_player', 'casual@email.com', '2022-01-10', 'Germany', '1988-07-25', 'user', 'active', FALSE, '2026-02-10 14:20:00', 139.97),
('shooter_ace', 'shooter@email.com', '2019-07-15', 'USA', '1997-03-18', 'user', 'active', TRUE, '2026-02-17 17:05:00', 59.99),
('souls_veteran', 'souls@email.com', '2017-05-20', 'France', '1990-12-05', 'moderator', 'active', TRUE, '2026-02-17 08:30:00', 179.97),
('indie_lover', 'indie@email.com', '2020-08-30', 'Australia', '1993-09-22', 'user', 'active', FALSE, '2026-02-12 19:45:00', 109.97),
('strategy_mind', 'strategy@email.com', '2018-11-12', 'South Korea', '1991-06-14', 'user', 'active', TRUE, '2026-02-16 23:15:00', 59.99),
('platformer_king', 'platform@email.com', '2021-02-28', 'Brazil', '1999-01-30', 'user', 'active', FALSE, '2026-02-13 16:30:00', 179.97),
('horror_fan', 'horror@email.com', '2019-10-31', 'Spain', '1994-10-13', 'user', 'active', FALSE, '2026-02-11 21:00:00', 129.98),
('multiplayer_addict', 'multi@email.com', '2020-06-01', 'USA', '2001-07-08', 'user', 'suspended', FALSE, '2025-12-20 15:45:00', 0.00),
('retro_gamer', 'retro@email.com', '2017-01-20', 'UK', '1985-04-25', 'admin', 'active', TRUE, '2026-02-17 10:00:00', 89.98),
('completionist', 'complete@email.com', '2021-09-15', 'Netherlands', '1996-11-19', 'user', 'active', TRUE, '2026-02-15 12:20:00', 179.97),
('fighting_champion', 'fighter@email.com', '2022-03-05', 'Japan', '1998-08-07', 'analyst', 'active', FALSE, '2026-02-16 19:30:00', 99.98);

-- Insert User Library
INSERT INTO user_library (user_id, game_id, purchase_date, purchase_price, hours_played) VALUES
(1, 1, '2020-02-01', 59.99, 120.5),
(1, 4, '2022-03-01', 59.99, 85.0),
(1, 12, '2021-12-10', 59.99, 145.0),
(1, 19, '2020-05-15', 0.00, 320.5),
(2, 1, '2019-05-15', 59.99, 250.0),
(2, 2, '2020-07-01', 69.99, 45.5),
(2, 24, '2020-03-22', 59.99, 180.0),
(2, 25, '2019-11-01', 59.99, 95.5),
(3, 3, '2020-12-15', 59.99, 60.0),
(3, 4, '2022-02-28', 59.99, 150.0),
(3, 11, '2021-07-10', 29.99, 275.0),
(3, 14, '2023-08-15', 59.99, 210.5),
(4, 5, '2019-01-20', 59.99, 200.0),
(4, 10, '2017-04-20', 39.99, 180.0),
(4, 21, '2020-10-01', 24.99, 95.0),
(5, 1, '2022-02-14', 49.99, 30.0),
(5, 13, '2021-06-18', 29.99, 450.0),
(5, 24, '2020-04-05', 59.99, 220.0),
(6, 12, '2022-01-15', 59.99, 165.5),
(6, 19, '2020-03-01', 0.00, 580.0),
(6, 23, '2020-08-20', 0.00, 420.5),
(7, 4, '2022-03-10', 59.99, 320.0),
(7, 10, '2018-08-25', 39.99, 240.5),
(7, 16, '2023-04-01', 59.99, 75.0),
(8, 20, '2018-03-15', 14.99, 85.0),
(8, 21, '2020-09-20', 24.99, 145.5),
(8, 8, '2020-11-20', 49.99, 40.0),
(9, 14, '2023-08-10', 59.99, 190.0),
(9, 22, '2015-10-15', 0.00, 1250.0),
(10, 25, '2018-11-05', 59.99, 120.0),
(10, 1, '2019-06-10', 59.99, 80.5),
(10, 24, '2020-03-25', 59.99, 140.0),
(11, 16, '2023-03-30', 59.99, 55.0),
(11, 2, '2020-06-25', 69.99, 38.5),
(12, 19, '2019-06-01', 0.00, 1100.0),
(12, 23, '2018-08-01', 0.00, 850.0),
(12, 22, '2020-03-15', 0.00, 420.0),
(13, 13, '2015-05-25', 29.99, 680.0),
(13, 5, '2019-11-10', 59.99, 150.0),
(14, 4, '2022-03-05', 59.99, 280.0),
(14, 14, '2023-08-05', 59.99, 195.5),
(14, 11, '2019-10-10', 29.99, 310.0),
(15, 18, '2023-06-10', 59.99, 125.0),
(15, 10, '2020-05-15', 39.99, 88.0);

-- Insert Reviews
INSERT INTO reviews (user_id, game_id, rating, review_text, review_date, helpful_count) VALUES
(1, 1, 10, 'Absolutely masterpiece! Best open-world game ever.', '2020-02-15', 156),
(2, 1, 9, 'Amazing game, though the weapon durability can be annoying.', '2019-06-01', 89),
(1, 4, 10, 'Challenging but incredibly rewarding. GOTY material.', '2022-04-15', 234),
(3, 3, 7, 'Great story but technical issues on launch.', '2021-01-10', 445),
(3, 4, 9, 'Best souls-like game. Incredible world design.', '2022-05-20', 178),
(4, 5, 10, 'Most immersive game I have ever played.', '2019-02-10', 567),
(1, 12, 9, 'Great multiplayer experience. Campaign is solid too.', '2022-01-15', 201),
(2, 24, 10, 'Perfect relaxing game. So wholesome and fun!', '2020-04-01', 312),
(5, 13, 10, 'Minecraft never gets old. Endless creativity!', '2021-07-20', 890),
(6, 19, 8, 'Best battle royale out there. Smooth gameplay.', '2020-04-10', 534),
(7, 10, 9, 'Dark Souls III is brutal but fair. Worth every death.', '2018-09-15', 423),
(3, 14, 10, 'Baldur''s Gate 3 exceeded all expectations. Masterpiece!', '2023-08-20', 678),
(8, 20, 10, 'Hollow Knight is a work of art. Best metroidvania ever.', '2018-04-05', 789),
(8, 21, 9, 'Hades combines great gameplay with amazing story.', '2020-10-05', 654),
(9, 14, 9, 'Incredible RPG with so many choices that matter.', '2023-09-01', 421),
(6, 23, 7, 'Fun but sometimes too competitive for casual play.', '2020-09-10', 298),
(10, 25, 10, 'Super Mario Odyssey is pure joy. Best Mario game!', '2018-11-20', 543),
(11, 16, 9, 'Resident Evil 4 Remake is terrifyingly good.', '2023-04-10', 389),
(7, 4, 10, 'Elden Ring is FromSoftware''s magnum opus.', '2022-03-20', 891),
(12, 22, 6, 'Fun but community can be toxic at times.', '2020-04-01', 1203),
(13, 5, 10, 'Red Dead 2 set a new standard for storytelling.', '2019-11-25', 734),
(3, 11, 9, 'The Witcher 3 is an epic adventure. Amazing DLCs!', '2021-08-05', 612),
(14, 4, 10, 'Elden Ring delivers the ultimate souls experience.', '2022-03-15', 567),
(15, 18, 8, 'Street Fighter 6 brings fresh mechanics to the series.', '2023-06-25', 234),
(2, 25, 10, 'So much creativity packed into one game!', '2019-11-15', 287),
(5, 24, 9, 'Animal Crossing is my stress relief game.', '2020-04-15', 456),
(4, 21, 9, 'Every run feels unique. Highly replayable!', '2020-11-10', 321),
(6, 12, 8, 'Halo Infinite has great gunplay but needs more content.', '2022-02-01', 189),
(9, 22, 5, 'Steep learning curve but rewarding once mastered.', '2015-11-20', 892),
(1, 19, 9, 'Apex Legends has the best movement system.', '2020-06-15', 412),
(14, 14, 10, 'Best RPG of the decade. Incredible depth!', '2023-08-15', 589),
(7, 16, 10, 'Best remake I''ve ever played. Perfect modernization.', '2023-04-05', 445);

-- Insert Achievements
INSERT INTO achievements (game_id, name, description, points) VALUES
(1, 'Defeat Ganon', 'Defeat the final boss', 100),
(1, 'All Shrines', 'Complete all 120 shrines', 50),
(1, 'Master Sword', 'Obtain the Master Sword', 30),
(1, 'Divine Beasts', 'Free all four Divine Beasts', 40),
(4, 'Elden Lord', 'Become the Elden Lord', 100),
(4, 'Shardbearer', 'Defeat a shardbearer', 30),
(4, 'Legendary Armaments', 'Acquire all legendary weapons', 50),
(4, 'Age of Stars', 'Achieve the Age of Stars ending', 40),
(5, 'Wanted', 'Reach max wanted level', 20),
(5, 'Treasure Hunter', 'Find all collectibles', 50),
(5, 'Gold Rush', 'Earn $10,000 in one day', 30),
(5, 'Companion', 'Reach max bonding level with horse', 25),
(2, 'Endure and Survive', 'Complete the story on Survivor difficulty', 100),
(2, 'Completed Trading Cards', 'Collect all trading cards', 40),
(11, 'Master Witcher', 'Complete the game on Death March difficulty', 100),
(11, 'Gwent Master', 'Collect all gwent cards', 50),
(14, 'Absolute Power', 'Defeat all bosses', 80),
(14, 'Critical Success', 'Complete the game on Tactician difficulty', 100),
(21, 'Heat Wave', 'Clear Tartarus with 32 Heat', 100),
(21, 'Distant Memory', 'Complete the game for the first time', 50),
(20, 'Steel Soul', 'Complete the game without dying', 100),
(20, 'Awakening', 'Obtain the Awakened Dream Nail', 60),
(13, 'The End?', 'Kill the Ender Dragon', 40),
(13, 'Diamonds!', 'Acquire diamonds', 30),
(24, 'Nook Miles Master', 'Earn 5,000 Nook Miles', 40),
(24, 'Island Designer', 'Unlock Island Designer app', 50),
(25, 'Globe Trotter', 'Capture all kingdoms', 100),
(25, 'Fashionista', 'Purchase 10 different costumes', 30);

-- Insert User Achievements
INSERT INTO user_achievements (user_id, achievement_id, unlocked_date) VALUES
(1, 1, '2020-03-15 14:30:00'),
(1, 3, '2020-02-20 16:45:00'),
(1, 5, '2022-04-10 19:20:00'),
(1, 6, '2022-03-25 21:15:00'),
(2, 1, '2019-08-20 20:15:00'),
(2, 2, '2019-12-25 16:45:00'),
(2, 3, '2019-07-10 18:30:00'),
(2, 4, '2019-09-15 14:20:00'),
(2, 25, '2020-04-15 10:30:00'),
(3, 5, '2022-06-10 22:00:00'),
(3, 6, '2022-03-15 18:30:00'),
(3, 7, '2022-08-20 20:45:00'),
(3, 17, '2023-09-05 23:15:00'),
(3, 18, '2023-09-20 15:30:00'),
(4, 9, '2019-03-05 17:45:00'),
(4, 10, '2019-02-20 19:30:00'),
(4, 11, '2019-04-15 21:00:00'),
(5, 23, '2021-08-10 12:20:00'),
(5, 24, '2021-09-05 14:45:00'),
(5, 25, '2020-05-01 16:30:00'),
(7, 5, '2022-05-20 18:15:00'),
(7, 6, '2022-04-10 20:30:00'),
(7, 7, '2022-08-15 22:45:00'),
(7, 8, '2022-07-05 19:00:00'),
(8, 21, '2018-04-20 21:30:00'),
(8, 22, '2018-05-15 23:45:00'),
(8, 19, '2020-11-10 17:20:00'),
(8, 20, '2020-12-05 19:15:00'),
(10, 1, '2019-08-15 15:45:00'),
(10, 27, '2018-12-20 18:30:00'),
(10, 28, '2018-11-25 20:15:00'),
(14, 5, '2022-04-20 16:30:00'),
(14, 17, '2023-09-10 22:00:00'),
(14, 18, '2023-10-01 20:45:00');


-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these to verify the data was loaded correctly

-- Check table counts
SELECT 'publishers' as table_name, COUNT(*) as row_count FROM publishers
UNION ALL
SELECT 'developers', COUNT(*) FROM developers
UNION ALL
SELECT 'genres', COUNT(*) FROM genres
UNION ALL
SELECT 'platforms', COUNT(*) FROM platforms
UNION ALL
SELECT 'games', COUNT(*) FROM games
UNION ALL
SELECT 'game_platforms', COUNT(*) FROM game_platforms
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'user_library', COUNT(*) FROM user_library
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'achievements', COUNT(*) FROM achievements
UNION ALL
SELECT 'user_achievements', COUNT(*) FROM user_achievements;

-- Sample data verification
SELECT 'Top 5 Rated Games' as query_result;
SELECT title, metacritic_score, price 
FROM games 
WHERE metacritic_score IS NOT NULL
ORDER BY metacritic_score DESC 
LIMIT 5;
