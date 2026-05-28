# 00. DDL, Schemas, and Table Lifecycle

## Why this exists
This module covers the core basics that are often skipped in query-focused practice: creating tables, altering them safely, schema usage, search path behavior, and object lifecycle.

## Docs
- Tutorial: SQL language intro: https://www.postgresql.org/docs/current/tutorial-sql.html
- Tutorial: creating/accessing DB: https://www.postgresql.org/docs/current/tutorial-createdb.html
- Table basics (CREATE/DROP): https://www.postgresql.org/docs/current/ddl-basics.html
- Modifying tables (ALTER): https://www.postgresql.org/docs/current/ddl-alter.html
- Schemas and search_path: https://www.postgresql.org/docs/current/ddl-schemas.html
- CREATE TABLE: https://www.postgresql.org/docs/current/sql-createtable.html
- ALTER TABLE: https://www.postgresql.org/docs/current/sql-altertable.html
- CREATE SCHEMA: https://www.postgresql.org/docs/current/sql-createschema.html
- DROP SCHEMA: https://www.postgresql.org/docs/current/sql-dropschema.html

## Q1. Create a clean schema workspace
Task:
Create schema `practice_core`, set ownership if needed, and set `search_path` for your current session.

Verification:
- Show `current_schema` and `current_schemas(true)`.
- Confirm unqualified table names resolve to `practice_core` first.

## Q2. Create tables with defaults and identity
Task:
Create a `users` table and an `orders` table with:
- identity or generated key columns
- NOT NULL and CHECK constraints
- DEFAULT timestamps
- FK from orders to users

Verification:
- Insert valid rows and return inserted IDs.
- Attempt one invalid row for each key constraint category.

## Q3. ALTER lifecycle drill
Task:
Apply safe schema evolution operations:
- add nullable column
- backfill values
- set NOT NULL
- rename a column
- change data type with explicit cast

Verification:
- Show final table definition with `\d+` (psql) or catalog query.
- Confirm old queries fail and updated queries pass.

## Q4. Constraint migration flow
Task:
Add a CHECK constraint as `NOT VALID`, fix bad data, then `VALIDATE CONSTRAINT`.

Verification:
- Show failure before data fix.
- Show successful validation after cleanup.

## Q5. Object dependency and drop safety
Task:
Create a view depending on a table, then test `DROP ... RESTRICT` vs `DROP ... CASCADE` behavior.

Verification:
- Explain which objects are removed in each approach.

## Q6. Public schema and naming hygiene
Task:
Create equivalent object names in `public` and `practice_core`, then run unqualified queries.

Verification:
- Demonstrate why explicit schema qualification matters.

## Tip
For production migrations, prefer additive changes first (add/backfill/validate/swap) and avoid destructive rewrites in one step.
