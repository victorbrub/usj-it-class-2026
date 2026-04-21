# Author: Víctor Barceló
# GameVerse Cassandra Lab

**Duration**: 2 hours  
**Tool**: cqlsh (Cassandra Query Language Shell)  
**Database**: GameVerse (adapted for wide-column model)

## Objectives

By the end of this lab you will be able to:

- Create a Cassandra keyspace and design tables around access patterns
- Write CQL INSERT, SELECT, UPDATE, and DELETE statements
- Understand partition keys and clustering columns and how they affect queries
- Model denormalized tables for specific query needs
- Use TTL for time-expiring data
- Explain why Cassandra requires a fundamentally different design approach compared to relational databases

## The Most Important Concept: Query-Driven Design

In a relational database you design tables to represent entities (games, users, publishers) and use JOINs at query time. In Cassandra, **you design tables around the queries you need to run**. One entity often requires multiple tables — one per access pattern — because Cassandra has no JOINs and queries must always include the partition key.

This is the central idea that underpins every decision in this lab.

**Three rules to internalise before starting:**

1. Every `SELECT` must include the partition key in its `WHERE` clause (or use `ALLOW FILTERING`, which is inefficient and should be avoided in production).
2. Wide-column tables are denormalized by design. Repeating data across tables is normal and expected.
3. Think about your queries first, then design your tables.

---

## Access Patterns for GameVerse

Before creating any tables, identify the queries the application needs to run:

| Query ID | Description |
|---|---|
| Q1 | Look up a game by its title |
| Q2 | List all games in a given genre |
| Q3 | List all games available on a given platform |
| Q4 | Look up a user profile by username |
| Q5 | List all games in a user's library |
| Q6 | List all reviews for a given game, newest first |
| Q7 | List all reviews written by a given user, newest first |
| Q8 | Look up the most recent activity events for a user |

Each of these queries becomes its own table design.

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Connect to Cassandra

Open a terminal and launch the CQL shell:

```bash
cqlsh
```

You should see the prompt `cqlsh>`. If Cassandra is not running, start it first:

```bash
# Linux / macOS
cassandra -f
```

Then reconnect in a second terminal:

```bash
cqlsh
```

### Step 0.2 - Create the Keyspace

A **keyspace** is the top-level container in Cassandra, equivalent to a database or schema. The `replication` strategy controls how data is copied across nodes.

For a local single-node development environment, use `SimpleStrategy` with a replication factor of 1:

```cql
CREATE KEYSPACE IF NOT EXISTS gameverse
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};
```

Switch to the keyspace:

```cql
USE gameverse;
```

You should now see the prompt `cqlsh:gameverse>`.

### Step 0.3 - Verify the Keyspace

```cql
DESCRIBE KEYSPACE gameverse;
```

> **Checkpoint**: The output should show your keyspace definition. Note that Cassandra stores metadata about keyspaces separately from user data — this is called the system catalogue.

---

## Part 1 - Tables for Game Access (20 minutes)

### Understanding Partition Keys and Clustering Columns

Every Cassandra table must have a **primary key**. The primary key has two parts:

- **Partition key**: One or more columns that determine which node stores the row. All rows with the same partition key value are stored together on the same node. Queries must filter on the partition key to be efficient.
- **Clustering columns**: Optional columns within a partition that sort the rows stored together and can be used in range queries.

```
PRIMARY KEY (partition_key, clustering_col1, clustering_col2)
```

**SQL comparison:**

| Concept | SQL | Cassandra |
|---|---|---|
| Database | Schema / Database | Keyspace |
| Table | Table | Table |
| Row lookup | Primary key / index | Partition key (required in WHERE) |
| Row ordering | ORDER BY at query time | Clustering columns (fixed at table creation) |
| Flexible filtering | WHERE on any indexed column | Only on partition key + clustering columns |

---

### Exercise 1.1 - Table Q1: Game by Title

Query Q1 looks up a single game by its title. Title becomes the partition key.

```cql
CREATE TABLE IF NOT EXISTS games (
  title          TEXT,
  genre          TEXT,
  release_date   TEXT,
  metacritic_score INT,
  price          DECIMAL,
  rating         TEXT,
  publisher_name TEXT,
  developer_name TEXT,
  developer_country TEXT,
  PRIMARY KEY (title)
);
```

