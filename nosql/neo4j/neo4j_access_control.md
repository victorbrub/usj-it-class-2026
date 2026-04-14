# Neo4j - Access Control and Security

## Overview

Neo4j provides comprehensive role-based access control (RBAC) that allows fine-grained control over who can access and modify data. This guide covers authentication, authorization, encryption, and security best practices.

---

## Authentication

### Built-in Authentication

Neo4j uses native authentication by default with username and password:

```cypher
// Default admin user
Username: neo4j
Password: neo4j (must be changed on first login)
```

### Enabling Authentication

Authentication is enabled by default in Neo4j 4.0+. Configuration in `neo4j.conf`:

```
# Require authentication
dbms.security.auth_enabled=true

# Authentication provider (native, ldap, plugin)
dbms.security.auth_providers=native
```

### Change Password

```cypher
// Change your own password
ALTER CURRENT USER SET PASSWORD FROM 'oldPassword' TO 'newPassword'

// Admin changing another user's password
ALTER USER alice SET PASSWORD 'newSecurePassword' CHANGE REQUIRED
// User must change password on next login
```

---

## User Management

### Create Users

```cypher
// Create basic user
CREATE USER alice SET PASSWORD 'password123' CHANGE NOT REQUIRED

// Create user with password change required
CREATE USER bob SET PASSWORD 'tempPassword' CHANGE REQUIRED

// Create user with specific status
CREATE USER charlie 
  SET PASSWORD 'password456' 
  CHANGE NOT REQUIRED 
  SET STATUS ACTIVE
```

### List Users

```cypher
// Show all users
SHOW USERS

// Show specific user details
SHOW USER alice PRIVILEGES
```

### Modify Users

```cypher
// Change password
ALTER USER alice SET PASSWORD 'newPassword'

// Require password change on next login
ALTER USER alice SET PASSWORD CHANGE REQUIRED

// Change user status
ALTER USER bob SET STATUS SUSPENDED
ALTER USER bob SET STATUS ACTIVE

// Set home database
ALTER USER alice SET HOME DATABASE production
```

### Delete Users

```cypher
DROP USER alice
```

---

## Role-Based Access Control (RBAC)

### Built-in Roles

Neo4j provides several built-in roles:

**PUBLIC** - Default role for all users
- No privileges by default
- Can be granted additional privileges

**reader** - Read-only access
- Can execute queries
- Cannot modify data

**editor** - Read and write access
- Can read and write data
- Cannot modify schema

**publisher** - Editor + schema modification
- Can read and write data
- Can create indexes and constraints

**architect** - Publisher + schema design
- Full schema control
- Cannot manage users or roles

**admin** - Full administrative access
- Can manage users and roles
- Cannot access data by default

### View Built-in Roles

```cypher
// Show all roles
SHOW ROLES

// Show role privileges
SHOW ROLE reader PRIVILEGES
```

---

## Creating Custom Roles

### Basic Role Creation

```cypher
// Create custom role
CREATE ROLE analyst

// Create role for specific team
CREATE ROLE sales_team
CREATE ROLE engineering_team
```

### Granting Roles to Users

```cypher
// Grant single role
GRANT ROLE reader TO alice

// Grant multiple roles
GRANT ROLE reader, analyst TO bob

// Users can have multiple roles
GRANT ROLE sales_team TO alice, bob, charlie
```

### Revoking Roles

```cypher
// Revoke role from user
REVOKE ROLE analyst FROM alice

// Revoke multiple roles
REVOKE ROLE reader, analyst FROM bob
```

### Deleting Roles

```cypher
DROP ROLE analyst
```

---

## Database Privileges

### Database Access

```cypher
// Grant access to specific database
GRANT ACCESS ON DATABASE production TO reader

// Grant access to all databases
GRANT ACCESS ON ALL DATABASES TO admin

// Grant access to home database
GRANT ACCESS ON HOME DATABASE TO user

// Grant access to default database
GRANT ACCESS ON DEFAULT DATABASE TO public
```

### Database Management

```cypher
// Allow creating databases
GRANT CREATE DATABASE ON DBMS TO architect

// Allow dropping databases
GRANT DROP DATABASE ON DBMS TO architect

// View database privileges
SHOW DATABASE production PRIVILEGES
```

---

## Graph Privileges

### Read Privileges

```cypher
// Grant read on all nodes and relationships
GRANT MATCH {*} ON GRAPH production TO reader

// Grant read on specific labels
GRANT MATCH {Person} ON GRAPH production TO hr_team

// Grant read on specific relationship types
GRANT MATCH {}-[:KNOWS]->{} ON GRAPH production TO analyst

// Grant read on all graphs
GRANT MATCH {*} ON GRAPHS * TO reader
```

### Write Privileges

