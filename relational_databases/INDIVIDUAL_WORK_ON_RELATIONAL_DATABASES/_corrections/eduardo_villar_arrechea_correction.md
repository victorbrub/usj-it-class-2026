# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** EDUARDO VILLAR ARRECHEA


**Total Score: 7.8 / 10**

## Summary
 
| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.6 |
| 2. Accessing the database | 2.0 | 1.7 |
| 3. Transactions and concurrency control | 3.0 | 1.5 |
| 4. Optimization | 4.0 | 4.0 |
| **Total** | **10.0** | **7.8** |

---

**General comments:**

The submission has notable weaknesses that significantly affect the final score. A large number of tables do not reach the 100-record minimum, which undermines any meaningful performance analysis. Triggers were introduced without explanation and appear to be AI-generated content on a topic not covered in the course. The concurrency demonstration video is entirely missing, and the concurrency problem is also misidentified.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.0 / 0.2** You added triggers, that we did not cover in class, and with no explanation at all. Probably AI generated.

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.0 / 0.2** - Some tables below requirement of 100 records. Counts: ability:25, build:2, build_item:1, game:1, game_player:3, hero:25, item:105, player:40, spirit:2, vitality:2, weapon:2.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.6 / 0.6** 

**Section 1 subtotal: 0.6 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3**

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.0 / 0.3** - Comprehensive, but no screenshots (required). 

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.6 / 0.6** 

**Section 2 subtotal: 1.7 / 2.0**

---

## Section 3 - Transactions and Concurrency Control (3 points)

### Exercise 3.1 - True/False: Serializability (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.2 - Concurrency Problems (0.75 points)

**Score: 0.25 / 0.75** - Incorrect concurrency problem identified. The main problem is a lost update: T2 commits after T1 but overwrites T1's value without re-reading T1's committed write.

### Exercise 3.3 - Correct the Schedule (0.25 points)

**Score: 0.25 / 0.25** 

### Exercise 3.4 - Serial or Serializable? (0.5 points)

**Score: 0.5 / 0.5** 

### Exercise 3.5 - Demonstrate Concurrency Problem (1 point)

**Score: 0.0 / 1.0** - No video found. A video demonstrating a concurrency problem is required.

**Section 3 subtotal: 1.5 / 3.0**

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

**Score: 1.5 / 1.5** -

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0.5 / 0.5**

**Section 4 subtotal: 4.0 / 4.0**
