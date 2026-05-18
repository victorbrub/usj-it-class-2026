# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** SAMUEL SANTOS GONZALEZ


**Total Score: 8.8  / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 1.0 |
| 2. Accessing the database | 2.0 | 1.8 |
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 3.0 |
| **Total** | **10.0** | **8.8** |

---

**General comments:**

Excellent submission overall. The database model is well designed, the transactions and concurrency section is thorough, and the optimization documentation is comprehensive. The optimization plan lacks a partitioning strategy and the uptimized query is not showing optimization results.

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

**Score: 0.3 / 0.3**

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.2 / 0.3** - CREATE USER statements not included in access_control.sql.

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.4 / 0.5** - GRANT statements not included in access_control.sql; 

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

**Score: 1.0 / 1.5** - Partitioning strategy not included, which limits the completeness of the optimization plan.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.0 / 0.5** - Optimization not explained, and not correctly shown. Optimized query faster then standard query without explanation, so maybe the query is not suited for the optimization. In that cases, adding more data can clear the issue. Also standard query plan shows signs of having indexes.

**Section 4 subtotal: 3.0 / 4.0**
