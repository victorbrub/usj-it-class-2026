# Redis - Practical Exercises

Complete these exercises to practice Redis commands and data structures. Work through them in order to build understanding progressively.

---

## Exercise 1: String Operations Basics

**Objective**: Practice basic string commands.

**Tasks**:

1. Set a key called "greeting" with value "Hello Redis"
2. Get the value of "greeting"
3. Set a key "counter" with value 0
4. Increment "counter" by 1
5. Increment "counter" by 10
6. Decrement "counter" by 3
7. Set a key "price" to 19.99 and increment by 5.50
8. Set "username" to "alice" and append " smith"
9. Get the length of "username"
10. Set "session:abc123" with value "user_data" that expires in 60 seconds
11. Check the TTL (time to live) of "session:abc123"
12. Set multiple keys at once: user1="Alice", user2="Bob", user3="Charlie"
13. Get all three users with one command

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 2: String Operations Advanced

**Objective**: Practice advanced string operations and patterns.

**Tasks**:

1. Implement a page view counter:
   - Create key "views:homepage"
   - Increment it 5 times
   - Get the current value

2. Implement rate limiting:
   - Create key "rate:user123:api" that expires in 60 seconds
   - Set initial value to 0
   - Increment 10 times
   - Check if value is over 5 (simulating rate limit)

3. Atomic operations:
   - Set key "status" to "offline"
   - Use GETSET to change it to "online" and return old value

4. Multiple keys pattern:
   - Set "config:db:host", "config:db:port", "config:db:name"
   - Get all config values at once

5. Bit operations:
   - Set bit 0 to 1 in key "flags"
   - Set bit 5 to 1 in key "flags"
   - Count the number of set bits
   - Get specific bits

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 3: List Operations

**Objective**: Practice Redis lists.

**Tasks**:

1. Create a task queue "queue:tasks":
   - Push 5 tasks to the left: "task1", "task2", "task3", "task4", "task5"
   - Get all tasks
   - Pop task from the right (FIFO queue)
   - Check remaining tasks

2. Create a stack "stack:operations":
   - Push items: "open", "read", "close"
   - Pop from left (LIFO stack)

3. Activity feed:
   - Create "feed:user123"
   - Add 10 activities to the left
   - Trim to keep only the 5 most recent
   - Get all activities

4. Range operations:
   - Get the first 3 items
   - Get the last 3 items
   - Get items at indices 1, 3, 5

5. List length and existence:
   - Count items in your list
   - Get item at index 0
   - Set item at index 2 to new value

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 4: Set Operations

**Objective**: Practice Redis sets and set operations.

**Tasks**:

1. Create user tags:
   - Add tags to "user:alice:tags": "python", "redis", "database"
   - Add tags to "user:bob:tags": "redis", "javascript", "docker"
   - Check if "python" is in Alice's tags
   - Get all of Alice's tags
   - Count Alice's tags

2. Set operations:
   - Find common tags between Alice and Bob (intersection)
   - Find all unique tags (union)
   - Find tags Alice has but Bob doesn't (difference)

3. Online users:
   - Add users to "online:users": "user1", "user2", "user3"
   - Check if "user2" is online
   - Remove "user1" from online users
   - Get count of online users

4. Random operations:
   - Get 2 random tags from Alice's tags (without removing)
   - Pop one random tag from Bob's tags (remove it)

5. Move operation:
   - Create "set1" and "set2"
   - Move an element from set1 to set2

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 5: Sorted Set Operations

**Objective**: Practice sorted sets for rankings and leaderboards.

**Tasks**:

1. Create a game leaderboard "leaderboard:game1":
   - Add players with scores: Alice=100, Bob=95, Charlie=110, Diana=88, Eve=105
   - Get all players sorted by score (ascending)
   - Get all players sorted by score (descending) with scores
   - Get top 3 players

2. Rank operations:
   - Get Alice's rank (position)
   - Get Bob's score
   - Increment Charlie's score by 5
   - Get Charlie's new rank

3. Range queries:
   - Get all players with scores between 90 and 110
   - Get players with scores above 100
   - Count how many players have scores above 95

4. Remove operations:
   - Remove the player with the lowest score
   - Remove all players with scores below 90

