# Database Transactions - Practice Exercises

## Instructions

Complete the following exercises to practice database transactions, isolation levels, locking, and concurrency control. Work with a partner when indicated for concurrent transaction exercises.

**Time Allocation**: 120-180 minutes  
**Difficulty**: Beginner to Advanced  
**Prerequisites**: SQL basics, understanding of database tables

---

## Part 1: Transaction Basics

### Exercise 1: Your First Transaction

Create a simple bank database and perform a basic transaction:

```sql
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(100),
    balance DECIMAL(10,2),
    CHECK (balance >= 0)
);

INSERT INTO accounts (account_name, balance) VALUES 
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Charlie', 750.00);
```

Now perform a transaction that transfers $100 from Alice to Bob:

1. Begin a transaction
2. Deduct $100 from Alice's account
3. Add $100 to Bob's account
4. Commit the transaction
5. Verify the balances

**Deliverable**: Complete SQL transaction with verification queries

---

### Exercise 2: Transaction Rollback

Practice rolling back a transaction:

1. Start a transaction
2. Update Alice's balance to $2000
3. Update Bob's balance to $50
4. Check  the balances (should see changes)
5. Rollback the transaction
6. Check the balances again (should be original values)

**Deliverable**: SQL commands showing rollback behavior

---

### Exercise 3: Transaction Error Handling

Attempt a transaction that violates a constraint:

1. Start a transaction
2. Try to set Alice's balance to -500 (should violate CHECK constraint)
3. Observe the error
4. Show that the transaction is automatically rolled back
5. Verify balance is unchanged

**Deliverable**: SQL commands and error message

---

## Part 2: ACID Properties

### Exercise 4: Atomicity

Demonstrate atomicity:

1. Create a transaction that updates 3 accounts
2. Make one of the updates invalid (violates constraint)
3. Show that none of the updates are applied
4. Document why this demonstrates atomicity

**Deliverable**: SQL transaction and explanation

---

### Exercise 5: Consistency

Demonstrate consistency:

1. Write a transaction that maintains total balance across accounts
2. Transfer money between multiple accounts
3. Verify that SUM(balance) is the same before and after
4. Attempt a transaction that would violate CHECK constraint
5. Show that database remains consistent

**Deliverable**: Transaction with before/after balance verification

---

### Exercise 6: Isolation (Simple)

Open two separate database connections. Demonstrate isolation:

**Connection 1**:
1. BEGIN transaction
2. UPDATE Alice's balance
3. Don't commit yet

**Connection 2**:
4. Query Alice's balance
5. What do you see? (Should not see uncommitted change)

**Connection 1**:
6. COMMIT

**Connection 2**:
7. Query Alice's balance again
8. What do you see now?

**Deliverable**: Step-by-step results demonstrating isolation

---

### Exercise 7: Durability

Demonstrate durability:

1. Start a transaction and insert a new account
2. Commit the transaction
3. Verify the account exists
4. Document that even if the database server restarts, this data persists

**Deliverable**: SQL commands with explanation of durability

---

## Part 3: Savepoints

### Exercise 8: Basic Savepoint

Use savepoints in a complex transaction:

1. Start a transaction
2. Insert a new account for David with $500
3. Create SAVEPOINT sp1
4. Transfer $200 from David to Alice
5. Create SAVEPOINT sp2
6. Transfer $300 from David to Bob (this will fail - insufficient funds)
7. Rollback to sp2
8. Commit the transaction
9. Verify final balances

**Deliverable**: Complete SQL with savepoints

---

### Exercise 9: Multiple Savepoints

Create a transaction with multiple savepoints for order processing:

```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_name VARCHAR(100),
    quantity INTEGER,
    price DECIMAL(10,2)
);
```

Create a transaction that:
1. Inserts an order
2. Creates SAVEPOINT after order creation
3. Inserts 3 order items
4. Creates SAVEPOINT after items
5. Updates order status
6. If status update fails, rollback to item savepoint
7. Commit

**Deliverable**: Complete order processing transaction with savepoints

---

### Exercise 10: Savepoint Release

Practice releasing savepoints:

1. Start a transaction with multiple savepoints
2. Release an intermediate savepoint
3. Try to rollback to released savepoint (should fail)
4. Document the error

**Deliverable**: SQL demonstrating savepoint release

---

## Part 4: Isolation Levels

### Exercise 11: Read Committed (Default)

Demonstrate Read Committed behavior with two connections:

**Connection 1**:
```sql
BEGIN;
SELECT balance FROM accounts WHERE account_name = 'Alice';
-- Query 1: Note the value
```

