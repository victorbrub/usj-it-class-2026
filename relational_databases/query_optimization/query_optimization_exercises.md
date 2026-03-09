# Query Optimization - Practice Exercises

## Instructions

Complete the following exercises to practice reading execution plans, identifying performance problems, and rewriting queries for better efficiency. Use the GameVerse database unless otherwise specified.

**Time Allocation**: 90-120 minutes  
**Difficulty**: Beginner to Advanced  
**Prerequisites**: SQL basics, understanding of indexes

---

## Setup

Run the following to create a small test dataset if you have not already set up the full GameVerse database:

```sql
CREATE TABLE IF NOT EXISTS customers (
    customer_id  SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL,
    country      CHAR(2),
    status       VARCHAR(20) DEFAULT 'active',
    registered_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    category    VARCHAR(50),
    price       NUMERIC(10, 2),
    stock       INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER REFERENCES customers,
    total_amount NUMERIC(12, 2),
    status       VARCHAR(20) DEFAULT 'pending',
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id    SERIAL PRIMARY KEY,
    order_id   INTEGER REFERENCES orders,
    product_id INTEGER REFERENCES products,
    quantity   INTEGER,
    unit_price NUMERIC(10, 2)
);

-- Populate with sample data
INSERT INTO customers (name, email, country)
SELECT
    'Customer ' || i,
    'customer' || i || '@example.com',
    CASE (i % 3) WHEN 0 THEN 'ES' WHEN 1 THEN 'US' ELSE 'FR' END
FROM generate_series(1, 10000) i;

INSERT INTO products (name, category, price, stock)
SELECT
    'Product ' || i,
    CASE (i % 4) WHEN 0 THEN 'game' WHEN 1 THEN 'dlc' WHEN 2 THEN 'hardware' ELSE 'merchandise' END,
    (random() * 200 + 0.99)::numeric(10,2),
    (random() * 500)::integer
FROM generate_series(1, 5000) i;

INSERT INTO orders (customer_id, total_amount, status, created_at)
SELECT
    (random() * 9999 + 1)::integer,
    (random() * 500 + 5)::numeric(12,2),
    CASE (i % 5) WHEN 0 THEN 'pending' WHEN 1 THEN 'processing' ELSE 'completed' END,
    NOW() - (random() * 730 || ' days')::interval
FROM generate_series(1, 100000) i;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    (random() * 99999 + 1)::integer,
    (random() * 4999 + 1)::integer,
    (random() * 4 + 1)::integer,
    (random() * 200 + 0.99)::numeric(10,2)
FROM generate_series(1, 250000) i;

ANALYZE customers, products, orders, order_items;
```

---

## Part 1: Reading Execution Plans

### Exercise 1: Your First EXPLAIN

Run the following query and inspect the execution plan:

```sql
SELECT * FROM orders WHERE status = 'pending';
```

1. Run `EXPLAIN` on this query. What join/scan method is used?
2. Run `EXPLAIN ANALYZE`. What is the actual execution time?
3. What are the estimated vs. actual row counts? Are they similar?

**Deliverable**: Written answers to each question above.

---

### Exercise 2: Comparing Plans After Indexing

1. Run `EXPLAIN ANALYZE` on this query and record the execution time:
   ```sql
   SELECT * FROM orders WHERE customer_id = 500;
   ```

2. Create an index:
   ```sql
   CREATE INDEX idx_orders_customer_id ON orders (customer_id);
   ```

3. Run `EXPLAIN ANALYZE` again on the same query. What changed?
4. What is the speedup (ratio of the two execution times)?

**Checkpoint**: Is the new plan using an Index Scan or Seq Scan? Why?

---

### Exercise 3: When the Planner Chooses a Seq Scan

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 1.00;
```

1. What scan type is used? Why does the planner not use an index (even if one existed)?
2. Create the index:
   ```sql
   CREATE INDEX idx_orders_total ON orders (total_amount);
   ```
3. Run the explain again. Is the index used? Why or why not?
4. Change the predicate to `WHERE total_amount > 490.00` and explain again. What changes?

**Deliverable**: Explanation of how selectivity influences the planner's choice.

---

## Part 2: Join Optimization

### Exercise 4: Nested Loop vs. Hash Join

```sql
EXPLAIN ANALYZE
SELECT o.order_id, c.name, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
LIMIT 100;
```

1. What join strategy does the planner choose?
2. Does adding `LIMIT 100` affect the plan? Remove it and compare.
3. Create an index on `customers(customer_id)` if it does not exist. Re-run and compare.

**Deliverable**: EXPLAIN output before and after the index, with a written comparison.

---

### Exercise 5: Correlated Subquery Rewrite

The following query uses a correlated subquery:

```sql
SELECT product_id, name,
       (SELECT SUM(quantity) FROM order_items oi WHERE oi.product_id = p.product_id) AS total_sold
