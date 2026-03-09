# Query Optimization - Complete Guide

## What is Query Optimization?

**Query optimization** is the process of selecting the most efficient execution plan for a SQL query. The database engine's **query planner** analyzes all possible ways to retrieve the requested data and chooses the plan with the lowest estimated cost.

Understanding how the planner works allows you to write queries that execute faster, consume fewer resources, and scale better as your data grows.

---

## The Query Execution Pipeline

When you submit a SQL statement, PostgreSQL processes it in several stages:

1. **Parsing**: Validates SQL syntax and builds a parse tree
2. **Rewriting**: Applies rule-based transformations (e.g., view expansion)
3. **Planning**: The query planner generates and evaluates candidate execution plans
4. **Execution**: The chosen plan is executed against the actual data

The planning stage is where optimization happens. The planner uses **statistics** about table contents (collected by `ANALYZE`) to estimate the cost of each candidate plan.

---

## Understanding EXPLAIN and EXPLAIN ANALYZE

### EXPLAIN

`EXPLAIN` shows the execution plan the planner chose, without actually running the query.

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 42;
```

Example output:
```
Index Scan using orders_customer_id_idx on orders  (cost=0.43..12.50 rows=5 width=64)
  Index Cond: (customer_id = 42)
```

### EXPLAIN ANALYZE

`EXPLAIN ANALYZE` actually executes the query and shows both the estimated and actual costs.

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;
```

Example output:
```
Index Scan using orders_customer_id_idx on orders  
  (cost=0.43..12.50 rows=5 width=64) 
  (actual time=0.082..0.095 rows=5 loops=1)
Planning Time: 0.210 ms
Execution Time: 0.121 ms
```

### Reading the Output

| Field | Meaning |
|-------|---------|
| `cost=start..total` | Estimated cost units; start = cost before first row, total = cost for all rows |
| `rows` | Estimated number of rows returned |
| `width` | Estimated average row size in bytes |
| `actual time` | Real elapsed time in milliseconds (ANALYZE only) |
| `loops` | How many times this node was executed |

### Key Plan Node Types

| Node | Description |
|------|-------------|
| `Seq Scan` | Reads every row in the table (full scan) |
| `Index Scan` | Uses an index to locate rows, then fetches from the heap |
| `Index Only Scan` | All needed columns come from the index itself |
| `Bitmap Heap Scan` | Collects heap pages from a bitmap index scan |
| `Hash Join` | Builds a hash table from one relation and probes it |
| `Merge Join` | Joins two pre-sorted relations |
| `Nested Loop` | For each outer row, scans the inner relation |
| `Sort` | Sorts rows (can be expensive without an index) |
| `Aggregate` | Computes aggregate functions (SUM, COUNT, etc.) |

---

## Sequential Scans vs. Index Scans

### When Sequential Scans Are Used

The planner may prefer a sequential scan when:
- The query returns a large fraction of the table (typically > 5-10%)
- The table is very small (fits in a few pages)
- No suitable index exists

```sql
-- Likely a Seq Scan - returning most rows
EXPLAIN SELECT * FROM products WHERE price > 0.01;

-- Likely an Index Scan - returning few rows
EXPLAIN SELECT * FROM products WHERE price > 950.00;
```

### Forcing an Index Scan (for testing only)

```sql
SET enable_seqscan = off;
EXPLAIN SELECT * FROM products WHERE price > 0.01;
SET enable_seqscan = on;  -- Always restore after testing
```

---

## Joins and Their Costs

### Nested Loop Join

Best for small outer relations or when the inner side has an index on the join column.

```sql
EXPLAIN ANALYZE
SELECT o.order_id, c.name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'pending';
```

### Hash Join

Best for larger relations without a useful index on the join column. Builds a hash table from the smaller side.

```sql
EXPLAIN ANALYZE
SELECT p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name;
```

### Merge Join

Best when both sides are already sorted on the join column (often via an index).

### Choosing Join Order

PostgreSQL evaluates join orderings automatically. You can see the chosen order in the EXPLAIN output. For queries with many tables, the planner may use genetic algorithms (`geqo`) to avoid combinatorial explosion.

---

## Subqueries, CTEs, and Joins

### Correlated Subquery (Usually Slow)

Executes once per row of the outer query.

```sql
-- Correlated subquery - runs N times
SELECT product_id, name,
       (SELECT AVG(quantity) FROM order_items oi WHERE oi.product_id = p.product_id) AS avg_qty
FROM products p;
```

### Rewritten as a Join (Usually Faster)

```sql
-- Join - executes once
SELECT p.product_id, p.name, AVG(oi.quantity) AS avg_qty
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name;
```

### CTEs (Common Table Expressions)

In PostgreSQL 12+, CTEs are inlined by default (the planner can optimize them together with the main query). In older versions, CTEs were optimization fences.

```sql
-- Modern PostgreSQL: planner can inline this CTE
WITH recent_orders AS (
    SELECT * FROM orders WHERE created_at > NOW() - INTERVAL '30 days'
)
SELECT customer_id, COUNT(*) FROM recent_orders GROUP BY customer_id;

-- Force materialization (PostgreSQL 12+) if you need the old behavior
WITH recent_orders AS MATERIALIZED (
    SELECT * FROM orders WHERE created_at > NOW() - INTERVAL '30 days'
)
SELECT customer_id, COUNT(*) FROM recent_orders GROUP BY customer_id;
```

---

## Filter Pushdown and Predicate Selectivity