**Connection 2**:
```sql
BEGIN;
UPDATE accounts SET balance = balance + 100 WHERE account_name = 'Alice';
COMMIT;
```

**Connection 1**:
```sql
SELECT balance FROM accounts WHERE account_name = 'Alice';
-- Query 2: What value do you see?
COMMIT;
```

**Questions**:
1. Did Query 1 see the uncommitted change?
2. Did Query 2 see the committed change?
3. Is this a non-repeatable read?

**Deliverable**: Results and answers to questions

---

### Exercise 12: Repeatable Read

Compare Repeatable Read with Read Committed:

**Connection 1**:
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE account_name = 'Alice';
-- Note the value
```

**Connection 2**:
```sql
UPDATE accounts SET balance = balance + 100 WHERE account_name = 'Alice';
```

**Connection 1**:
```sql
SELECT balance FROM accounts WHERE account_name = 'Alice';
-- What value do you see?
COMMIT;
```

**Questions**:
1. Did the balance change within the transaction?
2. How is this different from Read Committed?
3. When would you use Repeatable Read?

**Deliverable**: Results and analysis

---

### Exercise 13: Phantom Reads

Demonstrate phantom read prevention:

**Connection 1 (Read Committed)**:
```sql
BEGIN;
SELECT COUNT(*) FROM accounts WHERE balance > 700;
-- Note the count
```

**Connection 2**:
```sql
INSERT INTO accounts (account_name, balance) VALUES ('Eve', 800);
```

**Connection 1**:
```sql
SELECT COUNT(*) FROM accounts WHERE balance > 700;
-- Did the count change?
COMMIT;
```

Now repeat with REPEATABLE READ isolation level.

**Deliverable**: Results comparison between isolation levels

---

### Exercise 14: Serializable Isolation

Experiment with Serializable:

**Connection 1**:
```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(balance) FROM accounts;
UPDATE accounts SET balance = balance * 1.05;
-- Don't commit yet
```

**Connection 2**:
```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(balance) FROM accounts;
UPDATE accounts SET balance = balance * 1.03;
COMMIT;
```

**Connection 1**:
```sql
COMMIT;  -- What happens?
```

**Questions**:
1. Did Connection 1's commit succeed?
2. What error did you get?
3. Why did this happen?
4. How would you handle this in an application?

**Deliverable**: Results and retry strategy

---

## Part 5: Locking

### Exercise 15: FOR UPDATE

Practice exclusive row locking:

**Connection 1**:
```sql
BEGIN;
SELECT * FROM accounts WHERE account_name = 'Alice' FOR UPDATE;
-- Row is now locked
```

**Connection 2**:
```sql
-- Try to update Alice's account
UPDATE accounts SET balance = balance + 50 WHERE account_name = 'Alice';
-- What happens?
```

**Connection 1**:
```sql
UPDATE accounts SET balance = balance - 100 WHERE account_name = 'Alice';
COMMIT;
```

**Connection 2**:
```sql
-- What happens now?
```

**Deliverable**: Step-by-step results showing blocking behavior

---

### Exercise 16: FOR SHARE

Compare FOR SHARE with FOR UPDATE:

**Connection 1**:
```sql
BEGIN;
SELECT * FROM accounts WHERE account_name = 'Bob' FOR SHARE;
```

**Connection 2**:
```sql
-- Try this
SELECT * FROM accounts WHERE account_name = 'Bob' FOR SHARE;
-- Does it work?

