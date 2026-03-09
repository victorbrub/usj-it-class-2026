# Database Transactions - Complete Guide

## What is a Transaction?

A **transaction** is a sequence of one or more SQL operations treated as a single unit of work. Either all operations succeed (committed), or none of them do (rolled back). Transactions ensure database integrity even when errors occur or systems crash.

### Real-World Analogy

Think of a bank transfer:
1. Deduct $100 from Account A
2. Add $100 to Account B

Both steps must complete. If step 1 succeeds but step 2 fails, money disappears! Transactions ensure both happen or neither happens.

---

## Why Transactions Matter

### Problems Without Transactions

**Lost Updates**: Two users update the same record simultaneously
```sql
-- User A reads balance: $1000
-- User B reads balance: $1000
-- User A updates: balance = $1000 - $100 = $900
-- User B updates: balance = $1000 - $200 = $800
-- Final balance: $800 (User A's withdrawal is lost!)
```

**Partial Failures**: System crashes mid-operation
```sql
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- System crashes here
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
-- This never executes - money disappears!
```

**Inconsistent Reads**: Reading while data is being updated
```sql
-- User A is transferring $100 between accounts
-- User B calculates total balance mid-transfer
-- User B sees inconsistent state (money in neither account)
```

---

## ACID Properties

Transactions guarantee **ACID** properties:

### A - Atomicity

**All or nothing**: Either all operations in a transaction succeed, or none do.

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;  -- Both updates happen

-- OR if error occurs:
ROLLBACK;  -- Neither update happens
```

### C - Consistency

**Valid state transitions**: Database moves from one valid state to another. Constraints are always satisfied.

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    -- If this would violate CHECK (balance >= 0), transaction fails
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;  -- Only happens if all constraints satisfied
```

### I - Isolation

**Concurrent transactions don't interfere**: Each transaction executes as if it's the only one.

```sql
-- Transaction A
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    -- Transaction B cannot see this change yet
COMMIT;  -- Now Transaction B can see it
```

### D - Durability

**Permanent once committed**: Committed changes survive system crashes.

```sql
BEGIN;
    INSERT INTO orders VALUES (...);
COMMIT;  -- Even if server crashes right after, this data is saved
```

---

## Transaction Commands

### BEGIN (or START TRANSACTION)

Start a new transaction:

```sql
BEGIN;
-- or
START TRANSACTION;
-- or
BEGIN TRANSACTION;
```

### COMMIT

Save all changes made in the transaction:

```sql
BEGIN;
    UPDATE products SET stock = stock - 1 WHERE product_id = 100;
    INSERT INTO orders (product_id, quantity) VALUES (100, 1);
COMMIT;  -- Both changes are saved permanently
```

### ROLLBACK

Undo all changes made in the transaction:

```sql
BEGIN;
    UPDATE products SET stock = stock - 1 WHERE product_id = 100;
    -- Oops, error detected
ROLLBACK;  -- Product stock is restored to original value
```

### Auto-commit Mode

By default, each SQL statement is its own transaction:

```sql
-- These are three separate transactions
INSERT INTO users VALUES (1, 'Alice');
INSERT INTO users VALUES (2, 'Bob');
INSERT INTO users VALUES (3, 'Charlie');

-- If second INSERT fails, first one still committed!
```

To group them:

```sql
BEGIN;
    INSERT INTO users VALUES (1, 'Alice');
    INSERT INTO users VALUES (2, 'Bob');
    INSERT INTO users VALUES (3, 'Charlie');
COMMIT;  -- All three succeed or all three fail
```

---

## Savepoints

Create intermediate checkpoints within a transaction:

### Creating Savepoints

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    SAVEPOINT sp1;
    
    UPDATE accounts SET balance = balance + 50 WHERE account_id = 2;
    SAVEPOINT sp2;
    
    UPDATE accounts SET balance = balance + 50 WHERE account_id = 3;
    
    -- Undo last update only
    ROLLBACK TO sp2;
    
    -- Now commit the first two updates