> Note: `publisher_name` and `developer_name` are stored directly in this table — denormalized from the relational model, where they would live in separate tables.

Insert the game data:

```cql
INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Elden Ring', 'RPG', '2022-02-25', 96, 59.99, 'M', 'Bandai Namco', 'FromSoftware', 'Japan');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('The Legend of Zelda: Breath of the Wild', 'Adventure', '2017-03-03', 97, 59.99, 'E10+', 'Nintendo', 'Nintendo EPD', 'Japan');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Red Dead Redemption 2', 'Adventure', '2018-10-26', 97, 59.99, 'M', 'Rockstar Games', 'Rockstar Games', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Baldur''s Gate 3', 'RPG', '2023-08-03', 96, 59.99, 'M', 'Larian Studios', 'Larian Studios', 'Belgium');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('God of War Ragnarok', 'Action', '2022-11-09', 94, 69.99, 'M', 'Sony Interactive', 'Santa Monica Studio', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Hades', 'Roguelike', '2020-09-17', 93, 24.99, 'T', 'Supergiant Games', 'Supergiant Games', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('The Last of Us Part II', 'Adventure', '2020-06-19', 93, 69.99, 'M', 'Sony Interactive', 'Naughty Dog', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('The Witcher 3: Wild Hunt', 'RPG', '2015-05-19', 92, 39.99, 'M', 'CD Projekt', 'CD Projekt Red', 'Poland');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Disco Elysium', 'RPG', '2019-10-15', 97, 39.99, 'M', 'ZA/UM', 'ZA/UM', 'Estonia');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Hollow Knight', 'Platformer', '2017-02-24', 90, 14.99, 'E10+', 'Team Cherry', 'Team Cherry', 'Australia');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Apex Legends', 'Battle Royale', '2019-02-04', 89, 0.00, 'T', 'Electronic Arts', 'Respawn Entertainment', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Cyberpunk 2077', 'RPG', '2020-12-10', 86, 49.99, 'M', 'CD Projekt', 'CD Projekt Red', 'Poland');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Halo Infinite', 'Shooter', '2021-12-08', 87, 59.99, 'T', 'Microsoft Gaming', '343 Industries', 'USA');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Celeste', 'Platformer', '2018-01-25', 94, 19.99, 'E10+', 'Matt Makes Games', 'Matt Makes Games', 'Canada');

INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('Stardew Valley', 'Simulation', '2016-02-26', 89, 14.99, 'E10+', 'ConcernedApe', 'ConcernedApe', 'USA');
```

> Note: In CQL, a single quote inside a string is escaped by doubling it: `'Baldur''s Gate 3'`.

---

### Exercise 1.2 - Query Q1: Look Up a Game by Title

Retrieve the full record for Elden Ring:

```cql
SELECT * FROM games WHERE title = 'Elden Ring';
```

> **SQL equivalent:** `SELECT * FROM games WHERE title = 'Elden Ring';`  
> The syntax is almost identical. The key difference is that in Cassandra, `WHERE title = 'Elden Ring'` works efficiently only because `title` is the partition key. Filtering on any other column requires `ALLOW FILTERING`.

Retrieve only the score and price:

```cql
SELECT metacritic_score, price FROM games WHERE title = 'Hades';
```

Now write a query to retrieve the genre, publisher, and rating for **Disco Elysium**:

```cql
-- Write your SELECT here
```

---

### Exercise 1.3 - Table Q2: Games by Genre

Query Q2 needs all games for a given genre. genre becomes the partition key. Within a genre partition, rows are sorted by metacritic score descending so the best-rated games appear first.

```cql
CREATE TABLE IF NOT EXISTS games_by_genre (
  genre          TEXT,
  metacritic_score INT,
  title          TEXT,
  release_date   TEXT,
  price          DECIMAL,
  rating         TEXT,
  publisher_name TEXT,
  PRIMARY KEY (genre, metacritic_score, title)
) WITH CLUSTERING ORDER BY (metacritic_score DESC, title ASC);
```

Insert a subset of the data (note that data is repeated from the `games` table — this is intentional):

