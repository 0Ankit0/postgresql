# 04. Aggregates and Grouping Sets

DevDocs links:
- Aggregate functions: https://devdocs.io/postgresql/functions-aggregate
- SELECT GROUP BY clause: https://devdocs.io/postgresql/sql-select

Concepts from docs:
- aggregate null behavior (`sum` null on empty input)
- `FILTER` on aggregates
- ordered-set aggregates (`percentile_cont`, `percentile_disc`, `mode`)
- `ROLLUP`, `CUBE`, `GROUPING SETS`
- `GROUPING()` bitmask
- input-order-sensitive aggregates and `ORDER BY` inside aggregate calls

## Q1. Null aggregate behavior
Task:
Run an aggregate over a filter that matches zero rows and compare raw `SUM(...)` vs `COALESCE(SUM(...),0)`.

Tip:
Use a deliberately impossible filter.

## Q2. Filter aggregates in one pass
Task:
Return one row with counts for delivered, pending, returned orders using `COUNT(*) FILTER (...)`.

Tip:
Avoid multiple scans/subqueries.

## Q3. Ordered input-sensitive aggregate
Task:
Build a comma-separated product list per order with `string_agg`, sorted by product name.

Tip:
Use `string_agg(product_name, ', ' ORDER BY product_name)`.

## Q4. Continuous and discrete percentile
Task:
Compute `percentile_cont(0.5)` and `percentile_disc(0.5)` for paid amounts.

Tip:
Compare interpolation vs discrete behavior.

## Q5. ROLLUP and GROUPING
Task:
Aggregate order count by `(status, channel)` using `ROLLUP`, and include `GROUPING(status, channel)`.

Tip:
Use grouping bitmask to distinguish subtotal/grand-total rows.

## Q6. GROUPING SETS
Task:
Produce exactly these grouping levels for delivered revenue:
- by `status`
- by `channel`
- grand total

Tip:
Use `GROUPING SETS ((status), (channel), ())`.

## Q7. CUBE mini-analysis
Task:
For count of orders by `(status, channel)`, generate all subtotal combinations with `CUBE`.

Tip:
Compare row count from CUBE vs ROLLUP.

## Q8. mode() within group
Task:
Compute modal payment method using `mode() WITHIN GROUP (ORDER BY method)`.

Tip:
Use paid payments only.

## Q9. Hypothetical rank
Task:
Compute hypothetical rank of payment amount `5000` using ordered-set rank aggregate syntax.

Tip:
Use `rank(5000) WITHIN GROUP (ORDER BY amount)`.
