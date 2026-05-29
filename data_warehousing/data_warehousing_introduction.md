# Author: Víctor Barceló

# Introduction to Data Warehousing

## What is a Data Warehouse?

A **data warehouse** (DW or DWH) is a centralized repository designed to store, integrate, and analyze large volumes of historical data from multiple sources. Unlike operational databases — which are optimized for recording day-to-day transactions — a data warehouse is optimized for **analytical queries** that aggregate and compare data over time.

The term was popularized by Bill Inmon in the early 1990s, who defined a data warehouse as:

> "A subject-oriented, integrated, nonvolatile, and time-variant collection of data in support of management's decision making."

These four properties remain the foundation of data warehouse design today.

---

## Core Characteristics

### 1. Subject-Oriented

A data warehouse is organized around key business subjects such as customers, products, sales, or employees — not around the operational applications that produced the data. This makes it easier to analyze information from a business perspective.

### 2. Integrated

Data comes from many different source systems (ERP, CRM, flat files, APIs, etc.) and is cleaned, transformed, and consolidated into a consistent format before loading. Inconsistencies in naming, units, or encoding are resolved during this process.

**Example**: One source system stores gender as `"M"/"F"`, another as `"Male"/"Female"`, and a third as `1/2`. In the warehouse, all three are unified into a single standard representation.

### 3. Non-Volatile

Once data is loaded into a data warehouse, it is not updated or deleted in the normal sense. Historical records are preserved. This allows analysts to compare data across time periods reliably.

### 4. Time-Variant

Every record in a data warehouse is associated with a time period. This makes it possible to track trends, identify seasonal patterns, and compare performance across different points in time.

---

## Data Warehouse vs. Operational Database

| Dimension | Operational Database (OLTP) | Data Warehouse (OLAP) |
|-----------|----------------------------|----------------------|
| Purpose | Record daily transactions | Analyze historical data |
| Workload type | Online Transaction Processing (OLTP) | Online Analytical Processing (OLAP) |
| Query type | Short, frequent reads/writes | Long, complex queries over many rows |
| Data volume | Gigabytes | Terabytes to petabytes |
| Updates | Continuous (INSERT, UPDATE, DELETE) | Batch loads (ETL/ELT) |
| Schema | Normalized (3NF) | Denormalized (star, snowflake) |
| Users | Application users, services | Analysts, data scientists, managers |
| Response time | Milliseconds | Seconds to minutes |
| Examples | PostgreSQL, MySQL, Oracle | Snowflake, BigQuery, Redshift, Synapse |

The fundamental trade-off is this: operational databases minimize redundancy to make writes fast and safe; data warehouses accept redundancy to make complex reads fast.

---

## Architecture Overview

A typical data warehouse architecture has three main layers:

```
Source Systems          Integration Layer          Presentation Layer
-----------------       ----------------------     -------------------
  ERP System     -->                          -->    Dashboards
  CRM System     -->   ETL / ELT Pipeline    -->    Reports
  Web Logs       -->   (Staging Area)        -->    Ad-hoc Queries
  Flat Files     -->                          -->    Data Mining
  APIs           -->                          -->    Machine Learning
```

### Source Layer

The raw data originates in operational systems. These can be relational databases, SaaS applications, log files, event streams, or external data feeds. The warehouse does not modify these systems.

### Integration Layer (Staging + ETL/ELT)

This is where the heavy lifting happens. Data passes through:

1. **Extraction**: Data is pulled from source systems.
2. **Transformation**: Data is cleaned, validated, deduped, and reshaped into the warehouse schema.
3. **Loading**: Transformed data is written into the warehouse.

This process is called **ETL** (Extract, Transform, Load). A modern alternative is **ELT** (Extract, Load, Transform), where raw data is loaded first and transformed inside the warehouse using its own compute power.

### Presentation Layer

End users interact with the warehouse through:

- Business Intelligence (BI) tools (Power BI, Tableau, Metabase)
- SQL query interfaces
- Scheduled reports
- Machine learning pipelines

---

## Dimensional Modeling

Dimensional modeling is the standard approach for structuring data inside a warehouse. It was developed by Ralph Kimball and is designed to make analytical queries simple and fast.

It uses two types of tables:

### Fact Tables

A **fact table** stores measurable, quantitative events — the things you want to analyze. Each row represents one occurrence of an event.

**Common facts**: revenue, quantity sold, page views, login count, error count.

```sql
CREATE TABLE fact_sales (
    sale_id       BIGINT PRIMARY KEY,
    date_key      INTEGER REFERENCES dim_date(date_key),
    product_key   INTEGER REFERENCES dim_product(product_key),
    customer_key  INTEGER REFERENCES dim_customer(customer_key),
    store_key     INTEGER REFERENCES dim_store(store_key),
    quantity      INTEGER,
    unit_price    NUMERIC(10, 2),
    discount      NUMERIC(5, 2),
    total_revenue NUMERIC(12, 2)
);
```

### Dimension Tables

A **dimension table** stores descriptive attributes that provide context for the facts — the "who, what, where, when, and how" of each event.

**Common dimensions**: date, product, customer, geography, employee, campaign.

