# Author: Víctor Barceló
# Apache Cassandra - Transactions and Lightweight Transactions

## Overview

Cassandra is designed for high availability and partition tolerance (AP in the CAP theorem). It does not provide multi-row ACID transactions like PostgreSQL or MongoDB. Instead, it offers:

- **Single-partition atomicity**: Writes to a single partition are always atomic.
- **Lightweight Transactions (LWT)**: Conditional writes using a Paxos-based protocol, providing compare-and-set (CAS) semantics.
- **Logged batches**: Atomic delivery of writes to multiple tables (same or different partitions).

Understanding what Cassandra does and does not guarantee is essential before designing any data model.

---

## Atomicity in Cassandra

### Single-Partition Writes

Any write that touches a single partition is atomic. If you INSERT or UPDATE multiple columns in one statement, either all column values are written or none are — there is no partial write.

```sql
-- This is atomic: all columns are written together or not at all
INSERT INTO user_profiles (username, email, full_name, joined_at)
VALUES ('alice', 'alice@example.com', 'Alice Johnson', toTimestamp(now()));

-- This UPDATE is also atomic
UPDATE user_profiles
SET email = 'alice_new@example.com', full_name = 'Alice J.'
WHERE username = 'alice';
```

### What is NOT Guaranteed

- **No atomicity across partitions**: Two writes to different partitions can partially fail.
- **No isolation between reads and writes**: A concurrent reader may see a partial update if you are writing to multiple tables.
- **No rollback**: If a second write fails after a first succeeds, the first write is not undone.

---

## Lightweight Transactions (LWT)

Lightweight Transactions provide **compare-and-set (CAS)** semantics using the Paxos consensus algorithm. They allow you to perform a write only if a condition is true at the time of the write.

### How LWT Works

1. A coordinator node runs a Paxos round across a quorum of replicas.
2. The current value of the row is read (Paxos "prepare" phase).
3. If the condition is satisfied, the write is applied (Paxos "commit" phase).
4. The operation returns whether it was applied and the current row values.

This ensures linearizable consistency for the affected row — stronger than eventual consistency, but at a significant performance cost (roughly 4x the latency of a regular write).

### IF NOT EXISTS (Insert LWT)

Use `IF NOT EXISTS` to create a row only if it does not already exist. This prevents duplicate registration.

```sql
-- Create a user only if the username is not already taken
INSERT INTO user_profiles (username, email, full_name, joined_at)
VALUES ('alice', 'alice@example.com', 'Alice Johnson', toTimestamp(now()))
IF NOT EXISTS;
```

The result set has an `[applied]` column:

```
 [applied] | username | email                | full_name     | joined_at
-----------+----------+----------------------+---------------+-----------
      True |     null |                 null |          null |      null   <- inserted

-- If alice already exists:
      False |    alice | alice@example.com | Alice Johnson | 2026-01-10  <- not inserted, current row shown
```

### IF condition (Update LWT)

Use `IF` conditions on UPDATE or DELETE to apply a change only if the current data matches.

```sql
-- Update email only if it has the expected current value
UPDATE user_profiles
SET email = 'alice_new@example.com'
WHERE username = 'alice'
IF email = 'alice@example.com';

-- Update a game's price only if it matches the expected price (optimistic lock)
UPDATE games_by_title
SET price = 59.99
WHERE title = 'Cyberpunk 2077'
IF price = 49.99;

-- Delete a session only if the token matches
DELETE FROM session_tokens
WHERE token = 'abc123'
IF username = 'alice';
```

### Checking the Result

Always check `[applied]` before proceeding:

**Python**:
```python
from cassandra.cluster import Cluster

cluster = Cluster(['127.0.0.1'])
session = cluster.connect('gameverse')

prepared = session.prepare(
    "INSERT INTO user_profiles (username, email, full_name) "
    "VALUES (?, ?, ?) IF NOT EXISTS"
)

result = session.execute(prepared, ('alice', 'alice@example.com', 'Alice Johnson'))
row = result.one()

if row.applied:
    print("User created successfully")
else:
    print(f"Username already taken. Current email: {row.email}")
```

