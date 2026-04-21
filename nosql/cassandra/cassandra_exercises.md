# Author: Víctor Barceló
# Apache Cassandra - Practical Exercises

Complete these exercises to practice Cassandra concepts and CQL operations. Work through them in order, as they build on each other.

**Prerequisites**: Cassandra running locally or via Docker. Connect with:
```bash
docker exec -it cassandra-dev cqlsh
# or
cqlsh
```

---

## Exercise 1: Keyspace and Table Setup

**Objective**: Create a keyspace and tables for a library management system.

**Tasks**:

1. Create a keyspace named `library` with `SimpleStrategy` and `replication_factor = 1`.
2. Switch to the `library` keyspace.
3. Create a table `books_by_isbn` with the following columns:
   - `isbn` (text, partition key)
   - `title` (text)
   - `author` (text)
   - `publication_year` (int)
   - `genres` (set of text)
   - `available_copies` (int)
   - `total_copies` (int)
4. Create a table `books_by_author` with:
   - `author` (text, partition key)
   - `title` (text, clustering column, ascending)
   - `isbn` (text)
   - `publication_year` (int)
5. Run `DESCRIBE TABLES;` to verify creation.

**Your Solution**:
```sql
-- Write your CQL here
```

---

## Exercise 2: Insert Documents

**Objective**: Practice inserting rows into Cassandra tables.

**Tasks**:

1. Insert the following book into `books_by_isbn`:
```
ISBN: 978-0-7432-7356-5
Title: The Great Gatsby
Author: F. Scott Fitzgerald
Year: 1925
Genres: {'Fiction', 'Classic'}
Available: 3, Total: 3
```

2. Insert the same book into `books_by_author` (denormalized copy).

3. Insert at least four more books (of your choice) into both tables.

4. Use `IF NOT EXISTS` to attempt inserting a book with an ISBN that already exists. Observe the `[applied]` column in the result.

**Your Solution**:
```sql
-- Write your INSERT statements here
```

---

## Exercise 3: SELECT Operations

**Objective**: Practice querying data using the partition key.

**Tasks**:

1. Find the book with ISBN `978-0-7432-7356-5`.
2. Find all books by author `F. Scott Fitzgerald`.
3. Find all books by a specific author, ordered by title ascending.
4. Find only the `title` and `available_copies` of a specific book by ISBN.
5. Try running `SELECT * FROM books_by_isbn;` and note the warning. Then add `LIMIT 100` to suppress it.
6. Attempt `SELECT * FROM books_by_isbn WHERE publication_year = 1925;` — observe the error and explain why it fails.

**Your Solution**:
```sql
-- Write your SELECT queries here
```

---

## Exercise 4: UPDATE Operations

**Objective**: Practice updating existing rows.

**Tasks**:

1. Decrease `available_copies` by 1 for the book with ISBN `978-0-7432-7356-5` (a book was loaned).
2. Add `'Vintage'` to the `genres` set of "The Great Gatsby".
3. Remove `'Classic'` from the `genres` set of "The Great Gatsby".
4. Update `available_copies` back to its original value for the same book (it was returned).
5. Use `IF available_copies > 0` as a condition on the decrement. Observe `[applied]`.

**Your Solution**:
```sql
-- Write your UPDATE statements here
```

---

## Exercise 5: DELETE Operations

**Objective**: Practice deleting rows and column values.

**Tasks**:

1. Delete the row with ISBN `978-0-7432-7356-5` from `books_by_isbn`.
2. Delete the corresponding row from `books_by_author` as well.
3. Delete only the `available_copies` column from a book (set it to null/unset).
4. Re-insert "The Great Gatsby" into both tables.
5. Use a logged batch to insert a new book into both tables simultaneously.

**Your Solution**:
```sql
-- Write your DELETE and BATCH statements here
```

---

## Exercise 6: TTL (Time to Live)

**Objective**: Practice automatic data expiration.

**Tasks**:

1. Create a table `loan_sessions` with:
   - `loan_id` (uuid, partition key)
   - `isbn` (text)
   - `member_username` (text)
   - `loaned_at` (timestamp)