```cql
INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('RPG', 97, 'Disco Elysium', '2019-10-15', 39.99, 'M', 'ZA/UM');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('RPG', 96, 'Elden Ring', '2022-02-25', 59.99, 'M', 'Bandai Namco');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('RPG', 96, 'Baldur''s Gate 3', '2023-08-03', 59.99, 'M', 'Larian Studios');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('RPG', 92, 'The Witcher 3: Wild Hunt', '2015-05-19', 39.99, 'M', 'CD Projekt');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('RPG', 86, 'Cyberpunk 2077', '2020-12-10', 49.99, 'M', 'CD Projekt');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Adventure', 97, 'Red Dead Redemption 2', '2018-10-26', 59.99, 'M', 'Rockstar Games');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Adventure', 97, 'The Legend of Zelda: Breath of the Wild', '2017-03-03', 59.99, 'E10+', 'Nintendo');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Adventure', 93, 'The Last of Us Part II', '2020-06-19', 69.99, 'M', 'Sony Interactive');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Roguelike', 93, 'Hades', '2020-09-17', 24.99, 'T', 'Supergiant Games');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Platformer', 94, 'Celeste', '2018-01-25', 19.99, 'E10+', 'Matt Makes Games');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Platformer', 90, 'Hollow Knight', '2017-02-24', 14.99, 'E10+', 'Team Cherry');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Action', 94, 'God of War Ragnarok', '2022-11-09', 69.99, 'M', 'Sony Interactive');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Simulation', 89, 'Stardew Valley', '2016-02-26', 14.99, 'E10+', 'ConcernedApe');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Battle Royale', 89, 'Apex Legends', '2019-02-04', 0.00, 'T', 'Electronic Arts');

INSERT INTO games_by_genre (genre, metacritic_score, title, release_date, price, rating, publisher_name)
VALUES ('Shooter', 87, 'Halo Infinite', '2021-12-08', 59.99, 'T', 'Microsoft Gaming');
```

---

### Exercise 1.4 - Query Q2: Games by Genre

List all RPG games, best score first:

```cql
SELECT title, metacritic_score, price FROM games_by_genre WHERE genre = 'RPG';
```

> **SQL equivalent:** `SELECT title, metacritic_score, price FROM games WHERE genre = 'RPG' ORDER BY metacritic_score DESC;`  
> In Cassandra the order is fixed by the clustering definition at table creation — you cannot change it at query time with `ORDER BY`.

List all Platformer games:

```cql
SELECT title, metacritic_score FROM games_by_genre WHERE genre = 'Platformer';
```

List only RPG games with a score of 96 or higher (range query on clustering column):

```cql
SELECT title, metacritic_score FROM games_by_genre
WHERE genre = 'RPG' AND metacritic_score >= 96;
```

> This works because `metacritic_score` is the first clustering column. Cassandra allows range conditions on clustering columns after an equality condition on the partition key.

Now write a query to list all **Adventure** games with a score **above 95**:

```cql
-- Write your SELECT here
```

---

## Part 2 - Platform and User Tables (15 minutes)

### Exercise 2.1 - Table Q3: Games by Platform

Query Q3 needs all games on a specific platform. `platform` is the partition key.

```cql
CREATE TABLE IF NOT EXISTS games_by_platform (
  platform       TEXT,
  title          TEXT,
  genre          TEXT,
  metacritic_score INT,
  price          DECIMAL,
  PRIMARY KEY (platform, title)
);
```

> Clustering by `title` means rows per platform are stored in alphabetical title order. If you needed to query "games on PC sorted by score", you would create a different table with `(platform, metacritic_score DESC, title)` as the primary key — one table per access pattern.

Insert platform data:

```cql
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Elden Ring', 'RPG', 96, 59.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'The Witcher 3: Wild Hunt', 'RPG', 92, 39.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Cyberpunk 2077', 'RPG', 86, 49.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Hades', 'Roguelike', 93, 24.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Disco Elysium', 'RPG', 97, 39.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Hollow Knight', 'Platformer', 90, 14.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Celeste', 'Platformer', 94, 19.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Apex Legends', 'Battle Royale', 89, 0.00);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PC', 'Stardew Valley', 'Simulation', 89, 14.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'The Legend of Zelda: Breath of the Wild', 'Adventure', 97, 59.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'The Witcher 3: Wild Hunt', 'RPG', 92, 39.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'Hades', 'Roguelike', 93, 24.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'Hollow Knight', 'Platformer', 90, 14.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'Stardew Valley', 'Simulation', 89, 14.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('Nintendo Switch', 'Celeste', 'Platformer', 94, 19.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PlayStation 5', 'Elden Ring', 'RPG', 96, 59.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PlayStation 5', 'God of War Ragnarok', 'Action', 94, 69.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PlayStation 5', 'Baldur''s Gate 3', 'RPG', 96, 59.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PlayStation 5', 'The Last of Us Part II', 'Adventure', 93, 69.99);
INSERT INTO games_by_platform (platform, title, genre, metacritic_score, price) VALUES ('PlayStation 5', 'Hades', 'Roguelike', 93, 24.99);
```

