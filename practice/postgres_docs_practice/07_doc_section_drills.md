# 07. Doc Section -> Focused Drills

Use this file as a fast bridge from PostgreSQL docs reading to deliberate practice.

Workflow per section:
1. Read the linked documentation section.
2. Solve the 3 drills without looking at reference solutions.
3. Validate with `EXPLAIN` where relevant.
4. Record your mistakes and rewrite query once.

## A. SELECT Semantics and Query Shape
Doc:
- https://devdocs.io/postgresql/sql-select

Drill A1:
Task:
Write one query that returns latest order per customer using `DISTINCT ON`, and another using window function + subquery.

Target skill:
- Understand `DISTINCT ON` ordering rules vs row_number filtering.

Drill A2:
Task:
Create two equivalent queries for delivered orders by customer:
- one with explicit join syntax
- one with implicit join syntax
Then explain why explicit join is safer for readability.

Target skill:
- Internalize join condition placement and maintainability.

Drill A3:
Task:
Show top 5 expensive line items with deterministic pagination (stable `ORDER BY` + `OFFSET/FETCH`).
Then show a non-deterministic version and explain the risk.

Target skill:
- Correct mental model for result ordering and paging.

## B. Joins and Outer Join Behavior
Doc:
- https://devdocs.io/postgresql/tutorial-join

Drill B1:
Task:
Using customers/orders, return all customers even without orders and label unmatched rows.

Target skill:
- Null-extended row behavior in `LEFT JOIN`.

Drill B2:
Task:
Write a self-join over employees to return employee + direct manager names.

Target skill:
- Alias discipline for self-joins.

Drill B3:
Task:
Write one query with `JOIN ... USING` and another with `JOIN ... ON` for orders/payments.
Compare output column shape.

Target skill:
- Practical difference between `USING` and `ON`.

## C. WITH and Recursive CTE
Doc:
- https://devdocs.io/postgresql/queries-with

Drill C1:
Task:
Build a two-layer CTE pipeline:
- per-customer delivered spend
- customers above average spend
Return sorted result.

Target skill:
- Decompose complex logic with CTEs.

Drill C2:
Task:
On `docs_graph`, recursively walk from `id = 1`, keep path array, and mark cycles.

Target skill:
- Safe recursion with visited-path tracking.

Drill C3:
Task:
Write a CTE used twice in parent query. Compare plans with:
- default
- `MATERIALIZED`
- `NOT MATERIALIZED`

Target skill:
- Understand folding/materialization tradeoffs.

## D. Window Functions and Frames
Doc:
- https://devdocs.io/postgresql/tutorial-window

Drill D1:
Task:
For each customer order, compute:
- order total
- cumulative total per customer
- moving 3-row average per customer

Target skill:
- Partitioning + custom row frames.

Drill D2:
Task:
Return top 2 orders per customer by total value using `row_number` and outer filter.

Target skill:
- Correct post-window filtering pattern.

Drill D3:
Task:
Use named `WINDOW` clause to compute rank and dense rank over same definition.

Target skill:
- Reduce repetition and avoid over-clause errors.

## E. Aggregates and Grouping Sets
Doc:
- https://devdocs.io/postgresql/functions-aggregate

Drill E1:
Task:
In one query, compute status counts using `COUNT(*) FILTER (...)` columns.

Target skill:
- Multi-metric aggregation in one pass.

Drill E2:
Task:
Compute p50 and p90 of paid amounts using `percentile_cont`.
Compare with `percentile_disc`.

Target skill:
- Ordered-set aggregate semantics.

Drill E3:
Task:
Use `ROLLUP(status, channel)` and output `GROUPING(status, channel)` bitmask.
Label row type as detail/subtotal/grand_total.

Target skill:
- Interpret subtotal rows programmatically.

## F. Arrays and JSON
Doc:
- https://devdocs.io/postgresql/functions-array
- https://devdocs.io/postgresql/functions-json

Drill F1:
Task:
Build array basket per customer and test overlap between two chosen customer baskets.

Target skill:
- `array_agg`, overlap/containment operators.

Drill F2:
Task:
From `docs_json_feed` (feed 1), extract all HR values over 100 via jsonpath and compute max HR.

Target skill:
- `jsonb_path_query` and scalar extraction.

Drill F3:
Task:
From `docs_json_feed` (feed 2), unnest favorites -> films into relational rows and aggregate titles per kind into json array.

Target skill:
- JSON-to-relational shaping and re-aggregation.

## G. EXPLAIN and Plan Reading
Doc:
- https://devdocs.io/postgresql/using-explain

Drill G1:
Task:
Pick a selective query and compare `EXPLAIN` vs `EXPLAIN (ANALYZE, BUFFERS)`.
List biggest row-estimate mismatch.

Target skill:
- Estimate-vs-actual diagnostics.

Drill G2:
Task:
Run same filtered query with and without `LIMIT 1`; compare chosen plan and startup/total costs.

Target skill:
- Why LIMIT can change access strategy.

Drill G3:
Task:
Temporarily disable one join strategy (example: merge join), run a join query, compare the new plan, and then reset setting.

Target skill:
- Planner experimentation for learning, not production tuning.

## Suggested Progression

1. Day 1: Sections A + B
2. Day 2: Section C
3. Day 3: Section D
4. Day 4: Section E
5. Day 5: Section F
6. Day 6: Section G

## Optional Reflection Template

After each drill, write:
- What I expected:
- What actually happened:
- One planner/runtime clue I noticed:
- Final corrected query pattern to remember:
