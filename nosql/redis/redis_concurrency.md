# Redis - Concurrency Control

## Overview

Redis uses a single-threaded event loop model for command execution, which provides inherent atomicity for individual commands. However, understanding how to handle concurrent access patterns is crucial for building robust Redis applications.

---

## Single-Threaded Architecture

### How Redis Handles Concurrency

Redis processes commands one at a time in a single thread:

```
Client 1: SET counter 1      ─┐
Client 2: GET counter         ─┼──> Redis processes sequentially
Client 3: INCR counter        ─┘     (one command at a time)
```

**Benefits:**
- No race conditions for single commands
- No need for locks within Redis
- Predictable behavior
- Commands are atomic

**Limitations:**
- Long-running commands block other clients
- Complex operations need special handling

---

## Atomic Operations

### Single Command Atomicity

Every Redis command is atomic:

```bash
# Atomic increment
INCR counter
# Always thread-safe, no race conditions

# Atomic set if not exists
SETNX key "value"
# Either succeeds or fails atomically

# Atomic list operations
LPUSH queue "item"
RPOP queue
```

### Compound Operations

Multiple commands are **not** atomic by default:

```bash
# NOT ATOMIC - race condition possible
GET counter          # Read: 10
# Another client increments here
SET counter 11       # Write: overwrites other client's increment

# ATOMIC - proper way
INCR counter         # Atomic read-modify-write
```

---

## Optimistic Locking with WATCH

### The WATCH Command

WATCH implements optimistic concurrency control:

```bash
# Client 1
WATCH balance:user123
GET balance:user123           # Returns 1000

# Meanwhile, Client 2 modifies the key
SET balance:user123 900       # Changed by another client

# Back to Client 1
MULTI
SET balance:user123 500       # Try to update
EXEC                          # Returns (nil) - transaction aborted

# Transaction was aborted because watched key changed
```

### Complete Example: Transfer Money

```python
import redis

r = redis.Redis()

def transfer_money(from_account, to_account, amount, max_retries=3):
    for attempt in range(max_retries):
        try:
            # Watch both accounts
            pipe = r.pipeline()
            pipe.watch(f'balance:{from_account}', f'balance:{to_account}')
            
            # Get current balances
            from_balance = float(r.get(f'balance:{from_account}') or 0)
            to_balance = float(r.get(f'balance:{to_account}') or 0)
            
            # Validate
            if from_balance < amount:
                pipe.unwatch()
                raise ValueError("Insufficient funds")
            
            # Execute transaction
            pipe.multi()
            pipe.set(f'balance:{from_account}', from_balance - amount)
            pipe.set(f'balance:{to_account}', to_balance + amount)
            pipe.execute()
            
            print(f"Transfer successful on attempt {attempt + 1}")
            return True
            
        except redis.WatchError:
            print(f"Conflict detected, retrying... (attempt {attempt + 1})")
            continue
    
    raise Exception("Transfer failed after max retries")

# Usage
transfer_money('alice', 'bob', 100)
```

### Node.js Example

```javascript
const redis = require('redis');
const client = redis.createClient();

async function transferMoney(fromAccount, toAccount, amount, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      await client.watch(`balance:${fromAccount}`, `balance:${toAccount}`);
      
      const fromBalance = parseFloat(await client.get(`balance:${fromAccount}`)) || 0;
      const toBalance = parseFloat(await client.get(`balance:${toAccount}`)) || 0;
      
      if (fromBalance < amount) {
        await client.unwatch();
        throw new Error('Insufficient funds');
      }
      
      const multi = client.multi();
      multi.set(`balance:${fromAccount}`, fromBalance - amount);
      multi.set(`balance:${toAccount}`, toBalance + amount);
      
      await multi.exec();
      console.log(`Transfer successful on attempt ${attempt + 1}`);
      return true;
      
    } catch (error) {
      if (error.message === 'EXECABORT') {
        console.log(`Conflict detected, retrying... (attempt ${attempt + 1})`);
        continue;
      }
      throw error;
    }
  }
  
  throw new Error('Transfer failed after max retries');
}
```

---

## Transactions with MULTI/EXEC

### Basic Transactions

Commands between MULTI and EXEC are queued and executed atomically:

