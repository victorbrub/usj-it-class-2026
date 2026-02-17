# Hands-On PostgreSQL Roles and Views Tutorial
## Creating Users, Roles, and Testing Access Control

This tutorial demonstrates how to create different user roles with different permissions and verify what each role can access.

---

## Scenario

We'll create:
1. **admin_role** - Can see all user data including sensitive information
2. **customer_support_role** - Can see user data but NOT sensitive financial information
3. Create views for each role
4. Test by impersonating each role

---

## Learning Objectives

By the end of this tutorial, you will be able to:

1. **Create** roles and users with appropriate permissions
2. **Design** views that filter sensitive data based on job roles
3. **Grant and revoke** permissions at different levels (database, schema, table, view)
4. **Impersonate** roles to test security configurations
5. **Explain** the principle of least privilege
6. **Understand** the difference between roles and users
7. **Create** secure functions for controlled data updates
8. **Compare** what different roles can and cannot access
9. **Apply** security best practices in real-world scenarios

---

## Prerequisites

- Basic SQL knowledge (SELECT, WHERE, JOIN)
- Access to a PostgreSQL database (version 12+)
- Superuser/admin access to create roles and grant permissions
- The GameVerse database should be set up with sample data

---

## Estimated Time

- **Tutorial completion:** 60-90 minutes
- **Questions and exercises:** 30-45 minutes
- **Challenge questions:** 60-90 minutes
- **Total:** 2.5 - 4 hours

---

## Assessment Criteria

Your understanding will be assessed on:

- **Understanding (30%)**: Ability to explain why each security measure is important
- **Implementation (40%)**: Correctly creating roles, views, and permissions
- **Testing (20%)**: Properly verifying access control through impersonation
- **Problem-Solving (10%)**: Completing challenge questions and handling edge cases

---

## Step 1: Create the Roles and Users

Connect to PostgreSQL as a superuser (postgres) and run:

```sql
-- Create two roles
CREATE ROLE admin_role LOGIN PASSWORD 'admin123';
CREATE ROLE customer_support_role LOGIN PASSWORD 'support123';

-- Create specific users and assign them to roles
CREATE USER alice WITH PASSWORD 'alice123' IN ROLE admin_role;
CREATE USER bob WITH PASSWORD 'bob123' IN ROLE customer_support_role;
```

**Verify roles were created:**
```sql
SELECT rolname, rolsuper, rolcanlogin 
FROM pg_roles 
WHERE rolname IN ('admin_role', 'customer_support_role', 'alice', 'bob');
```

Expected output:
```
         rolname          | rolsuper | rolcanlogin
--------------------------+----------+-------------
 admin_role               | f        | t
 customer_support_role    | f        | t
 alice                    | f        | t
 bob                      | f        | t
```

### Questions for Step 1:

1. **What's the difference between a ROLE and a USER in PostgreSQL?**
   <details>
   <summary>Hint</summary>
   Think about LOGIN capability
   </details>

2. **Write a query to check if 'alice' can login to the database.**
   <details>
   <summary>Hint</summary>
   Look at the rolcanlogin column in pg_roles
   </details>

3. **Create a third role called 'read_only_role' that can login with password 'readonly123'. Then verify it was created.**

4. **What does the 'IN ROLE' clause do when creating a user?**
   <details>
   <summary>Hint</summary>
   It assigns the user as a member of that role
   </details>

---

## Step 2: Grant Basic Permissions

```sql
-- Grant connection to database
GRANT CONNECT ON DATABASE gameverse TO admin_role, customer_support_role;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO admin_role, customer_support_role;

-- Grant SELECT on all tables to both roles (we'll restrict via views)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT SELECT ON users, games, reviews TO customer_support_role;
```

### Questions for Step 2:

1. **Why do we need to grant CONNECT permission before users can access the database?**

2. **Write the SQL to grant SELECT permission on the 'publishers' table to 'customer_support_role'.**

3. **What's the difference between granting SELECT on 'ALL TABLES' versus granting on specific tables?**
   <details>
   <summary>Hint</summary>
   Think about security and the principle of least privilege
   </details>

4. **Try granting UPDATE permission on the 'games' table to 'customer_support_role'. Then test if bob can update a game's price.**

5. **What does 'GRANT USAGE ON SCHEMA public' allow a role to do?**

---

## Step 3: Create Views for Each Role

### Admin View - Full Access
Admins can see everything including sensitive financial data:

