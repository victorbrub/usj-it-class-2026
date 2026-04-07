# Redis - Access Control and Security

## Overview

Redis provides comprehensive security features including authentication, access control lists (ACLs), encryption, and network security. This guide covers how to secure your Redis deployment from development to production.

---

## Authentication

### Basic Password Authentication (Legacy)

Before Redis 6.0, authentication used a single shared password:

**Set password in redis.conf:**

```conf
# redis.conf
requirepass myStrongPassword123
```

**Or set at runtime:**

```bash
CONFIG SET requirepass "myStrongPassword123"
```

**Connect with password:**

```bash
# Using redis-cli
redis-cli -a myStrongPassword123

# Or authenticate after connecting
redis-cli
AUTH myStrongPassword123
```

**In application code:**

```python
# Python
import redis

r = redis.Redis(
    host='localhost',
    port=6379,
    password='myStrongPassword123'
)
```

```javascript
// Node.js
const redis = require('redis');

const client = redis.createClient({
    host: 'localhost',
    port: 6379,
    password: 'myStrongPassword123'
});
```

**Limitations of legacy AUTH:**
- Single password for entire Redis instance
- No per-user permissions
- All authenticated users have full access

---

## Access Control Lists (ACL) - Redis 6.0+

### ACL Overview

Redis 6.0 introduced fine-grained access control:

- **Multiple users** with different passwords
- **Command permissions** (which commands users can execute)
- **Key permissions** (which keys users can access)
- **Channel permissions** (for pub/sub)

### View Current ACLs

```bash
# List all users
ACL LIST

# Show current user
ACL WHOAMI

# Get detailed user info
ACL GETUSER username
```

### Default User

Redis has a default user with full permissions:

```bash
ACL GETUSER default
# Output:
# 1) "flags"
# 2) 1) "on"
#    2) "allkeys"
#    3) "allcommands"
#    4) "nopass"
```

---

## Creating Users

### Basic User Creation

```bash
# Create readonly user
ACL SETUSER alice on >password123 ~* +@read

# Create read-write user
ACL SETUSER bob on >password456 ~* +@read +@write

# Create admin user
ACL SETUSER admin on >adminpass ~* +@all
```

### ACL Rule Syntax

**User State:**
- `on` - Enable user
- `off` - Disable user
- `>password` - Set password
- `<password` - Remove password
- `nopass` - No password required (dangerous!)

**Key Patterns:**
- `~*` - All keys
- `~prefix:*` - Keys matching pattern
- `~key1 ~key2` - Specific keys only
- `allkeys` - Equivalent to ~*

**Command Permissions:**
- `+@all` - All commands
- `+@read` - All read commands
- `+@write` - All write commands
- `+@admin` - Administrative commands
- `+GET +SET` - Specific commands
- `-DEL -FLUSHDB` - Deny specific commands

**Channel Permissions (Pub/Sub):**
- `&*` - All channels
- `&news:*` - Channels matching pattern

---

## Practical ACL Examples

### Example 1: Read-Only User

```bash
# Create user that can only read from cache keys
ACL SETUSER cache_reader on >readerpass ~cache:* +@read -@write -@admin

# Test
AUTH cache_reader readerpass
GET cache:user:123        # OK
SET cache:user:123 "val"  # ERROR: No permissions
```

### Example 2: Application Service Account

```bash
# Create user for web application
ACL SETUSER webapp on >webapppass ~session:* ~user:* +@read +@write +@string +@hash +expire +ttl -@dangerous

# Can access session and user keys
# Can use common commands
# Cannot use dangerous commands (FLUSHDB, etc.)
```

### Example 3: Analytics User

```bash
# Create user for analytics/monitoring
ACL SETUSER analytics on >analyticspass ~* +@read +@slow +info +slowlog +client -@write -@admin

# Can read all data
# Can use monitoring commands
# Cannot modify data
# Cannot use admin commands
```

### Example 4: Queue Worker

```bash
# Create user for job queue processing
ACL SETUSER queue_worker on >queuepass ~queue:* +@read +@write +@list +@blocking -@admin

# Can access queue keys only
# Can use list operations (LPUSH, RPOP, BLPOP, etc.)
# Can use blocking operations
# Cannot use admin commands
```

### Example 5: Admin User

```bash
# Create admin with full access
ACL SETUSER admin on >adminStrongPass123 ~* +@all

# Full access to all keys and commands
```

### Example 6: Multi-Tenant Application

