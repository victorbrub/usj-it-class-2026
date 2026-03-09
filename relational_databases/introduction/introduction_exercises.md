# Introduction to Relational Databases - Exercises

## Exercise 1: Understanding Database Concepts (15 minutes)

### Question 1.1: Define Terms
Define the following terms in your own words:

a) Database:

b) Table:

c) Primary Key:

d) Foreign Key:

e) Constraint:

### Question 1.2: RDBMS Comparison
Research and compare two RDBMS systems (e.g., PostgreSQL vs MySQL):

| Feature | RDBMS 1: ________ | RDBMS 2: ________ |
|---------|-------------------|-------------------|
| Developer | | |
| License Type | | |
| Key Strengths | | |
| Common Use Cases | | |
| Your Recommendation | | |

### Question 1.3: Database vs Spreadsheet
List three scenarios where a database would be better than a spreadsheet, and explain why:

1.

2.

3.

---

## Exercise 2: Identifying Entities and Attributes (20 minutes)

### Scenario: University Management System

You need to design a database for a university. Read the requirements below and identify entities and their attributes.

**Requirements**:
- Track students (name, ID, email, enrollment date, major)
- Track courses (course code, name, credits, department)
- Students enroll in courses
- Professors teach courses
- Track grades for each student in each course

### Question 2.1: Identify Entities
List all entities (tables) needed:

1.
2.
3.
4.
5.

### Question 2.2: List Attributes
For each entity, list the attributes (columns):

**Students**:
-
-
-

**Courses**:
-
-
-

**Professors**:
-
-
-

### Question 2.3: Identify Primary Keys
For each entity, suggest an appropriate primary key:

- Students: _______________
- Courses: _______________
- Professors: _______________

---

## Exercise 3: Understanding Relationships (25 minutes)

### Question 3.1: Identify Relationship Types
For each pair of entities below, identify the relationship type (1:1, 1:N, or M:N):

a) Person ↔ Passport: _______

b) Customer ↔ Orders: _______

c) Students ↔ Courses: _______

d) Country ↔ Capital City: _______

e) Employee ↔ Department: _______

f) Author ↔ Books: _______

g) Driver ↔ Driver's License: _______

### Question 3.2: Design Relationships
For the university system from Exercise 2, identify relationships:

1. Students and Courses:
   - Type: _______
   - Why: 

2. Professors and Courses:
   - Type: _______
   - Why: 

3. Students and Grades:
   - Type: _______
   - Why: 

### Question 3.3: Junction Tables
For any M:N relationships identified above, design a junction table:

**Example**: Students ↔ Courses
```
Junction Table Name: _______________

Columns:
-
-
-
```

---

## Exercise 4: Data Types (15 minutes)

### Question 4.1: Choose Appropriate Data Types
For each attribute below, choose the most appropriate PostgreSQL data type:

| Attribute | Data Type | Reasoning |
|-----------|-----------|-----------|
| Student ID | | |
| Student Name | | |
| Date of Birth | | |
| GPA (0.00 to 4.00) | | |
| Is Active Student | | |
| Course Credits | | |
| Student Bio | | |
| Registration Timestamp | | |

### Question 4.2: Validate Data Types
Identify problems with these data type choices:

```sql
CREATE TABLE products (
    product_id VARCHAR(50),           -- Problem?
    name TEXT,
    price INTEGER,                    -- Problem?
    in_stock VARCHAR(10),            -- Problem?
    created_date VARCHAR(20)         -- Problem?
);
```

Problems identified:
1.
2.
3.
4.

---

## Exercise 5: Constraints (20 minutes)

### Question 5.1: Identify Necessary Constraints
For a students table, what constraints should be applied?

```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    email VARCHAR(100),
    age INTEGER,
    enrollment_date DATE,
    gpa DECIMAL(3,2)
);
```

Add appropriate constraints:
- Email:
- Age:
- GPA:
- Enrollment Date:

### Question 5.2: Write the SQL
Rewrite the above table definition with all appropriate constraints:

```sql
CREATE TABLE students (
    -- Your answer here
);
```

### Question 5.3: Constraint Violations
For each scenario, identify which constraint would be violated:

a) Trying to insert a student with student_id = 5 when student_id 5 already exists:
   Constraint: _______________

b) Trying to insert a student without an email address when email is marked NOT NULL:
   Constraint: _______________

c) Trying to insert a student with age = -5:
   Constraint: _______________

d) Trying to insert a course enrollment for a student_id that doesn't exist in students table:
   Constraint: _______________

---

## Exercise 6: ACID Properties (15 minutes)

### Question 6.1: ACID Scenarios
For each scenario, identify which ACID property is being demonstrated:

a) A bank transfer moves $100 from Account A to Account B. Either both the withdrawal and deposit happen, or neither happens.
   Property: _______________