```sql
-- Create admin view with ALL user data
CREATE VIEW admin_user_view AS
SELECT 
    user_id,
    username,
    email,
    registration_date,
    country,
    birth_date,
    role,
    account_status,
    is_premium,
    last_login,
    total_spent  -- SENSITIVE: Financial information
FROM users;

-- Grant access to admin_role
GRANT SELECT ON admin_user_view TO admin_role;
```

### Customer Support View - Limited Access
Customer support can see user info but NOT financial data:

```sql
-- Create customer support view WITHOUT sensitive data
CREATE VIEW support_user_view AS
SELECT 
    user_id,
    username,
    email,
    registration_date,
    country,
    role,
    account_status,
    is_premium,
    last_login
    -- NOTE: total_spent is EXCLUDED
    -- NOTE: birth_date is EXCLUDED (privacy)
FROM users;

-- Grant access to customer_support_role
GRANT SELECT ON support_user_view TO customer_support_role;
```

### Create a Detailed Activity View for Admins Only

```sql
-- Create a comprehensive view showing user activity
CREATE VIEW admin_user_activity AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.total_spent,
    COUNT(DISTINCT ul.game_id) AS games_owned,
    COUNT(DISTINCT r.review_id) AS reviews_written,
    COALESCE(SUM(ul.hours_played), 0) AS total_hours_played,
    COALESCE(SUM(ul.purchase_price), 0) AS actual_purchases_total
FROM users u
LEFT JOIN user_library ul ON u.user_id = ul.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
GROUP BY u.user_id, u.username, u.email, u.total_spent;

-- Only admins can see this
GRANT SELECT ON admin_user_activity TO admin_role;
```

**Verify views were created:**
```sql
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_name LIKE '%_view' OR table_name LIKE '%_activity'
ORDER BY table_name;
```

### Questions for Step 3:

1. **Why did we exclude 'total_spent' from the support_user_view?**
   <details>
   <summary>Hint</summary>
   Think about data sensitivity and job responsibilities
   </details>

2. **Create a new view called 'public_user_view' that shows only username, country, and is_premium (suitable for public display).**

3. **What columns does admin_user_activity include that aren't in the base users table?**
   <details>
   <summary>Hint</summary>
   Look at the aggregated columns from JOINs
   </details>

4. **Write a query to count how many columns are in admin_user_view versus support_user_view.**
   <details>
   <summary>Hint</summary>
   Use information_schema.columns
   </details>

5. **Modify the support_user_view to also exclude the 'email' column for additional privacy. What command would you use?**

6. **Why do we use LEFT JOIN instead of INNER JOIN in the admin_user_activity view?**

---

## Step 4: Test Access by Impersonating Users

### Method 1: Using SET ROLE (within same connection)

First, connect as a superuser or admin:

```sql
-- Check current user
SELECT current_user, session_user;

-- Impersonate admin role
SET ROLE admin_role;
SELECT current_user;  -- Should show: admin_role

-- Test what admin can see
SELECT * FROM admin_user_view LIMIT 5;
-- This works! Shows all columns including total_spent

SELECT * FROM admin_user_activity LIMIT 5;
-- This works! Shows detailed activity data

-- Try support view (should also work)
SELECT * FROM support_user_view LIMIT 5;
-- Works, but notice it has fewer columns

-- Reset back to original user
RESET ROLE;
```

Now test customer support role:

```sql
-- Impersonate customer support role
SET ROLE customer_support_role;
SELECT current_user;  -- Should show: customer_support_role

-- Test what support can see
SELECT * FROM support_user_view LIMIT 5;
-- This works! But notice: no total_spent, no birth_date

-- Try to access admin view
SELECT * FROM admin_user_view LIMIT 5;
-- ERROR: permission denied for view admin_user_view

-- Try to access admin activity view
SELECT * FROM admin_user_activity;
-- ERROR: permission denied for view admin_user_activity

-- Try to access raw users table
SELECT user_id, username, total_spent FROM users LIMIT 5;
-- This works because we granted SELECT on users table
-- But in production, you'd only grant access to views, not raw tables!

-- Reset back
RESET ROLE;
```

### Questions for Step 4:

1. **What command returns you to your original user after using SET ROLE?**
   <details>
   <summary>Hint</summary>
   RESET ROLE
   </details>

2. **While impersonating customer_support_role, try to SELECT from the 'developers' table. What happens and why?**

3. **Write a query to check what permissions 'admin_role' has on 'admin_user_view'.**
   <details>
   <summary>Hint</summary>
   Use has_table_privilege() function
   </details>

