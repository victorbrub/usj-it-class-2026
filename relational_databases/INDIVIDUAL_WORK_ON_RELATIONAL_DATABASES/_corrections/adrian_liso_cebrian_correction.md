# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** ADRIÁN LISO CEBRIÁN


**Total Score: 8.65 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 1.0 |
| 2. Accessing the database | 2.0 | 1.85 |
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 2.8 |
| **Total** | **10.0** | **8.65** |

---

**General comments:**

Solid overall submission with a well-structured database design and thorough documentation. The access control section would benefit from an explicit role-permission matrix to make the access policy unambiguous. The verification and optimization sections lack sufficient evidence and explanation. Partitioning should always be the first technique considered in any optimization strategy.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** - 8 tables with primary keys, foreign keys, and constraints. Well-structured schema.

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.2 / 0.2** - ~1279 data rows across 1279 INSERT statements. Meets the >=100 records requirement.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6** - Well-developed scope document. Covers functional purpose, examples, and limitations.

**Section 1 subtotal: 1.0 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.15 / 0.3** Definiton of the access is there, but is missing an access table: where each component of the database is asigned or not to each role.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** Privileges assigned with good coverage.

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.85 / 2.0**

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

**Score: 0.25 / 0.3** - If one of the JOIN names is provided (NATURAL JOIN) the second join should have also the type explicitly (INNER JOIN, LEFT JOIN...)

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0** 

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.75 / 1.5** - Not Partitioning strategy provided. Partitions are the first implementation you should make when optimizing a database.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.1 / 0.5** - Partial evidence an no explanation at all on the differences of the execution plan.

**Section 4 subtotal: 2.8 / 4.0**
