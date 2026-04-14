# Neo4j - Concurrency Control

## Overview

Neo4j uses a combination of locking mechanisms and MVCC (Multi-Version Concurrency Control) to handle concurrent access to the graph database. Understanding these mechanisms is essential for building high-performance graph applications.

---

## Locking in Neo4j

### Lock Types

Neo4j uses two types of locks:

1. **Read Locks (Shared Locks)**:
   - Multiple transactions can hold read locks on the same entity
   - Allow concurrent reads
   - Block write locks

2. **Write Locks (Exclusive Locks)**:
   - Only one transaction can hold a write lock
   - Block both read and write locks from other transactions
   - Ensure exclusive access for modifications

### Lock Granularity

Neo4j locks at different levels:

```cypher
// Locks acquired automatically based on operations

// Node lock
MATCH (n:Person {id: 123})
SET n.lastLogin = timestamp()
// Acquires write lock on node

// Relationship lock
MATCH (a:Person)-[r:KNOWS]->(b:Person)
SET r.since = 2024
// Acquires write lock on relationship

// Label lock
CREATE (n:NewLabel {name: "test"})
// Acquires lock on label

// Schema lock
CREATE INDEX FOR (n:Person) ON (n.email)
// Acquires schema lock
```

---

## Transaction Isolation

### ACID Properties

Neo4j provides full ACID guarantees:

**Atomicity**: All operations in a transaction succeed or fail together
```cypher
// Either both updates happen or neither
BEGIN
MATCH (a:Account {id: 'A123'})
SET a.balance = a.balance - 100

MATCH (b:Account {id: 'B456'})
SET b.balance = b.balance + 100
COMMIT
```

**Consistency**: Database constraints remain satisfied
```cypher
// Constraint prevents duplicate emails
CREATE CONSTRAINT person_email IF NOT EXISTS
FOR (p:Person) REQUIRE p.email IS UNIQUE
```

**Isolation**: Concurrent transactions don't interfere
- Neo4j uses **Read Committed** isolation level by default
- Transactions see only committed data from other transactions

**Durability**: Committed data persists after transaction
- Data written to transaction log
- Survives system crashes

### Read Committed Isolation

```cypher
// Transaction 1
BEGIN
MATCH (n:Person {name: "Alice"})
SET n.age = 31
// Not yet visible to other transactions

COMMIT
// Now visible to all transactions

// Transaction 2 (concurrent)
BEGIN
MATCH (n:Person {name: "Alice"})
RETURN n.age
// Returns original age until Transaction 1 commits
```

---

## Handling Concurrent Writes

### Write Conflicts

When multiple transactions try to modify the same node:

```cypher
// Transaction 1
BEGIN
MATCH (n:Counter {id: "views"})
SET n.count = n.count + 1
COMMIT

// Transaction 2 (concurrent)
BEGIN
MATCH (n:Counter {id: "views"})
SET n.count = n.count + 1
COMMIT

// One transaction will wait for the other to complete
// Both increments will be applied correctly
```

### Deadlocks

Deadlocks can occur when transactions wait for each other:

```cypher
// Transaction 1
BEGIN
MATCH (a:Person {id: 1})
SET a.updated = timestamp()
// Holds lock on node 1

MATCH (b:Person {id: 2})
SET b.updated = timestamp()
// Waits for lock on node 2
COMMIT

// Transaction 2 (concurrent)
BEGIN
MATCH (b:Person {id: 2})
SET b.updated = timestamp()
// Holds lock on node 2

MATCH (a:Person {id: 1})
SET a.updated = timestamp()
// Waits for lock on node 1 - DEADLOCK!
COMMIT
```

**Error**: Neo4j detects deadlock and aborts one transaction:
```
Neo.TransientError.Transaction.DeadlockDetected
```

### Deadlock Prevention

**1. Order your operations consistently:**

