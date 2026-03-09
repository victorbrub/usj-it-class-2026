# Database Optimization - Complete Guide

## Overview

Database optimization at the structural level focuses on how data is physically stored and organized. Three fundamental techniques are:

- **Indexing**: Fast lookup structures that avoid full table scans
- **Partitioning**: Splitting large tables into smaller, manageable pieces
- **Clustering**: Physically reordering table rows to match a given index

Together these techniques reduce I/O, improve query response times, and keep maintenance operations (VACUUM, backups) efficient as your dataset grows.

---

## Part 1: Indexing

### What is an Index?

An index is a separate data structure that maps column values to the physical location of rows in a table. Without an index, PostgreSQL must read every row (sequential scan). With a suitable index, it can jump directly to matching rows.

Indexes consume disk space and add overhead to `INSERT`, `UPDATE`, and `DELETE` operations. The goal is to create indexes that are used often enough to justify that overhead.

### B-tree Index (Default)

The default and most general-purpose index type. Supports equality (`=`), range comparisons (`<`, `>`, `BETWEEN`), `IN`, `IS NULL`, and ordered output (`ORDER BY`).

```sql
-- Single-column B-tree index
CREATE INDEX idx_orders_customer_id ON orders (customer_id);

-- Multi-column (composite) B-tree index
-- Useful for queries that filter on both columns together,
-- or queries that filter on the leftmost column alone
CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);

-- Unique index (also enforces uniqueness constraint)
CREATE UNIQUE INDEX idx_users_email ON users (email);
```

#### Column Order in Composite Indexes

The leftmost column of a composite index can be used independently. Subsequent columns are only used when all columns to their left are also in the predicate.

```sql
-- idx_orders_customer_status can accelerate:
SELECT * FROM orders WHERE customer_id = 5;                        -- Left prefix
SELECT * FROM orders WHERE customer_id = 5 AND status = 'pending'; -- Full index

-- But NOT efficiently:
SELECT * FROM orders WHERE status = 'pending';  -- No left-prefix match
```

### Hash Index

Supports only equality comparisons (`=`). Smaller than B-tree for high-cardinality equality lookups. Cannot be used for range queries or sorting.

```sql
CREATE INDEX idx_sessions_token ON sessions USING HASH (session_token);
```

### GIN Index (Generalized Inverted Index)

Best for multi-valued data types: arrays, JSONB, full-text search (`tsvector`).

```sql
-- Index a JSONB column for containment queries
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);
SELECT * FROM products WHERE attributes @> '{"color": "red"}';

-- Full-text search
CREATE INDEX idx_articles_content ON articles USING GIN (to_tsvector('english', content));
SELECT * FROM articles WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'database optimization');

-- Text pattern matching with trigrams (pg_trgm)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);
SELECT * FROM products WHERE name ILIKE '%widget%';
```

### GiST Index (Generalized Search Tree)

Used for geometric data types, range types, and nearest-neighbor searches.

```sql
-- Spatial data (PostGIS)
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);

-- Range type overlaps
CREATE INDEX idx_reservations_period ON reservations USING GIST (period);
SELECT * FROM reservations WHERE period && '[2026-01-01, 2026-01-31]'::daterange;
```

### BRIN Index (Block Range Index)

Very small index for large tables where column values correlate with physical storage order (e.g., a timestamp column that is always inserted in order).

```sql
-- Extremely compact; suitable for time-series or log tables
CREATE INDEX idx_logs_created_at ON logs USING BRIN (created_at);
```

BRIN stores the minimum and maximum value per range of data pages, not per row. It is much smaller than B-tree but less precise - PostgreSQL will still need to check more rows but avoids reading unrelated page ranges.

### Functional (Expression) Indexes

Index the result of an expression rather than a raw column value.

```sql
-- Allow case-insensitive lookups
CREATE INDEX idx_users_email_lower ON users (LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'alice@example.com';

-- Index a computed date part
CREATE INDEX idx_orders_year ON orders (EXTRACT(YEAR FROM created_at));
SELECT * FROM orders WHERE EXTRACT(YEAR FROM created_at) = 2025;
```

### Partial Indexes

Index only a subset of rows matching a condition. Smaller, faster to scan, and cheaper to maintain.

```sql
-- Only index unprocessed orders
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';
SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;

-- Only index non-deleted records
CREATE INDEX idx_users_active ON users (email) WHERE deleted_at IS NULL;
```

### Covering Indexes (INCLUDE)

Store additional columns in the index leaf pages so that index-only scans are possible.

```sql
-- The query can be satisfied entirely from the index (no heap access)
CREATE INDEX idx_orders_customer_covering ON orders (customer_id) INCLUDE (total_amount, status);

SELECT customer_id, total_amount, status
FROM orders
WHERE customer_id = 42;
-- Uses Index Only Scan - no heap fetch required
```

### Index Maintenance