```bash
# Create users for different tenants
ACL SETUSER tenant_a_user on >tenantApass ~tenant_a:* +@read +@write +@string +@hash -@admin
ACL SETUSER tenant_b_user on >tenantBpass ~tenant_b:* +@read +@write +@string +@hash -@admin

# Each tenant can only access their own data
```

---

## Command Categories

### Built-in Command Categories

```bash
# View all command categories
ACL CAT

# View commands in a category
ACL CAT read
ACL CAT write
ACL CAT admin
```

**Common categories:**
- `@read` - Read commands (GET, MGET, HGETALL, etc.)
- `@write` - Write commands (SET, HSET, LPUSH, etc.)
- `@admin` - Administrative commands (CONFIG, SHUTDOWN, ACL, etc.)
- `@dangerous` - Dangerous commands (FLUSHDB, FLUSHALL, KEYS, etc.)
- `@fast` - Fast O(1) commands
- `@slow` - Slow commands
- `@keyspace` - Keyspace commands
- `@string` - String commands
- `@hash` - Hash commands
- `@list` - List commands
- `@set` - Set commands
- `@sortedset` - Sorted set commands
- `@pubsub` - Pub/sub commands
- `@scripting` - Lua scripting commands
- `@transaction` - Transaction commands
- `@connection` - Connection commands

---

## Managing Users

### Modify Existing User

```bash
# Add permissions
ACL SETUSER alice +@hash +@set

# Remove permissions
ACL SETUSER alice -DEL -FLUSHDB

# Add key pattern
ACL SETUSER alice ~newpattern:*

# Change password
ACL SETUSER alice >newPassword456

# Disable user
ACL SETUSER alice off
```

### Delete User

```bash
ACL DELUSER alice
```

### Reset User Permissions

```bash
# Reset to default (no permissions)
ACL SETUSER bob reset
```

---

## ACL Configuration File

### Save ACL to File

```bash
# Save current ACL configuration
ACL SAVE
```

### Load ACL from File

Create `users.acl` file:

```acl
# users.acl

# Default user (disabled for security)
user default off

# Admin user
user admin on >adminPass123 ~* +@all

# Application users
user webapp on >webappPass456 ~session:* ~user:* ~cache:* +@read +@write +@string +@hash +expire +ttl -@admin -@dangerous

user analytics on >analyticsPass789 ~* +@read +info +slowlog +client -@write -@admin

# Queue worker
user queueworker on >queuePass321 ~queue:* +@list +@read +@write -@admin
```

**Configure Redis to use ACL file:**

```conf
# redis.conf
aclfile /etc/redis/users.acl
```

**Reload ACL from file:**

```bash
ACL LOAD
```

---

## Pub/Sub Security

### Control Channel Access

```bash
# Allow access to specific channels
ACL SETUSER subscriber on >subpass &news:* &updates:* +subscribe +psubscribe

# Allow publishing to specific channels
ACL SETUSER publisher on >pubpass &events:* +publish
```

### Example: Isolated Pub/Sub Users

```bash
# Subscriber can only receive messages
ACL SETUSER news_subscriber on >subpass ~* &news:* +subscribe +psubscribe -publish

# Publisher can only send messages
ACL SETUSER news_publisher on >pubpass ~* &news:* +publish -subscribe -psubscribe
```

---

## Encryption

### Encryption in Transit (TLS/SSL)

**Compile Redis with TLS support:**

```bash
make BUILD_TLS=yes
```

**Generate certificates:**

```bash
# Generate CA key and certificate
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt

# Generate server key and certificate
openssl genrsa -out redis.key 2048
openssl req -new -key redis.key -out redis.csr
openssl x509 -req -in redis.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out redis.crt -days 365 -sha256

# Generate client certificate (optional)
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365 -sha256
```

**Configure TLS in redis.conf:**

```conf
# Enable TLS
port 0
tls-port 6379

# Certificate files
tls-cert-file /path/to/redis.crt
tls-key-file /path/to/redis.key
tls-ca-cert-file /path/to/ca.crt

# Optional: Require client certificates
tls-auth-clients yes

# TLS protocols
tls-protocols "TLSv1.2 TLSv1.3"
```

**Connect with TLS:**

```bash
# redis-cli with TLS
redis-cli --tls \
  --cert /path/to/client.crt \
  --key /path/to/client.key \
  --cacert /path/to/ca.crt
```

**Application code with TLS:**

```python
# Python
import redis

r = redis.Redis(
    host='localhost',
    port=6379,
    password='myPassword',
    ssl=True,
    ssl_certfile='/path/to/client.crt',
    ssl_keyfile='/path/to/client.key',
    ssl_ca_certs='/path/to/ca.crt'
)
```

