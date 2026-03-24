# MongoDB - Access Control and Security

## Overview

MongoDB provides comprehensive security features including authentication, authorization, encryption, and auditing to protect your data. This guide covers access control mechanisms and best practices.

---

## Authentication

### Enabling Authentication

By default, MongoDB starts without authentication. To enable it:

**1. Start MongoDB without auth and create admin user:**

```javascript
// Connect to MongoDB
mongosh

// Switch to admin database
use admin

// Create admin user
db.createUser({
  user: "admin",
  pwd: "securePassword123",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" }
  ]
});
```

**2. Restart MongoDB with authentication:**

```bash
# Edit mongod.conf
security:
  authorization: enabled

# Or start with --auth flag
mongod --auth --dbpath /data/db
```

**3. Connect with credentials:**

```bash
# Method 1: Connection string
mongosh "mongodb://admin:securePassword123@localhost:27017/?authSource=admin"

# Method 2: After connecting
mongosh
use admin
db.auth("admin", "securePassword123")
```

### Authentication Mechanisms

MongoDB supports multiple authentication mechanisms:

1. **SCRAM (default)**:
   - SCRAM-SHA-256 (MongoDB 4.0+)
   - SCRAM-SHA-1 (legacy)

2. **x.509 Certificates**:
   - Client and server certificate authentication

3. **LDAP**:
   - Enterprise only
   - Active Directory integration

4. **Kerberos**:
   - Enterprise only
   - Network authentication

---

## Authorization (Role-Based Access Control)

### Built-in Roles

#### Database User Roles

1. **read**: Read data from all non-system collections
```javascript
db.createUser({
  user: "readOnlyUser",
  pwd: "password",
  roles: [ { role: "read", db: "mydb" } ]
});
```

2. **readWrite**: Read and write data
```javascript
db.createUser({
  user: "readWriteUser",
  pwd: "password",
  roles: [ { role: "readWrite", db: "mydb" } ]
});
```

#### Database Administration Roles

3. **dbAdmin**: Manage database (indexes, stats)
```javascript
db.createUser({
  user: "dbAdminUser",
  pwd: "password",
  roles: [ { role: "dbAdmin", db: "mydb" } ]
});
```

4. **userAdmin**: Create and modify users and roles
```javascript
db.createUser({
  user: "userAdminUser",
  pwd: "password",
  roles: [ { role: "userAdmin", db: "mydb" } ]
});
```

5. **dbOwner**: Full access to database
```javascript
db.createUser({
  user: "dbOwnerUser",
  pwd: "password",
  roles: [ { role: "dbOwner", db: "mydb" } ]
});
```

#### Cluster Administration Roles

6. **clusterAdmin**: Full cluster management
7. **clusterManager**: Manage cluster
8. **clusterMonitor**: Read cluster monitoring tools
9. **hostManager**: Monitor and manage servers

#### Backup and Restore Roles

10. **backup**: Backup data
11. **restore**: Restore data

#### All-Database Roles

12. **readAnyDatabase**: Read from all databases
13. **readWriteAnyDatabase**: Read/write all databases
14. **userAdminAnyDatabase**: User admin for all databases
15. **dbAdminAnyDatabase**: DB admin for all databases

#### Superuser Roles

16. **root**: Full access to all resources
```javascript
db.createUser({
  user: "superuser",
  pwd: "verysecurepassword",
  roles: [ "root" ]
});
```

---

## User Management

### Create Users

```javascript
// Basic user
db.createUser({
  user: "appUser",
  pwd: "password123",
  roles: [
    { role: "readWrite", db: "myapp" }
  ]
});

// User with multiple roles
db.createUser({
  user: "analyst",
  pwd: "password123",
  roles: [
    { role: "read", db: "sales" },
    { role: "read", db: "marketing" },
    { role: "readWrite", db: "reports" }
  ]
});

// User with custom role
db.createUser({
  user: "dataEngineer",
  pwd: "password123",
  roles: [
    { role: "readWrite", db: "warehouse" },
    { role: "dbAdmin", db: "warehouse" },
    "dataScientist"  // Custom role
  ]
});
```

### View Users

