# Neo4j - Introduction and Guide

## What is Neo4j?

**Neo4j** is a native graph database management system that stores data as nodes and relationships instead of tables or documents. It's optimized for storing and querying highly connected data, making it ideal for social networks, recommendation engines, fraud detection, and knowledge graphs.

### Key Features

- **Native Graph Storage**: Data stored as nodes, relationships, and properties
- **Cypher Query Language**: Powerful, intuitive graph query language
- **ACID Transactions**: Full ACID compliance
- **High Performance**: Optimized for traversing relationships
- **Scalability**: Horizontal scaling with clustering
- **Visualization**: Built-in graph visualization tools
- **Schema-optional**: Flexible data modeling

---

## Graph Database Concepts

### Nodes

Nodes represent entities in your domain (people, products, locations, etc.):

```
(n:Person {name: "Alice", age: 30})
```

- **Labels**: Categories that group nodes (`:Person`, `:Product`)
- **Properties**: Key-value pairs storing data (`name: "Alice"`)
- **Multiple Labels**: A node can have multiple labels

### Relationships

Relationships connect nodes and represent associations:

```
(alice)-[:KNOWS {since: 2020}]->(bob)
```

- **Type**: Every relationship has exactly one type (`:KNOWS`, `:LIKES`, `:BOUGHT`)
- **Direction**: Relationships always have a direction
- **Properties**: Relationships can have properties
- **No duplicates**: Same relationship type can only exist once between two nodes in same direction

### Properties

Both nodes and relationships can have properties:

```
{
  name: "Alice Johnson",
  age: 30,
  email: "alice@example.com",
  registered: date("2024-01-15")
}
```

Supported property types:
- String, Integer, Float, Boolean
- Date, DateTime, Time, Duration
- Point (spatial data)
- Lists of any above types

---

## Cypher Query Language

Cypher is Neo4j's declarative query language, using ASCII-art syntax for pattern matching.

### Basic Syntax

**Node Pattern**:
```cypher
(n)              // Any node
(n:Person)       // Node with Person label
(n:Person:User)  // Node with multiple labels
(n {name: "Alice"})  // Node with property
(n:Person {name: "Alice"})  // Combination
```

**Relationship Pattern**:
```cypher
()--()           // Any relationship, any direction
()-->()          // Relationship, right direction
()<--()          // Relationship, left direction
()-[:KNOWS]->()  // Specific relationship type
()-[r:KNOWS]->() // Named relationship variable
()-[r:KNOWS {since: 2020}]->()  // With properties
()-[r:KNOWS|LIKES]->()  // Multiple types
()-[*1..3]->()   // Variable length (1 to 3 hops)
```

**Pattern**:
```cypher
(alice:Person {name: "Alice"})-[:KNOWS]->(bob:Person {name: "Bob"})
```

---

## CRUD Operations

### Create

**Create Single Node**:
```cypher
CREATE (n:Person {
  name: "Alice Johnson",
  age: 30,
  email: "alice@example.com",
  city: "Boston"
})
RETURN n;
```

**Create Multiple Nodes**:
```cypher
CREATE 
  (alice:Person {name: "Alice", age: 30}),
  (bob:Person {name: "Bob", age: 25}),
  (charlie:Person {name: "Charlie", age: 35})
RETURN alice, bob, charlie;
```

**Create Node with Multiple Labels**:
```cypher
CREATE (n:Person:User:Admin {name: "Alice"})
RETURN n;
```

**Create Relationship**:
```cypher
MATCH (alice:Person {name: "Alice"})
MATCH (bob:Person {name: "Bob"})
CREATE (alice)-[r:KNOWS {since: 2020, type: "friend"}]->(bob)
RETURN alice, r, bob;
```

**Create Pattern (Nodes and Relationships)**:
```cypher
CREATE (alice:Person {name: "Alice", age: 30})
CREATE (bob:Person {name: "Bob", age: 25})
CREATE (alice)-[:KNOWS {since: 2020}]->(bob)
RETURN alice, bob;
```

**Create or Match (MERGE)**:
```cypher
// Create node if it doesn't exist
MERGE (n:Person {email: "alice@example.com"})
ON CREATE SET n.name = "Alice", n.createdAt = timestamp()
ON MATCH SET n.lastSeen = timestamp()
RETURN n;

// Create relationship if it doesn't exist
MATCH (alice:Person {name: "Alice"})
MATCH (bob:Person {name: "Bob"})
MERGE (alice)-[r:KNOWS]->(bob)
ON CREATE SET r.since = 2024
RETURN alice, r, bob;
```

