# NoSQL Databases - Practice Exercises

## Instructions

Complete the following exercises to understand NoSQL databases, their types, use cases, and when to choose them over relational databases.

**Time Allocation**: 90-120 minutes  
**Difficulty**: Beginner to Intermediate  
**Prerequisites**: Understanding of relational databases

---

## Part 1: Understanding NoSQL Concepts

### Exercise 1: NoSQL Types Classification

For each scenario below, identify which type of NoSQL database would be most appropriate and explain why.

**Scenarios**:

1. A social media platform where users have friends, followers, and complex relationship chains
2. A real-time analytics dashboard showing website visitor counts and page views
3. An e-commerce site with product catalogs that have varying attributes (books have ISBN, clothes have sizes)
4. A logging system capturing millions of IoT sensor readings per second
5. A recommendation engine that needs to find "users who bought X also bought Y"
6. A session management system for a web application with millions of concurrent users
7. A content management system for a news website with articles, authors, comments, and tags
8. A financial fraud detection system tracking transaction patterns and relationships

**Deliverable**: For each scenario, specify:
- NoSQL type (Document, Key-Value, Column-Family, or Graph)
- Specific database example (MongoDB, Redis, Cassandra, Neo4j, etc.)
- Justification (2-3 sentences why this choice is best)

---

### Exercise 2: CAP Theorem Analysis

Given the CAP theorem (Consistency, Availability, Partition Tolerance), answer the following:

1. **Banking Application**: 
   - Which two properties are most important?
   - Would you choose CP or AP? Why?
   - Give an example database

2. **Social Media Feed**: 
   - Which two properties are most important?
   - Would you choose CP or AP? Why?
   - Give an example database

3. **E-commerce Inventory**: 
   - Which two properties are most important?
   - Would you choose CP or AP? Why?
   - Is eventual consistency acceptable?

4. **Chat Application**: 
   - Which two properties are most important?
   - Would you choose CP or AP? Why?
   - What happens during a network partition?

**Deliverable**: Detailed answers for each scenario with justifications

---

### Exercise 3: ACID vs BASE

Compare ACID and BASE principles:

1. **Define each letter** in both ACID and BASE acronyms

2. **Real-world scenario**: A user updates their profile picture
   - Explain how this would work under ACID
   - Explain how this would work under BASE
   - What are the trade-offs?

3. **Banking transfer**: Transfer $100 from Account A to Account B
   - Why must this be ACID?
   - What could go wrong with BASE?
   - Which is more important: consistency or availability?

4. **Social media like**: User likes a post
   - Could this use BASE? Why or why not?
   - What if the like count is temporarily wrong?
   - When should it become consistent?

**Deliverable**: Written explanations for each scenario

---

## Part 2: Data Modeling

### Exercise 4: Document Database Design

Design a document database schema for a **blogging platform**:

**Requirements**:
- Users can write blog posts
- Posts can have multiple tags
- Users can comment on posts
- Users can follow other users
- Track post views and likes

**Tasks**:

1. **Design collections**: What collections (tables equivalent) do you need?

2. **Design documents**: Show example JSON documents for:
   - A user
   - A blog post
   - A comment

3. **Embed vs Reference**: For each relationship, decide:
   - Should data be embedded or referenced?
   - Justify your decision

4. **Queries**: Write pseudo-queries for:
   - Get all posts by a user
   - Get a post with all its comments
   - Find posts with specific tag
   - Get user's followers

**Deliverable**: Complete schema design with JSON examples and justifications

---

### Exercise 5: Key-Value Store Design

Design a key-value store for a **gaming leaderboard system**:

**Requirements**:
- Store player scores
- Track player statistics
- Maintain global leaderboard
- Store active game sessions
- Cache player profiles

**Tasks**:

1. **Key naming convention**: Design key patterns like:
   - `player:{id}:score`
   - `player:{id}:stats`
   - etc.

2. **Value structures**: Show what data each key stores

3. **Operations**: Describe how to:
   - Update a player's score
   - Get top 10 players
   - Increment a counter
   - Store session data with expiration

4. **Performance**: Why is key-value optimal for this use case?

**Deliverable**: Complete key design with examples and operations

---

### Exercise 6: Graph Database Modeling

Design a graph database for a **movie recommendation system**:

**Requirements**:
- Users watch movies
- Movies have genres, actors, directors
- Users rate movies
- Users can be friends
- Find movie recommendations

**Tasks**:

1. **Node types**: Define node types and their properties

2. **Relationship types**: Define relationships like:
   - WATCHED
   - RATED
   - ACTED_IN
   - DIRECTED
   - FRIENDS_WITH

3. **Visual diagram**: Draw a sample graph with 3 users, 3 movies, 2 actors

4. **Queries**: Write Cypher-like queries for:
   - Find all movies watched by a user
   - Find movies watched by user's friends
   - Recommend movies based on similar users
   - Find common actors between two movies

