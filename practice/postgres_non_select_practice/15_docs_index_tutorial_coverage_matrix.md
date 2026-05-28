# 15. PostgreSQL Docs Index and Tutorial Coverage Matrix

This matrix is the anti-gap control file for this repository.
Use it to ensure practice coverage tracks the official docs structure and tutorial journey.

## Source anchors
- Docs root: https://www.postgresql.org/docs/current/index.html
- Tutorial root: https://www.postgresql.org/docs/current/tutorial.html
- Book index: https://www.postgresql.org/docs/current/bookindex.html

## Tutorial Coverage (Part I)
- [x] Getting started (install, architecture, createdb, accessdb)
  - practice module: `00_ddl_schemas_and_table_lifecycle.md`
- [x] SQL language basics (`SELECT`, joins, aggregates, updates, deletes)
  - practice modules: `custom_practice/*`, `postgres_docs_practice/01..04`
- [x] Advanced tutorial features (views, foreign keys, transactions, window, inheritance)
  - practice modules: `05_views_matviews_and_rules.md`, `04_transactions_locks_mvcc.md`, `11_inheritance_and_partitioning.md`, `postgres_docs_practice/03_window_functions.md`

## SQL Language Part Coverage (Ch. 4-15)
- [x] SQL syntax
- [x] Data definition (CREATE/ALTER/DROP, schemas, constraints)
- [x] Data manipulation
- [x] Queries
- [x] Data types
- [x] Functions/operators
- [x] Type conversion
- [x] Indexes
- [x] Full text search
- [x] Concurrency control
- [x] Performance tips
- [x] Parallel query

Mapped modules:
- `00_ddl_schemas_and_table_lifecycle.md`
- `11_inheritance_and_partitioning.md`
- `01_constraints_and_integrity.md`
- `03_indexes_and_access_paths.md`
- `04_transactions_locks_mvcc.md`
- `12_types_sequences_extensions_fdw.md`
- `02_data_types_casts_and_domains.md`
- `10_full_text_search_practice.md`
- `06_functions_operators_and_expressions.md`
- `13_maintenance_stats_and_operations.md`
- `14_maintenance_and_admin_workflows.md`
- `postgres_docs_practice/01..08`

## Server Administration Part Coverage (Ch. 16-31)
- [x] Setup/operation and role fundamentals
- [x] routine maintenance, monitoring, backup strategy
- [x] high-availability/replication foundations

Mapped modules:
- `08_roles_privileges_and_rls.md`
- `13_maintenance_stats_and_operations.md`
- `14_maintenance_and_admin_workflows.md`
- `replication/*` project examples in workspace

## Reference and Internals Essentials
- [x] SQL commands practice coverage
- [x] system catalogs/system views usage
- [x] information schema introspection

Mapped modules:
- `09_system_catalogs_information_schema_and_introspection.md`
- `99_non_select_reference_solutions.sql`

## Explicit Gap Check for Your Requested Topics
- [x] creating tables
- [x] altering tables safely
- [x] creating and using schemas
- [x] partitioning practice
- [x] system tables/catalog usage
- [x] broader data types
- [x] full text search
- [x] functions and operators
- [x] maintenance workflows

## Completion rule
Mark this matrix complete only after:
1. You attempted every module in `postgres_non_select_practice`.
2. You finished `postgres_docs_practice/08_docs_completeness_checklist.md`.
3. You can explain each checked topic with one working SQL example from memory.
