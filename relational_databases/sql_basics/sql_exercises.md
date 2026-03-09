# SQL Basics - Practice Exercises

## Instructions

Complete the following exercises to practice SQL fundamentals. Start with a simple database schema and progressively work through more complex queries and operations.

**Time Allocation**: 120-180 minutes  
**Difficulty**: Beginner to Intermediate

---

## Part 1: Database Setup (DDL)

### Exercise 1: Create the Database Schema

Create a university database with the following tables:

**Students Table**:
- student_id (primary key, auto-increment)
- first_name (required, max 50 characters)
- last_name (required, max 50 characters)
- email (required, unique, max 100 characters)
- date_of_birth (date)
- major (max 50 characters)
- gpa (decimal, between 0.0 and 4.0)
- enrollment_date (date, defaults to current date)
- is_active (boolean, defaults to true)

**Courses Table**:
- course_id (primary key, auto-increment)
- course_code (required, unique, max 10 characters, e.g., 'CS101')
- course_name (required, max 100 characters)
- credits (integer, between 1 and 6)
- department (max 50 characters)
- instructor_name (max 100 characters)

**Enrollments Table**:
- enrollment_id (primary key, auto-increment)
- student_id (foreign key to students)
- course_id (foreign key to courses)
- enrollment_date (date, defaults to current date)
- grade (max 2 characters, e.g., 'A', 'B+', 'C-')
- semester (max 20 characters, e.g., 'Fall 2024')

Write the CREATE TABLE statements with all appropriate constraints.

**Deliverable**: SQL script with all three CREATE TABLE statements

---

### Exercise 2: Modify Table Structures

After creating the tables, make the following modifications:

1. Add a `phone` column to the students table (VARCHAR(20))
2. Add a `description` column to the courses table (TEXT)
3. Add a CHECK constraint to enrollments ensuring grade is one of ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F', 'W')
4. Rename the `instructor_name` column in courses to `instructor`

**Deliverable**: SQL ALTER TABLE statements

---

## Part 2: Data Insertion (DML)

### Exercise 3: Insert Sample Data

Insert the following data into your database:

**Students** (at least 8 students):
- Alice Johnson, Computer Science, GPA 3.8
- Bob Smith, Mathematics, GPA 3.5
- Carol White, Computer Science, GPA 3.9
- David Brown, Engineering, GPA 3.2
- Emma Davis, Mathematics, GPA 3.6
- Frank Wilson, Computer Science, GPA 2.9
- Grace Lee, Engineering, GPA 3.7
- Henry Martinez, Physics, GPA 3.4

**Courses** (at least 6 courses):
- CS101: Introduction to Programming, 3 credits, Computer Science dept
- CS201: Data Structures, 4 credits, Computer Science dept
- MATH101: Calculus I, 4 credits, Mathematics dept
- MATH201: Linear Algebra, 3 credits, Mathematics dept
- ENG101: Engineering Principles, 3 credits, Engineering dept
- PHYS101: Physics I, 4 credits, Physics dept

**Enrollments**:
- Enroll each student in 2-3 courses with appropriate grades
- Use different semesters (Fall 2024, Spring 2025)

**Deliverable**: INSERT statements for all data

---

## Part 3: Basic Queries

### Exercise 4: Simple SELECT Queries

Write queries to:

1. Retrieve all students with GPA greater than 3.5
2. Find all Computer Science majors
3. List all courses with 4 credits
4. Show students whose last name starts with 'W'
5. Display students who enrolled before 2025
6. Find students with no phone number (NULL)
7. List all unique majors in the database
8. Show the top 3 students by GPA

**Deliverable**: 8 SELECT queries with results

---

### Exercise 5: Aggregate Functions

Write queries to calculate:

1. Total number of students in the database
2. Average GPA of all students
3. Highest and lowest GPA
4. Number of students per major
5. Average GPA by major (sorted highest to lowest)
6. Count of courses in each department
7. Total credits offered by each department
8. Number of students with GPA above 3.5 vs below 3.5

**Deliverable**: 8 aggregate queries with results

---

### Exercise 6: Filtering and Complex Conditions

Write queries to find:

