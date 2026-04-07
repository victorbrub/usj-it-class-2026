# Redis - Introduction and Guide

## What is Redis?

**Redis** (Remote Dictionary Server) is an in-memory data structure store used as a database, cache, message broker, and streaming engine. It's one of the most popular key-value NoSQL databases, known for its exceptional performance and versatility.

### Key Features

- **In-Memory Storage**: Blazing fast performance (sub-millisecond latency)
- **Data Structures**: Strings, Lists, Sets, Sorted Sets, Hashes, Bitmaps, HyperLogLogs, Streams
- **Persistence Options**: RDB snapshots and AOF (Append-Only File)
- **Replication**: Master-slave replication
- **High Availability**: Redis Sentinel for automatic failover
- **Clustering**: Horizontal scaling with Redis Cluster
- **Pub/Sub**: Message patterns for real-time communication
- **Lua Scripting**: Server-side scripting
- **Transactions**: MULTI/EXEC for atomic operations
- **TTL Support**: Automatic key expiration

---

## Redis Data Structures

### 1. Strings

The most basic data type, storing text or binary data up to 512MB.

**Use Cases**: Caching, session storage, counters, distributed locks

**Commands**:
```bash
# Set and get
SET key "value"
GET key

# Set with expiration (seconds)
SETEX key 3600 "value"

# Set if not exists
SETNX key "value"

# Set multiple
MSET key1 "value1" key2 "value2"

# Get multiple
MGET key1 key2

# Append to value
APPEND key " additional text"

# String length
STRLEN key

# Numeric operations
SET counter 0
INCR counter          # Increment by 1
INCRBY counter 5      # Increment by 5
DECR counter          # Decrement by 1
DECRBY counter 3      # Decrement by 3
INCRBYFLOAT price 2.5 # Increment float

# Get and set atomically
GETSET key "new value"

# Bit operations
SETBIT key 0 1
GETBIT key 0
BITCOUNT key
```

**Examples**:
```bash
# Caching user session
SET session:12345 "user_data_json" EX 3600

# Page view counter
INCR page:homepage:views

# Rate limiting
SET rate:user123:api 0 EX 60
INCR rate:user123:api
```

### 2. Lists

Ordered collections of strings, implemented as linked lists.

**Use Cases**: Queues, stacks, activity feeds, recent items

**Commands**:
```bash
# Push to list
LPUSH list "item1"              # Push left (beginning)
RPUSH list "item2"              # Push right (end)
LPUSH list "a" "b" "c"          # Push multiple

# Pop from list
LPOP list                        # Pop left
RPOP list                        # Pop right

# Blocking pop (wait for item)
BLPOP list 0                    # Block forever
BRPOP list 5                    # Block 5 seconds

# Get elements
LRANGE list 0 -1                # Get all elements
LRANGE list 0 9                 # Get first 10 elements
LINDEX list 0                   # Get by index
LLEN list                       # Get length

# Set element at index
LSET list 0 "new value"

# Insert before/after
LINSERT list BEFORE "pivot" "new item"
LINSERT list AFTER "pivot" "new item"

# Remove elements
LREM list 1 "value"             # Remove first occurrence
LTRIM list 0 99                 # Keep only first 100 items

# Move between lists
RPOPLPUSH source destination    # Atomic pop and push
```

**Examples**:
```bash
# Task queue (FIFO)
LPUSH queue:tasks '{"task":"send_email","to":"user@example.com"}'
RPOP queue:tasks

# Recent activity feed (limited to 100)
LPUSH feed:user123 "Posted a photo"
LTRIM feed:user123 0 99

# Stack (LIFO)
LPUSH stack "item1"
LPOP stack
```

### 3. Sets

Unordered collections of unique strings.

**Use Cases**: Unique visitors, tags, social relationships, recommendations