**Deliverable**: Graph model with visual diagram and queries

---

## Part 3: SQL vs NoSQL Comparison

### Exercise 7: Migration Analysis

You have a **traditional SQL e-commerce database**:

**Tables**:
- customers (id, name, email, address)
- products (id, name, description, price, category)
- orders (id, customer_id, order_date, total)
- order_items (order_id, product_id, quantity, price)

**Tasks**:

1. **Identify bottlenecks**: What problems might occur at scale?

2. **NoSQL redesign**: Redesign using document database
   - Show document structures
   - Explain embed vs reference decisions
   - How would you handle JOINs?

3. **Trade-offs**: List 3 advantages and 3 disadvantages of migration

4. **Hybrid approach**: Design a system using both SQL and NoSQL
   - What stays in SQL?
   - What moves to NoSQL?
   - Why?

**Deliverable**: Complete analysis with redesigned schemas

---

### Exercise 8: Use Case Evaluation

For each scenario, decide: **SQL or NoSQL?**

| Scenario | Your Choice | Justification |
|----------|-------------|---------------|
| Banking transactions | | |
| Social media posts | | |
| Product inventory with variants | | |
| Government tax records | | |
| Real-time chat messages | | |
| Healthcare patient records | | |
| Gaming player data | | |
| Airline booking system | | |
| Analytics dashboard | | |
| Email system | | |

**Deliverable**: Complete table with detailed justifications

---

## Part 4: Querying NoSQL Databases

### Exercise 9: MongoDB Query Practice

Given this MongoDB collection `products`:

```json
{
  "_id": "P123",
  "name": "Laptop",
  "brand": "TechCo",
  "price": 999.99,
  "category": "Electronics",
  "specs": {
    "cpu": "Intel i7",
    "ram": "16GB",
    "storage": "512GB SSD"
  },
  "tags": ["computers", "portable", "work"],
  "reviews": [
    {"user": "Alice", "rating": 5, "comment": "Great!"},
    {"user": "Bob", "rating": 4, "comment": "Good value"}
  ],
  "inStock": true,
  "quantity": 15
}
```

**Write queries to**:

1. Find all products in "Electronics" category
2. Find products priced between $500 and $1500
3. Find products with tag "portable"
4. Find products with average rating above 4.5
5. Update the price of product P123 to $899.99
6. Add a new review to product P123
7. Find products that are out of stock (quantity = 0)
8. Get total count of products by category
9. Find products with "Intel" in the CPU specs
10. Delete products with no reviews

**Deliverable**: MongoDB-style queries for all 10 tasks

---

### Exercise 10: Redis Commands

Design Redis commands for these operations:

**Scenario**: User shopping cart system

1. Add item to cart: `Cart for user 1000, add product P123, quantity 2`
2. Get all items in cart
3. Remove item from cart
4. Set cart expiration: `Cart expires in 1 hour`
5. Increment product view counter
6. Store user session data: `User ID, last accessed, permissions`
7. Create a sorted leaderboard of top buyers
8. Check if user is logged in (using cache)
9. Store product popularity score
10. Implement rate limiting: `Max 100 requests per minute per user`

**Deliverable**: Redis commands for all operations

---

## Part 5: Advanced Concepts

### Exercise 11: Sharding Strategy

Design a sharding strategy for a **messaging application** with billions of messages:

**Requirements**:
- 1 billion active users
- 10 billion messages per day
- Messages belong to conversations
- Need to query user's conversations efficiently

**Tasks**:

1. **Choose shard key**: What field do you shard on? Why?
   - Options: user_id, conversation_id, timestamp, message_id

2. **Distribution**: How do you ensure even distribution?

3. **Query patterns**: How do these queries work across shards?
   - Get all messages in a conversation
   - Get user's recent conversations
   - Search messages by keyword

4. **Hot spots**: How do you avoid hot shards?

**Deliverable**: Complete sharding design with justifications

---

### Exercise 12: Replication Design

Design a replication strategy for a **global news website**:

**Requirements**:
- Readers in North America, Europe, Asia
- Breaking news must be fast
- Can tolerate slight delays for comments
- High read traffic, moderate write traffic

**Tasks**:

1. **Replication topology**: 
   - Single master or multi-master?
   - How many replicas per region?
   - Draw a diagram

2. **Consistency model**: 
   - Strong or eventual consistency?
   - Different for articles vs comments?

3. **Failover strategy**: 
   - What happens if primary fails?
   - How long to switch over?

4. **Read/write routing**:
   - Where do reads go?
   - Where do writes go?

**Deliverable**: Complete replication design with diagrams

---

## Part 6: Real-World Application

### Exercise 13: Polyglot Persistence Design

Design a complete database architecture for an **ride-sharing app** (like Uber):

**Features**:
- User accounts and profiles
- Real-time driver locations
- Ride history
- Payment processing
- Ratings and reviews
- Surge pricing calculations
- Driver analytics

**Tasks**:

1. **Choose databases**: For each feature, select appropriate database type

2. **Justify choices**: Explain why each database was chosen

3. **Data flow**: Show how data moves between systems

4. **Challenges**: What are the main challenges of this approach?

**Example format**:
```
Feature: User Profiles
Database: MongoDB (Document)
Reason: Flexible schema for varying user attributes
```

**Deliverable**: Complete architecture diagram with justifications

---

### Exercise 14: Performance Analysis

Compare performance characteristics:

Create a table comparing these operations across database types:

| Operation | SQL (PostgreSQL) | Document (MongoDB) | Key-Value (Redis) | Column (Cassandra) |
|-----------|------------------|-------------------|-------------------|-------------------|
| Single record lookup | | | | |
| Range query | | | | |
| Complex JOIN | | | | |
| Write throughput | | | | |
| Horizontal scaling | | | | |
| Schema changes | | | | |

**Deliverable**: Completed comparison table with explanations

---

### Exercise 15: Migration Plan

Create a migration plan to move a **SQL-based blog** to NoSQL:

**Current System**:
- PostgreSQL database
- 5 million posts
- 20 million comments
- 1 million users
- 100 GB data

**Tasks**:

1. **Analysis phase**:
   - Identify pain points
   - Measure current performance
   - Define success criteria

2. **Design phase**:
   - Choose NoSQL database
   - Design new schema
   - Plan data transformation

3. **Migration phase**:
   - Gradual or big bang?
   - Dual write strategy?
   - Data sync approach?

4. **Validation phase**:
   - How to verify correctness?
   - Performance testing?
   - Rollback plan?

5. **Timeline**: Estimate timeline for each phase

**Deliverable**: Complete migration plan document

---

## Bonus Challenges

### Challenge 1: Design a Search System

Design a complete search system using multiple NoSQL databases:

- Full-text search
- Auto-complete suggestions
- Search history
- Popular searches
- Personalized results

**Use**: Elasticsearch + Redis + MongoDB

**Deliverable**: Architecture diagram and data flow

---

### Challenge 2: Time-Series Database

Design a time-series database for **IoT sensor data**:

- 10,000 sensors
- Each reports temperature, humidity, pressure every second
- Need to query by time range
- Need to aggregate by hour/day/month
- Need to detect anomalies

**Deliverable**: Complete design using Cassandra or InfluxDB

---

### Challenge 3: Event Sourcing

Design an event sourcing system using NoSQL:

- Store all events (never delete)
- Rebuild state from events
- Support time travel (state at any point)
- Handle high write throughput

**Deliverable**: System design with example events

---

## Submission Checklist

Your completed exercise submission should include:

- [ ] NoSQL type classifications (Exercise 1)
- [ ] CAP theorem analysis (Exercise 2)
- [ ] ACID vs BASE comparison (Exercise 3)
- [ ] Document database design (Exercise 4)
- [ ] Key-value store design (Exercise 5)
- [ ] Graph database model (Exercise 6)
- [ ] Migration analysis (Exercise 7)
- [ ] Use case evaluations (Exercise 8)
- [ ] MongoDB queries (Exercise 9)
- [ ] Redis commands (Exercise 10)
- [ ] Sharding strategy (Exercise 11)
- [ ] Replication design (Exercise 12)
- [ ] Polyglot persistence architecture (Exercise 13)
- [ ] Performance analysis (Exercise 14)
- [ ] Migration plan (Exercise 15)
- [ ] Bonus challenges (optional)

---

## Tips for Success

1. **Think about access patterns**: Design based on how you'll query, not how you'll store
2. **Consider scale**: What works for 1000 records may not work for 1 billion
3. **Embrace denormalization**: In NoSQL, data duplication is often good
4. **Choose the right tool**: Not every problem needs NoSQL
5. **Draw diagrams**: Visual representations help understand architectures
6. **Research examples**: Look at how real companies use these databases
7. **Consider trade-offs**: Every choice has pros and cons

---

## Expected Learning Outcomes

After completing these exercises, you should be able to:

- Identify appropriate NoSQL database types for different use cases
- Understand CAP theorem and its implications
- Design schemas for document databases
- Model data for graph databases
- Compare SQL and NoSQL trade-offs
- Write queries for different NoSQL systems
- Design sharding and replication strategies
- Create polyglot persistence architectures
- Plan migrations from SQL to NoSQL
- Evaluate performance characteristics

---

## Additional Resources

- MongoDB University (free courses)
- Redis University (free courses)
- Neo4j Graph Academy
- DataStax Cassandra Academy
- AWS Database services documentation
- NoSQL Distilled (book by Martin Fowler)
- Designing Data-Intensive Applications (book)

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: NoSQL Databases
