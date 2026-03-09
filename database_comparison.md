# Database Systems Comparison

## Overview

This document compares four major categories of database systems:

1. **Relational (SQL)** - structured data in tables with fixed schemas
2. **NoSQL (Document)** - flexible, document-oriented storage
3. **Wide-Column** - columnar storage optimized for large-scale analytical and write-heavy workloads
4. **Graph** - networks of nodes and relationships

Each category was built to solve a different class of problem. Choosing the wrong database for a use case leads to performance bottlenecks, scalability limits, or unnecessary complexity. This guide helps you understand what each model offers and when to use it.

---

## 1. Quick Comparison at a Glance

| Dimension | Relational (SQL) | NoSQL (Document) | Wide-Column | Graph |
|-----------|-----------------|-----------------|-------------|-------|
| **Data model** | Tables, rows, columns | JSON/BSON documents | Column families | Nodes and edges |
| **Schema** | Strict, predefined | Flexible, per-document | Partial schema (column families defined, columns dynamic) | Schema-optional |
| **Query language** | SQL (standard) | Proprietary (MQL, etc.) | CQL (Cassandra), HQL | Cypher, Gremlin, SPARQL |
| **Relationships** | Foreign keys, JOINs | Embedded documents or references | Denormalized / no JOINs | First-class edges |
| **Transactions** | Full ACID | Document-level ACID; limited multi-document | Lightweight transactions (LWT) only | ACID per traversal (varies) |
| **Consistency** | Strong (ACID) | Tunable (eventual to strong) | Tunable (eventual to strong) | Strong or eventual (varies) |
| **Horizontal scale** | Difficult (sharding adds complexity) | Native | Native | Moderate |
| **Typical read pattern** | Complex queries with JOINs | Key or field lookups | Key lookups, column range scans | Relationship traversals |
| **Typical write pattern** | Moderate | High | Very high | Moderate |
| **Maturity** | Decades (1970s) | ~2009 | ~2008 | ~2012 |
| **Popular systems** | PostgreSQL, MySQL, Oracle | MongoDB, CouchDB, Firestore | Apache Cassandra, Google Bigtable, HBase, ScyllaDB | Neo4j, Amazon Neptune, ArangoDB |

---

## 2. Relational Databases (SQL)

### Core Concept

Data is organized into **tables** (relations). Each table has a fixed **schema** that defines column names and types. Rows in different tables are linked through **foreign keys** and combined at query time with **JOIN** operations.

### Key Properties

- **ACID transactions**: Atomicity, Consistency, Isolation, Durability are guaranteed even across multiple tables.
- **Normalization**: Data is stored without redundancy; updates affect one place.
- **Declarative querying**: SQL describes what you want; the engine decides how to fetch it.
- **Strong consistency**: All reads reflect the latest committed write.

### Data Model Example

```sql
-- Normalized schema: player and achievement stored separately
CREATE TABLE players (
    player_id   SERIAL PRIMARY KEY,
    username    VARCHAR(50) UNIQUE NOT NULL,
    email       VARCHAR(150) NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE achievements (
    achievement_id  SERIAL PRIMARY KEY,
    player_id       INTEGER REFERENCES players(player_id),
    name            VARCHAR(100),
    unlocked_at     TIMESTAMPTZ
);

-- Retrieve all achievements for a player using JOIN
SELECT p.username, a.name, a.unlocked_at
FROM players p
JOIN achievements a ON p.player_id = a.player_id
WHERE p.username = 'alice';
```

### Strengths

- Powerful, expressive queries over structured, related data
- ACID guarantees for financial, inventory, and transactional workloads
- Decades of tooling: ORMs, migration frameworks, monitoring
- SQL is a universal skill transferable across systems
- Strong data integrity through constraints and normalization

### Weaknesses

- Schema changes require careful migrations (ALTER TABLE)
- Horizontal scaling (sharding) adds significant complexity
- JOINs become expensive when tables are very large
- Poor fit for hierarchical or highly variable data structures

### Best Use Cases

- Financial systems, banking, accounting
- E-commerce order management
- Healthcare records with regulatory requirements
- Any domain where relationships between entities are complex and integrity matters

---

## 3. NoSQL - Document Databases