```cypher
// Grant write (create, delete, set property, remove property)
GRANT WRITE ON GRAPH production TO editor

// Grant create only
GRANT CREATE ON GRAPH production TO data_ingestion

// Grant delete only
GRANT DELETE ON GRAPH production TO moderator

// Grant set property only
GRANT SET PROPERTY ON GRAPH production TO updater
```

### Specific Element Privileges

```cypher
// Grant access to specific node labels
GRANT MATCH {User}, SET PROPERTY {User} 
ON GRAPH production 
TO user_service

// Grant access to specific properties
GRANT SET PROPERTY {User.lastLogin} 
ON GRAPH production 
TO analytics_service

// Grant relationship access
GRANT CREATE ON RELATIONSHIPS [:PURCHASED] 
ON GRAPH production 
TO order_service
```

---

## Schema Privileges

### Index Privileges

```cypher
// Grant index creation
GRANT CREATE INDEX ON DATABASE production TO architect

// Grant index dropping
GRANT DROP INDEX ON DATABASE production TO architect

// View index privileges
SHOW INDEXES
```

### Constraint Privileges

```cypher
// Grant constraint creation
GRANT CREATE CONSTRAINT ON DATABASE production TO architect

// Grant constraint dropping
GRANT DROP CONSTRAINT ON DATABASE production TO architect

// View constraints
SHOW CONSTRAINTS
```

---

## Fine-Grained Access Control

### Property-Level Access

```cypher
// Grant read on all properties except sensitive ones
GRANT MATCH {Person} ON GRAPH production TO analyst

// Deny specific properties
DENY READ {Person.ssn, Person.salary} ON GRAPH production TO analyst
```

### Label-Based Access

```cypher
// Create role for customer service
CREATE ROLE customer_service

// Grant access only to Customer nodes
GRANT MATCH {Customer} ON GRAPH production TO customer_service
GRANT SET PROPERTY {Customer} ON GRAPH production TO customer_service

// Deny access to internal data
DENY MATCH {Employee}, {InternalDocument} 
ON GRAPH production 
TO customer_service
```

### Path-Based Access

```cypher
// Allow traversing specific paths
GRANT TRAVERSE ON GRAPH production TO analyst

// Limit traversal depth with application logic
// Neo4j doesn't have built-in traversal depth limits in RBAC
```

---

## Practical Access Control Scenarios

### Scenario 1: Read-Only Analyst

```cypher
// Create analyst role with read-only access
CREATE ROLE analyst

// Grant database access
GRANT ACCESS ON DATABASE production TO analyst

// Grant read privileges
GRANT MATCH {*} ON GRAPH production TO analyst
GRANT TRAVERSE ON GRAPH production TO analyst

// Assign to user
CREATE USER alice SET PASSWORD 'password123' CHANGE NOT REQUIRED
GRANT ROLE analyst TO alice
```

### Scenario 2: Application Service Account

```cypher
// Create role for user service
CREATE ROLE user_service

// Grant specific database access
GRANT ACCESS ON DATABASE production TO user_service

// Grant read on all, write on specific labels
GRANT MATCH {*} ON GRAPH production TO user_service
GRANT WRITE ON LABELS User, Profile ON GRAPH production TO user_service

// Grant relationship creation
GRANT CREATE ON RELATIONSHIPS [:HAS_PROFILE], [:FRIEND_OF] 
ON GRAPH production 
TO user_service

// Create service account
CREATE USER user_svc SET PASSWORD 'servicePassword' CHANGE NOT REQUIRED
GRANT ROLE user_service TO user_svc
```

### Scenario 3: Database Administrator

```cypher
// Create DBA role
CREATE ROLE dba

// Grant all database privileges
GRANT ALL ON DATABASE * TO dba

// Grant all graph privileges
GRANT ALL ON GRAPH * TO dba

// Grant user management
GRANT CREATE USER, DROP USER, ALTER USER ON DBMS TO dba
GRANT CREATE ROLE, DROP ROLE, ASSIGN ROLE, REMOVE ROLE ON DBMS TO dba

// Grant database management
GRANT CREATE DATABASE, DROP DATABASE ON DBMS TO dba

// Assign to user
CREATE USER dbadmin SET PASSWORD 'adminPassword' CHANGE REQUIRED
GRANT ROLE dba TO dbadmin
```

### Scenario 4: Multi-Tenant Application

```cypher
// Create tenant-specific databases
CREATE DATABASE tenant_a
CREATE DATABASE tenant_b

// Create roles for each tenant
CREATE ROLE tenant_a_user
CREATE ROLE tenant_b_user

// Grant access to respective databases
GRANT ACCESS ON DATABASE tenant_a TO tenant_a_user
GRANT MATCH {*}, WRITE ON GRAPH tenant_a TO tenant_a_user

GRANT ACCESS ON DATABASE tenant_b TO tenant_b_user
GRANT MATCH {*}, WRITE ON GRAPH tenant_b TO tenant_b_user

// Create users for Tenant A
CREATE USER alice_a SET PASSWORD 'password' CHANGE NOT REQUIRED
GRANT ROLE tenant_a_user TO alice_a

// Create users for Tenant B
CREATE USER bob_b SET PASSWORD 'password' CHANGE NOT REQUIRED
GRANT ROLE tenant_b_user TO bob_b
```

