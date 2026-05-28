# 03. Indexes and Access Paths

## Docs
- Indexes intro: https://www.postgresql.org/docs/current/indexes.html
- Index types: https://www.postgresql.org/docs/current/indexes-types.html
- Multicolumn indexes: https://www.postgresql.org/docs/current/indexes-multicolumn.html
- Expression indexes: https://www.postgresql.org/docs/current/indexes-expressional.html
- Partial indexes: https://www.postgresql.org/docs/current/indexes-partial.html
- CREATE INDEX: https://www.postgresql.org/docs/current/sql-createindex.html

## Q1. B-tree baseline
Task:
Create a large-ish table and compare query plan before/after adding B-tree index on filter column.

Verification:
- Use `EXPLAIN (ANALYZE, BUFFERS)` and compare node types.

## Q2. Multicolumn index ordering
Task:
Create `(a, b)` index and test queries filtering by:
- `a` only
- `a, b`
- `b` only

Verification:
- Compare index usage across query patterns.

## Q3. Expression index
Task:
Index `lower(email)` and query case-insensitively.

Verification:
- Ensure planner uses expression index for matching expression.

## Q4. Partial index
Task:
Create partial index for active rows only.

Verification:
- Show query that can use partial index and one that cannot.

## Q5. Covering index (`INCLUDE`)
Task:
Use `INCLUDE` columns to enable index-only scan for selected columns.

Verification:
- Observe index-only scan possibility in plan.

## Q6. Unique index as data rule
Task:
Implement business rule via unique index (e.g., one active subscription per user).

Verification:
- Attempt violating insert/update.

## Q7. Reindex and maintenance thought drill
Task:
List commands and when to use `REINDEX` vs routine vacuum/analyze.

Verification:
- Provide short justification for each choice.