Query Q3: List all games on Nintendo Switch:

```cql
SELECT title, genre, metacritic_score FROM games_by_platform WHERE platform = 'Nintendo Switch';
```

> **SQL equivalent:**
> ```sql
> SELECT g.title, g.genre, g.metacritic_score FROM games g
> JOIN game_platforms gp ON g.id = gp.game_id
> JOIN platforms p ON gp.platform_id = p.id
> WHERE p.name = 'Nintendo Switch';
> ```
> Cassandra needs no JOIN — the query reads a single partition.

Now write a query to list all games on **PlayStation 5**:

```cql
-- Write your SELECT here
```

---

### Exercise 2.2 - Table Q4: User Profiles

```cql
CREATE TABLE IF NOT EXISTS users (
  username       TEXT,
  email          TEXT,
  country        TEXT,
  role           TEXT,
  is_premium     BOOLEAN,
  total_spent    DECIMAL,
  account_status TEXT,
  registration_date TEXT,
  PRIMARY KEY (username)
);
```

```cql
INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('rpg_master', 'rpg@email.com', 'UK', 'analyst', true, 209.97, 'active', '2021-06-22');

INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('gamer_pro123', 'gamer@email.com', 'USA', 'user', true, 119.98, 'active', '2020-01-15');

INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('zelda_fan', 'zelda@email.com', 'Canada', 'user', true, 309.96, 'active', '2019-03-10');

INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('souls_veteran', 'souls@email.com', 'France', 'moderator', true, 179.97, 'active', '2017-05-20');

INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('indie_lover', 'indie@email.com', 'Australia', 'user', false, 109.97, 'active', '2020-08-30');

INSERT INTO users (username, email, country, role, is_premium, total_spent, account_status, registration_date)
VALUES ('casual_player', 'casual@email.com', 'Germany', 'user', false, 139.97, 'active', '2022-01-10');
```

Look up a user by username:

```cql
SELECT * FROM users WHERE username = 'rpg_master';
```

> **SQL equivalent:** `SELECT * FROM users WHERE username = 'rpg_master';`

---

## Part 3 - User Library and Reviews (20 minutes)

### Exercise 3.1 - Table Q5: User Library

Query Q5 lists all games in a user's library. The user is the partition — all their games live in one partition and can be retrieved efficiently.

```cql
CREATE TABLE IF NOT EXISTS user_library (
  username       TEXT,
  game_title     TEXT,
  genre          TEXT,
  purchase_date  TEXT,
  purchase_price DECIMAL,
  hours_played   DECIMAL,
  PRIMARY KEY (username, game_title)
);
```

Insert library data:

```cql
INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('rpg_master', 'Cyberpunk 2077', 'RPG', '2020-12-15', 59.99, 60.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('rpg_master', 'Elden Ring', 'RPG', '2022-02-28', 59.99, 150.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('rpg_master', 'The Witcher 3: Wild Hunt', 'RPG', '2021-07-10', 29.99, 275.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('rpg_master', 'Baldur''s Gate 3', 'RPG', '2023-08-15', 59.99, 210.5);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('gamer_pro123', 'The Legend of Zelda: Breath of the Wild', 'Adventure', '2020-02-01', 59.99, 120.5);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('gamer_pro123', 'Elden Ring', 'RPG', '2022-03-01', 59.99, 85.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('gamer_pro123', 'Apex Legends', 'Battle Royale', '2020-05-15', 0.00, 320.5);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('souls_veteran', 'Elden Ring', 'RPG', '2022-03-10', 59.99, 320.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('souls_veteran', 'Hollow Knight', 'Platformer', '2018-08-25', 14.99, 240.5);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('indie_lover', 'Hollow Knight', 'Platformer', '2018-03-15', 14.99, 85.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('indie_lover', 'Hades', 'Roguelike', '2020-09-20', 24.99, 145.5);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('zelda_fan', 'The Legend of Zelda: Breath of the Wild', 'Adventure', '2019-05-15', 59.99, 250.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('zelda_fan', 'Hades', 'Roguelike', '2020-09-20', 24.99, 230.0);

INSERT INTO user_library (username, game_title, genre, purchase_date, purchase_price, hours_played)
VALUES ('zelda_fan', 'Hollow Knight', 'Platformer', '2018-06-12', 14.99, 90.0);
```