```cypher
// BAD: Different order in different transactions
// Transaction 1: Update A then B
// Transaction 2: Update B then A

// GOOD: Same order in all transactions
// Always update in ID order
BEGIN
MATCH (a:Person), (b:Person)
WHERE a.id < b.id
CALL {
  WITH a
  SET a.updated = timestamp()
} IN TRANSACTIONS
CALL {
  WITH b
  SET b.updated = timestamp()
} IN TRANSACTIONS
COMMIT
```

**2. Keep transactions short:**

```cypher
// BAD: Long transaction holding locks
BEGIN
MATCH (n:Person {id: 123})
SET n.processing = true
// ... long computation or external API call ...
SET n.result = computedResult
COMMIT

// GOOD: Short transactions
// Do computation outside transaction
WITH computedResult
BEGIN
MATCH (n:Person {id: 123})
SET n.result = $result
COMMIT
```

**3. Retry on deadlock:**

```javascript
// JavaScript/Node.js with neo4j driver
async function executeWithRetry(session, query, params, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const result = await session.run(query, params);
      return result;
    } catch (error) {
      if (error.code === 'Neo.TransientError.Transaction.DeadlockDetected' && i < maxRetries - 1) {
        console.log(`Deadlock detected, retrying (attempt ${i + 1})...`);
        await sleep(100 * Math.pow(2, i)); // Exponential backoff
        continue;
      }
      throw error;
    }
  }
}
```

---

## Optimistic Locking Pattern

### Version-Based Concurrency Control

Implement optimistic locking with version numbers:

```cypher
// Initial node
CREATE (n:Document {
  id: 'doc123',
  content: 'Original content',
  version: 1
})

// Update with version check
MATCH (n:Document {id: 'doc123'})
WHERE n.version = $expectedVersion
SET n.content = $newContent,
    n.version = n.version + 1
RETURN n.version AS newVersion

// If no row returned, version conflict occurred
```

**Application code:**

```javascript
async function updateDocumentOptimistic(docId, newContent) {
  const session = driver.session();
  
  try {
    // Read current version
    const readResult = await session.run(
      'MATCH (n:Document {id: $docId}) RETURN n.version AS version',
      { docId }
    );
    
    const currentVersion = readResult.records[0].get('version');
    
    // Try to update with version check
    const updateResult = await session.run(
      `MATCH (n:Document {id: $docId})
       WHERE n.version = $expectedVersion
       SET n.content = $newContent,
           n.version = n.version + 1
       RETURN n.version AS newVersion`,
      {
        docId,
        expectedVersion: currentVersion,
        newContent
      }
    );
    
    if (updateResult.records.length === 0) {
      throw new Error('Concurrent modification detected. Please retry.');
    }
    
    return updateResult.records[0].get('newVersion');
    
  } finally {
    await session.close();
  }
}
```

### Timestamp-Based Concurrency

```cypher
// Update only if not modified since read
MATCH (n:Document {id: 'doc123'})
WHERE n.lastModified = $readTimestamp
SET n.content = $newContent,
    n.lastModified = timestamp()
RETURN n.lastModified

// If no result, document was modified by another transaction
```

---

## Transaction Functions (Neo4j 4.0+)

### Managed Transactions

Automatic retry and error handling:

```javascript
// Node.js driver
const session = driver.session();

try {
  const result = await session.executeWrite(async tx => {
    // All operations in this function are in one transaction
    const result1 = await tx.run(
      'MATCH (a:Person {id: $id}) SET a.visited = true RETURN a',
      { id: 123 }
    );
    
    const result2 = await tx.run(
      'MATCH (a:Person {id: $id})-[:KNOWS]->(friend) RETURN friend',
      { id: 123 }
    );
    
    return { person: result1.records[0], friends: result2.records };
  });
  
  // Transaction automatically committed
  
} catch (error) {
  // Transaction automatically rolled back
  console.error('Transaction failed:', error);
  
} finally {
  await session.close();
}
```

### Read Transactions

Optimize for read-only operations:

```javascript
const result = await session.executeRead(async tx => {
  const result = await tx.run(
    'MATCH (p:Person)-[:KNOWS]->(friend) RETURN p.name, collect(friend.name) AS friends'
  );
  return result.records;
});

// Read transactions can be executed on read replicas
// Better performance for read-heavy workloads
```

---

## Concurrent Operations Performance

### Batching Updates

Reduce transaction overhead:

```cypher
// BAD: Many small transactions
UNWIND $users AS user
MATCH (n:Person {id: user.id})
SET n.lastLogin = timestamp()
// Each in separate transaction

// GOOD: One transaction for batch
UNWIND $users AS user
MATCH (n:Person {id: user.id})
SET n.lastLogin = timestamp()
// All updates in one transaction
```

### Parallel Updates

Use `CALL {} IN TRANSACTIONS` for parallel processing:

```cypher
// Process in batches with controlled concurrency
MATCH (n:Person)
WHERE n.needsUpdate = true
CALL {
  WITH n
  SET n.processed = true,
      n.processedAt = timestamp()
} IN TRANSACTIONS OF 1000 ROWS

// Commits every 1000 rows
// Allows concurrent access to other nodes
```

---

## Lock Contention Strategies

### Strategy 1: Sharding Hot Nodes

Distribute load across multiple nodes:

```cypher
// Instead of one counter node
CREATE (n:Counter {id: 'global', count: 0})

// Create sharded counters
UNWIND range(0, 9) AS shard
CREATE (n:Counter {id: 'global', shard: shard, count: 0})

// Increment random shard
MATCH (n:Counter {id: 'global', shard: toInteger(rand() * 10)})
SET n.count = n.count + 1

// Get total count
MATCH (n:Counter {id: 'global'})
RETURN sum(n.count) AS totalCount
```

### Strategy 2: Queue Pattern

Avoid contention on central nodes:

```cypher
// Instead of updating central node
MATCH (queue:Queue) SET queue.pending = queue.pending + 1

// Create individual queue items
CREATE (item:QueueItem {
  status: 'pending',
  createdAt: timestamp()
})

// Workers claim items
MATCH (item:QueueItem {status: 'pending'})
WITH item LIMIT 1
SET item.status = 'processing',
    item.workerId = $workerId
RETURN item
```

### Strategy 3: Eventual Consistency

Use eventual consistency for less critical data:

```cypher
// Don't update view count synchronously
// Instead, buffer view events
CREATE (e:ViewEvent {
  pageId: $pageId,
  userId: $userId,
  timestamp: timestamp()
})

// Aggregate periodically (separate process)
MATCH (e:ViewEvent)
WHERE e.timestamp < timestamp() - 60000 // Older than 1 minute
WITH e.pageId AS pageId, count(*) AS viewCount
MATCH (p:Page {id: pageId})
SET p.viewCount = coalesce(p.viewCount, 0) + viewCount
WITH pageId, viewCount
MATCH (e:ViewEvent {pageId: pageId})
WHERE e.timestamp < timestamp() - 60000
DELETE e
```

---

## Monitoring Concurrency

### View Active Transactions

```cypher
// Show running transactions
CALL dbms.listTransactions()
YIELD transactionId, username, currentQuery, status, startTime
RETURN *
```

### Transaction Statistics

```cypher
// Get transaction metrics
CALL dbms.queryJmx('org.neo4j:instance=kernel#0,name=Transactions')
YIELD attributes
RETURN attributes
```

### Find Long-Running Transactions

```cypher
CALL dbms.listTransactions()
YIELD transactionId, startTime, currentQuery
WHERE datetime() - startTime > duration({seconds: 30})
RETURN transactionId, startTime, currentQuery
```

### Kill Transaction

```cypher
// Terminate long-running or deadlocked transaction
CALL dbms.terminateTransaction($transactionId)
```

---

## Best Practices

### 1. Keep Transactions Short

