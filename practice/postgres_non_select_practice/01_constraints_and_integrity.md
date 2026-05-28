# 01. Constraints and Data Integrity

## Docs
- Constraints overview: https://www.postgresql.org/docs/current/ddl-constraints.html
- Domains: https://www.postgresql.org/docs/current/sql-createdomain.html
- ALTER TABLE: https://www.postgresql.org/docs/current/sql-altertable.html

## Q1. Primary/unique/foreign/check/not null
Task:
Design an `orders_core` schema using all major constraint types.

Verification:
- Insert valid rows.
- Try one violating insert per constraint and capture error.

## Q2. Composite keys
Task:
Create table with composite primary key and child table with matching composite foreign key.

Verification:
- Ensure FK enforcement works for both columns.

## Q3. DEFERRABLE constraints
Task:
Create two tables with cyclic references and use `DEFERRABLE INITIALLY DEFERRED` FK.

Verification:
- Insert interdependent rows inside one transaction.

## Q4. Exclusion constraints
Task:
Build a booking table with range overlaps blocked (e.g., room/time overlap prevention).

Verification:
- Attempt overlapping and non-overlapping inserts.

## Q5. Generated columns and checks
Task:
Add generated column for computed total and enforce sanity check.

Verification:
- Update base columns and confirm generated value updates.

## Q6. Domain-based validation
Task:
Create domain for standardized email or code format and apply across multiple tables.

Verification:
- Ensure domain errors fire consistently.

## Q7. Constraint management lifecycle
Task:
Add constraints with `NOT VALID`, validate later with `VALIDATE CONSTRAINT`.

Verification:
- Observe behavior before/after validation.