**Commands**:
```bash
# Add members
SADD set "member1"
SADD set "member1" "member2" "member3"

# Check membership
SISMEMBER set "member1"         # Returns 1 if exists

# Get all members
SMEMBERS set

# Get count
SCARD set

# Remove members
SREM set "member1"

# Pop random member
SPOP set
SPOP set 3                      # Pop 3 random members

# Get random member (without removing)
SRANDMEMBER set
SRANDMEMBER set 5               # Get 5 random members

# Set operations
SUNION set1 set2                # Union
SINTER set1 set2                # Intersection
SDIFF set1 set2                 # Difference
SUNIONSTORE dest set1 set2      # Store result
SINTERSTORE dest set1 set2
SDIFFSTORE dest set1 set2

# Move between sets
SMOVE source dest "member"
```

**Examples**:
```bash
# Unique visitors
SADD visitors:2024-03-01 "user123"
SCARD visitors:2024-03-01

# Tags for a post
SADD post:1:tags "redis" "database" "nosql"
SMEMBERS post:1:tags

# Friend relationships
SADD user:alice:friends "bob" "charlie"
SADD user:bob:friends "alice" "diana"
SINTER user:alice:friends user:bob:friends  # Mutual friends

# Online users
SADD online:users "user123"
SREM online:users "user123"
```

### 4. Sorted Sets (ZSets)

Ordered collections where each member has an associated score.

**Use Cases**: Leaderboards, priority queues, time-series data, search autocomplete

**Commands**:
```bash
# Add members with scores
ZADD zset 100 "player1"
ZADD zset 85 "player2" 92 "player3"

# Add with options
ZADD zset NX 100 "player1"      # Only if not exists
ZADD zset XX 100 "player1"      # Only if exists
ZADD zset GT 100 "player1"      # Only if new score is greater

# Get score
ZSCORE zset "player1"

# Get rank (0-based)
ZRANK zset "player1"            # Ascending order
ZREVRANK zset "player1"         # Descending order

# Increment score
ZINCRBY zset 10 "player1"

# Get count
ZCARD zset

# Count by score range
ZCOUNT zset 80 100

# Get range
ZRANGE zset 0 9                 # Top 10 (ascending)
ZREVRANGE zset 0 9              # Top 10 (descending)
ZRANGE zset 0 9 WITHSCORES      # Include scores

# Get by score
ZRANGEBYSCORE zset 80 100
ZRANGEBYSCORE zset -inf +inf    # All members
ZRANGEBYSCORE zset 80 100 LIMIT 0 10  # Pagination

# Remove members
ZREM zset "player1"

# Remove by rank
ZREMRANGEBYRANK zset 0 9        # Remove bottom 10

# Remove by score
ZREMRANGEBYSCORE zset 0 50      # Remove low scores

# Pop (Redis 5.0+)
ZPOPMIN zset                    # Pop lowest score
ZPOPMAX zset                    # Pop highest score

# Set operations
ZUNIONSTORE dest 2 zset1 zset2  # Union with sum of scores
ZINTERSTORE dest 2 zset1 zset2  # Intersection
```

**Examples**:
```bash
# Leaderboard
ZADD leaderboard:game1 1500 "player1" 1200 "player2"
ZREVRANGE leaderboard:game1 0 9 WITHSCORES  # Top 10

# Priority queue with timestamps
ZADD queue:priority 1678901234 "task1" 1678901500 "task2"
ZPOPMIN queue:priority  # Get earliest task

# Trending posts (time decay)
ZADD trending:posts 100 "post1"
ZINCRBY trending:posts 1 "post1"  # Upvote

# Auto-complete with scores
ZADD autocomplete 0 "redis"
ZRANGEBYLEX autocomplete "[red" "[red\xff"  # Find "red*"
```

### 5. Hashes

Maps between string fields and string values, ideal for representing objects.

**Use Cases**: User profiles, session data, configuration, shopping carts

**Commands**:
```bash
# Set fields
HSET hash field "value"
HSET hash field1 "value1" field2 "value2"  # Multiple fields

# Set if not exists
HSETNX hash field "value"

# Get field
HGET hash field

# Get all fields and values
HGETALL hash

# Get multiple fields
HMGET hash field1 field2

# Check field exists
HEXISTS hash field

# Get all fields/values
HKEYS hash                      # All field names
HVALS hash                      # All values

# Count fields
HLEN hash

# Delete fields
HDEL hash field1 field2

# Increment
HINCRBY hash field 5
HINCRBYFLOAT hash field 2.5

# String length of field value
HSTRLEN hash field

# Scan through large hashes
HSCAN hash 0 MATCH "user*" COUNT 100
```