COMMIT;
```

### Real-World Savepoint Example

```sql
BEGIN;
    -- Process order
    INSERT INTO orders (customer_id, total) VALUES (1, 150.00);
    SAVEPOINT order_created;
    
    -- Update inventory
    UPDATE products SET stock = stock - 1 WHERE product_id = 10;
    SAVEPOINT inventory_updated;
    
    -- Apply discount (might fail if invalid)
    UPDATE orders SET total = total * 0.9 WHERE order_id = LAST_INSERT_ID();
    
    -- If discount fails, rollback discount only:
    -- ROLLBACK TO inventory_updated;
    
COMMIT;
```

### Releasing Savepoints

Free resources used by savepoint:

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    SAVEPOINT sp1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
    -- Everything ok, don't need savepoint anymore
    RELEASE SAVEPOINT sp1;
COMMIT;
```

---

## Transaction Isolation Levels

Controls how transactions see each other's changes.

### The Problems Isolation Solves

**Dirty Read**: Reading uncommitted changes from another transaction
```sql
-- Transaction A
BEGIN;
UPDATE products SET price = 99.99 WHERE product_id = 1;
-- Not committed yet!

-- Transaction B (sees uncommitted change)
SELECT price FROM products WHERE product_id = 1;  -- Sees 99.99
-- But Transaction A might rollback!
```

**Non-Repeatable Read**: Same query returns different results within transaction
```sql
-- Transaction A
BEGIN;
SELECT price FROM products WHERE product_id = 1;  -- Returns 100.00

-- Transaction B commits a change
UPDATE products SET price = 99.99 WHERE product_id = 1;

-- Transaction A
SELECT price FROM products WHERE product_id = 1;  -- Returns 99.99 (different!)
```

**Phantom Read**: New rows appear in query results within transaction
```sql
-- Transaction A
BEGIN;
SELECT COUNT(*) FROM products WHERE price > 100;  -- Returns 5

-- Transaction B inserts new row
INSERT INTO products VALUES (6, 'New Product', 150.00);

-- Transaction A
SELECT COUNT(*) FROM products WHERE price > 100;  -- Returns 6 (phantom row!)
```

### Isolation Levels

PostgreSQL supports four isolation levels:

#### 1. Read Uncommitted (Not really in PostgreSQL)

PostgreSQL treats this as Read Committed.

- **Dirty Reads**: Possible (but not in PostgreSQL)
- **Non-Repeatable Reads**: Possible
- **Phantom Reads**: Possible

#### 2. Read Committed (PostgreSQL Default)

Only sees committed changes from other transactions.

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
    SELECT * FROM products WHERE product_id = 1;
    -- Sees only committed data
    -- Different query might see different results
COMMIT;
```

- **Dirty Reads**: NOT Possible
- **Non-Repeatable Reads**: Possible
- **Phantom Reads**: Possible

**Use when**: Multiple short transactions, don't need repeatable reads

#### 3. Repeatable Read

Sees snapshot of database at transaction start.

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
    SELECT price FROM products WHERE product_id = 1;  -- Returns 100.00
    
    -- Another transaction changes and commits price to 99.99
    
    SELECT price FROM products WHERE product_id = 1;  -- Still returns 100.00
COMMIT;
```

- **Dirty Reads**: NOT Possible
- **Non-Repeatable Reads**: NOT Possible
- **Phantom Reads**: NOT Possible (in PostgreSQL)

**Use when**: Need consistent snapshot for entire transaction

#### 4. Serializable

Strongest isolation. Transactions execute as if serial (one after another).

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
    SELECT SUM(balance) FROM accounts;
    -- No other transaction can modify accounts until this commits
    UPDATE accounts SET balance = balance * 1.05;
COMMIT;
```

- **Dirty Reads**: NOT Possible
- **Non-Repeatable Reads**: NOT Possible
- **Phantom Reads**: NOT Possible

**Use when**: Critical operations requiring complete isolation

**Warning**: Can cause serialization errors. Must handle retries!

### Setting Isolation Level

```sql
-- For current transaction
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    -- queries here
COMMIT;

