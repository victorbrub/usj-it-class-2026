# Introduction to NoSQL Databases

## What is NoSQL?

**NoSQL** stands for "Not Only SQL" and refers to a category of database management systems that differ from traditional relational databases. NoSQL databases are designed to handle large volumes of data, high traffic, and flexible data models that don't fit well into traditional table structures.

### Key Characteristics

- **Non-relational**: Data is not stored in tables with predefined relationships
- **Schema-flexible**: Structure can vary between records
- **Horizontally scalable**: Can distribute data across multiple servers
- **High performance**: Optimized for specific data access patterns
- **Eventually consistent**: May prioritize availability over immediate consistency

---

## Why NoSQL?

### Limitations of Relational Databases

Traditional relational databases face challenges with:

1. **Scale**: Difficult to scale horizontally across multiple servers
2. **Flexibility**: Schema changes require careful migration
3. **Performance**: JOINs become expensive with large datasets
4. **Variety**: Struggle with unstructured or semi-structured data
5. **Velocity**: May not handle extremely high write throughput

### The Rise of NoSQL

NoSQL databases emerged to address:

- **Big Data**: Handling massive volumes (terabytes to petabytes)
- **Real-time web applications**: Social networks, gaming, IoT
- **Flexible data models**: Rapidly changing requirements
- **Global distribution**: Data centers across continents
- **High availability**: Must never go down

---

## Types of NoSQL Databases

### 1. Document Databases

Store data as documents (JSON, BSON, XML).

**Examples**: MongoDB, CouchDB, Amazon DocumentDB

**Structure**:
```json
{
  "_id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "addresses": [
    {
      "type": "home",
      "street": "123 Main St",
      "city": "Boston"
    },
    {
      "type": "work",
      "street": "456 Office Blvd",
      "city": "Cambridge"
    }
  ],
  "orders": [
    {"orderId": "A123", "total": 99.99},
    {"orderId": "A124", "total": 149.99}
  ]
}
```

**Use Cases**:
- Content management systems
- E-commerce product catalogs
- User profiles
- Real-time analytics
- Mobile applications

**Advantages**:
- Flexible schema
- Intuitive for developers (similar to objects)
- Can embed related data
- Easy to scale horizontally

**Disadvantages**:
- Data duplication
- Complex queries across documents can be difficult
- No ACID transactions across documents (in some systems)

---

### 2. Key-Value Databases

Simplest NoSQL type - stores data as key-value pairs.

**Examples**: Redis, Amazon DynamoDB, Riak, Memcached

**Structure**:
```
Key                 Value
------------------------------------
"user:1000"      →  {"name": "Alice", "age": 30}
"session:abc123" →  {"userId": 1000, "expires": "2026-03-02"}
"cart:1000"      →  ["item1", "item2", "item3"]
"counter:views"  →  45231
```

**Use Cases**:
- Session storage
- Caching
- Shopping carts
- User preferences
- Real-time recommendations
- Leaderboards/counters

**Advantages**:
- Extremely fast (often in-memory)
- Simple data model
- Highly scalable
- Low latency