1. Computer Science students with GPA above 3.5
2. Students who enrolled between January 1, 2024 and December 31, 2024
3. Courses with 3 or 4 credits in the Computer Science department
4. Students whose email contains 'gmail'
5. Students whose major is Computer Science, Mathematics, or Engineering
6. Students with NULL phone OR inactive status
7. Courses taught by instructors whose name contains 'Smith' OR 'Johnson'
8. Students with GPA between 3.0 and 3.5 (inclusive)

**Deliverable**: 8 filtered SELECT queries

---

## Part 4: JOINs

### Exercise 7: INNER JOIN Queries

Write queries to:

1. List all students with their enrolled courses (student name + course name)
2. Show students enrolled in 'Data Structures' course
3. Display all enrollments with student name, course name, and grade
4. Find Computer Science students and the courses they're taking
5. List courses with student count for each course
6. Show students taking courses in the Computer Science department

**Deliverable**: 6 INNER JOIN queries

---

### Exercise 8: LEFT JOIN Queries

Write queries to:

1. List all students and their enrollments (include students with no enrollments)
2. Find students who are NOT enrolled in any courses
3. Show all courses and enrollment counts (include courses with no students)
4. Display students with their course count (including students with 0 courses)

**Deliverable**: 4 LEFT JOIN queries

---

### Exercise 9: Multiple JOINs

Write a comprehensive query that:

1. Shows student name, major, course name, department, and grade
2. Filters for only Computer Science majors
3. Orders by student last name, then course code
4. Includes only courses from Fall 2024 semester

**Deliverable**: 1 complex multi-JOIN query

---

## Part 5: Subqueries

### Exercise 10: Subquery Practice

Write queries using subqueries to:

1. Find students with GPA higher than the average GPA
2. List courses that have more enrolled students than average
3. Show students enrolled in the course with the most credits
4. Find students who are in the same major as 'Alice Johnson'
5. Display students NOT enrolled in 'Introduction to Programming'
6. List the top 3 majors by average GPA

**Deliverable**: 6 queries using subqueries

---

## Part 6: Data Modification

### Exercise 11: UPDATE Operations

Write UPDATE statements to:

1. Increase GPA by 0.1 for all Computer Science students
2. Change Frank Wilson's major to 'Information Systems'
3. Set all students with GPA below 3.0 to inactive status
4. Update Carol White's email to 'carol.white@university.edu'
5. Give all students enrolled in MATH201 a grade of 'B+' (if currently NULL)

**Deliverable**: 5 UPDATE statements

---

### Exercise 12: DELETE Operations

Write DELETE statements to:

1. Remove all enrollments with grade 'W' (withdrawn)
2. Delete students who are inactive AND have GPA below 2.5
3. Remove courses with zero enrollments

Note: Write these carefully and consider foreign key constraints!

**Deliverable**: 3 DELETE statements with explanations

---

## Part 7: Advanced Queries

### Exercise 13: GROUP BY and HAVING

Write queries to find:

1. Majors with more than 2 students
2. Courses with average grade better than 'B' (assume A=4.0, B=3.0, etc.)
3. Students who are enrolled in more than 2 courses
4. Departments offering more than 2 courses
5. Semesters with more than 5 total enrollments

**Deliverable**: 5 queries using GROUP BY and HAVING

---

### Exercise 14: Common Table Expressions (CTEs)

Rewrite the following using CTEs:

1. Find students with above-average GPA and show their enrollments
2. Calculate GPA by major, then show only majors with avg GPA > 3.5
3. Get top 3 students per major by GPA

**Deliverable**: 3 queries using CTEs

---

### Exercise 15: String and Date Functions

Write queries to:

1. Display student full names in format "LASTNAME, Firstname"
2. Extract domain from email addresses (part after @)
3. Calculate each student's age in years
4. Show enrollment date formatted as "Month DD, YYYY"
5. Find students who enrolled more than 1 year ago
6. Display first initial + last name (e.g., "A. Johnson")

**Deliverable**: 6 queries using string and date functions

---

## Part 8: Complex Scenarios

### Exercise 16: Academic Reports

Create the following reports:

**Report 1: Student Transcript**
For each student, show:
- Student name and major
- All courses taken with grades
- Number of courses completed
- Average grade (convert letter grades to numeric)