### Read (Match)

**Find All Nodes**:
```cypher
MATCH (n:Person)
RETURN n;
```

**Find Nodes with Conditions**:
```cypher
// Single condition
MATCH (n:Person {name: "Alice"})
RETURN n;

// WHERE clause
MATCH (n:Person)
WHERE n.age > 25
RETURN n;

// Multiple conditions
MATCH (n:Person)
WHERE n.age > 25 AND n.city = "Boston"
RETURN n;
```

**Find Relationships**:
```cypher
// Find who Alice knows
MATCH (alice:Person {name: "Alice"})-[:KNOWS]->(friend)
RETURN friend;

// Bidirectional
MATCH (alice:Person {name: "Alice"})-[:KNOWS]-(friend)
RETURN friend;

// With relationship properties
MATCH (alice:Person {name: "Alice"})-[r:KNOWS]->(friend)
WHERE r.since >= 2020
RETURN friend, r.since;
```

**Pattern Matching**:
```cypher
// Friends of friends
MATCH (person:Person {name: "Alice"})-[:KNOWS]->()-[:KNOWS]->(fof)
RETURN fof;

// Shortest path
MATCH path = shortestPath(
  (alice:Person {name: "Alice"})-[:KNOWS*]-(bob:Person {name: "Bob"})
)
RETURN path;

// Variable length paths
MATCH (person:Person {name: "Alice"})-[:KNOWS*1..3]->(connection)
RETURN connection;
```

**Return Specific Properties**:
```cypher
MATCH (n:Person)
RETURN n.name, n.age, n.city;

// With aliases
MATCH (n:Person)
RETURN n.name AS name, n.age AS age;

// Distinct values
MATCH (n:Person)
RETURN DISTINCT n.city;

// Count
MATCH (n:Person)
RETURN count(n);
```

### Update

**Set Properties**:
```cypher
// Update single property
MATCH (n:Person {name: "Alice"})
SET n.age = 31
RETURN n;

// Update multiple properties
MATCH (n:Person {name: "Alice"})
SET n.age = 31, n.city = "Cambridge"
RETURN n;

// Add property
MATCH (n:Person {name: "Alice"})
SET n.phone = "555-1234"
RETURN n;

// Replace all properties
MATCH (n:Person {name: "Alice"})
SET n = {name: "Alice Johnson", age: 31, email: "alice@example.com"}
RETURN n;

// Add properties without replacing
MATCH (n:Person {name: "Alice"})
SET n += {phone: "555-1234", verified: true}
RETURN n;
```

**Update Labels**:
```cypher
// Add label
MATCH (n:Person {name: "Alice"})
SET n:Admin
RETURN n;

// Add multiple labels
MATCH (n:Person {name: "Alice"})
SET n:Admin:Verified
RETURN n;

// Remove label
MATCH (n:Person:Admin {name: "Alice"})
REMOVE n:Admin
RETURN n;
```

**Update Relationship Properties**:
```cypher
MATCH (alice:Person {name: "Alice"})-[r:KNOWS]->(bob:Person {name: "Bob"})
SET r.strength = "strong", r.lastContact = timestamp()
RETURN r;
```

**Increment Values**:
```cypher
MATCH (n:Person {name: "Alice"})
SET n.loginCount = coalesce(n.loginCount, 0) + 1
RETURN n;
```

### Delete

**Delete Nodes**:
```cypher
// Delete node (only if no relationships)
MATCH (n:Person {name: "Alice"})
DELETE n;

// Delete node and all relationships (detach)
MATCH (n:Person {name: "Alice"})
DETACH DELETE n;

// Delete multiple nodes
MATCH (n:Person)
WHERE n.age < 18
DETACH DELETE n;
```

**Delete Relationships**:
```cypher
// Delete specific relationship
MATCH (alice:Person {name: "Alice"})-[r:KNOWS]->(bob:Person {name: "Bob"})
DELETE r;

// Delete all relationships of a type
MATCH ()-[r:TEMPORARY]-()
DELETE r;
```