The planner tries to apply filters as early as possible (pushdown) to reduce the number of rows processed at each stage.

### Selectivity

A highly **selective** predicate matches few rows; a low-selectivity predicate matches many. The planner estimates selectivity from column statistics.

```sql
-- High selectivity - likely Index Scan (few matching rows)
SELECT * FROM orders WHERE order_id = 1001;

-- Low selectivity - likely Seq Scan (many matching rows)
SELECT * FROM orders WHERE status = 'completed';
```

### Helping the Planner with Statistics

```sql
-- Increase statistics target for a column with high cardinality
ALTER TABLE orders ALTER COLUMN customer_id SET STATISTICS 500;

-- Refresh statistics after bulk data changes
ANALYZE orders;
```

---

## Common Query Anti-Patterns

### 1. Functions on Indexed Columns in WHERE

Wrapping an indexed column in a function prevents index use.

```sql
-- Anti-pattern: index on email is NOT used
SELECT * FROM users WHERE LOWER(email) = 'alice@example.com';

-- Fix: use a functional index
CREATE INDEX idx_users_email_lower ON users (LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'alice@example.com';
```

### 2. Leading Wildcard in LIKE

```sql
-- Anti-pattern: cannot use a B-tree index
SELECT * FROM products WHERE name LIKE '%widget%';

-- Fix: use a trigram index (pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);
SELECT * FROM products WHERE name LIKE '%widget%';
```

### 3. Implicit Type Conversion

```sql
-- Anti-pattern: customer_id is INTEGER, but value is TEXT
-- Implicit cast prevents index use
SELECT * FROM orders WHERE customer_id = '42';

-- Fix: use the correct type
SELECT * FROM orders WHERE customer_id = 42;
```

### 4. SELECT *

Fetches all columns unnecessarily, increasing I/O and network transfer.

```sql
-- Anti-pattern
SELECT * FROM products;

-- Fix: select only needed columns
SELECT product_id, name, price FROM products;
```

### 5. Counting Rows with COUNT(*)

`COUNT(*)` is efficient in PostgreSQL. Avoid `COUNT(1)` myths - they perform identically.

```sql
-- Both are equivalent in PostgreSQL
SELECT COUNT(*) FROM orders;
SELECT COUNT(1) FROM orders;
```

### 6. DISTINCT Without Purpose

`DISTINCT` forces a sort or hash aggregation; use it only when truly needed.

```sql
-- Check if a join produces duplicates before adding DISTINCT
SELECT DISTINCT c.customer_id FROM customers c JOIN orders o ON c.customer_id = o.customer_id;

-- Prefer EXISTS when you only need to know if a match exists
SELECT c.customer_id FROM customers c WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
```

---

## Pagination

### OFFSET/LIMIT (Simple but Scales Poorly)

```sql
-- Page 1
SELECT * FROM products ORDER BY product_id LIMIT 20 OFFSET 0;
-- Page 100 requires scanning and discarding 1980 rows
SELECT * FROM products ORDER BY product_id LIMIT 20 OFFSET 1980;
```

### Keyset Pagination (Cursor-Based, Scales Well)

```sql
-- First page
SELECT * FROM products ORDER BY product_id LIMIT 20;

-- Next page: pass the last seen product_id from client
SELECT * FROM products WHERE product_id > 1234 ORDER BY product_id LIMIT 20;
```

Keyset pagination is much faster for deep pages but requires a stable sort key.

---

## Query Planning Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `random_page_cost` | 4.0 | Cost of a non-sequential disk page fetch; lower for SSDs (e.g., 1.1) |
| `effective_cache_size` | 4GB | Estimate of OS + PostgreSQL cache; helps planner prefer index scans |
| `work_mem` | 4MB | Memory per sort/hash operation; increase for complex queries |
| `enable_seqscan` | on | Enable/disable sequential scans (for testing only) |
| `enable_hashjoin` | on | Enable/disable hash joins (for testing only) |

### SSD Tuning Example

```sql
-- If your storage is SSD, lower random_page_cost so the planner
-- favors index scans more aggressively
ALTER SYSTEM SET random_page_cost = 1.1;
SELECT pg_reload_conf();
```

---

## Query Rewriting with Views and Materialized Views

### Regular View

```sql
CREATE VIEW active_customers AS
SELECT customer_id, name, email
FROM customers
WHERE status = 'active';

-- Query is rewritten and planned against the base table
SELECT * FROM active_customers WHERE name LIKE 'A%';
```

### Materialized View

Stores the query result physically. Faster to query; requires manual refresh.

```sql
CREATE MATERIALIZED VIEW monthly_sales AS
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    SUM(total_amount) AS revenue
FROM orders
WHERE status = 'completed'
GROUP BY 1
ORDER BY 1;

-- Refresh when base data changes
REFRESH MATERIALIZED VIEW monthly_sales;

-- Refreshes without locking reads (requires a unique index)
CREATE UNIQUE INDEX ON monthly_sales (month);
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales;
```

---

## Summary

| Technique | Benefit |
|-----------|---------|
| Use EXPLAIN ANALYZE | Understand actual vs. estimated costs |
| Create appropriate indexes | Avoid full table scans for selective queries |
| Rewrite correlated subqueries as joins | Execute aggregation once instead of per row |
| Avoid functions on indexed columns | Allow index usage in WHERE clauses |
| Use keyset pagination | Avoid expensive OFFSET for deep pages |
| Tune random_page_cost for SSD | Encourage index usage on fast storage |
| ANALYZE after bulk loads | Keep planner statistics accurate |