4. **Explain why admin_role can access support_user_view but customer_support_role cannot access admin_user_view.**

5. **As customer_support_role, try to INSERT a new row into the 'reviews' table. What happens?**

---

## Step 5: Better Approach - Revoke Direct Table Access

To properly secure the data, revoke direct table access and only allow view access:

```sql
-- As superuser, revoke direct table access
REVOKE SELECT ON users FROM customer_support_role;

-- Now grant only view access
GRANT SELECT ON support_user_view TO customer_support_role;

-- Test again
SET ROLE customer_support_role;

-- This now fails
SELECT * FROM users;
-- ERROR: permission denied for table users

-- But view access works
SELECT * FROM support_user_view LIMIT 5;
-- Success!

RESET ROLE;
```

### Questions for Step 5:

1. **Why is it more secure to grant access only to views rather than to the underlying tables?**
   <details>
   <summary>Hint</summary>
   Think about column-level security and data filtering
   </details>

2. **After revoking SELECT on 'users' from customer_support_role, can they still query support_user_view? Why?**

3. **Write the SQL to revoke SELECT permission on the 'games' table from 'customer_support_role'.**

4. **What's the difference between REVOKE and DROP?**

5. **If you wanted to create a view that shows only active users, how would you modify support_user_view?**

---

## Step 6: Practical Testing Session

Here's a complete test session you can run:

```sql
-- ============================================
-- TEST SESSION AS ADMIN
-- ============================================

-- Connect as admin
SET ROLE admin_role;

-- See who you are
SELECT current_user AS "I am", session_user AS "Originally connected as";

-- Query 1: View all users with financial data
SELECT username, email, total_spent, is_premium 
FROM admin_user_view 
ORDER BY total_spent DESC 
LIMIT 5;

-- Query 2: See detailed user activity
SELECT username, games_owned, reviews_written, total_hours_played, actual_purchases_total
FROM admin_user_activity
WHERE games_owned > 0
ORDER BY total_hours_played DESC
LIMIT 5;

-- Query 3: Admin can see who spent the most
SELECT username, total_spent, is_premium
FROM admin_user_view
WHERE total_spent > 0
ORDER BY total_spent DESC
LIMIT 10;

-- Return to original user
RESET ROLE;

-- ============================================
-- TEST SESSION AS CUSTOMER SUPPORT
-- ============================================

-- Connect as support
SET ROLE customer_support_role;

-- See who you are
SELECT current_user AS "I am", session_user AS "Originally connected as";

-- Query 1: View users (no financial data)
SELECT username, email, account_status, is_premium 
FROM support_user_view 
ORDER BY registration_date DESC 
LIMIT 5;

-- Query 2: Try to see financial data (FAILS)
SELECT username, total_spent FROM admin_user_view LIMIT 5;
-- ERROR: permission denied for view admin_user_view

-- Query 3: Support can help with account issues
SELECT user_id, username, email, account_status, role
FROM support_user_view
WHERE account_status != 'active';

-- Query 4: See premium members (but not how much they spent)
SELECT username, email, is_premium, registration_date
FROM support_user_view
WHERE is_premium = TRUE
ORDER BY registration_date DESC;

-- Return to original user
RESET ROLE;
```

### Questions for Step 6:

1. **Run the admin test session and note the top 3 users by total_spent. What are their usernames?**

2. **As customer_support_role, write a query to find all users with account_status = 'suspended'.**

3. **Why does the admin query about users who spent the most work, but a similar query would fail for customer_support_role?**

4. **Modify Query 1 in the admin session to also show the user's country. What would the query look like?**

5. **As customer_support_role, can you count how many premium users exist? Write the query and test it.**

6. **What would happen if you tried to run the admin queries while SET ROLE is set to customer_support_role?**

---

## Step 7: Testing with Actual User Connections

### Method 2: Connect as specific users (separate connections)

Open a new terminal and connect as Alice (admin):

```bash
psql -U alice -d gameverse -h localhost
# Password: alice123
```

In the psql session as Alice:

```sql
-- Check who you are
SELECT current_user;
-- Result: alice

-- Check your role membership
SELECT 
    r.rolname AS role_name
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON m.member = u.oid
WHERE u.rolname = current_user;
-- Result: admin_role

-- Alice can access admin views
SELECT * FROM admin_user_view LIMIT 3;
-- Works! Shows all columns including total_spent

SELECT * FROM admin_user_activity LIMIT 3;
-- Works! Shows detailed activity

-- Exit
\q
```