```sql
CREATE TABLE dim_product (
    product_key   INTEGER PRIMARY KEY,
    product_id    VARCHAR(20),
    name          VARCHAR(200),
    category      VARCHAR(100),
    subcategory   VARCHAR(100),
    brand         VARCHAR(100),
    unit_cost     NUMERIC(10, 2),
    is_active     BOOLEAN
);

CREATE TABLE dim_date (
    date_key    INTEGER PRIMARY KEY,  -- e.g. 20260421
    full_date   DATE,
    year        INTEGER,
    quarter     INTEGER,
    month       INTEGER,
    month_name  VARCHAR(10),
    week        INTEGER,
    day_of_week VARCHAR(10),
    is_weekend  BOOLEAN,
    is_holiday  BOOLEAN
);
```

Notice that the date dimension is pre-computed and fully denormalized. This avoids expensive date functions during query time.

---

## Schema Patterns

### Star Schema

The simplest and most common layout. The fact table sits at the center, with dimension tables radiating outward — resembling a star.

```
                  dim_date
                     |
dim_customer --- fact_sales --- dim_product
                     |
                  dim_store
```

**Advantages**:
- Simple to understand and query
- Fewer JOINs than normalized schemas
- Excellent query performance

**Disadvantages**:
- Some redundancy in dimension tables
- Dimension tables can become large

### Snowflake Schema

A variation of the star schema where dimension tables are further normalized into sub-dimensions.

```
dim_city --> dim_store --- fact_sales --- dim_product --- dim_category
```

**Advantages**:
- Reduces redundancy in large dimensions
- Easier to maintain hierarchies

**Disadvantages**:
- More JOINs required in queries
- More complex to design and query

### Galaxy Schema (Fact Constellation)

Multiple fact tables share dimension tables. Used when the warehouse covers several business processes.

```
dim_date ---- fact_sales ---- dim_product
    |                              |
dim_date ---- fact_inventory -- dim_product
```

---

## ETL vs. ELT

| Aspect | ETL | ELT |
|--------|-----|-----|
| Where transformation happens | Dedicated ETL server | Inside the data warehouse |
| When to use | Limited warehouse compute, strict data governance | Cloud warehouses with scalable compute |
| Typical tooling | Apache Spark, Talend, Informatica | dbt, SQL scripts inside Snowflake/BigQuery |
| Raw data preservation | Often discarded | Raw data kept in a staging layer |
| Flexibility | Transformations fixed at load time | Can re-transform raw data at any time |

Modern cloud data platforms (Snowflake, BigQuery, Redshift) favor **ELT** because compute is elastic and cheap — it makes more sense to load raw data quickly and transform it later using SQL.

---

## Data Warehouse vs. Data Lake vs. Data Lakehouse

As the field evolved, new architectures emerged alongside the classical data warehouse.

| Concept | Data Warehouse | Data Lake | Data Lakehouse |
|---------|---------------|-----------|----------------|
| Data type | Structured | Structured, semi-structured, unstructured | All types |
| Schema | Schema on write | Schema on read | Schema on read + write |
| Query performance | High | Low to medium | High |
| Storage cost | High | Very low | Low |
| ACID support | Yes | No | Yes (Delta Lake, Iceberg) |
| Best for | BI, reporting | Raw storage, ML, exploration | Unified analytics |
| Examples | Snowflake, Redshift | S3 + Glue, ADLS | Databricks, Delta Lake |

A **data lakehouse** combines the low-cost storage of a data lake with the structure and query performance of a data warehouse. Technologies like Apache Iceberg, Delta Lake, and Apache Hudi make this possible by adding ACID transactions and schema enforcement on top of object storage.

---

## OLAP Operations

Analysts interact with multidimensional data using a set of standard operations:

### Slice

Select a single value for one dimension, reducing the number of dimensions by one.

**Example**: Show all sales data for the year 2025 only.

### Dice

Select a range or subset of values across multiple dimensions simultaneously.

**Example**: Show sales for products in the "Electronics" category, in the "North" region, during Q1 and Q2.

### Drill-Down

Move from a high-level summary to a more detailed view by descending a dimension hierarchy.

**Example**: Year -> Quarter -> Month -> Week -> Day

### Roll-Up (Drill-Up)

The opposite of drill-down: aggregate detail data upward along a hierarchy.

**Example**: Day -> Month -> Quarter -> Year

### Pivot (Rotate)

Rotate the data axes to present data from a different perspective.

**Example**: Swap rows and columns so that products become the rows and regions become the columns.

---

## Slowly Changing Dimensions (SCD)

A common challenge in data warehouses is handling changes in dimension attributes over time. For example, a customer moves to a new city, or a product changes its category. These are called **Slowly Changing Dimensions (SCD)**.

There are several strategies to handle them:

| Type | Strategy | Description |
|------|----------|-------------|
| SCD Type 0 | Ignore | No history kept; overwrite silently |
| SCD Type 1 | Overwrite | Update in place; old value is lost |
| SCD Type 2 | Add new row | New row added with new effective date; full history preserved |
| SCD Type 3 | Add column | Previous value stored in a separate column; limited history |

