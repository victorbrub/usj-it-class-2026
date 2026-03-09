# Introduction to Relational Databases

## What is a Database?

A **database** is an organized collection of structured data that is stored and accessed electronically. It provides a systematic way to store, retrieve, and manage information efficiently.

### Why Use Databases?

- **Data Organization**: Structure data in meaningful ways
- **Data Integrity**: Ensure accuracy and consistency
- **Concurrent Access**: Multiple users can access data simultaneously
- **Security**: Control who can access what data
- **Scalability**: Handle growing amounts of data
- **Persistence**: Data survives system crashes and power failures

## What is a Relational Database?

A **relational database** organizes data into tables (also called relations) consisting of rows and columns. The relationships between tables are what make these databases "relational."

### Key Characteristics

1. **Tables (Relations)**: Data is stored in tables with rows and columns
2. **Schemas**: Each table has a defined structure (schema)
3. **Relationships**: Tables can be connected through foreign keys
4. **SQL**: Uses Structured Query Language for data manipulation
5. **ACID Properties**: Ensures reliable transactions

## Relational Database Management Systems (RDBMS)

An RDBMS is software that manages relational databases. Popular examples:

| RDBMS | Developer | Key Features | Common Use Cases |
|-------|-----------|--------------|------------------|
| PostgreSQL | Open Source | Advanced features, extensible, standards-compliant | Web applications, data warehousing, GIS |
| MySQL | Oracle (Open Source) | Fast, reliable, widely supported | Web applications, e-commerce |
| Oracle Database | Oracle | Enterprise-grade, robust, scalable | Large enterprises, financial systems |
| Microsoft SQL Server | Microsoft | Integrates with Microsoft ecosystem | Enterprise applications, business intelligence |
| SQLite | Open Source | Lightweight, serverless, embedded | Mobile apps, embedded systems, prototyping |

## Core Concepts

### 1. Tables

Tables are the fundamental building blocks of relational databases. Each table represents an entity (e.g., customers, products, orders).

**Structure**:
- **Columns (Attributes)**: Define what type of data each field holds
- **Rows (Tuples/Records)**: Individual instances of data

**Example: Students Table**

| student_id | first_name | last_name | email | enrollment_date |
|------------|------------|-----------|-------|-----------------|
| 1 | John | Doe | john@email.com | 2024-09-01 |
| 2 | Jane | Smith | jane@email.com | 2024-09-01 |
| 3 | Bob | Johnson | bob@email.com | 2024-09-15 |

### 2. Primary Keys

A **primary key** is a column (or combination of columns) that uniquely identifies each row in a table.

**Characteristics**:
- Must contain UNIQUE values
- Cannot contain NULL values
- Each table should have one primary key
- Often auto-incrementing integers

**Example**:
```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,  -- Primary key
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);
```

### 3. Foreign Keys

A **foreign key** is a column that creates a relationship between two tables by referencing the primary key of another table.

**Example**:
```sql
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),  -- Foreign key
    course_id INTEGER REFERENCES courses(course_id),      -- Foreign key
    enrollment_date DATE
);
```

### 4. Data Types

Common data types in PostgreSQL:

| Category | Data Type | Description | Example |
|----------|-----------|-------------|---------|
| Numeric | INTEGER | Whole numbers | 42, -100 |
| Numeric | DECIMAL(p,s) | Exact decimal numbers | 19.99, 100.50 |
| Numeric | SERIAL | Auto-incrementing integer | 1, 2, 3... |
| Text | VARCHAR(n) | Variable-length string (max n chars) | 'John Doe' |
| Text | TEXT | Unlimited length string | Long descriptions |
| Date/Time | DATE | Calendar date | '2026-03-01' |
| Date/Time | TIME | Time of day | '14:30:00' |
| Date/Time | TIMESTAMP | Date and time | '2026-03-01 14:30:00' |
| Boolean | BOOLEAN | True/false values | TRUE, FALSE |

### 5. Constraints

Constraints enforce rules on data to maintain integrity:

**Common Constraints**:

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,                    -- PRIMARY KEY constraint
    product_name VARCHAR(100) NOT NULL,               -- NOT NULL constraint
    price DECIMAL(10,2) CHECK (price > 0),           -- CHECK constraint
    category VARCHAR(50) DEFAULT 'General',           -- DEFAULT constraint
    sku VARCHAR(20) UNIQUE                            -- UNIQUE constraint
);
```

- **PRIMARY KEY**: Uniquely identifies each row
- **FOREIGN KEY**: Links to another table
- **NOT NULL**: Column must have a value
- **UNIQUE**: No duplicate values allowed
- **CHECK**: Value must satisfy a condition
- **DEFAULT**: Default value if none provided

## Relationships Between Tables

### One-to-One (1:1)

One record in Table A relates to exactly one record in Table B.

**Example**: Person and Passport

```sql
CREATE TABLE persons (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE passports (
    passport_id SERIAL PRIMARY KEY,
    passport_number VARCHAR(20) UNIQUE,
    person_id INTEGER UNIQUE REFERENCES persons(person_id)
);
```

### One-to-Many (1:N)

One record in Table A can relate to many records in Table B.

**Example**: Customer and Orders

```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE
);
```

One customer can have many orders, but each order belongs to one customer.

### Many-to-Many (M:N)

Records in Table A can relate to many records in Table B, and vice versa.

**Example**: Students and Courses

```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Junction/Bridge table
CREATE TABLE enrollments (
    student_id INTEGER REFERENCES students(student_id),
    course_id INTEGER REFERENCES courses(course_id),
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id)
);
```

Students can enroll in many courses, and courses can have many students.

## Database Design Principles

### Normalization

**Normalization** is the process of organizing data to reduce redundancy and improve data integrity.

**Goals**:
- Eliminate redundant data
- Ensure data dependencies make sense
- Make the database flexible and maintainable

**Normal Forms**:

**First Normal Form (1NF)**:
- Each column contains atomic (indivisible) values
- Each column contains values of a single type
- Each row is unique

**Second Normal Form (2NF)**:
- Meets 1NF requirements
- All non-key attributes depend on the entire primary key

**Third Normal Form (3NF)**:
- Meets 2NF requirements
- No transitive dependencies (non-key attributes don't depend on other non-key attributes)

### Entity-Relationship (ER) Diagrams

ER diagrams visually represent database structure:

**Components**:
- **Entities**: Represented by rectangles (e.g., Student, Course)
- **Attributes**: Represented by ovals (e.g., name, age)
- **Relationships**: Represented by diamonds (e.g., enrolls in)

**Cardinality Notation**:
- 1:1 (one-to-one)
- 1:N (one-to-many)
- M:N (many-to-many)

## ACID Properties

ACID ensures database transactions are processed reliably:

### Atomicity
**All or nothing**: Either all operations in a transaction complete successfully, or none do.

**Example**: Transferring money between accounts
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```
Both updates happen, or neither happens.

### Consistency
**Valid state**: Database moves from one valid state to another, maintaining all rules and constraints.

### Isolation
**Independent transactions**: Concurrent transactions don't interfere with each other.

### Durability
**Permanent changes**: Once committed, changes persist even if the system crashes.

## Database vs. Spreadsheet

| Feature | Database | Spreadsheet |
|---------|----------|-------------|
| Data Volume | Millions of records | Thousands of rows |
| Concurrent Users | Many simultaneous users | Limited collaboration |
| Data Integrity | Enforced constraints | Manual validation |
| Complex Queries | Powerful SQL capabilities | Limited formulas |
| Security | Granular access control | Basic protection |
| Relationships | Built-in relationships | Manual references |
| Performance | Optimized for large data | Slows with size |

## Advantages of Relational Databases

1. **Data Integrity**: Constraints ensure data accuracy
2. **Flexibility**: Easy to add, modify, or query data
3. **Standardization**: SQL is widely understood and portable
4. **Security**: Fine-grained access control
5. **Reduced Redundancy**: Normalization minimizes duplication
6. **Complex Queries**: JOIN operations allow sophisticated data retrieval
7. **ACID Compliance**: Reliable transactions
8. **Mature Technology**: Decades of development and best practices

## Disadvantages and Limitations

1. **Rigid Schema**: Structure must be defined upfront
2. **Scalability**: Horizontal scaling can be challenging
3. **Complex Relationships**: Many JOINs can impact performance
4. **Not Ideal for Unstructured Data**: Better suited for structured data
5. **Learning Curve**: Requires understanding of SQL and database design

## When to Use Relational Databases

**Ideal For**:
- Structured data with clear relationships
- Applications requiring data consistency
- Complex queries and reporting
- Multiple users needing concurrent access
- Banking, e-commerce, inventory management
- Content management systems
- Enterprise resource planning (ERP)

**Consider Alternatives For**:
- Unstructured data (documents, images)
- Need for extreme horizontal scalability
- Rapid schema changes
- Key-value or document-based data models

## Common Database Operations

### CRUD Operations

The fundamental operations in any database:

- **Create**: INSERT new records
- **Read**: SELECT/query data
- **Update**: UPDATE existing records
- **Delete**: DELETE records

**Example**:
```sql
-- Create
INSERT INTO students (first_name, last_name) VALUES ('John', 'Doe');

-- Read
SELECT * FROM students WHERE last_name = 'Doe';

-- Update
UPDATE students SET first_name = 'Jane' WHERE student_id = 1;

-- Delete
DELETE FROM students WHERE student_id = 1;
```

## Real-World Example: E-Commerce Database

Let's design a simplified e-commerce database:

### Tables:

1. **customers**: customer_id, name, email, phone
2. **products**: product_id, name, description, price, stock_quantity
3. **orders**: order_id, customer_id, order_date, total_amount, status
4. **order_items**: order_item_id, order_id, product_id, quantity, price

### Relationships:
- One customer can have many orders (1:N)
- One order can have many order items (1:N)
- One product can appear in many order items (1:N)

### Sample Schema:
```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL
);
```

## Summary

Relational databases provide:
- Structured data organization in tables
- Relationships between data entities
- Data integrity through constraints
- Powerful query capabilities with SQL
- ACID properties for reliable transactions
- Mature, well-understood technology

Understanding relational databases is fundamental to modern software development and data management.

---

**Next Steps**: 
- Learn SQL syntax for querying data
- Practice database design and normalization
- Understand transactions and concurrency
- Explore access control and security

---

**Last Updated**: March 1, 2026
**Course**: USJ IT Class 2026
