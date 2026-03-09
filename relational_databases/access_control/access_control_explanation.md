# Access Control in Databases - Complete Guide

## What is Database Access Control?

**Access control** is the security mechanism that determines who can access what data in a database and what operations they can perform. It's a critical aspect of database security that protects sensitive information and prevents unauthorized modifications.

### Why Access Control Matters

- **Data Security**: Protect sensitive information from unauthorized access
- **Data Integrity**: Prevent accidental or malicious data corruption
- **Compliance**: Meet legal and regulatory requirements (GDPR, HIPAA, SOX)
- **Audit Trail**: Track who accessed or modified data
- **Principle of Least Privilege**: Give users only the permissions they need

---

## Core Concepts

### 1. Users and Roles

**User**: An individual database account that can log in and execute commands.

**Role**: A named collection of privileges that can be assigned to users. Roles simplify permission management.

Think of roles like job titles in a company:
- A "Manager" role has certain permissions
- Multiple employees can be assigned the "Manager" role
- If you need to change manager permissions, you change the role once, not each person

### 2. Privileges (Permissions)

Privileges are specific actions that users can perform:

**Object Privileges** (on tables, views, etc.):
- `SELECT`: Read data
- `INSERT`: Add new data
- `UPDATE`: Modify existing data
- `DELETE`: Remove data
- `TRUNCATE`: Remove all data quickly
- `REFERENCES`: Create foreign keys
- `TRIGGER`: Create triggers

**Schema Privileges**:
- `USAGE`: Access objects in schema
- `CREATE`: Create new objects

**Database Privileges**:
- `CONNECT`: Connect to database
- `CREATE`: Create schemas
- `TEMPORARY`: Create temporary tables

**Administrative Privileges**:
- `CREATEDB`: Create databases
- `CREATEROLE`: Create roles
- `SUPERUSER`: All privileges (dangerous!)

### 3. Permission Hierarchy

```
Database
  └── Schemas
      └── Tables/Views/Functions
          └── Columns
```

To access a table, a user typically needs:
1. Permission to connect to the database
2. Usage permission on the schema
3. Specific privilege on the table (SELECT, INSERT, etc.)

---

## Creating Users and Roles

### Creating a User (Role with Login)

```sql
-- Basic user
CREATE USER username WITH PASSWORD 'securepassword123';

-- User with expiration
CREATE USER temp_user WITH PASSWORD 'temp123' VALID UNTIL '2025-12-31';

-- Read-only user
CREATE USER readonly_user WITH PASSWORD 'pass123' IN ROLE read_only_group;
```

### Creating a Role (No Login)

```sql
-- Create a role for grouping permissions
CREATE ROLE analysts;

-- Create role that can create databases
CREATE ROLE db_manager CREATEDB;

-- Create role that inherits from another role
CREATE ROLE senior_analyst INHERIT;
```

### Role Attributes

```sql
CREATE ROLE username WITH
    LOGIN                     -- Can log in
    PASSWORD 'password'       -- Password for authentication
    SUPERUSER                 -- Has all privileges (use carefully!)
    CREATEDB                  -- Can create databases
    CREATEROLE                -- Can create other roles
    REPLICATION               -- Can initiate streaming replication
    CONNECTION LIMIT 5        -- Max concurrent connections
    VALID UNTIL '2025-12-31'  -- Account expiration
    IN ROLE role1, role2;     -- Member of these roles
```

### Viewing Users and Roles

```sql
-- List all roles
SELECT rolname, rolsuper, rolcreatedb, rolcanlogin 
FROM pg_roles 
ORDER BY rolname;

-- List roles with their members
SELECT 
    r.rolname AS role_name,
    ARRAY_AGG(m.rolname) AS members
FROM pg_roles r
LEFT JOIN pg_auth_members am ON r.oid = am.roleid
LEFT JOIN pg_roles m ON am.member = m.oid
GROUP BY r.rolname
ORDER BY r.rolname;

-- Quick view of users (roles that can login)
\du
```

---

## Granting Privileges

### Database-Level Privileges

```sql
-- Allow connection to database
GRANT CONNECT ON DATABASE mydb TO username;

-- Allow creating schemas
GRANT CREATE ON DATABASE mydb TO username;

-- Allow temporary tables
GRANT TEMPORARY ON DATABASE mydb TO username;

-- Grant all database privileges
GRANT ALL PRIVILEGES ON DATABASE mydb TO username;
```

