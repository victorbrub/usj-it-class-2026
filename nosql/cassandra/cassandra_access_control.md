# Author: Víctor Barceló
# Apache Cassandra - Access Control and Security

## Overview

Cassandra provides security through authentication (who you are), authorization (what you can do), and encryption (protecting data in transit and at rest). By default, a fresh Cassandra installation has authentication and authorization disabled. This guide covers how to enable and configure them.

---

## Authentication

### Enabling Authentication

**1. Edit `cassandra.yaml`** on every node:

```yaml
# /etc/cassandra/cassandra.yaml

authenticator: PasswordAuthenticator
authorizer: CassandraAuthorizer
role_manager: CassandraRoleManager
```

**2. Restart Cassandra**:

```bash
sudo systemctl restart cassandra
```

**3. Connect as the default superuser**:

```bash
# Default credentials after enabling PasswordAuthenticator
cqlsh -u cassandra -p cassandra
```

> The built-in `cassandra` superuser is created automatically. Change its password immediately after enabling authentication.

**4. Change the default superuser password**:

```sql
ALTER ROLE cassandra WITH PASSWORD = 'a-very-strong-password';
```

### Authentication Mechanisms

Cassandra supports two authenticators:

| Authenticator | Description |
|---|---|
| `AllowAllAuthenticator` | Default. No authentication required. Development only. |
| `PasswordAuthenticator` | Username and password stored in `system_auth` keyspace. |

For enterprise deployments, DataStax Enterprise (DSE) adds support for LDAP, Kerberos, and certificate-based authentication.

---

## Roles (Role-Based Access Control)

Cassandra uses **roles** as the unified model for both users and groups. A role can log in (like a user), or it can be granted to other roles (like a group).

### Create a Role

```sql
-- Basic role with login capability
CREATE ROLE app_user
    WITH PASSWORD = 'StrongPassword1!'
    AND LOGIN = true;

-- Role without login (used as a group/permission bundle)
CREATE ROLE analytics_read;

-- Superuser role
CREATE ROLE db_admin
    WITH PASSWORD = 'AdminPass2026!'
    AND LOGIN = true
    AND SUPERUSER = true;
```

### Alter a Role

```sql
-- Change password
ALTER ROLE app_user WITH PASSWORD = 'NewPassword2026!';

-- Grant superuser
ALTER ROLE app_user WITH SUPERUSER = true;

-- Disable login
ALTER ROLE app_user WITH LOGIN = false;
```

### Drop a Role

```sql
DROP ROLE app_user;
```

### List All Roles

```sql
LIST ROLES;

-- Show roles granted to a specific role
LIST ROLES OF app_user;
```

---

## Permissions

Permissions in Cassandra are granted on **resources** (keyspaces, tables, functions, roles) and control what actions a role can perform.

### Permission Types

| Permission | Description |
|---|---|
| `CREATE` | Create keyspaces, tables, functions, roles, or indexes |
| `ALTER` | Alter keyspaces, tables, or functions |
| `DROP` | Drop keyspaces, tables, functions, or roles |
| `SELECT` | Query data (SELECT statements) |
| `MODIFY` | INSERT, UPDATE, DELETE, TRUNCATE |
| `AUTHORIZE` | Grant or revoke permissions |
| `DESCRIBE` | Describe cluster resources |
| `EXECUTE` | Execute functions or procedures |

### Grant Permissions

```sql
-- Grant SELECT on a specific table
GRANT SELECT ON TABLE gameverse.user_profiles TO app_user;

-- Grant SELECT and MODIFY on a table
GRANT SELECT, MODIFY ON TABLE gameverse.reviews_by_game TO app_user;

-- Grant all permissions on a keyspace
GRANT ALL PERMISSIONS ON KEYSPACE gameverse TO app_admin;

-- Grant all permissions on a single table
GRANT ALL PERMISSIONS ON TABLE gameverse.user_profiles TO app_admin;

-- Grant CREATE on all keyspaces (requires superuser)
GRANT CREATE ON ALL KEYSPACES TO schema_manager;

-- Grant permissions on all tables in a keyspace
GRANT SELECT ON ALL TABLES IN KEYSPACE gameverse TO analytics_read;

-- Grant EXECUTE on a function
GRANT EXECUTE ON FUNCTION gameverse.calculate_score(text, int) TO app_user;

-- Grant AUTHORIZE (lets a role grant its own permissions to others)
GRANT AUTHORIZE ON KEYSPACE gameverse TO app_admin;
```

### Revoke Permissions

```sql
-- Revoke a specific permission
REVOKE MODIFY ON TABLE gameverse.user_profiles FROM app_user;

-- Revoke all permissions on a resource
REVOKE ALL PERMISSIONS ON TABLE gameverse.reviews_by_game FROM app_user;

-- Revoke all permissions on a keyspace
REVOKE ALL PERMISSIONS ON KEYSPACE gameverse FROM app_user;
```