-- Now try this
UPDATE accounts SET balance = balance + 10 WHERE account_name = 'Bob';
-- Does it work?
```

**Questions**:
1. Can multiple connections hold FOR SHARE locks simultaneously?
2. Can you UPDATE while another connection has FOR SHARE?
3. When would you use FOR SHARE instead of FOR UPDATE?

**Deliverable**: Results and analysis

---

### Exercise 17: SKIP LOCKED

Implement a job queue processor:

```sql
CREATE TABLE job_queue (
    job_id SERIAL PRIMARY KEY,
    job_data TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO job_queue (job_data) VALUES 
    ('Job 1'), ('Job 2'), ('Job 3'), ('Job 4'), ('Job 5');
```

Simulate two workers:

**Worker 1**:
```sql
BEGIN;
SELECT * FROM job_queue 
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;
-- Process the job
UPDATE job_queue SET status = 'completed' WHERE job_id = ?;
COMMIT;
```

**Worker 2** (run simultaneously):
```sql
BEGIN;
SELECT * FROM job_queue 
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;
-- Process the job
UPDATE job_queue SET status = 'completed' WHERE job_id = ?;
COMMIT;
```

**Questions**:
1. Did both workers get the same job?
2. How does SKIP LOCKED prevent conflicts?
3. What are use cases for this pattern?

**Deliverable**: Implementation and analysis

---

### Exercise 18: NOWAIT

Practice non-blocking lock attempts:

**Connection 1**:
```sql
BEGIN;
SELECT * FROM accounts WHERE account_name = 'Alice' FOR UPDATE;
```

**Connection 2**:
```sql
BEGIN;
SELECT * FROM accounts WHERE account_name = 'Alice' FOR UPDATE NOWAIT;
-- What happens?
```

Handle the error in application logic (pseudocode):
```
try:
    SELECT ... FOR UPDATE NOWAIT
except LockNotAvailable:
    return "Resource busy, try again"
```

**Deliverable**: Results and error handling strategy

---

## Part 6: Deadlocks

### Exercise 19: Create a Deadlock

Intentionally create a deadlock:

**Connection 1**:
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_name = 'Alice';
-- Wait 5 seconds
UPDATE accounts SET balance = balance + 100 WHERE account_name = 'Bob';
```

**Connection 2** (start before Connection 1's second UPDATE):
```sql
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE account_name = 'Bob';
-- Wait 5 seconds
UPDATE accounts SET balance = balance + 50 WHERE account_name = 'Alice';
```

**Questions**:
1. What error message did you get?
2. Which transaction was aborted?
3. Which transaction succeeded?

**Deliverable**: Deadlock error message and analysis

---

### Exercise 20: Prevent Deadlock

Fix the deadlock from Exercise 19:

Rewrite the transactions to always lock accounts in alphabetical order:

```sql
-- Both transactions lock in same order: Alice first, then Bob
```

**Questions**:
1. Does the deadlock still occur?
2. Why does consistent ordering prevent deadlocks?
3. What if you have more than 2 resources to lock?

**Deliverable**: Fixed transactions with explanation

---

### Exercise 21: Deadlock Detection

Monitor for deadlocks:

1. Enable deadlock logging in PostgreSQL
2. Create a deadlock intentionally
3. Check the PostgreSQL logs
4. Document what information is logged

**Deliverable**: Log excerpts and analysis

---

## Part 7: Real-World Scenarios

### Exercise 22: Money Transfer with Validation

Implement a safe money transfer:

1. Begin transaction
2. Lock both accounts (in consistent order)
3. Verify source account has sufficient balance
4. Verify destination account exists
5. Perform transfer
6. Commit or rollback based on validation

Include error handling for:
- Insufficient funds
- Account doesn't exist
- Overdraft

**Deliverable**: Complete transaction with all error handling

---

### Exercise 23: Inventory Management

Create an inventory reservation system:

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    stock INTEGER CHECK (stock >= 0),
    reserved INTEGER DEFAULT 0
);

CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    customer_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP
);
```

Implement:
1. Reserve inventory (decrease stock, create reservation)
2. Handle concurrent reservations for same product
3. Timeout expired reservations
4. Complete reservation (move from reserved to sold)
5. Cancel reservation (restore stock)

**Deliverable**: Complete reservation system with concurrent handling

---

### Exercise 24: Order Processing Pipeline

Implement a multi-step order processing system:

```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    total_amount DECIMAL(10,2),
    status VARCHAR(20), -- pending, validated, paid, shipped, completed
    created_at TIMESTAMP DEFAULT NOW()
);
```

Create transactions for:
1. Create order (with savepoint after validation)
2. Process payment (with rollback if payment fails)
3. Update inventory (with rollback if insufficient stock)
4. Generate shipping label
5. Handle failures at each step

**Deliverable**: Complete order pipeline with error handling

---

### Exercise 25: Double-Spend Prevention

Prevent double-spending in a gift card system:

```sql
CREATE TABLE gift_cards (
    card_id SERIAL PRIMARY KEY,
    card_number VARCHAR(50) UNIQUE,
    balance DECIMAL(10,2),
    CHECK (balance >= 0)
);