### Schema-Level Privileges

```sql
-- Allow using objects in schema
GRANT USAGE ON SCHEMA public TO username;

-- Allow creating objects in schema
GRANT CREATE ON SCHEMA public TO username;

-- Grant all schema privileges
GRANT ALL ON SCHEMA public TO username;
```

### Table-Level Privileges

```sql
-- Grant SELECT (read)
GRANT SELECT ON TABLE employees TO username;

-- Grant INSERT (create)
GRANT INSERT ON TABLE employees TO username;

-- Grant UPDATE (modify)
GRANT UPDATE ON TABLE employees TO username;

-- Grant DELETE (remove)
GRANT DELETE ON TABLE employees TO username;

-- Grant multiple privileges
GRANT SELECT, INSERT, UPDATE ON TABLE employees TO username;

-- Grant  all privileges on table
GRANT ALL PRIVILEGES ON TABLE employees TO username;

-- Grant on multiple tables
GRANT SELECT ON TABLE employees, departments, projects TO username;

-- Grant on all tables in schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;

-- Grant on future tables (auto-assign to new tables)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO username;
```

### Column-Level Privileges

Grant access to specific columns only:

```sql
-- Grant SELECT on specific columns
GRANT SELECT (employee_id, first_name, last_name, department) 
ON TABLE employees 
TO hr_staff;

-- Grant UPDATE on specific columns
GRANT UPDATE (salary, job_title) 
ON TABLE employees 
TO hr_manager;
```

### Special Permissions

```sql
-- Grant permission to grant same privilege to others
GRANT SELECT ON TABLE employees TO manager WITH GRANT OPTION;

-- Grant execute on function
GRANT EXECUTE ON FUNCTION calculate_salary(INT) TO payroll_user;

-- Grant usage on sequence
GRANT USAGE ON SEQUENCE employees_id_seq TO app_user;
```

---

## Revoking Privileges

### Basic REVOKE

```sql
-- Revoke SELECT permission
REVOKE SELECT ON TABLE employees FROM username;

-- Revoke multiple privileges
REVOKE INSERT, UPDATE, DELETE ON TABLE employees FROM username;

-- Revoke all privileges
REVOKE ALL PRIVILEGES ON TABLE employees FROM username;

-- Revoke from all tables in schema
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM username;
```

### CASCADE vs RESTRICT

```sql
-- RESTRICT: Fail if others depend on this privilege
REVOKE SELECT ON TABLE employees FROM manager RESTRICT;

-- CASCADE: Also revoke from users who got privilege from this user
REVOKE SELECT ON TABLE employees FROM manager CASCADE;
```

---

## Role Membership

### Assign Users to Roles

```sql
-- Grant role to user
GRANT analysts TO alice;

-- Grant role to multiple users
GRANT analysts TO alice, bob, charlie;

-- Grant with admin option (can grant role to others)
GRANT analysts TO alice WITH ADMIN OPTION;

-- Revoke role from user
REVOKE analysts FROM bob;
```

### Role Inheritance

```sql
-- Create hierarchy
CREATE ROLE employees;
CREATE ROLE managers INHERIT;
CREATE ROLE executives INHERIT;

-- Build hierarchy
GRANT employees TO managers;
GRANT managers TO executives;

-- Now executives inherit privileges from managers and employees
```

---

## Common Access Control Patterns

### Pattern 1: Read-Only Role

```sql
-- Create role
CREATE ROLE readonly;

-- Grant minimal permissions
GRANT CONNECT ON DATABASE mydb TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT ON TABLES TO readonly;

-- Assign to users
GRANT readonly TO user1, user2;
```

### Pattern 2: Application User

```sql
-- Create role for application
CREATE ROLE app_user;

-- Grant necessary permissions
GRANT CONNECT ON DATABASE mydb TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Apply to future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE ON SEQUENCES TO app_user;

-- Create actual user
CREATE USER myapp WITH PASSWORD 'securepass' IN ROLE app_user;
```

### Pattern 3: Department-Based Access

