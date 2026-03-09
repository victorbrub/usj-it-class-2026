# SQL Basics - A Comprehensive Guide

## What is SQL?

**SQL** (Structured Query Language) is the standard language for interacting with relational databases. It allows you to create, read, update, and delete data, as well as manage database structure and control access.

### SQL Characteristics

- **Declarative**: You specify what you want, not how to get it
- **Standardized**: Based on ANSI/ISO standards (though implementations vary)
- **Portable**: Works across different database systems with minor variations
- **Powerful**: Can express complex data manipulations concisely

## SQL Statement Categories

SQL statements are divided into several categories:

### DDL (Data Definition Language)
Defines database structure:
- `CREATE`: Create tables, databases, indexes
- `ALTER`: Modify existing structures
- `DROP`: Delete tables, databases
- `TRUNCATE`: Remove all data from table

### DML (Data Manipulation Language)
Manipulates data:
- `SELECT`: Query/retrieve data
- `INSERT`: Add new data
- `UPDATE`: Modify existing data
- `DELETE`: Remove data

### DCL (Data Control Language)
Controls access:
- `GRANT`: Give permissions
- `REVOKE`: Remove permissions

### TCL (Transaction Control Language)
Manages transactions:
- `BEGIN/START TRANSACTION`: Start transaction
- `COMMIT`: Save changes
- `ROLLBACK`: Undo changes
- `SAVEPOINT`: Create checkpoint

---

## Creating Tables (DDL)

### Basic CREATE TABLE Syntax

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

### Example: Students Table

```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    gpa DECIMAL(3,2) CHECK (gpa >= 0 AND gpa <= 4.0),
    is_active BOOLEAN DEFAULT TRUE
);
```

### Common Data Types in PostgreSQL

**Numeric Types**:
```sql
INTEGER or INT          -- Whole numbers
SMALLINT               -- Small integers (-32768 to 32767)
BIGINT                 -- Large integers
DECIMAL(p,s) or NUMERIC -- Exact decimal (p=precision, s=scale)
REAL                   -- Floating point (6 decimal digits precision)
DOUBLE PRECISION       -- Double precision floating point
SERIAL                 -- Auto-incrementing integer
```

**Character Types**:
```sql
CHAR(n)               -- Fixed length string
VARCHAR(n)            -- Variable length string (max n characters)
TEXT                  -- Unlimited length string
```

**Date/Time Types**:
```sql
DATE                  -- Date only (YYYY-MM-DD)
TIME                  -- Time only
TIMESTAMP             -- Date and time
TIMESTAMPTZ           -- Timestamp with timezone
INTERVAL              -- Time interval
```

**Boolean**:
```sql
BOOLEAN               -- TRUE, FALSE, or NULL
```

**Other Useful Types**:
```sql
JSON or JSONB         -- JSON data
UUID                  -- Universally unique identifier
ARRAY                 -- Array of any data type
```

### Constraints

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,           -- Primary key
    product_name VARCHAR(100) NOT NULL,       -- Not null
    sku VARCHAR(50) UNIQUE,                   -- Unique values
    price DECIMAL(10,2) CHECK (price > 0),   -- Check constraint
    category VARCHAR(50) DEFAULT 'General',   -- Default value
    supplier_id INTEGER REFERENCES suppliers(supplier_id)  -- Foreign key
);
```

### ALTER TABLE

Modify existing tables:

```sql
-- Add column
ALTER TABLE students ADD COLUMN phone VARCHAR(20);

-- Drop column
ALTER TABLE students DROP COLUMN phone;

-- Rename column
ALTER TABLE students RENAME COLUMN first_name TO given_name;

-- Change data type
ALTER TABLE students ALTER COLUMN email TYPE VARCHAR(150);

-- Add constraint
ALTER TABLE students ADD CONSTRAINT check_gpa CHECK (gpa >= 0);

-- Drop constraint
ALTER TABLE students DROP CONSTRAINT check_gpa;
```

### DROP TABLE

```sql
-- Delete table completely
DROP TABLE students;

-- Delete only if exists
DROP TABLE IF EXISTS students;

-- Delete table and all dependent objects
DROP TABLE students CASCADE;
```

---

## Inserting Data (DML)

### INSERT Syntax

```sql
-- Insert single row
INSERT INTO students (first_name, last_name, email)
VALUES ('John', 'Doe', 'john.doe@email.com');

