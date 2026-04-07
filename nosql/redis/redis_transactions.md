# Redis - Transactions

## Overview

Redis transactions allow you to execute a group of commands atomically. Understanding Redis transactions is important because they work differently from traditional ACID databases - they provide atomicity and isolation but with some limitations.

---

## Transaction Basics

### MULTI/EXEC/DISCARD

The core of Redis transactions:

```bash
# Start transaction
MULTI
OK

# Queue commands
SET account:alice 1000
QUEUED

SET account:bob 2000
QUEUED

INCR total_accounts
QUEUED

# Execute all commands atomically
EXEC
1) OK
2) OK
3) (integer) 1
```

### Discarding Transactions

```bash
MULTI
SET key1 "value1"
QUEUED

SET key2 "value2"
QUEUED

# Cancel the transaction
DISCARD
OK

# Nothing was executed

GET key1
(nil)
```

---

## Transaction Properties

### Atomicity

All commands execute as a single unit:

```bash
MULTI
DECRBY account:alice 100
INCRBY account:bob 100
EXEC

# Either both execute or neither
# No partial execution
```

### Isolation

Commands in a transaction don't see intermediate results:

```bash
# Client 1
MULTI
SET counter 1
INCR counter
GET counter
EXEC
# Returns: [OK, 2, "2"]
# Each command operates on result of previous

# Client 2 (concurrent)
GET counter
# Sees either old value or final value after EXEC
# Never sees intermediate states
```

### No Rollback

Redis does not rollback on errors (intentional design):

```bash
MULTI
SET key1 "value1"
INCR key1             # Error: value is not an integer
SET key2 "value2"
EXEC
# Returns: [OK, (error) ERR value is not an integer, OK]
# key1 and key2 are both set despite the error
```

---

## Using Transactions in Applications

### Python (redis-py)

```python
import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Basic transaction
def transfer_money(from_account, to_account, amount):
    pipe = r.pipeline()
    
    # Start transaction
    pipe.multi()
    
    # Queue commands
    pipe.decrby(f'balance:{from_account}', amount)
    pipe.incrby(f'balance:{to_account}', amount)
    
    # Execute atomically
    results = pipe.execute()
    
    return results

# Usage
try:
    result = transfer_money('alice', 'bob', 100)
    print(f"Transfer successful: {result}")
except redis.RedisError as e:
    print(f"Transfer failed: {e}")
```

### Node.js

```javascript
const redis = require('redis');
const client = redis.createClient();

async function transferMoney(fromAccount, toAccount, amount) {
  const multi = client.multi();
  
  multi.decrBy(`balance:${fromAccount}`, amount);
  multi.incrBy(`balance:${toAccount}`, amount);
  
  try {
    const results = await multi.exec();
    console.log('Transfer successful:', results);
    return results;
  } catch (error) {
    console.error('Transfer failed:', error);
    throw error;
  }
}

// Usage
await transferMoney('alice', 'bob', 100);
```

### Java (Jedis)

```java
import redis.clients.jedis.Jedis;
import redis.clients.jedis.Transaction;

public class RedisTransactionExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        
        String fromAccount = "balance:alice";
        String toAccount = "balance:bob";
        int amount = 100;
        
        Transaction tx = jedis.multi();
        
        tx.decrBy(fromAccount, amount);
        tx.incrBy(toAccount, amount);
        
        tx.exec();
        
        jedis.close();
    }
}
```

---

## Optimistic Locking with WATCH

### The WATCH Command

WATCH provides check-and-set (CAS) behavior:

```bash
# Monitor keys for changes
WATCH balance:alice
OK

# Read current value
GET balance:alice
"1000"

# If balance:alice changes here, transaction aborts

# Start transaction
MULTI
OK

DECRBY balance:alice 100
QUEUED

# Execute transaction
EXEC
# Returns (nil) if balance:alice was modified
# Returns [900] if successful
```

### Complete Transfer Example