**Remove Properties**:
```cypher
// Remove single property
MATCH (n:Person {name: "Alice"})
REMOVE n.phone
RETURN n;

// Remove multiple properties
MATCH (n:Person {name: "Alice"})
REMOVE n.phone, n.address
RETURN n;
```

**Delete All Data**:
```cypher
// Delete everything (use with caution!)
MATCH (n)
DETACH DELETE n;
```

---

## Query Operators and Functions

### Comparison Operators

```cypher
MATCH (n:Person)
WHERE n.age = 30              // Equal
   OR n.age <> 30             // Not equal
   OR n.age > 25              // Greater than
   OR n.age >= 25             // Greater than or equal
   OR n.age < 40              // Less than
   OR n.age <= 40             // Less than or equal
RETURN n;
```

### Logical Operators

```cypher
// AND
MATCH (n:Person)
WHERE n.age > 25 AND n.city = "Boston"
RETURN n;

// OR
MATCH (n:Person)
WHERE n.city = "Boston" OR n.city = "Cambridge"
RETURN n;

// NOT
MATCH (n:Person)
WHERE NOT n.city = "Boston"
RETURN n;

// XOR
MATCH (n:Person)
WHERE n.age > 30 XOR n.city = "Boston"
RETURN n;
```

### String Operators

```cypher
// String matching
MATCH (n:Person)
WHERE n.name STARTS WITH "A"     // Starts with
   OR n.name ENDS WITH "son"     // Ends with
   OR n.name CONTAINS "Alice"    // Contains
RETURN n;

// Regular expression
MATCH (n:Person)
WHERE n.email =~ ".*@example\\.com$"
RETURN n;

// Case-insensitive
MATCH (n:Person)
WHERE toLower(n.name) = "alice"
RETURN n;
```

### Collection Operators

```cypher
// IN operator
MATCH (n:Person)
WHERE n.city IN ["Boston", "Cambridge", "New York"]
RETURN n;

// List properties
MATCH (p:Product)
WHERE "electronics" IN p.categories
RETURN p;

// ALL
MATCH (p:Product)
WHERE ALL(x IN p.tags WHERE x STARTS WITH "tech-")
RETURN p;

// ANY
MATCH (p:Product)
WHERE ANY(x IN p.tags WHERE x = "featured")
RETURN p;

// NONE
MATCH (p:Product)
WHERE NONE(x IN p.tags WHERE x = "discontinued")
RETURN p;
```

### Null Checks

```cypher
// IS NULL
MATCH (n:Person)
WHERE n.phone IS NULL
RETURN n;

// IS NOT NULL
MATCH (n:Person)
WHERE n.email IS NOT NULL
RETURN n;
```

### Pattern Predicates

```cypher
// Node exists with pattern
MATCH (person:Person)
WHERE (person)-[:KNOWS]->(:Person {name: "Alice"})
RETURN person;

// NOT EXISTS
MATCH (person:Person)
WHERE NOT (person)-[:KNOWS]->()
RETURN person;

// Relationship count
MATCH (person:Person)
WHERE size((person)-[:KNOWS]->()) > 5
RETURN person;
```

---

## Aggregation

### Basic Aggregation Functions

```cypher
// Count
MATCH (n:Person)
RETURN count(n);

// Count distinct
MATCH (n:Person)
RETURN count(DISTINCT n.city);

// Sum
MATCH (p:Product)
RETURN sum(p.price);

// Average
MATCH (p:Product)
RETURN avg(p.price);

// Min/Max
MATCH (p:Person)
RETURN min(p.age), max(p.age);

// Collect (create list)
MATCH (p:Person)
RETURN collect(p.name);

// Collect distinct
MATCH (p:Person)
RETURN collect(DISTINCT p.city);
```

### GROUP BY (Implicit with Aggregation)

```cypher
// Group by city and count
MATCH (n:Person)
RETURN n.city, count(n) AS population
ORDER BY population DESC;

// Group by multiple fields
MATCH (n:Person)
RETURN n.city, n.age, count(n) AS count;

// Group with WHERE
MATCH (n:Person)
WHERE n.age >= 18
RETURN n.city, avg(n.age) AS avgAge;
```

### WITH Clause (Chaining Queries)