Open another terminal and connect as Bob (customer support):

```bash
psql -U bob -d gameverse -h localhost
# Password: bob123
```

In the psql session as Bob:

```sql
-- Check who you are
SELECT current_user;
-- Result: bob

-- Check your role membership
SELECT 
    r.rolname AS role_name
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON m.member = u.oid
WHERE u.rolname = current_user;
-- Result: customer_support_role

-- Bob can access support view
SELECT * FROM support_user_view LIMIT 3;
-- Works! But with limited columns

-- Bob CANNOT access admin views
SELECT * FROM admin_user_view LIMIT 3;
-- ERROR: permission denied for view admin_user_view

SELECT * FROM admin_user_activity LIMIT 3;
-- ERROR: permission denied for view admin_user_activity

-- Exit
\q
```

### Questions for Step 7:

1. **What's the difference between using SET ROLE and connecting as a different user with psql -U?**
   <details>
   <summary>Hint</summary>
   Think about session_user vs current_user
   </details>

2. **Connect as bob and try to query the 'platforms' table. What happens and why?**

3. **How would you check what roles alice belongs to while connected as alice?**

4. **If alice tries to DROP the support_user_view, what would happen?**

5. **Connect as bob and write a query to find users from 'USA'. Can you do this? Why or why not?**

---

## Step 8: Compare Results Side by Side

### What Admin Sees:

```sql
SET ROLE admin_role;

SELECT * FROM admin_user_view WHERE user_id = 1;
```

**Result (example):**
```
 user_id | username | email           | registration_date | country | birth_date | role | account_status | is_premium | last_login          | total_spent
---------+----------+-----------------+-------------------+---------+------------+------+----------------+------------+---------------------+-------------
       1 | player1  | p1@example.com  | 2024-01-15        | USA     | 1990-05-20 | user | active         | t          | 2026-02-15 10:30:00 |      450.75
```

### What Customer Support Sees:

```sql
SET ROLE customer_support_role;

SELECT * FROM support_user_view WHERE user_id = 1;
```

**Result (example):**
```
 user_id | username | email           | registration_date | country | role | account_status | is_premium | last_login
---------+----------+-----------------+-------------------+---------+------+----------------+------------+---------------------
       1 | player1  | p1@example.com  | 2024-01-15        | USA     | user | active         | t          | 2026-02-15 10:30:00
```

**Notice:**
- Customer support does NOT see `birth_date` (privacy)
- Customer support does NOT see `total_spent` (financial information)

### Questions for Step 8:

1. **List all the columns that admin can see but customer support cannot.**

2. **If a new column called 'payment_method' is added to the users table, which view(s) would need to be updated to include it?**

3. **Run both queries and compare the actual output. Pick one user and document what information is hidden from customer support.**

4. **Why might we want to hide birth_date from customer support, even though it's not financial data?**
   <details>
   <summary>Hint</summary>
   Think about privacy regulations like GDPR
   </details>

5. **Create a comparison table showing which roles can access which views.**

---

## Step 9: Create Update Permissions for Support Role

Customer support should be able to update account status:

```sql
-- As superuser, create a function that support can use
CREATE OR REPLACE FUNCTION update_user_status(
    p_user_id INT,
    p_new_status VARCHAR(20)
)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET account_status = p_new_status 
    WHERE user_id = p_user_id 
    AND p_new_status IN ('active', 'suspended', 'banned');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to customer support
GRANT EXECUTE ON FUNCTION update_user_status(INT, VARCHAR) TO customer_support_role;

-- Test as support
SET ROLE customer_support_role;

-- Support can suspend an account
SELECT update_user_status(1, 'suspended');
-- Success!

-- Verify
SELECT user_id, username, account_status FROM support_user_view WHERE user_id = 1;

-- But support cannot change financial data
UPDATE users SET total_spent = 1000 WHERE user_id = 1;
-- ERROR: permission denied (no direct UPDATE on users table)

RESET ROLE;
```

### Questions for Step 9:

1. **What does SECURITY DEFINER mean in the function definition?**
   <details>
   <summary>Hint</summary>
   The function executes with the permissions of the user who created it
   </details>

2. **Why do we validate that p_new_status is one of ('active', 'suspended', 'banned') in the function?**

3. **Create a similar function called 'update_user_email' that allows customer support to update a user's email address.**

4. **As customer_support_role, try calling update_user_status with an invalid status like 'deleted'. What happens?**

5. **Why is using a function better than granting UPDATE permission directly on the users table?**
   <details>
   <summary>Hint</summary>
   Think about controlled access and business logic enforcement
   </details>