**SCD Type 2** is by far the most common in practice because it preserves the full history of changes.

**Example of SCD Type 2** for a customer changing their city:

```
customer_key | customer_id | city       | valid_from | valid_to   | is_current
-------------|-------------|------------|------------|------------|----------
1            | C001        | Zaragoza   | 2024-01-01 | 2025-06-14 | FALSE
2            | C001        | Barcelona  | 2025-06-15 | 9999-12-31 | TRUE
```

A fact row recorded in February 2025 (linked to `customer_key = 1`) correctly reflects that the customer lived in Zaragoza at the time of the sale.

---

## Modern Cloud Data Warehouses

Traditional on-premises data warehouses required expensive hardware and significant upfront investment. Cloud platforms have transformed this model.

| Platform | Provider | Key Feature |
|----------|----------|-------------|
| BigQuery | Google Cloud | Serverless, pay-per-query, columnar storage |
| Snowflake | Multi-cloud | Separate compute and storage, time travel |
| Amazon Redshift | AWS | MPP, tight AWS ecosystem integration |
| Azure Synapse Analytics | Microsoft Azure | Integrated analytics + Spark + SQL |
| Databricks | Multi-cloud | Lakehouse architecture, Delta Lake, ML integration |

### Key Innovations in Cloud Warehouses

**Columnar Storage**: Data is stored column by column rather than row by row. When an analytical query reads only 3 out of 50 columns, only those 3 columns are read from disk — drastically reducing I/O.

**Massively Parallel Processing (MPP)**: Queries are automatically split across many compute nodes and executed in parallel, enabling fast processing of billions of rows.

**Separation of Compute and Storage**: Storage and compute are scaled independently. You can pause compute when not in use to save cost without losing data.

**Zero-copy cloning and time travel**: Some platforms (Snowflake, Databricks) allow instant cloning of tables and querying data as it existed at a past point in time without additional storage cost.

---

## Data Quality and Governance

A data warehouse is only as trustworthy as the data inside it. Poor data quality leads to incorrect reports and wrong business decisions.

### Common Data Quality Dimensions

- **Completeness**: Are required fields populated?
- **Accuracy**: Does the data reflect reality?
- **Consistency**: Is the same entity represented the same way across sources?
- **Timeliness**: Is the data fresh enough for its intended use?
- **Uniqueness**: Are there duplicate records?
- **Validity**: Does the data conform to expected formats and ranges?

### Data Governance

Data governance defines who is responsible for data, how it is documented, and how access is controlled. Key practices include:

- **Data catalog**: Metadata inventory that describes what data exists and what it means
- **Data lineage**: Tracking where data came from and how it was transformed
- **Access control**: Role-based permissions to protect sensitive data
- **Data contracts**: Agreements between source teams and consumers about schema and quality guarantees

---

## Typical Data Warehouse Workflow

A simplified end-to-end workflow looks like this:

```
1. Source Systems
   PostgreSQL (orders), CRM (customers), CSV (marketing spend)

2. Extraction
   Pull daily snapshots or CDC (Change Data Capture) streams

3. Staging Area
   Raw data loaded as-is into staging tables — no transformation yet

4. Transformation (dbt or SQL)
   Clean, join, aggregate, apply business logic

5. Dimensional Model
   Load into fact and dimension tables in the warehouse

6. Semantic Layer / BI Tool
   Connect Tableau, Power BI, or Metabase to the warehouse

7. Consumers
   Analysts query dashboards; data scientists pull training data;
   automated reports email stakeholders
```

---

## Relationship to Other Topics in This Course

You have already studied several database systems in this course. Data warehousing builds directly on top of them:

| Topic Studied | Relevance to Data Warehousing |
|---------------|-------------------------------|
| Relational databases (PostgreSQL) | The dimensional model uses SQL; many warehouses are relational at their core |
| SQL basics and query optimization | Analytical queries in a warehouse are SQL, often complex aggregations over large tables |
| Access control | Warehouses store sensitive business data; role-based access is essential |
| Transactions and concurrency | ETL pipelines must handle partial failures; understanding ACID matters |
| NoSQL databases | Data lakes and lakehouse architectures ingest data from NoSQL sources; understanding schema-on-read is key |
| Database optimization | Columnar storage, partitioning, and indexing strategies apply directly to warehouse performance |

---

## Summary

| Concept | Key Takeaway |
|---------|-------------|
| Data warehouse | Centralized analytical store; subject-oriented, integrated, non-volatile, time-variant |
| OLTP vs. OLAP | Operational databases optimize for writes; warehouses optimize for reads |
| Dimensional modeling | Facts (measurements) + dimensions (context); star and snowflake schemas |
| ETL / ELT | The pipeline that moves data from sources into the warehouse |
| SCD Type 2 | Preserving historical changes in dimension tables |
| Columnar storage | Reads only the columns needed; critical for analytical performance |
| Data lake | Raw storage for all data types; cheap but unstructured |
| Data lakehouse | Combines lake storage costs with warehouse query performance |
| Data quality | Trustworthy analysis requires clean, consistent, well-governed data |