```cypher
// Use WITH to chain operations
MATCH (person:Person)
WITH person, size((person)-[:KNOWS]->()) AS friendCount
WHERE friendCount > 5
RETURN person.name, friendCount
ORDER BY friendCount DESC;

// Multiple WITH clauses
MATCH (person:Person)-[:BOUGHT]->(product:Product)
WITH person, count(product) AS purchaseCount
WHERE purchaseCount > 10
WITH person, purchaseCount
ORDER BY purchaseCount DESC
LIMIT 5
RETURN person.name, purchaseCount;
```

---

## Sorting and Limiting

```cypher
// Order by ascending
MATCH (n:Person)
RETURN n
ORDER BY n.age;

// Order by descending
MATCH (n:Person)
RETURN n
ORDER BY n.age DESC;

// Order by multiple fields
MATCH (n:Person)
RETURN n
ORDER BY n.city, n.age DESC;

// Limit results
MATCH (n:Person)
RETURN n
LIMIT 10;

// Skip and limit (pagination)
MATCH (n:Person)
RETURN n
ORDER BY n.name
SKIP 20
LIMIT 10;
```

---

## Advanced Patterns

### Optional Match

Like LEFT JOIN in SQL:

```cypher
// Return persons even if they don't know anyone
MATCH (person:Person)
OPTIONAL MATCH (person)-[:KNOWS]->(friend)
RETURN person.name, collect(friend.name) AS friends;
```

### Union

```cypher
// Combine results
MATCH (n:Person {city: "Boston"})
RETURN n.name AS name
UNION
MATCH (n:Person {city: "Cambridge"})
RETURN n.name AS name;

// Union All (include duplicates)
MATCH (n:Person {city: "Boston"})
RETURN n.name
UNION ALL
MATCH (n:Person {age: 30})
RETURN n.name;
```

### Case Expressions

```cypher
MATCH (p:Person)
RETURN p.name,
  CASE
    WHEN p.age < 18 THEN "Minor"
    WHEN p.age < 65 THEN "Adult"
    ELSE "Senior"
  END AS ageGroup;

// Simple case
MATCH (p:Person)
RETURN p.name,
  CASE p.status
    WHEN "active" THEN "Active User"
    WHEN "inactive" THEN "Inactive User"
    ELSE "Unknown"
  END AS statusLabel;
```

### Subqueries

```cypher
// Subquery in WHERE
MATCH (person:Person)
WHERE person.age > 25 
  AND size([
    (person)-[:KNOWS]->(friend)
    WHERE friend.age > 25 | friend
  ]) > 3
RETURN person;

// CALL subquery
MATCH (person:Person)
CALL {
  WITH person
  MATCH (person)-[:KNOWS]->(friend)
  RETURN count(friend) AS friendCount
}
RETURN person.name, friendCount;
```

---

## Path Queries

### Shortest Path

```cypher
// Shortest path between two nodes
MATCH (alice:Person {name: "Alice"}),
      (bob:Person {name: "Bob"}),
      path = shortestPath((alice)-[:KNOWS*]-(bob))
RETURN path;

// Shortest path with max length
MATCH path = shortestPath(
  (alice:Person {name: "Alice"})-[:KNOWS*..5]-(bob:Person {name: "Bob"})
)
RETURN path;
```

### All Paths

```cypher
// All paths between two nodes
MATCH path = (alice:Person {name: "Alice"})-[:KNOWS*..4]-(bob:Person {name: "Bob"})
RETURN path;
```

### Variable Length Relationships

```cypher
// Friends within 3 degrees
MATCH (person:Person {name: "Alice"})-[:KNOWS*1..3]->(connection)
RETURN DISTINCT connection;

// Count path length
MATCH path = (person:Person {name: "Alice"})-[:KNOWS*]-(connection)
RETURN connection.name, length(path) AS degrees
ORDER BY degrees;
```

---

## Indexes and Constraints

### Indexes

```cypher
// Create single property index
CREATE INDEX person_name FOR (n:Person) ON (n.name);

// Create composite index
CREATE INDEX person_name_age FOR (n:Person) ON (n.name, n.age);

// Create full-text index
CREATE FULLTEXT INDEX person_search FOR (n:Person) ON EACH [n.name, n.email];

// List all indexes
SHOW INDEXES;

// Drop index
DROP INDEX person_name;
```

### Constraints