Query Q5: List all games in rpg_master's library:

```cql
SELECT game_title, genre, hours_played FROM user_library WHERE username = 'rpg_master';
```

> **SQL equivalent:** `SELECT game_title, genre, hours_played FROM user_library WHERE username = 'rpg_master';`

Look up whether rpg_master owns a specific game — use both partition key and clustering column:

```cql
SELECT * FROM user_library WHERE username = 'rpg_master' AND game_title = 'Elden Ring';
```

Now write a query to list all games in **indie_lover**'s library:

```cql
-- Write your SELECT here
```

---

### Exercise 3.2 - Table Q6: Reviews by Game

Query Q6 needs all reviews for a game, newest first. The game title is the partition key; `review_date` is the clustering column in descending order.

```cql
CREATE TABLE IF NOT EXISTS reviews_by_game (
  game_title     TEXT,
  review_date    TEXT,
  username       TEXT,
  rating         INT,
  review_text    TEXT,
  helpful_count  INT,
  PRIMARY KEY (game_title, review_date, username)
) WITH CLUSTERING ORDER BY (review_date DESC, username ASC);
```

Insert reviews:

```cql
INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('The Witcher 3: Wild Hunt', '2021-08-01', 'rpg_master', 10, 'The best RPG ever made. Every quest feels hand-crafted.', 201);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Baldur''s Gate 3', '2023-09-01', 'rpg_master', 10, 'Larian has outdone themselves. Incredible depth and freedom.', 134);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Cyberpunk 2077', '2021-02-10', 'rpg_master', 7, 'Great story, mixed technical experience at launch. Much better now.', 66);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('The Legend of Zelda: Breath of the Wild', '2020-02-15', 'gamer_pro123', 10, 'Absolutely a masterpiece. Best open-world game ever made.', 156);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Elden Ring', '2022-03-15', 'gamer_pro123', 9, 'Incredibly challenging but rewarding.', 88);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Elden Ring', '2022-03-20', 'souls_veteran', 10, 'The pinnacle of the soulslike genre. Masterful open-world design.', 310);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Hollow Knight', '2018-09-15', 'souls_veteran', 10, 'Made by 3 people and better than most AAA games. Stunning.', 180);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Hades', '2020-10-15', 'indie_lover', 10, 'Best roguelike ever. Every run keeps you hooked.', 99);

INSERT INTO reviews_by_game (game_title, review_date, username, rating, review_text, helpful_count)
VALUES ('Hollow Knight', '2018-04-01', 'indie_lover', 9, 'Absolutely beautiful and challenging. A true indie gem.', 72);
```

Query Q6: Get all reviews for Elden Ring (newest first):

```cql
SELECT username, review_date, rating, review_text
FROM reviews_by_game
WHERE game_title = 'Elden Ring';
```

> **SQL equivalent:** `SELECT username, review_date, rating, review_text FROM reviews WHERE game_id = ... ORDER BY review_date DESC;`

Get all reviews for Hollow Knight, but only those from 2018:

```cql
SELECT username, review_date, rating
FROM reviews_by_game
WHERE game_title = 'Hollow Knight'
  AND review_date >= '2018-01-01'
  AND review_date <= '2018-12-31';
```

> This is a range query on the first clustering column (`review_date`). Cassandra supports this efficiently.

Now write a query to get all reviews for **The Witcher 3: Wild Hunt**:

```cql
-- Write your SELECT here
```

---

### Exercise 3.3 - Table Q7: Reviews by User

Query Q7 needs all reviews written by a user, newest first. This requires a separate table — the same review data exists in both `reviews_by_game` and `reviews_by_user`. This duplication is expected in Cassandra.

```cql
CREATE TABLE IF NOT EXISTS reviews_by_user (
  username       TEXT,
  review_date    TEXT,
  game_title     TEXT,
  rating         INT,
  review_text    TEXT,
  PRIMARY KEY (username, review_date, game_title)
) WITH CLUSTERING ORDER BY (review_date DESC, game_title ASC);
```

