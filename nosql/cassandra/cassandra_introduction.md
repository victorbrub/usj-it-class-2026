# Author: Víctor Barceló
# Apache Cassandra - Introduction and Guide

## What is Cassandra?

**Apache Cassandra** is a distributed, wide-column NoSQL database designed for high availability, fault tolerance, and linear scalability. Originally developed at Facebook and open-sourced in 2008, Cassandra is optimized for write-heavy workloads and large-scale data across multiple data centers.

### Key Features

- **Wide-column model**: Data organized in keyspaces, tables, rows, and columns
- **Distributed architecture**: No single point of failure; every node is equal
- **Linear scalability**: Adding nodes increases throughput linearly
- **High write throughput**: Optimized for massive write volumes
- **Multi-datacenter replication**: Built-in support for geographically distributed clusters
- **Tunable consistency**: Choose between availability and consistency per query
- **CQL**: SQL-like query language (Cassandra Query Language)
- **TTL support**: Automatic data expiration at row or column level

---

## Cassandra Architecture

### The Ring Model

Cassandra organizes nodes in a logical ring. Each node is responsible for a range of partition key hashes. Data is automatically distributed across all nodes using **consistent hashing**.

```
            Node A (0 - 25%)
           /                \
  Node D (75-100%)       Node B (25-50%)
           \                /
            Node C (50-75%)
```

There is no master node. Every node can accept reads and writes — this is called a **peer-to-peer** architecture.

### Keyspace

A **keyspace** is the top-level namespace, equivalent to a database in PostgreSQL. It defines the replication strategy and replication factor.

```
Keyspace: gameverse
  ├─ Table: games_by_genre
  ├─ Table: games_by_platform
  ├─ Table: user_profiles
  └─ Table: reviews_by_game
```

### Table Structure

A Cassandra table has:

| Component | Description |
|---|---|
| **Partition key** | Determines which node stores the data. All rows with the same partition key are stored together. |
| **Clustering columns** | Sort data within a partition. Optional. |
| **Regular columns** | The actual data payload. |

```
PRIMARY KEY (partition_key, clustering_column_1, clustering_column_2)
```

### Partitions

A **partition** is the fundamental unit of storage and access. All rows within a partition are stored on the same node(s) and are always retrieved together.

- Choosing the right partition key is the single most important design decision.
- A partition that is too large (millions of rows) causes hotspots and degrades performance.
- A partition that is too small provides no benefit and increases overhead.

### Replication

Data is replicated across multiple nodes according to the **replication factor** defined in the keyspace. With `replication_factor = 3`, every partition is stored on three different nodes, providing fault tolerance.

---

## CQL Data Types

Cassandra Query Language (CQL) supports the following common data types:

### Numeric Types

| Type | Description | Example |
|---|---|---|
| `int` | 32-bit signed integer | `42` |
| `bigint` | 64-bit signed integer | `9223372036854775807` |
| `smallint` | 16-bit signed integer | `32767` |
| `tinyint` | 8-bit signed integer | `127` |
| `float` | 32-bit IEEE 754 floating point | `3.14` |
| `double` | 64-bit IEEE 754 floating point | `3.14159265` |
| `decimal` | Variable-precision decimal | `99.99` |
| `varint` | Arbitrary-precision integer | `123456789012345678901234567890` |
| `counter` | Distributed counter (append-only) | `0` |

### Text Types

| Type | Description |
|---|---|
| `text` | UTF-8 encoded string (alias: `varchar`) |
| `ascii` | ASCII string |

### Date and Time Types

| Type | Description |
|---|---|
| `timestamp` | Date and time with millisecond precision |
| `date` | Date only (no time) |
| `time` | Time only (no date), in nanoseconds |
| `duration` | A duration (months, days, nanoseconds) |

### Other Types

| Type | Description |
|---|---|
| `uuid` | A universally unique identifier (any UUID version) |
| `timeuuid` | A version-1 UUID, sortable by time |
| `boolean` | `true` or `false` |
| `blob` | Raw bytes |
| `inet` | IPv4 or IPv6 address |