```javascript
// Show all users in current database
db.getUsers();

// Show specific user
db.getUser("appUser");

// Show users with credentials
db.getUser("appUser", { showCredentials: true });

// Show all users in all databases (requires userAdminAnyDatabase)
use admin
db.system.users.find();
```

### Update Users

```javascript
// Change password
db.changeUserPassword("appUser", "newPassword456");

// Update user roles
db.updateUser("appUser", {
  roles: [
    { role: "readWrite", db: "myapp" },
    { role: "read", db: "analytics" }
  ]
});

// Grant additional role
db.grantRolesToUser("appUser", [
  { role: "dbAdmin", db: "myapp" }
]);

// Revoke role
db.revokeRolesFromUser("appUser", [
  { role: "dbAdmin", db: "myapp" }
]);
```

### Delete Users

```javascript
// Drop user
db.dropUser("appUser");

// Drop all users from database
db.dropAllUsers();
```

---

## Custom Roles

### Create Custom Role

```javascript
use mydb

db.createRole({
  role: "dataScientist",
  privileges: [
    {
      resource: { db: "mydb", collection: "analytics" },
      actions: [ "find", "insert", "update" ]
    },
    {
      resource: { db: "mydb", collection: "experiments" },
      actions: [ "find", "insert", "update", "remove" ]
    }
  ],
  roles: [
    { role: "read", db: "reference_data" }
  ]
});
```

### Privilege Actions

**Query and Write Actions**:
- `find`: Query documents
- `insert`: Insert documents
- `update`: Update documents
- `remove`: Remove documents

**Database Management Actions**:
- `createCollection`: Create collections
- `createIndex`: Create indexes
- `dropCollection`: Drop collections
- `dropIndex`: Drop indexes

**Deployment Management Actions**:
- `shutdown`: Shutdown server
- `killop`: Kill operations

**Replication Actions**:
- `replSetConfigure`: Configure replica set
- `replSetGetStatus`: Get replica set status

**Example: Read-Only Role for Specific Collections**:

```javascript
db.createRole({
  role: "readSpecificCollections",
  privileges: [
    {
      resource: { db: "mydb", collection: "public_data" },
      actions: [ "find" ]
    },
    {
      resource: { db: "mydb", collection: "archived_data" },
      actions: [ "find" ]
    }
  ],
  roles: []
});
```

### Role Management

```javascript
// View role
db.getRole("dataScientist", { showPrivileges: true });

// View all roles
db.getRoles({ showPrivileges: true });

// Update role
db.updateRole("dataScientist", {
  privileges: [
    {
      resource: { db: "mydb", collection: "analytics" },
      actions: [ "find", "insert", "update", "remove" ]
    }
  ]
});

// Grant privileges to role
db.grantPrivilegesToRole("dataScientist", [
  {
    resource: { db: "mydb", collection: "models" },
    actions: [ "find", "insert" ]
  }
]);

// Drop role
db.dropRole("dataScientist");
```

---

## Resource Permissions

### Resource Types

```javascript
// Specific database and collection
{ db: "mydb", collection: "users" }

// All collections in database
{ db: "mydb", collection: "" }

// Specific collection in all databases
{ db: "", collection: "users" }

// All collections in all databases
{ db: "", collection: "" }

// Cluster resource
{ cluster: true }
```

### Fine-Grained Access Control

```javascript
// Role with multiple resource permissions
db.createRole({
  role: "applicationRole",
  privileges: [
    // Full access to users collection
    {
      resource: { db: "myapp", collection: "users" },
      actions: [ "find", "insert", "update", "remove" ]
    },
    // Read-only access to config
    {
      resource: { db: "myapp", collection: "config" },
      actions: [ "find" ]
    },
    // Create indexes on sessions
    {
      resource: { db: "myapp", collection: "sessions" },
      actions: [ "find", "insert", "update", "remove", "createIndex" ]
    },
    // View collection stats
    {
      resource: { db: "myapp", collection: "" },
      actions: [ "collStats" ]
    }
  ],
  roles: []
});
```

---

## Field-Level Access Control

### MongoDB Atlas and Enterprise

Field-level redaction using views:

```javascript
// Create view that excludes sensitive fields
db.createView(
  "users_public",
  "users",
  [
    {
      $project: {
        name: 1,
        email: 1,
        city: 1,
        _id: 1,
        // Exclude: password, ssn, creditCard
      }
    }
  ]
);

// Grant access only to view
db.createRole({
  role: "publicUserAccess",
  privileges: [
    {
      resource: { db: "mydb", collection: "users_public" },
      actions: [ "find" ]
    }
  ],
  roles: []
});
```

### Field-Level Encryption (Client-Side)

```javascript
// Configure client-side field level encryption
const clientEncryption = new ClientEncryption(keyVaultClient, {
  keyVaultNamespace: "encryption.__keyVault",
  kmsProviders: {
    local: {
      key: masterKey
    }
  }
});

// Create encrypted collection
await db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        ssn: {
          encrypt: {
            keyId: [dataKeyId],
            algorithm: "AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic",
            bsonType: "string"
          }
        },
        creditCard: {
          encrypt: {
            keyId: [dataKeyId],
            algorithm: "AEAD_AES_256_CBC_HMAC_SHA_512-Random",
            bsonType: "string"
          }
        }
      }
    }
  }
});
```

---

## Encryption

### Encryption at Rest

**MongoDB Enterprise** supports encryption at rest:

```yaml
# mongod.conf
security:
  enableEncryption: true
  encryptionKeyFile: /path/to/keyfile
```

### Encryption in Transit (TLS/SSL)

**1. Generate certificates:**

```bash
# Generate CA certificate
openssl req -new -x509 -days 3650 -out ca.crt -keyout ca.key

# Generate server certificate
openssl req -new -nodes -out server.csr -keyout server.key
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650

# Combine certificate and key
cat server.crt server.key > server.pem
```

**2. Configure MongoDB:**

```yaml
# mongod.conf
net:
  tls:
    mode: requireTLS
    certificateKeyFile: /path/to/server.pem
    CAFile: /path/to/ca.crt
```

**3. Connect with TLS:**

```bash
mongosh "mongodb://localhost:27017/?tls=true&tlsCAFile=/path/to/ca.crt"
```

---

## Network Security

### IP Whitelisting

```yaml
# mongod.conf
net:
  bindIp: localhost,192.168.1.100
  port: 27017
```

### Firewall Rules

```bash
# Linux: Allow MongoDB port only from specific IPs
sudo ufw allow from 192.168.1.0/24 to any port 27017

# Deny all other traffic
sudo ufw deny 27017
```

---

## Auditing (Enterprise)

### Enable Auditing

```yaml
# mongod.conf
auditLog:
  destination: file
  format: JSON
  path: /var/log/mongodb/audit.json
  filter: '{ atype: { $in: [ "authenticate", "createUser", "dropUser" ] } }'
```

### Audit Filter Examples

```javascript
// Audit all authentication attempts
{ atype: "authenticate" }

// Audit user management
{ atype: { $in: [ "createUser", "dropUser", "updateUser" ] } }

// Audit specific collection access
{ 
  ns: "mydb.sensitiveCollection",
  atype: { $in: [ "insert", "update", "remove" ] }
}

// Audit by user
{ "param.user": "admin" }
```

---

## Best Practices

### 1. Principle of Least Privilege

```javascript
// DON'T: Give root access
db.createUser({
  user: "appUser",
  pwd: "password",
  roles: [ "root" ]  // Too much access!
});

// DO: Give minimal necessary permissions
db.createUser({
  user: "appUser",
  pwd: "password",
  roles: [
    { role: "readWrite", db: "myapp" }  // Only what's needed
  ]
});
```

### 2. Use Strong Passwords

```javascript
// DON'T: Weak passwords
db.createUser({
  user: "admin",
  pwd: "admin123",  // Weak!
  roles: [ "root" ]
});

// DO: Strong passwords
db.createUser({
  user: "admin",
  pwd: "Xy9$mK#p2L@vN8qR",  // Strong!
  roles: [ "root" ]
});
```

### 3. Separate Admin and Application Users