```sql
-- Create department roles
CREATE ROLE hr_department;
CREATE ROLE finance_department;
CREATE ROLE it_department;

-- Grant HR access to employee data
GRANT SELECT, INSERT, UPDATE ON employees TO hr_department;
GRANT SELECT ON departments TO hr_department;

-- Grant Finance access to financial data
GRANT SELECT, INSERT, UPDATE ON salaries, expenses TO finance_department;

-- Grant IT full access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO it_department;

-- Assign users to departments
CREATE USER alice_hr WITH PASSWORD 'pass123' IN ROLE hr_department;
CREATE USER bob_finance WITH PASSWORD 'pass456' IN ROLE finance_department;
```

### Pattern 4: Separation of Duties

```sql
-- Create specialized roles
CREATE ROLE data_entry;        -- Can only insert
CREATE ROLE data_modifier;     -- Can update
CREATE ROLE data_viewer;       -- Can only read
CREATE ROLE data_approver;     -- Can read and flag records

-- Grant minimal permissions
GRANT INSERT ON orders TO data_entry;
GRANT SELECT, UPDATE ON orders TO data_modifier;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO data_viewer;
GRANT SELECT, UPDATE (status, approved_by) ON orders TO data_approver;
```

---

## Row-Level Security (RLS)

Control access at the row level, not just table level.

### Enabling RLS

```sql
-- Enable row-level security on table
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Create policy: users can only see their own records
CREATE POLICY employee_isolation ON employees
    FOR SELECT
    USING (employee_id = current_user::INT);

-- Create policy: managers can see their team
CREATE POLICY manager_team ON employees
    FOR SELECT
    USING (manager_id = current_user::INT OR employee_id = current_user::INT);

-- Create policy for INSERT
CREATE POLICY employee_insert ON employees
    FOR INSERT
    WITH CHECK (employee_id = current_user::INT);

-- Create policy for UPDATE
CREATE POLICY employee_update ON employees
    FOR UPDATE
    USING (employee_id = current_user::INT)
    WITH CHECK (employee_id = current_user::INT);
```

### RLS Examples

```sql
-- Only show active employees to non-managers
CREATE POLICY active_only ON employees
    FOR SELECT
    USING (
        status = 'active' OR 
        current_user IN (SELECT username FROM managers)
    );

-- Restrict salary updates to HR
CREATE POLICY salary_update ON employees
    FOR UPDATE
    USING (current_user IN (SELECT username FROM hr_roles))
    WITH CHECK (current_user IN (SELECT username FROM hr_roles));

-- Multi-tenant application
CREATE POLICY tenant_isolation ON orders
    FOR ALL
    USING (tenant_id = current_setting('app.tenant_id')::INT);
```

---

## Views for Access Control

Views can hide sensitive data and simplify permissions.

### Creating Security Views

```sql
-- View without sensitive columns
CREATE VIEW employee_directory AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    department,
    job_title
FROM employees;
-- (excludes salary, ssn, date_of_birth, etc.)

-- Grant access to view instead of table
GRANT SELECT ON employee_directory TO all_staff;

-- View with row filtering
CREATE VIEW my_team AS
SELECT *
FROM employees
WHERE manager_id = current_user::INT;

GRANT SELECT ON my_team TO managers;

-- View with computed/masked data
CREATE VIEW employee_summary AS
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    department,
    CASE 
        WHEN salary < 50000 THEN 'Junior'
        WHEN salary < 100000 THEN 'Mid-Level'
        ELSE 'Senior'
    END AS level
FROM employees;
```

---

## Auditing and Monitoring

Track who accesses what data:

### Enable Logging

```sql
-- In postgresql.conf:
-- log_connections = on
-- log_disconnections = on
-- log_statement = 'mod'  -- Log INSERT, UPDATE, DELETE
-- log_duration = on

-- Or set at session level:
SET log_statement = 'all';
```

### Create Audit Triggers

```sql
-- Create audit log table
CREATE TABLE audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    username VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSON,
    new_data JSON
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, operation, username, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, row_to_json(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, operation, username, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, operation, username, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, row_to_json(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER employees_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

### Monitor Active Sessions

```sql
-- View active connections
SELECT 
    datname AS database,
    usename AS username,
    client_addr AS client_ip,
    state,
    query,
    query_start
FROM pg_stat_activity
WHERE state = 'active';

-- Kill a session
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE usename = 'suspicious_user';
```

---

## Best Practices

### 1. Principle of Least Privilege
```sql
-- BAD: Granting too much
GRANT ALL PRIVILEGES ON DATABASE mydb TO app_user;

