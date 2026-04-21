# Author: Víctor Barceló
# Apache Cassandra - Concurrency Control

## Overview

Cassandra is designed for high write throughput across distributed nodes. Its concurrency model differs fundamentally from relational databases: there are no traditional locks on rows or tables. Instead, Cassandra relies on **last-write-wins (LWW)** conflict resolution, **tunable consistency levels**, **Multi-Version Concurrency Control (MVCC)** at the storage layer, and **Lightweight Transactions (LWT)** for cases where conditional writes are required.

---

## The Last-Write-Wins (LWW) Model

When two concurrent writes update the same cell, Cassandra uses the **write timestamp** to decide which value wins. The write with the higher timestamp is kept.

- Each write carries a timestamp (in microseconds since Unix epoch).
- By default, Cassandra uses the coordinator node's clock as the timestamp.
- A custom timestamp can be set explicitly using `USING TIMESTAMP`.

```sql
-- Explicit timestamp (microseconds)
INSERT INTO user_profiles (username, email)
VALUES ('alice', 'alice_v1@example.com')
USING TIMESTAMP 1713600000000000;

-- A later timestamp overwrites the earlier one
INSERT INTO user_profiles (username, email)
VALUES ('alice', 'alice_v2@example.com')
USING TIMESTAMP 1713600001000000;

-- alice_v2@example.com wins because its timestamp is higher
```

### Implications

- **Clock skew matters**: If two nodes have clocks out of sync, the wrong value may win. Synchronize clocks with NTP on all nodes.
- **Deletes use tombstones**: A DELETE is recorded as a special "tombstone" write with a timestamp. If a concurrent INSERT has a later timestamp than the tombstone, the inserted value reappears after the tombstone expires (the "zombie resurrection" problem).
- **LWW is not suitable for counters**: Use the `counter` data type instead, which uses a CRDT-based approach.

---

## Consistency Levels

Cassandra's tunable consistency levels control how many replicas must participate in a read or write before the operation is acknowledged. This is the primary mechanism for trading availability against consistency.

### Write Consistency Levels

| Level | Replicas that must acknowledge |
|---|---|
| `ANY` | At least one node (including hinted handoff). Lowest durability. |
| `ONE` | One replica. |
| `TWO` | Two replicas. |
| `THREE` | Three replicas. |
| `QUORUM` | Majority: `floor(RF / 2) + 1` |
| `LOCAL_QUORUM` | Quorum within the local datacenter. |
| `EACH_QUORUM` | Quorum in every datacenter. |
| `ALL` | Every replica. Highest durability, lowest availability. |

### Read Consistency Levels

| Level | Replicas that must respond |
|---|---|
| `ONE` | One replica (may return stale data). |
| `TWO` | Two replicas. |
| `THREE` | Three replicas. |
| `QUORUM` | Majority: `floor(RF / 2) + 1` |
| `LOCAL_QUORUM` | Quorum within the local datacenter. |
| `ALL` | Every replica (strongest consistency). |
| `SERIAL` | Read the latest committed LWT value (linearizable). |
| `LOCAL_SERIAL` | Linearizable read within local datacenter. |

### Setting Consistency in cqlsh

```sql
-- Check current consistency level
CONSISTENCY;

-- Set for the current session
CONSISTENCY QUORUM;

-- Now all queries in this session use QUORUM
SELECT * FROM user_profiles WHERE username = 'alice';
```

### Setting Consistency in Python

```python
from cassandra.cluster import Cluster
from cassandra.policies import ConsistencyLevel
from cassandra.query import SimpleStatement

cluster = Cluster(['127.0.0.1'])
session = cluster.connect('gameverse')

# Per-query consistency level
stmt = SimpleStatement(
    "SELECT * FROM user_profiles WHERE username = %s",
    consistency_level=ConsistencyLevel.QUORUM
)
rows = session.execute(stmt, ('alice',))

# Default consistency for all queries on the session
from cassandra import ConsistencyLevel as CL
session.default_consistency_level = CL.LOCAL_QUORUM
```

### Setting Consistency in Java

```java
import com.datastax.oss.driver.api.core.ConsistencyLevel;
import com.datastax.oss.driver.api.core.cql.SimpleStatement;

SimpleStatement stmt = SimpleStatement.builder(
        "SELECT * FROM gameverse.user_profiles WHERE username = ?")
    .setConsistencyLevel(ConsistencyLevel.QUORUM)
    .build();

session.execute(stmt.bind("alice"));
```

---

## Strong Consistency

To guarantee that a read always reflects the most recent committed write (strong consistency), the sum of the read and write consistency levels must exceed the replication factor:

$$CL_{write} + CL_{read} > RF$$

**Example with RF = 3:**

| Write CL | Read CL | Sum | Strongly Consistent? |
|---|---|---|---|
| `QUORUM` (2) | `QUORUM` (2) | 4 | Yes (4 > 3) |
| `ALL` (3) | `ONE` (1) | 4 | Yes (4 > 3) |
| `ONE` (1) | `ALL` (3) | 4 | Yes (4 > 3) |
| `ONE` (1) | `ONE` (1) | 2 | No (2 <= 3) |
| `ONE` (1) | `QUORUM` (2) | 3 | No (3 <= 3) |

For most production workloads, **`LOCAL_QUORUM`** for both reads and writes is the recommended starting point. It provides strong consistency within a single datacenter without requiring cross-datacenter coordination.

---

## MVCC and the Storage Engine

Cassandra's storage engine (based on LSM trees) uses a form of **Multi-Version Concurrency Control (MVCC)**:

- Writes are always appended — they never overwrite existing data on disk immediately.
- Each write is a new immutable version with a timestamp.
- Reads merge all versions in memory (Memtable) and on disk (SSTables) and return the value with the highest timestamp.
- Old versions are cleaned up during **compaction**.

This means:
- **Reads never block writes** and writes never block reads.
- Concurrent reads and writes to the same partition do not cause contention in the traditional locking sense.
- Conflict resolution is purely timestamp-based (LWW).

---

## Read Repair

When a read detects that some replicas have stale data (different values), Cassandra can repair the inconsistency in two ways:

- **Foreground read repair**: The coordinator waits for all contacted replicas, compares responses, and sends a repair to stale replicas before returning the result. Controlled by the read consistency level.
- **Background read repair**: Triggered probabilistically after a read returns. Configurable per table with `read_repair` option.

```sql
-- Table with background read repair enabled (default)
CREATE TABLE user_profiles (
    username text PRIMARY KEY,
    email    text
) WITH read_repair = 'BLOCKING';   -- Options: BLOCKING, NONE
```

Read repair helps keep replicas consistent over time but adds latency to the operations that trigger it.

---

## Lightweight Transactions (LWT) for Concurrent Writes