5. Leaderboard pagination:
   - Get players ranked 2-4 (with scores)
   - Implement "show next 5 players" starting from rank 5

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 6: Hash Operations

**Objective**: Practice Redis hashes for object storage.

**Tasks**:

1. Create user profile "user:1000":
   - Set fields: name="Alice Johnson", email="alice@example.com", age=30, city="Boston"
   - Get the name field
   - Get all fields and values
   - Get name and email fields only

2. Update operations:
   - Update age to 31
   - Add new field phone="555-1234"
   - Increment age by 1
   - Check if email field exists

3. Shopping cart "cart:user123":
   - Add items: product:101=2, product:102=1, product:103=5
   - Get quantity of product:101
   - Increment product:101 quantity by 1
   - Get all cart items
   - Delete product:102 from cart

4. Session data "session:abc123":
   - Store: userId=1000, loginTime=1678901234, lastActivity=1678905000
   - Update lastActivity
   - Get all session data
   - Delete the session

5. Configuration object:
   - Create "config:app" with multiple settings
   - Get all keys (field names)
   - Get all values
   - Count number of fields

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 7: Expiration and TTL

**Objective**: Practice key expiration and time-to-live.

**Tasks**:

1. Set keys with expiration:
   - Set "temp1" with 60 second expiration
   - Set "temp2" with 120 second expiration
   - Check TTL for both keys

2. Expire existing keys:
   - Create key "session:xyz"
   - Set it to expire in 300 seconds
   - Check TTL
   - Update expiration to 600 seconds

3. Expire at timestamp:
   - Create key "event:registration"
   - Set it to expire at specific Unix timestamp
   - Check TTL

4. Persist (remove expiration):
   - Create key with expiration
   - Remove expiration using PERSIST
   - Verify it no longer has TTL

5. Expiration patterns:
   - Create cache key with 5 minute expiration
   - Create session key with 1 hour expiration
   - Create temporary lock with 30 second expiration

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 8: Key Management

**Objective**: Practice key operations and patterns.

**Tasks**:

1. Key existence and type:
   - Create keys of different types (string, list, set, hash)
   - Check if each key exists
   - Get the type of each key

2. Key patterns:
   - Create keys following pattern: user:1000:profile, user:1000:posts, user:1001:profile
   - Use SCAN to find all user:*:profile keys
   - Count how many keys match the pattern

