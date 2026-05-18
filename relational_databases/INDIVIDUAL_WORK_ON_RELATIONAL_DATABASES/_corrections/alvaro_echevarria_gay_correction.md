# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** ÁLVARO ECHEVERRÍA GAY


**Total Score: 8.70 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.7 |
| 2. Accessing the database | 2.0 | 2.0 |
| 3. Transactions and concurrency control | 3.0 | 2.9 |
| 4. Optimization | 4.0 | 3.25 |
| **Total** | **10.0** | **8.85** |

---

**General comments:**

Good work overall, with solid performance in concurrency and optimization. The database population does not fully meet the minimum record requirements in all tables, which limits the validity of any performance analysis. The scope document covers the basics but would benefit from concrete real-world use cases rather than enumerated lists. The most significant omission is the absence of a partitioning strategy in the optimization plan.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.1 / 0.2** - Not all tables meet the minimum of 100 rows (accessory). Also, being your approach correct, could have been optimal (and easy) to add >=1000 rows or so for the database optimizations an analyses be more clear.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.4 / 0.6** - Adequate scope but examples could be better explained, not only enumerated, with real world use cases for each.

**Section 1 subtotal: 0.70 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 2.0 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.75 / 0.75**

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.25 / 0.25**

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.4 / 0.5** Should also note it is trivially serializable.

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 1.0 / 1.0** 

**Section 3 subtotal: 2.90 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.4 / 0.4** .

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0**

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.75 / 1.5** - No partitioning strategy discussed or implemented. This should be the first thing addressed when designing the optimization plan.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.5 / 0.5**

**Section 4 subtotal: 3.25 / 4.0**