Insert the same review data, this time partitioned by user:

```cql
INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('rpg_master', '2021-08-01', 'The Witcher 3: Wild Hunt', 10, 'The best RPG ever made. Every quest feels hand-crafted.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('rpg_master', '2023-09-01', 'Baldur''s Gate 3', 10, 'Larian has outdone themselves. Incredible depth and freedom.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('rpg_master', '2021-02-10', 'Cyberpunk 2077', 7, 'Great story, mixed technical experience at launch. Much better now.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('gamer_pro123', '2020-02-15', 'The Legend of Zelda: Breath of the Wild', 10, 'Absolutely a masterpiece. Best open-world game ever made.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('gamer_pro123', '2022-03-15', 'Elden Ring', 9, 'Incredibly challenging but rewarding.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('souls_veteran', '2022-03-20', 'Elden Ring', 10, 'The pinnacle of the soulslike genre. Masterful open-world design.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('souls_veteran', '2018-09-15', 'Hollow Knight', 10, 'Made by 3 people and better than most AAA games. Stunning.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('indie_lover', '2020-10-15', 'Hades', 10, 'Best roguelike ever. Every run keeps you hooked.');

INSERT INTO reviews_by_user (username, review_date, game_title, rating, review_text)
VALUES ('indie_lover', '2018-04-01', 'Hollow Knight', 9, 'Absolutely beautiful and challenging. A true indie gem.');
```

Query Q7: Get all reviews by rpg_master, newest first:

```cql
SELECT game_title, review_date, rating
FROM reviews_by_user
WHERE username = 'rpg_master';
```

Get only rpg_master's most recent review:

```cql
SELECT game_title, review_date, rating
FROM reviews_by_user
WHERE username = 'rpg_master'
LIMIT 1;
```

> **SQL equivalent:** `SELECT game_title, review_date, rating FROM reviews WHERE username = 'rpg_master' ORDER BY review_date DESC LIMIT 1;`

Now write a query to get all reviews by **indie_lover**:

```cql
-- Write your SELECT here
```

---

## Part 4 - Time-Series: Activity Log (10 minutes)

### Why Cassandra Excels at Time-Series

Cassandra is widely used for time-series data such as logs, sensor readings, and event streams. The pattern is always the same: a high-cardinality entity (user, device, sensor) as the partition key, and a timestamp as the first clustering column in descending order. This gives fast access to the most recent events for any entity, and Cassandra handles millions of writes per second with low latency.

---

### Exercise 4.1 - Table Q8: User Activity Log

```cql
CREATE TABLE IF NOT EXISTS user_activity (
  username       TEXT,
  event_time     TIMESTAMP,
  event_type     TEXT,
  description    TEXT,
  PRIMARY KEY (username, event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);
```

Insert activity events:

```cql
INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('rpg_master', '2023-08-15 14:30:00+0000', 'PURCHASE', 'Purchased Baldur''s Gate 3');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('rpg_master', '2023-09-01 20:00:00+0000', 'REVIEW', 'Reviewed Baldur''s Gate 3 - Rating: 10');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('rpg_master', '2022-02-28 10:00:00+0000', 'PURCHASE', 'Purchased Elden Ring');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('rpg_master', '2022-03-15 22:00:00+0000', 'REVIEW', 'Reviewed Elden Ring - Rating: 9');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('gamer_pro123', '2020-02-01 11:00:00+0000', 'PURCHASE', 'Purchased Zelda: Breath of the Wild');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('gamer_pro123', '2020-02-15 19:00:00+0000', 'REVIEW', 'Reviewed Zelda: Breath of the Wild - Rating: 10');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('souls_veteran', '2022-03-10 09:00:00+0000', 'PURCHASE', 'Purchased Elden Ring');

INSERT INTO user_activity (username, event_time, event_type, description)
VALUES ('souls_veteran', '2022-03-20 23:00:00+0000', 'REVIEW', 'Reviewed Elden Ring - Rating: 10');
```

Query Q8: Get all recent activity for rpg_master (newest first):

```cql
SELECT event_time, event_type, description
FROM user_activity
WHERE username = 'rpg_master';
```

Get only the 3 most recent events:

```cql
SELECT event_time, event_type, description
FROM user_activity
WHERE username = 'rpg_master'
LIMIT 3;
```

