# MongoDB - Concurrency Control

## Overview

MongoDB uses a combination of locking mechanisms and optimistic concurrency control to handle concurrent access to data. Understanding these mechanisms is crucial for building high-performance applications.

---

## Locking Mechanisms

### Lock Granularity

MongoDB uses different levels of locking:

1. **Global Locks**: Affect the entire MongoDB instance (rare)
2. **Database Locks**: Affect a single database
3. **Collection Locks**: Affect a single collection
4. **Document Locks**: Most granular level (WiredTiger storage engine)

### WiredTiger Storage Engine Locking

WiredTiger (default since MongoDB 3.2) provides:
- **Document-level concurrency control**
- **Optimistic concurrency using MVCC** (Multi-Version Concurrency Control)
- Multiple clients can modify different documents simultaneously
- Lock-free reads (no read locks needed)

---

## Read and Write Concerns

### Write Concern

Controls acknowledgment of write operations:

```javascript
// Write with acknowledgment from majority
db.users.insertOne(
  { name: "Alice", email: "alice@example.com" },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
);

// Write concern options:
// w: 1           - Acknowledgment from primary only (default)
// w: "majority"  - Acknowledgment from majority of replica set
// w: 0           - No acknowledgment (fire and forget)
// j: true        - Write to journal before acknowledgment
// wtimeout       - Time limit for write concern
```

**Common Write Concern Levels**:

```javascript
// Fast but less durable
{ w: 1 }

// Balanced (recommended for most cases)
{ w: "majority", j: true }

// Maximum durability (slower)
{ w: "majority", j: true, wtimeout: 5000 }
```

### Read Concern

Controls consistency of read operations:

```javascript
// Read with specific read concern
db.users.find(
  { city: "Boston" }
).readConcern("majority");
```

**Read Concern Levels**:

1. **local** (default):
   - Returns most recent data
   - May be rolled back
   - Fastest reads

2. **available**:
   - Similar to local
   - For sharded clusters
   - May return orphaned documents

3. **majority**:
   - Returns data acknowledged by majority
   - Cannot be rolled back
   - Slightly slower

4. **linearizable**:
   - Strongest consistency
   - Reads reflect all successful writes
   - Only for single document reads
   - Slowest

5. **snapshot** (transactions only):
   - Consistent snapshot across operations
   - Used within transactions

**Examples**:

```javascript
// Read latest data (may not be durable)
db.orders.find().readConcern("local");

// Read only majority-committed data
db.orders.find().readConcern("majority");

// Linearizable read (single document)
db.inventory.findOne(
  { product: "widget" },
  { readConcern: { level: "linearizable" } }
);
```

---

## Isolation Levels

### Read Phenomena

MongoDB prevents certain read phenomena:

1. **Dirty Reads**: Reading uncommitted data
   - **Prevented** with readConcern: "majority"
   - **Possible** with readConcern: "local"

2. **Non-Repeatable Reads**: Same query returns different results
   - **Prevented** within transactions (snapshot isolation)
   - **Possible** without transactions

3. **Phantom Reads**: New documents appear in range queries
   - **Prevented** within transactions
   - **Possible** without transactions

### Snapshot Isolation

Transactions use snapshot isolation:

```javascript
const session = db.getMongo().startSession();
session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" }
});

try {
  const accountsCol = session.getDatabase("bank").accounts;
  
  // All reads see same snapshot
  const account1 = accountsCol.findOne({ accountId: "A" }, { session });
  const account2 = accountsCol.findOne({ accountId: "B" }, { session });
  
  // Modifications
  accountsCol.updateOne(
    { accountId: "A" },
    { $inc: { balance: -100 } },
    { session }
  );
  
  accountsCol.updateOne(
    { accountId: "B" },
    { $inc: { balance: 100 } },
    { session }
  );
  
  session.commitTransaction();
} catch (error) {
  session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```

---

## Optimistic Concurrency Control

### Version Field Pattern

Implement optimistic locking with version numbers:

```javascript
// Document with version
{
  _id: ObjectId("..."),
  productId: "P123",
  quantity: 100,
  version: 1
}

// Update with version check
function updateInventory(productId, quantityChange) {
  const product = db.inventory.findOne({ productId: productId });
  
  const result = db.inventory.updateOne(
    { 
      productId: productId,
      version: product.version  // Only update if version matches
    },
    {
      $inc: { quantity: quantityChange },
      $set: { version: product.version + 1 }  // Increment version
    }
  );
  
  if (result.matchedCount === 0) {
    // Version mismatch - someone else modified it
    throw new Error("Concurrent modification detected. Please retry.");
  }
  
  return result;
}
```

### Timestamp Pattern

Use timestamps for conflict detection:

```javascript
// Document with timestamp
{
  _id: ObjectId("..."),
  data: "value",
  lastModified: ISODate("2024-03-01T10:30:00Z")
}

// Update only if not modified since read
const doc = db.collection.findOne({ _id: docId });
const originalTimestamp = doc.lastModified;

const result = db.collection.updateOne(
  { 
    _id: docId,
    lastModified: originalTimestamp  // Ensure no changes since read
  },
  {
    $set: { 
      data: "new value",
      lastModified: new Date()
    }
  }
);

if (result.matchedCount === 0) {
  throw new Error("Document was modified by another process");
}
```