### Collection Types

| Type | Description | Example |
|---|---|---|
| `list<T>` | Ordered list of values | `['action', 'rpg']` |
| `set<T>` | Unordered set of unique values | `{'PC', 'PS5'}` |
| `map<K,V>` | Key-value pairs | `{'score': '95', 'rank': '1'}` |
| `frozen<T>` | Immutable nested collection or UDT | `frozen<list<text>>` |

### User-Defined Types (UDT)

You can define custom types for complex nested structures:

```sql
CREATE TYPE gameverse.address (
    street text,
    city   text,
    country text
);

CREATE TABLE users (
    username text PRIMARY KEY,
    address  frozen<address>
);
```

---

## Keyspace Management

### Create a Keyspace

```sql
-- SimpleStrategy: for single-datacenter clusters
CREATE KEYSPACE gameverse
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

-- NetworkTopologyStrategy: for multi-datacenter clusters
CREATE KEYSPACE gameverse
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3,
    'datacenter2': 2
};
```

### Use a Keyspace

```sql
USE gameverse;
```

### Alter a Keyspace

```sql
ALTER KEYSPACE gameverse
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 2
};
```

### Drop a Keyspace

```sql
DROP KEYSPACE gameverse;
```

---

## Table Management

### Create a Table

```sql
-- Simple primary key (partition key only)
CREATE TABLE user_profiles (
    username  text PRIMARY KEY,
    email     text,
    full_name text,
    joined_at timestamp
);

-- Composite primary key (partition key + clustering column)
CREATE TABLE reviews_by_game (
    game_title  text,
    reviewed_at timestamp,
    username    text,
    rating      int,
    body        text,
    PRIMARY KEY (game_title, reviewed_at, username)
) WITH CLUSTERING ORDER BY (reviewed_at DESC, username ASC);

-- Compound partition key (multiple columns as partition key)
CREATE TABLE events_by_user_date (
    username   text,
    event_date date,
    event_time timeuuid,
    event_type text,
    payload    text,
    PRIMARY KEY ((username, event_date), event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);
```

### Describe a Table

```sql
DESCRIBE TABLE reviews_by_game;
```

### Alter a Table

```sql
-- Add a column
ALTER TABLE user_profiles ADD avatar_url text;

-- Drop a column
ALTER TABLE user_profiles DROP avatar_url;
```

### Drop a Table

```sql
DROP TABLE reviews_by_game;
```

---

## CRUD Operations

### Create (INSERT)

**Insert a row**:

```sql
INSERT INTO user_profiles (username, email, full_name, joined_at)
VALUES ('alice', 'alice@example.com', 'Alice Johnson', toTimestamp(now()));
```

**Insert with TTL** (row expires after 3600 seconds):

```sql
INSERT INTO session_tokens (token, username, created_at)
VALUES ('abc123', 'alice', toTimestamp(now()))
USING TTL 3600;
```

**Insert if not exists** (lightweight transaction):

```sql
INSERT INTO user_profiles (username, email, full_name, joined_at)
VALUES ('alice', 'alice@example.com', 'Alice Johnson', toTimestamp(now()))
IF NOT EXISTS;
```

### Read (SELECT)

**Select all rows in a partition**:

```sql
SELECT * FROM reviews_by_game WHERE game_title = 'The Witcher 3';
```

**Select with clustering column range**:

```sql
SELECT * FROM reviews_by_game
WHERE game_title = 'The Witcher 3'
  AND reviewed_at > '2024-01-01 00:00:00+0000';
```

**Select specific columns**:

```sql
SELECT username, rating, body FROM reviews_by_game
WHERE game_title = 'The Witcher 3';
```

**Limit results**:

```sql
SELECT * FROM reviews_by_game
WHERE game_title = 'The Witcher 3'
LIMIT 10;
```

**Select with token function** (for full-table scans, avoid in production):

```sql
SELECT * FROM user_profiles LIMIT 100;
```

### Update (UPDATE)

**Update a regular column**:

```sql
UPDATE user_profiles
SET email = 'alice_new@example.com'
WHERE username = 'alice';
```