### List Permissions

```sql
-- List all permissions for a role
LIST ALL PERMISSIONS OF app_user;

-- List permissions on a resource
LIST ALL PERMISSIONS ON TABLE gameverse.user_profiles;

-- List all permissions in the cluster (requires superuser)
LIST ALL PERMISSIONS;
```

---

## Role Hierarchy (Granting Roles to Roles)

Roles can be granted to other roles to create a permission hierarchy. This is the recommended way to manage permissions at scale.

```sql
-- Create permission bundles
CREATE ROLE gameverse_read;
CREATE ROLE gameverse_write;
CREATE ROLE gameverse_admin;

-- Grant table permissions to bundle roles
GRANT SELECT ON ALL TABLES IN KEYSPACE gameverse TO gameverse_read;
GRANT SELECT, MODIFY ON ALL TABLES IN KEYSPACE gameverse TO gameverse_write;
GRANT ALL PERMISSIONS ON KEYSPACE gameverse TO gameverse_admin;

-- Create application roles and assign bundles
CREATE ROLE reporting_user WITH PASSWORD = 'ReportPass1!' AND LOGIN = true;
CREATE ROLE app_backend WITH PASSWORD = 'BackendPass1!' AND LOGIN = true;
CREATE ROLE dba WITH PASSWORD = 'DbaPass2026!' AND LOGIN = true;

-- Grant bundle roles to application roles
GRANT gameverse_read TO reporting_user;
GRANT gameverse_write TO app_backend;
GRANT gameverse_admin TO dba;

-- The app_backend role now inherits all permissions from gameverse_write
-- plus anything granted directly to app_backend
```

---

## User Management (Practical Examples)

### Create a Read-Only Analyst

```sql
-- 1. Create the role
CREATE ROLE analyst
    WITH PASSWORD = 'AnalystPass2026!'
    AND LOGIN = true;

-- 2. Grant read access to the gameverse keyspace
GRANT SELECT ON ALL TABLES IN KEYSPACE gameverse TO analyst;

-- Verify
LIST ALL PERMISSIONS OF analyst;
```

### Create an Application Backend User

```sql
-- 1. Create the role
CREATE ROLE gameverse_app
    WITH PASSWORD = 'AppBackend2026!'
    AND LOGIN = true;

-- 2. Grant read and write on all tables
GRANT SELECT, MODIFY ON ALL TABLES IN KEYSPACE gameverse TO gameverse_app;

-- 3. The app does NOT need CREATE or DROP permissions
```

### Create a Schema Manager

```sql
CREATE ROLE schema_manager
    WITH PASSWORD = 'SchemaMgr2026!'
    AND LOGIN = true;

-- Grant CREATE, ALTER, DROP on the keyspace (schema changes only)
GRANT CREATE ON KEYSPACE gameverse TO schema_manager;
GRANT ALTER ON KEYSPACE gameverse TO schema_manager;
GRANT DROP ON KEYSPACE gameverse TO schema_manager;
GRANT CREATE ON ALL TABLES IN KEYSPACE gameverse TO schema_manager;
GRANT ALTER ON ALL TABLES IN KEYSPACE gameverse TO schema_manager;
GRANT DROP ON ALL TABLES IN KEYSPACE gameverse TO schema_manager;
```

### Create a DBA (Full Access, Not Superuser)

```sql
CREATE ROLE dba_user
    WITH PASSWORD = 'DbaFull2026!'
    AND LOGIN = true;

GRANT ALL PERMISSIONS ON KEYSPACE gameverse TO dba_user;
```

---

## Encryption

### SSL/TLS for Client-to-Node Encryption

Encrypting traffic between clients and Cassandra nodes is essential for production.

**1. Generate certificates** (example using self-signed certs for development):

```bash
# Generate a keystore for the Cassandra node
keytool -genkey -alias cassandra -keyalg RSA -validity 365 \
    -keystore /etc/cassandra/ssl/cassandra.keystore \
    -storepass keystorepassword \
    -dname "CN=cassandra-node1, OU=IT, O=USJ, L=Zaragoza, C=ES"

# Export the public certificate
keytool -export -alias cassandra \
    -keystore /etc/cassandra/ssl/cassandra.keystore \
    -rfc -file /etc/cassandra/ssl/cassandra.pem \
    -storepass keystorepassword
```

**2. Configure `cassandra.yaml`**:

```yaml
client_encryption_options:
    enabled: true
    optional: false
    keystore: /etc/cassandra/ssl/cassandra.keystore
    keystore_password: keystorepassword
    truststore: /etc/cassandra/ssl/cassandra.truststore
    truststore_password: truststorepassword
    require_client_auth: false   # Set to true to require client certificates
    protocol: TLS
    cipher_suites: [TLS_RSA_WITH_AES_256_CBC_SHA]
```

**3. Connect with SSL from cqlsh**:

```bash
cqlsh --ssl -u app_user -p AppPass2026! cassandra-host 9042
```

Or create a `.cqlshrc` file:

```ini
[connection]
hostname = cassandra-host
port = 9042
factory = cqlshlib.ssl.ssl_transport_factory

[ssl]
certfile = /path/to/cassandra.pem
validate = true
```

### Node-to-Node Encryption (Internode)

```yaml
# cassandra.yaml
server_encryption_options:
    internode_encryption: all   # Options: none, dc, rack, all
    keystore: /etc/cassandra/ssl/cassandra.keystore
    keystore_password: keystorepassword
    truststore: /etc/cassandra/ssl/cassandra.truststore
    truststore_password: truststorepassword
```

### Encryption at Rest

Cassandra itself does not provide native encryption at rest in the open-source version. Common approaches:

- **OS-level**: Use `dm-crypt` / `LUKS` on Linux to encrypt the data volume.
- **Cloud provider**: Use encrypted volumes (e.g., Azure Disk Encryption, AWS EBS encryption).
- **DataStax Enterprise**: Provides transparent data encryption (TDE) natively.

---

## `system_auth` Keyspace Replication

Authentication data is stored in the `system_auth` keyspace. In a multi-node cluster, this keyspace must be replicated to all nodes to prevent authentication failures when a node goes down.

```sql
-- Check current replication
DESCRIBE KEYSPACE system_auth;

-- Update replication to match your cluster size
ALTER KEYSPACE system_auth
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3   -- Replicate to all nodes in the DC
};

-- Then run a repair to distribute the data
-- (from a terminal, not cqlsh)
-- nodetool repair system_auth
```

> If `system_auth` is under-replicated and a node holding the only copy of a role goes down, all logins may fail.

---

## Best Practices

### Principle of Least Privilege

Grant only the permissions each role needs. Never grant `ALL PERMISSIONS` or `SUPERUSER` to application roles.

```sql
-- Application backend: read and write data only
GRANT SELECT, MODIFY ON ALL TABLES IN KEYSPACE gameverse TO gameverse_app;

-- Do NOT do this for an application role
GRANT ALL PERMISSIONS ON KEYSPACE gameverse TO gameverse_app;  -- Too broad
```

### Separate Roles for Schema and Data

Keep schema change permissions separate from data access permissions. Application code should never be able to DROP or ALTER tables.

```sql
-- Schema management role (used only for migrations)
CREATE ROLE schema_deployer WITH PASSWORD = 'Deploy2026!' AND LOGIN = true;
GRANT CREATE, ALTER, DROP ON ALL TABLES IN KEYSPACE gameverse TO schema_deployer;

-- Application role (data only)
CREATE ROLE app_service WITH PASSWORD = 'AppSvc2026!' AND LOGIN = true;
GRANT SELECT, MODIFY ON ALL TABLES IN KEYSPACE gameverse TO app_service;
```

### Rotate Passwords Regularly

```sql
ALTER ROLE app_service WITH PASSWORD = 'NewAppSvc2026!';
```

### Never Use the Default `cassandra` Superuser in Applications

```sql
-- Create a named DBA role instead
CREATE ROLE dba_ops WITH PASSWORD = 'DbaOps2026!' AND LOGIN = true AND SUPERUSER = true;

-- Then change the built-in cassandra password to something long and store it in a vault
ALTER ROLE cassandra WITH PASSWORD = 'long-random-vault-password';
```

### Monitor Authentication Failures

Check Cassandra system logs for authentication events:

```bash
grep -i "authentication" /var/log/cassandra/system.log
grep -i "unauthorized" /var/log/cassandra/system.log
```

---

## Common Reference: Resource Syntax

When granting permissions, resources are specified as follows:

| Resource | CQL Syntax |
|---|---|
| All keyspaces | `ALL KEYSPACES` |
| Specific keyspace | `KEYSPACE gameverse` |
| All tables in keyspace | `ALL TABLES IN KEYSPACE gameverse` |
| Specific table | `TABLE gameverse.user_profiles` |
| All functions in keyspace | `ALL FUNCTIONS IN KEYSPACE gameverse` |
| Specific function | `FUNCTION gameverse.fn_name(arg_type)` |
| All roles | `ALL ROLES` |
| Specific role | `ROLE analyst` |

---

**Last Updated**: April 20, 2026
**Course**: USJ IT Class 2026
**Module**: Cassandra Access Control
