# 01. SELECT Processing and Joins

DevDocs links:
- SELECT command: https://devdocs.io/postgresql/sql-select
- Joins tutorial: https://devdocs.io/postgresql/tutorial-join

Concepts from docs:
- SELECT pipeline order (`FROM` -> `WHERE` -> `GROUP BY` -> `HAVING` -> output -> `DISTINCT` -> set ops -> `ORDER BY` -> `LIMIT/FETCH`)
- Explicit vs implicit joins
- `LEFT/RIGHT/FULL` outer join semantics
- `DISTINCT ON` + leftmost `ORDER BY`
- `LATERAL`
- `UNION`, `INTERSECT`, `EXCEPT`
- `TABLE` command
- Locking clause (`FOR UPDATE`, `SKIP LOCKED`, `NOWAIT`) at query level

## Q1. Explicit vs implicit join
Task:
Write two equivalent queries that return delivered orders with customer names:
1. explicit `JOIN ... ON`
2. implicit `FROM a, b WHERE ...`

Tip:
Return columns: `order_id, customer_name, order_date`.

## Q2. LEFT JOIN null-extended rows
Task:
List all customers and their order IDs, including customers with no orders.

Tip:
Use `LEFT JOIN` and sort by customer then order.

Expected characteristic:
`Priya` must appear with a null order ID.

## Q3. FULL OUTER JOIN check
Task:
Perform a `FULL OUTER JOIN` between customers and orders on customer id and show rows where either side is unmatched.

Tip:
Filter with `WHERE c.customer_id IS NULL OR o.order_id IS NULL`.

Expected characteristic:
You should see the unmatched customer row only (with this dataset).

## Q4. DISTINCT ON latest order per customer
Task:
Get latest order row per customer using `DISTINCT ON`.

Tip:
`DISTINCT ON (customer_id)` requires `ORDER BY customer_id, order_date DESC, order_id DESC`.

## Q5. ORDER BY + FETCH WITH TIES
Task:
Return top 3 highest priced products using `FETCH FIRST ... WITH TIES`.

Tip:
This can return more than 3 rows if the cutoff has ties.

## Q6. LIMIT/OFFSET determinism
Task:
Write two versions of query for rows 3 to 5 of orders:
1. without `ORDER BY`
2. with deterministic `ORDER BY order_date, order_id`

Tip:
Explain why one is unstable.

## Q7. LATERAL top item per order
Task:
For each order, return exactly one item row: the highest line value (`quantity * unit_price`).

Tip:
Use `LEFT JOIN LATERAL (...) ON TRUE` and `ORDER BY ... LIMIT 1` in the lateral subquery.

## Q8. USING syntax and duplicate join columns
Task:
Join `orders` and `payments` using `USING (order_id)` and show how output differs from `ON` in terms of duplicate columns.

Tip:
Inspect selected columns in each version.

## Q9. UNION vs UNION ALL
Task:
Return cities from `customers` and channels from `orders` as one-column text output using:
1. `UNION`
2. `UNION ALL`

Tip:
Observe deduplication difference.

## Q10. INTERSECT
Task:
Find values that appear in both sets:
- customer cities
- a literal set `('Mumbai','Delhi','Kolkata')`

Tip:
Use compatible types and one-column shape.

## Q11. EXCEPT
Task:
Find customer cities that are not in literal set `('Mumbai','Delhi')`.

Tip:
`EXCEPT` removes duplicates by default.

## Q12. TABLE command
Task:
Use `TABLE customers` and equivalent `SELECT * FROM customers`; compare results.

Tip:
Practice `TABLE` as shorthand.

## Q13. Locking clause (practice form)
Task:
Write a queue-style query over `orders` that selects pending rows with:
`FOR UPDATE SKIP LOCKED`.

Tip:
Use deterministic `ORDER BY` and `LIMIT`.

## Q14. FETCH syntax parity
Task:
Write equivalent pagination queries using:
1. `LIMIT ... OFFSET ...`
2. `OFFSET ... FETCH NEXT ... ROWS ONLY`

Tip:
Confirm identical rowset with stable ordering.