```cypher
// Unique constraint
CREATE CONSTRAINT person_email FOR (n:Person) REQUIRE n.email IS UNIQUE;

// Node key (multiple properties must be unique together)
CREATE CONSTRAINT person_key FOR (n:Person) REQUIRE (n.firstName, n.lastName) IS NODE KEY;

// Property existence (Enterprise only)
CREATE CONSTRAINT person_name_exists FOR (n:Person) REQUIRE n.name IS NOT NULL;

// List all constraints
SHOW CONSTRAINTS;

// Drop constraint
DROP CONSTRAINT person_email;
```

---

## Functions

### String Functions

```cypher
MATCH (p:Person)
RETURN 
  toUpper(p.name),           // ALICE
  toLower(p.name),           // alice
  trim(p.name),              // Remove whitespace
  substring(p.name, 0, 3),   // Ali
  replace(p.name, "Alice", "Alicia"),
  split(p.name, " "),        // ["Alice", "Johnson"]
  size(p.name);              // String length
```

### Mathematical Functions

```cypher
RETURN 
  abs(-42),           // 42
  ceil(3.14),         // 4
  floor(3.14),        // 3
  round(3.14),        // 3
  sqrt(16),           // 4.0
  rand(),             // Random 0-1
  sign(-42);          // -1
```

### Collection Functions

```cypher
MATCH (p:Person)
WITH collect(p.name) AS names
RETURN 
  size(names),              // Count
  head(names),              // First element
  last(names),              // Last element
  tail(names),              // All but first
  range(0, 10),             // [0,1,2..10]
  [x IN names WHERE x STARTS WITH "A"];  // Filter
```

### Date/Time Functions

```cypher
RETURN 
  date(),                              // Current date
  datetime(),                          // Current datetime
  time(),                              // Current time
  timestamp(),                         // Milliseconds since epoch
  date("2024-01-15"),                  // Parse date
  datetime("2024-01-15T10:30:00"),     // Parse datetime
  duration("P1Y2M3D");                 // 1 year, 2 months, 3 days

// Date arithmetic
MATCH (p:Person)
RETURN p.name, 
  date() - p.birthDate AS age,
  date() + duration("P1M") AS nextMonth;
```

### Node/Relationship Functions

```cypher
MATCH (n:Person)-[r:KNOWS]->(m)
RETURN 
  id(n),                // Node internal ID
  labels(n),            // ["Person", "User"]
  properties(n),        // All properties as map
  keys(n),              // Property names
  type(r),              // "KNOWS"
  startNode(r),         // n
  endNode(r);           // m
```

---

## Data Modeling Patterns

### One-to-Many

```cypher
// User has many posts
CREATE (user:User {name: "Alice"})
CREATE (post1:Post {title: "First Post"})
CREATE (post2:Post {title: "Second Post"})
CREATE (user)-[:POSTED]->(post1)
CREATE (user)-[:POSTED]->(post2);

// Query
MATCH (user:User {name: "Alice"})-[:POSTED]->(post)
RETURN user, collect(post) AS posts;
```

### Many-to-Many

```cypher
// Students enroll in courses
CREATE (s1:Student {name: "Alice"})
CREATE (s2:Student {name: "Bob"})
CREATE (c1:Course {name: "Math"})
CREATE (c2:Course {name: "Science"})
CREATE (s1)-[:ENROLLED_IN {year: 2024}]->(c1)
CREATE (s1)-[:ENROLLED_IN {year: 2024}]->(c2)
CREATE (s2)-[:ENROLLED_IN {year: 2024}]->(c1);
```

### Hierarchies (Tree)

```cypher
// Organization chart
CREATE (ceo:Employee {name: "Alice", title: "CEO"})
CREATE (cto:Employee {name: "Bob", title: "CTO"})
CREATE (dev1:Employee {name: "Charlie", title: "Developer"})
CREATE (dev2:Employee {name: "Diana", title: "Developer"})
CREATE (cto)-[:REPORTS_TO]->(ceo)
CREATE (dev1)-[:REPORTS_TO]->(cto)
CREATE (dev2)-[:REPORTS_TO]->(cto);

// Find all reports (direct and indirect)
MATCH (ceo:Employee {name: "Alice"})<-[:REPORTS_TO*]-(employee)
RETURN employee;
```

### Time-Based Relationships

