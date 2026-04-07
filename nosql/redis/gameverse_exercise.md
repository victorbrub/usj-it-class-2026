# Author: Víctor Barceló
# GameVerse Redis Lab

**Duration**: 2 hours  
**Tool**: Redis Insight  
**Database**: GameVerse (adapted for Redis)

## Objectives

By the end of this lab you will be able to:

- Connect to a Redis server and navigate the CLI
- Model game and user data using appropriate Redis data structures
- Use Strings, Hashes, Sets, Sorted Sets, and Lists to represent GameVerse data
- Apply key naming conventions to organise data in a schema-free store
- Use TTL and expiration for session and cache scenarios
- Explain the trade-offs between Redis, MongoDB, and a relational database

## Dataset

This lab uses data drawn from the GameVerse database you already know from previous exercises. Rather than importing JSON files, you will enter the data directly using Redis commands — this is intentional, because it helps you understand how data modelling works in Redis.

The games and users below are a representative subset of the full dataset:

**Games (10 records):**

| Title | Genre | Score | Price | Rating | Platforms |
|---|---|---|---|---|---|
| Elden Ring | RPG | 96 | 59.99 | M | PC, PlayStation 5, Xbox Series X |
| The Legend of Zelda: Breath of the Wild | Adventure | 97 | 59.99 | E10+ | Nintendo Switch |
| Red Dead Redemption 2 | Adventure | 97 | 59.99 | M | PC, PlayStation 4, Xbox One |
| Baldur's Gate 3 | RPG | 96 | 59.99 | M | PC, PlayStation 5 |
| God of War Ragnarok | Action | 94 | 69.99 | M | PlayStation 5, PlayStation 4 |
| Hades | Roguelike | 93 | 24.99 | T | PC, PlayStation 5, Xbox Series X, Nintendo Switch |
| The Witcher 3: Wild Hunt | RPG | 92 | 39.99 | M | PC, PlayStation 4, Xbox One, Nintendo Switch |
| Hollow Knight | Platformer | 90 | 14.99 | E10+ | PC, PlayStation 4, Xbox One, Nintendo Switch |
| Apex Legends | Battle Royale | 89 | 0.00 | T | PC, PlayStation 5, Xbox Series X, Nintendo Switch |
| Cyberpunk 2077 | RPG | 86 | 49.99 | M | PC, PlayStation 5, Xbox Series X |

**Users (4 records):**

| Username | Country | Premium | Total Spent |
|---|---|---|---|
| gamer_pro123 | USA | yes | 119.98 |
| zelda_fan | Canada | yes | 309.96 |
| rpg_master | UK | yes | 209.97 |
| speed_runner | Japan | no | 124.97 |

---

## Redis Data Modelling: A Key Concept

Before starting, understand one fundamental difference from MongoDB and SQL:

**Redis has no collections and no documents.** Every value lives under a single flat key. You are responsible for organising your data through key naming conventions and by choosing the right data structure for each use case.

A common naming pattern uses colons as separators:

```
game:elden-ring:score          → a String storing the metacritic score
game:elden-ring:platforms      → a Set of platform names
user:rpg_master:profile        → a Hash storing user profile fields
leaderboard:metacritic         → a Sorted Set linking game titles to scores
feed:user:gamer_pro123         → a List of recent activity events
```

This lab will guide you through building such a structure for the GameVerse dataset.

---

## Part 0 - Setup (5 minutes)

### Step 0.0 - Install Redis on Windows

Redis does not have an official native Windows build. The recommended approach is to use **Windows Subsystem for Linux (WSL 2)**, which provides a real Linux environment inside Windows.

**1. Enable WSL 2**

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

This installs WSL 2 and the default Ubuntu distribution. Restart your machine when prompted.

**2. Open Ubuntu from the Start menu**

After the restart, open Ubuntu from the Start menu. Complete the first-run setup (create a Unix username and password).

**3. Install Redis inside Ubuntu**

In the Ubuntu terminal, run:

```bash
sudo apt update
sudo apt install redis -y
```

Verify the installation:

```bash
redis-server --version
```

**4. Start the Redis server**

```bash
redis-server --daemonize yes
```

The `--daemonize yes` flag runs Redis in the background. You can verify it is running with:

```bash
redis-cli ping
```

Expected reply: `PONG`

> To stop the server: `redis-cli shutdown`

**5. Download and install Redis Insight**

Download the Redis Insight installer for Windows from the official website:

[redis.io/redis-insight](https://redis.io/redis-insight)

Run the `.exe` installer and follow the setup wizard. Redis Insight is a native Windows application — it connects to the Redis server running inside WSL over `127.0.0.1:6379`.

---

Choose one of the two options below to connect and run commands. All Redis commands throughout the lab are identical regardless of which option you use — only the interface differs.

---

### Option A: Redis Insight (graphical interface)

#### Step 0.1A - Open Redis Insight and Add a Connection

Open Redis Insight. On the home screen, click **Add Redis Database**.

Enter the following connection details for your local Redis server:

- **Host**: `127.0.0.1`
- **Port**: `6379`
- **Name**: `GameVerse Lab` (optional label for your reference)

Click **Add Redis Database**. Redis Insight will test the connection and add it to the list. Click the database name to open it.

If Redis is not running, start it in a terminal first:

```bash
redis-server
```

Then return to Redis Insight and retry.

#### Step 0.2A - Select Database 1

Redis has 16 numbered databases (0–15). Use database 1 to keep this lab separate from other work.

Locate the database selector in the bottom-left corner of Redis Insight (labelled **db0** by default). Click it and select **db1**.

> **All Redis commands in this lab are entered in the Workbench.** Click the **Workbench** icon in the left sidebar (looks like a terminal with a pencil) to open the command editor.

#### Step 0.3A - Verify the Connection

In the Workbench editor, type the following and click **Run** (or press Ctrl+Enter):

```
PING
```

Redis should reply: `PONG`

Check how many keys currently exist in database 1:

```
DBSIZE
```

If it returns `0`, the database is empty and you are ready to begin.

> **Checkpoint**: You should see `PONG` in the results panel below the editor. The database selector in the bottom-left should show **db1**.

---

### Option B: redis-cli (command line)

#### Step 0.1B - Connect to Redis

Open a terminal (on Windows, open the Ubuntu WSL terminal). Connect to the local Redis server:

```bash
redis-cli
```

You should see the prompt `127.0.0.1:6379>`. This confirms the connection is working.

If Redis is not running, start it first in a separate terminal:

```bash
redis-server --daemonize yes
```

Then re-run `redis-cli`.

#### Step 0.2B - Select Database 1

Redis has 16 numbered databases (0–15). Use database 1 to keep this lab separate from other work:

```
SELECT 1
```

Reply: `OK`

The prompt will change to `127.0.0.1:6379[1]>`. The `[1]` confirms you are now in database 1.

#### Step 0.3B - Verify the Connection

```
PING
```

Redis should reply: `PONG`

Count how many keys currently exist in database 1:

```
DBSIZE
```

If it returns `(integer) 0`, the database is empty and you are ready to begin.

> **Checkpoint**: The prompt should read `127.0.0.1:6379[1]>`. `PING` returns `PONG` and `DBSIZE` returns `(integer) 0`.

---

## Part 1 - Strings: Individual Game Properties (15 minutes)

### How Strings Work in Redis

A Redis String stores a single value under a single key. The value can be text, a number, or binary data. Strings are the simplest structure but are useful for caching individual fields (a price, a score, a status flag) and for atomic counters.

The key name is just a string — Redis has no concept of tables or collections, so the convention `game:<slug>:<field>` is used to organise keys logically.

**SQL comparison:**

In a relational database, a row in the `games` table stores all fields together. In Redis, each field becomes its own key — or, more efficiently, a Hash (covered in Part 2). Strings are best used for single values you need to access or update independently and atomically.

---

### Exercise 1.1 - Store Basic Game Properties

Store the metacritic score and price for three games:

```bash
SET game:elden-ring:score 96
SET game:elden-ring:price 59.99

SET game:hades:score 93
SET game:hades:price 24.99

SET game:hollow-knight:score 90
SET game:hollow-knight:price 14.99
```

Retrieve them:

```bash
GET game:elden-ring:score
GET game:hades:price
```

Retrieve multiple keys in a single command:

```bash
MGET game:elden-ring:score game:hades:score game:hollow-knight:score
```

> **SQL equivalent:** `SELECT metacritic_score FROM games WHERE title IN ('Elden Ring', 'Hades', 'Hollow Knight');`  
> Note: In SQL, a single query returns multiple rows. In Redis, `MGET` returns multiple values in one round trip.

---

### Exercise 1.2 - Counters

Redis Strings support atomic integer operations. This is commonly used for counters, such as tracking how many times a game page has been viewed.

Simulate a page view counter for the Elden Ring game page:

```bash
SET views:game:elden-ring 0
INCR views:game:elden-ring
INCR views:game:elden-ring
INCR views:game:elden-ring
GET views:game:elden-ring
```

Add 50 more views at once using `INCRBY`:

```bash
INCRBY views:game:elden-ring 50
GET views:game:elden-ring
```

Now apply a discount to the Hades price using `INCRBYFLOAT`:

```bash
INCRBYFLOAT game:hades:price -5.00
GET game:hades:price
```

> **SQL equivalent:** `UPDATE games SET price = price - 5.00 WHERE title = 'Hades';`  
> The Redis version is atomic without requiring a transaction.

---

### Exercise 1.3 - Store and Update Cyberpunk 2077

Store the score and price for Cyberpunk 2077:

```bash
SET game:cyberpunk-2077:score 86
SET game:cyberpunk-2077:price 49.99
```

After a patch, the score improved. Update it:

```bash
SET game:cyberpunk-2077:score 88
GET game:cyberpunk-2077:score
```

Apply a permanent price reduction to 29.99:

```bash
SET game:cyberpunk-2077:price 29.99
```

Now write commands on your own:

Store the score and price for **God of War Ragnarok** (score: 94, price: 69.99):

```bash
# Write your commands here
```

Retrieve both values with a single `MGET` command:

```bash
# Write your command here
```

---

### Exercise 1.4 - Key Inspection

List all keys matching the pattern `game:*:score` using `SCAN`:

```bash
SCAN 0 MATCH "game:*:score" COUNT 100
```

> Note: Use `SCAN` instead of `KEYS` in production environments. `KEYS` blocks the server on large datasets; `SCAN` is non-blocking.

Check whether a key exists:

```bash
EXISTS game:elden-ring:score
EXISTS game:doesnotexist:score
```

Check the data type of a key:

```bash
TYPE game:elden-ring:score
```

---

## Part 2 - Hashes: Game and User Profiles (20 minutes)

### How Hashes Work in Redis

A Redis Hash stores multiple field-value pairs under one key. It is the closest Redis equivalent to a row in a SQL table or a document in MongoDB. Rather than creating one key per field (as in Part 1), a Hash groups related fields together.

**Comparison:**

| Structure | SQL | MongoDB | Redis |
|---|---|---|---|
| All fields for one game | Row in `games` table | Document in `games` collection | Hash at `game:elden-ring` |
| Access one field | `SELECT score FROM games WHERE ...` | `db.games.findOne({title:"..."}, {score:1})` | `HGET game:elden-ring score` |
| Access all fields | `SELECT * FROM games WHERE ...` | `db.games.findOne({title:"..."})` | `HGETALL game:elden-ring` |

---

### Exercise 2.1 - Create Game Hashes

Store the full profile for Elden Ring as a Hash:

```bash
HSET game:elden-ring title "Elden Ring" genre "RPG" metacritic_score 96 price 59.99 rating "M" release_date "2022-02-25" publisher "Bandai Namco" developer "FromSoftware"
```

Retrieve all fields:

```bash
HGETALL game:elden-ring
```

Retrieve a single field:

```bash
HGET game:elden-ring genre
HGET game:elden-ring metacritic_score
```

Retrieve several specific fields at once:

```bash
HMGET game:elden-ring title genre price
```

> **SQL equivalent:** `SELECT title, genre, price FROM games WHERE title = 'Elden Ring';`

---

### Exercise 2.2 - Create More Game Hashes

Store the profiles for Hades and The Witcher 3:

```bash
HSET game:hades title "Hades" genre "Roguelike" metacritic_score 93 price 24.99 rating "T" release_date "2020-09-17" publisher "Supergiant Games" developer "Supergiant Games"

HSET game:witcher-3 title "The Witcher 3: Wild Hunt" genre "RPG" metacritic_score 92 price 39.99 rating "M" release_date "2015-05-19" publisher "CD Projekt" developer "CD Projekt Red"
```

Now write the command to store **Baldur's Gate 3** (score: 96, price: 59.99, genre: RPG, rating: M, publisher: Larian Studios, developer: Larian Studios, release_date: 2023-08-03):

```bash
# Write your HSET command here
```

---

### Exercise 2.3 - Update Hash Fields

Reduce the Witcher 3 price to 19.99 using `HSET` (it overwrites existing fields):

```bash
HSET game:witcher-3 price 19.99
HGET game:witcher-3 price
```

Increment the Hades metacritic score by 1 using `HINCRBY`:

```bash
HINCRBY game:hades metacritic_score 1
HGET game:hades metacritic_score
```

Check whether the `dlc_available` field exists in the Elden Ring hash:

```bash
HEXISTS game:elden-ring dlc_available
```

Add it:

```bash
HSET game:elden-ring dlc_available 1
HEXISTS game:elden-ring dlc_available
```

Get all field names (keys) in a hash:

```bash
HKEYS game:elden-ring
```

Get only the values:

```bash
HVALS game:elden-ring
```

Count the number of fields:

```bash
HLEN game:elden-ring
```

---

### Exercise 2.4 - User Profile Hashes

Store the profiles for two users:

```bash
HSET user:rpg_master username "rpg_master" email "rpg@email.com" country "UK" role "analyst" is_premium 1 total_spent 209.97 account_status "active" registration_date "2021-06-22"

HSET user:gamer_pro123 username "gamer_pro123" email "gamer@email.com" country "USA" role "user" is_premium 1 total_spent 119.98 account_status "active" registration_date "2020-01-15"
```

Retrieve the country and total_spent for rpg_master:

```bash
HMGET user:rpg_master country total_spent
```

Now write commands to store the **zelda_fan** profile (country: Canada, is_premium: 1, total_spent: 309.96, account_status: active):

```bash
# Write your HSET command here
```

> **Checkpoint**: Run `HGETALL user:rpg_master` and compare the output to the original `users.json` document. What fields from the JSON document are missing in the Redis hash, and why?

---

## Part 3 - Sets: Tags, Platforms, and Libraries (15 minutes)

### How Sets Work in Redis

A Redis Set is an unordered collection of unique strings. Sets are ideal for representing many-to-many relationships (a game has many platforms, a user owns many games) and for computing intersections and unions.

**Comparison:**

In a relational database, platforms would be stored in a join table (`game_platforms`). In MongoDB, they are an embedded array. In Redis, they become a Set under a dedicated key.

---

### Exercise 3.1 - Platforms per Game

Add the platforms for Elden Ring:

```bash
SADD game:elden-ring:platforms "PC" "PlayStation 5" "Xbox Series X"
```

List all platforms:

```bash
SMEMBERS game:elden-ring:platforms
```

Check whether Elden Ring is available on Nintendo Switch:

```bash
SISMEMBER game:elden-ring:platforms "Nintendo Switch"
```

Count the number of platforms:

```bash
SCARD game:elden-ring:platforms
```

> **SQL equivalent:**
> ```sql
> SELECT p.name FROM platforms p
> JOIN game_platforms gp ON p.id = gp.platform_id
> JOIN games g ON gp.game_id = g.id
> WHERE g.title = 'Elden Ring';
> ```
> Redis requires no JOIN — the data is directly accessible under the game's key.

Now add platforms for The Witcher 3 and Hades:

```bash
SADD game:witcher-3:platforms "PC" "PlayStation 4" "Xbox One" "Nintendo Switch"
SADD game:hades:platforms "PC" "PlayStation 5" "Xbox Series X" "Nintendo Switch"
```

---

### Exercise 3.2 - Set Operations: Finding Common Platforms

Find games available on **both** Nintendo Switch and PC (intersection of Witcher 3 and Hades platforms):

```bash
SINTER game:witcher-3:platforms game:hades:platforms
```

> **SQL equivalent:** Find games available on multiple specific platforms using a self-join or `HAVING COUNT(DISTINCT platform) = 2`.

Find all platforms covered by either game (union):

```bash
SUNION game:witcher-3:platforms game:hades:platforms
```

Find platforms where Witcher 3 is available but Hades is not (difference):

```bash
SDIFF game:witcher-3:platforms game:hades:platforms
```

Now write a command to find all platforms where **both** Elden Ring and Hades are available:

```bash
# Write your SINTER command here
```

---

### Exercise 3.3 - Tags per Game

Add tags for Elden Ring and The Witcher 3:

```bash
SADD game:elden-ring:tags "open-world" "souls-like" "challenging" "fantasy"
SADD game:witcher-3:tags "open-world" "fantasy" "RPG" "narrative"
```

Find all tags that both games share:

```bash
SINTER game:elden-ring:tags game:witcher-3:tags
```

Find tags that are on Elden Ring but not on Witcher 3:

```bash
SDIFF game:elden-ring:tags game:witcher-3:tags
```

Now write commands to:

1. Add these tags to Hades: `roguelike`, `mythology`, `indie`, `action`
2. Find the union of all tags across Elden Ring, Witcher 3, and Hades

```bash
# Write your commands here
```

---

### Exercise 3.4 - User Game Libraries

A user's library is the set of games they own. Model it as a Set.

Add the library for rpg_master:

```bash
SADD user:rpg_master:library "Cyberpunk 2077" "Elden Ring" "The Witcher 3: Wild Hunt" "Baldur's Gate 3"
```

Add the library for gamer_pro123:

```bash
SADD user:gamer_pro123:library "The Legend of Zelda: Breath of the Wild" "Elden Ring" "Halo Infinite" "Apex Legends"
```

Check whether rpg_master owns Elden Ring:

```bash
SISMEMBER user:rpg_master:library "Elden Ring"
```

Check whether gamer_pro123 owns Cyberpunk 2077:

```bash
SISMEMBER user:gamer_pro123:library "Cyberpunk 2077"
```

Find games that **both** users own (common games):

```bash
SINTER user:rpg_master:library user:gamer_pro123:library
```

Find all unique games across both libraries:

```bash
SUNION user:rpg_master:library user:gamer_pro123:library
```

> **SQL equivalent:**
> ```sql
> SELECT game_title FROM user_library WHERE user_id = (SELECT id FROM users WHERE username = 'rpg_master')
> INTERSECT
> SELECT game_title FROM user_library WHERE user_id = (SELECT id FROM users WHERE username = 'gamer_pro123');
> ```

Now add **zelda_fan**'s library (games: The Legend of Zelda: Breath of the Wild, Animal Crossing: New Horizons, Hollow Knight, Hades) and find games shared between zelda_fan and gamer_pro123:

```bash
# Write your commands here
```

---

## Part 4 - Sorted Sets: Leaderboards and Rankings (15 minutes)

### How Sorted Sets Work in Redis

A Redis Sorted Set stores unique members each associated with a floating-point score. Members are always sorted by score. This structure is ideal for leaderboards, rankings, and any scenario where you need fast retrieval of top-N items or items within a score range.

**Comparison:**

| Task | SQL | Redis Sorted Set |
|---|---|---|
| Insert game with score | `INSERT INTO leaderboard ...` | `ZADD leaderboard <score> <member>` |
| Top 5 by score (desc) | `ORDER BY score DESC LIMIT 5` | `ZREVRANGE leaderboard 0 4` |
| Score for one game | `SELECT score FROM ... WHERE title = ...` | `ZSCORE leaderboard <member>` |
| Games above score 90 | `WHERE score >= 90` | `ZRANGEBYSCORE leaderboard 90 +inf` |

---

### Exercise 4.1 - Build the Metacritic Leaderboard

Add all ten games to the leaderboard with their metacritic scores:

```bash
ZADD leaderboard:metacritic 96 "Elden Ring"
ZADD leaderboard:metacritic 97 "The Legend of Zelda: Breath of the Wild"
ZADD leaderboard:metacritic 97 "Red Dead Redemption 2"
ZADD leaderboard:metacritic 96 "Baldur's Gate 3"
ZADD leaderboard:metacritic 94 "God of War Ragnarok"
ZADD leaderboard:metacritic 93 "Hades"
ZADD leaderboard:metacritic 92 "The Witcher 3: Wild Hunt"
ZADD leaderboard:metacritic 90 "Hollow Knight"
ZADD leaderboard:metacritic 89 "Apex Legends"
ZADD leaderboard:metacritic 86 "Cyberpunk 2077"
```

Retrieve all games sorted from lowest to highest score:

```bash
ZRANGE leaderboard:metacritic 0 -1 WITHSCORES
```

Retrieve all games sorted from highest to lowest score:

```bash
ZREVRANGE leaderboard:metacritic 0 -1 WITHSCORES
```

> **SQL equivalent:**
> ```sql
> SELECT title, metacritic_score FROM games ORDER BY metacritic_score DESC;
> ```

---

### Exercise 4.2 - Top Games and Score Queries

Get the top 3 games by metacritic score:

```bash
ZREVRANGE leaderboard:metacritic 0 2 WITHSCORES
```

> **SQL equivalent:** `SELECT title, metacritic_score FROM games ORDER BY metacritic_score DESC LIMIT 3;`

Get the rank of Cyberpunk 2077 (0-based, lowest score = rank 0):

```bash
ZRANK leaderboard:metacritic "Cyberpunk 2077"
```

Get the rank in descending order (highest score = rank 0):

```bash
ZREVRANK leaderboard:metacritic "Cyberpunk 2077"
```

Get the exact score for Elden Ring:

```bash
ZSCORE leaderboard:metacritic "Elden Ring"
```

Find all games with a metacritic score of **90 or higher**:

```bash
ZRANGEBYSCORE leaderboard:metacritic 90 +inf WITHSCORES
```

> **SQL equivalent:** `SELECT title, metacritic_score FROM games WHERE metacritic_score >= 90;`

Find all games with a score **between 92 and 96 (inclusive)**:

```bash
ZRANGEBYSCORE leaderboard:metacritic 92 96 WITHSCORES
```

Count how many games have a score above 92:

```bash
ZCOUNT leaderboard:metacritic 93 +inf
```

> **SQL equivalent:** `SELECT COUNT(*) FROM games WHERE metacritic_score > 92;`

---

### Exercise 4.3 - Score Updates

After a re-review, Cyberpunk 2077 receives an updated score of 88. Update it:

```bash
ZADD leaderboard:metacritic 88 "Cyberpunk 2077"
ZSCORE leaderboard:metacritic "Cyberpunk 2077"
ZREVRANK leaderboard:metacritic "Cyberpunk 2077"
```

> Note: `ZADD` on an existing member overwrites its score and re-sorts it automatically.

Alternatively, increment the score by a delta using `ZINCRBY`:

```bash
ZINCRBY leaderboard:metacritic 2 "Cyberpunk 2077"
ZSCORE leaderboard:metacritic "Cyberpunk 2077"
```

Now write commands to:

1. Find all games with a metacritic score **below 90**
2. Find the rank of Hades in the descending leaderboard

```bash
# Write your commands here
```

---

### Exercise 4.4 - User Spending Leaderboard

Build a sorted set ranking users by total amount spent:

```bash
ZADD leaderboard:user:spending 309.96 "zelda_fan"
ZADD leaderboard:user:spending 209.97 "rpg_master"
ZADD leaderboard:user:spending 124.97 "speed_runner"
ZADD leaderboard:user:spending 119.98 "gamer_pro123"
```

Get the top spender:

```bash
ZREVRANGE leaderboard:user:spending 0 0 WITHSCORES
```

Simulate a new purchase: rpg_master buys a game for 59.99:

```bash
ZINCRBY leaderboard:user:spending 59.99 "rpg_master"
ZREVRANGE leaderboard:user:spending 0 -1 WITHSCORES
```

> **Checkpoint**: Did rpg_master move up in rank after the purchase? Use `ZREVRANK` to check.

---

## Part 5 - Lists: Activity Feeds and Review Queues (15 minutes)

### How Lists Work in Redis

A Redis List is an ordered sequence of strings. New items can be pushed to either end. Lists are ideal for activity feeds (where the most recent event is listed first), message queues, and recent-items caches.

**Comparison:**

| Use case | SQL equivalent | Redis List |
|---|---|---|
| Recent reviews for a game | `SELECT ... ORDER BY date DESC LIMIT 10` | `LRANGE reviews:game:elden-ring 0 9` after pushing newest first |
| Activity log for a user | `SELECT ... FROM activity WHERE user_id = ... ORDER BY time DESC` | `LRANGE feed:user:rpg_master 0 -1` |
| Review processing queue | Queue table with status column | `LPUSH` / `RPOP` pattern |

---

### Exercise 5.1 - User Activity Feed

Simulate a recent activity feed for rpg_master. The feed stores the most recent events at the left (index 0).

```bash
LPUSH feed:user:rpg_master "Purchased Baldur's Gate 3"
LPUSH feed:user:rpg_master "Reviewed The Witcher 3: Wild Hunt - Rating: 10"
LPUSH feed:user:rpg_master "Purchased The Witcher 3: Wild Hunt"
LPUSH feed:user:rpg_master "Reviewed Elden Ring - Rating: 9"
LPUSH feed:user:rpg_master "Purchased Elden Ring"
```

Read the full feed (most recent first):

```bash
LRANGE feed:user:rpg_master 0 -1
```

Read only the 3 most recent events:

```bash
LRANGE feed:user:rpg_master 0 2
```

> **SQL equivalent:** `SELECT event FROM activity_log WHERE user_id = ... ORDER BY created_at DESC LIMIT 3;`

Count how many events are in the feed:

```bash
LLEN feed:user:rpg_master
```

---

### Exercise 5.2 - Bounding the Feed (Trim)

To avoid unbounded memory growth, keep only the 10 most recent events per user. Use `LTRIM` after each push:

```bash
LPUSH feed:user:rpg_master "Purchased Cyberpunk 2077"
LTRIM feed:user:rpg_master 0 9
LRANGE feed:user:rpg_master 0 -1
```

> This pattern (push then trim) is standard for bounded activity feeds in production Redis applications.

Now write commands to:

1. Create a feed for **gamer_pro123** with at least three events (purchases or reviews)
2. Trim it to a maximum of 5 events

```bash
# Write your commands here
```

---

### Exercise 5.3 - Review Processing Queue

Simulate a background queue where new review submissions are added to the right and a worker processes them from the right (LIFO stack) or the left (FIFO queue).

Add pending reviews to the queue:

```bash
RPUSH queue:reviews "rpg_master:Baldur's Gate 3:10:Amazing depth and strategic combat"
RPUSH queue:reviews "gamer_pro123:Elden Ring:9:Difficult but incredibly rewarding"
RPUSH queue:reviews "zelda_fan:Hades:10:Best roguelike ever made"
```

Check how many reviews are waiting:

```bash
LLEN queue:reviews
```

Process (pop) the oldest review first (FIFO):

```bash
LPOP queue:reviews
LLEN queue:reviews
```

> **SQL equivalent:** `SELECT ... FROM review_queue ORDER BY submitted_at ASC LIMIT 1;` followed by `DELETE`.  
> The Redis version is atomic — a single `LPOP` both retrieves and removes the item with no risk of another worker claiming the same item.

---

### Exercise 5.4 - Recent Reviews per Game

Store the three most recent reviews for Elden Ring (newest first):

```bash
LPUSH reviews:game:elden-ring "gamer_pro123|9|Difficult but incredibly rewarding"
LPUSH reviews:game:elden-ring "rpg_master|9|Incredible challenge and world design"
LPUSH reviews:game:elden-ring "speed_runner|8|Amazing game, brutal difficulty"
```

Retrieve all reviews:

```bash
LRANGE reviews:game:elden-ring 0 -1
```

Get only the most recent review:

```bash
LINDEX reviews:game:elden-ring 0
```

Now write commands to add a new review for Hades from zelda_fan (rating: 10) and trim the list to the most recent 5:

```bash
# Write your commands here
```

---

## Part 6 - Expiration and Session Caching (10 minutes)

### When to Use TTL in GameVerse

Redis keys can be given a time-to-live (TTL) after which they are automatically deleted. In a production game platform this is used for:

- **User sessions**: Session tokens expire after inactivity
- **Price cache**: Cached prices expire and are re-fetched from the database
- **Rate limiting**: API call counters expire at the end of each window

---

### Exercise 6.1 - Session Management

Create a session for rpg_master that expires after 30 minutes (1800 seconds):

```bash
HSET session:abc123 user_id "rpg_master" role "analyst" login_time "2026-04-07T10:00:00Z"
EXPIRE session:abc123 1800
```

Check the remaining TTL:

```bash
TTL session:abc123
```

Simulate session activity: reset the TTL back to 1800 seconds (as if the user just made a request):

```bash
EXPIRE session:abc123 1800
```

Check what happens if you call TTL on a key with no expiration:

```bash
TTL game:elden-ring
```

> A return value of `-1` means the key exists but has no expiration (it is persistent). A value of `-2` means the key does not exist.

---

### Exercise 6.2 - Price Cache with Expiration

Cache the current price of God of War Ragnarok for 10 minutes (600 seconds):

```bash
SETEX price_cache:god-of-war-ragnarok 600 69.99
TTL price_cache:god-of-war-ragnarok
```

Alternatively, combine `SET` with the `EX` option:

```bash
SET price_cache:cyberpunk-2077 29.99 EX 600
TTL price_cache:cyberpunk-2077
```

Remove the expiration from the Cyberpunk 2077 price cache (make it permanent):

```bash
PERSIST price_cache:cyberpunk-2077
TTL price_cache:cyberpunk-2077
```

---

### Exercise 6.3 - Rate Limiting

Simulate an API rate limiter that allows a maximum of 10 requests per minute per user.

Create a counter for rpg_master with a 60-second expiration:

```bash
SET rate:rpg_master:api 0 EX 60
INCR rate:rpg_master:api
INCR rate:rpg_master:api
INCR rate:rpg_master:api
GET rate:rpg_master:api
TTL rate:rpg_master:api
```

After 60 seconds the key will auto-delete, and the counter resets for the next request window.

Now write commands to:

1. Create a session for **zelda_fan** using a Hash with an expiration of 1 hour (3600 seconds)
2. Verify the TTL on that session key

```bash
# Write your commands here
```

---

## Part 7 - Combining Data Structures (10 minutes)

Real applications use multiple Redis data structures together. This section walks through two realistic GameVerse scenarios.

---

### Scenario 7.1 - Game Detail Page

When a user visits the Elden Ring game page, the platform needs:

1. The game's metadata (title, genre, score)
2. The list of platforms
3. The current view count
4. The 5 most recent reviews

All of this is accessible through separate Redis keys, following the naming convention:

```bash
# Game metadata
HGETALL game:elden-ring

# Platforms
SMEMBERS game:elden-ring:platforms

# View count (increment on each page visit)
INCR views:game:elden-ring
GET views:game:elden-ring

# 5 most recent reviews
LRANGE reviews:game:elden-ring 0 4
```

In a single application request, these four calls retrieve everything needed. There are no joins.

> **SQL equivalent:** This would require joining `games`, `game_platforms`, `platforms`, and `reviews` tables, plus a separate counter update.

---

### Scenario 7.2 - User Dashboard

When rpg_master logs in, the dashboard needs:

1. Their profile information
2. Their game library
3. Their rank on the spending leaderboard
4. Their 5 most recent activity events

```bash
# Profile
HGETALL user:rpg_master

# Library
SMEMBERS user:rpg_master:library

# Spending rank (0-based from highest)
ZREVRANK leaderboard:user:spending "rpg_master"

# Recent activity
LRANGE feed:user:rpg_master 0 4
```

Now write a sequence of Redis commands to build a **game of the year summary** page that shows:

1. The top 3 games by metacritic score (from the sorted set)
2. The total number of games in the leaderboard
3. The genre of the top-ranked game (from its hash)

```bash
# Write your commands here
```

---

## Bonus Challenges

If you finish early, try these:

**Bonus 1**: Store the tags for all 10 games in the dataset table. Then use `SUNIONSTORE` to create a new key `all:tags` containing every unique tag across all games. Count how many unique tags exist.

**Bonus 2**: Create a sorted set `leaderboard:genre:rpg` containing only RPG games (Elden Ring, Witcher 3, Cyberpunk 2077, Baldur's Gate 3) with their metacritic scores. Then compute the average RPG score manually using `ZRANGEBYSCORE` and basic arithmetic.

**Bonus 3**: Simulate a friend recommendation system. Create sets for the libraries of all four users. For each pair of users, compute the intersection (shared games). Which two users have the most games in common?

**Bonus 4**: Build a composite access control structure. Create a set `role:analyst:permissions` with members `read:games`, `read:users`, `read:reports`. Create a set `role:user:permissions` with members `read:games`. When rpg_master (role: analyst) makes a request, check whether `read:reports` is in their role's permission set using `SISMEMBER`.

**Bonus 5**: Implement a bounded recent-purchases list for each user. For every game in rpg_master's library, push an entry to `purchases:rpg_master` using `LPUSH`. Then add a TTL of 24 hours to the list key and verify it with `TTL`.

---

## Reflection Questions

Answer these after completing the exercise:

1. In MongoDB, all fields of a game document are stored together in a single document. In Redis, you spread game data across multiple keys (`game:elden-ring`, `game:elden-ring:platforms`, `game:elden-ring:tags`). What are the advantages and disadvantages of this approach?

2. You used a Sorted Set to build a metacritic leaderboard. How would you implement the same feature in a relational database? What happens to performance as the number of games grows to millions?

3. Redis has no query language. You cannot write `WHERE genre = 'RPG'` to filter games. How would you design a data model in Redis that allows efficient retrieval of all games in a given genre? What trade-offs does this introduce?

4. In Exercise 6.3, you used a String with a TTL for rate limiting. Why is Redis especially well suited for this use case compared to a relational database?

5. Sorted Sets maintain their members in sorted order at all times. Compare this to adding an index to a column in SQL. When would you prefer a Redis Sorted Set over a SQL index for a leaderboard, and when would you prefer the SQL approach?

6. The GameVerse data in Redis is split across many keys. If a game's title changes (e.g., a remaster is renamed), which keys would need to be updated? Compare this to updating a single row in a relational database. What does this tell you about data redundancy in Redis?