-- Or after BEGIN
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    -- queries here
COMMIT;

-- For session
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- For all future sessions (in postgresql.conf)
-- default_transaction_isolation = 'repeatable read'
```

### Isolation Level Comparison

| Problem | Read Uncommitted | Read Committed | Repeatable Read | Serializable |
|---------|------------------|----------------|-----------------|--------------|
| Dirty Read | Yes* | No | No | No |
| Non-Repeatable Read | Yes | Yes | No | No |
| Phantom Read | Yes | Yes | No | No |
| Performance | Fastest | Fast | Slower | Slowest |

*Not in PostgreSQL

---

## Locking

### Types of Locks

**Row-Level Locks**: Lock specific rows
- `FOR UPDATE`: Exclusive lock, prevents reads and writes
- `FOR NO KEY UPDATE`: Exclusive lock, allows foreign key checks
- `FOR SHARE`: Shared lock, prevents updates
- `FOR KEY SHARE`: Shared lock, allows updates not affecting keys

**Table-Level Locks**: Lock entire tables
- `ACCESS SHARE`: Acquired by SELECT
- `ROW EXCLUSIVE`: Acquired by INSERT, UPDATE, DELETE
- `EXCLUSIVE`: Prevents all operations except SELECT
- `ACCESS EXCLUSIVE`: Prevents all operations

### Row-Level Locking Examples

#### FOR UPDATE

```sql
-- Lock row for update (others wait)
BEGIN;
    SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
    -- This row is locked until commit
    UPDATE products SET stock = stock - 1 WHERE product_id = 1;
COMMIT;

-- Use case: Reserve inventory
BEGIN;
    SELECT stock FROM products WHERE product_id = 100 FOR UPDATE;
    -- Check if sufficient stock
    -- If ok, update
    UPDATE products SET stock = stock - 5 WHERE product_id = 100;
COMMIT;
```

#### FOR SHARE

```sql
-- Lock row for reading (allows other reads, prevents writes)
BEGIN;
    SELECT * FROM orders WHERE order_id = 1 FOR SHARE;
    -- Process order...
    -- Other transactions can read but not modify this order
COMMIT;
```

#### SKIP LOCKED

Skip rows that are currently locked:

```sql
-- Queue processor: get next unlocked job
SELECT * FROM job_queue
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;
```

#### NOWAIT

Fail immediately if row is locked:

```sql
-- Try to lock, don't wait
BEGIN;
    SELECT * FROM products 
    WHERE product_id = 1 
    FOR UPDATE NOWAIT;
COMMIT;
-- Raises error immediately if row is locked
```

### Table-Level Locking

```sql
-- Explicit table lock
BEGIN;
    LOCK TABLE products IN EXCLUSIVE MODE;
    -- Now have exclusive access to entire table
    -- Complex multi-row updates
COMMIT;

-- Advisory locks (application-defined)
SELECT pg_advisory_lock(1234);  -- Acquire lock with ID 1234
-- Critical section
SELECT pg_advisory_unlock(1234);  -- Release lock
```

---

## Deadlocks

### What is a Deadlock?

Two transactions waiting for each other to release locks.

```sql
-- Transaction A
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- Waiting for lock on account 2...

-- Transaction B
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 2;
-- Waiting for lock on account 1...

-- Deadlock! Neither can proceed.
```

### PostgreSQL Deadlock Detection

PostgreSQL automatically detects deadlocks and aborts one transaction:

```
ERROR:  deadlock detected
DETAIL:  Process 1234 waits for ShareLock on transaction 5678;
         blocked by process 5679.
```

### Preventing Deadlocks

**1. Consistent Lock Order**
```sql
-- Good: Always lock accounts in ID order
BEGIN;
    UPDATE accounts SET balance = balance - 100 
    WHERE account_id = LEAST(1, 2);  -- Smaller ID first
    
    UPDATE accounts SET balance = balance + 100 
    WHERE account_id = GREATEST(1, 2);  -- Larger ID second