**Update with TTL**:

```sql
UPDATE user_profiles
USING TTL 86400
SET email = 'alice_new@example.com'
WHERE username = 'alice';
```

**Update a map column**:

```sql
UPDATE game_stats
SET scores['level_1'] = '980'
WHERE username = 'alice' AND game_title = 'The Witcher 3';
```

**Update a list column** (append):

```sql
UPDATE user_profiles
SET tags = tags + ['veteran']
WHERE username = 'alice';
```

**Conditional update** (lightweight transaction):

```sql
UPDATE user_profiles
SET email = 'alice_new@example.com'
WHERE username = 'alice'
IF email = 'alice@example.com';
```

### Delete (DELETE)

**Delete a row**:

```sql
DELETE FROM user_profiles WHERE username = 'alice';
```

**Delete a specific column value**:

```sql
DELETE email FROM user_profiles WHERE username = 'alice';
```

**Delete a range of clustering rows**:

```sql
DELETE FROM reviews_by_game
WHERE game_title = 'The Witcher 3'
  AND reviewed_at < '2023-01-01 00:00:00+0000';
```

**Delete a single element from a collection**:

```sql
UPDATE user_profiles
SET tags = tags - {'veteran'}
WHERE username = 'alice';
```

---

## Data Modeling

### Query-Driven Design

Cassandra requires a fundamentally different approach to data modeling compared to relational databases.

**Relational approach**: Design tables for entities, JOIN at query time.  
**Cassandra approach**: Design tables for queries. One query = one table.

Rules to follow:

1. Every `SELECT` must include the full partition key in the `WHERE` clause.
2. Clustering columns can be filtered with `=` or range operators (`>`, `<`, `>=`, `<=`), but only in order.
3. There are no JOINs. Denormalize data across tables instead.
4. A table can store the same data as another table but arranged differently for a different query.

### Example: Games Table Per Access Pattern

Suppose the application needs two queries:
- Q1: Find a game by title
- Q2: List all games in a genre

These require two separate tables:

```sql
-- Table for Q1: look up game by title
CREATE TABLE games_by_title (
    title       text PRIMARY KEY,
    genre       text,
    platform    set<text>,
    release_year int,
    developer   text
);

-- Table for Q2: list games by genre
CREATE TABLE games_by_genre (
    genre        text,
    title        text,
    platform     set<text>,
    release_year int,
    developer    text,
    PRIMARY KEY (genre, title)
);
```

Both tables contain the same data. That is intentional.

### Choosing a Good Partition Key

A good partition key:

- Distributes data evenly across nodes (high cardinality)
- Groups data that is always queried together
- Does not result in partitions that grow without bound

| Partition Key | Assessment |
|---|---|
| `user_id` | Good if there are many users with balanced activity |
| `country` | Poor — few values, creates hotspots on a few nodes |
| `date` | Poor — all writes on a given day go to one partition |
| `(user_id, date)` | Better — spreads writes while keeping daily data together |

### Avoiding Common Mistakes

| Mistake | Consequence | Solution |
|---|---|---|
| Using `ALLOW FILTERING` | Full partition scan, poor performance | Redesign the table for the query |
| Unbounded partition growth | Partition too large, read performance degrades | Add a bucket (e.g., week number) to the partition key |
| Too many lightweight transactions (IF) | Cassandra uses Paxos; LWTs are expensive | Use only when strictly necessary |
| Selecting without partition key | Full cluster scan | Always include the partition key in WHERE |
| Storing large blobs in Cassandra | Increases compaction load | Store blobs externally (e.g., S3/Azure Blob), store references in Cassandra |

---

## Indexes

### Secondary Indexes (SASI / SAI)

Cassandra supports secondary indexes to query on non-primary-key columns, but they have limitations and should be used carefully.

**Storage-Attached Index (SAI)** — the modern recommended index type:

```sql
-- Create an SAI on a regular column
CREATE INDEX ON user_profiles (email)
  USING 'sai';

-- Now you can query by email directly
SELECT * FROM user_profiles WHERE email = 'alice@example.com';
```

