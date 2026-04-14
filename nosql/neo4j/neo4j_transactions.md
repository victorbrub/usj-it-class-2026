# Neo4j - Transactions

## Overview

Neo4j is a fully ACID-compliant database. Every read and write operation in Neo4j happens within a transaction. Understanding how to use transactions effectively is crucial for maintaining data consistency and building reliable graph applications.

---

## ACID Properties in Neo4j

### Atomicity
All operations in a transaction succeed or fail together:

```cypher
// All or nothing - both nodes created or neither
BEGIN
CREATE (a:Person {name: 'Alice'})
CREATE (b:Person {name: 'Bob'})
CREATE (a)-[:KNOWS]->(b)
COMMIT

// If any operation fails, entire transaction rolls back
```

### Consistency
Database constraints are enforced throughout:

```cypher
// Constraint ensures consistency
CREATE CONSTRAINT person_email IF NOT EXISTS
FOR (p:Person) REQUIRE p.email IS UNIQUE

// Transaction will fail if it violates constraint
BEGIN
CREATE (p:Person {email: 'alice@example.com'})
CREATE (p2:Person {email: 'alice@example.com'})  // Fails - duplicate email
COMMIT
```

### Isolation
Concurrent transactions don't interfere (Read Committed isolation):

```cypher
// Transaction 1
BEGIN
MATCH (n:Person {name: 'Alice'})
SET n.age = 31
COMMIT

// Transaction 2 (concurrent) sees only committed data
BEGIN
MATCH (n:Person {name: 'Alice'})
RETURN n.age
// Returns old age until Transaction 1 commits
```

### Durability
Committed changes persist even after system failure:

```cypher
BEGIN
CREATE (n:ImportantData {value: 'critical'})
COMMIT
// Data is written to transaction log
// Survives database restarts or crashes
```

---

## Transaction Basics

### Explicit Transactions

```cypher
// Start transaction
BEGIN

// Perform operations
MATCH (a:Person {name: 'Alice'})
CREATE (b:Person {name: 'Bob'})
CREATE (a)-[:KNOWS]->(b)
SET a.friendCount = a.friendCount + 1

// Commit changes
COMMIT
```

### Rollback Transaction

```cypher
BEGIN
MATCH (a:Account {id: 'A123'})
SET a.balance = a.balance - 100

MATCH (b:Account {id: 'B456'})
SET b.balance = b.balance + 100

// Something went wrong, undo everything
ROLLBACK
```

### Auto-Commit Transactions

```cypher
// Each statement runs in its own transaction
CREATE (n:Person {name: 'Alice'})
// Automatically committed after execution

MATCH (n:Person) RETURN n
// Separate transaction, automatically committed
```

---

## Using Transactions with Drivers

### Node.js Driver

**Managed Transactions (Recommended):**

```javascript
const neo4j = require('neo4j-driver');

const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('neo4j', 'password')
);

async function transferFunds(fromId, toId, amount) {
  const session = driver.session();
  
  try {
    const result = await session.executeWrite(async tx => {
      // Deduct from source account
      const debitResult = await tx.run(
        `MATCH (a:Account {id: $fromId})
         WHERE a.balance >= $amount
         SET a.balance = a.balance - $amount
         RETURN a.balance AS newBalance`,
        { fromId, amount }
      );
      
      if (debitResult.records.length === 0) {
        throw new Error('Insufficient funds or account not found');
      }
      
      // Add to destination account
      const creditResult = await tx.run(
        `MATCH (a:Account {id: $toId})
         SET a.balance = a.balance + $amount
         RETURN a.balance AS newBalance`,
        { toId, amount }
      );
      
      if (creditResult.records.length === 0) {
        throw new Error('Destination account not found');
      }
      
      return {
        fromBalance: debitResult.records[0].get('newBalance'),
        toBalance: creditResult.records[0].get('newBalance')
      };
    });
    
    console.log('Transfer successful:', result);
    return result;
    
  } catch (error) {
    console.error('Transfer failed:', error.message);
    throw error;
    
  } finally {
    await session.close();
  }
}

// Usage
transferFunds('A123', 'B456', 100);
```

**Explicit Transaction Control:**

```javascript
async function complexOperation() {
  const session = driver.session();
  const tx = session.beginTransaction();
  
  try {
    // Operation 1
    await tx.run(
      'CREATE (n:Person {name: $name})',
      { name: 'Alice' }
    );
    
    // Operation 2
    await tx.run(
      'MATCH (n:Person {name: $name}) SET n.age = $age',
      { name: 'Alice', age: 30 }
    );
    
    // Commit all operations
    await tx.commit();
    console.log('Transaction committed successfully');
    
  } catch (error) {
    // Rollback on error
    await tx.rollback();
    console.error('Transaction rolled back:', error);
    throw error;
    
  } finally {
    await session.close();
  }
}
```

