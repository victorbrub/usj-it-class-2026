# Database Optimization - Practice Exercises

## Instructions

Complete the following exercises to practice creating indexes, partitioning tables, and clustering data. Use the GameVerse database or the setup script below.

**Time Allocation**: 120-150 minutes  
**Difficulty**: Beginner to Advanced  
**Prerequisites**: SQL basics, understanding of query execution plans

---

## Setup

Run the following script to create the tables used in these exercises:

```sql
-- Main orders table (will be partitioned later)
CREATE TABLE orders_unpartitioned (
    order_id     BIGSERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL,
    total_amount NUMERIC(12, 2),
    status       VARCHAR(20) DEFAULT 'pending',
    region       CHAR(2),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Populate with sample data spanning multiple years
INSERT INTO orders_unpartitioned (customer_id, total_amount, status, region, created_at)
SELECT
    (random() * 9999 + 1)::integer,
    (random() * 500 + 5)::numeric(12,2),
    CASE (i % 5)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        ELSE 'completed'
    END,
    CASE (i % 3) WHEN 0 THEN 'ES' WHEN 1 THEN 'US' ELSE 'FR' END,
    TIMESTAMP '2022-01-01' + (random() * 1460 || ' days')::interval
FROM generate_series(1, 500000) i;

-- Product table for index exercises
CREATE TABLE products (
    product_id  BIGSERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    category    VARCHAR(50),
    price       NUMERIC(10, 2),
    stock       INTEGER DEFAULT 0,
    attributes  JSONB,
    deleted_at  TIMESTAMPTZ
);

INSERT INTO products (name, category, price, stock, attributes)
SELECT
    'Product ' || i,
    CASE (i % 4) WHEN 0 THEN 'game' WHEN 1 THEN 'dlc' WHEN 2 THEN 'hardware' ELSE 'merchandise' END,
    (random() * 200 + 0.99)::numeric(10,2),
    (random() * 500)::integer,
    jsonb_build_object(
        'color', CASE (i % 3) WHEN 0 THEN 'red' WHEN 1 THEN 'blue' ELSE 'green' END,
        'weight_kg', round((random() * 2 + 0.1)::numeric, 2)
    )
FROM generate_series(1, 100000) i;

ANALYZE orders_unpartitioned, products;
```

---

## Part 1: Indexing

### Exercise 1: B-tree Index - Equality Lookup

The following query performs a sequential scan:

```sql
EXPLAIN ANALYZE
SELECT * FROM orders_unpartitioned WHERE customer_id = 500;
```

1. Record the current execution time and scan type.
2. Create a B-tree index on `customer_id`.
3. Run the same EXPLAIN ANALYZE again and compare results.
4. Drop the index when done: `DROP INDEX <index_name>;`

**Checkpoint**: What is the approximate speedup?

---

### Exercise 2: Composite Index and Column Order

```sql
EXPLAIN ANALYZE
SELECT order_id, total_amount
FROM orders_unpartitioned
WHERE customer_id = 200 AND status = 'pending';
```

1. Create a composite index on `(customer_id, status)`.
2. Verify with EXPLAIN that it is used for the query above.
3. Run EXPLAIN for this query:
   ```sql
   SELECT order_id FROM orders_unpartitioned WHERE status = 'pending';
   ```
   Is the composite index used? Why or why not?
4. Create a second index with reversed column order `(status, customer_id)`. Which index does the planner prefer for each query?

**Deliverable**: Both EXPLAIN outputs with written explanation of column order importance.

---

### Exercise 3: Partial Index

Most queries that poll for work filter on `status = 'pending'`, which represents only a small fraction of rows.

1. Create a partial index covering only pending orders:
   ```sql
   CREATE INDEX idx_orders_pending ON orders_unpartitioned (created_at)
   WHERE status = 'pending';
   ```
2. Run EXPLAIN ANALYZE on:
   ```sql
   SELECT * FROM orders_unpartitioned WHERE status = 'pending' ORDER BY created_at LIMIT 100;
   ```
3. How does the size of this partial index compare to a full index on `(status, created_at)`?
   ```sql
   SELECT pg_size_pretty(pg_relation_size('idx_orders_pending'));
   ```
4. Does the partial index help a query that does NOT include `WHERE status = 'pending'`? Test it.

**Deliverable**: Index size comparison and EXPLAIN outputs.

---

### Exercise 4: Functional Index

```sql
EXPLAIN SELECT * FROM products WHERE LOWER(name) = 'product 1000';
```

1. Is any index used? Why not?
2. Create a functional index:
   ```sql
   CREATE INDEX idx_products_name_lower ON products (LOWER(name));
   ```
3. Run the same EXPLAIN. Is the index now used?
4. Write a query that would NOT benefit from this functional index (even though it uses the `name` column) and explain why.

**Deliverable**: Functional index DDL and EXPLAIN outputs before and after.

---

### Exercise 5: GIN Index for JSONB

The `attributes` column stores JSON data. Run:

```sql
EXPLAIN ANALYZE
SELECT * FROM products WHERE attributes @> '{"color": "red"}';
```