**Disadvantages**:
- No query language (lookup by key only)
- No relationships between data
- Limited querying capabilities
- Values are opaque (can't query inside them easily)

---

### 3. Column-Family Databases (Wide-Column Stores)

Store data in columns rather than rows, grouped into column families.

**Examples**: Apache Cassandra, HBase, ScyllaDB, Google Bigtable

**Structure**:
```
Row Key: user:1000
Column Family: profile
  ├─ name: "Alice Johnson"
  ├─ email: "alice@example.com"
  └─ created: "2024-01-15"

Column Family: activity
  ├─ 2026-03-01:10:15 → "login"
  ├─ 2026-03-01:10:20 → "view_product:123"
  └─ 2026-03-01:10:25 → "add_to_cart:123"
```

**Use Cases**:
- Time-series data
- IoT sensor data
- Event logging
- Recommendation engines
- Messaging platforms
- Financial transactions

**Advantages**:
- Excellent for time-series data
- Highly scalable and distributed
- Fast writes
- Efficient column-based queries

**Disadvantages**:
- Complex data modeling
- Limited query flexibility
- Eventual consistency
- Steep learning curve

---

### 4. Graph Databases

Store data as nodes and relationships (edges).

**Examples**: Neo4j, Amazon Neptune, ArangoDB, OrientDB

**Structure**:
```
(Person: Alice) -[FRIENDS_WITH]-> (Person: Bob)
(Person: Alice) -[WORKS_AT]-> (Company: Acme Corp)
(Person: Bob) -[LIKES]-> (Product: Laptop)
(Product: Laptop) -[MANUFACTURED_BY]-> (Company: TechCo)
```

**Visual Representation**:
```
    Alice
   /  |  \
FRIENDS WORKS_AT PURCHASED
 /     |         \
Bob    Acme      Phone
 |               |
LIKES       MANUFACTURED_BY
 |               |
Laptop -------- TechCo
```

**Use Cases**:
- Social networks
- Recommendation engines
- Fraud detection
- Network topology
- Knowledge graphs
- Access control systems

**Advantages**:
- Natural representation of connected data
- Fast relationship traversals
- Flexible schema
- Powerful query language (e.g., Cypher)

**Disadvantages**:
- Can be slower for non-graph queries
- Challenging to scale horizontally
- Learning curve for graph query languages
- Not suitable for all data models

---

## CAP Theorem

The CAP theorem states that distributed databases can only guarantee two of three properties:

### C - Consistency
Every read receives the most recent write. All nodes see the same data at the same time.

### A - Availability
Every request receives a response (success or failure). The system remains operational.

### P - Partition Tolerance
The system continues to operate despite network partitions (communication breakdowns).

### Trade-offs

**CA (Consistency + Availability)**: Traditional relational databases
- Example: PostgreSQL, MySQL (single node)
- Not partition-tolerant

**CP (Consistency + Partition Tolerance)**: Strong consistency, may be unavailable during network issues
- Example: MongoDB, HBase, Redis
- Sacrifices availability for consistency

**AP (Availability + Partition Tolerance)**: Always available, but may serve stale data
- Example: Cassandra, DynamoDB, CouchDB
- Sacrifices consistency for availability

Most NoSQL databases choose AP or CP depending on use case.

---

## BASE vs ACID

NoSQL databases often follow BASE principles instead of ACID:

### ACID (Relational Databases)
- **Atomicity**: All or nothing
- **Consistency**: Valid state transitions
- **Isolation**: Transactions don't interfere
- **Durability**: Committed data persists

### BASE (NoSQL Databases)
- **Basically Available**: System appears to work most of the time
- **Soft state**: State may change without input (due to eventual consistency)
- **Eventually consistent**: System will become consistent over time

### Example of Eventual Consistency

```
Time: T0
Server 1: Balance = $1000
Server 2: Balance = $1000
Server 3: Balance = $1000

Time: T1 - User withdraws $100 from Server 1
Server 1: Balance = $900 (updated)
Server 2: Balance = $1000 (not yet updated)
Server 3: Balance = $1000 (not yet updated)

Time: T2 - Replication in progress
Server 1: Balance = $900
Server 2: Balance = $900 (updated)
Server 3: Balance = $1000 (not yet updated)

Time: T3 - Eventually consistent
Server 1: Balance = $900
Server 2: Balance = $900
Server 3: Balance = $900 (updated)
```

---

## When to Use NoSQL

### Use NoSQL When:

1. **Massive scale**: Handling millions/billions of records
2. **High throughput**: Thousands of reads/writes per second
3. **Flexible schema**: Data structure changes frequently
4. **Unstructured data**: JSON documents, logs, sensor data
5. **Global distribution**: Data centers worldwide
6. **Rapid development**: Need to iterate quickly
7. **Specific access patterns**: Known query patterns don't need JOINs

### Use Relational Databases When:

1. **Complex relationships**: Many-to-many relationships across entities
2. **ACID compliance**: Financial transactions, banking
3. **Ad-hoc queries**: Unknown query patterns
4. **Data integrity**: Strong constraints and validations
5. **Reporting**: Complex analytical queries with JOINs
6. **Mature ecosystem**: Need standard SQL tools
7. **Small to medium scale**: Data fits on single server

---

## Comparison: Relational vs NoSQL

| Aspect | Relational (SQL) | NoSQL |
|--------|------------------|-------|
| **Data Model** | Tables with rows/columns | Varies (documents, key-value, etc.) |
| **Schema** | Fixed, predefined | Flexible, dynamic |
| **Scaling** | Vertical (bigger servers) | Horizontal (more servers) |
| **Transactions** | ACID compliant | BASE (eventual consistency) |
| **Query Language** | SQL (standardized) | Varies by database |
| **Relationships** | JOINs, foreign keys | Embedded or referenced |
| **Best For** | Complex queries, transactions | High scale, flexible data |
| **Consistency** | Strong consistency | Eventual consistency (often) |
| **Examples** | PostgreSQL, MySQL, Oracle | MongoDB, Cassandra, Redis |

---

## Polyglot Persistence

Modern applications often use multiple database types:

```
E-commerce Application:
├─ PostgreSQL: Order transactions, inventory (ACID needed)
├─ MongoDB: Product catalog (flexible schema)
├─ Redis: Session cache, shopping carts (fast access)
├─ Elasticsearch: Product search (full-text search)
└─ Neo4j: Product recommendations (graph relationships)
```

**Benefits**:
- Use the right tool for each job
- Optimize for specific use cases
- Balance trade-offs across system

**Challenges**:
- Increased complexity
- Data synchronization
- More systems to manage
- Consistency across databases

---

## Popular NoSQL Databases

### MongoDB (Document)
- Most popular NoSQL database
- JSON-like documents
- Rich query language
- Good developer experience
- Cloud: MongoDB Atlas

### Redis (Key-Value)
- In-memory data store
- Extremely fast
- Data structures: strings, lists, sets, hashes
- Caching, session storage, real-time analytics
- Cloud: Redis Enterprise, AWS ElastiCache

### Cassandra (Column-Family)
- Highly scalable and available
- No single point of failure
- Linear scalability
- Time-series and IoT data
- Used by: Netflix, Instagram, Apple

### Neo4j (Graph)
- Leading graph database
- Cypher query language
- ACID transactions
- Social networks, fraud detection
- Cloud: Neo4j Aura

### Amazon DynamoDB (Key-Value/Document)
- Fully managed AWS service
- Single-digit millisecond latency
- Automatic scaling
- Serverless option
- Pay per request

### Elasticsearch (Search)
- Full-text search engine
- Near real-time search
- Log analytics
- Built on Apache Lucene
- Part of Elastic Stack (ELK)

---

## NoSQL Query Examples

### MongoDB (Document)
```javascript
// Insert document
db.users.insertOne({
  name: "Alice",
  email: "alice@example.com",
  age: 30,
  interests: ["reading", "coding", "travel"]
});

// Find documents
db.users.find({ age: { $gt: 25 } });

// Update document
db.users.updateOne(
  { name: "Alice" },
  { $set: { age: 31 } }
);

// Complex query with aggregation
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } },
  { $sort: { total: -1 } },
  { $limit: 10 }
]);
```

### Redis (Key-Value)
```redis
# Set key-value
SET user:1000:name "Alice"
SET user:1000:email "alice@example.com"

# Get value
GET user:1000:name

# Hash (object)
HSET user:1000 name "Alice" email "alice@example.com" age 30

# List operations
LPUSH cart:1000 "item1" "item2" "item3"
LRANGE cart:1000 0 -1

# Set expiration
SETEX session:abc123 3600 "sessiondata"

# Increment counter
INCR page:views
```

### Cassandra (Column-Family)
```cql
-- Create table
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  name TEXT,
  email TEXT,
  created_at TIMESTAMP
);

-- Insert data
INSERT INTO users (user_id, name, email, created_at)
VALUES (uuid(), 'Alice', 'alice@example.com', toTimestamp(now()));

-- Query data
SELECT * FROM users WHERE user_id = 123e4567-e89b-12d3-a456-426614174000;

-- Time-series table
CREATE TABLE events (
  user_id UUID,
  event_time TIMESTAMP,
  event_type TEXT,
  PRIMARY KEY (user_id, event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);
```

### Neo4j (Graph)
```cypher
// Create nodes
CREATE (alice:Person {name: 'Alice', age: 30})
CREATE (bob:Person {name: 'Bob', age: 25})
CREATE (acme:Company {name: 'Acme Corp'})

// Create relationships
CREATE (alice)-[:FRIENDS_WITH]->(bob)
CREATE (alice)-[:WORKS_AT {since: 2020}]->(acme)

// Query: Find Alice's friends
MATCH (alice:Person {name: 'Alice'})-[:FRIENDS_WITH]->(friend)
RETURN friend.name

// Complex query: Friend recommendations
MATCH (user:Person {name: 'Alice'})-[:FRIENDS_WITH]->(friend)-[:FRIENDS_WITH]->(fof)
WHERE NOT (user)-[:FRIENDS_WITH]->(fof) AND user <> fof
RETURN fof.name, COUNT(*) AS mutual_friends
ORDER BY mutual_friends DESC
```

---

## Data Modeling in NoSQL

### Document Database Modeling

**Embed Related Data** (Denormalization):
```json
{
  "_id": "order001",
  "customer": {
    "name": "Alice",
    "email": "alice@example.com"
  },
  "items": [
    {"productId": "P123", "name": "Laptop", "price": 999.99, "quantity": 1},
    {"productId": "P456", "name": "Mouse", "price": 24.99, "quantity": 2}
  ],
  "total": 1049.97,
  "status": "shipped"
}
```

**Reference Related Data**:
```json
{
  "_id": "order001",
  "customerId": "C123",
  "items": [
    {"productId": "P123", "quantity": 1},
    {"productId": "P456", "quantity": 2}
  ]
}
```

**When to Embed**:
- Data is accessed together
- One-to-few relationships
- Data doesn't change often
- Need atomic updates

**When to Reference**:
- Data is large
- Many-to-many relationships
- Data changes frequently
- Need to access independently

---

## NoSQL Performance Considerations

### Indexing

Most NoSQL databases support indexes:

```javascript
// MongoDB: Create index
db.users.createIndex({ email: 1 });
db.users.createIndex({ age: 1, name: 1 });
db.users.createIndex({ interests: 1 }); // Array index
```

### Sharding (Horizontal Partitioning)

Distribute data across multiple servers:

```
Shard 1 (Users A-M): Server 1
Shard 2 (Users N-Z): Server 2
```

**Shard Key Selection**:
- High cardinality
- Even distribution
- Matches query patterns

### Replication

Copy data across multiple servers:

```
Primary: Master (writes)
  ├─ Secondary 1: Slave (reads)
  └─ Secondary 2: Slave (reads)
```

**Benefits**:
- High availability
- Read scalability
- Disaster recovery

---

## Migration from SQL to NoSQL

### Planning

1. **Analyze access patterns**: How is data queried?
2. **Identify bottlenecks**: What's slow in current system?
3. **Choose NoSQL type**: Document, key-value, etc.
4. **Design data model**: Embed vs reference
5. **Plan migration strategy**: Big bang or gradual

### Migration Strategies

**Strategy 1: Dual Write**
```
Application
  ├─ Write to SQL (primary)
  └─ Write to NoSQL (sync)
Eventually switch reads to NoSQL
```

**Strategy 2: Change Data Capture (CDC)**
```
SQL Database → CDC Tool → NoSQL Database
```

**Strategy 3: Batch Migration**
```
1. Snapshot SQL data
2. Transform and load to NoSQL
3. Catch up with recent changes
4. Switch over
```

---

## Best Practices

### 1. Understand Your Access Patterns
Design schema based on how you'll query data, not how you'll store it.

### 2. Denormalize When Appropriate
In NoSQL, duplication is often acceptable for performance.

### 3. Design for Scale
Plan for horizontal scaling from the beginning.

### 4. Monitor Performance
Track query performance, storage, and throughput.

### 5. Handle Failures Gracefully
Design for eventual consistency and partition tolerance.

### 6. Use Appropriate Data Types
Choose the right NoSQL type for your use case.

### 7. Security
Implement authentication, authorization, encryption.

### 8. Backup and Recovery
Regular backups, test restore procedures.

---

## Common Pitfalls

1. **Using NoSQL for everything**: Not all problems need NoSQL
2. **Ignoring consistency requirements**: Some data needs ACID
3. **Poor schema design**: Not thinking about access patterns
4. **Over-normalization**: Trying to recreate SQL in NoSQL
5. **No indexing**: Assuming NoSQL is always fast
6. **Ignoring monitoring**: Not tracking performance
7. **Single region deployment**: Missing benefits of distribution

---

## Future of NoSQL

### Trends

1. **Multi-model databases**: Support multiple data models (ArangoDB, CosmosDB)
2. **NewSQL**: SQL databases with NoSQL scalability (Google Spanner, CockroachDB)
3. **Cloud-native**: Serverless NoSQL (DynamoDB, Firestore)
4. **Edge computing**: Distributed databases at edge locations
5. **AI/ML integration**: Built-in ML capabilities

---

## Summary

NoSQL databases provide alternatives to traditional relational databases for specific use cases:

- **Documents**: Flexible, intuitive (MongoDB, CouchDB)
- **Key-Value**: Fast, simple (Redis, DynamoDB)
- **Column-Family**: Time-series, IoT (Cassandra, HBase)
- **Graph**: Connected data (Neo4j, Neptune)

Choose based on:
- Scale requirements
- Data structure
- Query patterns
- Consistency needs
- Development speed

NoSQL is not a replacement for SQL, but a complementary tool in the database landscape.

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026