-- Insert multiple rows
INSERT INTO students (first_name, last_name, email) VALUES
    ('Jane', 'Smith', 'jane.smith@email.com'),
    ('Bob', 'Johnson', 'bob.johnson@email.com'),
    ('Alice', 'Williams', 'alice.williams@email.com');

-- Insert with all columns (in table order)
INSERT INTO students 
VALUES (DEFAULT, 'Charlie', 'Brown', 'charlie@email.com', '2000-05-15', CURRENT_DATE, 3.5, TRUE);

-- Insert from SELECT
INSERT INTO archived_students
SELECT * FROM students WHERE graduation_date < '2020-01-01';

-- Insert and return inserted values
INSERT INTO students (first_name, last_name, email)
VALUES ('Eve', 'Davis', 'eve@email.com')
RETURNING student_id, first_name, enrollment_date;
```

---

## Querying Data (SELECT)

### Basic SELECT Syntax

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition
ORDER BY column
LIMIT number;
```

### SELECT Examples

```sql
-- Select all columns
SELECT * FROM students;

-- Select specific columns
SELECT first_name, last_name, email FROM students;

-- Select with alias
SELECT first_name AS "First Name", last_name AS "Last Name" FROM students;

-- Select distinct values
SELECT DISTINCT major FROM students;

-- Select with calculation
SELECT first_name, last_name, (gpa * 25) AS percentage FROM students;

-- Select with concatenation
SELECT first_name || ' ' || last_name AS full_name FROM students;
```

### WHERE Clause

Filter rows based on conditions:

```sql
-- Comparison operators
SELECT * FROM students WHERE gpa > 3.5;
SELECT * FROM students WHERE enrollment_date = '2024-09-01';
SELECT * FROM students WHERE last_name != 'Smith';

-- Logical operators
SELECT * FROM students WHERE gpa > 3.0 AND is_active = TRUE;
SELECT * FROM students WHERE major = 'Computer Science' OR major = 'Engineering';
SELECT * FROM students WHERE NOT is_active;

-- BETWEEN
SELECT * FROM students WHERE gpa BETWEEN 3.0 AND 4.0;
SELECT * FROM students WHERE enrollment_date BETWEEN '2023-01-01' AND '2023-12-31';

-- IN
SELECT * FROM students WHERE major IN ('Computer Science', 'Mathematics', 'Physics');

-- LIKE (pattern matching)
SELECT * FROM students WHERE email LIKE '%@gmail.com';
SELECT * FROM students WHERE first_name LIKE 'J%';  -- Starts with J
SELECT * FROM students WHERE last_name LIKE '%son'; -- Ends with son
SELECT * FROM students WHERE phone LIKE '555-____';  -- Underscore matches single char

-- IS NULL / IS NOT NULL
SELECT * FROM students WHERE phone IS NULL;
SELECT * FROM students WHERE gpa IS NOT NULL;
```

### ORDER BY

Sort results:

```sql
-- Ascending order (default)
SELECT * FROM students ORDER BY last_name;

-- Descending order
SELECT * FROM students ORDER BY gpa DESC;

-- Multiple columns
SELECT * FROM students ORDER BY major, gpa DESC;

-- Order by expression
SELECT first_name, last_name, gpa * 25 AS percentage 
FROM students 
ORDER BY percentage DESC;
```

### LIMIT and OFFSET

Limit number of results:

```sql
-- Get first 10 students
SELECT * FROM students LIMIT 10;

-- Get students 11-20 (pagination)
SELECT * FROM students LIMIT 10 OFFSET 10;

-- Get top 5 students by GPA
SELECT * FROM students ORDER BY gpa DESC LIMIT 5;
```

---

## Aggregate Functions

Perform calculations on sets of rows:

```sql
-- COUNT
SELECT COUNT(*) FROM students;                           -- Count all rows
SELECT COUNT(phone) FROM students;                       -- Count non-null phones
SELECT COUNT(DISTINCT major) FROM students;              -- Count unique majors

-- SUM
SELECT SUM(credits) FROM courses;

-- AVG
SELECT AVG(gpa) FROM students;
SELECT AVG(gpa) AS average_gpa FROM students WHERE major = 'Computer Science';

-- MIN and MAX
SELECT MIN(gpa) AS lowest_gpa FROM students;
SELECT MAX(enrollment_date) AS most_recent FROM students;

-- Multiple aggregates
SELECT 
    COUNT(*) AS total_students,
    AVG(gpa) AS avg_gpa,
    MIN(gpa) AS min_gpa,
    MAX(gpa) AS max_gpa
FROM students;
```

