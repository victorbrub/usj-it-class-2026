# Author: Víctor Barceló

# Connecting to Apache Cassandra

## Overview

Cassandra listens on port **9042** by default (native CQL binary protocol). The drivers communicate directly via this protocol — no HTTP layer is involved. All nodes in the cluster are peers; the driver connects to one or more **contact points** and discovers the rest automatically.

---

## Prerequisites

### Python — cassandra-driver

```bash
pip install cassandra-driver
```

For improved performance on Linux, install the optional C extensions:

```bash
pip install cassandra-driver[libev]
```

### Java — DataStax Java Driver

Add to `pom.xml` (Maven):

```xml
<dependency>
    <groupId>com.datastax.oss</groupId>
    <artifactId>java-driver-core</artifactId>
    <version>4.17.0</version>
</dependency>
```

Add to `build.gradle` (Gradle):

```groovy
implementation 'com.datastax.oss:java-driver-core:4.17.0'
```

### C++ — DataStax C++ Driver

On Debian/Ubuntu:

```bash
sudo apt install libuv1-dev libssl-dev
# Download the .deb package from https://github.com/datastax/cpp-driver/releases
sudo dpkg -i cassandra-cpp-driver_2.16.2-1_amd64.deb
sudo dpkg -i cassandra-cpp-driver-dev_2.16.2-1_amd64.deb
```

Or build from source:

```bash
git clone https://github.com/datastax/cpp-driver.git
cd cpp-driver && mkdir build && cd build
cmake .. && make && sudo make install
```

---

## Python Example

See the full working script: [scripts/cassandra/cassandra_example.py](scripts/cassandra/cassandra_example.py)

### Run

```bash
export CASS_PASSWORD="cassandra"
python cassandra_example.py
```

---

## Java Example

See the full working script: [scripts/cassandra/CassandraExample.java](scripts/cassandra/CassandraExample.java)

### Compile and Run

```bash
# Using Maven
mvn compile exec:java -Dexec.mainClass="CassandraExample"
# Or with a fat jar after 'mvn package'
CASS_PASSWORD=cassandra java -jar target/app.jar
```

---

## C++ Example

See the full working script: [scripts/cassandra/cassandra_example.cpp](scripts/cassandra/cassandra_example.cpp)

### Compile and Run

```bash
g++ -std=c++17 -o cassandra_example cassandra_example.cpp -lcassandra
export CASS_PASSWORD="cassandra"
./cassandra_example
```

---

## Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `NoHostAvailable` | Cassandra not running or wrong IP | `sudo systemctl start cassandra`; verify contact point |
| `AuthenticationFailed` | Wrong credentials | Default credentials are `cassandra`/`cassandra`; check `cassandra.yaml` |
| `InvalidQuery: Keyspace does not exist` | Keyspace not created | Run the `CREATE KEYSPACE` statement first |
| Driver returns `0 rows` | Wrong data center name | Check `nodetool status` and set `local_dc` to match |
| Slow first connection | Cassandra still starting | Wait ~30 seconds after service start before connecting |
| `AllowAllAuthenticator` error | Auth disabled on server | Either enable `PasswordAuthenticator` in `cassandra.yaml` or omit credentials in driver |