**Limitations of secondary indexes**:
- Not suitable for high-cardinality columns with many unique values queried infrequently
- Not suitable for columns with very low cardinality (e.g., `boolean`)
- Better to denormalize into a separate table for high-traffic query patterns

### Materialized Views

Materialized views automatically maintain a copy of a base table organized around a different primary key. They are managed by Cassandra internally.

```sql
CREATE MATERIALIZED VIEW games_by_developer AS
    SELECT * FROM games_by_title
    WHERE developer IS NOT NULL AND title IS NOT NULL
    PRIMARY KEY (developer, title);
```

> Note: Materialized views add write overhead and have known edge-case limitations. Prefer manual denormalization for critical paths.

---

## TTL (Time to Live)

TTL allows data to expire automatically without application-level cleanup.

**Set TTL on insert**:

```sql
INSERT INTO session_tokens (token, username)
VALUES ('xyz789', 'alice')
USING TTL 86400;  -- expires in 24 hours
```

**Set TTL on update**:

```sql
UPDATE session_tokens
USING TTL 3600
SET username = 'alice'
WHERE token = 'xyz789';
```

**Check the TTL of a column**:

```sql
SELECT TTL(username) FROM session_tokens WHERE token = 'xyz789';
```

**Remove TTL** (set to 0):

```sql
UPDATE session_tokens
USING TTL 0
SET username = 'alice'
WHERE token = 'xyz789';
```

---

## Consistency Levels

Cassandra allows you to choose how many replicas must acknowledge a read or write before the operation is considered successful. This gives you a tunable trade-off between consistency and availability.

### Common Consistency Levels

| Level | Description |
|---|---|
| `ONE` | One replica must respond. Fastest, least consistent. |
| `TWO` | Two replicas must respond. |
| `THREE` | Three replicas must respond. |
| `QUORUM` | Majority of replicas must respond: `floor(replication_factor / 2) + 1`. |
| `ALL` | Every replica must respond. Strongest consistency, least available. |
| `LOCAL_QUORUM` | Quorum within the local datacenter only. |
| `EACH_QUORUM` | Quorum in each datacenter. |
| `ANY` | At least one node must acknowledge (even a hinted handoff). Weakest. |

### Strong Consistency Rule

To guarantee strong consistency (reading your own writes), ensure:

$$CL_{write} + CL_{read} > RF$$

For example, with `replication_factor = 3`:
- `QUORUM` writes + `QUORUM` reads = 2 + 2 = 4 > 3. Strong consistency guaranteed.
- `ONE` writes + `ONE` reads = 1 + 1 = 2 ≤ 3. No strong consistency guarantee.

### Setting Consistency in cqlsh

```sql
CONSISTENCY QUORUM;

SELECT * FROM user_profiles WHERE username = 'alice';
```

---

## Counters

Cassandra has a special `counter` type for distributed, increment-only counters. A table that uses counters must have only counter columns (plus the primary key).

```sql
CREATE TABLE page_views (
    page_id   text PRIMARY KEY,
    view_count counter
);

-- Increment
UPDATE page_views SET view_count = view_count + 1 WHERE page_id = 'homepage';

-- Decrement
UPDATE page_views SET view_count = view_count - 1 WHERE page_id = 'homepage';

-- Read
SELECT view_count FROM page_views WHERE page_id = 'homepage';
```

Counter limitations:
- Counter columns cannot be reset to a specific value.
- A table cannot mix counter and non-counter columns (except the primary key).
- Counters are not idempotent — retrying a failed write may double-count.

---

## Batch Statements

CQL supports `BATCH` for grouping multiple write statements. Batches in Cassandra are NOT equivalent to transactions — they do not provide atomicity across partitions.

**Unlogged batch** (no guarantees, maximum performance):

```sql
BEGIN UNLOGGED BATCH
    INSERT INTO games_by_title (title, genre) VALUES ('Cyberpunk 2077', 'RPG');
    INSERT INTO games_by_genre (genre, title) VALUES ('RPG', 'Cyberpunk 2077');
APPLY BATCH;
```