b) After a database crash, all completed transactions are still in the database.
   Property: _______________

c) Two users trying to book the same seat don't both succeed; one gets it, the other sees it's taken.
   Property: _______________

d) All CHECK constraints are satisfied after a transaction completes.
   Property: _______________

### Question 6.2: Real-World ACID
Describe a real-world scenario where each ACID property is critical:

**Atomicity**:

**Consistency**:

**Isolation**:

**Durability**:

---

## Exercise 7: Normalization (30 minutes)

### Question 7.1: Identify Issues
This table design has problems. Identify what's wrong:

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_phone VARCHAR(20),
    product_names TEXT,              -- "Laptop, Mouse, Keyboard"
    product_prices TEXT,             -- "999.99, 29.99, 79.99"
    quantities TEXT,                 -- "1, 2, 1"
    order_total DECIMAL(10,2),
    order_date DATE
);
```

Problems identified:
1.
2.
3.

### Question 7.2: Normalize the Design
Redesign the above into properly normalized tables:

```sql
-- Table 1
CREATE TABLE _____________ (
    -- Your design
);

-- Table 2
CREATE TABLE _____________ (
    -- Your design
);

-- Table 3
CREATE TABLE _____________ (
    -- Your design
);

-- Additional tables if needed
```

### Question 7.3: Explain Benefits
List three benefits of your normalized design:

1.
2.
3.

---

## Exercise 8: Design a Database (45 minutes)

### Scenario: Library Management System

Design a complete database for a library that tracks:
- Books (title, ISBN, author, publication year, genre, number of copies)
- Members (name, membership ID, email, phone, join date)
- Loans (which member borrowed which book, loan date, due date, return date)
- Authors (can write multiple books)
- Genres (can have multiple books)

### Question 8.1: Entity List
List all entities (tables) needed:

1.
2.
3.
4.
5.

### Question 8.2: Complete Schema Design
Write the complete SQL to create all tables with:
- Appropriate data types
- Primary keys
- Foreign keys
- Constraints
- Comments explaining your choices

```sql
-- Your complete database design here
```

### Question 8.3: Sample Data
Write INSERT statements to add sample data:
- At least 3 authors
- At least 5 books
- At least 3 members
- At least 2 loans

```sql
-- Your INSERT statements here
```

### Question 8.4: Justify Design
Explain your design choices:

1. Why did you choose this structure?

2. What relationships did you identify?

3. What constraints did you add and why?

4. Is your design normalized? To what level?

---

## Exercise 9: Real-World Analysis (20 minutes)

### Question 9.1: Analyze an Application
Choose a real application you use (e.g., Instagram, Spotify, Netflix, online store).

**Application chosen**: _______________

Identify:
1. What entities (tables) do you think it has?
   -
   -
   -

2. What relationships exist between entities?
   -
   -

3. What constraints would be important?
   -
   -

4. What challenges might this database face?
   -
   -

### Question 9.2: Database Selection
For each scenario, would you recommend a relational database? Why or why not?

a) Social media platform with posts, likes, comments:


b) Financial transaction processing system:


c) Real-time chat application:


d) Document storage and retrieval system:


---

## Exercise 10: Critical Thinking (15 minutes)

### Question 10.1: Advantages and Disadvantages
List three advantages and three disadvantages of relational databases:

**Advantages**:
1.
2.
3.

**Disadvantages**:
1.
2.
3.

### Question 10.2: Design Tradeoffs
You're designing a system that needs to handle both:
- Structured product catalog data
- User-generated content (reviews, images)

Discuss the tradeoffs of using:
a) Only a relational database:

b) Only a NoSQL database:

c) Both (hybrid approach):

### Question 10.3: Future Considerations
What factors would influence your decision to use a relational database for a new project?

1.
2.
3.
4.

---

## Bonus Challenge: Complex Design

### Scenario: Online Course Platform
Design a complete database for an online learning platform like Coursera or Udemy that includes:
- Instructors who create courses
- Courses with multiple modules/sections
- Students who enroll in courses
- Video lectures within each module
- Quizzes and assignments
- Student progress tracking
- Reviews and ratings
- Certificates upon completion

Create:
1. Complete ER diagram (draw or describe)
2. All table definitions with constraints
3. Sample INSERT statements
4. Three complex queries you might need to run

---

## Submission Guidelines

Submit:
1. Answers to all questions
2. All SQL code properly formatted
3. Written explanations for design choices
4. ER diagram for Exercise 8 (can be hand-drawn and scanned)

---

**Estimated Total Time**: 3-4 hours
**Difficulty**: Beginner to Intermediate
**Prerequisites**: None

---

**Last Updated**: March 1, 2026
**Course**: USJ IT Class 2026