### Python Driver

```python
from neo4j import GraphDatabase

driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "password")
)

def transfer_funds(tx, from_id, to_id, amount):
    # Deduct from source
    result = tx.run("""
        MATCH (a:Account {id: $from_id})
        WHERE a.balance >= $amount
        SET a.balance = a.balance - $amount
        RETURN a.balance AS new_balance
        """,
        from_id=from_id, amount=amount
    )
    
    record = result.single()
    if not record:
        raise ValueError("Insufficient funds")
    
    # Add to destination
    tx.run("""
        MATCH (a:Account {id: $to_id})
        SET a.balance = a.balance + $amount
        """,
        to_id=to_id, amount=amount
    )
    
    return record["new_balance"]

# Execute transaction
with driver.session() as session:
    try:
        new_balance = session.execute_write(transfer_funds, "A123", "B456", 100)
        print(f"Transfer successful. New balance: {new_balance}")
    except Exception as e:
        print(f"Transfer failed: {e}")
```

### Java Driver

```java
import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

public class TransactionExample {
    public static void main(String[] args) {
        Driver driver = GraphDatabase.driver(
            "bolt://localhost:7687",
            AuthTokens.basic("neo4j", "password")
        );
        
        try (Session session = driver.session()) {
            String fromId = "A123";
            String toId = "B456";
            int amount = 100;
            
            session.executeWrite(tx -> {
                // Deduct from source
                Result debitResult = tx.run(
                    "MATCH (a:Account {id: $fromId}) " +
                    "WHERE a.balance >= $amount " +
                    "SET a.balance = a.balance - $amount " +
                    "RETURN a.balance AS newBalance",
                    parameters("fromId", fromId, "amount", amount)
                );
                
                if (!debitResult.hasNext()) {
                    throw new RuntimeException("Insufficient funds");
                }
                
                // Add to destination
                tx.run(
                    "MATCH (a:Account {id: $toId}) " +
                    "SET a.balance = a.balance + $amount",
                    parameters("toId", toId, "amount", amount)
                );
                
                return debitResult.single().get("newBalance").asInt();
            });
            
            System.out.println("Transfer successful");
            
        } catch (Exception e) {
            System.err.println("Transfer failed: " + e.getMessage());
        } finally {
            driver.close();
        }
    }
}
```

---

## Transaction Patterns

### Pattern 1: Create with Relationships

```cypher
BEGIN

// Create user
CREATE (u:User {
  id: randomUUID(),
  email: $email,
  name: $name,
  createdAt: timestamp()
})

// Create profile
CREATE (p:Profile {
  bio: $bio,
  avatar: $avatar
})

// Create relationship
CREATE (u)-[:HAS_PROFILE]->(p)

// Update counter
MATCH (s:Stats {type: 'users'})
SET s.totalCount = s.totalCount + 1

COMMIT
```

### Pattern 2: Conditional Updates

```cypher
BEGIN

// Try to reserve item
MATCH (i:Item {id: $itemId})
WHERE i.status = 'available'
SET i.status = 'reserved',
    i.reservedBy = $userId,
    i.reservedAt = timestamp()

// Check if update succeeded
WITH i
WHERE i IS NOT NULL

// Create reservation record
CREATE (r:Reservation {
  id: randomUUID(),
  itemId: $itemId,
  userId: $userId,
  createdAt: timestamp()
})

COMMIT
```

### Pattern 3: Batch Processing

```cypher
// Process in batches with explicit transaction control
UNWIND $batch AS item
MATCH (n:Product {id: item.id})
SET n.price = item.price,
    n.stock = item.stock,
    n.updatedAt: timestamp()

// Runs in single transaction
```

### Pattern 4: Graph Modifications

```cypher
BEGIN

// Remove old relationships
MATCH (u:User {id: $userId})-[r:MEMBER_OF]->(:Team)
DELETE r

// Create new relationships
UNWIND $teamIds AS teamId
MATCH (u:User {id: $userId}), (t:Team {id: teamId})
CREATE (u)-[:MEMBER_OF {joinedAt: timestamp()}]->(t)

// Update user's team count
MATCH (u:User {id: $userId})
SET u.teamCount = size($teamIds)

COMMIT
```

---

## Error Handling and Retries

### Handling Transient Errors