---

## LDAP Integration (Enterprise)

### Configure LDAP

```
# neo4j.conf

# Enable LDAP authentication
dbms.security.auth_providers=ldap

# LDAP server configuration
dbms.security.ldap.host=ldap.example.com
dbms.security.ldap.port=389

# Use LDAPS (secure)
dbms.security.ldap.use_starttls=true

# User DN template
dbms.security.ldap.user_dn_template=uid={0},ou=users,dc=example,dc=com

# Authorization configuration
dbms.security.ldap.authorization.use_system_account=true
dbms.security.ldap.authorization.system_username=cn=neo4j,ou=services,dc=example,dc=com
dbms.security.ldap.authorization.system_password=ldapPassword

# Group to role mapping
dbms.security.ldap.authorization.group_to_role_mapping=\
  "cn=neo4j_read,ou=groups,dc=example,dc=com"=reader;\
  "cn=neo4j_edit,ou=groups,dc=example,dc=com"=editor;\
  "cn=neo4j_admin,ou=groups,dc=example,dc=com"=admin
```

---

## Encryption

### Encryption in Transit (SSL/TLS)

**Generate Certificates:**

```bash
# Generate private key
openssl genrsa -out private.key 2048

# Generate certificate signing request
openssl req -new -key private.key -out cert.csr

# Generate self-signed certificate
openssl x509 -req -days 365 -in cert.csr -signkey private.key -out public.crt

# Copy to Neo4j certificates directory
cp private.key /var/lib/neo4j/certificates/bolt/
cp public.crt /var/lib/neo4j/certificates/bolt/
```

**Configure SSL in neo4j.conf:**

```
# Enable SSL for Bolt
dbms.ssl.policy.bolt.enabled=true
dbms.ssl.policy.bolt.base_directory=certificates/bolt
dbms.ssl.policy.bolt.private_key=private.key
dbms.ssl.policy.bolt.public_certificate=public.crt

# Require client authentication (optional)
dbms.ssl.policy.bolt.client_auth=REQUIRE
```

**Connect with TLS:**

```javascript
// Node.js
const driver = neo4j.driver(
  'bolt+s://localhost:7687',  // Note: bolt+s for secure connection
  neo4j.auth.basic('neo4j', 'password'),
  {
    encrypted: true,
    trust: 'TRUST_SYSTEM_CA_SIGNED_CERTIFICATES'
  }
);
```

### Encryption at Rest (Enterprise)

```
# neo4j.conf

# Enable encryption at rest
dbms.security.encryption.enabled=true

# Encryption provider
dbms.security.encryption.provider=AES256

# Key management
dbms.security.encryption.keystore=/path/to/keystore
dbms.security.encryption.key=myEncryptionKey
```

---

## Connection Security

### IP Whitelisting

```
# neo4j.conf

# Bind to specific network interface
dbms.connector.bolt.listen_address=192.168.1.100:7687

# Allow only specific IPs (using firewall)
# iptables -A INPUT -p tcp --dport 7687 -s 192.168.1.0/24 -j ACCEPT
# iptables -A INPUT -p tcp --dport 7687 -j DROP
```

### Connection Pooling and Timeouts

```javascript
const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('neo4j', 'password'),
  {
    maxConnectionPoolSize: 50,
    connectionAcquisitionTimeout: 60000,  // 60 seconds
    maxConnectionLifetime: 3600000,       // 1 hour
    connectionTimeout: 30000              // 30 seconds
  }
);
```

---

## Auditing (Enterprise)

### Enable Security Event Logging

```
# neo4j.conf

# Enable security logging
dbms.logs.security.enabled=true

# Log level
dbms.logs.security.level=INFO

# Log file rotation
dbms.logs.security.rotation.size=10M
dbms.logs.security.rotation.keep_number=10
```

### Security Events Logged

- Authentication attempts (success/failure)
- Authorization decisions (granted/denied)
- User management operations
- Role management operations
- Database operations

### Query Security Logs

```bash
# View security log
tail -f /var/lib/neo4j/logs/security.log

# Example log entry:
# 2024-03-01 10:15:32.145+0000 INFO  [alice] logged in successfully
# 2024-03-01 10:16:45.891+0000 WARN  [bob] failed login attempt
# 2024-03-01 10:17:12.456+0000 INFO  [alice] executed query on database:production
```

---

## Application Security Best Practices

### 1. Use Parameterized Queries

