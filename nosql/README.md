# NoSQL Databases Module

## Overview

This module provides a comprehensive introduction to NoSQL databases, covering different types, use cases, and when to choose NoSQL over traditional relational databases.

## Module Contents

### 1. [NoSQL Introduction](nosql_introduction.md)
Comprehensive guide covering:
- What is NoSQL and why it exists
- Four types of NoSQL databases (Document, Key-Value, Column-Family, Graph)
- CAP theorem and BASE principles
- Comparison with relational databases
- Popular NoSQL databases
- Query examples for each type
- Data modeling strategies
- Best practices and common pitfalls

### 2. [NoSQL Exercises](nosql_exercises.md)
Hands-on practice exercises including:
- Classification of NoSQL types for different scenarios
- CAP theorem and ACID vs BASE analysis
- Data modeling for document, key-value, and graph databases
- SQL vs NoSQL comparison and migration planning
- Query writing for MongoDB and Redis
- Sharding and replication strategies
- Polyglot persistence architecture design

## Learning Objectives

After completing this module, you will be able to:

- Understand the differences between relational and NoSQL databases
- Identify which type of NoSQL database suits specific use cases
- Design schemas for document and graph databases
- Apply CAP theorem to database selection
- Compare ACID and BASE consistency models
- Write queries for different NoSQL systems
- Design scalable database architectures
- Plan migrations from SQL to NoSQL
- Implement polyglot persistence strategies

## Prerequisites

- Understanding of relational databases
- SQL query knowledge
- Basic understanding of database concepts (tables, indexes, transactions)

## Recommended Study Path

1. **Week 1**: Read NoSQL Introduction
   - Focus on: What is NoSQL, types of databases, CAP theorem
   - Complete: Exercises 1-3 (Concepts)

2. **Week 2**: Data Modeling
   - Focus on: Document, key-value, and graph modeling
   - Complete: Exercises 4-6 (Data Modeling)

3. **Week 3**: Comparison and Migration
   - Focus on: SQL vs NoSQL trade-offs
   - Complete: Exercises 7-8 (Comparison)

4. **Week 4**: Query Practice
   - Focus on: MongoDB and Redis queries
   - Complete: Exercises 9-10 (Querying)

5. **Week 5**: Advanced Topics
   - Focus on: Sharding, replication, polyglot persistence
   - Complete: Exercises 11-15 (Advanced)

## Database Types Covered

### Document Databases
- **Examples**: MongoDB, CouchDB, Amazon DocumentDB
- **Use Cases**: Content management, e-commerce catalogs, user profiles
- **Key Concepts**: Flexible schema, nested documents, embedded vs referenced data

### Key-Value Stores
- **Examples**: Redis, Amazon DynamoDB, Memcached
- **Use Cases**: Caching, session storage, leaderboards, counters
- **Key Concepts**: In-memory speed, simple data model, TTL expiration

### Column-Family Databases
- **Examples**: Apache Cassandra, HBase, ScyllaDB
- **Use Cases**: Time-series data, IoT sensors, event logging
- **Key Concepts**: Wide columns, high write throughput, distributed architecture

### Graph Databases
- **Examples**: Neo4j, Amazon Neptune, ArangoDB
- **Use Cases**: Social networks, recommendations, fraud detection
- **Key Concepts**: Nodes and relationships, graph traversal, Cypher query language

## Key Concepts

### CAP Theorem
- **Consistency**: All nodes see the same data
- **Availability**: System remains operational
- **Partition Tolerance**: System works despite network issues
- **Trade-off**: Can only guarantee 2 of 3

### ACID vs BASE
- **ACID** (Relational): Atomicity, Consistency, Isolation, Durability
- **BASE** (NoSQL): Basically Available, Soft state, Eventually consistent

### When to Use NoSQL
- Massive scale (millions/billions of records)
- High throughput (thousands of ops/second)
- Flexible schema requirements
- Unstructured or semi-structured data
- Global distribution needs
- Specific access patterns