3. Rename operations:
   - Create key "oldname"
   - Rename to "newname"
   - Try RENAMENX (rename if new name doesn't exist)

4. Delete operations:
   - Create 5 keys
   - Delete 3 keys with one command
   - Verify deletion

5. Random and dump:
   - Get a random key
   - Dump a key value (serialize it)

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 9: Transactions

**Objective**: Practice atomic operations with MULTI/EXEC.

**Tasks**:

1. Simple transaction:
   - Start transaction
   - Set key1="value1"
   - Set key2="value2"
   - Increment counter
   - Execute transaction

2. Bank transfer simulation:
   - Set account:alice=1000
   - Set account:bob=500
   - Use transaction to:
     - Decrease Alice's balance by 100
     - Increase Bob's balance by 100
   - Verify final balances

3. Discarded transaction:
   - Start transaction
   - Set some keys
   - DISCARD the transaction
   - Verify keys were not set

4. Shopping cart checkout:
   - Use transaction to:
     - Get cart items
     - Create order
     - Clear cart
     - Increment order counter

5. Atomic counter update:
   - Use transaction to increment multiple counters atomically

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 10: Pub/Sub Messaging

**Objective**: Practice publish/subscribe pattern.

**Tasks**:

Note: You'll need two Redis CLI sessions for these exercises.

1. Simple pub/sub:
   - Terminal 1: Subscribe to channel "news"
   - Terminal 2: Publish message to "news"

2. Multiple channels:
   - Subscribe to "sports" and "weather"
   - Publish to both channels

3. Pattern subscription:
   - Subscribe to pattern "news:*"
   - Publish to "news:tech", "news:sports", "news:world"

4. Channel information:
   - List all active channels
   - Count subscribers for a channel
   - Check patterns being subscribed to

5. Real-world scenario:
   - Create channels for different log levels: "log:error", "log:warn", "log:info"
   - Subscribe to "log:*"
   - Publish different log messages

**Your Solution**:
```bash
# Terminal 1 commands:

# Terminal 2 commands:

```

---

## Exercise 11: Bitmaps and HyperLogLog

**Objective**: Practice space-efficient data structures.

**Tasks**:

1. Daily active users with bitmap:
   - Create "active:2024-03-01"
   - Set bit for user IDs: 1, 5, 10, 15, 100
   - Count active users
   - Check if user 5 was active
   - Check if user 7 was active

2. Weekly active users:
   - Create bitmaps for 7 days
   - Use BITOP OR to combine them
   - Count weekly active users

3. User feature flags:
   - Create bitmap for user features
   - Bit 0: isPremium
   - Bit 1: hasNotifications
   - Bit 2: isDarkMode
   - Set flags for a user
   - Check individual flags

4. HyperLogLog for unique visitors:
   - Create HLL "visitors:homepage"
   - Add 100 user IDs (simulate visits)
   - Get approximate count
   - Add more IDs and check count

5. Merge HyperLogLogs:
   - Create HLL for different pages
   - Merge them to get unique visitors across all pages

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 12: Real-World Caching

**Objective**: Implement caching patterns.

**Tasks**:

1. Basic cache:
   - Simulate database data for user:1000
   - Cache it in Redis with 5-minute expiration
   - Retrieve from cache
   - Implement cache-aside pattern logic (pseudocode)

2. Cache invalidation:
   - Set cache for multiple users
   - Implement pattern to invalidate specific user cache
   - Implement pattern to invalidate all user caches

3. Cache warming:
   - Create script to pre-populate cache with frequently accessed data
   - Set appropriate TTLs for different data types

4. Cache key naming:
   - Design key naming scheme for:
     - User profiles
     - Product details
     - Search results
     - API responses

5. Cache statistics:
   - Track cache hits and misses using counters
   - Calculate hit ratio

**Your Solution**:
```bash
# Write your Redis commands and pseudocode here
```

---

## Exercise 13: Rate Limiting Implementation

**Objective**: Implement various rate limiting strategies.

**Tasks**:

1. Fixed window rate limiting:
   - User can make 10 requests per minute
   - Use key pattern: rate:user:{userId}:{minute}
   - Implement check and increment logic

2. Sliding window with sorted set:
   - Add timestamp for each request to sorted set
   - Remove requests older than window
   - Count requests in current window
   - Allow or deny based on count

3. Token bucket:
   - Initialize bucket with tokens
   - Consume token on request
   - Refill tokens at rate
   - Implement using hash with tokens and timestamp

4. Per-endpoint rate limiting:
   - Different limits for different API endpoints
   - key pattern: rate:user:{userId}:endpoint:{endpoint}

5. Distributed rate limiting:
   - Multiple servers using same Redis
   - Test concurrent access simulation

**Your Solution**:
```bash
# Write your Redis commands and logic here
```

---

## Exercise 14: Session Management

**Objective**: Build a session management system.

**Tasks**:

1. Create session:
   - Generate session ID
   - Store session data in hash: userId, loginTime, ipAddress
   - Set expiration to 30 minutes

2. Session validation:
   - Check if session exists
   - Get session data
   - Extend session expiration on activity

3. Session tracking:
   - Keep set of active sessions per user
   - Allow logout from all devices

4. Session metadata:
   - Track: userAgent, lastActivity, pageViews
   - Increment pageViews on each request

5. Session cleanup:
   - List all sessions
   - Remove expired sessions
   - Force logout (delete session)

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 15: Leaderboard System

**Objective**: Build a complete leaderboard system.

**Tasks**:

1. Basic leaderboard:
   - Create leaderboard for game scores
   - Add 10 players with scores
   - Get top 10 players
   - Get player's rank
   - Get player's score

2. Multiple leaderboards:
   - Daily leaderboard
   - Weekly leaderboard
   - All-time leaderboard
   - Update all when score changes

3. Around-player leaderboard:
   - Get 5 players above and 5 below a specific player
   - Show player's ranking context

4. Percentile calculation:
   - Calculate player's percentile ranking
   - Show "Top X%" message

5. Leaderboard with metadata:
   - Store player info in separate hashes
   - Combine leaderboard rank with player details
   - Return enriched leaderboard data

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 16: Real-Time Analytics

**Objective**: Implement real-time analytics counters.

**Tasks**:

1. Page view tracking:
   - Counter for total page views
   - Counter per page: views:{page}
   - Counter per hour: views:{page}:{hour}
   - Get hourly stats

2. Event tracking:
   - Track different events: clicks, shares, purchases
   - Store counts in hash: events:{date}
   - Increment specific event counters

3. Time-series data:
   - Store metrics in sorted set with timestamp as score
   - Query metrics for last hour
   - Query metrics for date range

4. Top content:
   - Track popular pages/articles in sorted set
   - Increment score on each view
   - Get trending content

5. User activity heatmap:
   - Track active users per hour of day
   - Use hash with hour as field
   - Visualize activity patterns (data structure design)

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 17: Social Features

**Objective**: Build social network features.

**Tasks**:

1. Follow system:
   - User A follows users: followers:{userA} set
   - Users following A: following:{userA} set
   - Add/remove followers
   - Count followers/following

2. Mutual followers:
   - Find users that both A and B follow
   - Use set intersection

3. Friend suggestions:
   - Find followers of followers
   - Exclude existing followers
   - Rank by number of mutual connections

4. Activity feed:
   - User posts stored in list
   - Combined feed from all followed users
   - Implement feed generation logic

5. Like system:
   - Users who liked a post: set
   - Posts liked by user: sorted set (score = timestamp)
   - Check if user liked post
   - Count total likes

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 18: Queue Systems

**Objective**: Implement different queue patterns.

**Tasks**:

1. Simple FIFO queue:
   - Producer pushes tasks to list
   - Consumer pops tasks from list
   - Implement basic task queue

2. Priority queue:
   - Use sorted set with priority as score
   - Lower score = higher priority
   - Pop highest priority task

3. Delayed queue:
   - Use sorted set with execution time as score
   - Pop tasks that are ready (timestamp <= now)

4. Reliable queue:
   - Move task to processing list when popped
   - Acknowledge completion
   - Re-queue failed tasks

5. Multiple consumers:
   - Use blocking pop for multiple workers
   - Implement consumer group pattern

**Your Solution**:
```bash
# Write your Redis commands here
```

---

## Exercise 19: Distributed Locks

**Objective**: Implement distributed locking.

**Tasks**:

1. Basic lock:
   - Acquire lock with SET NX EX
   - Check if lock acquired
   - Release lock

2. Lock with unique token:
   - Use UUID as lock value
   - Only owner can release lock
   - Implement with Lua script

3. Lock timeout handling:
   - Set appropriate expiration
   - Auto-release if holder crashes

4. Lock extension:
   - Extend lock expiration if task not complete
   - Implement keep-alive pattern

5. Try-lock pattern:
   - Try to acquire lock
   - If fails, don't wait
   - If succeeds, execute critical section

**Your Solution**:
```bash
# Write your Redis commands here
# Include Lua script for safe lock release
```

---

## Exercise 20: Data Modeling Challenge

**Objective**: Design complete data models for applications.

**Scenario 1: E-commerce Cart and Checkout**

Design and implement:
- Shopping cart (items, quantities, prices)
- Product inventory tracking
- Order placement (atomic)
- Purchase history

**Scenario 2: Chat Application**

Design and implement:
- User online/offline status
- Message delivery
- Unread message counts
- Chat room members
- Message history (limited)

**Scenario 3: URL Shortener**

Design and implement:
- Short URL to long URL mapping
- Click tracking
- Expiration handling
- Popular URLs ranking

**Your Solution**:
```bash
# Choose one scenario and implement complete solution
# Include:
# - Data structure choices
# - Key naming patterns
# - All necessary commands
# - Sample data
```

---

## Exercise 21: Performance Optimization

**Objective**: Optimize Redis usage patterns.

**Tasks**:

1. Pipeline usage:
   - Set 100 keys without pipeline (measure)
   - Set 100 keys with pipeline (measure)
   - Compare performance (pseudocode)

2. Large collection handling:
   - Create large sorted set (10000 items)
   - Use ZSCAN to iterate instead of ZRANGE
   - Compare approaches

3. Memory optimization:
   - Use hashes for many small objects vs individual keys
   - Calculate memory savings

4. Avoid expensive operations:
   - Avoid KEYS in production (use SCAN)
   - Limit ZRANGE results
   - Use EXISTS before GET when appropriate

5. Connection pooling:
   - Design connection pool strategy (pseudocode)
   - Reuse connections
   - Handle connection failures

**Your Solution**:
```bash
# Write your optimization examples and measurements
```

---

## Exercise 22: Streams for Event Processing

**Objective**: Practice Redis Streams.

**Tasks**:

1. Basic stream operations:
   - Add events to stream
   - Read events
   - Get stream length

2. Range queries:
   - Read events in time range
   - Read last N events
   - Read first N events

3. Consumer groups:
   - Create consumer group
   - Multiple consumers reading from group
   - Acknowledge processed messages

4. Pending messages:
   - Check pending messages
   - Claim abandoned messages
   - Handle failures

5. Stream as event log:
   - Log application events
   - Implement event replay
   - Trim old events

**Your Solution**:
```bash
# Write your stream commands here
```

---

## Exercise 23: Geo-Spatial Data

**Objective**: Practice geospatial commands.

**Tasks**:

1. Add locations:
   - Add cities with coordinates to geo set
   - Add multiple locations at once

2. Distance calculation:
   - Calculate distance between two locations
   - Different units (m, km, mi)

3. Radius search:
   - Find locations within radius
   - Sort by distance
   - Get coordinates and distance

4. Geo hash:
   - Get geohash for location
   - Use for proximity grouping

5. Real-world application:
   - Restaurant finder
   - Store locations
   - Find nearest restaurants
   - Filter by distance

**Your Solution**:
```bash
# Write your geospatial commands here
```

---

## Exercise 24: Lua Scripting

**Objective**: Write and execute Lua scripts.

**Tasks**:

1. Simple script:
   - Write script to get and set atomically
   - Execute with EVAL

2. Conditional logic:
   - Script that only sets value if key doesn't exist
   - Return different values based on condition

3. Safe lock release:
```lua
if redis.call("GET", KEYS[1]) == ARGV[1] then
    return redis.call("DEL", KEYS[1])
else
    return 0
end
```

4. Batch operations:
   - Script that processes multiple keys
   - Atomic updates across keys

5. Load and execute:
   - Load script with SCRIPT LOAD
   - Execute with EVALSHA
   - Check if script is loaded

**Your Solution**:
```bash
# Write your Lua scripts here
```

---

## Exercise 25: Full Application - Blog Platform

**Objective**: Build a complete blog platform with Redis.

**Requirements**:

1. **User Management**:
   - User profiles (hash)
   - Login sessions
   - Online users (set)

2. **Posts**:
   - Post data (hash)
   - Post counter
   - User's posts (list/sorted set)

3. **Engagement**:
   - Post likes (set)
   - Post views (counter)
   - Comments (list/stream)

4. **Social**:
   - User followers
   - Post feed generation
   - Notifications

5. **Analytics**:
   - Popular posts (sorted set by views)
   - Trending tags
   - Daily active users
   - Post statistics

6. **Features to implement**:
   - Create user
   - Login/logout
   - Create post
   - Like/unlike post
   - Follow/unfollow user
   - Generate feed
   - Get trending posts
   - Search by tag
   - Analytics dashboard data

**Your Solution**:
```bash
# Design complete data model
# Implement all features
# Include key naming conventions
# Add sample data and queries
```

---

## Testing Your Solutions

For each exercise:

1. Open redis-cli or use Redis GUI tool
2. Execute your commands
3. Verify the output
4. Check data types with TYPE command
5. Check TTL where applicable
6. Clean up test data

**Useful debugging commands**:
```bash
TYPE key              # Check data type
TTL key               # Check expiration
EXISTS key            # Check if key exists
SCAN 0 MATCH pattern  # Find keys by pattern
INFO memory           # Memory usage
MONITOR               # Watch commands (dev only)
```

---

## Performance Measurement

Time your operations:
```bash
# Linux/Mac
time redis-cli << EOF
  # Your commands here
EOF

# Within redis-cli
redis-cli --latency
redis-cli --stat
```

---

**Estimated Time**: 8-10 hours for all exercises  
**Difficulty**: Beginner → Advanced  
**Prerequisites**: Redis installed locally or access to Redis Cloud  

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Redis Exercises