2. Insert a loan session with a TTL of 30 days (in seconds: `2592000`).

3. Check the TTL of the `member_username` column for that row using `TTL()`.

4. Insert another row with a TTL of 10 seconds. Wait 10 seconds, then query it — the row should be gone.

5. Insert a row without TTL. Then use `UPDATE ... USING TTL` to apply a TTL of 60 seconds to the `isbn` column only.

**Your Solution**:
```sql
-- Write your TTL-related CQL here
```

---

## Exercise 7: Collections

**Objective**: Practice working with set, list, and map columns.

**Tasks**:

1. Alter `books_by_isbn` to add a `tags` list column and a `metadata` map column (`map<text, text>`).

2. Update a book to set `tags = ['must-read', 'award-winner']`.

3. Append `'classic-lit'` to the `tags` list for that book.

4. Prepend `'top-10'` to the `tags` list.

5. Update `metadata` to add the key-value pair `'publisher': 'Scribner'`.

6. Remove `'award-winner'` from the `tags` list.

7. Remove the `'publisher'` key from the `metadata` map.

**Your Solution**:
```sql
-- Write your collection operation queries here
```

---

## Exercise 8: Data Modeling — Multiple Query Tables

**Objective**: Design tables around access patterns, not entities.

**Scenario**: The library application needs the following queries:
- Q1: Look up a book by ISBN
- Q2: List all books by a given author
- Q3: List all books in a given genre
- Q4: Look up a member by username
- Q5: List all loans for a given member, most recent first
- Q6: List all active loans for a given book (by ISBN)

**Tasks**:

1. For each query, state which column(s) must be the partition key and which can be clustering columns.

2. Write the `CREATE TABLE` statement for each query's dedicated table.

3. Insert sample data into all tables for at least 3 books and 2 members with loans.

4. Write the `SELECT` query for each access pattern and verify it works without `ALLOW FILTERING`.

**Your Solution**:
```sql
-- Write your table designs and INSERT/SELECT statements here
```

---

## Exercise 9: Lightweight Transactions (LWT)

**Objective**: Practice conditional writes with `IF NOT EXISTS` and `IF condition`.

**Tasks**:

1. Create a table `member_profiles` with:
   - `username` (text, partition key)
   - `email` (text)
   - `full_name` (text)
   - `version` (int)

2. Insert a member using `IF NOT EXISTS`. Observe the `[applied]` column.

3. Try inserting the same member again with `IF NOT EXISTS`. Confirm it is not applied.

4. Update the member's email using `IF email = 'original_email'`. Confirm it is applied.

5. Attempt the same update again with the old email value. Confirm it is not applied (it was already changed).

6. Implement an optimistic lock: update `email` and increment `version` only if `version = current_version`.

7. Simulate a conflict: prepare two updates with the same `IF version = 1`. Execute the first — it should succeed. Execute the second — it should fail.

**Your Solution**:
```sql
-- Write your LWT queries here
```

---

## Exercise 10: Counters

**Objective**: Practice the counter data type.

**Tasks**:

1. Create a table `page_views` with:
   - `page_id` (text, partition key)
   - `view_count` (counter)

2. Create a table `book_loan_counts` with:
   - `isbn` (text, partition key)
   - `total_loans` (counter)

3. Increment `view_count` for `page_id = 'homepage'` three times.

4. Read the current `view_count`.

5. Decrement `total_loans` for a book by 1.

6. Try to INSERT into `page_views` instead of using UPDATE. Observe the error.

7. Try to add a non-counter column to `page_views`. Observe the error.

**Your Solution**:
```sql
-- Write your counter queries here
```

---

## Exercise 11: Consistency Levels

**Objective**: Practice setting and understanding consistency levels.

**Tasks**:

1. In cqlsh, check the current default consistency level with `CONSISTENCY;`.

2. Set the consistency level to `QUORUM` with `CONSISTENCY QUORUM;`.

3. Run a SELECT query. If you have only one node, it will succeed because `QUORUM` with RF=1 requires only 1 replica.