6. **Write a function that allows customer support to add a note to a user's account (you'd need to create a user_notes table first).**

7. **Test the update_user_status function by suspending a user, then try to update their total_spent. Document what works and what fails.**

---

## Summary: Key Differences

| Feature | Admin Role | Customer Support Role |
|---------|------------|----------------------|
| **View Name** | `admin_user_view` | `support_user_view` |
| **See user email** | Yes | Yes |
| **See birth_date** | Yes | No (privacy) |
| **See total_spent** | Yes | No (financial data) |
| **See detailed activity** | Yes (`admin_user_activity`) | No |
| **Update account_status** | Yes | Yes (via function) |
| **Update financial data** | Yes | No |
| **Delete users** | Yes | No |
| **See all tables** | Yes | Limited |

---

## Cleanup (Optional)

To remove everything created in this tutorial:

```sql
-- Drop views
DROP VIEW IF EXISTS admin_user_activity;
DROP VIEW IF EXISTS admin_user_view;
DROP VIEW IF EXISTS support_user_view;

-- Drop function
DROP FUNCTION IF EXISTS update_user_status(INT, VARCHAR);

-- Revoke permissions
REVOKE ALL ON DATABASE gameverse FROM admin_role, customer_support_role;

-- Drop users and roles
DROP USER IF EXISTS alice;
DROP USER IF EXISTS bob;
DROP ROLE IF EXISTS admin_role;
DROP ROLE IF EXISTS customer_support_role;
```

---

## Best Practices Demonstrated

1. **Principle of Least Privilege**: Each role has only the permissions needed for their job
2. **View-Based Security**: Use views to filter sensitive columns
3. **Function-Based Updates**: Allow controlled updates via functions instead of direct table access
4. **Role Hierarchy**: Users inherit permissions from their assigned roles
5. **Testing**: Always test permissions by impersonating roles

---

## Quick Reference Commands

```sql
-- Switch to a role in same session
SET ROLE role_name;
RESET ROLE;

-- Check current user
SELECT current_user, session_user;

-- Check your permissions on a view
SELECT has_table_privilege('view_name', 'SELECT');

-- List all views you can access
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public';

-- See what roles you belong to
SELECT 
    r.rolname AS role_name
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON m.member = u.oid
WHERE u.rolname = current_user;
```

---

## Final Challenge Questions

These questions require you to synthesize concepts from multiple steps:

### Challenge 1: Design a New Role
**Task:** Create a new role called 'analytics_role' that can:
- View all game information
- See aggregated user statistics (count of users, total revenue) but NOT individual user details
- Cannot modify any data

Write all the SQL commands needed, including:
- Creating the role
- Creating appropriate view(s)
- Granting permissions
- Testing the role

### Challenge 2: Security Audit
**Task:** You've been asked to audit the current security setup.

1. List all views that exist in the database
2. For each view, document which roles have access
3. Identify any potential security issues
4. Suggest improvements

### Challenge 3: Enhance Customer Support Capabilities
**Task:** Customer support needs to be able to:
- Reset a user's password (without seeing the actual password)
- Send a notification to a user (insert into a notifications table)
- View a user's purchase history (from user_library)

Design and implement:
1. Any new tables needed
2. New views
3. New functions
4. Grant appropriate permissions
5. Test everything as the customer_support_role

### Challenge 4: Cross-Role Analysis
**Task:** Compare permissions and document:

1. Create a table showing all views and which roles can access them
2. What happens if alice tries to DROP bob's account?
3. Can bob see what permissions alice has? Try it.
4. What information can customer_support_role infer about financial data even though they can't see total_spent directly?

### Challenge 5: Real-World Scenario
**Scenario:** A customer calls saying their account was suspended and they don't know why.

As customer support (bob):
1. How would you find this user?
2. What information can you see about them?
3. How would you check their account status?
4. How would you reactivate their account?
5. What information can you NOT see that might be helpful?

Document each query you would run.

### Challenge 6: Create Marketing Role
**Task:** Create a 'marketing_role' that needs to:
- See user counts by country
- See game popularity (number of owners)
- See review statistics
- Cannot see individual user data or emails
- Cannot modify anything

Design the complete security setup for this role.

---

## Reflection Questions

After completing this tutorial, answer these questions:

1. **Why is role-based access control important in a real database?**

2. **What are the risks of giving everyone admin access?**

3. **How do views help with security?**

4. **When would you use a function instead of granting direct UPDATE permissions?**

