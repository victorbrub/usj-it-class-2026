# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** ÁLVARO GARCÍA SERRANO


**Total Score: 8.7 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.9 |
| 2. Accessing the database | 2.0 | 2.0 |
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 2.8 |
| **Total** | **10.0** | **8.7** |

---

**General comments:**

The work is generally competent, though several sections contain technical inaccuracies that reduce the overall quality. The record count requirement is not fully met, and the corrected SQL query keeps unnecessary joins that produce duplicates rather than addressing the root problem. The optimization plan is broadly correct but lacks sufficient depth and motivation. More careful review of your own solutions before submission is needed.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.1 / 0.2** - Below the 100 records per table requirement.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6** 

**Section 1 subtotal: 0.9 / 1.0**

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

**Score: 0.25 / 0.25** - Although the phantom read problem is solved, the schedule is serializable but not serial. You can add the SERIALIZABLE isolation level for better isolation. Anyway the problem is solved so its OK.

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.5 / 0.5**

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 1.0 / 1.0** 

**Section 3 subtotal: 3.0 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.15 / 0.3** - 2 errors identified (WHERE before FROM; NATURAL JOIN issue). But not the one of the ON condition of the second JOIN "ON user_id = orders.user_id": only orders table has user_id so this condition has no sense and will throw an error.

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.4 / 0.4**

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0 / 0.3** The query fixed is much more simpler. Your corrected query work, and its OK. BUT you are selecting and filtering only fields from the PRODUCT table, so it has no sense to make the joins. In fact, the joins will only add duplicates to your result. This is the corrected version:

```sql

SELECT name, price
FROM products
WHERE stock > 0 AND category_id < 3;

```

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0** 

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.75 / 1.5** - Optimization plan considers all needed steps but suffers from several issues. Examples:
- For large datasets in **orders**, it is better to have daily partitioning for improving partition prunning. If not, if you want to query December 2025 and January 2026, you will scan partitions for two full years.
- Clustering Dependency: Clarify that clustering choice depends on dominant query patterns (user-based vs. time-based). You can only cluster on ONE index, so choose based on your most frequent queries.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.5 / 0.5**

**Section 4 subtotal: 2.8 / 4.0**