```javascript
// Node.js
const redis = require('redis');
const fs = require('fs');

const client = redis.createClient({
    host: 'localhost',
    port: 6379,
    password: 'myPassword',
    tls: {
        cert: fs.readFileSync('/path/to/client.crt'),
        key: fs.readFileSync('/path/to/client.key'),
        ca: [fs.readFileSync('/path/to/ca.crt')]
    }
});
```

---

## Network Security

### Bind to Specific Interface

```conf
# redis.conf

# Bind to localhost only (development)
bind 127.0.0.1

# Bind to specific IP
bind 192.168.1.100

# Bind to multiple interfaces
bind 127.0.0.1 192.168.1.100

# Bind to all interfaces (use with caution!)
bind 0.0.0.0
```

### Protected Mode

```conf
# redis.conf

# Enable protected mode (default)
# Prevents external connections when no password is set
protected-mode yes
```

### Firewall Rules

```bash
# Allow Redis port only from application servers
sudo ufw allow from 192.168.1.0/24 to any port 6379

# Block all other connections
sudo ufw deny 6379
```

---

## Rename Dangerous Commands

Rename or disable dangerous commands:

```conf
# redis.conf

# Disable commands
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
rename-command SHUTDOWN ""
rename-command KEYS ""

# Rename commands (security through obscurity)
rename-command CONFIG "b840fc02d524045429941cc15f59e41cb7be6c52"
```

**Access renamed command:**

```bash
# Instead of CONFIG GET
b840fc02d524045429941cc15f59e41cb7be6c52 GET maxmemory
```

---

## Monitoring and Auditing

### Monitor Commands

```bash
# Real-time command monitoring
MONITOR

# Output:
# 1614556800.123456 [0 127.0.0.1:52376] "GET" "key"
# 1614556801.234567 [0 127.0.0.1:52376] "SET" "key" "value"
```

### Slow Log

```bash
# View slow queries
SLOWLOG GET 10

# Configure slow log threshold (microseconds)
CONFIG SET slowlog-log-slower-than 10000

# Maximum slow log entries
CONFIG SET slowlog-max-len 128
```

### Client List

```bash
# List connected clients
CLIENT LIST

# Output includes:
# - addr: client address
# - name: client name
# - cmd: last command
# - user: authenticated user
```

### Track Client Connections

```bash
# Set client name for tracking
CLIENT SETNAME webapp_01

# Kill specific client
CLIENT KILL addr 192.168.1.100:52376

# Kill clients by user
CLIENT KILL user webapp skipme yes
```

---

## Security Best Practices

### 1. Always Use Authentication

```conf
# redis.conf
requirepass strongPassword123

# Or use ACL (preferred)
aclfile /etc/redis/users.acl
```

### 2. Disable Default User

```acl
# users.acl
user default off
```

### 3. Principle of Least Privilege

```bash
# Give only necessary permissions
ACL SETUSER webapp on >pass ~session:* ~user:* +@read +@write +@string +@hash -@admin
```

### 4. Use Strong Passwords

```bash
# Generate strong password
openssl rand -base64 32

# Set for user
ACL SETUSER alice >$(openssl rand -base64 32)
```

### 5. Enable TLS/SSL

```conf
tls-port 6379
tls-cert-file /path/to/redis.crt
tls-key-file /path/to/redis.key
```

### 6. Network Isolation

```conf
bind 127.0.0.1
protected-mode yes
```

### 7. Rename Dangerous Commands

```conf
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command DEBUG ""
```

### 8. Regular Backups

```bash
# Manual backup
SAVE

# Or use AOF persistence
```

### 9. Monitor Access

```bash
# Check who's connected
CLIENT LIST

# Review slow queries
SLOWLOG GET
```

### 10. Secure Connection Strings

```python
# Store credentials securely
import os

redis_password = os.environ.get('REDIS_PASSWORD')
r = redis.Redis(password=redis_password)
```

---

## Application Security Examples

### Python with ACL

```python
import redis
import os

# Connect as application user
r = redis.Redis(
    host='redis.example.com',
    port=6379,
    username='webapp',
    password=os.environ.get('REDIS_PASSWORD'),
    ssl=True,
    ssl_cert_reqs='required',
    ssl_ca_certs='/path/to/ca.crt'
)

# Use Redis
try:
    r.set('session:12345', '{"user_id": 1}')
    session = r.get('session:12345')
    print(session)
except redis.exceptions.AuthenticationError:
    print("Authentication failed")
except redis.exceptions.ResponseError as e:
    print(f"Permission denied: {e}")
```

