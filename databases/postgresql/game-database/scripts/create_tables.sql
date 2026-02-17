-- Create the database
SET gameverse
-- Connect to it in pgAdmin, then run:

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
CREATE TABLE IF NOT EXISTSIF NOT EXISTSplatforms (
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
CREATE TABLE IF NOT EXISTSreviews (
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