```python
import redis
import time

r = redis.Redis(decode_responses=True)

def safe_transfer(from_account, to_account, amount, max_retries=3):
    """Transfer money with optimistic locking"""
    for attempt in range(max_retries):
        try:
            pipe = r.pipeline()
            
            # Watch both accounts
            pipe.watch(f'balance:{from_account}', f'balance:{to_account}')
            
            # Read current balances
            from_balance = float(r.get(f'balance:{from_account}') or 0)
            to_balance = float(r.get(f'balance:{to_account}') or 0)
            
            # Validate business logic
            if from_balance < amount:
                pipe.unwatch()
                raise ValueError("Insufficient funds")
            
            # Calculate new balances
            new_from_balance = from_balance - amount
            new_to_balance = to_balance + amount
            
            # Execute transaction
            pipe.multi()
            pipe.set(f'balance:{from_account}', new_from_balance)
            pipe.set(f'balance:{to_account}', new_to_balance)
            
            # This will fail if watched keys changed
            result = pipe.execute()
            
            print(f"Transfer successful on attempt {attempt + 1}")
            return result
            
        except redis.WatchError:
            print(f"Concurrent modification detected, retrying... (attempt {attempt + 1})")
            time.sleep(0.01)  # Brief backoff
            continue
    
    raise Exception("Transfer failed after maximum retries")

# Initialize accounts
r.set('balance:alice', 1000)
r.set('balance:bob', 500)

# Perform transfer
try:
    safe_transfer('alice', 'bob', 100)
    print(f"Alice: {r.get('balance:alice')}")
    print(f"Bob: {r.get('balance:bob')}")
except Exception as e:
    print(f"Error: {e}")
```

### WATCH with Multiple Keys

```python
def update_user_and_stats(user_id, new_email):
    pipe = r.pipeline()
    
    # Watch user and stats
    pipe.watch(f'user:{user_id}', 'stats:total_users')
    
    # Check if user exists
    user = r.hgetall(f'user:{user_id}')
    if not user:
        pipe.unwatch()
        raise ValueError("User not found")
    
    # Check if email changed
    old_email = user.get('email', '')
    email_changed = old_email != new_email
    
    # Start transaction
    pipe.multi()
    pipe.hset(f'user:{user_id}', 'email', new_email)
    
    if email_changed:
        pipe.incr('stats:email_changes')
    
    result = pipe.execute()
    return result
```

---

## Transaction Patterns

### Pattern 1: Atomic Counter with Metadata

```python
def increment_with_timestamp(counter_key):
    """Increment counter and update timestamp atomically"""
    pipe = r.pipeline()
    pipe.multi()
    
    pipe.incr(counter_key)
    pipe.set(f'{counter_key}:last_updated', int(time.time()))
    
    results = pipe.execute()
    return results[0]  # Return new counter value
```

### Pattern 2: Create Entity with Relationships

```python
def create_user_with_profile(user_id, username, email, bio):
    """Create user and profile atomically"""
    pipe = r.pipeline()
    pipe.multi()
    
    # Create user hash
    pipe.hset(f'user:{user_id}', mapping={
        'username': username,
        'email': email,
        'created_at': int(time.time())
    })
    
    # Create profile hash
    pipe.hset(f'profile:{user_id}', mapping={
        'bio': bio
    })
    
    # Add to username index
    pipe.set(f'username:{username}', user_id)
    
    # Increment total users
    pipe.incr('stats:total_users')
    
    # Add to user list
    pipe.sadd('users:all', user_id)
    
    results = pipe.execute()
    return results
```

### Pattern 3: Atomic List Operations

```python
def move_item_between_lists(item, from_list, to_list):
    """Move item from one list to another atomically"""
    pipe = r.pipeline()
    pipe.multi()
    
    pipe.lrem(from_list, 1, item)  # Remove from source
    pipe.rpush(to_list, item)       # Add to destination
    
    results = pipe.execute()
    return results
```

### Pattern 4: Session Management

```python
import uuid

def create_session(user_id, ttl=3600):
    """Create session with automatic expiration"""
    session_id = str(uuid.uuid4())
    session_key = f'session:{session_id}'
    
    pipe = r.pipeline()
    pipe.multi()
    
    # Create session hash
    pipe.hset(session_key, mapping={
        'user_id': user_id,
        'created_at': int(time.time())
    })
    
    # Set expiration
    pipe.expire(session_key, ttl)
    
    # Add to user's sessions
    pipe.sadd(f'user:{user_id}:sessions', session_id)
    
    pipe.execute()
    
    return session_id
```

### Pattern 5: Inventory Management