### Core Concept

Data is stored as **self-contained documents** (typically JSON or BSON). A document can contain nested objects and arrays - an entire entity and its related data can live in a single document, eliminating the need for JOINs.

### Key Properties

- **Flexible schema**: Each document can have different fields; new fields can be added without migrating existing documents.
- **Document-level ACID**: Reads and writes on a single document are atomic; multi-document transactions exist in modern systems (e.g., MongoDB 4.x+) but add overhead.
- **Horizontal scaling**: Native sharding distributes data across nodes by a shard key.
- **Tunable consistency**: Applications can choose between eventual and strong consistency per operation.

### Data Model Example

```json
// MongoDB document - all player data in one place
{
  "_id": "player_001",
  "username": "alice",
  "email": "alice@example.com",
  "profile": {
    "level": 42,
    "xp": 18500,
    "country": "ES"
  },
  "achievements": [
    { "name": "First Kill",   "unlocked_at": "2025-03-01T10:00:00Z" },
    { "name": "Speed Runner", "unlocked_at": "2025-04-15T14:30:00Z" }
  ],
  "created_at": "2024-01-10T08:00:00Z"
}
```

```javascript
// MongoDB query: find all Spanish players above level 40
db.players.find({
  "profile.country": "ES",
  "profile.level": { $gt: 40 }
})
```

### Strengths

- Schema flexibility supports rapidly evolving data structures
- Single-document reads are very fast (no JOINs)
- Native horizontal scaling
- Natural fit for hierarchical or nested data (user profiles, catalogs, CMS)
- Expressive query language including aggregation pipelines

### Weaknesses

- Data duplication when the same information appears in multiple documents
- Updating a piece of data that is embedded in many documents is expensive
- Multi-document transactions have overhead and are avoided when possible
- Not suitable for highly relational data (many-to-many relationships)
- Less mature tooling than SQL for complex analytics

### Best Use Cases

- Content management systems (articles, product catalogs)
- User profile and session storage
- Event logging with variable attributes
- Mobile and web application backends
- IoT device data with variable sensor schemas

---

## 4. Wide-Column Databases

### Core Concept

Wide-column databases (also called **column-family stores**) organize data into rows identified by a **row key**, grouped into **column families**. Unlike relational databases, columns within a family are dynamic and can differ between rows. Data is stored and retrieved by key, not by joins.

The data model is best understood as a **sorted map of maps**:
`row_key -> column_family -> (column_name -> value, timestamp)`

Apache Cassandra is the most widely deployed open-source wide-column database. Google Bigtable (on which HBase and Cassandra are conceptually based) pioneered this model.

### Key Properties

- **Write-optimized**: Uses an append-only log (SSTable + memtable) for extremely high write throughput.
- **Linear horizontal scale**: Adding nodes increases both capacity and throughput proportionally.
- **Tunable consistency**: Quorum levels (ONE, QUORUM, ALL) can be chosen per query.
- **No JOINs**: Data must be modeled around query patterns (query-first modeling).
- **Time-to-live (TTL)**: Columns can expire automatically.

### Data Model Example

```sql
-- Cassandra Query Language (CQL)
-- Schema designed around the access pattern: "get all sessions for a user"
CREATE TABLE game_sessions_by_user (
    user_id     UUID,
    session_id  TIMEUUID,
    game_id     UUID,
    duration_s  INT,
    score       INT,
    started_at  TIMESTAMP,
    PRIMARY KEY (user_id, session_id)
) WITH CLUSTERING ORDER BY (session_id DESC);

-- Insert
INSERT INTO game_sessions_by_user (user_id, session_id, game_id, duration_s, score, started_at)
VALUES (uuid(), now(), uuid(), 3600, 9500, toTimestamp(now()));

-- Query: latest 10 sessions for a specific user
SELECT * FROM game_sessions_by_user
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000
LIMIT 10;
```

### Strengths

- Handles millions of writes per second across a distributed cluster
- Excellent for time-series, IoT sensor data, and event logging at scale
- Linear scalability with no single point of failure (always-on architecture)
- Built-in TTL for automatic data expiration
- Geo-distributed replication out of the box

### Weaknesses

- No JOINs: all relationships must be pre-denormalized into the schema
- Schema must be designed for specific queries; changing access patterns may require new tables
- Limited transaction support (no multi-partition ACID)
- Aggregations (SUM, GROUP BY) are not native; require separate frameworks (Spark, Flink)
- Learning curve: query-first modeling is counterintuitive for SQL developers

### Wide-Column vs. Columnar (Analytical)

It is important not to confuse wide-column stores with **column-oriented relational databases** (e.g., Amazon Redshift, Google BigQuery, ClickHouse). These are different concepts:

| Type | Examples | Primary Use |
|------|---------|-------------|
| Wide-column store | Cassandra, HBase, Bigtable | High-throughput OLTP, time-series |
| Columnar RDBMS | Redshift, BigQuery, ClickHouse | Analytical queries (OLAP) over large datasets |

### Best Use Cases

- IoT telemetry: millions of sensor readings per second
- Time-series data: metrics, monitoring, financial tick data
- Messaging and chat history at massive scale (WhatsApp-style)
- Recommendation engine feature storage
- Write-heavy workloads requiring global distribution

---

## 5. Graph Databases

### Core Concept

Graph databases store data as a network of **nodes** (entities) and **edges** (relationships) between them. Both nodes and edges can carry properties. The database is optimized for **traversing relationships** efficiently, making queries like "find all friends of friends who play the same game" fast regardless of dataset size.

### Key Properties

- **Relationships are first-class citizens**: Edges are stored as direct pointers, not computed with JOINs.
- **Index-free adjacency**: Traversing to neighbors does not require index lookups; each node physically points to its neighbors.
- **Expressive traversal queries**: Languages like Cypher (Neo4j) allow pattern matching across arbitrary-depth relationships.
- **ACID transactions**: Most mature graph databases (Neo4j, Amazon Neptune with openCypher) support full ACID.
- **Property graph model**: Nodes and edges each have labels and key-value properties.

### Data Model Example

```
Nodes:
  (:Player {id: 1, name: "alice"})
  (:Player {id: 2, name: "bob"})
  (:Game   {id: 10, title: "SpaceRacer"})

Edges:
  (alice)-[:FRIENDS_WITH {since: "2024-01-01"}]->(bob)
  (alice)-[:PLAYS {hours: 120}]->(SpaceRacer)
  (bob)  -[:PLAYS {hours: 45}] ->(SpaceRacer)
```

```cypher
-- Cypher (Neo4j) query: find all games played by alice's friends that alice has not played
MATCH (alice:Player {name: "alice"})-[:FRIENDS_WITH]->(friend:Player)-[:PLAYS]->(game:Game)
WHERE NOT (alice)-[:PLAYS]->(game)
RETURN game.title, COUNT(friend) AS friend_count
ORDER BY friend_count DESC;
```

### Strengths

- Relationship traversal is O(relationship count), not O(table size) as with SQL JOINs
- Naturally models social networks, knowledge graphs, recommendation engines
- Pattern matching queries are concise and readable
- No schema rigidity: new relationship types can be added without migration
- Excellent for fraud detection (many-hop relationship chains)

### Weaknesses

- Poor performance for bulk/aggregate queries over all nodes (table scans)
- Not designed for high-volume write throughput like wide-column stores
- Horizontal scaling is harder than document or wide-column databases
- Smaller ecosystem and community than relational or document databases
- Overkill when relationships are simple (a relational database handles one or two foreign keys efficiently)

### Best Use Cases

- Social networks (friend recommendations, degrees of connection)
- Fraud detection (unusual transaction patterns across accounts)
- Knowledge graphs and semantic web
- Recommendation engines (collaborative filtering)
- Network and IT infrastructure mapping
- Identity and access management (permission hierarchies)

---

## 6. Consistency Models Compared

| Model | Relational | Document | Wide-Column | Graph |
|-------|-----------|---------|-------------|-------|
| **ACID** | Full | Document-level (mongo 4+: multi-doc) | Partial (LWT per partition) | Full (Neo4j) |
| **CAP** | CA (single node) | CP or AP (tunable) | AP (tunable toward CP) | CP |
| **BASE** | No | Yes | Yes | Partially |
| **Isolation levels** | Read uncommitted to Serializable | Snapshot | None (by design) | Serializable |

