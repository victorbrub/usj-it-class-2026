# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** SERGIO SANMARTÍN AZNAR


**Total Score: 7.45 / 10**

## Summary

| Section | Max | Score | 
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.7 |
| 2. Accessing the database | 2.0 | 1.75 |
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 2.0 |
| **Total** | **10.0** | **7.45** |

---

**General comments:**

The main structural issue in this submission is that the SQL scripts were embedded in the main markdown file rather than delivered as standalone files, as the assignment required. The optimization section provides no supporting files, no execution plans, and no justification for the techniques applied. The access control implementation is also partial, with the receptionist role missing privilege assignments. Adherence to the delivery format is part of the evaluation.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.05 / 0.2** - Create_database.sql not found. Create tables inside main .md, but delivery not as requested.

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.05 / 0.2** - populate_database.sql not found. Same issue as create_database.sql.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6** - Comprehensive scope (414 words). Covers use cases, examples, and limitations.

**Section 1 subtotal: 0.7 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.4 / 0.5** - 8 GRANT statement(s) found. Partial privilege coverage. Missing grants for receptionist role.

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.15 / 0.3** - 1 screenshot(s) found. Access verification present but not all scenarios covered.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.75 / 2.0**

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

**Score: 0.0 / 1.5** - Neither optimization.md nor optimize_database.sql found. The indexes and cluster defined are provided with no justification or motivation at all (common queries to the database for example.). Missing partitioning approach.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.0 / 0.5** - No execution plans added, cannot see the result of he optimization nor the query.

**Section 4 subtotal: 2.0 / 4.0**
