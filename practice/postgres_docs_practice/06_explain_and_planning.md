# 06. EXPLAIN and Planning Practice

DevDocs links:
- EXPLAIN usage: https://devdocs.io/postgresql/using-explain
- EXPLAIN command reference: https://devdocs.io/postgresql/sql-explain

Concepts from docs:
- plan tree reading (scan/join/sort nodes)
- cost, rows, width estimates
- `EXPLAIN ANALYZE` actual metrics and loops
- how `LIMIT` can change plan choice
- index condition vs filter
- caveats of small datasets
- subplans, hashed subplans, initplans

## Q1. Baseline plan
Task:
Run `EXPLAIN` for `SELECT * FROM orders`.

Tip:
Identify scan node type and estimated rows.

## Q2. Predicate selectivity change
Task:
Compare plans for:
1. broad filter (`order_date >= '2024-05-01'`)
2. selective filter (`order_id = 10`)

Tip:
Note when planner prefers index-like path vs sequential scan.

## Q3. Index condition vs filter
Task:
Explain a query where one condition is used as index condition and another appears as filter.

Tip:
Use conditions across different columns.

## Q4. LIMIT-driven plan shift
Task:
Compare `EXPLAIN` with and without `LIMIT 1` on a filtered query.

Tip:
Observe startup vs total cost tradeoff.

## Q5. Join strategy observation
Task:
Run `EXPLAIN` on a join between `orders` and `order_items` and identify join node (`Nested Loop`, `Hash Join`, or `Merge Join`).

Tip:
Change selectivity and see if strategy changes.

## Q6. EXPLAIN ANALYZE validation
Task:
Run `EXPLAIN (ANALYZE, BUFFERS)` on one aggregate query and compare estimated vs actual rows.

Tip:
Look for biggest estimation mismatch.

## Q7. Safe analyze for data-modifying statement
Task:
Wrap an `EXPLAIN ANALYZE UPDATE ...` inside `BEGIN; ... ROLLBACK;`.

Tip:
This mirrors docs guidance for avoiding persistent side effects while measuring.

## Q8. Plan forcing experiment
Task:
Temporarily disable one planner method (example: merge join) and compare plan.

Tip:
Use `SET enable_mergejoin = off` (or similar), then reset after test.

## Q9. Subplan behavior
Task:
Write a query with `NOT IN (subquery)` and inspect whether planner uses hashed subplan.

Tip:
Use `EXPLAIN` and inspect `SubPlan` details.

## Q10. Initplan behavior
Task:
Write a query where scalar subquery is independent of outer row and inspect `InitPlan` use.

Tip:
Example pattern: compare column to `(SELECT ...)` single-row expression.