---

## 7. Scalability Compared

| Aspect | Relational | Document | Wide-Column | Graph |
|--------|-----------|---------|-------------|-------|
| **Vertical scale** | Excellent | Good | Moderate | Good |
| **Horizontal scale** | Difficult (read replicas, sharding) | Native | Native, linear | Moderate |
| **Typical dataset size** | GB to low TB | GB to TB | TB to PB | GB to TB |
| **Write throughput** | Moderate | High | Very high | Moderate |
| **Read throughput** | High (with indexes) | High (key-based) | High (key-based) | High (traversals) |

---

## 8. Data Modeling Comparison

The same domain modeled differently in each system - storing players, games, and achievements for a gaming platform:

### Relational

```sql
-- Normalized tables, joined at query time
players(player_id, username, email)
games(game_id, title, genre)
achievements(achievement_id, player_id, game_id, name, unlocked_at)
```

### Document (MongoDB)

```json
// Achievements embedded inside the player document
{
  "_id": "player_001",
  "username": "alice",
  "achievements": [
    { "game": "SpaceRacer", "name": "Speed Demon", "unlocked_at": "2025-06-01" }
  ]
}
```

### Wide-Column (Cassandra)

```sql
-- One table per access pattern
-- "Get achievements for a player, ordered by unlock date"
CREATE TABLE player_achievements (
    player_id   UUID,
    unlocked_at TIMESTAMP,
    game_id     UUID,
    name        TEXT,
    PRIMARY KEY (player_id, unlocked_at)
) WITH CLUSTERING ORDER BY (unlocked_at DESC);
```

### Graph (Neo4j)

```cypher
// Relationships stored as edges
CREATE (alice:Player {name: "alice"})
CREATE (game:Game {title: "SpaceRacer"})
CREATE (ach:Achievement {name: "Speed Demon", unlocked_at: date("2025-06-01")})
CREATE (alice)-[:EARNED]->(ach)-[:IN]->(game)
```

---

## 9. When to Use Each

| If you need... | Use |
|---------------|-----|
| Complex joins between many related entities | Relational (PostgreSQL) |
| Full ACID across multiple entity types | Relational (PostgreSQL) |
| Flexible, evolving document structure | Document (MongoDB) |
| Hierarchical/nested data in one read | Document (MongoDB) |
| Millions of writes per second | Wide-Column (Cassandra) |
| Time-series data with automatic TTL | Wide-Column (Cassandra) |
| Multi-hop relationship queries | Graph (Neo4j) |
| Fraud detection / social network analysis | Graph (Neo4j) |
| Regulatory compliance and data integrity | Relational |
| Global distribution with always-on availability | Wide-Column |

---

## 10. Polyglot Persistence

Real-world applications often use more than one database type, selecting the best tool for each part of the system. This is called **polyglot persistence**.

Example architecture for a gaming platform:

| Component | Database | Reason |
|-----------|---------|--------|
| Player accounts, billing | PostgreSQL | ACID transactions, strict integrity |
| Game session events | Cassandra | Very high write throughput, time-series |
| Player profiles, game catalog | MongoDB | Flexible schema, fast document reads |
| Friend recommendations | Neo4j | Efficient relationship traversal |

The trade-off of polyglot persistence is operational complexity: each system requires its own expertise, monitoring, and backup procedures.

---

## 11. Summary Table

| | Relational | Document | Wide-Column | Graph |
|--|-----------|---------|-------------|-------|
| **Data structure** | Tables | JSON documents | Rows + column families | Nodes + edges |
| **Query language** | SQL | MQL / aggregation pipeline | CQL | Cypher |
| **Best for** | Structured, relational data | Hierarchical, flexible data | Massive write throughput | Relationship traversal |
| **ACID** | Full | Partial (improving) | Partial | Full (Neo4j) |
| **Scale-out** | Hard | Native | Native, linear | Moderate |
| **Schema flexibility** | Low | High | Medium | High |
| **Learning curve** | Low (SQL is standard) | Medium | High (query-first model) | Medium |
| **Operational maturity** | Very high | High | High | Medium |
| **Representative system** | PostgreSQL | MongoDB | Apache Cassandra | Neo4j |
