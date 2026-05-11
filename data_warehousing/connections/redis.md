# Author: Víctor Barceló

# Connecting to Redis

## Overview

Redis listens on port **6379** by default. Drivers use the **RESP** (Redis Serialization Protocol) over TCP — a lightweight text-based protocol. By default Redis has no authentication; in secured deployments a password (`requirepass`) is configured.

Connection URI format:

```
redis://[:password@]host[:port][/db-index]
redis://username:password@host:port/db    # ACL-based auth (Redis 6+)
```

---

## Prerequisites

### Python — redis-py

```bash
pip install redis
```

### Java — Jedis

Add to `pom.xml` (Maven):

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>5.1.3</version>
</dependency>
```

Add to `build.gradle` (Gradle):

```groovy
implementation 'redis.clients:jedis:5.1.3'
```

### C++ — hiredis

On Debian/Ubuntu:

```bash
sudo apt install libhiredis-dev
```

On macOS:

```bash
brew install hiredis
```

Or build from source:

```bash
git clone https://github.com/redis/hiredis.git
cd hiredis && make && sudo make install
```

---

## Python Example

See the full working script: [scripts/redis/redis_example.py](scripts/redis/redis_example.py)

### Run

```bash
export REDIS_PASSWORD="your_password"   # omit if no auth configured
python redis_example.py
```

---

## Java Example

See the full working script: [scripts/redis/RedisExample.java](scripts/redis/RedisExample.java)

### Compile and Run

```bash
mvn compile exec:java -Dexec.mainClass="RedisExample"
# Or:
REDIS_PASSWORD=your_password java -jar target/app.jar
```

---

## C++ Example

See the full working script: [scripts/redis/redis_example.cpp](scripts/redis/redis_example.cpp)

### Compile and Run

```bash
g++ -std=c++17 -o redis_example redis_example.cpp -lhiredis
export REDIS_PASSWORD="your_password"   # omit if no auth configured
./redis_example
```

---

## Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `Connection refused on 6379` | Redis not running | `sudo systemctl start redis`; verify with `redis-cli ping` |
| `NOAUTH Authentication required` | Server requires password but none provided | Set `REDIS_PASSWORD` env var |
| `WRONGPASS invalid username-password pair` | Wrong password | Check `requirepass` in `/etc/redis/redis.conf` |
| `MOVED` error | Redis Cluster redirect | Use a cluster-aware client (redis-py's `RedisCluster`, Jedis `JedisCluster`) |
| Keys disappear unexpectedly | TTL expired | Check if `EXPIRE` was set unintentionally; use `TTL key` to inspect |
| `max number of clients reached` | Connection pool not reused | Use a connection pool rather than opening a new connection per operation |