**Java**:
```java
PreparedStatement stmt = session.prepare(
    "INSERT INTO gameverse.user_profiles (username, email, full_name) " +
    "VALUES (?, ?, ?) IF NOT EXISTS"
);

Row result = session.execute(stmt.bind("alice", "alice@example.com", "Alice Johnson")).one();

if (result.getBoolean("[applied]")) {
    System.out.println("User created successfully");
} else {
    System.out.println("Username taken. Current: " + result.getString("email"));
}
```

---

## Logged Batches

A **logged batch** guarantees that all statements in the batch will eventually be applied, even if a node fails partway through. Cassandra achieves this by writing the entire batch to a **batch log** on two nodes before applying any statements.

Logged batches are NOT full ACID transactions:
- They guarantee **atomicity of delivery** (all statements will be applied eventually).
- They do NOT guarantee **isolation** (other clients may read partial results while the batch is being applied).
- They do NOT provide rollback.

### When to Use Logged Batches

The primary use case is keeping **denormalized tables in sync**. When the same data is stored in multiple tables (as is common in Cassandra), a logged batch ensures all copies are updated even if a node fails.

```sql
-- Keeping two denormalized tables in sync
BEGIN BATCH
    INSERT INTO games_by_title (title, genre, developer, release_year)
    VALUES ('Cyberpunk 2077', 'RPG', 'CD Projekt Red', 2020);

    INSERT INTO games_by_genre (genre, title, developer, release_year)
    VALUES ('RPG', 'Cyberpunk 2077', 'CD Projekt Red', 2020);
APPLY BATCH;
```

If Cassandra fails after writing to `games_by_title` but before writing to `games_by_genre`, the batch log triggers a retry to complete the second write on recovery.

### Unlogged Batches

An **unlogged batch** skips the batch log. It is only safe when all statements target the **same partition** (they will be applied atomically). For cross-partition writes, use a logged batch.

```sql
-- Safe: all statements write to the same partition (username = 'alice')
BEGIN UNLOGGED BATCH
    UPDATE user_profiles SET email = 'alice_new@example.com' WHERE username = 'alice';
    UPDATE user_profiles SET full_name = 'Alice J. Johnson' WHERE username = 'alice';
APPLY BATCH;
```

### Batch with Timestamps

You can set a custom timestamp for all statements in a batch to ensure consistent ordering:

```sql
BEGIN BATCH USING TIMESTAMP 1713600000000000
    INSERT INTO games_by_title (title, genre) VALUES ('New Game', 'Action');
    INSERT INTO games_by_genre (genre, title) VALUES ('Action', 'New Game');
APPLY BATCH;
```

---

## Practical Patterns

### Pattern 1: Unique Username Registration

Prevent two users from registering the same username:

```python
def register_user(session, username, email, full_name):
    prepared = session.prepare(
        "INSERT INTO user_profiles (username, email, full_name, joined_at) "
        "VALUES (?, ?, ?, toTimestamp(now())) IF NOT EXISTS"
    )
    result = session.execute(prepared, (username, email, full_name))
    row = result.one()

    if row.applied:
        return {"success": True, "message": "Registration successful"}
    else:
        return {"success": False, "message": f"Username '{username}' is already taken"}
```

### Pattern 2: Optimistic Concurrency with Version Field

Simulate optimistic locking using a version column:

```sql
-- Table with a version column
CREATE TABLE game_inventory (
    game_id   uuid PRIMARY KEY,
    quantity  int,
    version   int
);

-- Insert initial record
INSERT INTO game_inventory (game_id, quantity, version)
VALUES (uuid(), 100, 1);
```

```python
def decrement_inventory(session, game_id, expected_version):
    prepared = session.prepare(
        "UPDATE game_inventory "
        "SET quantity = quantity - 1, version = version + 1 "
        "WHERE game_id = ? "
        "IF version = ?"
    )
    result = session.execute(prepared, (game_id, expected_version))
    row = result.one()

    if row.applied:
        return True
    else:
        print(f"Conflict: expected version {expected_version}, got {row.version}")
        return False
```

