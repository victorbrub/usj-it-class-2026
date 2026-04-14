# Author: Víctor Barceló
# GameVerse Neo4j Lab

**Duration**: 2 hours  
**Tool**: Neo4j Browser (http://localhost:7474)  
**Database**: GameVerse (adapted for graph model)

## Objectives

By the end of this lab you will be able to:

- Model GameVerse entities as nodes with labels and properties
- Model relationships between entities (games, publishers, developers, users, platforms)
- Write Cypher queries to find, filter, and traverse the graph
- Use aggregation and path queries
- Explain how a graph model differs from relational and document models for connected data

## The Graph Model for GameVerse

In a relational database, GameVerse uses separate tables for games, publishers, developers, users, and join tables for platforms, libraries, and reviews. In MongoDB, publisher and developer data is embedded inside each game document.

In Neo4j, each entity becomes a **node** and each relationship between entities becomes an explicit **edge** in the graph. There are no join tables and no embedded documents — connections are first-class citizens.

**Node labels used in this lab:**

| Label | Represents |
|---|---|
| `Game` | A video game |
| `Publisher` | A company that published a game |
| `Developer` | A studio that developed a game |
| `User` | A registered platform user |
| `Platform` | A gaming platform (PC, PlayStation 5, etc.) |
| `Genre` | A game genre (RPG, Action, etc.) |
| `Tag` | A descriptive tag (open-world, indie, etc.) |

**Relationship types used in this lab:**

| Relationship | Meaning |
|---|---|
| `(:Publisher)-[:PUBLISHED]->(:Game)` | Publisher published this game |
| `(:Developer)-[:DEVELOPED]->(:Game)` | Developer developed this game |
| `(:Game)-[:AVAILABLE_ON]->(:Platform)` | Game is available on this platform |
| `(:Game)-[:HAS_GENRE]->(:Genre)` | Game belongs to this genre |
| `(:Game)-[:TAGGED]->(:Tag)` | Game has this tag |
| `(:User)-[:OWNS]->(:Game)` | User owns this game in their library |
| `(:User)-[:REVIEWED {rating, text}]->(:Game)` | User reviewed this game |
| `(:Developer)-[:LOCATED_IN {country}]->(:Publisher)` | Same studio group, shared country context |

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Open Neo4j Browser

1. Start Neo4j Desktop or your local Neo4j server.
2. Open a browser and navigate to: `http://localhost:7474`
3. Log in with your credentials (default: `neo4j` / `neo4j` — you will be asked to change the password on first login).
4. You should see the Neo4j Browser with a blank query editor.

### Step 0.2 - Clear Any Existing Data

If there is leftover data from previous sessions, delete it:

```cypher
MATCH (n)
DETACH DELETE n;
```

Confirm the database is empty:

```cypher
MATCH (n)
RETURN count(n) AS total_nodes;
```

The result should be `0`.

### Step 0.3 - Create Constraints

Constraints ensure data integrity. Create a uniqueness constraint on each node type so duplicate nodes are never created:

```cypher
CREATE CONSTRAINT game_title IF NOT EXISTS
FOR (g:Game) REQUIRE g.title IS UNIQUE;

CREATE CONSTRAINT publisher_name IF NOT EXISTS
FOR (p:Publisher) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT developer_name IF NOT EXISTS
FOR (d:Developer) REQUIRE d.name IS UNIQUE;

CREATE CONSTRAINT user_username IF NOT EXISTS
FOR (u:User) REQUIRE u.username IS UNIQUE;

CREATE CONSTRAINT platform_name IF NOT EXISTS
FOR (p:Platform) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT genre_name IF NOT EXISTS
FOR (g:Genre) REQUIRE g.name IS UNIQUE;

CREATE CONSTRAINT tag_name IF NOT EXISTS
FOR (t:Tag) REQUIRE t.name IS UNIQUE;
```

> **Checkpoint**: Run `:schema` in the browser to see the constraints you just created.

---

## Part 1 - Creating Nodes (15 minutes)

### How `CREATE` and `MERGE` Work

`CREATE` always creates a new node, even if one with the same properties already exists.  
`MERGE` creates a node only if it does not exist yet — otherwise it matches the existing one. Use `MERGE` for reference nodes (platforms, genres, tags) so they are not duplicated.

---

### Exercise 1.1 - Create Publisher and Developer Nodes

```cypher
// Publishers
MERGE (:Publisher {name: "Bandai Namco", country: "Japan", founded_year: 1955});
MERGE (:Publisher {name: "Nintendo", country: "Japan", founded_year: 1889});
MERGE (:Publisher {name: "Sony Interactive", country: "Japan", founded_year: 1993});
MERGE (:Publisher {name: "CD Projekt", country: "Poland", founded_year: 1994});
MERGE (:Publisher {name: "Larian Studios", country: "Belgium", founded_year: 1996});
MERGE (:Publisher {name: "Supergiant Games", country: "USA", founded_year: 2009});

// Developers
MERGE (:Developer {name: "FromSoftware", country: "Japan", founded_year: 1986, employee_count: 350});
MERGE (:Developer {name: "Nintendo EPD", country: "Japan", founded_year: 2015, employee_count: 800});
MERGE (:Developer {name: "CD Projekt Red", country: "Poland", founded_year: 1994, employee_count: 1200});
MERGE (:Developer {name: "Larian Studios", country: "Belgium", founded_year: 1996, employee_count: 450});
MERGE (:Developer {name: "Supergiant Games", country: "USA", founded_year: 2009, employee_count: 30});
MERGE (:Developer {name: "Naughty Dog", country: "USA", founded_year: 1984, employee_count: 400});
MERGE (:Developer {name: "Santa Monica Studio", country: "USA", founded_year: 1999, employee_count: 300});
MERGE (:Developer {name: "ZA/UM", country: "Estonia", founded_year: 2016, employee_count: 35});
```

---

### Exercise 1.2 - Create Platform, Genre, and Tag Nodes

```cypher
// Platforms
MERGE (:Platform {name: "PC"});
MERGE (:Platform {name: "PlayStation 5"});
MERGE (:Platform {name: "PlayStation 4"});
MERGE (:Platform {name: "Xbox Series X"});
MERGE (:Platform {name: "Xbox One"});
MERGE (:Platform {name: "Nintendo Switch"});

// Genres
MERGE (:Genre {name: "RPG"});
MERGE (:Genre {name: "Adventure"});
MERGE (:Genre {name: "Action"});
MERGE (:Genre {name: "Roguelike"});
MERGE (:Genre {name: "Platformer"});
MERGE (:Genre {name: "Horror"});
MERGE (:Genre {name: "Simulation"});
MERGE (:Genre {name: "Battle Royale"});
MERGE (:Genre {name: "Shooter"});
MERGE (:Genre {name: "Fighting"});

// Tags
MERGE (:Tag {name: "open-world"});
MERGE (:Tag {name: "souls-like"});
MERGE (:Tag {name: "challenging"});
MERGE (:Tag {name: "fantasy"});
MERGE (:Tag {name: "indie"});
MERGE (:Tag {name: "narrative"});
MERGE (:Tag {name: "roguelike"});
MERGE (:Tag {name: "mythology"});
MERGE (:Tag {name: "multiplayer"});
MERGE (:Tag {name: "free-to-play"});
```

---

### Exercise 1.3 - Create Game Nodes

```cypher
CREATE (:Game {
  title: "Elden Ring",
  release_date: "2022-02-25",
  metacritic_score: 96,
  price: 59.99,
  rating: "M"
});

CREATE (:Game {
  title: "The Legend of Zelda: Breath of the Wild",
  release_date: "2017-03-03",
  metacritic_score: 97,
  price: 59.99,
  rating: "E10+"
});

CREATE (:Game {
  title: "Red Dead Redemption 2",
  release_date: "2018-10-26",
  metacritic_score: 97,
  price: 59.99,
  rating: "M"
});

CREATE (:Game {
  title: "Baldur's Gate 3",
  release_date: "2023-08-03",
  metacritic_score: 96,
  price: 59.99,
  rating: "M"
});

CREATE (:Game {
  title: "God of War Ragnarok",
  release_date: "2022-11-09",
  metacritic_score: 94,
  price: 69.99,
  rating: "M"
});

CREATE (:Game {
  title: "Hades",
  release_date: "2020-09-17",
  metacritic_score: 93,
  price: 24.99,
  rating: "T"
});

CREATE (:Game {
  title: "The Last of Us Part II",
  release_date: "2020-06-19",
  metacritic_score: 93,
  price: 69.99,
  rating: "M"
});

CREATE (:Game {
  title: "The Witcher 3: Wild Hunt",
  release_date: "2015-05-19",
  metacritic_score: 92,
  price: 39.99,
  rating: "M"
});

CREATE (:Game {
  title: "Disco Elysium",
  release_date: "2019-10-15",
  metacritic_score: 97,
  price: 39.99,
  rating: "M"
});

CREATE (:Game {
  title: "Hollow Knight",
  release_date: "2017-02-24",
  metacritic_score: 90,
  price: 14.99,
  rating: "E10+"
});

CREATE (:Game {
  title: "Apex Legends",
  release_date: "2019-02-04",
  metacritic_score: 89,
  price: 0.00,
  rating: "T"
});

CREATE (:Game {
  title: "Cyberpunk 2077",
  release_date: "2020-12-10",
  metacritic_score: 86,
  price: 49.99,
  rating: "M"
});
```

---

### Exercise 1.4 - Create User Nodes

```cypher
CREATE (:User {
  username: "rpg_master",
  country: "UK",
  is_premium: true,
  total_spent: 209.97,
  role: "analyst",
  account_status: "active"
});

CREATE (:User {
  username: "gamer_pro123",
  country: "USA",
  is_premium: true,
  total_spent: 119.98,
  role: "user",
  account_status: "active"
});

CREATE (:User {
  username: "zelda_fan",
  country: "Canada",
  is_premium: true,
  total_spent: 309.96,
  role: "user",
  account_status: "active"
});

CREATE (:User {
  username: "souls_veteran",
  country: "France",
  is_premium: true,
  total_spent: 179.97,
  role: "moderator",
  account_status: "active"
});

CREATE (:User {
  username: "indie_lover",
  country: "Australia",
  is_premium: false,
  total_spent: 109.97,
  role: "user",
  account_status: "active"
});
```

> **Checkpoint**: Run `MATCH (n) RETURN labels(n), count(n) AS count` to see a summary of all node types created so far.

---

## Part 2 - Creating Relationships (15 minutes)

### How Relationship Creation Works

To create a relationship, first `MATCH` both nodes, then `CREATE` or `MERGE` the relationship between them. The relationship has a direction (indicated by `->`) and an optional name used to add properties.

**SQL comparison:**

In a relational schema, the fact that Elden Ring is published by Bandai Namco would be stored as a foreign key (`publisher_id`) in the `games` table, requiring a JOIN to retrieve. In Neo4j, it is a direct connection you can traverse without any join.

---

### Exercise 2.1 - Published and Developed Relationships

```cypher
MATCH (pub:Publisher {name: "Bandai Namco"}), (g:Game {title: "Elden Ring"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "FromSoftware"}), (g:Game {title: "Elden Ring"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "Nintendo"}), (g:Game {title: "The Legend of Zelda: Breath of the Wild"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "Nintendo EPD"}), (g:Game {title: "The Legend of Zelda: Breath of the Wild"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "CD Projekt"}), (g:Game {title: "The Witcher 3: Wild Hunt"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "CD Projekt Red"}), (g:Game {title: "The Witcher 3: Wild Hunt"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "CD Projekt"}), (g:Game {title: "Cyberpunk 2077"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "CD Projekt Red"}), (g:Game {title: "Cyberpunk 2077"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "Larian Studios"}), (g:Game {title: "Baldur's Gate 3"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "Larian Studios"}), (g:Game {title: "Baldur's Gate 3"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "Supergiant Games"}), (g:Game {title: "Hades"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "Supergiant Games"}), (g:Game {title: "Hades"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "Sony Interactive"}), (g:Game {title: "The Last of Us Part II"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "Naughty Dog"}), (g:Game {title: "The Last of Us Part II"})
CREATE (dev)-[:DEVELOPED]->(g);

MATCH (pub:Publisher {name: "Sony Interactive"}), (g:Game {title: "God of War Ragnarok"})
CREATE (pub)-[:PUBLISHED]->(g);

MATCH (dev:Developer {name: "Santa Monica Studio"}), (g:Game {title: "God of War Ragnarok"})
CREATE (dev)-[:DEVELOPED]->(g);
```

Now write the `PUBLISHED` and `DEVELOPED` relationships for **Disco Elysium** (publisher and developer: ZA/UM):

```cypher
// Write your CREATE statements here
```

---

### Exercise 2.2 - Platform Relationships

```cypher
MATCH (g:Game {title: "Elden Ring"}), (p:Platform {name: "PC"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Elden Ring"}), (p:Platform {name: "PlayStation 5"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Elden Ring"}), (p:Platform {name: "Xbox Series X"})
CREATE (g)-[:AVAILABLE_ON]->(p);

MATCH (g:Game {title: "The Legend of Zelda: Breath of the Wild"}), (p:Platform {name: "Nintendo Switch"})
CREATE (g)-[:AVAILABLE_ON]->(p);

MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (p:Platform {name: "PC"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (p:Platform {name: "PlayStation 4"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (p:Platform {name: "Xbox One"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (p:Platform {name: "Nintendo Switch"})
CREATE (g)-[:AVAILABLE_ON]->(p);

MATCH (g:Game {title: "Hades"}), (p:Platform {name: "PC"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Hades"}), (p:Platform {name: "PlayStation 5"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Hades"}), (p:Platform {name: "Xbox Series X"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Hades"}), (p:Platform {name: "Nintendo Switch"})
CREATE (g)-[:AVAILABLE_ON]->(p);

MATCH (g:Game {title: "Hollow Knight"}), (p:Platform {name: "PC"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Hollow Knight"}), (p:Platform {name: "Nintendo Switch"})
CREATE (g)-[:AVAILABLE_ON]->(p);
MATCH (g:Game {title: "Hollow Knight"}), (p:Platform {name: "PlayStation 4"})
CREATE (g)-[:AVAILABLE_ON]->(p);
```

Now write the `AVAILABLE_ON` relationships for **Baldur's Gate 3** (PC and PlayStation 5) and **Cyberpunk 2077** (PC, PlayStation 5, Xbox Series X):

```cypher
// Write your CREATE statements here
```

---

### Exercise 2.3 - Genre and Tag Relationships

```cypher
MATCH (g:Game {title: "Elden Ring"}), (genre:Genre {name: "RPG"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "Hades"}), (genre:Genre {name: "Roguelike"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "The Legend of Zelda: Breath of the Wild"}), (genre:Genre {name: "Adventure"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "Hollow Knight"}), (genre:Genre {name: "Platformer"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (genre:Genre {name: "RPG"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "Cyberpunk 2077"}), (genre:Genre {name: "RPG"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "Baldur's Gate 3"}), (genre:Genre {name: "RPG"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "Disco Elysium"}), (genre:Genre {name: "RPG"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "God of War Ragnarok"}), (genre:Genre {name: "Action"})
CREATE (g)-[:HAS_GENRE]->(genre);

MATCH (g:Game {title: "The Last of Us Part II"}), (genre:Genre {name: "Adventure"})
CREATE (g)-[:HAS_GENRE]->(genre);
```

```cypher
MATCH (g:Game {title: "Elden Ring"}), (t:Tag {name: "open-world"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Elden Ring"}), (t:Tag {name: "souls-like"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Elden Ring"}), (t:Tag {name: "challenging"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Elden Ring"}), (t:Tag {name: "fantasy"})
CREATE (g)-[:TAGGED]->(t);

MATCH (g:Game {title: "Hades"}), (t:Tag {name: "roguelike"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Hades"}), (t:Tag {name: "mythology"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Hades"}), (t:Tag {name: "indie"})
CREATE (g)-[:TAGGED]->(t);

MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (t:Tag {name: "open-world"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (t:Tag {name: "narrative"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "The Witcher 3: Wild Hunt"}), (t:Tag {name: "fantasy"})
CREATE (g)-[:TAGGED]->(t);

MATCH (g:Game {title: "Hollow Knight"}), (t:Tag {name: "indie"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Hollow Knight"}), (t:Tag {name: "challenging"})
CREATE (g)-[:TAGGED]->(t);

MATCH (g:Game {title: "Apex Legends"}), (t:Tag {name: "multiplayer"})
CREATE (g)-[:TAGGED]->(t);
MATCH (g:Game {title: "Apex Legends"}), (t:Tag {name: "free-to-play"})
CREATE (g)-[:TAGGED]->(t);
```

---

### Exercise 2.4 - User OWNS and REVIEWED Relationships

```cypher
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "Cyberpunk 2077"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 60.0}]->(g);
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "Elden Ring"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 150.0}]->(g);
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "The Witcher 3: Wild Hunt"})
CREATE (u)-[:OWNS {purchase_price: 29.99, hours_played: 275.0}]->(g);
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "Baldur's Gate 3"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 210.5}]->(g);

MATCH (u:User {username: "rpg_master"}), (g:Game {title: "The Witcher 3: Wild Hunt"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2021-08-01"}]->(g);
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "Baldur's Gate 3"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2023-09-01"}]->(g);
MATCH (u:User {username: "rpg_master"}), (g:Game {title: "Cyberpunk 2077"})
CREATE (u)-[:REVIEWED {rating: 7, review_date: "2021-02-10"}]->(g);

MATCH (u:User {username: "gamer_pro123"}), (g:Game {title: "The Legend of Zelda: Breath of the Wild"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 120.5}]->(g);
MATCH (u:User {username: "gamer_pro123"}), (g:Game {title: "Elden Ring"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 85.0}]->(g);
MATCH (u:User {username: "gamer_pro123"}), (g:Game {title: "Apex Legends"})
CREATE (u)-[:OWNS {purchase_price: 0.00, hours_played: 320.5}]->(g);

MATCH (u:User {username: "gamer_pro123"}), (g:Game {title: "The Legend of Zelda: Breath of the Wild"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2020-02-15"}]->(g);
MATCH (u:User {username: "gamer_pro123"}), (g:Game {title: "Elden Ring"})
CREATE (u)-[:REVIEWED {rating: 9, review_date: "2022-03-15"}]->(g);

MATCH (u:User {username: "souls_veteran"}), (g:Game {title: "Elden Ring"})
CREATE (u)-[:OWNS {purchase_price: 59.99, hours_played: 320.0}]->(g);
MATCH (u:User {username: "souls_veteran"}), (g:Game {title: "Hollow Knight"})
CREATE (u)-[:OWNS {purchase_price: 14.99, hours_played: 240.5}]->(g);

MATCH (u:User {username: "souls_veteran"}), (g:Game {title: "Elden Ring"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2022-03-20"}]->(g);
MATCH (u:User {username: "souls_veteran"}), (g:Game {title: "Hollow Knight"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2018-09-15"}]->(g);

MATCH (u:User {username: "indie_lover"}), (g:Game {title: "Hollow Knight"})
CREATE (u)-[:OWNS {purchase_price: 14.99, hours_played: 85.0}]->(g);
MATCH (u:User {username: "indie_lover"}), (g:Game {title: "Hades"})
CREATE (u)-[:OWNS {purchase_price: 24.99, hours_played: 145.5}]->(g);

MATCH (u:User {username: "indie_lover"}), (g:Game {title: "Hades"})
CREATE (u)-[:REVIEWED {rating: 10, review_date: "2020-10-15"}]->(g);
MATCH (u:User {username: "indie_lover"}), (g:Game {title: "Hollow Knight"})
CREATE (u)-[:REVIEWED {rating: 9, review_date: "2018-04-01"}]->(g);
```

> **Checkpoint**: Click the **graph icon** in the left sidebar and run `MATCH (n) RETURN n LIMIT 50` to see the visual graph. Try expanding a Game node by double-clicking it.

---

## Part 3 - Basic MATCH Queries (15 minutes)

### How MATCH Works

`MATCH` is the core read clause in Cypher. It describes a **pattern** — a combination of nodes and relationships — and finds all matching instances in the graph. `WHERE` adds property conditions. `RETURN` specifies what to output.

**SQL comparison:**

| SQL | Cypher |
|---|---|
| `SELECT * FROM games` | `MATCH (g:Game) RETURN g` |
| `WHERE metacritic_score >= 90` | `WHERE g.metacritic_score >= 90` |
| `SELECT title, price FROM games` | `RETURN g.title, g.price` |
| `ORDER BY metacritic_score DESC` | `ORDER BY g.metacritic_score DESC` |
| `LIMIT 5` | `LIMIT 5` |

---

### Exercise 3.1 - Find All Nodes of a Type

Find all games:

```cypher
MATCH (g:Game)
RETURN g.title, g.metacritic_score, g.price
ORDER BY g.metacritic_score DESC;
```

Find all publishers:

```cypher
MATCH (p:Publisher)
RETURN p.name, p.country, p.founded_year
ORDER BY p.founded_year;
```

Find all platforms:

```cypher
MATCH (p:Platform)
RETURN p.name;
```

> **SQL equivalent:** `SELECT name FROM platforms;`

---

### Exercise 3.2 - Filter with WHERE

Find all games with a metacritic score of 96 or higher:

```cypher
MATCH (g:Game)
WHERE g.metacritic_score >= 96
RETURN g.title, g.metacritic_score
ORDER BY g.metacritic_score DESC;
```

> **SQL equivalent:** `SELECT title, metacritic_score FROM games WHERE metacritic_score >= 96 ORDER BY metacritic_score DESC;`

Find all games that cost less than 25:

```cypher
MATCH (g:Game)
WHERE g.price < 25
RETURN g.title, g.price
ORDER BY g.price;
```

Find all premium users from Europe (UK or France):

```cypher
MATCH (u:User)
WHERE u.is_premium = true AND u.country IN ["UK", "France"]
RETURN u.username, u.country, u.total_spent;
```

> **SQL equivalent:** `SELECT username, country, total_spent FROM users WHERE is_premium = true AND country IN ('UK', 'France');`

Now write a query to find all games rated "M" with a price between 40 and 70:

```cypher
// Write your MATCH query here
```

---

### Exercise 3.3 - Match Relationships

Find all games published by Bandai Namco:

```cypher
MATCH (pub:Publisher {name: "Bandai Namco"})-[:PUBLISHED]->(g:Game)
RETURN g.title, g.metacritic_score;
```

> **SQL equivalent:** `SELECT g.title, g.metacritic_score FROM games g JOIN publishers p ON g.publisher_id = p.id WHERE p.name = 'Bandai Namco';`  
> In Cypher, no JOIN syntax is needed — the relationship is traversed directly.

Find all platforms where Elden Ring is available:

```cypher
MATCH (g:Game {title: "Elden Ring"})-[:AVAILABLE_ON]->(p:Platform)
RETURN p.name;
```

Find all games owned by rpg_master:

```cypher
MATCH (u:User {username: "rpg_master"})-[:OWNS]->(g:Game)
RETURN g.title, g.metacritic_score
ORDER BY g.metacritic_score DESC;
```

Now write a query to find all games developed by CD Projekt Red:

```cypher
// Write your MATCH query here
```

---

### Exercise 3.4 - Returning Relationship Properties

Find all games rpg_master owns, including how many hours they have played:

```cypher
MATCH (u:User {username: "rpg_master"})-[o:OWNS]->(g:Game)
RETURN g.title, o.hours_played
ORDER BY o.hours_played DESC;
```

Find all reviews written by rpg_master, including the rating:

```cypher
MATCH (u:User {username: "rpg_master"})-[r:REVIEWED]->(g:Game)
RETURN g.title, r.rating, r.review_date
ORDER BY r.rating DESC;
```

> **SQL equivalent:** `SELECT g.title, r.rating, r.review_date FROM reviews r JOIN games g ON r.game_id = g.id WHERE r.user_id = (SELECT id FROM users WHERE username = 'rpg_master') ORDER BY r.rating DESC;`

---

## Part 4 - Multi-Hop Traversal (15 minutes)

### The Real Power of Graph Databases

Graph databases excel at multi-hop queries: "find all games available on a platform where FromSoftware also published a game", or "find users who own games from the same publisher as rpg_master". These queries require multiple JOINs in SQL but are expressed simply as path patterns in Cypher.

---

### Exercise 4.1 - Two-Hop Queries

Find the developer of every game that rpg_master owns:

```cypher
MATCH (u:User {username: "rpg_master"})-[:OWNS]->(g:Game)<-[:DEVELOPED]-(dev:Developer)
RETURN g.title, dev.name;
```

> **SQL equivalent:** Three-table JOIN across `users`, `user_library`, `games`, and `developers`.

Find all users who own a game published by Bandai Namco:

```cypher
MATCH (pub:Publisher {name: "Bandai Namco"})-[:PUBLISHED]->(g:Game)<-[:OWNS]-(u:User)
RETURN DISTINCT u.username, g.title;
```

Find all platforms accessible from rpg_master's library (platforms of games he owns):

```cypher
MATCH (u:User {username: "rpg_master"})-[:OWNS]->(g:Game)-[:AVAILABLE_ON]->(p:Platform)
RETURN DISTINCT p.name
ORDER BY p.name;
```

Now write a query to find all tags assigned to games that indie_lover owns:

```cypher
// Write your MATCH query here
// Hint: (u:User)-[:OWNS]->(g:Game)-[:TAGGED]->(t:Tag)
```

---

### Exercise 4.2 - Shared Patterns (Recommendations)

Find users who own the same games as rpg_master (potential friends):

```cypher
MATCH (u1:User {username: "rpg_master"})-[:OWNS]->(g:Game)<-[:OWNS]-(u2:User)
WHERE u2.username <> "rpg_master"
RETURN DISTINCT u2.username, collect(g.title) AS shared_games
ORDER BY size(collect(g.title)) DESC;
```

> **SQL equivalent:** Self-join on `user_library` — significantly more verbose.

Find games that share the same genre as Elden Ring (excluding Elden Ring itself):

```cypher
MATCH (g1:Game {title: "Elden Ring"})-[:HAS_GENRE]->(genre:Genre)<-[:HAS_GENRE]-(g2:Game)
WHERE g1 <> g2
RETURN g2.title, genre.name
ORDER BY g2.metacritic_score DESC;
```

Find games tagged with both "open-world" and "narrative":

```cypher
MATCH (g:Game)-[:TAGGED]->(:Tag {name: "open-world"})
MATCH (g)-[:TAGGED]->(:Tag {name: "narrative"})
RETURN g.title;
```

Now write a query to find all games that share a developer country with Elden Ring (i.e., games developed in Japan):

```cypher
// Write your MATCH query here
// Hint: match developer of Elden Ring, then find other games with developers from the same country
```

---

### Exercise 4.3 - Optional Match (LEFT JOIN)

Find all games and their publisher — include games without a publisher relationship in the results:

```cypher
MATCH (g:Game)
OPTIONAL MATCH (pub:Publisher)-[:PUBLISHED]->(g)
RETURN g.title, pub.name AS publisher
ORDER BY g.title;
```

> A null value in `publisher` means the relationship does not exist in the graph. This is equivalent to `LEFT JOIN` in SQL.

Find all users and any reviews they have written (include users with no reviews):

```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[r:REVIEWED]->(g:Game)
RETURN u.username, count(r) AS review_count
ORDER BY review_count DESC;
```

---

## Part 5 - Aggregation (15 minutes)

### Aggregation in Cypher

Cypher aggregates implicitly when non-aggregated fields are mixed with aggregation functions. The non-aggregated fields form the grouping key — similar to `GROUP BY` in SQL.

| SQL | Cypher |
|---|---|
| `COUNT(*)` | `count(g)` |
| `AVG(col)` | `avg(g.metacritic_score)` |
| `SUM(col)` | `sum(o.hours_played)` |
| `GROUP BY genre` | implicit grouping by the non-aggregated RETURN columns |
| `ORDER BY count DESC` | `ORDER BY count DESC` |

---

### Exercise 5.1 - Count and Group

Count how many games exist per genre:

```cypher
MATCH (g:Game)-[:HAS_GENRE]->(genre:Genre)
RETURN genre.name AS genre, count(g) AS game_count
ORDER BY game_count DESC;
```

> **SQL equivalent:** `SELECT genre, COUNT(*) FROM games GROUP BY genre ORDER BY COUNT(*) DESC;`

Count how many games each publisher has in the dataset:

```cypher
MATCH (pub:Publisher)-[:PUBLISHED]->(g:Game)
RETURN pub.name AS publisher, count(g) AS game_count
ORDER BY game_count DESC;
```

Count how many platforms each game is available on:

```cypher
MATCH (g:Game)-[:AVAILABLE_ON]->(p:Platform)
RETURN g.title, count(p) AS platform_count
ORDER BY platform_count DESC;
```

---

### Exercise 5.2 - Average, Min, Max

Find the average metacritic score across all games in the dataset:

```cypher
MATCH (g:Game)
RETURN avg(g.metacritic_score) AS avg_score,
       min(g.metacritic_score) AS min_score,
       max(g.metacritic_score) AS max_score;
```

Find the average metacritic score per genre:

```cypher
MATCH (g:Game)-[:HAS_GENRE]->(genre:Genre)
RETURN genre.name, round(avg(g.metacritic_score) * 10) / 10 AS avg_score
ORDER BY avg_score DESC;
```

> **SQL equivalent:** `SELECT genre, ROUND(AVG(metacritic_score), 1) FROM games GROUP BY genre ORDER BY AVG(metacritic_score) DESC;`

Find total hours played per user across their entire library:

```cypher
MATCH (u:User)-[o:OWNS]->(g:Game)
RETURN u.username, sum(o.hours_played) AS total_hours
ORDER BY total_hours DESC;
```

---

### Exercise 5.3 - WITH for Multi-Step Aggregation

`WITH` pipes the results of one query step into the next, enabling filtering on aggregated values. It is similar to a subquery or CTE in SQL.

Find users who have played more than 200 total hours across all their games:

```cypher
MATCH (u:User)-[o:OWNS]->(g:Game)
WITH u, sum(o.hours_played) AS total_hours
WHERE total_hours > 200
RETURN u.username, total_hours
ORDER BY total_hours DESC;
```

> **SQL equivalent:** `SELECT username, SUM(hours_played) AS total FROM user_library GROUP BY username HAVING SUM(hours_played) > 200;`

Find the genre with the highest average metacritic score:

```cypher
MATCH (g:Game)-[:HAS_GENRE]->(genre:Genre)
WITH genre, avg(g.metacritic_score) AS avg_score
ORDER BY avg_score DESC
LIMIT 1
RETURN genre.name, avg_score;
```

Now write a query that finds all games with more than 2 platform connections, returning the title and platform count:

```cypher
// Write your Cypher query here
// Hint: use WITH after the MATCH to compute count, then filter with WHERE
```

---

## Part 6 - Graph-Specific Queries (15 minutes)

These are the query types where graph databases genuinely outperform relational and document stores.

---

### Exercise 6.1 - Degree (Number of Connections)

Find how many users own each game:

```cypher
MATCH (u:User)-[:OWNS]->(g:Game)
RETURN g.title, count(u) AS owner_count
ORDER BY owner_count DESC;
```

Find users with the most games in their library:

```cypher
MATCH (u:User)-[:OWNS]->(g:Game)
RETURN u.username, count(g) AS library_size
ORDER BY library_size DESC;
```

Find games that have been reviewed at least twice:

```cypher
MATCH (u:User)-[:REVIEWED]->(g:Game)
WITH g, count(u) AS review_count
WHERE review_count >= 2
RETURN g.title, review_count
ORDER BY review_count DESC;
```

---

### Exercise 6.2 - Mutual Ownership (Intersection)

Find pairs of users who own at least one game in common:

```cypher
MATCH (u1:User)-[:OWNS]->(g:Game)<-[:OWNS]-(u2:User)
WHERE u1.username < u2.username
RETURN u1.username, u2.username, collect(g.title) AS common_games,
       count(g) AS games_in_common
ORDER BY games_in_common DESC;
```

> **SQL equivalent:** Self-join on `user_library` grouped by both users — requires multiple joins and a subquery.

---

### Exercise 6.3 - Find Users Who Have NOT Reviewed a Game They Own

```cypher
MATCH (u:User)-[:OWNS]->(g:Game)
WHERE NOT (u)-[:REVIEWED]->(g)
RETURN u.username, g.title AS unreviewed_game;
```

> **SQL equivalent:** `LEFT JOIN reviews r ON ... WHERE r.id IS NULL` — readable, but the graph version is more natural to express.

---

### Exercise 6.4 - Collect (Aggregated Lists)

Collect all platform names for each game into a list:

```cypher
MATCH (g:Game)-[:AVAILABLE_ON]->(p:Platform)
RETURN g.title, collect(p.name) AS platforms
ORDER BY g.title;
```

> **SQL equivalent:** `STRING_AGG` or array aggregation — syntax varies by database.

Collect all games owned by each user with their hours played:

```cypher
MATCH (u:User)-[o:OWNS]->(g:Game)
RETURN u.username, collect({title: g.title, hours: o.hours_played}) AS library;
```

---

## Part 7 - Update and Delete (10 minutes)

### Exercise 7.1 - Update Node Properties

Reduce the price of Cyberpunk 2077 to 29.99:

```cypher
MATCH (g:Game {title: "Cyberpunk 2077"})
SET g.price = 29.99
RETURN g.title, g.price;
```

Update the metacritic score of Cyberpunk 2077 to 88:

```cypher
MATCH (g:Game {title: "Cyberpunk 2077"})
SET g.metacritic_score = 88
RETURN g.title, g.metacritic_score;
```

Mark all games costing 0 as free-to-play by adding a `is_free` property:

```cypher
MATCH (g:Game)
WHERE g.price = 0
SET g.is_free = true
RETURN g.title, g.is_free;
```

---

### Exercise 7.2 - Update Relationship Properties

After replaying Elden Ring, souls_veteran updates their hours:

```cypher
MATCH (u:User {username: "souls_veteran"})-[o:OWNS]->(g:Game {title: "Elden Ring"})
SET o.hours_played = 400.0
RETURN u.username, g.title, o.hours_played;
```

Now write a query to add a `review_date` of `"2026-04-07"` to the REVIEWED relationship between indie_lover and Hades:

```cypher
// Write your SET query here
```

---

### Exercise 7.3 - Delete Relationships

Remove the OWNS relationship between gamer_pro123 and Apex Legends (they deleted the game from their library):

```cypher
MATCH (u:User {username: "gamer_pro123"})-[o:OWNS]->(g:Game {title: "Apex Legends"})
DELETE o;
```

Verify the deletion:

```cypher
MATCH (u:User {username: "gamer_pro123"})-[:OWNS]->(g:Game)
RETURN g.title;
```

> Note: Only the relationship is deleted. Both the User node and the Game node remain in the graph.

---

## Bonus Challenges

If you finish early, try these:

**Bonus 1**: Find the "most connected" game — the game that shares the most tags with other games. Hint: traverse `(:Game)-[:TAGGED]->(:Tag)<-[:TAGGED]-(:Game)`, group by the first game, and count distinct connected games.

**Bonus 2**: Recommend games to zelda_fan. Define a recommendation as: a game that a user who owns the same games as zelda_fan also owns, but zelda_fan does not own yet.

**Bonus 3**: Find all games published by publishers from Japan. Then find the average metacritic score for Japanese-published games vs. all other games.

**Bonus 4**: Create a new User node for yourself with your own properties. Add OWNS and REVIEWED relationships for three games from the dataset. Then find which existing users share at least one game with you.

**Bonus 5**: Find all developers that have worked on more than one game in the dataset, and list the games they developed.

---

## Reflection Questions

Answer these after completing the exercise:

1. In the relational GameVerse schema, the relationship between a user and a game they own is stored in a join table (`user_library`). In Neo4j, it is a direct `OWNS` relationship with properties. What are the advantages of storing it as a relationship with properties versus a join table row?

2. In Exercise 4.2, you found games that share the same genre as Elden Ring with a single MATCH pattern. How many SQL JOINs would that query require? What does this suggest about the type of data that benefits most from a graph model?

3. You used `MERGE` to create platforms, genres, and tags, but `CREATE` for games, users, publishers, and developers. Why is the distinction important? What would happen if you used `CREATE` for platforms?

4. `OPTIONAL MATCH` behaves like a LEFT JOIN. In which scenarios is this necessary? Give an example from the GameVerse dataset where a game might not have a publisher relationship.

5. Compare the query in Exercise 6.2 (mutual ownership between users) with its SQL equivalent. What does this example reveal about the fundamental difference in how relational databases and graph databases represent and query connections?

6. The GameVerse graph model separates Genre and Tag into individual nodes, whereas MongoDB stores them as arrays inside the game document. When is the graph approach preferable? When is the embedded array approach preferable?