```javascript
// Admin user (for DBA tasks)
use admin
db.createUser({
  user: "dba",
  pwd: "strongAdminPassword",
  roles: [ "userAdminAnyDatabase", "dbAdminAnyDatabase" ]
});

// Application user (limited access)
use myapp
db.createUser({
  user: "appUser",
  pwd: "strongAppPassword",
  roles: [ { role: "readWrite", db: "myapp" } ]
});
```

### 4. Regular User Audits

```javascript
// Review users periodically
use admin
db.system.users.find({}, { user: 1, roles: 1 });

// Remove unused users
db.dropUser("oldAppUser");
```

### 5. Rotate Credentials

```javascript
// Change passwords regularly
db.changeUserPassword("appUser", "newStrongPassword");
```

### 6. Monitor Access

```javascript
// Use profiling to monitor queries
db.setProfilingLevel(1, { slowms: 100 });

// Check current operations
db.currentOp({ active: true });

// View user connections
db.serverStatus().connections;
```

### 7. Use Environment Variables

```javascript
// DON'T: Hardcode credentials in code
const uri = "mongodb://admin:password@localhost:27017";

// DO: Use environment variables
const uri = `mongodb://${process.env.DB_USER}:${process.env.DB_PASS}@${process.env.DB_HOST}`;
```

---

## Application Connection Security

### Connection String with Authentication

```javascript
// Node.js example
const MongoClient = require('mongodb').MongoClient;

const uri = "mongodb://username:password@localhost:27017/mydb?authSource=admin";

const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  ssl: true,
  sslValidate: true,
  sslCA: fs.readFileSync('/path/to/ca.pem')
});

await client.connect();
```

### Connection Pooling

```javascript
const client = new MongoClient(uri, {
  maxPoolSize: 10,        // Maximum connections
  minPoolSize: 5,         // Minimum connections
  maxIdleTimeMS: 30000,   // Close idle connections after 30s
  serverSelectionTimeoutMS: 5000
});
```

---

## Security Checklist

- [ ] Enable authentication
- [ ] Use strong passwords
- [ ] Apply principle of least privilege
- [ ] Create separate users for different purposes
- [ ] Enable TLS/SSL encryption
- [ ] Configure network security (firewalls, IP whitelisting)
- [ ] Enable encryption at rest (if using Enterprise)
- [ ] Enable auditing (if using Enterprise)
- [ ] Regular security audits
- [ ] Monitor access logs
- [ ] Rotate credentials periodically
- [ ] Use connection string encryption in applications
- [ ] Keep MongoDB updated with security patches
- [ ] Backup encryption keys securely
- [ ] Document security policies

---

## Common Security Scenarios

### Scenario 1: Web Application

```javascript
// Separate users for different components
// 1. Read-only user for analytics
db.createUser({
  user: "analyticsReader",
  pwd: "securePassword1",
  roles: [ { role: "read", db: "webapp" } ]
});

// 2. Read-write for application
db.createUser({
  user: "webappUser",
  pwd: "securePassword2",
  roles: [ { role: "readWrite", db: "webapp" } ]
});

// 3. Admin for maintenance
db.createUser({
  user: "webappAdmin",
  pwd: "securePassword3",
  roles: [ { role: "dbOwner", db: "webapp" } ]
});
```

### Scenario 2: Multi-Tenant Application

```javascript
// Create database per tenant
// User with access to specific tenant
db.createUser({
  user: "tenant_abc_user",
  pwd: "tenantPassword",
  roles: [ { role: "readWrite", db: "tenant_abc" } ]
});

// Admin with access to all tenants
db.createUser({
  user: "multiTenantAdmin",
  pwd: "adminPassword",
  roles: [ "readWriteAnyDatabase" ]
});
```

### Scenario 3: Development vs Production

```javascript
// Development (more permissive)
db.createUser({
  user: "devUser",
  pwd: "devPassword",
  roles: [
    { role: "readWrite", db: "myapp_dev" },
    { role: "dbAdmin", db: "myapp_dev" }
  ]
});

// Production (restricted)
db.createUser({
  user: "prodUser",
  pwd: "strongProdPassword",
  roles: [ { role: "readWrite", db: "myapp_prod" } ]
});
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: MongoDB Access Control and Security
