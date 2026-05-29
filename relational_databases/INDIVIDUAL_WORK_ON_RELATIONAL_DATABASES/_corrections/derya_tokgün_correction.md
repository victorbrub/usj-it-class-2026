# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** DERYA TOKGÜN

**Total Score: 8.8 / 10**

## Summary

| Section                                 | Max      | Score   |
| --------------------------------------- | -------- | ------- |
| 1. Creating the database                | 1.0      | 1.0     |
| 2. Accessing the database               | 2.0      | 1.8     |
| 3. Transactions and concurrency control | 3.0      | 3.0     |
| 4. Optimization                         | 4.0      | 3.0     |
| **Total**                               | **10.0** | **8.8** |

---

**General comments:**

The access control section relies exclusively on pgAdmin screenshots rather than SQL scripts, which limits verifiability and does not produce reusable code artifacts. The optimization SQL correctly applies indexing and clustering, but partitioning is mentioned in the plan document without being implemented in the script. Also no explantion on the results of optimization.

---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6**

**Section 1 subtotal: 1.0 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.2 / 0.3** - No structured role-permission matrix or design document was provided. It is not possible to confirm what operations each role is permitted on each table without a written definition.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.4 / 0.5** - No SQL GRANT script was provided; individual grant coverage cannot be verified from a screenshot alone.

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.8 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.75 / 0.75**

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.25 / 0.25** 

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.5 / 0.5**

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 1.0 / 1.0** 

**Section 3 subtotal: 3.0 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.4 / 0.4** 

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0**

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 1.0 / 1.5** - Partitioning is described and justified in optimization.md but is absent from the SQL implementation. Partitioning should be the first technique applied when optimizing a database for large or growing tables.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.0 / 0.5** - 'Before' Query not showing execution plan so no 

**Section 4 subtotal: 3.0 / 4.0**
