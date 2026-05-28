# 09. System Catalogs, Information Schema, and Introspection

## Docs
- System catalogs overview: https://www.postgresql.org/docs/current/catalogs.html
- System views: https://www.postgresql.org/docs/current/views.html
- Information schema: https://www.postgresql.org/docs/current/information-schema.html
- System columns (`ctid`, `xmin`, `tableoid`): https://www.postgresql.org/docs/current/ddl-system-columns.html
- Catalog info functions: https://www.postgresql.org/docs/current/functions-info.html

## Q1. List all user tables with ownership and estimated row count
Task:
Build a query using `pg_class`, `pg_namespace`, and `pg_roles`.

Verification:
- Return schema, table, owner, reltuples, and relation size.

## Q2. Introspect constraints by type
Task:
Query `pg_constraint` joined to `pg_class` to list PK/FK/UK/CHECK constraints.

Verification:
- Include referenced table details for FKs.

## Q3. Compare `information_schema` vs `pg_catalog`
Task:
Write one query for column metadata via `information_schema.columns` and one via `pg_attribute` + `pg_type`.

Verification:
- Explain portability vs PostgreSQL-specific depth.

## Q4. Detect unused or duplicate indexes (baseline heuristic)
Task:
Use `pg_stat_user_indexes` and `pg_indexes` to identify low-usage candidates.

Verification:
- Produce a review table, not auto-drop SQL.

## Q5. Use system columns carefully
Task:
Query a sample table including `ctid`, `xmin`, and `tableoid`.

Verification:
- Explain when these are useful and why they should not be business keys.

## Q6. Search path and object visibility checks
Task:
Use schema visibility functions (`pg_table_is_visible`, `to_regclass`) in a multi-schema setup.

Verification:
- Show two objects with same name and visibility behavior.

## Tip
Use `information_schema` for generic tooling and `pg_catalog` for precise PostgreSQL diagnostics.