CREATE TABLE gift_card_transactions (
    transaction_id SERIAL PRIMARY KEY,
    card_id INTEGER REFERENCES gift_cards(card_id),
    amount DECIMAL(10,2),
    transaction_type VARCHAR(20), -- debit or credit
    created_at TIMESTAMP DEFAULT NOW()
);
```

Implement a transaction that:
1. Locks the gift card
2. Verifies sufficient balance
3. Deducts amount
4. Records transaction
5. Prevents race conditions

Test with concurrent transactions attempting to use the same card.

**Deliverable**: Race-condition-proof gift card system

---

## Part 8: Performance and Monitoring

### Exercise 26: Transaction Performance

Compare performance of different approaches:

1. Individual transactions for 1000 inserts
2. Single transaction for 1000 inserts
3. Batched transactions (100 inserts per transaction)

Measure execution time for each approach.

**Deliverable**: Performance comparison and analysis

---

### Exercise 27: Lock Monitoring

Create queries to monitor database locks:

1. Query to show all current locks
2. Query to show blocking locks
3. Query to show lock wait times
4. Query to find long-running transactions

**Deliverable**: 4 monitoring queries with sample output

---

### Exercise 28: Transaction Timeout

Configure and test transaction timeouts:

1. Set a 5-second transaction timeout
2. Start a transaction
3. Wait 6 seconds without committing
4. Observe the timeout error
5. Document when timeouts are useful

**Deliverable**: Timeout configuration and test results

---

## Part 9: Advanced Topics

### Exercise 29: Optimistic Locking

Implement optimistic locking with version numbers:

```sql
CREATE TABLE  documents (
    doc_id SERIAL PRIMARY KEY,
    content TEXT,
    version INTEGER DEFAULT 1,
    last_modified TIMESTAMP DEFAULT NOW()
);
```

Implement update logic:
1. Read document with current version
2. User edits document
3. Update only if version matches
4. Increment version on successful update
5. Handle version mismatch (concurrent update)

**Deliverable**: Optimistic locking implementation

---

### Exercise 30: Pessimistic Locking

Compare with pessimistic locking:

1. Lock document immediately when user starts editing
2. Hold lock during editing
3. Update and release lock
4. Handle lock timeout

Compare pros/cons of optimistic vs pessimistic locking.

**Deliverable**: Both implementations with comparison

---

### Exercise 31: Advisory Locks

Use advisory locks for application-level synchronization:

```sql
-- Lock a resource by ID
SELECT pg_advisory_lock(12345);

-- Critical section - only one process can be here

-- Unlock
SELECT pg_advisory_unlock(12345);
```

Implement a system where multiple processes coordinate using advisory locks.

**Deliverable**: Advisory lock implementation

---

### Exercise 32: Bulk Operations

Optimize bulk operations with transactions:

Insert 10,000 rows using:
1. Individual auto-commit statements
2. Single transaction with batch inserts
3. COPY command

Compare performance and document best practices.

**Deliverable**: Performance comparison and recommendations

---

## Bonus Challenges

### Challenge 1: Distributed Transaction

Simulate a distributed transaction across multiple tables/databases:

1. Update accounts table
2. Log to transactions table
3. Update audit table
4. Ensure all succeed or all fail

**Deliverable**: Coordinated multi-table transaction

---

### Challenge 2: Transaction Retry Logic

Implement automatic retry logic for serialization errors:

```python
def transfer_money(from_account, to_account, amount, max_retries=3):
    for attempt in range(max_retries):
        try:
            # BEGIN transaction
            # Perform transfer
            # COMMIT
            return success
        except SerializationError:
            if attempt == max_retries - 1:
                raise
            sleep(random.uniform(0.1, 0.5))
```

**Deliverable**: Complete retry implementation in SQL or application code

---

### Challenge 3: Transaction Audit Trail

Create a comprehensive audit system:

1. Log all transaction starts
2. Log all commits and rollbacks
3. Record transaction duration
4. Track affected tables and row counts
5. Generate audit report

**Deliverable**: Complete audit system

---

## Submission Checklist

Your completed exercise submission should include:

- [ ] Basic transaction commands (Exercises 1-3)
- [ ] ACID demonstrations (Exercises 4-7)
- [ ] Savepoint usage (Exercises 8-10)
- [ ] Isolation level experiments (Exercises 11-14)
- [ ] Locking mechanisms (Exercises 15-18)
- [ ] Deadlock creation and prevention (Exercises 19-21)
- [ ] Real-world scenarios (Exercises 22-25)
- [ ] Performance analysis (Exercises 26-28)
- [ ] Advanced techniques (Exercises 29-32)
- [ ] Bonus challenges (optional)

---

## Testing Checklist

For each exercise involving concurrent transactions:

- [ ] Test with two simultaneous connections
- [ ] Verify expected blocking behavior
- [ ] Confirm transaction isolation
- [ ] Check for race conditions
- [ ] Test error handling
- [ ] Verify data consistency after all operations

---

## Expected Learning Outcomes

After completing these exercises, you should be able to:

- Use transactions properly (BEGIN, COMMIT, ROLLBACK)
- Understand and apply ACID properties
- Use savepoints for partial rollback
- Choose appropriate isolation levels
- Implement proper locking strategies
- Detect and prevent deadlocks
- Handle concurrent access safely
- Monitor and troubleshoot transaction issues
- Implement real-world transaction patterns
- Optimize transaction performance

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Database Transactions