```cypher
// Track relationship history
CREATE (alice:Person {name: "Alice"})
CREATE (company1:Company {name: "StartupCo"})
CREATE (company2:Company {name: "BigCorp"})
CREATE (alice)-[:WORKED_AT {from: date("2018-01-01"), to: date("2020-12-31")}]->(company1)
CREATE (alice)-[:WORKED_AT {from: date("2021-01-01"), to: null}]->(company2);

// Find current employer
MATCH (alice:Person {name: "Alice"})-[r:WORKED_AT]->(company)
WHERE r.to IS NULL
RETURN company;
```

---

## Performance Best Practices

###1. Use Indexes

```cypher
// Create index on frequently queried properties
CREATE INDEX FOR (n:Person) ON (n.email);
CREATE INDEX FOR (n:Person) ON (n.name, n.city);
```

### 2. Use Labels

```cypher
// Bad: No label
MATCH (n {name: "Alice"})
RETURN n;

// Good: Use label
MATCH (n:Person {name: "Alice"})
RETURN n;
```

### 3. Start with Most Specific

```cypher
// Bad: Start with broad pattern
MATCH (n)-[:KNOWS]->(friend)
WHERE n.email = "alice@example.com"
RETURN friend;

// Good: Start with specific node
MATCH (n:Person {email: "alice@example.com"})-[:KNOWS]->(friend)
RETURN friend;
```

### 4. Use LIMIT

```cypher
// Limit results early
MATCH (n:Person)
WHERE n.city = "Boston"
RETURN n
LIMIT 100;
```

### 5. Profile Queries

```cypher
// See query execution plan
PROFILE
MATCH (n:Person)-[:KNOWS]->(friend)
WHERE n.name = "Alice"
RETURN friend;

// Explain without executing
EXPLAIN
MATCH (n:Person)-[:KNOWS]->(friend)
WHERE n.name = "Alice"
RETURN friend;
```

---

## Neo4j Browser Commands

```cypher
// System commands
:help                  // Show help
:clear                 // Clear console
:schema                // Show database schema
:sysinfo               // System information

// Query management
:queries               // List running queries
:queries kill 123      // Kill query by ID

// Visualization
:style                 // Customize visualization
:style reset           // Reset to default

// Settings
:config                // Show configuration
:param name => "Alice" // Set parameter
:params                // Show all parameters
```

---

## Common Use Cases

### 1. Social Network

```cypher
// Find mutual friends
MATCH (alice:Person {name: "Alice"})-[:KNOWS]->(mutual)<-[:KNOWS]-(bob:Person {name: "Bob"})
RETURN mutual;

// Friend recommendations (friends of friends, not already friends)
MATCH (alice:Person {name: "Alice"})-[:KNOWS]->()-[:KNOWS]->(recommendation)
WHERE NOT (alice)-[:KNOWS]->(recommendation)
  AND alice <> recommendation
RETURN recommendation.name, count(*) AS strength
ORDER BY strength DESC
LIMIT 5;
```

### 2. Recommendation Engine

```cypher
// Collaborative filtering
MATCH (me:User {name: "Alice"})-[:RATED]->(product:Product)<-[:RATED]-(other:User)
MATCH (other)-[:RATED]->(recommendation:Product)
WHERE NOT (me)-[:RATED]->(recommendation)
RETURN recommendation, count(*) AS score
ORDER BY score DESC
LIMIT 10;
```

### 3. Fraud Detection

```cypher
// Find suspicious patterns (account sharing)
MATCH (u1:User)-[:LOGGED_IN_FROM]->(device:Device)<-[:LOGGED_IN_FROM]-(u2:User)
WHERE u1 <> u2
  AND NOT (u1)-[:KNOWS]-(u2)
RETURN u1, u2, device;
```

### 4. Network Impact Analysis

```cypher
// Find most influential person (highest degree centrality)
MATCH (person:Person)-[:KNOWS]-()
RETURN person.name, count(*) AS connections
ORDER BY connections DESC
LIMIT 10;
```

---

## Resources

- **Official Documentation**: [neo4j.com/docs](https://neo4j.com/docs/)
- **Cypher Refcard**: [neo4j.com/docs/cypher-refcard](https://neo4j.com/docs/cypher-refcard/)
- **Neo4j Browser**: Built-in interactive interface
- **Neo4j Desktop**: Development environment
- **Neo4j Aura**: Managed cloud service (free tier available)
- **Graph Gists**: Example datasets and queries

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Neo4j Graph Database
