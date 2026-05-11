# Author: Víctor Barceló

# Database Connection Guides

This folder contains step-by-step instructions and runnable code examples for connecting to every database covered in this course. Each guide includes examples in **Python**, **Java**, and **C++**.

---

## Databases Covered

| Database | Type | Default Port | Guide |
|----------|------|-------------|-------|
| PostgreSQL | Relational (SQL) | 5432 | [postgresql.md](postgresql.md) |
| Apache Cassandra | Wide-column NoSQL | 9042 | [cassandra.md](cassandra.md) |
| MongoDB | Document NoSQL | 27017 | [mongodb.md](mongodb.md) |
| Neo4j | Graph NoSQL | 7687 (Bolt) | [neo4j.md](neo4j.md) |
| Redis | Key-value NoSQL | 6379 | [redis.md](redis.md) |

---

## Language Prerequisites

### Python

Python 3.8 or higher is recommended. Install drivers with `pip`:

```bash
pip install psycopg2-binary      # PostgreSQL
pip install cassandra-driver     # Cassandra
pip install pymongo              # MongoDB
pip install neo4j                # Neo4j
pip install redis                # Redis
```

Or install all at once using the provided requirements file:

```bash
pip install -r requirements.txt
```

### Java

Java 17 or higher is recommended. Each guide provides the Maven and Gradle dependency declaration for the relevant driver.

### C++

C++ 17 or higher is recommended. Each guide specifies the library, how to install it (via `apt`, `vcpkg`, or from source), and how to compile the example.

---

## General Security Notes

- Never hardcode credentials in source files committed to version control.
- Use environment variables or a secrets manager for passwords.
- Always use the principle of least privilege: connect with a user that has only the permissions it needs.
- Enable SSL/TLS for all connections in production environments.