```javascript
async function executeWithRetry(session, operation, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation(session);
      
    } catch (error) {
      // Check if error is transient
      const isTransient = 
        error.code && 
        (error.code.startsWith('Neo.TransientError') ||
         error.code === 'Neo.ClientError.Transaction.LockClientStopped');
      
      const isLastAttempt = attempt === maxRetries - 1;
      
      if (isTransient && !isLastAttempt) {
        // Exponential backoff
        const delay = Math.pow(2, attempt) * 100;
        console.log(`Transient error, retrying in ${delay}ms...`);
        await sleep(delay);
        continue;
      }
      
      // Not transient or last attempt failed
      throw error;
    }
  }
}

// Usage
const result = await executeWithRetry(session, async (session) => {
  return await session.executeWrite(tx => {
    return tx.run(
      'MATCH (n:Counter) SET n.count = n.count + 1 RETURN n.count'
    );
  });
});
```

### Common Transaction Errors

**Deadlock Detection:**

```javascript
try {
  await session.executeWrite(tx => {
    // Transaction operations
  });
} catch (error) {
  if (error.code === 'Neo.TransientError.Transaction.DeadlockDetected') {
    console.log('Deadlock detected, retrying...');
    // Retry transaction
  }
}
```

**Lock Timeout:**

```javascript
try {
  await session.executeWrite(tx => {
    // Transaction operations
  });
} catch (error) {
  if (error.code === 'Neo.TransientError.Transaction.LockAcquisitionTimeout') {
    console.log('Lock timeout, retrying...');
    // Retry transaction
  }
}
```

**Constraint Violation:**

```javascript
try {
  await session.executeWrite(tx => {
    return tx.run(
      'CREATE (p:Person {email: $email})',
      { email: 'alice@example.com' }
    );
  });
} catch (error) {
  if (error.code === 'Neo.ClientError.Schema.ConstraintValidationFailed') {
    console.log('Email already exists');
    // Handle duplicate email
  }
}
```

---

## Transaction Configuration

### Set Transaction Timeout

```javascript
// Node.js driver
const session = driver.session({
  defaultAccessMode: neo4j.session.WRITE
});

const tx = session.beginTransaction({
  timeout: 30000  // 30 seconds
});

try {
  await tx.run('MATCH (n) RETURN n');
  await tx.commit();
} catch (error) {
  await tx.rollback();
  throw error;
} finally {
  await session.close();
}
```

### Transaction Metadata

```javascript
// Add metadata for monitoring
await session.executeWrite(
  tx => tx.run('CREATE (n:Person {name: $name})', { name: 'Alice' }),
  {
    metadata: {
      app: 'user-service',
      operation: 'create-user',
      userId: '12345'
    }
  }
);

// View transaction with metadata
// CALL dbms.listTransactions()
```

---

## Read and Write Transactions

### Read Transactions

Optimized for queries that don't modify data:

```javascript
// Read transaction can be routed to read replicas
const result = await session.executeRead(tx => {
  return tx.run(`
    MATCH (p:Person)-[:KNOWS]->(friend)
    RETURN p.name, collect(friend.name) AS friends
    LIMIT 10
  `);
});

// Better performance for read-heavy workloads
// Can be load-balanced across cluster
```

### Write Transactions

For operations that modify data:

```javascript
// Write transaction goes to leader in cluster
const result = await session.executeWrite(tx => {
  return tx.run(`
    CREATE (p:Person {name: $name, email: $email})
    RETURN p
  `, { name: 'Alice', email: 'alice@example.com' });
});

// Ensures strong consistency
```

---

## Transaction Best Practices

### 1. Keep Transactions Short

```cypher
// BAD: Long transaction holding locks
BEGIN
MATCH (n:Person)
// ... complex processing ...
// ... external API call ...
SET n.processed = true
COMMIT

// GOOD: Short transaction
// Do processing outside transaction
WITH processedData
BEGIN
MATCH (n:Person {id: $id})
SET n.data = $processedData
COMMIT
```

### 2. Read Before Write in Same Transaction

```cypher
// GOOD: Read and write in same transaction
BEGIN
MATCH (a:Account {id: $id})
WHERE a.balance >= $amount
SET a.balance = a.balance - $amount
RETURN a.balance
COMMIT

// BAD: Separate read and write
// Read
MATCH (a:Account {id: $id}) RETURN a.balance
// ... application logic ...
// Write (balance might have changed!)
MATCH (a:Account {id: $id})
SET a.balance = a.balance - $amount
```

### 3. Use Appropriate Transaction Type

```javascript
// Read-only operations
await session.executeRead(tx => {
  return tx.run('MATCH (n:Person) RETURN n LIMIT 10');
});

// Write operations
await session.executeWrite(tx => {
  return tx.run('CREATE (n:Person {name: $name})', { name: 'Alice' });
});
```

### 4. Handle Errors Properly

```javascript
const session = driver.session();

try {
  const result = await session.executeWrite(tx => {
    // Transaction logic
  });
  return result;
  
} catch (error) {
  console.error('Transaction failed:', error);
  throw error;
  
} finally {
  // Always close session
  await session.close();
}
```

