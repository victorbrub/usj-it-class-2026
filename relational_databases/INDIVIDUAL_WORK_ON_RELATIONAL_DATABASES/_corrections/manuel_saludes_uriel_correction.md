# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** MANUEL SALUDES URIEL


**Total Score: 5.25 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.8 |
| 2. Accessing the database | 2.0 | 1.0 |
| 3. Transactions and concurrency control | 3.0 | 1.2 |
| 4. Optimization | 4.0 | 2.25 |
| **Total** | **10.0** | **5.25** |

---

**General comments:**

The submission covers the basic structure of the assignment but has substantial gaps across multiple sections. The concurrency problem is misidentified, the view for the derived attribute exercise is missing, no video evidence is provided for the concurrency demonstration, and the optimization section lacks both motivation and execution plan comparison. A significant portion of the required deliverables is either absent or incomplete.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2**

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.4 / 0.6** - Limitations not clearly stated.

**Section 1 subtotal: 0.8 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.2 / 0.3** - Roles defined but coverage across all user types is incomplete.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5**

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.0 / 0.3** - No access verification screenshots or evidence found.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.0 / 0.6** - No CREATE VIEW found for derived/composite attribute exercise.

**Section 2 subtotal: 1.0 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.25 / 0.75** - Incorrect concurrency problem identified. The main problem is a lost update: T2 commits after T1 but overwrites T1's value without re-reading T1's committed write.

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.2 / 0.25** - Corrected schedule concept described but schedule table not fully shown.

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.25 / 0.5** - Partial answer. Should clarify both serial and serializable nature of the corrected schedule.

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 0.0 / 1.0** - No video found. A video demonstrating a concurrency problem is required.

**Section 3 subtotal: 1.2 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.4 / 0.4** 

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 0.5 / 1.0** - No explanation at all.

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.5 / 1.5** - Optimization plan lacks motivation on the optimizations made: why you are making those optimizations?

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.25 / 0.5** - You should explain and compare the query plans.

**Section 4 subtotal: 2.25 / 4.0**