```sql
-- Remove an unused index
DROP INDEX idx_orders_customer_id;

-- Rebuild an index without locking the table
REINDEX INDEX CONCURRENTLY idx_orders_customer_id;

-- View index usage statistics
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find unused indexes (candidates for removal)
SELECT indexrelid::regclass AS index, relid::regclass AS table, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

---

## Part 2: Table Partitioning

### What is Partitioning?

Partitioning divides a large table into smaller physical subtables called **partitions**. Queries that filter on the partition key can skip irrelevant partitions entirely (**partition pruning**), dramatically reducing the amount of data scanned.

PostgreSQL supports **declarative partitioning** (introduced in version 10, significantly improved in 11+).

### Partition Types

| Type | Description | Best For |
|------|-------------|----------|
| Range | Partitions rows where key falls within a range | Dates, sequential IDs |
| List | Partitions rows by a discrete set of values | Regions, categories, status |
| Hash | Distributes rows evenly across N partitions | Evenly distributing any key |

### Range Partitioning

Typical use case: time-series data where queries filter on a date column.

```sql
-- Create the partitioned parent table
CREATE TABLE orders (
    order_id     BIGSERIAL,
    customer_id  INTEGER NOT NULL,
    total_amount NUMERIC(12, 2),
    status       VARCHAR(20),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create individual partitions
CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- A DEFAULT partition catches rows that match no other partition
CREATE TABLE orders_default PARTITION OF orders DEFAULT;
```

Inserting and querying the parent table works transparently:

```sql
INSERT INTO orders (customer_id, total_amount, status, created_at)
VALUES (1, 99.99, 'completed', '2025-03-15');

-- Partition pruning: only orders_2025 is scanned
EXPLAIN SELECT * FROM orders WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
```

### List Partitioning

Use when the partition key has a finite set of meaningful values.

```sql
CREATE TABLE sales (
    sale_id    BIGSERIAL,
    region     VARCHAR(20) NOT NULL,
    amount     NUMERIC(12, 2),
    sale_date  DATE
) PARTITION BY LIST (region);

CREATE TABLE sales_europe   PARTITION OF sales FOR VALUES IN ('ES', 'FR', 'DE', 'IT');
CREATE TABLE sales_americas PARTITION OF sales FOR VALUES IN ('US', 'CA', 'MX', 'BR');
CREATE TABLE sales_apac     PARTITION OF sales FOR VALUES IN ('JP', 'CN', 'AU', 'IN');
CREATE TABLE sales_other    PARTITION OF sales DEFAULT;
```

### Hash Partitioning

Distributes rows evenly when no natural range or list grouping exists.

```sql
CREATE TABLE user_events (
    event_id   BIGSERIAL,
    user_id    INTEGER NOT NULL,
    event_type VARCHAR(50),
    occurred_at TIMESTAMPTZ
) PARTITION BY HASH (user_id);

CREATE TABLE user_events_0 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE user_events_1 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE user_events_2 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE user_events_3 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### Indexes on Partitioned Tables

In PostgreSQL 11+, indexes created on the parent table are automatically propagated to all partitions.

```sql
CREATE INDEX idx_orders_customer ON orders (customer_id);
-- Automatically creates the same index on orders_2024, orders_2025, orders_2026
```

### Sub-partitioning

Partitions can themselves be partitioned (composite partitioning).

```sql
-- Partition by year first, then by status within each year
CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01')
    PARTITION BY LIST (status);

CREATE TABLE orders_2025_completed PARTITION OF orders_2025 FOR VALUES IN ('completed');
CREATE TABLE orders_2025_pending   PARTITION OF orders_2025 FOR VALUES IN ('pending');
CREATE TABLE orders_2025_other     PARTITION OF orders_2025 DEFAULT;
```

### Partition Management

```sql
-- Detach a partition (makes it an ordinary table; fast, no data copy)
ALTER TABLE orders DETACH PARTITION orders_2024;

-- Attach an existing table as a partition
ALTER TABLE orders ATTACH PARTITION orders_2023
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Drop old data efficiently (much faster than DELETE)
DROP TABLE orders_2022;

-- View partitions and their row counts
SELECT
    child.relname AS partition,
    pg_relation_size(child.oid) AS size_bytes,
    pg_size_pretty(pg_relation_size(child.oid)) AS size_pretty
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
WHERE parent.relname = 'orders';
```

### Partition Pruning Verification

```sql
-- Confirm that only relevant partitions are accessed
SET enable_partition_pruning = on;  -- Default: on

EXPLAIN SELECT COUNT(*) FROM orders WHERE created_at >= '2026-01-01';
-- You should see only orders_2026 in the plan, not older partitions
```

---

## Part 3: Clustering

### What is Clustering?

`CLUSTER` physically rewrites a table so that its rows are stored on disk in the order defined by a given index. After clustering, sequential scans that follow that order benefit from excellent data locality - related rows are on the same disk pages.

### When to Use CLUSTER

- The table is read far more often than it is written
- Queries consistently filter or sort on a column that has a B-tree index
- The table is large enough that I/O locality matters
- You can afford brief table-level locking (PostgreSQL's `CLUSTER` locks the table)

### Basic Usage

```sql
-- Ensure an index exists on the desired column
CREATE INDEX idx_orders_created_at ON orders (created_at);

-- Reorder the physical rows to match that index
CLUSTER orders USING idx_orders_created_at;

-- Re-cluster using the previously recorded index (no index name needed)
CLUSTER orders;

-- Cluster all tables in the current database that have a recorded cluster index
CLUSTER;
```

After `CLUSTER`, the index association is remembered. New rows inserted afterward are not automatically placed in order; you need to run `CLUSTER` again periodically to maintain locality.

### CLUSTER vs. Index Scan Performance

Before clustering on `created_at`:
- A query for `WHERE created_at BETWEEN '2026-01-01' AND '2026-01-31'` may need to fetch rows scattered across many different heap pages.

After clustering:
- Those rows are concentrated on a much smaller set of contiguous pages, requiring far fewer I/O operations.

### Example with the GameVerse Database

```sql
-- The game_sessions table is heavy on time-range queries
CREATE INDEX idx_game_sessions_started_at ON game_sessions (started_at);
CLUSTER game_sessions USING idx_game_sessions_started_at;

-- Verify with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT * FROM game_sessions
WHERE started_at BETWEEN '2026-01-01' AND '2026-01-31';
```

### CLUSTER vs. pg_repack

`CLUSTER` acquires an exclusive lock, blocking reads and writes during the operation. For production environments, **pg_repack** is a popular extension that performs equivalent reordering online (without prolonged table locks).

```sql
-- With pg_repack extension installed:
-- pg_repack --table game_sessions --order-by started_at mydb
```

---

## Combining Indexing, Partitioning, and Clustering

These techniques are complementary and often used together:

| Scenario | Recommended Approach |
|----------|---------------------|
| Frequently queried column with high selectivity | B-tree index |
| JSONB or array column with containment queries | GIN index |
| Very large table with time-based queries | Range partition by date |
| Time-series table scanned in time order | CLUSTER on timestamp column |
| Large table, rare leading-wildcard text search | GIN with pg_trgm |
| Table that grows only by appending | BRIN index on insertion-order column |
| Need to drop old data efficiently | Partition by date, drop old partition |

### Practical Example: Large Orders Table

```sql
-- 1. Partition by year for efficient pruning and old-data management
CREATE TABLE orders (
    order_id     BIGSERIAL,
    customer_id  INTEGER NOT NULL,
    total_amount NUMERIC(12, 2),
    status       VARCHAR(20),
    created_at   TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- 2. Index the most selective lookup columns
CREATE INDEX idx_orders_customer ON orders (customer_id);     -- Equality lookups
CREATE INDEX idx_orders_status   ON orders (status) WHERE status != 'completed';  -- Partial

-- 3. Cluster the current active partition on insertion timestamp
--    (good for range scans within the year)
CREATE INDEX idx_orders_2026_created ON orders_2026 (created_at);
CLUSTER orders_2026 USING idx_orders_2026_created;
```

---

## Monitoring Index and Partition Usage

```sql
-- Index hit rate (should be > 99% for OLTP workloads)
SELECT
    relname AS table,
    idx_scan,
    seq_scan,
    ROUND(idx_scan::numeric / NULLIF(idx_scan + seq_scan, 0) * 100, 2) AS index_hit_pct
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- Table and index sizes
SELECT
    relname AS table,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_indexes_size(relid)) AS indexes_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Bloat check - tables with many dead rows (candidates for VACUUM or CLUSTER)
SELECT relname, n_dead_tup, n_live_tup,
       ROUND(n_dead_tup::numeric / NULLIF(n_live_tup, 0) * 100, 2) AS bloat_pct
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY bloat_pct DESC;
```

---

## Summary

| Technique | Primary Benefit | Key Consideration |
|-----------|----------------|-------------------|
| B-tree Index | Fast equality and range queries | Overhead on writes; avoid unused indexes |
| Partial Index | Smaller index for a filtered subset | Predicate must match query WHERE clause |
| Functional Index | Index computed expressions | Expression in query must match exactly |
| Covering Index | Avoids heap access entirely | Extra storage; useful for read-heavy tables |
| GIN Index | Efficient searches in arrays/JSONB/text | Larger and slower to update than B-tree |
| BRIN Index | Minimal size for append-only, correlated data | Less precise; requires correlation |
| Range Partitioning | Partition pruning for time-series data | Choose partition size to balance pruning vs. overhead |
| List Partitioning | Isolate rows by category or region | Partition for each category must be defined |
| Hash Partitioning | Even data distribution | No pruning benefit for equality on non-hash key |
| CLUSTER | Heap locality for range scans | Locks table; re-run periodically |