**Report 2: Course Roster**
For a specific course (you choose), show:
- Course details (code, name, credits, instructor)
- List of enrolled students
- Distribution of grades (how many A's, B's, etc.)

**Report 3: Department Summary**
For each department, show:
- Total courses offered
- Total credits available
- Number of students enrolled in department courses
- Average GPA of students in department courses

**Deliverable**: 3 comprehensive report queries

---

### Exercise 17: Data Integrity

Write queries to identify potential data problems:

1. Find students enrolled in courses but marked as inactive
2. Identify enrollments with grades but no enrollment date
3. Find duplicate email addresses
4. Check for students with invalid GPA (outside 0.0-4.0 range)
5. Find courses with no enrollments in the past year
6. Identify students without a major specified

**Deliverable**: 6 data validation queries

---

## Part 9: Real-World Application

### Exercise 18: University Dashboard

Design a set of queries for a university dashboard that shows:

1. **Key Metrics**:
   - Total students
   - Total active students
   - Total courses
   - Average GPA across university

2. **Top Performers**:
   - Top 10 students by GPA
   - Majors with highest average GPA

3. **Enrollment Analytics**:
   - Most popular courses (by enrollment)
   - Least popular courses
   - Enrollment trend by semester

4. **At-Risk Students**:
   - Students with GPA below 2.5
   - Students with no enrollments
   - Students with multiple failing grades

**Deliverable**: Organized set of dashboard queries with clear headings

---

## Bonus Challenge

### Exercise 19: Grade Management System

Create a complete grade update system:

1. Write a query to calculate semester GPA for each student
2. Update the main GPA field based on all course grades
3. Identify students on academic probation (GPA < 2.0)
4. Generate a dean's list (GPA >= 3.5)
5. Create a view that shows student standings (Excellent, Good, Satisfactory, Probation)

**Deliverable**: Complete SQL script with calculations and categorizations

---

### Exercise 20: Database Optimization

For your most complex queries from previous exercises:

1. Use EXPLAIN ANALYZE to check query performance
2. Identify which columns should have indexes
3. Create appropriate indexes
4. Re-run EXPLAIN ANALYZE and compare results

**Deliverable**: Before/after EXPLAIN results with index recommendations

---

## Submission Checklist

Your completed exercise submission should include:

- [ ] All CREATE TABLE statements (Exercise 1)
- [ ] All ALTER TABLE statements (Exercise 2)
- [ ] All INSERT statements with sample data (Exercise 3)
- [ ] Basic SELECT queries (Exercise 4)
- [ ] Aggregate queries (Exercise 5)
- [ ] Filtered queries (Exercise 6)
- [ ] JOIN queries (Exercises 7-9)
- [ ] Subquery examples (Exercise 10)
- [ ] UPDATE and DELETE statements (Exercises 11-12)
- [ ] GROUP BY/HAVING queries (Exercise 13)
- [ ] CTE examples (Exercise 14)
- [ ] String/Date function queries (Exercise 15)
- [ ] Complex reports (Exercise 16)
- [ ] Data validation queries (Exercise 17)
- [ ] Dashboard queries (Exercise 18)
- [ ] Bonus challenges (Exercises 19-20) - Optional

---

## Tips for Success

1. **Test incrementally**: Run each query as you write it
2. **Comment your SQL**: Add comments explaining complex queries
3. **Check your data**: Use SELECT to verify INSERT/UPDATE/DELETE operations
4. **Use transactions**: When testing destructive operations (UPDATE/DELETE), wrap in BEGIN/ROLLBACK
5. **Format your SQL**: Use proper indentation and line breaks for readability
6. **Verify constraints**: Ensure foreign key relationships are maintained
7. **Handle NULL values**: Consider NULL in your WHERE clauses
8. **Test edge cases**: What happens with empty results, NULL values, or duplicates?

---

## Expected Learning Outcomes

After completing these exercises, you should be able to:

- Create and modify database tables with appropriate constraints
- Insert, update, and delete data safely
- Write SELECT queries with filtering and sorting
- Use aggregate functions and GROUP BY effectively
- Join multiple tables to combine related data
- Write subqueries and CTEs for complex logic
- Use string and date functions for data manipulation
- Analyze and optimize query performance
- Design comprehensive database reports
- Validate and maintain data integrity

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026
**Module**: SQL Basics
