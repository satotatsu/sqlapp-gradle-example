# Core Concepts

This document explains the core design concepts of **sqlapp** and how its components work together.

## Overview

Unlike tools that focus on a single task, sqlapp provides an integrated workflow for the entire database development lifecycle.

* Schema version management
* Schema modeling and documentation
* Schema diff analysis
* Dictionary management
* Logical relationship management
* Test data generation
* Data import and export
* Format conversion

The goal is to use a consistent configuration model and execution framework across these features.

---

## Schema as a Canonical Model

sqlapp exports database metadata into an XML representation.

The exported schema is more than a backup of metadata—it serves as the canonical model for other features.

```text
           Database
                │
                ▼
          Schema XML Model
      ┌─────────┼─────────┐
      │         │         │
      ▼         ▼         ▼
 HTML Docs  Schema Diff  Dictionaries
```

The schema model can include:

* Tables
* Columns
* Primary and foreign keys
* Indexes and constraints
* Views
* Sequences
* Functions
* Stored procedures (including source code)
* Synonyms
* Tablespaces
* Partitioning metadata
* SQL Server partition functions and partition schemes
* PostgreSQL `INHERITS`
* External tables

---

## Dictionary-Driven Documentation

Business-friendly names and descriptions are managed separately from the database.

Dictionary templates can be generated from the schema and edited using Excel or YAML.

```text
Schema XML
      │
      ▼
Dictionary Templates
(tables.xlsx, columns.xlsx, ...)
      │
      ▼
Business Names & Remarks
      │
      ▼
Generated HTML Documentation
```

This approach allows documentation to evolve without modifying the database schema itself.

---

## Logical Foreign Keys

Not every database defines physical foreign key constraints.

sqlapp supports user-defined logical relationships that are incorporated into documentation and diagrams.

Example:

```text
#job_details->jobs

#user_jobs(created_at, id)->jobs(created_at, id)
```

This enables accurate documentation of application-managed relationships and legacy systems.

---

## Streaming Data Pipeline

Data generation, import, and export are designed around a streaming architecture.

```text
Data Source
     │
     ▼
Iterator / SQL / CSV / TSV / Excel / YAML / JSONL
     │
     ▼
MVEL Expressions
     │
     ▼
Column Mapping
     │
     ▼
Streaming Processing
     │
     ▼
Destination
```

Because records are processed sequentially, sqlapp can efficiently handle very large datasets while keeping memory usage low.

---

## Expression-Based Processing

Many parts of sqlapp are configurable through MVEL expressions.

Examples include:

* Data generation
* Data transformation
* Column mapping
* Value conversion
* Random value generation
* Custom business logic

Projects can also expose custom Java static methods for use within expressions.

---

## Unified Configuration Philosophy

Generator, import, and export features share common concepts.

For example:

* `dataSourceExpression`
* `columnMappingExpression`
* Streaming execution
* Expression evaluation
* Java extensions

This consistency reduces the learning curve and enables reusable configurations.

---

## High-Performance Test Data Generation

The data generator automatically analyzes foreign key dependencies and generates relationally consistent datasets.

Features include:

* Automatic dependency ordering
* Streaming execution
* Configurable JDBC batch size
* Configurable commit interval
* Iterator- and file-based data sources
* SQL-based initialization
* Excel ↔ YAML configuration conversion

The architecture is designed to support datasets containing tens of millions of rows.

---

## Data Import and Export

sqlapp supports importing and exporting data in multiple formats, including:

* CSV
* TSV
* Excel
* YAML
* JSONL

Transformation can be applied during processing using MVEL expressions and custom Java functions.

Binary data can also be handled through `InputStream`-based expressions.

---

## Separation of Configuration and Execution

Configuration files describe **what** should be processed.

Command-line options determine **how and where** processing occurs.

For example:

```bash
gradlew exportData \
  --config=export/customers.yaml \
  --output-dir=./build/export
```

This separation allows the same configuration to be reused across different environments and CI/CD pipelines.

---

## Extensibility

sqlapp is designed to be extensible.

Projects can customize behavior by:

* Adding MVEL expressions
* Registering Java utility functions
* Using external data sources
* Creating reusable configuration files
* Combining multiple processing pipelines

This flexibility allows sqlapp to support use cases ranging from documentation generation to large-scale test data creation and data migration.