**Examples**:
```bash
# User profile
HSET user:1000 name "Alice" email "alice@example.com" age 30
HGET user:1000 name
HGETALL user:1000

# Session data
HSET session:abc123 userId "1000" loginTime "1678901234"
HGET session:abc123 userId

# Shopping cart
HSET cart:user123 product:101 2      # 2 items of product 101
HINCRBY cart:user123 product:101 1   # Add one more
HGETALL cart:user123

# Configuration
HSET config:app debug "false" timeout 30 maxConnections 100
HGET config:app timeout
```

### 6. Bitmaps

Not a distinct data type but string operations treating the string as an array of bits.

**Use Cases**: Feature flags, real-time analytics, presence tracking

**Commands**:
```bash
# Set bit
SETBIT key 0 1

# Get bit
GETBIT key 0

# Count set bits
BITCOUNT key

# Bit operations
BITOP AND dest key1 key2
BITOP OR dest key1 key2
BITOP XOR dest key1 key2
BITOP NOT dest key

# Find first bit
BITPOS key 1                    # First set bit
BITPOS key 0                    # First unset bit
```

**Examples**:
```bash
# Daily active users (user ID as bit position)
SETBIT active:2024-03-01 123 1  # User 123 was active
BITCOUNT active:2024-03-01      # Count active users

# Weekly active users
BITOP OR weekly:2024-w10 active:2024-03-01 active:2024-03-02 ... active:2024-03-07
BITCOUNT weekly:2024-w10
```

### 7. HyperLogLog

Probabilistic data structure for counting unique elements.

**Use Cases**: Unique visitor counting with minimal memory

**Commands**:
```bash
# Add elements
PFADD key "element1"
PFADD key "element1" "element2" "element3"

# Get count (approximate)
PFCOUNT key

# Merge HyperLogLogs
PFMERGE dest key1 key2
```

**Examples**:
```bash
# Unique visitors per day
PFADD visitors:2024-03-01 "user123" "user456"
PFCOUNT visitors:2024-03-01

# Unique visitors per month
PFMERGE visitors:2024-03 visitors:2024-03-01 visitors:2024-03-02 ...
PFCOUNT visitors:2024-03
```

### 8. Streams

Append-only log data structure for message streaming.

**Use Cases**: Event sourcing, messaging, activity feeds, sensor data

**Commands**:
```bash
# Add to stream
XADD stream * field1 value1 field2 value2  # * = auto-generate ID
XADD stream 1678901234567-0 field value    # Explicit ID

# Read from stream
XREAD COUNT 10 STREAMS stream 0         # Read from beginning
XREAD COUNT 10 STREAMS stream $         # Read new messages
XREAD BLOCK 0 STREAMS stream $          # Block for new messages

# Get stream length
XLEN stream

# Get range
XRANGE stream - +                       # All messages
XRANGE stream 1678901234567 1678901244567  # Time range
XRANGE stream - + COUNT 10              # First 10

# Consumer groups
XGROUP CREATE stream group1 0           # Create group
XREADGROUP GROUP group1 consumer1 STREAMS stream >
XACK stream group1 message-id           # Acknowledge message

# Delete messages
XDEL stream message-id
XTRIM stream MAXLEN 1000                # Keep only latest 1000
```

**Examples**:
```bash
# Event log
XADD events * type "user_login" userId "123" timestamp "1678901234"

# Sensor data
XADD sensor:temp * value 23.5 unit "celsius"
XRANGE sensor:temp - + COUNT 100
```

---

## Advanced Features

### Transactions

Execute multiple commands atomically:

```bash
MULTI
SET key1 "value1"
SET key2 "value2"
INCR counter
EXEC

# Discard transaction
MULTI
SET key "value"
DISCARD
```

### Pipelining