### Pattern 3: State Machine Transitions

Ensure a record only moves forward through defined states:

```sql
-- Transition an order from 'pending' to 'processing'
UPDATE orders_by_id
SET status = 'processing', updated_at = toTimestamp(now())
WHERE order_id = 'd1a2b3c4-...'
IF status = 'pending';

-- Transition from 'processing' to 'shipped'
UPDATE orders_by_id
SET status = 'shipped', shipped_at = toTimestamp(now())
WHERE order_id = 'd1a2b3c4-...'
IF status = 'processing';
```

### Pattern 4: Denormalized Write with Logged Batch

Keep multiple query tables synchronized:

```python
from cassandra.query import BatchStatement, BatchType

def add_review(session, game_title, username, rating, body, reviewed_at):
    # Insert to reviews_by_game (query: all reviews for a game)
    insert_by_game = session.prepare(
        "INSERT INTO reviews_by_game (game_title, reviewed_at, username, rating, body) "
        "VALUES (?, ?, ?, ?, ?)"
    )
    # Insert to reviews_by_user (query: all reviews by a user)
    insert_by_user = session.prepare(
        "INSERT INTO reviews_by_user (username, reviewed_at, game_title, rating, body) "
        "VALUES (?, ?, ?, ?, ?)"
    )

    batch = BatchStatement(batch_type=BatchType.LOGGED)
    batch.add(insert_by_game, (game_title, reviewed_at, username, rating, body))
    batch.add(insert_by_user, (username, reviewed_at, game_title, rating, body))

    session.execute(batch)
```

---

## LWT Limitations and Costs

### Performance Cost

LWT uses Paxos, which requires multiple round-trips between nodes. Expect roughly **4x the latency** of a normal write. Under heavy load, Paxos contention can cause LWT operations to time out.

### Scope

LWT only applies to a **single partition**. You cannot use `IF` conditions across multiple partitions in a single statement.

```sql
-- VALID: condition and write are in the same partition
UPDATE user_profiles SET email = 'new@example.com'
WHERE username = 'alice'
IF email = 'old@example.com';

-- NOT POSSIBLE: cannot condition on data in a different partition or table
```

### Mixing LWT and Non-LWT in Batches

You cannot mix LWT statements and regular statements in the same batch. A batch is either entirely LWT or entirely non-LWT.

```sql
-- INVALID: cannot mix IF and non-IF statements
BEGIN BATCH
    INSERT INTO user_profiles (username, email) VALUES ('alice', 'a@example.com') IF NOT EXISTS;
    INSERT INTO games_by_title (title, genre) VALUES ('New Game', 'Action');  -- Error!
APPLY BATCH;
```

### No Cross-Table LWT

You cannot atomically apply a conditional write to two different tables in a single operation. This is a fundamental limitation.

**Workaround**: Accept eventual consistency between tables and design idempotent writes. Use logged batches for delivery guarantees, not transactional guarantees.

---

## Comparing Cassandra LWT to MongoDB Transactions

| Feature | Cassandra LWT | MongoDB Multi-Document Transaction |
|---|---|---|
| Scope | Single partition only | Multiple documents, multiple collections |
| Mechanism | Paxos consensus | Snapshot isolation |
| Performance cost | High (~4x normal write) | Moderate |
| Rollback | Not supported | Full rollback |
| Cross-table atomicity | No | Yes |
| Best use case | Unique constraint, CAS | Complex business logic requiring atomicity |

---

## When to Use (and Avoid) LWT

**Use LWT when:**
- Enforcing uniqueness (e.g., unique usernames, unique email addresses)
- Implementing state machine transitions (pending -> processing -> shipped)
- Implementing optimistic concurrency control with a version field
- The operation is genuinely rare (not on the hot path)

**Avoid LWT when:**
- High throughput is required (LWT does not scale well under contention)
- The condition involves data from more than one partition
- A simpler design (e.g., using a UUID as the primary key) avoids the need entirely

---

**Last Updated**: April 20, 2026
**Course**: USJ IT Class 2026
**Module**: Cassandra Transactions