4. Set the consistency level to `ALL` and run the same query.

5. Set the consistency level to `ONE` and run the query again.

6. Explain in your own words: with RF=3, which combinations of write CL and read CL guarantee strong consistency? List at least three.

**Your Solution**:
```sql
-- Write your consistency level commands and explanation here
```

---

## Exercise 12: Indexes

**Objective**: Practice creating and using secondary indexes.

**Tasks**:

1. Create a Storage-Attached Index (SAI) on the `email` column of `member_profiles`:
```sql
CREATE INDEX ON member_profiles (email) USING 'sai';
```

2. Query `member_profiles` by email. Confirm it works without `ALLOW FILTERING`.

3. Create a SAI on `publication_year` in `books_by_isbn`.

4. Query books by `publication_year`. Confirm it works.

5. List all indexes on `books_by_isbn` with `DESCRIBE TABLE books_by_isbn;`.

6. Drop the index on `publication_year`.

7. Attempt the same query by `publication_year` again and observe the error.

**Your Solution**:
```sql
-- Write your index commands here
```

---

## Exercise 13: Logged Batches (Denormalized Sync)

**Objective**: Use logged batches to keep denormalized tables consistent.

**Scenario**: You have `books_by_isbn` and `books_by_author`. Whenever a new book is added, both tables must be updated atomically.

**Tasks**:

1. Write a logged batch that inserts a new book into both `books_by_isbn` and `books_by_author` simultaneously.

2. Write a logged batch that deletes a book from both tables when it is removed from the library.

3. Write a logged batch that updates the `available_copies` in `books_by_isbn` AND inserts a new row in a `loan_log` table (create the `loan_log` table as needed).

4. Attempt to add an `IF NOT EXISTS` condition inside a logged batch. Observe the error and explain why it is not allowed.

**Your Solution**:
```sql
-- Write your batch statements here
```

---

## Exercise 14: Modeling Time-Series Data

**Objective**: Design and query a time-series table.

**Scenario**: The library wants to log every time a book is loaned or returned. The application needs:
- Q1: Retrieve all loan events for a given book, newest first.
- Q2: Retrieve all loan events for a given member, newest first.

**Tasks**:

1. Design two tables to satisfy Q1 and Q2. Use `timeuuid` as a clustering column for natural time-ordering.

2. Insert at least 5 loan events for one book across two different members.

3. Query all events for a specific book.

4. Query events for a specific book within a time range using the `minTimeuuid()` and `maxTimeuuid()` functions:
```sql
WHERE event_time > minTimeuuid('2026-01-01 00:00:00+0000')
  AND event_time < maxTimeuuid('2026-12-31 23:59:59+0000')
```

5. Use `LIMIT 5` to get only the 5 most recent events for a book.

**Your Solution**:
```sql
-- Write your time-series table designs and queries here
```

---

## Exercise 15: Access Control

**Objective**: Create roles and grant permissions.

**Tasks**:

1. Enable authentication by checking the current `authenticator` setting (skip actual restart if on a shared lab environment; write the `cassandra.yaml` change as a comment).

2. Create a role `library_read` with no login capability.

3. Create a role `library_app` with login capability and a password.

4. Grant `SELECT` on all tables in `library` to `library_read`.

5. Grant `SELECT` and `MODIFY` on all tables in `library` to `library_app`.

6. Grant the `library_read` role to `library_app` (so `library_app` inherits read permissions).

7. List all permissions for `library_app`.

8. Revoke `MODIFY` on `library.books_by_isbn` from `library_app`.

9. Drop the `library_read` role.

**Your Solution**:
```sql
-- Write your access control commands here
```

---

## Exercise 16: Partitioning Strategy Analysis

**Objective**: Analyze and improve a partition key design.

**Scenario**: A developer has created the following table to store application log events:

```sql
CREATE TABLE app_logs (
    log_date  date,
    log_time  timeuuid,
    level     text,
    message   text,
    service   text,
    PRIMARY KEY (log_date, log_time)
) WITH CLUSTERING ORDER BY (log_time DESC);
```

