# MongoDB - Transactions

## Overview

MongoDB provides ACID (Atomicity, Consistency, Isolation, Durability) transactions for multi-document operations. Transactions ensure data consistency across multiple documents and collections.

**Available since**: MongoDB 4.0 (replica sets), MongoDB 4.2 (sharded clusters)

---

## When to Use Transactions

### Use Transactions When:

- **Financial operations**: Bank transfers, payments
- **Multi-document updates**: Need atomic updates across documents
- **Complex business logic**: Requires all-or-nothing execution
- **Data consistency**: Critical that related data remains synchronized

### Avoid Transactions When:

- **Single document operations**: Already atomic
- **High throughput requirements**: Transactions have overhead
- **Simple operations**: Atomic operators like `$inc` are sufficient
- **Long-running operations**: Keep transactions short

---

## Basic Transaction Syntax

### Simple Transaction Example

```javascript
const session = client.startSession();

try {
  session.startTransaction();
  
  const db = client.db("mydb");
  const accounts = db.collection("accounts");
  
  // Debit from account A
  await accounts.updateOne(
    { accountId: "A" },
    { $inc: { balance: -100 } },
    { session }
  );
  
  // Credit to account B
  await accounts.updateOne(
    { accountId: "B" },
    { $inc: { balance: 100 } },
    { session }
  );
  
  // Commit transaction
  await session.commitTransaction();
  console.log("Transaction committed successfully");
  
} catch (error) {
  // Abort transaction on error
  await session.abortTransaction();
  console.error("Transaction aborted:", error);
  throw error;
  
} finally {
  // Always end session
  await session.endSession();
}
```

### With mongosh (MongoDB Shell)

```javascript
const session = db.getMongo().startSession();

session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority" }
});

try {
  const accountsCol = session.getDatabase("bank").accounts;
  
  accountsCol.updateOne(
    { accountId: "A" },
    { $inc: { balance: -100 } },
    { session: session }
  );
  
  accountsCol.updateOne(
    { accountId: "B" },
    { $inc: { balance: 100 } },
    { session: session }
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

## Transaction Options

### Read and Write Concerns

```javascript
session.startTransaction({
  readConcern: { level: "snapshot" },      // Snapshot isolation
  writeConcern: { w: "majority" },         // Write to majority
  readPreference: "primary"                // Read from primary
});
```

**Read Concern Levels**:
- `local`: Default, reads latest data
- `majority`: Reads majority-committed data
- `snapshot`: Consistent snapshot (transactions only)

**Write Concern Options**:
- `w: 1`: Acknowledge from primary only
- `w: "majority"`: Acknowledge from majority of replicas
- `j: true`: Write to journal

### Timeout

```javascript
// Set transaction timeout (default: 60 seconds)
session.startTransaction({
  maxCommitTimeMS: 30000  // 30 seconds
});
```

---

## Transaction Lifecycle

### 1. Start Transaction

```javascript
const session = client.startSession();
session.startTransaction(options);
```

### 2. Execute Operations

All operations must pass the session:

```javascript
// CORRECT: Pass session to each operation
await collection.insertOne(doc, { session });
await collection.updateOne(filter, update, { session });
await collection.deleteOne(filter, { session });

// INCORRECT: Missing session (won't be part of transaction)
await collection.insertOne(doc);  // Not in transaction!
```

### 3. Commit or Abort

```javascript
// Commit - make changes permanent
await session.commitTransaction();

