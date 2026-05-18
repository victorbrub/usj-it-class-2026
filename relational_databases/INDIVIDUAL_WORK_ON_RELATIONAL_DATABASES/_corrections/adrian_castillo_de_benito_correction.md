# Author: Víctor Barceló
# Correction - Individual Work I: Relational Databases

**Student:** ADRIÁN CASTILLO DE BENITO

**Total Score: 7.8 / 10**

---

## Summary

| Section | Max | Score |
|---------|-----|-------|
| 1. Creating the database | 1.0 | 0.5 |
| 2. Accessing the database | 2.0 | 0.9|
| 3. Transactions and concurrency control | 3.0 | 3.0 |
| 4. Optimization | 4.0 | 3.4 |
| **Total** | **10.0** | **7.8** |

---

**General comments:**

The submission covers all required sections but quality is inconsistent throughout. Several parts show clear signs of AI-generated content that was not reviewed or adapted to the specific requirements, which results in misplaced content and technical inaccuracies. Presentation must improve significantly: results need to be communicated clearly and professionally, not simply pasted without context.
---

## Section 1 - Creating the Database (1 point)

### Exercise 1.1 - create_database.sql (0.2 points)

**Score: 0.1 / 0.2** Indexes are part of the optimization process, there is no place for those statements here. Probably because response is LLM generated. 

### Exercise 1.2 - populate_database.sql (0.2 points)

**Score: 0.1 / 0.2** Not all tables have >= 100 records: diet table has 15.

### Exercise 1.3 - scope.md (0.6 points)

**Score: 0.3 / 0.6** Missing limitations of the model. A scope of any project shoul focus not only on what this projet can do but also (and most important) on what is NOT able to cover.

**Section 1 subtotal: 0.5 / 1.0**

---

## Section 2 - Accessing the Database (2 points)

### Exercise 2.1 - Define User Access (0.3 points)

**Score: 0.1 / 0.3** Poor definition. What tables can access each role? What operations can each role make to each table? Role access policies should be specific and granular.

### Exercise 2.2 - Create Users (0.3 points)

**Score: 0.3 / 0.3** 

### Exercise 2.3 - Assign Privileges (0.5 points)

**Score: 0.1 / 0.5** Why you created a views here? You had to grant privileges to the current data tables, no new views. This approach is for Row level security, we did not wanted that.

### Exercise 2.4 - Verify User Access (0.3 points)

**Score: 0.2 / 0.3** Poor presentation on that part, difficult to see, not professional.

### Exercise 2.5 - View for Derived/Composite Attribute (0.6 points)

**Score: 0.2 / 0.6**  Very poor presentation. Also, you mentioned row level security (RLS) but this is out of scope. If you want to add high number of code lines always add a sepparate file with the corresponding file type or extension. This part is an overkill of what I demanded, probably LLM generated.

**Section 2 subtotal: 0.9 / 2.0**

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

**Score: 0.2 / 0.3** The query is fixed because it works, but if you specify a NATURAL JOIN, the rest of the JOINs should specify also the type (LEFT JOIN, INNER JOIN...) 

### Exercise 4.4 - Execution Cost Calculation (1 point)

**Score: 1.0 / 1.0** 

### Exercise 4.5 - Optimization Plan (1.5 points)

**Score: 1.5 / 1.5** .

### Exercise 4.6 - Query Demonstrating Optimization Benefit (0.5 points)

**Score: 0 / 0.5** NO EXPLANATION AT ALL on the execution plan. Also, if you do not show execution plan before an after, there is no comparison to be made.

**Section 4 subtotal: 3.4 / 4.0**