### When to Use SQL
- Complex relationships and JOINs
- ACID compliance required
- Ad-hoc reporting queries
- Strong data integrity needs
- Mature tooling requirements

## Popular NoSQL Databases

| Database | Type | Best For |
|----------|------|----------|
| MongoDB | Document | Flexible schemas, rapid development |
| Redis | Key-Value | Caching, real-time analytics |
| Cassandra | Column-Family | Time-series, IoT, high writes |
| Neo4j | Graph | Social networks, recommendations |
| DynamoDB | Key-Value/Doc | AWS serverless applications |
| Elasticsearch | Search | Full-text search, log analytics |

## Practical Applications

### E-commerce Platform
- **MongoDB**: Product catalog (varying attributes)
- **Redis**: Shopping carts, session cache
- **PostgreSQL**: Order transactions (ACID needed)
- **Elasticsearch**: Product search

### Social Media
- **Neo4j**: Friend relationships, recommendations
- **Cassandra**: Activity feeds, time-series data
- **Redis**: Like counters, trending topics
- **MongoDB**: User profiles, posts

### IoT Platform
- **Cassandra**: Sensor data ingestion
- **Redis**: Real-time dashboards
- **MongoDB**: Device configurations
- **PostgreSQL**: User accounts, billing

## Tools and Resources

### Online Courses
- MongoDB University (free)
- Redis University (free)
- Neo4j Graph Academy (free)
- DataStax Cassandra Academy (free)

### Documentation
- [MongoDB Docs](https://docs.mongodb.com/)
- [Redis Docs](https://redis.io/documentation)
- [Cassandra Docs](https://cassandra.apache.org/doc/)
- [Neo4j Docs](https://neo4j.com/docs/)

### Books
- *NoSQL Distilled* by Martin Fowler
- *Designing Data-Intensive Applications* by Martin Kleppmann
- *MongoDB: The Definitive Guide*
- *Graph Databases* by Ian Robinson

### Hands-On Practice
- MongoDB Atlas (free tier)
- Redis Labs (free tier)
- Neo4j Aura (free tier)
- AWS Free Tier (DynamoDB)

## Assessment

To demonstrate mastery of this module, you should be able to:

1. **Classify** appropriate NoSQL types for given scenarios
2. **Design** data models for document and graph databases
3. **Explain** CAP theorem trade-offs
4. **Compare** SQL and NoSQL approaches
5. **Write** queries for MongoDB and Redis
6. **Plan** database sharding and replication strategies
7. **Create** polyglot persistence architectures
8. **Evaluate** when to use NoSQL vs SQL

## Related Modules

- **Relational Databases**: Foundation for comparison
- **Introduction**: Database basics and RDBMS concepts
- **SQL Basics**: SQL query language
- **Transactions**: ACID properties and concurrency
- **Access Control**: Security principles apply to NoSQL too

## Common Pitfalls to Avoid

1. Using NoSQL for everything (not all problems need it)
2. Ignoring consistency requirements
3. Poor data modeling (trying to recreate SQL in NoSQL)
4. Over-normalization in document databases
5. Neglecting indexes
6. Not planning for scale
7. Ignoring security and backups

## Future Topics

After mastering this module, consider exploring:
- NewSQL databases (CockroachDB, Google Spanner)
- Multi-model databases (ArangoDB, CosmosDB)
- Vector databases (Pinecone, Weaviate)
- Specialized databases (TimescaleDB, InfluxDB)
- Database optimization and performance tuning
- Cloud-native databases and serverless

---

## Getting Started

1. Read [nosql_introduction.md](nosql_introduction.md) thoroughly
2. Start with Exercise 1 in [nosql_exercises.md](nosql_exercises.md)
3. Install MongoDB and try some queries
4. Experiment with Redis for caching
5. Design your own database architecture for a real-world problem

---

**Last Updated**: March 1, 2026  
**Course**: USJ IT Class 2026  
**Module**: NoSQL Databases