```bash
MULTI
INCR counter
INCR counter
INCR counter
EXEC
# All three increments execute atomically
# Returns array: [1, 2, 3]
```

### Transaction with Error Handling

```bash
MULTI
SET key1 "value1"
INCR key1              # Error: value is not an integer
SET key2 "value2"
EXEC
# Returns errors for invalid commands
# Other commands still execute
```

### Discard Transactions

```bash
MULTI
SET key1 "value1"
SET key2 "value2"
DISCARD                # Cancel transaction
# Nothing is executed
```

---

## Lua Scripting for Atomicity

### Why Use Lua Scripts

Lua scripts execute atomically in Redis:

```lua
-- Atomic increment with limit
local current = redis.call('GET', KEYS[1])
if current and tonumber(current) >= tonumber(ARGV[1]) then
    return 0  -- Limit reached
end
redis.call('INCR', KEYS[1])
return 1  -- Success
```

### Example: Rate Limiter

```lua
-- rate_limiter.lua
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])

local current = redis.call('INCR', key)

if current == 1 then
    redis.call('EXPIRE', key, window)
end

if current > limit then
    return 0  -- Rate limit exceeded
end

return 1  -- Request allowed
```

**Using the script:**

```python
import redis

r = redis.Redis()

# Load script
rate_limiter_script = r.register_script("""
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])

local current = redis.call('INCR', key)

if current == 1 then
    redis.call('EXPIRE', key, window)
end

if current > limit then
    return 0
end

return 1
""")

# Execute script
user_id = "user:123"
allowed = rate_limiter_script(keys=[f'rate_limit:{user_id}'], args=[100, 60])

if allowed:
    print("Request allowed")
else:
    print("Rate limit exceeded")
```

### Example: Conditional Update

```lua
-- conditional_update.lua
local key = KEYS[1]
local expected_version = ARGV[1]
local new_value = ARGV[2]
local new_version = ARGV[3]

local current = redis.call('HGETALL', key)
local version_index = nil

-- Find version in hash
for i = 1, #current, 2 do
    if current[i] == 'version' then
        version_index = i + 1
        break
    end
end

if version_index and current[version_index] ~= expected_version then
    return 0  -- Version mismatch
end

redis.call('HSET', key, 'value', new_value, 'version', new_version)
return 1  -- Success
```

### Example: Distributed Lock

```lua
-- acquire_lock.lua
local key = KEYS[1]
local token = ARGV[1]
local ttl = ARGV[2]

local result = redis.call('SET', key, token, 'NX', 'EX', ttl)

if result then
    return 1
else
    return 0
end
```

---

## Distributed Locking

### Simple Lock with SETNX

```python
import redis
import time
import uuid

r = redis.Redis()

class RedisLock:
    def __init__(self, key, ttl=10):
        self.key = f'lock:{key}'
        self.token = str(uuid.uuid4())
        self.ttl = ttl
    
    def acquire(self, timeout=10):
        """Try to acquire lock with timeout"""
        end_time = time.time() + timeout
        
        while time.time() < end_time:
            # Try to set lock with NX (not exists) and EX (expiration)
            if r.set(self.key, self.token, nx=True, ex=self.ttl):
                return True
            
            # Wait before retry
            time.sleep(0.01)
        
        return False
    
    def release(self):
        """Release lock only if we own it"""
        # Lua script for atomic check-and-delete
        release_script = """
        if redis.call("GET", KEYS[1]) == ARGV[1] then
            return redis.call("DEL", KEYS[1])
        else
            return 0
        end
        """
        script = r.register_script(release_script)
        return script(keys=[self.key], args=[self.token])

# Usage
lock = RedisLock('resource:123', ttl=30)

if lock.acquire(timeout=5):
    try:
        # Critical section
        print("Lock acquired, performing operation...")
        time.sleep(2)
    finally:
        lock.release()
        print("Lock released")
else:
    print("Could not acquire lock")
```

### Redlock Algorithm

For distributed Redis clusters, use Redlock:

```python
import redis
import time
import uuid

class Redlock:
    def __init__(self, redis_instances):
        self.redis_instances = redis_instances
        self.quorum = len(redis_instances) // 2 + 1
    
    def acquire(self, resource, ttl=10000):
        """Acquire lock across multiple Redis instances"""
        token = str(uuid.uuid4())
        start_time = int(time.time() * 1000)
        
        # Try to acquire lock on all instances
        locked = 0
        for instance in self.redis_instances:
            try:
                if instance.set(f'lock:{resource}', token, nx=True, px=ttl):
                    locked += 1
            except:
                pass
        
        # Check if we got quorum
        elapsed = int(time.time() * 1000) - start_time
        validity_time = ttl - elapsed - 100  # Drift compensation
        
        if locked >= self.quorum and validity_time > 0:
            return token, validity_time
        else:
            # Release locks if we didn't get quorum
            self.release(resource, token)
            return None, 0
    
    def release(self, resource, token):
        """Release lock on all instances"""
        release_script = """
        if redis.call("GET", KEYS[1]) == ARGV[1] then
            return redis.call("DEL", KEYS[1])
        else
            return 0
        end
        """
        
        for instance in self.redis_instances:
            try:
                script = instance.register_script(release_script)
                script(keys=[f'lock:{resource}'], args=[token])
            except:
                pass

# Usage with multiple Redis instances
redis1 = redis.Redis(host='redis1.example.com')
redis2 = redis.Redis(host='redis2.example.com')
redis3 = redis.Redis(host='redis3.example.com')

lock_manager = Redlock([redis1, redis2, redis3])

token, validity = lock_manager.acquire('shared_resource', ttl=30000)
if token:
    try:
        print(f"Lock acquired with validity {validity}ms")
        # Perform critical operation
    finally:
        lock_manager.release('shared_resource', token)
```

---

## Pipeline for Performance

### Reduce Network Round Trips

```python
import redis

r = redis.Redis()

# WITHOUT Pipeline - multiple round trips
for i in range(1000):
    r.set(f'key:{i}', i)
# 1000 network round trips

# WITH Pipeline - batched
pipe = r.pipeline()
for i in range(1000):
    pipe.set(f'key:{i}', i)
pipe.execute()
# 1 network round trip
```

### Pipeline vs Transaction

```python
# Pipeline (not atomic, just batched)
pipe = r.pipeline(transaction=False)
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
pipe.execute()
# Faster, but not atomic

# Transaction (atomic)
pipe = r.pipeline(transaction=True)
pipe.multi()
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
pipe.execute()
# Atomic, slightly slower
```

---

## Concurrency Patterns

### Pattern 1: Distributed Counter

```python
def increment_counter(key):
    """Thread-safe counter increment"""
    return r.incr(key)

# Parallel increments are safe
result = increment_counter('page_views')
print(f"Page views: {result}")
```

### Pattern 2: Unique Value Set

```python
def add_unique_value(set_key, value):
    """Add value atomically to set"""
    added = r.sadd(set_key, value)
    return added == 1

# Concurrent adds are handled atomically
if add_unique_value('unique_visitors', 'user123'):
    print("New visitor")
else:
    print("Returning visitor")
```

### Pattern 3: Work Queue

```python
def enqueue_job(queue, job_data):
    """Add job to queue"""
    r.rpush(queue, job_data)

def dequeue_job(queue, timeout=5):
    """Pop job from queue with timeout"""
    result = r.blpop(queue, timeout=timeout)
    if result:
        queue_name, job_data = result
        return job_data
    return None

# Producer
enqueue_job('jobs', '{"task": "send_email", "to": "user@example.com"}')

# Consumer (blocks until job available)
job = dequeue_job('jobs')
if job:
    process_job(job)
```

### Pattern 4: Rate Limiting (Sliding Window)

```python
import time

def rate_limit_check(user_id, limit=100, window=60):
    """Check if user is within rate limit"""
    key = f'rate_limit:{user_id}'
    now = time.time()
    
    # Lua script for atomic sliding window
    script = """
    local key = KEYS[1]
    local now = tonumber(ARGV[1])
    local window = tonumber(ARGV[2])
    local limit = tonumber(ARGV[3])
    
    -- Remove old entries
    redis.call('ZREMRANGEBYSCORE', key, 0, now - window)
    
    -- Count current entries
    local current = redis.call('ZCARD', key)
    
    if current < limit then
        redis.call('ZADD', key, now, now)
        redis.call('EXPIRE', key, window)
        return 1
    else
        return 0
    end
    """
    
    rate_limit = r.register_script(script)
    allowed = rate_limit(keys=[key], args=[now, window, limit])
    
    return allowed == 1

# Usage
if rate_limit_check('user123', limit=100, window=60):
    print("Request allowed")
else:
    print("Rate limit exceeded")
```