---

## Atomic Operations

### Single Document Atomicity

All single document operations are atomic:

```javascript
// Atomic increment
db.counters.updateOne(
  { _id: "page_views" },
  { $inc: { count: 1 } }
);

// Atomic push to array
db.posts.updateOne(
  { _id: postId },
  { $push: { comments: newComment } }
);

// Atomic array operations
db.inventory.updateOne(
  { productId: "P123" },
  { 
    $inc: { quantity: -1 },
    $push: { 
      transactions: {
        type: "sale",
        quantity: 1,
        timestamp: new Date()
      }
    }
  }
);
```

### findAndModify

Atomically find and modify a document:

```javascript
// Find and update atomically
const result = db.queue.findAndModify({
  query: { status: "pending" },
  sort: { priority: -1, created: 1 },
  update: { $set: { status: "processing", worker: "worker-1" } },
  new: true  // Return modified document
});

// Get and increment counter atomically
const counter = db.counters.findAndModify({
  query: { _id: "order_id" },
  update: { $inc: { value: 1 } },
  new: true,
  upsert: true
});
```

---

## Handling Concurrent Writes

### Write Conflicts

When multiple clients update the same document:

```javascript
// Scenario: Two clients try to update inventory
// Client 1:
db.inventory.updateOne(
  { productId: "P123" },
  { $inc: { quantity: -5 } }
);

// Client 2 (concurrent):
db.inventory.updateOne(
  { productId: "P123" },
  { $inc: { quantity: -3 } }
);

// Both succeed - increments are atomic and combined
// Final result: quantity decreased by 8
```

### Preventing Negative Inventory

Use conditional updates:

```javascript
// Ensure quantity doesn't go negative
const result = db.inventory.updateOne(
  { 
    productId: "P123",
    quantity: { $gte: 5 }  // Only if enough stock
  },
  { $inc: { quantity: -5 } }
);

if (result.matchedCount === 0) {
  throw new Error("Insufficient inventory");
}
```

### Retry Logic

Implement retry for transient errors:

```javascript
async function updateWithRetry(operation, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (error.hasErrorLabel('TransientTransactionError') && attempt < maxRetries) {
        console.log(`Retry attempt ${attempt}`);
        await sleep(100 * attempt);  // Exponential backoff
        continue;
      }
      throw error;
    }
  }
}

// Usage
await updateWithRetry(async () => {
  const session = client.startSession();
  try {
    session.startTransaction();
    // ... transaction operations
    await session.commitTransaction();
  } finally {
    await session.endSession();
  }
});
```

---

## Multi-Document Transactions

### Transaction Isolation

Transactions provide snapshot isolation:

```javascript
const session = client.startSession();

session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" },
  readPreference: "primary"
});

try {
  const accounts = session.getDatabase("bank").accounts;
  
  // All operations see consistent snapshot
  const alice = await accounts.findOne({ name: "Alice" }, { session });
  const bob = await accounts.findOne({ name: "Bob" }, { session });
  
  // Validate business logic
  if (alice.balance < 100) {
    throw new Error("Insufficient funds");
  }
  
  // Execute transfer
  await accounts.updateOne(
    { name: "Alice" },
    { $inc: { balance: -100 } },
    { session }
  );
  
  await accounts.updateOne(
    { name: "Bob" },
    { $inc: { balance: 100 } },
    { session }
  );
  
  await session.commitTransaction();
  console.log("Transfer completed");
  
} catch (error) {
  await session.abortTransaction();
  console.error("Transaction failed:", error);
  throw error;
} finally {
  await session.endSession();
}
```

### Write Conflicts in Transactions

Handle write conflicts:

```javascript
async function runTransactionWithRetry(txnFunc) {
  while (true) {
    try {
      await txnFunc();
      break;
    } catch (error) {
      if (error.hasErrorLabel('TransientTransactionError')) {
        console.log("TransientTransactionError, retrying...");
        continue;
      } else if (error.hasErrorLabel('UnknownTransactionCommitResult')) {
        console.log("UnknownTransactionCommitResult, retrying commit...");
        continue;
      } else {
        throw error;
      }
    }
  }
}
```

---

## Performance Considerations

### Lock Contention

Minimize lock contention:

1. **Keep transactions short**:
```javascript
// Bad: Long-running transaction
session.startTransaction();
await heavyComputation();  // Avoid!
await db.collection.updateOne(..., { session });
await session.commitTransaction();

// Good: Compute outside transaction
const result = await heavyComputation();
session.startTransaction();
await db.collection.updateOne(..., { session });
await session.commitTransaction();
```