Get activity in a specific time window:

```cql
SELECT event_time, event_type, description
FROM user_activity
WHERE username = 'rpg_master'
  AND event_time >= '2022-01-01'
  AND event_time <= '2023-01-01';
```

> **SQL equivalent:** `SELECT event_time, event_type, description FROM activity_log WHERE username = 'rpg_master' ORDER BY event_time DESC LIMIT 3;`

---

## Part 5 - Updates, Deletes, and TTL (15 minutes)

### Exercise 5.1 - UPDATE Existing Rows

Update the price of Cyberpunk 2077 in the `games` table:

```cql
UPDATE games
SET price = 29.99
WHERE title = 'Cyberpunk 2077';

SELECT title, price FROM games WHERE title = 'Cyberpunk 2077';
```

> **SQL equivalent:** `UPDATE games SET price = 29.99 WHERE title = 'Cyberpunk 2077';`  
> CQL syntax for single-row updates is nearly identical to SQL. The difference is that UPDATE in Cassandra always requires the full primary key.

Update rpg_master's hours played for Elden Ring:

```cql
UPDATE user_library
SET hours_played = 310.0
WHERE username = 'rpg_master' AND game_title = 'Elden Ring';

SELECT game_title, hours_played FROM user_library WHERE username = 'rpg_master' AND game_title = 'Elden Ring';
```

Now write an UPDATE to change **souls_veteran**'s hours for Hollow Knight to 260.0:

```cql
-- Write your UPDATE here
```

---

### Exercise 5.2 - Use TTL (Time to Live)

Insert a temporary promotional price for God of War Ragnarok that expires in 5 minutes (300 seconds):

```cql
INSERT INTO games (title, genre, release_date, metacritic_score, price, rating, publisher_name, developer_name, developer_country)
VALUES ('God of War Ragnarok', 'Action', '2022-11-09', 94, 39.99, 'M', 'Sony Interactive', 'Santa Monica Studio', 'USA')
USING TTL 300;
```

Check the remaining TTL on the price field:

```cql
SELECT TTL(price), title, price FROM games WHERE title = 'God of War Ragnarok';
```

> After 300 seconds, the row fields written with TTL will return null. The row itself may also disappear if all its non-primary-key fields expire (depending on the Cassandra version).

You can also set TTL on individual columns in an UPDATE:

```cql
UPDATE games USING TTL 3600
SET price = 34.99
WHERE title = 'Hades';

SELECT TTL(price), title, price FROM games WHERE title = 'Hades';
```

TTL is commonly used in GameVerse for:
- Promotional pricing (expires at end of sale)
- Session tokens in user data
- Temporary feature flags

---

### Exercise 5.3 - DELETE Rows and Columns

Delete a specific game from a user's library:

```cql
DELETE FROM user_library
WHERE username = 'gamer_pro123' AND game_title = 'Apex Legends';

SELECT game_title FROM user_library WHERE username = 'gamer_pro123';
```

> **SQL equivalent:** `DELETE FROM user_library WHERE username = 'gamer_pro123' AND game_title = 'Apex Legends';`

Delete only a specific column (set it to null) without removing the row:

```cql
DELETE review_text FROM reviews_by_user
WHERE username = 'rpg_master'
  AND review_date = '2021-02-10'
  AND game_title = 'Cyberpunk 2077';

SELECT * FROM reviews_by_user WHERE username = 'rpg_master';
```

> A column delete in Cassandra writes a **tombstone** — a special marker that hides the value. The row still exists; only that column is nullified.

---

## Part 6 - ALLOW FILTERING and Why to Avoid It (10 minutes)

### Exercise 6.1 - What Happens Without a Partition Key

Try querying `games` without the partition key:

```cql
SELECT * FROM games WHERE metacritic_score >= 95;
```

Cassandra will return an error:

```
InvalidRequest: Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING.
```

Now force it with `ALLOW FILTERING`:

```cql
SELECT title, metacritic_score FROM games WHERE metacritic_score >= 95 ALLOW FILTERING;
```

This works, but it performs a **full table scan** — it reads every partition in the table. With millions of rows distributed across a cluster, this query could read data from every node and take seconds or minutes.

> **Key lesson**: `ALLOW FILTERING` is acceptable only for data exploration in development. Never use it in production queries. The correct solution is to create a dedicated table (`games_by_score`) with `metacritic_score` as part of the partition or clustering key.