```javascript
// GOOD: Parameterized query prevents injection
await session.run(
  'MATCH (u:User {email: $email}) RETURN u',
  { email: userInput }
);

// BAD: String concatenation vulnerable to injection
await session.run(
  `MATCH (u:User {email: '${userInput}'}) RETURN u`
);
```

### 2. Principle of Least Privilege

```cypher
// Give only necessary permissions
CREATE ROLE api_service

// Only what the service needs
GRANT ACCESS ON DATABASE production TO api_service
GRANT MATCH {User, Product, Order} ON GRAPH production TO api_service
GRANT CREATE ON LABELS Order ON GRAPH production TO api_service
GRANT SET PROPERTY {Order} ON GRAPH production TO api_service
```

### 3. Separate Accounts for Services

```cypher
// Different service accounts
CREATE USER web_app_svc SET PASSWORD 'pwd1' CHANGE NOT REQUIRED
CREATE USER analytics_svc SET PASSWORD 'pwd2' CHANGE NOT REQUIRED
CREATE USER batch_job_svc SET PASSWORD 'pwd3' CHANGE NOT REQUIRED

// Each with appropriate roles
GRANT ROLE web_service TO web_app_svc
GRANT ROLE analyst TO analytics_svc
GRANT ROLE batch_processor TO batch_job_svc
```

### 4. Secure Credential Storage

```javascript
// Use environment variables
const driver = neo4j.driver(
  process.env.NEO4J_URI,
  neo4j.auth.basic(
    process.env.NEO4J_USER,
    process.env.NEO4J_PASSWORD
  )
);

// Or use secret management service
const secrets = await getSecretsFromVault();
const driver = neo4j.driver(
  secrets.neo4j.uri,
  neo4j.auth.basic(secrets.neo4j.user, secrets.neo4j.password)
);
```

### 5. Regular Audits

```cypher
// Review user access regularly
SHOW USERS

// Check user privileges
SHOW USER alice PRIVILEGES

// Review role assignments
SHOW ROLES
SHOW ROLE analyst PRIVILEGES
```

### 6. Password Policies

```cypher
// Enforce strong passwords (application layer)
// Neo4j doesn't have built-in password complexity requirements

// Require password changes
ALTER USER alice SET PASSWORD CHANGE REQUIRED

// Rotate passwords regularly (policy, not enforced)
ALTER USER service_account SET PASSWORD 'newPassword123'
```

### 7. Monitor Failed Login Attempts

```bash
# Review security logs for failed logins
grep "failed login" /var/lib/neo4j/logs/security.log

# Implement rate limiting at application layer
# Lock accounts after N failed attempts
```

---

## Security Checklist

- [ ] Change default `neo4j` password immediately
- [ ] Enable authentication (`dbms.security.auth_enabled=true`)
- [ ] Create separate user accounts for each service/person
- [ ] Implement role-based access control for all users
- [ ] Grant minimum necessary privileges (least privilege)
- [ ] Use parameterized queries to prevent injection attacks
- [ ] Enable SSL/TLS for encrypted connections
- [ ] Configure firewall rules to restrict access
- [ ] Store credentials securely (environment variables/secrets manager)
- [ ] Enable security logging and monitoring
- [ ] Regularly audit user access and privileges
- [ ] Implement password rotation policy
- [ ] Use LDAP/SSO for centralized authentication (Enterprise)
- [ ] Enable encryption at rest (Enterprise)
- [ ] Regular backups with secure storage
- [ ] Keep Neo4j updated with latest security patches

---

## Connection String Examples

### Basic Authentication

```javascript
// Node.js
const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('username', 'password')
);
```

### Secure Connection (TLS)

```javascript
const driver = neo4j.driver(
  'bolt+s://production.example.com:7687',
  neo4j.auth.basic('username', 'password'),
  { encrypted: true }
);
```

### No Authentication (Development Only)

```
# neo4j.conf
dbms.security.auth_enabled=false
```

```javascript
const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.none()
);
```

---

## Troubleshooting Access Issues

### Check User Privileges

```cypher
// View all privileges for current user
SHOW USER PRIVILEGES

// View privileges for specific user
SHOW USER alice PRIVILEGES

// View denied privileges
SHOW USER alice PRIVILEGES
WHERE action = 'denied'
```

### Common Access Errors

**Error: "Permission denied"**
```cypher
// Check if user has necessary role
SHOW USER alice PRIVILEGES

// Grant missing privilege
GRANT MATCH {*} ON GRAPH production TO ROLE reader
```

**Error: "Authentication failed"**
```cypher
// Reset password
ALTER USER alice SET PASSWORD 'newPassword'

// Check user status
SHOW USER alice
// Ensure STATUS is ACTIVE
```

**Error: "Database access denied"**
```cypher
// Grant database access
GRANT ACCESS ON DATABASE production TO alice
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Neo4j Access Control and Security