Send multiple commands without waiting for responses:

```python
# Python example
pipe = redis.pipeline()
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
pipe.get('key1')
results = pipe.execute()
```

### Pub/Sub

Message broadcasting:

```bash
# Subscribe to channels
SUBSCRIBE channel1 channel2

# Pattern subscribe
PSUBSCRIBE news:*

# Publish message
PUBLISH channel1 "Hello World"

# List channels
PUBSUB CHANNELS
PUBSUB NUMSUB channel1
```

### Lua Scripting

Execute custom logic on server:

```bash
EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 mykey myvalue

# Load script
SCRIPT LOAD "return redis.call('GET', KEYS[1])"
# Returns SHA1 hash

# Execute loaded script
EVALSHA <sha1> 1 mykey
```

---

## Key Management

### Key Operations

```bash
# Check if key exists
EXISTS key

# Get key type
TYPE key

# Delete keys
DEL key1 key2 key3

# Rename key
RENAME oldkey newkey
RENAMENX oldkey newkey          # Only if newkey doesn't exist

# Set expiration
EXPIRE key 3600                 # Seconds
EXPIREAT key 1678901234         # Unix timestamp
PEXPIRE key 3600000             # Milliseconds

# Check TTL
TTL key                         # Seconds remaining
PTTL key                        # Milliseconds remaining

# Remove expiration
PERSIST key

# Find keys (use with caution in production!)
KEYS *                          # All keys
KEYS user:*                     # Pattern matching

# Scan keys (better than KEYS)
SCAN 0 MATCH user:* COUNT 100

# Random key
RANDOMKEY

# Dump and restore
DUMP key                        # Serialize
RESTORE key 0 <serialized-value>
```

### Key Patterns

```bash
# Namespacing
user:1000:profile
user:1000:posts
session:abc123
cache:product:101

# Versioning
user:1000:v2
config:app:v3

# Hierarchical
analytics:2024:03:01:pageviews
analytics:2024:03:02:pageviews
```

---

## Persistence

### RDB (Redis Database)

Point-in-time snapshots:

```bash
# Manual snapshot
SAVE                            # Blocking
BGSAVE                          # Background (non-blocking)

# Configuration (redis.conf)
save 900 1                      # After 900s if 1 key changed
save 300 10                     # After 300s if 10 keys changed
save 60 10000                   # After 60s if 10000 keys changed
```

### AOF (Append-Only File)

Log of all write operations:

```bash
# Configuration (redis.conf)
appendonly yes
appendfsync always              # Fsync after every command (slow, safest)
appendfsync everysec            # Fsync every second (default)
appendfsync no                  # Let OS decide when to fsync (fast, least safe)

# Manual rewrite
BGREWRITEAOF
```

---

## Replication

Master-slave replication for read scaling:

```bash
# On slave
REPLICAOF master-host master-port
REPLICAOF NO ONE                # Promote to master

# Info
INFO replication
```

---

## Common Patterns

### 1. Caching

```bash
# Cache aside pattern
GET user:1000:profile
# If miss:
#   - Query database
#   - SET user:1000:profile <data> EX 3600
```

### 2. Rate Limiting

```bash
# Fixed window
SET rate:user123:2024-03-01-14 0 EX 3600
INCR rate:user123:2024-03-01-14
# If count > limit: deny

# Sliding window log
ZADD rate:user123 <timestamp> <request-id>
ZREMRANGEBYSCORE rate:user123 0 <timestamp-window>
ZCOUNT rate:user123 -inf +inf
# If count > limit: deny
```

### 3. Distributed Locks

```bash
# Acquire lock
SET lock:resource "lock-id" NX EX 30
# If success: hold lock
# If fail: already locked

# Release lock
# Use Lua script to check lock-id before deleting
```

### 4. Session Management

```bash
# Store session
HSET session:abc123 userId "1000" loginTime "1678901234"
EXPIRE session:abc123 3600

# Extend session
GET session:abc123:lastActivity
SET session:abc123:lastActivity <timestamp>
EXPIRE session:abc123 3600
```