```python
def reserve_item(item_id, user_id, quantity=1):
    """Reserve inventory item atomically"""
    pipe = r.pipeline()
    
    # Watch inventory
    pipe.watch(f'inventory:{item_id}')
    
    # Check availability
    available = int(r.get(f'inventory:{item_id}') or 0)
    
    if available < quantity:
        pipe.unwatch()
        return False, "Insufficient inventory"
    
    # Create reservation
    reservation_id = str(uuid.uuid4())
    
    pipe.multi()
    
    # Decrease inventory
    pipe.decrby(f'inventory:{item_id}', quantity)
    
    # Create reservation
    pipe.hset(f'reservation:{reservation_id}', mapping={
        'item_id': item_id,
        'user_id': user_id,
        'quantity': quantity,
        'timestamp': int(time.time())
    })
    
    # Set expiration on reservation (auto-release after 15 minutes)
    pipe.expire(f'reservation:{reservation_id}', 900)
    
    try:
        pipe.execute()
        return True, reservation_id
    except redis.WatchError:
        return False, "Concurrent reservation conflict"
```

---

## Lua Scripts as Transactions

### Why Use Lua Scripts

Lua scripts are atomic and often better than MULTI/EXEC:

**Advantages:**
- Truly atomic (script runs as single operation)
- Can contain logic (if/else, loops)
- Reduce network round trips
- Better performance

**MULTI/EXEC:**
```python
# Multiple round trips: WATCH, GET, MULTI, commands, EXEC
pipe.watch('key')
value = r.get('key')
# Process value...
pipe.multi()
pipe.set('key', new_value)
pipe.execute()
```

**Lua Script:**
```python
# Single round trip, atomic execution
script = """
local value = redis.call('GET', KEYS[1])
-- Process value...
redis.call('SET', KEYS[1], new_value)
return new_value
"""
result = r.eval(script, 1, 'key')
```

### Example: Conditional Increment

```lua
-- increment_if_below_limit.lua
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local increment = tonumber(ARGV[2])

local current = tonumber(redis.call('GET', key) or 0)

if current + increment <= limit then
    return redis.call('INCRBY', key, increment)
else
    return -1  -- Limit would be exceeded
end
```

**Usage:**

```python
script = r.register_script("""
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local increment = tonumber(ARGV[2])

local current = tonumber(redis.call('GET', key) or 0)

if current + increment <= limit then
    return redis.call('INCRBY', key, increment)
else
    return -1
end
""")

# Execute script
result = script(keys=['counter'], args=[100, 5])

if result == -1:
    print("Limit exceeded")
else:
    print(f"New value: {result}")
```

### Example: Complex Business Logic

```lua
-- process_order.lua
local order_id = KEYS[1]
local product_id = ARGV[1]
local quantity = tonumber(ARGV[2])
local user_id = ARGV[3]

-- Check inventory
local inventory = tonumber(redis.call('GET', 'inventory:' .. product_id) or 0)

if inventory < quantity then
    return {err = 'insufficient_inventory'}
end

-- Check user credit
local credit = tonumber(redis.call('GET', 'credit:' .. user_id) or 0)
local price = tonumber(redis.call('GET', 'price:' .. product_id) or 0)
local total = price * quantity

if credit < total then
    return {err = 'insufficient_credit'}
end

-- Process order
redis.call('DECRBY', 'inventory:' .. product_id, quantity)
redis.call('DECRBY', 'credit:' .. user_id, total)

-- Create order
redis.call('HSET', 'order:' .. order_id,
    'product_id', product_id,
    'quantity', quantity,
    'user_id', user_id,
    'total', total,
    'timestamp', redis.call('TIME')[1]
)

-- Update stats
redis.call('INCR', 'stats:orders_total')
redis.call('INCRBY', 'stats:revenue_total', total)

return {ok = order_id}
```

---

## Error Handling

### Handling WATCH Errors

```python
def reliable_update(key, max_retries=5):
    """Update with automatic retry on conflicts"""
    for attempt in range(max_retries):
        try:
            pipe = r.pipeline()
            pipe.watch(key)
            
            current_value = r.get(key)
            new_value = process_value(current_value)
            
            pipe.multi()
            pipe.set(key, new_value)
            pipe.execute()
            
            return new_value
            
        except redis.WatchError:
            if attempt < max_retries - 1:
                time.sleep(0.01 * (2 ** attempt))  # Exponential backoff
                continue
            else:
                raise Exception("Max retries exceeded")
```

### Handling Command Errors