### Node.js with ACL

```javascript
const redis = require('redis');
const fs = require('fs');

const client = redis.createClient({
    socket: {
        host: 'redis.example.com',
        port: 6379,
        tls: true,
        cert: fs.readFileSync('/path/to/client.crt'),
        key: fs.readFileSync('/path/to/client.key'),
        ca: [fs.readFileSync('/path/to/ca.crt')]
    },
    username: 'webapp',
    password: process.env.REDIS_PASSWORD
});

client.on('error', (err) => {
    console.error('Redis error:', err);
});

await client.connect();

try {
    await client.set('session:12345', JSON.stringify({user_id: 1}));
    const session = await client.get('session:12345');
    console.log(session);
} catch (error) {
    console.error('Redis operation failed:', error);
} finally {
    await client.quit();
}
```

---

## Common Security Scenarios

### Scenario 1: Multi-Tier Application

```bash
# Web tier - limited access
ACL SETUSER web_tier on >webpass ~session:* ~cache:* +@read +@write +@string +@hash +expire -@admin

# API tier - broader access
ACL SETUSER api_tier on >apipass ~* +@read +@write -@admin -@dangerous

# Admin tier - full access
ACL SETUSER admin_tier on >adminpass ~* +@all
```

### Scenario 2: Shared Redis Instance

```bash
# Service A - isolated keys
ACL SETUSER service_a on >passA ~service_a:* +@read +@write -@admin

# Service B - isolated keys
ACL SETUSER service_b on >passB ~service_b:* +@read +@write -@admin

# Each service can only access their own namespace
```

### Scenario 3: Read Replicas

```bash
# Primary - read/write
ACL SETUSER primary_app on >primarypass ~* +@read +@write -@admin

# Replica - read only
ACL SETUSER replica_app on >replicapass ~* +@read -@write -@admin
```

---

## Security Checklist

- [ ] Enable authentication (password or ACL)
- [ ] Use ACL with multiple users (Redis 6.0+)
- [ ] Disable or rename dangerous commands
- [ ] Enable TLS/SSL encryption
- [ ] Bind to specific network interfaces
- [ ] Enable protected mode
- [ ] Use firewall rules to restrict access
- [ ] Store passwords securely (environment variables, secrets manager)
- [ ] Implement least privilege access
- [ ] Disable default user in production
- [ ] Regular security audits
- [ ] Monitor client connections
- [ ] Enable persistence (RDB/AOF) for backups
- [ ] Keep Redis updated with security patches
- [ ] Use strong passwords (generated, not manual)

---

## Troubleshooting Access Issues

### Check Authentication

```bash
# Test connection with password
redis-cli -a myPassword ping

# Check current user
AUTH username password
ACL WHOAMI
```

### Check User Permissions

```bash
# View user details
ACL GETUSER username

# Test specific command
AUTH username password
GET somekey
# If fails: check key pattern and command permissions
```

### Debug ACL Errors

```bash
# View ACL log (recent violations)
ACL LOG 10

# Output shows:
# - Which user attempted action
# - Which command was denied
# - Which key was involved
# - Reason for denial
```

### Reset Locked Account

```bash
# Re-enable user
ACL SETUSER username on

# Reset permissions
ACL SETUSER username reset
ACL SETUSER username on >newpass ~* +@all
```

---

## Production Deployment Example

**redis.conf:**

```conf
# Bind to private network
bind 10.0.1.5

# Disable protected mode (we have strict network rules)
protected-mode no

# Use ACL file
aclfile /etc/redis/users.acl

# Enable TLS
port 0
tls-port 6379
tls-cert-file /etc/redis/certs/redis.crt
tls-key-file /etc/redis/certs/redis.key
tls-ca-cert-file /etc/redis/certs/ca.crt
tls-auth-clients yes

# Rename dangerous commands
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
rename-command DEBUG ""

# Enable persistence
save 900 1
save 300 10
save 60 10000

appendonly yes
appendfilename "appendonly.aof"
```

**users.acl:**

```acl
user default off

user admin on >$(ADMIN_PASS) ~* +@all

user webapp on >$(WEBAPP_PASS) ~session:* ~user:* ~cache:* +@read +@write +@string +@hash +@list +expire +ttl -@admin -@dangerous

user analytics on >$(ANALYTICS_PASS) ~* +@read +info +slowlog -@write -@admin
```

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Redis Access Control and Security