**Logged batch** (atomic within a single partition, with Cassandra's batch log):

```sql
BEGIN BATCH
    UPDATE user_profiles SET email = 'new@example.com' WHERE username = 'alice';
    INSERT INTO audit_log (username, action, ts) VALUES ('alice', 'email_change', toTimestamp(now()));
APPLY BATCH;
```

When to use batches:
- Use logged batches to keep two denormalized tables in sync when they share the same partition key.
- Avoid large batches across many partitions — they increase coordinator load and can cause timeouts.

---

## Installation

### Docker (Recommended for Development)

```bash
# Pull the official Cassandra image
docker pull cassandra:5.0

# Start a single-node cluster
docker run --name cassandra-dev \
    -p 9042:9042 \
    -d cassandra:5.0

# Connect with cqlsh
docker exec -it cassandra-dev cqlsh
```

### Multi-Node Cluster with Docker Compose

```yaml
version: '3.8'
services:
  cassandra-1:
    image: cassandra:5.0
    container_name: cassandra-1
    ports:
      - "9042:9042"
    environment:
      - CASSANDRA_CLUSTER_NAME=dev-cluster
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack1
    volumes:
      - cassandra1-data:/var/lib/cassandra

  cassandra-2:
    image: cassandra:5.0
    container_name: cassandra-2
    environment:
      - CASSANDRA_CLUSTER_NAME=dev-cluster
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack1
      - CASSANDRA_SEEDS=cassandra-1
    depends_on:
      - cassandra-1
    volumes:
      - cassandra2-data:/var/lib/cassandra

volumes:
  cassandra1-data:
  cassandra2-data:
```

```bash
docker compose up -d
# Wait ~30 seconds for the cluster to form, then:
docker exec -it cassandra-1 nodetool status
docker exec -it cassandra-1 cqlsh
```

### Linux (Debian/Ubuntu)

```bash
# Install Java (required)
sudo apt-get update
sudo apt-get install -y default-jdk

# Add the Apache Cassandra repository
echo "deb https://debian.cassandra.apache.org 50x main" | \
    sudo tee /etc/apt/sources.list.d/cassandra.sources.list
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -

# Install Cassandra
sudo apt-get update
sudo apt-get install -y cassandra

# Start the service
sudo systemctl enable cassandra
sudo systemctl start cassandra

# Check status
nodetool status
```

---

## Connecting from Python

### Installation

```bash
pip install cassandra-driver
```

### Basic Connection

```python
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider

# Local development (no authentication)
cluster = Cluster(['127.0.0.1'])
session = cluster.connect('gameverse')

# With authentication (production)
auth_provider = PlainTextAuthProvider(username='cassandra', password='cassandra')
cluster = Cluster(['127.0.0.1'], auth_provider=auth_provider)
session = cluster.connect('gameverse')
```

### Executing Queries

```python
# Simple query
rows = session.execute("SELECT * FROM user_profiles WHERE username = %s", ('alice',))
for row in rows:
    print(row.username, row.email)

# Prepared statement (recommended for repeated queries)
prepared = session.prepare(
    "INSERT INTO user_profiles (username, email, full_name) VALUES (?, ?, ?)"
)
session.execute(prepared, ('bob', 'bob@example.com', 'Bob Smith'))
```

### Using an Object Mapper (cqlengine)

```python
from cassandra.cqlengine import columns
from cassandra.cqlengine.models import Model
from cassandra.cqlengine.management import sync_table

class UserProfile(Model):
    __keyspace__ = 'gameverse'
    username  = columns.Text(primary_key=True)
    email     = columns.Text()
    full_name = columns.Text()

sync_table(UserProfile)

# Insert
UserProfile.create(username='alice', email='alice@example.com', full_name='Alice Johnson')

# Query
user = UserProfile.get(username='alice')
print(user.full_name)
```

### Always Close the Connection

```python
session.shutdown()
cluster.shutdown()
```

---

## Connecting from Java

### Maven Dependency

```xml
<dependency>
    <groupId>com.datastax.oss</groupId>
    <artifactId>java-driver-core</artifactId>
    <version>4.17.0</version>
</dependency>
```

### Basic Connection

```java
import com.datastax.oss.driver.api.core.CqlSession;
import com.datastax.oss.driver.api.core.cql.ResultSet;
import com.datastax.oss.driver.api.core.cql.Row;
import com.datastax.oss.driver.api.core.cql.SimpleStatement;
import java.net.InetSocketAddress;

public class CassandraExample {

    public static void main(String[] args) {
        try (CqlSession session = CqlSession.builder()
                .addContactPoint(new InetSocketAddress("127.0.0.1", 9042))
                .withLocalDatacenter("datacenter1")
                .withKeyspace("gameverse")
                .build()) {

            // Simple query
            ResultSet rs = session.execute(
                SimpleStatement.newInstance(
                    "SELECT * FROM user_profiles WHERE username = ?", "alice"
                )
            );

            for (Row row : rs) {
                System.out.println(row.getString("username") + " - " + row.getString("email"));
            }

            // Prepared statement
            var prepared = session.prepare(
                "INSERT INTO user_profiles (username, email, full_name) VALUES (?, ?, ?)"
            );
            session.execute(prepared.bind("bob", "bob@example.com", "Bob Smith"));
        }
    }
}
```

---

## Useful cqlsh Commands

| Command | Description |
|---|---|
| `DESCRIBE KEYSPACES;` | List all keyspaces |
| `DESCRIBE KEYSPACE gameverse;` | Show keyspace definition |
| `DESCRIBE TABLES;` | List tables in the current keyspace |
| `DESCRIBE TABLE user_profiles;` | Show full table definition |
| `COPY table TO 'file.csv';` | Export table to CSV |
| `COPY table FROM 'file.csv';` | Import CSV into table |
| `TRACING ON;` | Enable query tracing |
| `TRACING OFF;` | Disable query tracing |
| `CONSISTENCY QUORUM;` | Set consistency level |
| `SHOW VERSION;` | Show Cassandra and CQL versions |
| `EXIT;` | Quit cqlsh |

### nodetool Commands (Cluster Management)

```bash
# Check cluster status and token ring
nodetool status

# Show ring token assignments
nodetool ring

# Flush memtables to disk
nodetool flush

# Compact SSTables
nodetool compact

# Show table stats
nodetool tablestats gameverse.user_profiles
```

---

## When to Use Cassandra

Cassandra is a strong fit when:

- Write throughput is the primary concern (millions of writes per second)
- Data is time-series or event-based (logs, sensor readings, activity feeds)
- The access patterns are well-known and fixed at design time
- High availability with no downtime is required (multi-datacenter replication)
- The dataset is very large (terabytes to petabytes)

Cassandra is a poor fit when:

- Ad-hoc queries and complex JOINs are required
- Data relationships are complex and dynamic
- Strong transactional guarantees across multiple entities are needed
- The team cannot invest in query-driven data modeling upfront
- The dataset is small and relational — use PostgreSQL instead

---

## Comparison: Cassandra vs PostgreSQL

| Feature | Apache Cassandra | PostgreSQL |
|---|---|---|
| Data model | Wide-column | Relational |
| Query language | CQL (SQL-like) | SQL |
| JOINs | Not supported | Fully supported |
| Transactions | Lightweight (single partition) | Full ACID |
| Scalability | Horizontal (add nodes) | Vertical (larger server) |
| Consistency | Tunable | Strong by default |
| Best for | High write throughput, time-series | Complex queries, relational data |
| Schema changes | Additive only (without downtime) | Full ALTER TABLE |
| Secondary indexes | Limited (SAI) | Rich (B-tree, GIN, GiST, BRIN) |

---

## Further Reading

- [Apache Cassandra Documentation](https://cassandra.apache.org/doc/latest/)
- [DataStax Academy (free courses)](https://www.datastax.com/dev)
- [CQL Reference](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/)
- [Cassandra Data Modeling Guide](https://cassandra.apache.org/doc/latest/cassandra/data_modeling/)