COMMIT;
```

**2. Keep Transactions Short**
```sql
-- Bad: Long transaction
BEGIN;
    -- Lots of operations
    -- User interaction
    -- More operations
COMMIT;

-- Good: Short transaction
-- Do calculations outside transaction
BEGIN;
    UPDATE accounts SET balance = balance + calculated_amount;
COMMIT;
```

**3. Use Lock Timeout**
```sql
SET lock_timeout = '5s';
BEGIN;
    UPDATE products SET stock = stock - 1 WHERE product_id = 1;
COMMIT;
-- Fails after 5 seconds if can't acquire lock
```

**4. Handle Deadlock Errors**
```python
# In application code
while attempts < max_attempts:
    try:
        # Execute transaction
        break
    except DeadlockError:
        attempts += 1
        time.sleep(random.uniform(0.1, 0.5))  # Random backoff
```

---

## Best Practices

### 1. Keep Transactions Short

```sql
-- Bad: User interaction inside transaction
BEGIN;
    SELECT * FROM cart WHERE user_id = 1;
    -- Display to user
    -- Wait for user to confirm (could be minutes!)
    UPDATE orders SET status = 'confirmed';
COMMIT;

-- Good: Quick transaction
-- Display to user first, then:
BEGIN;
    UPDATE orders SET status = 'confirmed' WHERE order_id = ?;
COMMIT;
```

### 2. Access Resources in Consistent Order

```sql
-- Bad: Inconsistent order (can cause deadlocks)
-- Transaction A locks A then B
-- Transaction B locks B then A

-- Good: Consistent order
-- Always lock in order: A, B, C, D...
BEGIN;
    UPDATE table_a SET ... WHERE id IN (1, 2, 3) ORDER BY id;
    UPDATE table_b SET ... WHERE id IN (5, 6, 7) ORDER BY id;
COMMIT;
```

### 3. Use Appropriate Isolation Level

```sql
-- For most cases, default is fine
BEGIN;  -- Uses READ COMMITTED
    ...
COMMIT;

-- For complex reads needing consistency
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SELECT SUM(balance) FROM accounts;
    SELECT COUNT(*) FROM accounts;
    -- Both see same snapshot
COMMIT;

-- For critical operations
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Ensures serial execution
COMMIT;
```

### 4. Handle Errors Properly

```sql
-- In application code
BEGIN;
    try:
        UPDATE accounts SET balance = balance - 100 WHERE id = 1;
        if (new_balance < 0):
            raise InsufficientFunds
        UPDATE accounts SET balance = balance + 100 WHERE id = 2;
        COMMIT;
    except Exception:
        ROLLBACK;
        raise;
```

### 5. Use Savepoints for Partial Rollback

```sql
BEGIN;
    INSERT INTO orders (...);
    SAVEPOINT sp1;
    
    try:
        INSERT INTO order_items (...);
        INSERT INTO order_items (...);
    except:
        ROLLBACK TO sp1;  -- Keep order, discard items
        
COMMIT;
```

### 6. Monitor Long Transactions

```sql
-- Find long-running transactions
SELECT 
    pid,
    current_user,
    state,
    NOW() - xact_start AS duration,
    query
FROM pg_stat_activity
WHERE state != 'idle'
    AND xact_start IS NOT NULL
    AND NOW() - xact_start > INTERVAL '1 minute'
ORDER BY duration DESC;
```

### 7. Set Timeouts

```sql
-- Statement timeout (per query)
SET statement_timeout = '30s';

-- Transaction timeout
SET transaction_timeout = '5min';