When LWW is not acceptable (for example, when two clients must not overwrite each other's changes without knowing), use LWT. LWT provides **linearizable consistency** for a single partition using Paxos.

### Conditional Update (Compare-and-Set)

```sql
-- Only update email if we know the current value (optimistic lock)
UPDATE user_profiles
SET email = 'alice_new@example.com'
WHERE username = 'alice'
IF email = 'alice_old@example.com';
```

If a concurrent writer has already changed the email, this update will not be applied. The response shows `[applied] = False` along with the current values.

### Versioned Row Pattern

Add a `version` column to detect concurrent modifications:

```sql
CREATE TABLE game_state (
    game_id  uuid PRIMARY KEY,
    state    text,
    version  int
);
```

```python
def update_game_state(session, game_id, new_state, expected_version):
    prepared = session.prepare(
        "UPDATE game_state SET state = ?, version = ? "
        "WHERE game_id = ? IF version = ?"
    )
    result = session.execute(
        prepared, (new_state, expected_version + 1, game_id, expected_version)
    )
    row = result.one()

    if row.applied:
        return True
    else:
        print(f"Conflict: expected version {expected_version}, actual {row.version}")
        return False
```

---

## Handling Concurrent Writes in Practice

### Idempotent Writes

Design writes to be idempotent wherever possible. If the same write can be safely retried without side effects, concurrency issues become much easier to handle.

```sql
-- Idempotent: inserting the same row twice produces the same result
INSERT INTO user_profiles (username, email, full_name)
VALUES ('alice', 'alice@example.com', 'Alice Johnson');

-- Non-idempotent: counter increments cannot be safely retried
UPDATE page_views SET view_count = view_count + 1 WHERE page_id = 'homepage';
-- If this is retried after a timeout (when you don't know if it succeeded),
-- the counter may be double-incremented. Use the counter type instead.
```

### Distributed Counters

Use the `counter` type for shared counters. Cassandra uses a CRDT (Conflict-free Replicated Data Type) approach internally to merge concurrent increments correctly across replicas.

```sql
CREATE TABLE page_views (
    page_id    text PRIMARY KEY,
    view_count counter
);

-- Safe concurrent increment
UPDATE page_views SET view_count = view_count + 1 WHERE page_id = 'homepage';
```

Multiple clients can increment the counter simultaneously and the results will be merged correctly — no LWT required.

### Write Retry on Timeout

When a write times out, you do not know whether it was applied. For regular writes (non-LWT), it is safe to retry if the write is idempotent.

**Python with automatic retry**:
```python
from cassandra.cluster import Cluster
from cassandra.policies import RetryPolicy, ExponentialReconnectionPolicy

cluster = Cluster(
    ['127.0.0.1'],
    reconnection_policy=ExponentialReconnectionPolicy(base_delay=1.0, max_delay=60.0)
)
session = cluster.connect('gameverse')
```

For a custom retry strategy on write timeouts, implement a `RetryPolicy`:

```python
from cassandra.policies import RetryPolicy

class IdempotentWriteRetryPolicy(RetryPolicy):
    def on_write_timeout(self, query, consistency, write_type,
                         required_responses, received_responses, retry_num):
        if retry_num < 3:
            return self.RETRY, consistency
        return self.RETHROW, None
```

### Queue Pattern (Avoid)

Cassandra is not well-suited for queue patterns where rows are consumed and deleted concurrently. The anti-pattern looks like:

```sql
-- Worker picks an unprocessed task
SELECT * FROM task_queue WHERE status = 'pending' LIMIT 1 ALLOW FILTERING;  -- Bad!

-- Two workers may claim the same task
UPDATE task_queue SET status = 'processing' WHERE task_id = ?;
```

If you need a queue, use an LWT to claim tasks:

```sql
-- Safer: claim a specific task atomically
UPDATE task_queue
SET status = 'processing', worker_id = 'worker-1'
WHERE task_id = ?
IF status = 'pending';
```

Or better, use a dedicated message queue (Apache Kafka, RabbitMQ) for queue workloads and use Cassandra only for persistent storage.

---

## Monitoring Concurrency Issues

### Dropped Messages

Dropped messages indicate overload — nodes are receiving more requests than they can handle:

```bash
nodetool tpstats
```

Look at `Dropped` counts for `READ`, `WRITE`, and `REQUEST_RESPONSE`.

### Read/Write Latency

```bash
nodetool tablestats gameverse.user_profiles
```

Key metrics:
- `Local read latency`
- `Local write latency`
- `Pending compactions`

### Timeout Configuration

Timeouts are configured in `cassandra.yaml`:

```yaml
# Time to wait for a read response
read_request_timeout_in_ms: 5000

# Time to wait for a write response
write_request_timeout_in_ms: 2000

# Time to wait for a counter write
counter_write_request_timeout_in_ms: 5000

# Time to wait for a CAS (LWT) operation
cas_contention_timeout_in_ms: 1000

# Overall request timeout
request_timeout_in_ms: 10000
```

### Paxos Contention (LWT)

High LWT contention shows as slow or failed CAS operations. Check for:

```bash
grep "CAS" /var/log/cassandra/system.log
grep "paxos" /var/log/cassandra/system.log
```

Reduce LWT contention by:
- Reducing the rate of LWT operations
- Partitioning the data so fewer clients contend on the same partition
- Increasing `cas_contention_timeout_in_ms`

---

## Best Practices

### Choose the Right Consistency Level

Match the consistency level to the business requirement:

```python
# Critical financial write: use QUORUM or higher
session.execute(
    SimpleStatement(
        "INSERT INTO payments (...) VALUES (...)",
        consistency_level=ConsistencyLevel.QUORUM
    )
)

# Analytics read where stale data is acceptable: use ONE
session.execute(
    SimpleStatement(
        "SELECT * FROM metrics WHERE ...",
        consistency_level=ConsistencyLevel.ONE
    )
)
```

### Use SERIAL for Linearizable Reads After LWT

After writing with LWT, use `SERIAL` consistency to read the latest committed value:

```python
from cassandra import ConsistencyLevel

stmt = SimpleStatement(
    "SELECT * FROM user_profiles WHERE username = %s",
    consistency_level=ConsistencyLevel.SERIAL
)
row = session.execute(stmt, ('alice',)).one()
```

### Keep LWT Usage to a Minimum

LWT operations are expensive. Redesign the data model to avoid them wherever possible:

- Use UUIDs as primary keys to guarantee uniqueness without `IF NOT EXISTS`.
- Accept eventual consistency for most reads.
- Use the `counter` type instead of LWT for shared counters.

### Synchronize Clocks

Ensure NTP is running on all Cassandra nodes. Clock skew causes incorrect LWW resolution and can lead to data inconsistency.

```bash
# Check time sync status
timedatectl status
chronyc tracking
```

---

**Last Updated**: April 20, 2026
**Course**: USJ IT Class 2026
**Module**: Cassandra Concurrency Control
