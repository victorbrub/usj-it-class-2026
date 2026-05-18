# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** DARÍO SARASA NAVARRO


**Total Score: 7.0 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 1.0 |
| 2. Accessing the database | 2.0 | 1.7 |
| 3. Transactions and concurrency control | 3.0 | 2.25 |
| 4. Optimization | 4.0 | 2.8 |
| **Total** | **10.0** | **7.75** |

---

**General comments:**

The submission addresses all required sections but lacks the depth and explanation expected at this level. Several sections consist of code or query results with no accompanying justification, which makes it impossible to assess whether the underlying concepts are understood. The concurrency analysis contains a conceptual error in identifying the problem type. All technical claims must be supported with clear written reasoning.
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

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.1 / 0.3** - No explanation of the process at all.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.5 / 0.6** - Not isolated view on the document. You need to work on presenting your results.

**Section 2 subtotal: 1.7 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.0 / 0.75** - Incorrect concurrency problem identified. The main problem is a lost update: T2 commits after T1 but overwrites T1's value without re-reading T1's committed write.

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.25 / 0.25** 

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 1.0 / 1.0** 

**Section 3 subtotal: 2.25 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.4 / 0.4** 

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.1 / 0.3** - The query works and its correct semmantically, but the join on Account_Categories is useless, as you are not retrieving nor filtering fields from that table, so the only thing this join can do is to provide duplicates on your result. You should have removed it.

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0** ¡

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.5 / 1.5** - Optimization plan covers only basic techniques (indexes) and with poor implementation. You need to consider on that order: Partitioning, Clustering, Indexing. You obnly applied indexing, and only on some tables.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.5 / 0.5** 

**Section 4 subtotal: 2.8 / 4.0**
