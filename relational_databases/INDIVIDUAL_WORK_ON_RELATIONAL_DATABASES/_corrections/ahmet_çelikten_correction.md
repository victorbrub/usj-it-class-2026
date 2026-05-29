# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** AHMET ÇELIKTEN

**Total Score: 6.1 / 10**

## Summary

| Section                                 | Max      | Score   |
| --------------------------------------- | -------- | ------- |
| 1. Creating the database                | 1.0      | 0.9     |
| 2. Accessing the database               | 2.0      | 1.7     |
| 3. Transactions and concurrency control | 3.0      | 3.0     |
| 4. Optimization                         | 4.0      | 0.5     |
| **Total**                               | **10.0** | **6.1** |

---

**General comments:**

Strong database design demonstrating solid knowledge of relational modeling: proper use of a weak entity (Achievement), a multi-valued attribute table (Game_Genres), and a junction table for an N:M relationship (Library). The populate script is creative and well-populated with realistic data. The scope document is well-structured but brief relative to peers and is missing a dedicated limitations and conclusion section. Sections 2, 3, and 4 were submitted entirely as a single PDF document. While the content is accepted, consolidating all answers into a PDF does not produce reusable SQL artifacts and reduces exercise-level verifiability. Separate SQL files for access control and optimization are strongly preferred.

---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.5 / 0.6** - The document lacks a dedicated limitations section that distinguishes design simplifications from missing features, and has no conclusion.

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

**Score: 0.0 / 0.3** - Access not correctly verified. You should check which users does not have access to the elements that the access is not defined to.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.7 / 2.0**

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

**Score: 0.0 / 0.3** - Not provided.

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.0 / 0.4** - Not provided.

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.0 / 0.3** - Not provided

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 0.0 / 1.0** - Not provided.

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 0.0 / 1.5** - Plan not provided

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.5 / 0.5** - Good analysis. Simple but OK.

**Section 4 subtotal: 0.**5** / 4.0**
