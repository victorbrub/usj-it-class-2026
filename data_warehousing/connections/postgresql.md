# Author: Víctor Barceló

# Connecting to PostgreSQL

## Overview

PostgreSQL listens on port **5432** by default. The standard protocol is TCP with the libpq wire protocol. All three language drivers shown below use this protocol under the hood.

---

## Prerequisites

### Python — psycopg2

```bash
pip install psycopg2-binary
```

`psycopg2-binary` bundles the compiled C library. For production deployments, prefer the source distribution `psycopg2` with libpq installed on the system.

### Java — PostgreSQL JDBC Driver

Add to `pom.xml` (Maven):

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.7.3</version>
</dependency>
```

Add to `build.gradle` (Gradle):

```groovy
implementation 'org.postgresql:postgresql:42.7.3'
```

### C++ — libpq

Install via apt on Debian/Ubuntu:

```bash
sudo apt install libpq-dev
```

On Windows, install PostgreSQL and the development headers are included. On macOS:

```bash
brew install libpq
```

---

## Python Example

See the full working script: [scripts/postgresql/postgresql_example.py](scripts/postgresql/postgresql_example.py)

### Run

```bash
export PG_PASSWORD="your_password"
python postgresql_example.py
```

---

## Java Example

See the full working script: [scripts/postgresql/PostgreSQLExample.java](scripts/postgresql/PostgreSQLExample.java)

### Compile and Run

```bash
# Download the driver jar first or use Maven/Gradle
javac -cp .:postgresql-42.7.3.jar PostgreSQLExample.java
PG_PASSWORD=your_password java -cp .:postgresql-42.7.3.jar PostgreSQLExample
```

---

## C++ Example

See the full working script: [scripts/postgresql/postgresql_example.cpp](scripts/postgresql/postgresql_example.cpp)

### Compile and Run

```bash
g++ -std=c++17 -o postgresql_example postgresql_example.cpp -lpq
export PG_PASSWORD="your_password"
./postgresql_example
```

---

## Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| `Connection refused` | PostgreSQL not running or wrong port | `sudo systemctl start postgresql`; verify port |
| `password authentication failed` | Wrong user or password | Check `PG_USER` and `PG_PASSWORD` env vars |
| `database does not exist` | Database name typo or not created | Run `createdb mydb` or check spelling |
| `FATAL: role does not exist` | User not created in PostgreSQL | Run `CREATE ROLE myuser LOGIN PASSWORD '...';` |
| SSL handshake error | Server does not support SSL | Change `sslmode` to `disable` for local dev |
| `could not connect to server` | Firewall or `pg_hba.conf` blocking | Add host entry in `pg_hba.conf`; reload config |