```cypher
// BAD: Long transaction
BEGIN
MATCH (n:Person)
WHERE n.needsProcessing = true
WITH collect(n) AS nodes
UNWIND nodes AS node
// ... complex processing for each node ...
SET node.processed = true
COMMIT

// GOOD: Short transaction batches
MATCH (n:Person)
WHERE n.needsProcessing = true
CALL {
  WITH n
  SET n.processed = true
} IN TRANSACTIONS OF 100 ROWS
```

### 2. Order Operations Consistently

```cypher
// Always access nodes in same order
MATCH (a:Person {id: $id1}), (b:Person {id: $id2})
WHERE a.id < b.id  // Ensure consistent order
CREATE (a)-[:KNOWS]->(b)
```

### 3. Use Appropriate Transaction Types

```javascript
// Read-only query
await session.executeRead(tx => {
  return tx.run('MATCH (n:Person) RETURN n LIMIT 10');
});

// Write query
await session.executeWrite(tx => {
  return tx.run('CREATE (n:Person {name: $name})', { name: 'Alice' });
});
```

### 4. Handle Transient Errors

```javascript
async function withRetry(operation, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      const isTransient = error.code && error.code.startsWith('Neo.TransientError');
      
      if (isTransient && attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 100;
        await sleep(delay);
        continue;
      }
      throw error;
    }
  }
}
```

### 5. Use Connection Pooling

```javascript
const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('neo4j', 'password'),
  {
    maxConnectionPoolSize: 50,
    connectionAcquisitionTimeout: 60000,
    maxTransactionRetryTime: 30000
  }
);
```

---

## Concurrency Patterns

### Pattern 1: Distributed Counter

```cypher
// Create sharded counter for high concurrency
MERGE (c:Counter {name: 'page_views'})
WITH c
UNWIND range(0, 9) AS shard
MERGE (s:CounterShard {counter: 'page_views', shard: shard})
ON CREATE SET s.count = 0

// Increment (low contention)
MATCH (s:CounterShard {
  counter: 'page_views',
  shard: toInteger(rand() * 10)
})
SET s.count = s.count + 1

// Read total
MATCH (s:CounterShard {counter: 'page_views'})
RETURN sum(s.count) AS total
```

### Pattern 2: Work Queue

```cypher
// Add work item
CREATE (w:WorkItem {
  id: randomUUID(),
  task: 'send_email',
  status: 'pending',
  createdAt: timestamp()
})

// Worker claims item (atomic)
MATCH (w:WorkItem {status: 'pending'})
WITH w ORDER BY w.createdAt LIMIT 1
SET w.status = 'processing',
    w.workerId = $workerId,
    w.startedAt = timestamp()
RETURN w

// Complete work
MATCH (w:WorkItem {id: $workId, workerId: $workerId})
SET w.status = 'completed',
    w.completedAt = timestamp()
```

### Pattern 3: Rate Limiting

```cypher
// Track requests in sliding window
MATCH (u:User {id: $userId})
MERGE (u)-[:HAS_RATE_LIMIT]->(rl:RateLimit {window: $currentMinute})
ON CREATE SET rl.count = 0
SET rl.count = rl.count + 1

// Check if over limit
WITH rl
WHERE rl.count > $maxRequests
RETURN false AS allowed

// Clean old windows
MATCH (rl:RateLimit)
WHERE rl.window < $currentMinute - 5
DELETE rl
```

---

## Performance Tuning

### 1. Index for Lock Reduction

```cypher
// Create indexes to speed up lock acquisition
CREATE INDEX person_id FOR (n:Person) ON (n.id)
CREATE INDEX document_version FOR (n:Document) ON (n.id, n.version)
```

### 2. Analyze Query Plans

```cypher
// Check if queries acquire unnecessary locks
PROFILE
MATCH (n:Person {id: $id})
SET n.lastAccessed = timestamp()
RETURN n
```

### 3. Configure Transaction Timeouts

```
// neo4j.conf
dbms.transaction.timeout=30s
dbms.lock.acquisition.timeout=15s
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Neo4j Concurrency Control