-- GOOD: Grant only what's needed
GRANT CONNECT ON DATABASE mydb TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON specific_tables TO app_user;
```

### 2. Use Roles, Not Individual Users
```sql
-- BAD: Managing individual users
GRANT SELECT ON employees TO alice;
GRANT SELECT ON employees TO bob;
GRANT SELECT ON employees TO charlie;

-- GOOD: Use roles
CREATE ROLE hr_staff;
GRANT SELECT ON employees TO hr_staff;
GRANT hr_staff TO alice, bob, charlie;
```

### 3. Never Use SUPERUSER for Applications
```sql
-- BAD: Application with superuser
CREATE USER myapp WITH SUPERUSER PASSWORD 'pass';

-- GOOD: Application with minimal privileges
CREATE ROLE app_role;
GRANT CONNECT ON DATABASE mydb TO app_role;
GRANT necessary_privileges TO app_role;
CREATE USER myapp WITH PASSWORD 'pass' IN ROLE app_role;
```

### 4. Regularly Audit Permissions
```sql
-- Check table permissions
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'public'
ORDER BY grantee, table_name;

-- Check role memberships
SELECT 
    r.rolname AS role,
    m.rolname AS member
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.roleid
JOIN pg_roles m ON am.member = m.oid
ORDER BY r.rolname;
```

### 5. Use Schemas for Isolation
```sql
-- Create separate schemas
CREATE SCHEMA hr_data;
CREATE SCHEMA finance_data;
CREATE SCHEMA public_data;

-- Grant schema-specific access
GRANT USAGE ON SCHEMA hr_data TO hr_role;
GRANT USAGE ON SCHEMA finance_data TO finance_role;
GRANT USAGE ON SCHEMA public_data TO PUBLIC;
```

### 6. Implement Connection Limits
```sql
-- Limit connections per user
CREATE ROLE limited_user CONNECTION LIMIT 5;

-- Limit connections per database
ALTER DATABASE mydb CONNECTION LIMIT 100;
```

### 7. Use SSL/TLS for Connections
```sql
-- Require SSL for user
ALTER USER sensitive_user WITH PASSWORD 'pass' 
    CONNECTION LIMIT 1 
    VALID UNTIL '2025-12-31';

-- In pg_hba.conf:
-- hostssl  all  all  0.0.0.0/0  md5
```

---

## Common Scenarios

### Scenario 1: Onboarding New Employee

```sql
-- 1. Create user account
CREATE USER john_doe WITH PASSWORD 'temppass123' 
    CONNECTION LIMIT 3 
    VALID UNTIL '2025-03-01';

-- 2. Assign to appropriate role
GRANT employee_role TO john_doe;

-- 3. Grant access to necessary databases
GRANT CONNECT ON DATABASE company_db TO john_doe;

-- 4. Force password change on first login (application level)
-- 5. Add to audit log
INSERT INTO access_log (username, action, timestamp)
VALUES ('john_doe', 'Account Created', CURRENT_TIMESTAMP);
```

### Scenario 2: Employee Leaves Company

```sql
-- 1. Revoke all privileges
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM john_doe;
REVOKE ALL PRIVILEGES ON DATABASE company_db FROM john_doe;

-- 2. Remove from all roles
REVOKE employee_role FROM john_doe;

-- 3. Disable account
ALTER USER john_doe WITH NOLOGIN;

-- 4. Or delete account (after audit)
DROP USER john_doe;

-- 5. Log the action
INSERT INTO access_log (username, action, timestamp)
VALUES ('john_doe', 'Account Disabled', CURRENT_TIMESTAMP);
```

### Scenario 3: Temporary Contractor Access

```sql
-- Create temporary user
CREATE USER contractor_temp WITH PASSWORD 'temp123'
    CONNECTION LIMIT 2
    VALID UNTIL '2025-03-31';  -- Auto-expires

-- Grant minimal read-only access
GRANT readonly_role TO contractor_temp;

-- Restrict to specific tables
GRANT SELECT ON project_data, meeting_notes TO contractor_temp;
```

---

## Summary

Access control is essential for:
- **Security**: Protect sensitive data
- **Compliance**: Meet regulatory requirements
- **Integrity**: Prevent unauthorized changes
- **Auditing**: Track data access and modifications

Key principles:
- Grant minimum necessary privileges
- Use roles for permission management
- Implement row-level security where needed
- Use views to hide sensitive data
- Audit and monitor access regularly
- Review and revoke unnecessary permissions

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026