1. Record the execution plan (expect a Seq Scan).
2. Create a GIN index:
   ```sql
   CREATE INDEX idx_products_attributes ON products USING GIN (attributes);
   ```
3. Run the query again. Is the GIN index used?
4. Test another containment query: `WHERE attributes @> '{"weight_kg": 1.5}'`. Is the index used?

**Deliverable**: EXPLAIN outputs before and after the GIN index.

---

### Exercise 6: Covering Index (INCLUDE)

```sql
EXPLAIN ANALYZE
SELECT customer_id, total_amount, status
FROM orders_unpartitioned
WHERE customer_id = 42;
```

1. Create a regular index on `customer_id` and run EXPLAIN ANALYZE. Note whether the query uses Index Scan or Index Only Scan.
2. Drop the index and create a covering index instead:
   ```sql
   CREATE INDEX idx_orders_customer_cover ON orders_unpartitioned (customer_id)
   INCLUDE (total_amount, status);
   ```
3. Run EXPLAIN ANALYZE again. Does it now use an Index Only Scan? What is the benefit?

**Deliverable**: Both EXPLAIN outputs with written explanation.

---

### Exercise 7: Finding and Removing Unused Indexes

1. Create two indexes that will not be used:
   ```sql
   CREATE INDEX idx_unused_1 ON products (stock);
   CREATE INDEX idx_unused_2 ON orders_unpartitioned (region, total_amount);
   ```
2. Run several queries that do NOT use these indexes.
3. Query the index usage statistics:
   ```sql
   SELECT schemaname, tablename, indexname, idx_scan
   FROM pg_stat_user_indexes
   WHERE idx_scan = 0
   ORDER BY tablename, indexname;
   ```
4. Drop the unused indexes.

**Checkpoint**: Why is it important to remove indexes that are never used?

---

## Part 2: Partitioning

### Exercise 8: Range Partitioning by Date

Convert `orders_unpartitioned` into a partitioned table:

1. Create a new partitioned table:
   ```sql
   CREATE TABLE orders (
       order_id     BIGSERIAL,
       customer_id  INTEGER NOT NULL,
       total_amount NUMERIC(12, 2),
       status       VARCHAR(20),
       region       CHAR(2),
       created_at   TIMESTAMPTZ NOT NULL
   ) PARTITION BY RANGE (created_at);
   ```

2. Create yearly partitions for 2022-2026 and a default partition.

3. Insert the data from `orders_unpartitioned`:
   ```sql
   INSERT INTO orders SELECT * FROM orders_unpartitioned;
   ```

4. Run EXPLAIN on a date-restricted query and confirm partition pruning is active:
   ```sql
   EXPLAIN SELECT COUNT(*) FROM orders WHERE created_at >= '2026-01-01';
   ```
   How many partitions appear in the plan?

**Deliverable**: DDL for all partitions plus EXPLAIN output demonstrating pruning.

---

### Exercise 9: List Partitioning by Region

1. Create a list-partitioned table for sales by region:
   ```sql
   CREATE TABLE regional_sales (
       sale_id    BIGSERIAL,
       region     CHAR(2) NOT NULL,
       amount     NUMERIC(12, 2),
       sale_date  DATE NOT NULL
   ) PARTITION BY LIST (region);
   ```

2. Create the following partitions:
   - `regional_sales_europe`: regions ES, FR, DE, IT
   - `regional_sales_americas`: regions US, CA, MX, BR
   - `regional_sales_other`: DEFAULT

3. Insert sample rows for each region and verify they land in the correct partition:
   ```sql
   SELECT tableoid::regclass AS partition, region, COUNT(*)
   FROM regional_sales
   GROUP BY 1, 2
   ORDER BY 1, 2;
   ```

4. Run a query filtering on `region = 'ES'` and check the EXPLAIN output for partition pruning.

**Deliverable**: DDL, sample inserts, and EXPLAIN output.

---

### Exercise 10: Hash Partitioning

1. Create a hash-partitioned table:
   ```sql
   CREATE TABLE user_events (
       event_id    BIGSERIAL,
       user_id     INTEGER NOT NULL,
       event_type  VARCHAR(50),
       occurred_at TIMESTAMPTZ DEFAULT NOW()
   ) PARTITION BY HASH (user_id);
   ```

2. Create 4 partitions.

3. Insert 100,000 sample rows with random `user_id` values.

4. Check the row distribution across partitions:
   ```sql
   SELECT tableoid::regclass AS partition, COUNT(*)
   FROM user_events
   GROUP BY 1
   ORDER BY 1;
   ```
   Is the distribution roughly equal?

5. Run EXPLAIN for `WHERE user_id = 12345`. How many partitions are scanned?

**Deliverable**: DDL, distribution query output, and EXPLAIN output.

---

### Exercise 11: Partition Management - Detach and Drop

Starting from the partitioned `orders` table created in Exercise 8:

1. Detach the 2022 partition without deleting data:
   ```sql
   ALTER TABLE orders DETACH PARTITION orders_2022;
   ```
2. Verify that the detached table still exists and contains data.
3. Archive the data by renaming the table:
   ```sql
   ALTER TABLE orders_2022 RENAME TO orders_archive_2022;
   ```