2. **Batch operations**:
```javascript
// Instead of many single updates
for (const doc of documents) {
  await db.collection.updateOne({ _id: doc._id }, { $set: doc.data });
}

// Use bulkWrite
await db.collection.bulkWrite(
  documents.map(doc => ({
    updateOne: {
      filter: { _id: doc._id },
      update: { $set: doc.data }
    }
  }))
);
```

3. **Update specific fields**:
```javascript
// Bad: Replace entire document
db.users.replaceOne({ _id: userId }, newUserDoc);

// Good: Update only changed fields
db.users.updateOne({ _id: userId }, { $set: { email: newEmail } });
```

### Index Selection

Proper indexing reduces contention:

```javascript
// Create index to speed up queries
db.orders.createIndex({ customerId: 1, orderDate: -1 });

// With index, concurrent queries don't block
db.orders.find({ customerId: "C123" });  // Fast lookup
```

---

## Monitoring Concurrency

### Current Operations

View active operations:

```javascript
// Show current operations
db.currentOp();

// Show only active operations
db.currentOp({ active: true });

// Show operations waiting for locks
db.currentOp({ waitingForLock: true });

// Kill long-running operation
db.killOp(opId);
```

### Lock Statistics

Check locking stats:

```javascript
// Server status includes lock info
db.serverStatus().locks;

// Lock timing
db.serverStatus().globalLock;
```

### Profiling

Enable profiling to identify slow operations:

```javascript
// Enable profiling for slow queries (>100ms)
db.setProfilingLevel(1, { slowms: 100 });

// View profiled operations
db.system.profile.find().sort({ ts: -1 }).limit(10);

// Analyze specific query
db.system.profile.find({ 
  ns: "mydb.users",
  millis: { $gt: 100 }
}).sort({ millis: -1 });
```

---

## Best Practices

### 1. Use Appropriate Read/Write Concerns

```javascript
// For critical financial data
db.transactions.insertOne(
  doc,
  { writeConcern: { w: "majority", j: true } }
);

// For analytics queries (eventual consistency ok)
db.logs.find().readConcern("local");
```

### 2. Implement Application-Level Locking

For complex operations:

```javascript
async function acquireDistributedLock(lockId, ttl = 30000) {
  const result = await db.locks.updateOne(
    { 
      _id: lockId,
      $or: [
        { expiresAt: { $exists: false } },
        { expiresAt: { $lt: new Date() } }
      ]
    },
    { 
      $set: { 
        holder: processId,
        expiresAt: new Date(Date.now() + ttl)
      }
    },
    { upsert: true }
  );
  
  return result.modifiedCount > 0 || result.upsertedCount > 0;
}

async function releaseLock(lockId) {
  await db.locks.deleteOne({ 
    _id: lockId,
    holder: processId
  });
}
```

### 3. Handle Failures Gracefully

```javascript
async function robustUpdate() {
  const maxRetries = 3;
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const result = await db.collection.updateOne(
        filter,
        update,
        { writeConcern: { w: "majority" } }
      );
      return result;
    } catch (error) {
      lastError = error;
      if (error.code === 11000) {  // Duplicate key
        throw error;  // Don't retry
      }
      await sleep(Math.pow(2, i) * 100);  // Exponential backoff
    }
  }
  
  throw lastError;
}
```

### 4. Design for Concurrency

```javascript
// Good: Use atomic operators
db.posts.updateOne(
  { _id: postId },
  { 
    $inc: { views: 1 },
    $push: { viewHistory: { userId, timestamp: new Date() } }
  }
);

// Bad: Read-modify-write (race condition)
const post = await db.posts.findOne({ _id: postId });
post.views++;
await db.posts.replaceOne({ _id: postId }, post);
```

---

## Common Patterns

### Queue with Concurrency Control

```javascript
// Add task to queue
await db.queue.insertOne({
  task: "send_email",
  payload: { to: "user@example.com" },
  status: "pending",
  attempts: 0,
  createdAt: new Date()
});

// Worker gets task atomically
const task = await db.queue.findOneAndUpdate(
  { 
    status: "pending",
    attempts: { $lt: 3 }
  },
  { 
    $set: { 
      status: "processing",
      workerId: workerId,
      startedAt: new Date()
    },
    $inc: { attempts: 1 }
  },
  { 
    sort: { createdAt: 1 },
    returnDocument: "after"
  }
);

// Complete task
await db.queue.updateOne(
  { _id: task._id },
  { 
    $set: { 
      status: "completed",
      completedAt: new Date()
    }
  }
);
```

### Distributed Counter

```javascript
// Sharded counter for high concurrency
async function incrementCounter(counterId) {
  const shardId = Math.floor(Math.random() * 10);  // 10 shards
  
  await db.counterShards.updateOne(
    { 
      counterId: counterId,
      shard: shardId
    },
    { $inc: { count: 1 } },
    { upsert: true }
  );
}

// Get total count
async function getCount(counterId) {
  const result = await db.counterShards.aggregate([
    { $match: { counterId: counterId } },
    { $group: { _id: null, total: { $sum: "$count" } } }
  ]).toArray();
  
  return result[0]?.total || 0;
}
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: MongoDB Concurrency Control