// Abort - roll back all changes
await session.abortTransaction();
```

### 4. End Session

```javascript
// Always end session to free resources
await session.endSession();
```

---

## Complete Examples

### Example 1: Bank Transfer

```javascript
async function transferMoney(fromAccount, toAccount, amount) {
  const session = client.startSession();
  
  try {
    session.startTransaction({
      readConcern: { level: "snapshot" },
      writeConcern: { w: "majority" }
    });
    
    const accounts = client.db("bank").collection("accounts");
    
    // Check source account balance
    const sourceAccount = await accounts.findOne(
      { accountId: fromAccount },
      { session }
    );
    
    if (!sourceAccount || sourceAccount.balance < amount) {
      throw new Error("Insufficient funds");
    }
    
    // Debit from source
    await accounts.updateOne(
      { accountId: fromAccount },
      { 
        $inc: { balance: -amount },
        $push: { 
          transactions: {
            type: "debit",
            amount: amount,
            to: toAccount,
            timestamp: new Date()
          }
        }
      },
      { session }
    );
    
    // Credit to destination
    await accounts.updateOne(
      { accountId: toAccount },
      { 
        $inc: { balance: amount },
        $push: {
          transactions: {
            type: "credit",
            amount: amount,
            from: fromAccount,
            timestamp: new Date()
          }
        }
      },
      { session }
    );
    
    // Record in transaction log
    const transactionLog = client.db("bank").collection("transactionLog");
    await transactionLog.insertOne({
      from: fromAccount,
      to: toAccount,
      amount: amount,
      timestamp: new Date(),
      status: "completed"
    }, { session });
    
    await session.commitTransaction();
    return { success: true, message: "Transfer completed" };
    
  } catch (error) {
    await session.abortTransaction();
    console.error("Transfer failed:", error.message);
    return { success: false, error: error.message };
    
  } finally {
    await session.endSession();
  }
}

// Usage
await transferMoney("ACC001", "ACC002", 500);
```

### Example 2: Order Processing

```javascript
async function createOrder(customerId, items) {
  const session = client.startSession();
  
  try {
    session.startTransaction();
    
    const db = client.db("ecommerce");
    const orders = db.collection("orders");
    const inventory = db.collection("inventory");
    const customers = db.collection("customers");
    
    // 1. Check and reserve inventory
    for (const item of items) {
      const product = await inventory.findOne(
        { productId: item.productId },
        { session }
      );
      
      if (!product || product.quantity < item.quantity) {
        throw new Error(`Insufficient inventory for ${item.productId}`);
      }
      
      // Decrement inventory
      await inventory.updateOne(
        { productId: item.productId },
        { 
          $inc: { quantity: -item.quantity },
          $push: { 
            reservations: {
              quantity: item.quantity,
              timestamp: new Date()
            }
          }
        },
        { session }
      );
    }
    
    // 2. Create order
    const order = {
      orderId: generateOrderId(),
      customerId: customerId,
      items: items,
      totalAmount: calculateTotal(items),
      status: "pending",
      createdAt: new Date()
    };
    
    await orders.insertOne(order, { session });
    
    // 3. Update customer order history
    await customers.updateOne(
      { customerId: customerId },
      { 
        $push: { orderHistory: order.orderId },
        $inc: { totalOrders: 1 }
      },
      { session }
    );
    
    await session.commitTransaction();
    return { success: true, orderId: order.orderId };
    
  } catch (error) {
    await session.abortTransaction();
    return { success: false, error: error.message };
    
  } finally {
    await session.endSession();
  }
}
```

### Example 3: User Registration with Profile

```javascript
async function registerUser(userData, profileData) {
  const session = client.startSession();
  
  try {
    session.startTransaction();
    
    const db = client.db("app");
    const users = db.collection("users");
    const profiles = db.collection("profiles");
    const counters = db.collection("counters");
    
    // Get next user ID
    const counter = await counters.findOneAndUpdate(
      { _id: "userId" },
      { $inc: { value: 1 } },
      { session, returnDocument: "after", upsert: true }
    );
    
    const userId = counter.value;
    
    // Create user account
    const user = {
      userId: userId,
      email: userData.email,
      passwordHash: userData.passwordHash,
      createdAt: new Date(),
      active: true
    };
    
    await users.insertOne(user, { session });
    
    // Create user profile
    const profile = {
      userId: userId,
      name: profileData.name,
      bio: profileData.bio,
      avatar: profileData.avatar,
      settings: {
        notifications: true,
        privacy: "public"
      }
    };
    
    await profiles.insertOne(profile, { session });
    
    await session.commitTransaction();
    return { success: true, userId: userId };
    
  } catch (error) {
    await session.abortTransaction();
    
    if (error.code === 11000) {
      return { success: false, error: "Email already exists" };
    }
    
    return { success: false, error: error.message };
    
  } finally {
    await session.endSession();
  }
}
```

---

## Error Handling and Retries

### Transient Transaction Errors

Some errors are transient and should be retried:

```javascript
async function runTransactionWithRetry(txnFunc, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await txnFunc();
    } catch (error) {
      if (error.hasErrorLabel('TransientTransactionError')) {
        console.log(`TransientTransactionError, attempt ${attempt}/${maxRetries}`);
        if (attempt < maxRetries) {
          await sleep(100 * attempt);  // Exponential backoff
          continue;
        }
      }
      throw error;
    }
  }
}