### 5. Real-time Analytics

```bash
# Increment counters
INCR stats:pageviews:2024-03-01
HINCRBY stats:pageviews:2024-03-01 "/home" 1

# Store in sorted set
ZINCRBY trending:pages 1 "/products"
```

### 6. Leaderboards

```bash
# Update score
ZADD leaderboard <score> <player-id>
ZINCRBY leaderboard 10 <player-id>

# Get rank
ZREVRANK leaderboard <player-id>

# Get top players
ZREVRANGE leaderboard 0 9 WITHSCORES
```

---

## Performance Tips

### 1. Use Appropriate Data Structures

- Strings for simple values
- Hashes for objects
- Sets for unique collections
- Sorted sets for ranked data
- Lists for ordered sequences

### 2. Avoid Large Keys

- Keep values under 512MB
- Split large collections
- Use SCAN instead of KEYS
- Paginate large sorted sets

### 3. Use Pipelining

- Batch commands
- Reduce network round trips
- Especially important for high latency connections

### 4. Set Expiration

- Use TTL to auto-cleanup
- Prevent memory bloat
- Set reasonable expiration times

### 5. Monitor Performance

```bash
# Slow log
SLOWLOG GET 10
CONFIG SET slowlog-log-slower-than 10000  # Microseconds

# Stats
INFO stats
INFO memory
INFO commandstats

# Monitor commands
MONITOR  # Real-time command log (heavy!)
```

---

## Redis CLI Tips

```bash
# Connect
redis-cli
redis-cli -h host -p port -a password

# Execute command
redis-cli GET key

# Pipe commands
echo "SET key value" | redis-cli

# Execute file
cat commands.txt | redis-cli

# Interactive mode features
redis-cli> help @string     # Help for string commands
redis-cli> help ZADD        # Help for specific command
```

---

## Redis in Different Languages

### Python (redis-py)

```python
import redis

r = redis.Redis(host='localhost', port=6379, db=0)

# Strings
r.set('key', 'value')
value = r.get('key')

# Lists
r.lpush('list', 'item1')
items = r.lrange('list', 0, -1)

# Sets
r.sadd('set', 'member1')
members = r.smembers('set')

# Hashes
r.hset('hash', 'field', 'value')
all_data = r.hgetall('hash')

# Pipelining
pipe = r.pipeline()
pipe.set('key1', 'value1')
pipe.get('key1')
results = pipe.execute()
```

### Node.js (ioredis)

```javascript
const Redis = require('ioredis');
const redis = new Redis();

// Strings
await redis.set('key', 'value');
const value = await redis.get('key');

// Lists
await redis.lpush('list', 'item1');
const items = await redis.lrange('list', 0, -1);

// Hashes
await redis.hset('hash', 'field', 'value');
const data = await redis.hgetall('hash');

// Pipeline
const pipeline = redis.pipeline();
pipeline.set('key1', 'value1');
pipeline.get('key1');
const results = await pipeline.exec();
```

---

## Use Cases Summary

| Use Case | Data Structure | Example |
|----------|---------------|---------|
| Caching | String | Page cache, API responses |
| Session Storage | Hash | User session data |
| Rate Limiting | String/Sorted Set | API rate limits |
| Real-time Analytics | String/Hash | Page view counters |
| Leaderboards | Sorted Set | Game scores |
| Queue | List | Task queues |
| Pub/Sub | Pub/Sub | Real-time notifications |
| Unique Counters | Set/HyperLogLog | Unique visitors |
| Time-series | Sorted Set/Stream | Sensor data |
| Social Features | Set | Friends, followers |
| Auto-complete | Sorted Set | Search suggestions |
| Distributed Locks | String | Resource locking |

---

## Resources

- **Official Documentation**: [redis.io/docs](https://redis.io/docs/)
- **Redis Commands**: [redis.io/commands](https://redis.io/commands/)
- **Try Redis Online**: [try.redis.io](https://try.redis.io/)
- **Redis Stack**: Extended Redis with modules
- **Redis Cloud**: Managed Redis service (free tier available)

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Redis Key-Value Store