**Tasks**:

1. Identify the problem with using `log_date` as the only partition key in a high-traffic application (hint: how many rows will one partition hold after one year of 10,000 events/day?).

2. Redesign the table to use a **bucket** strategy that limits partition size. Use `(service, log_date)` as a compound partition key.

3. Write the `CREATE TABLE` statement for the redesigned table.

4. Insert at least 5 log rows for `service = 'auth'` and `service = 'payment'`.

5. Query all logs for `service = 'auth'` on today's date.

6. Query the 10 most recent logs for `service = 'payment'`.

**Your Solution**:
```sql
-- Write your analysis and redesigned table here
```

---

## Exercise 17: Cassandra vs. PostgreSQL — Migration Thinking

**Objective**: Understand what changes when migrating a relational schema to Cassandra.

**Scenario**: A PostgreSQL library database has the following tables:

```sql
-- PostgreSQL schema (relational)
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name      TEXT NOT NULL
);

CREATE TABLE books (
    book_id    SERIAL PRIMARY KEY,
    title      TEXT NOT NULL,
    isbn       TEXT UNIQUE NOT NULL,
    author_id  INT REFERENCES authors(author_id),
    year       INT,
    genre      TEXT
);

CREATE TABLE loans (
    loan_id    SERIAL PRIMARY KEY,
    book_id    INT REFERENCES books(book_id),
    member_id  INT,
    loaned_at  TIMESTAMP,
    returned_at TIMESTAMP
);
```

**Tasks**:

1. List the queries that would require JOINs in PostgreSQL (e.g., "get all books by author name").

2. For each query identified, design a dedicated Cassandra table with the correct partition key and clustering columns.

3. Write the `CREATE TABLE` CQL for each table.

4. Explain how you would handle the following in Cassandra (no foreign keys, no JOINs):
   - Ensuring a loan references a valid book
   - Ensuring referential integrity when a book is deleted
   - Running an ad-hoc query not anticipated during design

**Your Solution**:
```sql
-- Write your Cassandra table designs and explanations here
```

---

## Exercise 18: Real-World Challenge — GameVerse Activity Feed

**Objective**: Design and implement a real-world feature end-to-end.

**Scenario**: The GameVerse platform needs an activity feed for each user showing recent events (game purchased, review posted, achievement unlocked, friend added). The requirements are:
- Retrieve the 20 most recent activity events for a user.
- Store events for up to 90 days (use TTL).
- Events have a type (`purchase`, `review`, `achievement`, `friend`) and a payload (arbitrary text).

**Tasks**:

1. Design the table for this feature. Justify your choice of partition key and clustering column.

2. Write the `CREATE TABLE` statement including the appropriate `CLUSTERING ORDER BY`.

3. Insert at least 10 activity events for two different users across multiple event types. Apply a TTL of 90 days (`7776000` seconds).

4. Query the 20 most recent events for one user.

5. Query only `review` events for a user using `ALLOW FILTERING` (acceptable here since the partition is already targeted). Note: explain why `ALLOW FILTERING` is less harmful within a single partition.

6. Verify the TTL on one of the event rows.

**Your Solution**:
```sql
-- Write your table design, inserts, and queries here
```

---

## Solutions Note

Work through these exercises using cqlsh. Test your solutions and compare them with classmates. Multiple valid designs often exist — focus on understanding the trade-offs.

**Hints**:
- Use `DESCRIBE TABLE table_name;` to inspect the full table definition including indexes.
- Use `TRACING ON;` to see execution details for a query.
- Use `CONSISTENCY QUORUM;` before any query to change the consistency level.
- Cassandra documentation: [cassandra.apache.org/doc/latest](https://cassandra.apache.org/doc/latest/)
- When in doubt, think about the query first, then design the table.

---

**Estimated Time**: 5-7 hours for all exercises
**Difficulty Progression**: Beginner -> Intermediate -> Advanced
**Prerequisites**: Cassandra running locally or via Docker

**Last Updated**: April 20, 2026
**Course**: USJ IT Class 2026
**Module**: Cassandra Exercises
