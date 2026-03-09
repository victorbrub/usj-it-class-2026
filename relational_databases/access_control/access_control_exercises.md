# Access Control - Practice Exercises

## Instructions

Complete the following exercises to practice database access control and security. You'll create users, roles, grant privileges, and implement various security patterns.

**Time Allocation**: 120-150 minutes  
**Difficulty**: Beginner to Advanced  
**Prerequisites**: SQL basics, understanding of database tables

---

## Part 1: User and Role Creation

### Exercise 1: Create Basic Users

Create the following users with appropriate passwords:

1. `alice` - Password: 'alice2026'
2. `bob` - Password: 'bob2026'
3. `charlie` - Password: 'charlie2026'
4. `admin_user` - Password: 'admin2026' with CREATEDB privilege

**Deliverable**: CREATE USER statements for all four users

---

### Exercise 2: Create Department Roles

Create roles for different departments in a company:

1. `hr_department` - Human Resources
2. `finance_department` - Finance
3. `it_department` - Information Technology
4. `sales_department` - Sales and Marketing

**Note**: These should be roles (not users), meaning they cannot login directly.

**Deliverable**: CREATE ROLE statements

---

### Exercise 3: View Users and Roles

Write queries to:

1. List all roles in the database
2. Show only roles that can login (users)
3. Display roles with CREATEDB privilege
4. Show role names and their attributes (can login, can create DB, etc.)

**Deliverable**: 4 SELECT queries showing different role information

---

## Part 2: Database Setup

For the following exercises, create a simple company database with these tables:

### Exercise 4: Create Sample Database

```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT CURRENT_DATE,
    ssn CHAR(11)  -- Sensitive data
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INTEGER,
    budget DECIMAL(12,2)
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES departments(department_id),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2)
);

CREATE TABLE timesheets (
    timesheet_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked DECIMAL(5,2),
    work_date DATE,
    description TEXT
);
```

Insert sample data (at least 5 employees, 3 departments, 3 projects).

**Deliverable**: Complete database setup with sample data

---

## Part 3: Basic Permissions

### Exercise 5: Grant Database Access

Grant the following permissions:

1. Allow `alice`, `bob`, and `charlie` to connect to your database
2. Grant them usage on the `public` schema
3. Verify they have connection rights

**Deliverable**: GRANT statements

---

### Exercise 6: Read-Only Access

Set up read-only access for `bob`:

1. Grant SELECT on `employees` table
2. Grant SELECT on `departments` table  
3. Verify bob cannot INSERT, UPDATE, or DELETE

**Test**: Try to run INSERT as bob - it should fail

**Deliverable**: GRANT statements and test results

---

### Exercise 7: Department-Specific Access

Configure access based on departments:

1. Grant `hr_department` role SELECT on all tables
2. Grant `hr_department` role INSERT, UPDATE on `employees` table
3. Grant `hr_department` role UPDATE only on salary and department columns of employees
4. Assign `alice` to the `hr_department` role

**Deliverable**: GRANT statements and role assignment

---

## Part 4: Advanced Permissions

### Exercise 8: Finance Department Permissions

Set up appropriate permissions for finance:

1. Grant `finance_department` SELECT on all tables
2. Grant `finance_department` INSERT, UPDATE on `departments` (budget management)
3. Grant `finance_department` SELECT on salary column only (not full employee record)
4. Assign `charlie` to `finance_department` role

**Hint**: Use column-level permissions for salary access

**Deliverable**: Complete permission setup for finance

---

### Exercise 9: Grant with Grant Option

1. Grant `alice` SELECT on `employees` WITH GRANT OPTION
2. Have `alice` grant SELECT on `employees` to `bob`
3. Verify that bob now has SELECT permission
4. Revoke the permission from `alice` with CASCADE
5. Verify that bob's permission was also revoked

**Deliverable**: Sequence of GRANT/REVOKE commands with explanations

---

### Exercise 10: Default Privileges

Set up default privileges so new tables automatically have correct permissions:

1. Configure default privileges so `hr_department` automatically gets SELECT on new tables
2. Configure default privileges so `finance_department` gets SELECT on new tables
3. Create a new table to test
4. Verify the roles have access without explicit GRANT

**Deliverable**: ALTER DEFAULT PRIVILEGES statements and verification

---

## Part 5: Views for Security

### Exercise 11: Create Security Views

Create views that hide sensitive information:

1. **Employee Directory**: Show employee_id, first_name, last_name, email, department (exclude salary, ssn)
2. **Department Summary**: Show department_name, employee count, average salary range (not exact salaries)
3. **Project Overview**: Show project_name, department_name, date range (exclude budget)

Grant appropriate roles SELECT on these views instead of base tables.

**Deliverable**: CREATE VIEW statements and GRANT permissions