---

### Exercise 6.2 - The Correct Solution: Design a New Table

If "find games with score above 95" is a real application query, the correct Cassandra approach is to create a table for it.

A common pattern uses a **bucket** as the partition key to avoid a single hot partition:

```cql
CREATE TABLE IF NOT EXISTS top_games (
  score_bucket   TEXT,
  metacritic_score INT,
  title          TEXT,
  genre          TEXT,
  price          DECIMAL,
  PRIMARY KEY (score_bucket, metacritic_score, title)
) WITH CLUSTERING ORDER BY (metacritic_score DESC, title ASC);
```

Insert only games with a score of 90 or higher into the `high` bucket:

```cql
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 97, 'Disco Elysium', 'RPG', 39.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 97, 'Red Dead Redemption 2', 'Adventure', 59.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 97, 'The Legend of Zelda: Breath of the Wild', 'Adventure', 59.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 96, 'Elden Ring', 'RPG', 59.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 96, 'Baldur''s Gate 3', 'RPG', 59.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 94, 'God of War Ragnarok', 'Action', 69.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 94, 'Celeste', 'Platformer', 19.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 93, 'Hades', 'Roguelike', 24.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 93, 'The Last of Us Part II', 'Adventure', 69.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 92, 'The Witcher 3: Wild Hunt', 'RPG', 39.99);
INSERT INTO top_games (score_bucket, metacritic_score, title, genre, price) VALUES ('high', 90, 'Hollow Knight', 'Platformer', 14.99);
```

Now query the top 5 games efficiently:

```cql
SELECT title, metacritic_score FROM top_games
WHERE score_bucket = 'high'
LIMIT 5;
```

All games with score above 95:

```cql
SELECT title, metacritic_score FROM top_games
WHERE score_bucket = 'high' AND metacritic_score > 95;
```

No `ALLOW FILTERING` needed. The query reads a single partition.

---

## Bonus Challenges

If you finish early, try these:

**Bonus 1**: Design and create a table `games_by_developer_country` that supports the query "find all games made by developers from a given country". Insert data for at least two countries and write the SELECT query.

**Bonus 2**: Insert a new activity event for rpg_master with a TTL of 60 seconds. Use `SELECT TTL(description)` to watch the value count down. After 60 seconds, observe that the column returns null.

**Bonus 3**: Add a new column `platform_count` to the `games` table using `ALTER TABLE`. Then write UPDATE statements to set the correct value for Elden Ring (3 platforms) and Hades (4 platforms). Verify with SELECT.

**Bonus 4**: The `reviews_by_game` and `reviews_by_user` tables contain the same review data duplicated. Write a sequence of CQL statements that adds a new review (for a new user, casual_player, reviewing Stardew Valley with rating 9) to both tables consistently.

**Bonus 5**: Design a `leaderboard_by_genre` table that stores, for each genre, the top users by total hours played. Define the schema, insert sample data, and write a query to retrieve the top 3 most-played users in the RPG genre.

---

## Reflection Questions

Answer these after completing the exercise:

1. In this lab you created separate tables (`games`, `games_by_genre`, `games_by_platform`) to answer three different queries about games. In a relational database, all three queries would be answered by a single `games` table with indexes. What are the trade-offs of the Cassandra approach in terms of storage, write complexity, and query performance?

2. In Exercise 6.1 you saw that a query without a partition key requires `ALLOW FILTERING`. Why is this a problem at scale? What would happen if this query ran against a 10-node cluster with 100 million game records?

3. The `reviews_by_game` and `reviews_by_user` tables store identical review data. In the relational model, this would be considered a violation of normal form. Why is this duplication acceptable, and even desirable, in Cassandra?

4. You used TTL to insert a promotional price that expires automatically. Compare this to implementing the same feature in PostgreSQL. What infrastructure does PostgreSQL require (jobs, triggers, background tasks) that Cassandra provides natively?

5. In the `user_activity` table, the primary key is `(username, event_time)`. What would happen if two events for the same user occurred at exactly the same timestamp? How would you fix this?

6. Compare the CAP theorem positions of Cassandra and PostgreSQL. Cassandra is classified as AP (Available + Partition Tolerant). How does this affect the behaviour of the `reviews_by_game` and `reviews_by_user` tables when a network partition separates two Cassandra nodes? What is the consequence for consistency?