4. Drop the now-unnecessary 2022 data:
   ```sql
   DROP TABLE orders_archive_2022;
   ```
5. Compare the time this takes vs. running `DELETE FROM orders WHERE created_at < '2023-01-01'`.

**Checkpoint**: Why is dropping a partition faster than deleting rows?

---

### Exercise 12: Indexes on Partitioned Tables

Continuing with the `orders` partitioned table:

1. Create a global index on `customer_id`:
   ```sql
   CREATE INDEX idx_orders_part_customer ON orders (customer_id);
   ```
2. Verify that the index was created on the parent and each partition:
   ```sql
   SELECT indexname, tablename
   FROM pg_indexes
   WHERE tablename LIKE 'orders%'
   ORDER BY tablename, indexname;
   ```
3. Run EXPLAIN ANALYZE on:
   ```sql
   SELECT * FROM orders WHERE customer_id = 42;
   ```
   Does partition pruning still apply even though `customer_id` is not the partition key?

**Deliverable**: Index listing and EXPLAIN output.

---

## Part 3: Clustering

### Exercise 13: Basic CLUSTER Operation

The `orders_unpartitioned` table has rows in insertion order. Many queries filter by `created_at` range.

1. Run EXPLAIN ANALYZE on a range query and record the Buffers count (add `BUFFERS` option):
   ```sql
   EXPLAIN (ANALYZE, BUFFERS)
   SELECT * FROM orders_unpartitioned
   WHERE created_at BETWEEN '2024-06-01' AND '2024-08-31';
   ```

2. Create an index on `created_at` if it does not exist.

3. Cluster the table:
   ```sql
   CLUSTER orders_unpartitioned USING <your_index_name>;
   ```

4. Run the same EXPLAIN (ANALYZE, BUFFERS) again. How do the Buffers counts compare?

**Deliverable**: Both EXPLAIN (ANALYZE, BUFFERS) outputs with written comparison.

---

### Exercise 14: CLUSTER on a Smaller Table

1. Create a smaller table to observe clustering effects more directly:
   ```sql
   CREATE TABLE game_sessions (
       session_id  SERIAL PRIMARY KEY,
       user_id     INTEGER,
       game_id     INTEGER,
       started_at  TIMESTAMPTZ,
       duration_s  INTEGER
   );

   INSERT INTO game_sessions (user_id, game_id, started_at, duration_s)
   SELECT
       (random() * 999 + 1)::integer,
       (random() * 99 + 1)::integer,
       TIMESTAMP '2025-01-01' + (random() * 365 || ' days')::interval,
       (random() * 3600 + 60)::integer
   FROM generate_series(1, 200000) i;
   ```

2. Create an index on `user_id`.

3. Run EXPLAIN ANALYZE for `WHERE user_id = 50`.

4. Cluster on `user_id`.

5. Run the same EXPLAIN ANALYZE. Does the number of heap pages fetched decrease?

**Deliverable**: EXPLAIN ANALYZE outputs before and after clustering with written analysis.

---

### Exercise 15: Observing Cluster Decay

Clustering is a one-time operation; new rows do not maintain the order.

1. After clustering `game_sessions` from Exercise 14, insert 50,000 new rows with random `user_id` values.

2. Run EXPLAIN (ANALYZE, BUFFERS) again for `WHERE user_id = 50`.

3. Re-cluster and run the same EXPLAIN one more time.

4. Compare all three runs.

**Checkpoint**: How would you schedule periodic re-clustering in a production environment?

---

## Part 4: Combining Techniques

### Exercise 16: Full Optimization Pipeline

You receive complaints that the following dashboard query is slow:

```sql
SELECT
    DATE_TRUNC('month', o.created_at) AS month,
    o.region,
    COUNT(*) AS order_count,
    SUM(o.total_amount) AS revenue
FROM orders o
WHERE o.created_at >= '2025-01-01'
  AND o.status = 'completed'
GROUP BY 1, 2
ORDER BY 1, 2;
```

Apply the following optimization steps, running EXPLAIN ANALYZE at each stage:

1. **Baseline**: Run EXPLAIN ANALYZE with no extra indexes or partitions.
2. **Index**: Add an index that helps the `WHERE` clause.
3. **Partial index**: Refine the index to cover only `status = 'completed'`.
4. **Materialized view**: Create a materialized view that stores the monthly aggregation.
5. **Final query**: Query the materialized view instead of the base table.

**Deliverable**: Five EXPLAIN ANALYZE outputs (one per step) and a summary of improvements.

---

## Reflection Questions

1. What is the difference between a partial index and a regular index on the same column?
2. When would a BRIN index be more appropriate than a B-tree index?
3. Why must the partition key be included in the `PRIMARY KEY` or `UNIQUE` constraint of a partitioned table?
4. List two scenarios where partitioning would NOT improve performance.
5. After clustering a table, new inserts do not maintain the cluster order. What strategies can minimize the impact of this decay?
6. If you had to choose between adding a covering index and creating a materialized view for a slow aggregate query, what factors would influence your decision?
