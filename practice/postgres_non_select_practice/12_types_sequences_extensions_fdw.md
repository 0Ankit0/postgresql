# 12. Types, Sequences, Extensions, and FDW

## Docs
- Data types overview: https://www.postgresql.org/docs/current/datatype.html
- Enumerated types: https://www.postgresql.org/docs/current/datatype-enum.html
- Composite types: https://www.postgresql.org/docs/current/rowtypes.html
- Sequences: https://www.postgresql.org/docs/current/sql-createsequence.html
- CREATE EXTENSION: https://www.postgresql.org/docs/current/sql-createextension.html
- postgres_fdw: https://www.postgresql.org/docs/current/postgres-fdw.html

## Q1. Enum and migration impact
Task:
Create enum-backed status column and later add enum value safely.

Verification:
- Verify existing rows and new inserts remain valid.

## Q2. Composite type usage
Task:
Define composite type and store/retrieve it in table column.

Verification:
- Access individual fields from composite values.

## Q3. Sequence control
Task:
Create explicit sequence, bind to table column, and test `setval` behavior.

Verification:
- Confirm next generated values after manual adjustments.

## Q4. Extension management
Task:
Install one useful extension (example: `pg_trgm` or `uuid-ossp`) and use one feature.

Verification:
- Show extension object existence and one practical query.

## Q5. Foreign data wrapper basics
Task:
Configure local loopback postgres_fdw server and foreign table.

Verification:
- Query foreign table and test pushdown plan with `EXPLAIN`.