// Usage
await runTransactionWithRetry(async () => {
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

### Unknown Commit Result

Handle uncertain commit results:

```javascript
async function commitWithRetry(session, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await session.commitTransaction();
      console.log("Transaction committed");
      return;
    } catch (error) {
      if (error.hasErrorLabel('UnknownTransactionCommitResult')) {
        console.log(`UnknownTransactionCommitResult, retry ${attempt}`);
        if (attempt < maxRetries) {
          continue;  // Retry commit
        }
      }
      throw error;
    }
  }
}
```

### Complete Retry Logic

```javascript
async function runTransactionWithFullRetry(txnFunc) {
  while (true) {
    const session = client.startSession();
    
    try {
      session.startTransaction({
        readConcern: { level: "snapshot" },
        writeConcern: { w: "majority" }
      });
      
      await txnFunc(session);
      
      // Try to commit
      while (true) {
        try {
          await session.commitTransaction();
          console.log("Transaction committed successfully");
          return;
        } catch (error) {
          if (error.hasErrorLabel('UnknownTransactionCommitResult')) {
            console.log("Retrying commit...");
            continue;
          }
          throw error;
        }
      }
      
    } catch (error) {
      await session.abortTransaction();
      
      if (error.hasErrorLabel('TransientTransactionError')) {
        console.log("Retrying entire transaction...");
        continue;
      }
      
      throw error;
      
    } finally {
      await session.endSession();
    }
  }
}

// Usage
await runTransactionWithFullRetry(async (session) => {
  const accounts = client.db("bank").collection("accounts");
  
  await accounts.updateOne(
    { accountId: "A" },
    { $inc: { balance: -100 } },
    { session }
  );
  
  await accounts.updateOne(
    { accountId: "B" },
    { $inc: { balance: 100 } },
    { session }
  );
});
```

---

## Transaction Limitations

### 1. Operation Restrictions

Not allowed in transactions:
- Creating collections
- Creating indexes
- Creating/dropping databases
- Operations affecting multiple databases (sharded clusters)

```javascript
// WRONG: Cannot create collection in transaction
session.startTransaction();
await db.createCollection("newCollection", { session });  // Error!

// CORRECT: Create collection before transaction
await db.createCollection("newCollection");
session.startTransaction();
await db.collection("newCollection").insertOne(doc, { session });
```

### 2. Size Limits

- Total transaction size: 16MB
- Single document size: 16MB
- Transaction duration: 60 seconds (default, configurable)

### 3. Read Operations

Transactions see their own writes:

```javascript
session.startTransaction();

// Insert document
await collection.insertOne({ _id: 1, value: "A" }, { session });

// Can read own write
const doc = await collection.findOne({ _id: 1 }, { session });
console.log(doc);  // { _id: 1, value: "A" }

// Outside transaction cannot see it yet
const docOutside = await collection.findOne({ _id: 1 });
console.log(docOutside);  // null

await session.commitTransaction();
```

---

## Best Practices

### 1. Keep Transactions Short

```javascript
// BAD: Long-running transaction
session.startTransaction();
const data = await externalAPICall();  // Slow!
await collection.insertOne(data, { session });
await session.commitTransaction();

// GOOD: Prepare data first
const data = await externalAPICall();
session.startTransaction();
await collection.insertOne(data, { session });
await session.commitTransaction();
```

### 2. Read Operations at Start

```javascript
// GOOD: Read data at transaction start
session.startTransaction();

const account = await accounts.findOne({ id: "A" }, { session });
if (account.balance >= 100) {
  await accounts.updateOne(
    { id: "A" },
    { $inc: { balance: -100 } },
    { session }
  );
}

await session.commitTransaction();
```

### 3. Use Appropriate Concerns

```javascript
// Critical financial data
session.startTransaction({
  readConcern: { level: "snapshot" },
  writeConcern: { w: "majority", j: true }
});

// Less critical data
session.startTransaction({
  readConcern: { level: "local" },
  writeConcern: { w: 1 }
});
```

### 4. Handle Errors Properly

```javascript
try {
  session.startTransaction();
  // ... operations
  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  
  // Log error details
  console.error("Transaction failed:", {
    message: error.message,
    code: error.code,
    labels: error.errorLabels
  });
  
  // Handle specific errors
  if (error.code === 11000) {
    // Duplicate key
  } else if (error.hasErrorLabel('TransientTransactionError')) {
    // Retry
  }
  
  throw error;
} finally {
  await session.endSession();
}
```

### 5. Validate Before Transaction

```javascript
// Validate business logic before transaction
async function processPayment(orderId, amount) {
  // Validate first
  if (amount <= 0) {
    throw new Error("Invalid amount");
  }
  
  const order = await orders.findOne({ orderId });
  if (!order) {
    throw new Error("Order not found");
  }
  
  if (order.status !== "pending") {
    throw new Error("Order already processed");
  }
  
  // Now start transaction
  const session = client.startSession();
  try {
    session.startTransaction();
    // ... transaction operations
    await session.commitTransaction();
  } finally {
    await session.endSession();
  }
}
```

---

## Alternatives to Transactions

### 1. Embedded Documents

```javascript
// Instead of transaction across documents
{
  orderId: "ORD123",
  customer: { id: "C001", name: "Alice" },
  items: [
    { productId: "P001", quantity: 2, price: 10 },
    { productId: "P002", quantity: 1, price: 25 }
  ],
  totalAmount: 45
}
```

### 2. Atomic Operators

```javascript
// Single document update (no transaction needed)
await collection.updateOne(
  { _id: orderId },
  {
    $inc: { totalAmount: 100 },
    $push: { items: newItem },
    $set: { lastUpdated: new Date() }
  }
);
```

### 3. Two-Phase Commits (Manual)

```javascript
// Phase 1: Prepare
await account1.updateOne(
  { _id: "A" },
  { 
    $set: { pendingTransaction: txId, state: "pending" },
    $inc: { balance: -100 }
  }
);

await account2.updateOne(
  { _id: "B" },
  { 
    $set: { pendingTransaction: txId, state: "pending" },
    $inc: { balance: 100 }
  }
);

// Phase 2: Commit
await account1.updateOne(
  { _id: "A", pendingTransaction: txId },
  { $set: { state: "committed" }, $unset: { pendingTransaction: "" } }
);

await account2.updateOne(
  { _id: "B", pendingTransaction: txId },
  { $set: { state: "committed" }, $unset: { pendingTransaction: "" } }
);
```

---

## Performance Considerations

### Transaction Overhead

Transactions have performance costs:
- Snapshot isolation overhead
- Write concern replication
- Lock acquisition
- Commit coordination

### Optimization Tips

1. **Batch operations**:
```javascript
// Instead of multiple transactions
for (const doc of docs) {
  await singleDocTransaction(doc);
}

// One transaction for batch
session.startTransaction();
for (const doc of docs) {
  await collection.insertOne(doc, { session });
}
await session.commitTransaction();
```

2. **Read your writes**:
```javascript
// Read once, use multiple times
session.startTransaction();
const account = await accounts.findOne({ id }, { session });

if (account.balance >= 100) {
  // Multiple operations using cached data
  await accounts.updateOne({ id }, update1, { session });
  await accounts.updateOne({ id }, update2, { session });
}
await session.commitTransaction();
```

3. **Minimize transaction scope**:
```javascript
// Prepare data outside transaction
const preparedData = await prepareData();

// Short transaction
session.startTransaction();
await collection.insertMany(preparedData, { session });
await session.commitTransaction();
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: MongoDB Transactions
