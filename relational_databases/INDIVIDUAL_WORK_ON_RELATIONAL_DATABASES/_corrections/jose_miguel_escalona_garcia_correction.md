# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** JOSÉ MIGUEL ESCALONA GARCÍA


**Total Score: 4.7 / 10**

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.9 |
| 2. Accessing the database | 2.0 | 1.3 |
| 3. Transactions and concurrency control | 3.0 | 0.4 |
| 4. Optimization | 4.0 | 2.1 |
| **Total** | **10.0** | **4.7** |

---

**General comments:**

The submission is substantially incomplete and does not meet the minimum expectations for this assignment. Critical sections are either absent or answered superficially, and several theoretical questions are incorrect, including the serializability true/false question and the concurrency problem identification. The optimization section is particularly deficient, with no execution cost calculation and no analysis provided. A thorough review of the course material is strongly recommended.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.2 / 0.2** .

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.2 / 0.2** 

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.5 / 0.6** - Brief scope, I was expecting more detail.

**Section 1 subtotal: 0.9 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.0 / 0.3** - No definition on user access: type of user, data that each type of user can access, etc.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.2 / 0.3** Limited user coverage.

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.0 / 0.3** - No access verification screenshots or evidence found.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.3 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.0 / 0.5** - Incorrect answer (TRUE). The statement is FALSE: the schedule is not serial due to interleaving, not because it is serializable. Serial schedules are also serializable.

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.0 / 0.75** - No concurrency problem identified. The correct answer is: lost update. T2 overwrites T1's committed write.

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.2 / 0.25** - Why the WAIT on T2 instead of having T1 COMMIT before the T2 BEGIN??

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.2 / 0.5** - OK, but WHY???

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 0.0 / 1.0**  - No video Found.

**Section 3 subtotal: 0.4 / 3.0**

---

## Section 4 - Optimization (4 points)

### Exercise 4.1 - Identify Query Errors (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.2 - Map Errors to Processing Steps (0.4 points)

**Score: 0.0 / 0.4** - This is not serious. We talked about it in class and it is in the slides. Instead of asking ChatGPT you can ask me.

### Exercise 4.3 - Fix the Query (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 0.0 / 1.0** - No execution cost calculation found.

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 1.5 / 1.5**

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.0 / 0.5** - Not provided.

**Section 4 subtotal: 2.1 / 4.0**