-- Lock timeout
SET lock_timeout = '10s';
```

---

## Common Patterns

### Pattern 1: Bank Transfer

```sql
BEGIN;
    -- Withdraw from source
    UPDATE accounts 
    SET balance = balance - 100 
    WHERE account_id = 1 
        AND balance >= 100;  -- Check sufficient funds
    
    -- Verify update happened
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    IF rows_affected = 0 THEN
        ROLLBACK;
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
    
    -- Deposit to destination
    UPDATE accounts 
    SET balance = balance + 100 
    WHERE account_id = 2;
    
COMMIT;
```

### Pattern 2: Inventory Reserve

```sql
BEGIN;
    -- Lock and check inventory
    SELECT stock INTO current_stock
    FROM products 
    WHERE product_id = 100
    FOR UPDATE;
    
    IF current_stock < 5 THEN
        ROLLBACK;
        RAISE EXCEPTION 'Insufficient stock';
    END IF;
    
    -- Reserve inventory
    UPDATE products 
    SET stock = stock - 5 
    WHERE product_id = 100;
    
    -- Create order
    INSERT INTO orders (product_id, quantity) 
    VALUES (100, 5);
    
COMMIT;
```

### Pattern 3: Conditional Update

```sql
BEGIN;
    -- Get current state
    SELECT status INTO current_status
    FROM orders
    WHERE order_id = 123
    FOR UPDATE;
    
    -- Validate state transition
    IF current_status != 'pending' THEN
        ROLLBACK;
        RAISE EXCEPTION 'Order cannot be processed';
    END IF;
    
    -- Update state
    UPDATE orders 
    SET status = 'processing' 
    WHERE order_id = 123;
    
COMMIT;
```

### Pattern 4: Idempotent Operation

```sql
BEGIN;
    -- Check if already processed
    IF EXISTS (SELECT 1 FROM processed_transactions WHERE tx_id = 'TX123') THEN
        ROLLBACK;
        RETURN 'Already processed';
    END IF;
    
    -- Process transaction
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
    
    -- Mark as processed
    INSERT INTO processed_transactions (tx_id, processed_at) 
    VALUES ('TX123', NOW());
    
COMMIT;
```

---

## Monitoring and Troubleshooting

### View Active Transactions

```sql
SELECT 
    pid,
    usename,
    state,
    xact_start,
    AGE(NOW(), xact_start) AS age,
    query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start;
```

### View Locks

```sql
SELECT 
    l.pid,
    l.mode,
    l.granted,
    a.usename,
    a.query,
    a.state
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
ORDER BY l.pid;
```

### View Blocking Queries

```sql
SELECT 
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks ON blocked.pid = blocked_locks.pid
JOIN pg_locks blocking_locks ON 
    blocked_locks.locktype = blocking_locks.locktype
    AND blocked_locks.database IS NOT DISTINCT FROM blocking_locks.database
    AND blocked_locks.relation IS NOT DISTINCT FROM blocking_locks.relation
    AND blocked_locks.page IS NOT DISTINCT FROM blocking_locks.page
    AND blocked_locks.tuple IS NOT DISTINCT FROM blocking_locks.tuple
    AND blocked_locks.virtualxid IS NOT DISTINCT FROM blocking_locks.virtualxid
    AND blocked_locks.transactionid IS NOT DISTINCT FROM blocking_locks.transactionid
    AND blocked_locks.classid IS NOT DISTINCT FROM blocking_locks.classid
    AND blocked_locks.objid IS NOT DISTINCT FROM blocking_locks.objid
    AND blocked_locks.objsubid IS NOT DISTINCT FROM blocking_locks.objsubid
    AND blocked_locks.pid != blocking_locks.pid
JOIN pg_stat_activity blocking ON blocking.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

---

## Summary

Transactions are essential for:
- **Data Integrity**: Ensure consistent state
- **Concurrency Control**: Handle multiple users safely
- **Error Recovery**: Rollback on failures
- **Complex Operations**: Coordinate multiple changes

Key concepts:
- **ACID properties**: Atomicity, Consistency, Isolation, Durability
- **Isolation levels**: Control concurrent transaction visibility
- **Locking**: Prevent conflicting operations
- **Deadlocks**: Detection and prevention strategies

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026