5. **What's the principle of least privilege and why does it matter?**

6. **How would you handle a situation where a user needs temporary elevated permissions?**

7. **What are the trade-offs between security and usability?**

8. **How would you document who has access to what in a production database?**

---

## Extra Practice

### Practice Exercise 1: Password Policy
Create a function that enforces a password policy:
- Minimum 8 characters
- Must contain at least one number
- Store in a separate passwords table (never in users table directly)

### Practice Exercise 2: Audit Logging
Create a trigger that logs whenever a user's account_status changes:
- Who made the change
- What the old status was
- What the new status is
- When it happened

### Practice Exercise 3: Time-Based Access
Research and implement a solution where customer_support_role can only access data during business hours (9 AM - 5 PM).

Hint: Look into PostgreSQL's current_time function and CHECK constraints or triggers.

### Practice Exercise 4: Multi-Level Security
Design a system with three levels:
- Level 1: Public (anyone can view basic game info)
- Level 2: Members (registered users can see detailed info)
- Level 3: VIP (premium members can see exclusive content)

Create roles, views, and test the access control.

---

## Summary and Key Takeaways

Congratulations on completing this tutorial! Here's what you've learned:

### Core Concepts Mastered

1. **Role-Based Access Control (RBAC)**
   - Created roles with specific job functions
   - Assigned users to roles
   - Applied the principle of least privilege

2. **Views as Security Layers**
   - Used views to filter sensitive data
   - Created role-specific views with different data visibility
   - Understood how views can hide complexity and enforce security

3. **Permission Management**
   - Granted table, view, and function permissions
   - Connected users to databases with specific privileges
   - Revoked permissions when needed

4. **Secure Functions**
   - Created SECURITY DEFINER functions for controlled updates
   - Limited what operations different roles can perform
   - Validated input within functions

5. **Testing and Verification**
   - Used SET ROLE to impersonate users
   - Verified what each role can and cannot access
   - Tested security boundaries

### Real-World Applications

This tutorial simulates real database security scenarios:

- **Admin roles** have full control for system management
- **Customer support roles** can help users without accessing sensitive data
- **Application roles** might have different permissions than human users
- **Audit requirements** need function-based logging of changes

### Security Best Practices Learned

✓ Never give blanket admin access  
✓ Create views instead of exposing raw tables  
✓ Use functions for controlled data modifications  
✓ Test your security setup by impersonating users  
✓ Document what each role can access  
✓ Regularly review and audit permissions  
✓ Use meaningful role names that reflect job functions  
✓ Consider both what users need AND what they shouldn't access

### Common Pitfalls to Avoid

- Forgetting to grant CONNECT to the database
- Granting permissions on tables when you want users to use views
- Not testing with actual role impersonation
- Creating too many roles (keep it simple)
- Hardcoding sensitive checks instead of using functions
- Not documenting the security model

### Next Steps

To deepen your understanding:

1. **Practice**: Try creating security models for other types of applications (e-commerce, healthcare, education)
2. **Research**: Look into row-level security (RLS) policies in PostgreSQL
3. **Explore**: Study audit logging and compliance requirements
4. **Experiment**: Try PostgreSQL's pg_audit extension
5. **Challenge Yourself**: Implement the Extra Practice exercises above

### Cleanup (Optional)

When you're done practicing, clean up the tutorial objects:

```sql
-- Disconnect users first
-- Make sure you're the superuser/postgres user
REASSIGN OWNED BY alice TO postgres;
REASSIGN OWNED BY bob TO postgres;
DROP OWNED BY alice;
DROP OWNED BY bob;

-- Drop users and roles
DROP USER IF EXISTS alice;
DROP USER IF EXISTS bob;
DROP ROLE IF EXISTS admin_role;
DROP ROLE IF EXISTS customer_support_role;

-- Drop views
DROP VIEW IF EXISTS admin_full_users;
DROP VIEW IF EXISTS customer_support_users;

-- Drop function
DROP FUNCTION IF EXISTS update_user_status(integer, varchar);
```

### Resources for Further Learning

- [PostgreSQL Documentation: Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
- [PostgreSQL Documentation: Views](https://www.postgresql.org/docs/current/sql-createview.html)
- [PostgreSQL Documentation: Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [OWASP Database Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Database_Security_Cheat_Sheet.html)

---

**Last Updated:** February 17, 2026  
**Database:** GameVerse (PostgreSQL)  
**Version:** 2.0 - Enhanced with Learning Objectives and Practice Questions