### GROUP BY

Group rows for aggregate functions:

```sql
-- Count students by major
SELECT major, COUNT(*) AS student_count
FROM students
GROUP BY major;

-- Average GPA by major
SELECT major, AVG(gpa) AS avg_gpa
FROM students
GROUP BY major
ORDER BY avg_gpa DESC;

-- Multiple grouping columns
SELECT major, is_active, COUNT(*) AS count
FROM students
GROUP BY major, is_active;

-- Group by with WHERE
SELECT major, AVG(gpa) AS avg_gpa
FROM students
WHERE enrollment_date >= '2023-01-01'
GROUP BY major;
```

### HAVING

Filter groups (like WHERE but for GROUP BY):

```sql
-- Majors with more than 10 students
SELECT major, COUNT(*) AS student_count
FROM students
GROUP BY major
HAVING COUNT(*) > 10;

-- Majors with average GPA above 3.5
SELECT major, AVG(gpa) AS avg_gpa
FROM students
GROUP BY major
HAVING AVG(gpa) > 3.5;

-- Combine WHERE and HAVING
SELECT major, AVG(gpa) AS avg_gpa
FROM students
WHERE is_active = TRUE
GROUP BY major
HAVING COUNT(*) >= 5
ORDER BY avg_gpa DESC;
```

---

## Updating Data

### UPDATE Syntax

```sql
-- Update single column
UPDATE students 
SET email = 'newemail@example.com' 
WHERE student_id = 1;

-- Update multiple columns
UPDATE students 
SET gpa = 3.8, is_active = TRUE 
WHERE student_id = 5;

-- Update with calculation
UPDATE products 
SET price = price * 1.10 
WHERE category = 'Electronics';

-- Update all rows (be careful!)
UPDATE students SET is_active = FALSE;

-- Update with subquery
UPDATE enrollments 
SET grade = 'A' 
WHERE student_id IN (SELECT student_id FROM students WHERE gpa > 3.9);

-- Update and return
UPDATE students 
SET gpa = 3.95 
WHERE student_id = 10
RETURNING *;
```

---

## Deleting Data

### DELETE Syntax

```sql
-- Delete specific rows
DELETE FROM students WHERE student_id = 5;

-- Delete with condition
DELETE FROM students WHERE enrollment_date < '2020-01-01';

-- Delete all rows (keeps table structure)
DELETE FROM students;

-- Better alternative for deleting all (faster)
TRUNCATE TABLE students;

-- Delete and return deleted rows
DELETE FROM students 
WHERE gpa < 2.0
RETURNING *;
```

---

## JOINs

Combine data from multiple tables:

### INNER JOIN

Returns rows that have matching values in both tables:

```sql
SELECT students.first_name, students.last_name, courses.course_name
FROM students
INNER JOIN enrollments ON students.student_id = enrollments.student_id
INNER JOIN courses ON enrollments.course_id = courses.course_id;

-- Using table aliases
SELECT s.first_name, s.last_name, c.course_name, e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE e.grade = 'A';
```

### LEFT JOIN (LEFT OUTER JOIN)

Returns all rows from left table and matching rows from right:

```sql
-- Get all students and their enrollments (including students with no enrollments)
SELECT s.first_name, s.last_name, c.course_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id;

-- Find students not enrolled in any courses
SELECT s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;
```

### RIGHT JOIN (RIGHT OUTER JOIN)

Returns all rows from right table and matching rows from left:

```sql
-- Get all courses and enrolled students (including courses with no students)
SELECT c.course_name, s.first_name, s.last_name
FROM students s
RIGHT JOIN enrollments e ON s.student_id = e.student_id
RIGHT JOIN courses c ON e.course_id = c.course_id;
```

### FULL JOIN (FULL OUTER JOIN)

Returns all rows from both tables:

```sql
SELECT s.first_name, c.course_name
FROM students s
FULL JOIN enrollments e ON s.student_id = e.student_id
FULL JOIN courses c ON e.course_id = c.course_id;
```

### CROSS JOIN

Cartesian product (every row from first table combined with every row from second):

```sql
SELECT s.first_name, c.course_name
FROM students s
CROSS JOIN courses c;
```

---

## Subqueries

Query within a query:

### Subquery in WHERE