### Pattern 5: Leader Election

```python
import time
import uuid

class LeaderElection:
    def __init__(self, election_key, ttl=10):
        self.election_key = f'leader:{election_key}'
        self.node_id = str(uuid.uuid4())
        self.ttl = ttl
    
    def try_become_leader(self):
        """Try to become leader"""
        return r.set(self.election_key, self.node_id, nx=True, ex=self.ttl)
    
    def am_i_leader(self):
        """Check if this node is the leader"""
        current_leader = r.get(self.election_key)
        return current_leader and current_leader.decode() == self.node_id
    
    def renew_leadership(self):
        """Renew leadership if still leader"""
        script = """
        if redis.call("GET", KEYS[1]) == ARGV[1] then
            return redis.call("EXPIRE", KEYS[1], ARGV[2])
        else
            return 0
        end
        """
        renew = r.register_script(script)
        return renew(keys=[self.election_key], args=[self.node_id, self.ttl])

# Usage
election = LeaderElection('service_cluster', ttl=30)

if election.try_become_leader():
    print(f"I am the leader: {election.node_id}")
    
    # Perform leader duties
    while election.am_i_leader():
        # Do work
        time.sleep(5)
        # Renew leadership
        election.renew_leadership()
else:
    print("Another node is the leader")
```

---

## Handling Race Conditions

### Problem Example

```python
# INCORRECT - Race condition
balance = float(r.get('balance:user123'))
if balance >= 100:
    r.set('balance:user123', balance - 100)
    # Another process might have changed balance here
```

### Solution 1: Atomic Commands

```python
# Use DECRBY instead
remaining = r.decrby('balance:user123', 100)
if remaining < 0:
    r.incrby('balance:user123', 100)  # Rollback
    print("Insufficient funds")
```

### Solution 2: WATCH/MULTI

```python
def decrement_with_check(key, amount):
    pipe = r.pipeline()
    
    while True:
        try:
            pipe.watch(key)
            balance = float(pipe.get(key) or 0)
            
            if balance < amount:
                pipe.unwatch()
                return False
            
            pipe.multi()
            pipe.set(key, balance - amount)
            pipe.execute()
            return True
            
        except redis.WatchError:
            continue
```

### Solution 3: Lua Script

```lua
-- decrement_with_check.lua
local key = KEYS[1]
local amount = tonumber(ARGV[1])
local balance = tonumber(redis.call('GET', key) or 0)

if balance < amount then
    return 0
end

redis.call('SET', key, balance - amount)
return 1
```

---

## Performance Considerations

### 1. Use Pipelining for Bulk Operations

```python
# Slow
for i in range(10000):
    r.set(f'key:{i}', i)

# Fast
pipe = r.pipeline()
for i in range(10000):
    pipe.set(f'key:{i}', i)
pipe.execute()
```

### 2. Avoid Long-Running Operations

```python
# BAD - blocks Redis
r.keys('user:*')  # Scans all keys

# GOOD - non-blocking scan
cursor = 0
while True:
    cursor, keys = r.scan(cursor, match='user:*', count=100)
    for key in keys:
        process(key)
    if cursor == 0:
        break
```

### 3. Use Connection Pooling

```python
pool = redis.ConnectionPool(
    host='localhost',
    port=6379,
    max_connections=50
)

r = redis.Redis(connection_pool=pool)
```

---

## Best Practices

1. **Use Atomic Commands**: Prefer `INCR`, `HINCRBY`, `SADD` over read-modify-write
2. **Implement Retry Logic**: Handle `WatchError` and transient failures
3. **Set Expiration on Locks**: Always use TTL to prevent deadlocks
4. **Use Lua for Complex Operations**: Ensure atomicity for multi-step logic
5. **Avoid Long Transactions**: Keep transactions small and fast
6. **Use Pipelining**: Batch commands to reduce network overhead
7. **Monitor Slow Commands**: Use `SLOWLOG` to identify problematic queries
8. **Connection Pooling**: Reuse connections for better performance

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Redis Concurrency Control
