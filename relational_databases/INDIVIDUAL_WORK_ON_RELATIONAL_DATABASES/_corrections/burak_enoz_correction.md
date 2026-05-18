# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** BURAK ENÖZ


**Total Score: 8.4 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.9 |
| 2. Accessing the database | 2.0 | 1.8 |
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 2.7 |
| **Total** | **10.0** | **8.4** |

---

**General comments:**

The submission demonstrates a reasonable understanding of the covered topics. However, the separation of concerns between scripts is not respected: the create_database script includes views and permission grants that belong elsewhere. The query correction is functional but retains joins that serve no purpose and introduce duplicates. Partitioning is entirely absent from the optimization plan and should always be the first technique considered.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.15 / 0.2** - Create database script has also the views and permission grants. This is not part of the requirements.

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.15 / 0.2** - First variable `SET search_path = marine_biology;` present but not used.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6** 

**Section 1 subtotal: 0.90 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.1 / 0.3** - Missing some context like who are the roles defined to.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** 

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

**Score: 0 / 0.3** -  The query fixed is much more simpler. Your corrected query work, and its OK. BUT you are selecting and filtering only fields from the CREATURES table, so it has no sense to make the joins. In fact, the joins will only add duplicates to your result. This is the corrected version:

```sql

SELECT c.scientific_name,c.common_name
FROM Creatures c
WHERE c.habitat_id =3 AND c.min_depth <200;

```

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0**

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 1.0 / 1.5** - No partitioning applied. Partitioning is the first thing to consider when optimizing a database as it can lead to the most significant performance improvement.

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0 / 0.5** - Screenshots thrown but no discussion. Also, query on the optimized database is slower. This must be discussed, and may be because:
- Not enough records per table to increase query times.
- Optimizations implemented are wrong for the use cases.
- Query is not designed for the optimizations made.

If you see, no Index Scan made on the query ran after the optimization, so you are querying and filtering along fields that does not activate the indexes. 

Here are the issues:

1. Missing ORDER BY Index: The query uses ORDER BY o.observed_at DESC, but no index exists on observed_at, forcing an expensive full sort operation instead of leveraging an index for ordered retrieval.

2. No Composite Index: Filters on both h.region and o.observation_depth exist separately, but no composite index covers the filter + join path, causing the optimizer to use suboptimal access plans.

3. No Covering Index: The query selects 6 columns across 4 tables, but no covering index exists to provide all needed data, forcing table lookups 
after index scans.

4. Join Order Not Optimized: Without composite indices guiding the optimizer, it may not choose the most efficient join order (filtering Habitats by region first would be faster).

**Section 4 subtotal: 2.7 / 4.0**