---

### Exercise 12: Dynamic Views

Create a view that shows different data based on who is querying:

1. Create a view `my_team` that shows:
   - For managers: All employees in their department
   - For regular employees: Only their own record
2. Use `current_user` in the view definition

**Hint**: You'll need to join with a managers table or use a specific logic to determine department.

**Deliverable**: CREATE VIEW statement with conditional logic

---

## Part 6: Row-Level Security

### Exercise 13: Enable Row-Level Security

Enable RLS on the employees table:

1. Enable row-level security on `employees`
2. Create a policy so users can only see their own row (where username matches)
3. Create a policy allowing HR department to see all rows
4. Test with different users

**Deliverable**: RLS policies and test results

---

### Exercise 14: Department-Based RLS

Implement row-level security based on departments:

1. Add a policy so employees only see records from their department
2. Add a policy allowing managers to see all departments
3. Test the policies with different users

**Deliverable**: RLS policies for department isolation

---

### Exercise 15: RLS for Multi-tenant Application

Simulate a multi-tenant application where each company should only see their data:

1. Add a `company_id` column to relevant tables
2. Enable RLS on tables
3. Create policies using session variables: `current_setting('app.company_id')`
4. Test by setting the session variable and querying

**Deliverable**: Complete multi-tenant RLS implementation

---

## Part 7: Role Hierarchies

### Exercise 16: Create Role Hierarchy

Build a hierarchy of roles:

1. Create `employee_base` role with basic read permissions
2. Create `team_lead` role that inherits from `employee_base` plus UPDATE on timesheets
3. Create `manager` role that inherits from `team_lead` plus UPDATE on employees
4. Create `director` role that inherits from `manager` plus budget management

**Deliverable**: Role creation with inheritance structure

---

### Exercise 17: Assign Users to Hierarchy

1. Assign `bob` to `employee_base`
2. Assign `alice` to `manager`
3. Assign `charlie` to `director`
4. Verify that `alice` has all permissions from `employee_base` and `team_lead`
5. Verify that `charlie` has all permissions from the entire hierarchy

**Deliverable**: Role assignments and permission verification

---

## Part 8: Auditing and Monitoring

### Exercise 18: Create Audit Log

Set up auditing for sensitive tables:

1. Create an `audit_log` table with columns:
   - audit_id (primary key)
   - table_name
   - operation (INSERT, UPDATE, DELETE)
   - record_id
   - username
   - timestamp
   - old_values (JSON)
   - new_values (JSON)

2. Create a trigger function that logs all changes to employees table
3. Create triggers for INSERT, UPDATE, and DELETE on employees
4. Test by making changes and viewing the audit log

**Deliverable**: Complete audit system with trigger functions

---

### Exercise 19: Monitor Active Sessions

Write queries to monitor database activity:

1. Show all active database connections
2. Show what queries each user is currently running
3. Find long-running queries (over 5 minutes)
4. Show connection count per user
5. Identify idle connections

**Deliverable**: 5 monitoring queries

---

## Part 9: Security Scenarios

### Exercise 20: Contractor Access

A contractor needs temporary access for 30 days:

1. Create a user `contractor_john` with password that expires in 30 days
2. Grant read-only access to `projects` and `timesheets` tables only
3. Limit the contractor to 2 concurrent connections
4. Write the command to disable access after project completion
5. Write the command to completely remove the user

**Deliverable**: Complete contractor access setup and removal plan

---

### Exercise 21: Employee Promotion

An employee is promoted from team member to manager:

1. Create initial user with employee-level access
2. Show the commands to promote them (grant manager role)
3. Verify they have new permissions
4. Show the commands to demote them back if needed

**Deliverable**: Promotion and demotion procedures

---

### Exercise 22: Data Breach Response

Someone reports unauthorized access to salary data:

1. Write query to find who has access to the salary column
2. Write query to check recent SELECTs on employees table (from logs)
3. Revoke all salary access except for finance department
4. Create a view that masks salary data (shows ranges instead of exact values)
5. Grant access to the masked view instead

**Deliverable**: Incident response SQL commands

---

## Part 10: Best Practices Implementation

### Exercise 23: Implement Least Privilege

Review and fix this overly-permissive setup:

```sql
-- Current (insecure) setup:
CREATE USER app_user WITH PASSWORD 'pass' SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE company_db TO app_user;
```

Rewrite it following least privilege principle:
1. Remove SUPERUSER
2. Grant only CONNECT on database
3. Grant only necessary table operations
4. Use roles instead of direct grants

**Deliverable**: Corrected permission setup with explanation

---

### Exercise 24: Regular Permission Audit

Create a comprehensive permission audit report:

1. List all users and their roles
2. Show all table privileges per user/role
3. List users with dangerous privileges (SUPERUSER, CREATEDB, CREATEROLE)
4. Find tables with PUBLIC access
5. Identify users who haven't connected in 90+ days

**Deliverable**: Complete audit report with 5 queries

---

### Exercise 25: Secure Application Access

Design secure access for a web application:

1. Create a dedicated application role with minimal privileges
2. Grant only needed operations (SELECT, INSERT, UPDATE on specific tables)
3. Use connection pooling (document the approach)
4. Implement connection limit
5. Create a separate role for batch processes
6. Create a separate role for reporting (read-only)

**Deliverable**: Complete multi-role application security design

---

## Part 11: Advanced Scenarios

### Exercise 26: Schema-Based Isolation

Implement multi-schema security:

1. Create schemas: `hr_schema`, `finance_schema`, `public_schema`
2. Move appropriate tables to each schema
3. Grant schema-specific access to roles
4. Configure default privileges per schema
5. Test cross-schema access restrictions

**Deliverable**: Multi-schema security implementation

---

### Exercise 27: Column-Level Encryption

Implement additional security for sensitive data:

1. Add a `ssn_encrypted` column to employees
2. Create a function to encrypt SSN using `pgcrypto`
3. Create a view that decrypts for authorized users only
4. Grant access to the view, not the raw table
5. Test with different users

**Deliverable**: Encryption setup with access control

---

### Exercise 28: Compliance Report

Generate a report for security compliance:

1. All users with access to PII (Personal Identifiable Information)
2. All modifications to sensitive tables in the last 30 days
3. List of users without password expiration
4. Tables with no RLS enabled
5. Roles with excessive privileges

**Deliverable**: 5-query compliance report

---

## Bonus Challenges

### Challenge 1: Dynamic Permission Management

Create a stored procedure that:
1. Takes username and role as parameters
2. Assigns appropriate permissions based on role
3. Logs the change to an audit table
4. Sends email notification (simulate with INSERT to notifications table)

**Deliverable**: Complete procedure with error handling

---

### Challenge 2: Automated Access Review

Create a system that automatically:
1. Identifies unused permissions (not exercised in 90 days)
2. Flags users with excessive privileges
3. Suggests permissions to revoke
4. Generates a report for security team

**Deliverable**: Automated review script

---

### Challenge 3: Break and Fix

You're given this deliberately insecure setup:

```sql
CREATE USER app WITH PASSWORD 'password123' SUPERUSER;
GRANT ALL ON DATABASE company TO PUBLIC;
ALTER TABLE employees DISABLE ROW LEVEL SECURITY;
```

Identify all security issues and provide fixes.

**Deliverable**: List of vulnerabilities and corrected setup

---

## Submission Checklist

Your completed exercise submission should include:

- [ ] All user and role creation statements (Exercises 1-3)
- [ ] Sample database with data (Exercise 4)
- [ ] Basic permission grants (Exercises 5-7)
- [ ] Advanced permissions (Exercises 8-10)
- [ ] Security views (Exercises 11-12)
- [ ] Row-level security policies (Exercises 13-15)
- [ ] Role hierarchies (Exercises 16-17)
- [ ] Audit system (Exercises 18-19)
- [ ] Security scenarios (Exercises 20-22)
- [ ] Best practices implementation (Exercises 23-25)
- [ ] Advanced scenarios (Exercises 26-28)
- [ ] Bonus challenges (optional)

---

## Testing Your Work

For each exercise:

1. **Test Access**: Try operations as different users
2. **Test Denial**: Verify unauthorized operations fail
3. **Check Audit Logs**: Ensure changes are logged
4. **Review Permissions**: Use information_schema queries
5. **Document Assumptions**: Note any decisions you made

---

## Common Mistakes to Avoid

1. **Granting PUBLIC access** - Public means everyone, including future users
2. **Using SUPERUSER for applications** - Way too dangerous
3. **Forgetting CASCADE on REVOKE** - Derived permissions remain
4. **Not testing with actual users** - Log in as the user to verify
5. **Overlooking schema permissions** - Need USAGE on schema
6. **Ignoring connection permits** - Need CONNECT on database
7. **Not documenting changes** - Always document permission changes

---

## Expected Learning Outcomes

After completing these exercises, you should be able to:

- Create users and roles with appropriate attributes
- Grant and revoke privileges at multiple levels (database, schema, table, column)
- Implement role hierarchies and inheritance
- Use views for security
- Implement row-level security policies
- Create audit trails for sensitive operations
- Monitor database access and activity
- Design secure multi-user database systems
- Respond to security incidents
- Implement compliance requirements
- Follow security best practices

---

## Additional Resources

- PostgreSQL Security Documentation
- OWASP Database Security Cheat Sheet
- CIS PostgreSQL Benchmarks
- Your organization's security policies

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Access Control