```sql
-- Students with GPA higher than average
SELECT first_name, last_name, gpa
FROM students
WHERE gpa > (SELECT AVG(gpa) FROM students);

-- Students enrolled in 'Database Systems'
SELECT first_name, last_name
FROM students
WHERE student_id IN (
    SELECT student_id 
    FROM enrollments 
    WHERE course_id = (SELECT course_id FROM courses WHERE course_name = 'Database Systems')
);
```

### Subquery in FROM

```sql
-- Query results from subquery
SELECT major, avg_gpa
FROM (
    SELECT major, AVG(gpa) AS avg_gpa
    FROM students
    GROUP BY major
) AS major_averages
WHERE avg_gpa > 3.5;
```

### Subquery in SELECT

```sql
-- Show each student with count of their enrollments
SELECT 
    first_name, 
    last_name,
    (SELECT COUNT(*) FROM enrollments WHERE student_id = s.student_id) AS course_count
FROM students s;
```

---

## Common Table Expressions (CTEs)

More readable alternative to subqueries:

```sql
-- Basic CTE
WITH high_gpa_students AS (
    SELECT student_id, first_name, last_name, gpa
    FROM students
    WHERE gpa > 3.5
)
SELECT * FROM high_gpa_students
ORDER BY gpa DESC;

-- Multiple CTEs
WITH 
    active_students AS (
        SELECT * FROM students WHERE is_active = TRUE
    ),
    recent_enrollments AS (
        SELECT * FROM enrollments WHERE enrollment_date >= '2024-01-01'
    )
SELECT s.first_name, s.last_name, COUNT(*) AS course_count
FROM active_students s
JOIN recent_enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name;
```

---

## String Functions

```sql
-- Concatenation
SELECT first_name || ' ' || last_name AS full_name FROM students;
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM students;

-- Case conversion
SELECT UPPER(first_name), LOWER(last_name) FROM students;

-- Substring
SELECT SUBSTRING(email FROM 1 FOR 10) FROM students;
SELECT LEFT(email, 10), RIGHT(email, 15) FROM students;

-- Trim whitespace
SELECT TRIM(first_name), LTRIM(last_name), RTRIM(email) FROM students;

-- Length
SELECT first_name, LENGTH(first_name) AS name_length FROM students;

-- Replace
SELECT REPLACE(email, '@gmail.com', '@school.edu') FROM students;
```

---

## Date Functions

```sql
-- Current date/time
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;
SELECT NOW();

-- Extract parts
SELECT EXTRACT(YEAR FROM enrollment_date) AS year FROM students;
SELECT DATE_PART('month', enrollment_date) AS month FROM students;

-- Date arithmetic
SELECT enrollment_date + INTERVAL '1 year' AS one_year_later FROM students;
SELECT enrollment_date - INTERVAL '6 months' AS six_months_earlier FROM students;

-- Age calculation
SELECT first_name, AGE(CURRENT_DATE, date_of_birth) AS age FROM students;

-- Format dates
SELECT TO_CHAR(enrollment_date, 'YYYY-MM-DD') FROM students;
SELECT TO_CHAR(enrollment_date, 'Month DD, YYYY') FROM students;
```

---

## Best Practices

### 1. Use Clear Column and Table Names
```sql
-- Good
SELECT student_id, first_name, last_name FROM students;

-- Avoid
SELECT sid, fn, ln FROM stud;
```

### 2. Always Use WHERE with UPDATE and DELETE
```sql
-- Dangerous - updates all rows!
-- UPDATE students SET is_active = FALSE;

-- Safe - updates specific rows
UPDATE students SET is_active = FALSE WHERE graduation_date < CURRENT_DATE;
```

### 3. Use Transactions for Related Changes
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```

### 4. Use Indexes for Performance
```sql
CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_major ON students(major);
```

### 5. Use EXPLAIN to Analyze Queries
```sql
EXPLAIN ANALYZE SELECT * FROM students WHERE gpa > 3.5;
```

---

## Summary

SQL provides powerful operations for:
- **Creating and modifying database structure** (DDL)
- **Querying and manipulating data** (DML)
- **Controlling access** (DCL)
- **Managing transactions** (TCL)

Master these fundamentals to work effectively with relational databases.

---

**Next Steps**:
- Practice writing queries
- Learn advanced JOIN techniques
- Understand indexes and query optimization
- Study transactions and concurrency

---

**Last Updated**: March 1, 2026
**Course**: USJ IT Class 2026