```python
def safe_transaction():
    try:
        pipe = r.pipeline()
        pipe.multi()
        
        pipe.set('key1', 'value1')
        pipe.incr('key1')  # This will error
        pipe.set('key2', 'value2')
        
        results = pipe.execute()
        
        # Check results for errors
        for i, result in enumerate(results):
            if isinstance(result, redis.ResponseError):
                print(f"Command {i} failed: {result}")
        
        return results
        
    except redis.RedisError as e:
        print(f"Transaction failed: {e}")
        return None
```

---

## Transaction vs Lua Script

### When to Use MULTI/EXEC

Use transactions when:
- Simple sequence of commands
- No conditional logic needed
- Need optimistic locking with WATCH
- Client-side validation required

```python
# Good use of MULTI/EXEC
pipe = r.pipeline()
pipe.multi()
pipe.set('user:123:name', 'Alice')
pipe.set('user:123:email', 'alice@example.com')
pipe.sadd('users:all', '123')
pipe.execute()
```

### When to Use Lua Scripts

Use Lua scripts when:
- Complex logic (if/else, loops)
- Need to inspect intermediate values
- Want true atomicity
- Performance critical (single round trip)

```python
# Good use of Lua script
script = """
local balance = tonumber(redis.call('GET', KEYS[1]) or 0)

if balance >= tonumber(ARGV[1]) then
    redis.call('DECRBY', KEYS[1], ARGV[1])
    return {ok = 'success', new_balance = balance - ARGV[1]}
else
    return {err = 'insufficient_funds', balance = balance}
end
"""

result = r.eval(script, 1, 'balance:alice', 100)
```

---

## Performance Considerations

### Pipeline Transactions

```python
# Batch multiple transactions with pipelining
pipe = r.pipeline()

for user_id in user_ids:
    pipe.multi()
    pipe.hset(f'user:{user_id}', 'processed', 'true')
    pipe.incr('stats:processed_users')

# Execute all transactions
results = pipe.execute()
```

### Avoid Large Transactions

```python
# BAD - Large transaction blocks Redis
pipe = r.pipeline()
pipe.multi()
for i in range(100000):
    pipe.set(f'key:{i}', i)
pipe.execute()

# GOOD - Batch in smaller transactions
batch_size = 1000
for i in range(0, 100000, batch_size):
    pipe = r.pipeline()
    pipe.multi()
    for j in range(i, min(i + batch_size, 100000)):
        pipe.set(f'key:{j}', j)
    pipe.execute()
```

---

## Best Practices

1. **Keep Transactions Short**: Minimize commands in transaction to reduce blocking
2. **Use WATCH for CAS**: Implement optimistic locking for conditional updates
3. **Implement Retry Logic**: Handle WatchError with exponential backoff
4. **Validate Before Transaction**: Check preconditions before MULTI
5. **Use Lua for Complex Logic**: Prefer Lua scripts over multiple WATCH/MULTI attempts
6. **Don't Mix Pipeline and Transaction**: Use pipeline(transaction=True) or pipeline(transaction=False)
7. **Handle Command Errors**: Check results array for errors after EXEC
8. **Monitor Performance**: Use SLOWLOG to identify slow transactions

---

## Transaction Limitations

### No Rollback on Error

```bash
MULTI
SET key1 "value"
INCR key1        # Error, but transaction continues
SET key2 "value"
EXEC
# key1 and key2 are both set
```

**Workaround**: Use Lua scripts which can return early on error

### No Nested Transactions

```python
# This doesn't work
pipe1 = r.pipeline()
pipe1.multi()

pipe2 = r.pipeline()
pipe2.multi()  # Can't nest transactions
```

### Watched Keys Reset on EXEC

```python
r.watch('key1')
# ... transaction ...
r.execute()
# Need to WATCH again for next transaction
```

---

## Comparison with Other Databases

### Redis vs SQL Transactions

| Feature | Redis | SQL |
|---------|-------|-----|
| Rollback | No | Yes |
| Isolation Levels | Read Committed (WATCH) | Multiple levels |
| Nested Transactions | No | Yes (savepoints) |
| Cross-Key Operations | Limited | Full support |
| Performance | Very fast | Slower |
| Use Case | Simple atomic ops | Complex business logic |

### When NOT to Use Redis Transactions

- Complex multi-step business logic with many rollback scenarios
- Need for nested transactions
- Require different isolation levels
- Cross-database consistency (use dedicated distributed transaction coordinator)

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: Redis Transactions
