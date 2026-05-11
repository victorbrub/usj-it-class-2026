# Author: Víctor Barceló

# Connecting to Neo4j

## Overview

Neo4j exposes two ports by default:

| Port | Protocol | Purpose |
|------|----------|---------|
| **7474** | HTTP | Neo4j Browser (web UI), REST API |
| **7687** | Bolt | Binary driver protocol — use this for all application connections |

All official drivers connect via **Bolt on port 7687**. The connection URI format is:

```
bolt://host:7687        # single instance
neo4j://host:7687       # routing protocol (cluster-aware)
```

---

## Prerequisites

### Python — neo4j (official driver)

```bash
pip install neo4j
```

### Java — Neo4j Java Driver

Add to `pom.xml` (Maven):

```xml
<dependency>
    <groupId>org.neo4j.driver</groupId>
    <artifactId>neo4j-java-driver</artifactId>
    <version>5.20.0</version>
</dependency>
```

Add to `build.gradle` (Gradle):

```groovy
implementation 'org.neo4j.driver:neo4j-java-driver:5.20.0'
```

### C++ — libneo4j-client

On Debian/Ubuntu:

```bash
sudo apt install libneo4j-client-dev
```

Or build from source:

```bash
git clone https://github.com/cleishm/libneo4j-client.git
cd libneo4j-client
./autogen.sh
./configure --disable-tools
make && sudo make install
```

> Note: `libneo4j-client` is a community C library. It covers the Bolt protocol but is not an official Neo4j product. For production C++ projects, consider wrapping the HTTP API instead (see the Common Issues section).

---

## Python Example

See the full working script: [scripts/neo4j/neo4j_example.py](scripts/neo4j/neo4j_example.py)

### Run

```bash
export NEO4J_PASSWORD="your_password"
python neo4j_example.py
```

---

## Java Example

See the full working script: [scripts/neo4j/Neo4jExample.java](scripts/neo4j/Neo4jExample.java)

### Compile and Run

```bash
mvn compile exec:java -Dexec.mainClass="Neo4jExample"
# Or:
NEO4J_PASSWORD=your_password java -jar target/app.jar
```

---

## C++ Example

The `libneo4j-client` library provides a C API for connecting to Neo4j via the Bolt protocol. The C++ example wraps it with RAII helpers.

See the full working script: [scripts/neo4j/neo4j_example.cpp](scripts/neo4j/neo4j_example.cpp)

### Compile and Run

```bash
g++ -std=c++17 -o neo4j_example neo4j_example.cpp -lneo4j-client
export NEO4J_PASSWORD="your_password"
./neo4j_example
```

---

## Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `ServiceUnavailable` | Neo4j not running | `sudo systemctl start neo4j`; check port 7687 |
| `AuthenticationException` | Wrong password | Default user is `neo4j`; password is set on first login |
| `ClientError: Neo.ClientError.Security.Unauthorized` | Token expired or wrong creds | Re-authenticate; check `NEO4J_USER`/`NEO4J_PASSWORD` |
| `Unable to acquire connection` | Max connection pool exhausted | Increase pool size or close sessions promptly |
| C++ `neo4j_connect` returns null | Library not installed or wrong URL | Verify `libneo4j-client` is installed; check URL format |
| First login fails in Neo4j 5+ | Must change default password | Open `http://localhost:7474` in browser and change password |