FROM products p
WHERE category = 'game';
```

1. Run `EXPLAIN ANALYZE` and record the execution time.
2. Rewrite the query using a `JOIN` and `GROUP BY` instead.
3. Run `EXPLAIN ANALYZE` on the rewritten version and compare both execution times.
4. Which plan is better and why?

**Deliverable**: Both queries plus EXPLAIN ANALYZE output and written comparison.

---

## Part 3: Anti-Pattern Identification and Fixes

### Exercise 6: Function on Indexed Column

```sql
-- Assume email is indexed: CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_email ON customers(email);

EXPLAIN SELECT * FROM customers WHERE LOWER(email) = 'customer100@example.com';
```

1. Is the index used? Why not?
2. Create a functional index that fixes this problem.
3. Verify with EXPLAIN that the new index is used.

**Deliverable**: Functional index definition and EXPLAIN output showing it is used.

---

### Exercise 7: Implicit Type Conversion

Consider a table with `customer_id INTEGER`. Run:

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = '500';
```

Versus:

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 500;
```

1. Do both queries use the same plan?
2. Note any differences in the plans or estimated costs.
3. Why is matching the correct data type important?

**Deliverable**: Both EXPLAIN outputs and a written explanation.

---

### Exercise 8: SELECT * vs. Targeted Columns

1. Run `EXPLAIN ANALYZE SELECT * FROM order_items WHERE order_id = 1000;`
2. Create a covering index: `CREATE INDEX idx_oi_cover ON order_items (order_id) INCLUDE (product_id, quantity, unit_price);`
3. Run `EXPLAIN ANALYZE SELECT product_id, quantity, unit_price FROM order_items WHERE order_id = 1000;`
4. Does the second query use an Index Only Scan? What does that mean for heap access?

**Deliverable**: Both EXPLAIN outputs plus written explanation of the difference.

---

## Part 4: CTEs and Subqueries

### Exercise 9: CTE Inlining

```sql
WITH high_value_orders AS (
    SELECT order_id, customer_id, total_amount
    FROM orders
    WHERE total_amount > 400
)
SELECT c.name, h.total_amount
FROM high_value_orders h
JOIN customers c ON h.customer_id = c.customer_id;
```

1. Run `EXPLAIN ANALYZE`. Is the CTE inlined or materialized?
2. Force materialization:
   ```sql
   WITH high_value_orders AS MATERIALIZED ( ... )
   ```
3. Compare plans and execution times. Which is faster?

**Deliverable**: Both EXPLAIN outputs with written comparison.

---

## Part 5: Pagination

### Exercise 10: OFFSET vs. Keyset Pagination

1. Run and time these two queries:
   ```sql
   -- OFFSET-based (page 1)
   EXPLAIN ANALYZE SELECT order_id, created_at FROM orders ORDER BY order_id LIMIT 20 OFFSET 0;

   -- OFFSET-based (page 5000)
   EXPLAIN ANALYZE SELECT order_id, created_at FROM orders ORDER BY order_id LIMIT 20 OFFSET 99980;
   ```

2. Note the cost difference between page 1 and page 5000.

3. Implement keyset pagination for page 5000 (assuming the last seen `order_id` from page 4999 was `99980`):
   ```sql
   EXPLAIN ANALYZE SELECT order_id, created_at FROM orders WHERE order_id > 99980 ORDER BY order_id LIMIT 20;
   ```

4. Compare the three plans.

**Deliverable**: Three EXPLAIN outputs plus a written explanation of when to prefer each approach.

---

## Part 6: Advanced Challenges

### Exercise 11: Materialized View for Aggregation

The following aggregate query is slow when run repeatedly:

```sql
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2;
```

1. Create a materialized view for this query.
2. Create a unique index on the materialized view to support `REFRESH CONCURRENTLY`.
3. Demonstrate refreshing the view.
4. Query the materialized view and compare time vs. the base query.

**Deliverable**: DDL for the materialized view, index, and EXPLAIN ANALYZE comparison.

---

### Exercise 12: Tuning random_page_cost

1. Run: `SHOW random_page_cost;`
2. On a system with SSDs, set it to 1.1 for the session:
   ```sql
   SET random_page_cost = 1.1;
   ```
3. Re-run the query from Exercise 3 (`WHERE total_amount > 490.00`). Does the plan change?
4. Reset: `RESET random_page_cost;`

**Deliverable**: Explanation of how this setting influences index vs. sequential scan choice.

---

## Reflection Questions

1. When should you NOT add an index to a table?
2. What is the difference between `EXPLAIN` and `EXPLAIN ANALYZE`? When would you avoid `EXPLAIN ANALYZE` in production?
3. If the estimated rows in an EXPLAIN output differ greatly from actual rows, what should you do?
4. What is the difference between a regular CTE and a `MATERIALIZED` CTE? When would you use each?
5. Why does keyset pagination scale better than OFFSET for deep pages?