### 5. Use Parameterized Queries

```cypher
// GOOD: Parameterized
BEGIN
MATCH (n:Person {id: $id})
SET n.name = $name
COMMIT

// BAD: String concatenation (security risk)
BEGIN
MATCH (n:Person {id: "' + userId + '"})
SET n.name = "' + userName + '"
COMMIT
```

---

## Transaction Performance

### Batch Operations

```cypher
// Process large datasets in batches
CALL {
  LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
  CREATE (p:Person {
    id: row.id,
    name: row.name,
    email: row.email
  })
} IN TRANSACTIONS OF 1000 ROWS

// Commits every 1000 rows
// Reduces transaction size and memory usage
```

### Parallel Transaction Processing

```javascript
// Process independent operations in parallel
async function processUsers(userIds) {
  const promises = userIds.map(userId => {
    const session = driver.session();
    return session.executeWrite(tx => {
      return tx.run(
        'MATCH (u:User {id: $userId}) SET u.processed = true',
        { userId }
      );
    }).finally(() => session.close());
  });
  
  await Promise.all(promises);
}
```

### Monitor Transaction Performance

```cypher
// View slow transactions
CALL dbms.listTransactions()
YIELD transactionId, elapsedTime, currentQuery
WHERE elapsedTime.milliseconds > 5000
RETURN transactionId, elapsedTime, currentQuery
ORDER BY elapsedTime.milliseconds DESC
```

---

## Advanced Transaction Patterns

### Saga Pattern for Distributed Operations

```javascript
async function createOrderWithInventory(orderData) {
  const session = driver.session();
  
  const compensations = [];
  
  try {
    // Step 1: Create order
    const orderId = await session.executeWrite(tx => {
      return tx.run(
        'CREATE (o:Order {id: randomUUID(), status: "pending"}) RETURN o.id',
      ).then(result => result.records[0].get(0));
    });
    
    compensations.push(async () => {
      await session.executeWrite(tx => {
        return tx.run('MATCH (o:Order {id: $orderId}) DELETE o', { orderId });
      });
    });
    
    // Step 2: Reserve inventory
    const reserved = await session.executeWrite(tx => {
      return tx.run(`
        MATCH (p:Product {id: $productId})
        WHERE p.stock >= $quantity
        SET p.stock = p.stock - $quantity
        RETURN p.stock
        `, orderData
      ).then(result => result.records.length > 0);
    });
    
    if (!reserved) {
      throw new Error('Insufficient stock');
    }
    
    compensations.push(async () => {
      await session.executeWrite(tx => {
        return tx.run(`
          MATCH (p:Product {id: $productId})
          SET p.stock = p.stock + $quantity
          `, orderData
        );
      });
    });
    
    // Step 3: Process payment (external service)
    const paymentSuccess = await processPayment(orderData.amount);
    
    if (!paymentSuccess) {
      throw new Error('Payment failed');
    }
    
    // Confirm order
    await session.executeWrite(tx => {
      return tx.run(
        'MATCH (o:Order {id: $orderId}) SET o.status = "confirmed"',
        { orderId }
      );
    });
    
    return orderId;
    
  } catch (error) {
    // Execute compensating transactions in reverse order
    console.log('Rolling back saga...');
    for (const compensate of compensations.reverse()) {
      try {
        await compensate();
      } catch (compError) {
        console.error('Compensation failed:', compError);
      }
    }
    throw error;
    
  } finally {
    await session.close();
  }
}
```

### Two-Phase Commit Simulation

```cypher
// Phase 1: Prepare
BEGIN
MATCH (t:Transfer {id: $transferId})
SET t.status = 'preparing'

MATCH (a:Account {id: $fromId})
WHERE a.balance >= $amount
SET a.pendingDebit = coalesce(a.pendingDebit, 0) + $amount

MATCH (b:Account {id: $toId})
SET b.pendingCredit = coalesce(b.pendingCredit, 0) + $amount

MATCH (t:Transfer {id: $transferId})
SET t.status = 'prepared'
COMMIT

// Phase 2: Commit
BEGIN
MATCH (t:Transfer {id: $transferId})
WHERE t.status = 'prepared'
SET t.status = 'committing'

MATCH (a:Account {id: $fromId})
SET a.balance = a.balance - $amount,
    a.pendingDebit = a.pendingDebit - $amount

MATCH (b:Account {id: $toId})
SET b.balance = b.balance + $amount,
    b.pendingCredit = b.pendingCredit - $amount

MATCH (t:Transfer {id: $transferId})
SET t.status = 'committed'
COMMIT
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Neo4j Transactions
