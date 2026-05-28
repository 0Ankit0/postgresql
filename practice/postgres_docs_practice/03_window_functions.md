# 03. Window Functions

DevDocs links:
- Window tutorial: https://devdocs.io/postgresql/tutorial-window
- SELECT WINDOW clause details: https://devdocs.io/postgresql/sql-select

Concepts from docs:
- `OVER`, `PARTITION BY`, `ORDER BY`
- ranking functions
- frame defaults and running aggregates
- named windows via `WINDOW` clause
- filtering after window via subquery
- frame modes (`ROWS`, `RANGE`, `GROUPS`) and frame exclusions

## Q1. Department-style average analogy
Task:
For each customer order, show order total and average order total for that customer.

Tip:
Use `AVG(order_total) OVER (PARTITION BY customer_id)`.

## Q2. Rank orders by value per customer
Task:
Assign `row_number`, `rank`, and `dense_rank` to orders per customer by descending order total.

Tip:
Use same partition/order in three functions to compare behavior with ties.

## Q3. Running delivered revenue by month
Task:
Compute monthly delivered revenue and running total.

Tip:
Use a monthly CTE + `SUM(...) OVER (ORDER BY month)`.

## Q4. Demonstrate default frame behavior
Task:
Using paid transactions ordered by amount, compute cumulative amount with default frame.

Tip:
`SUM(amount) OVER (ORDER BY amount)` includes peers with same sort value.

## Q5. Custom frame
Task:
For events per user ordered by time, compute previous + current + next event count marker using `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`.

Tip:
Window aggregates with custom frame highlight frame boundaries.

## Q6. Top 2 orders per customer
Task:
Return top 2 orders by value for each customer.

Tip:
Compute `row_number` in subquery then filter `<= 2` outside.

## Q7. Named WINDOW clause
Task:
Use one named window to compute both `sum(order_total)` and `avg(order_total)` over the same partition/order.

Tip:
`WINDOW w AS (...)` avoids repetition.

## Q8. RANGE vs ROWS comparison
Task:
On paid transactions ordered by amount, compare cumulative sum with:
1. `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
2. default `RANGE` frame

Tip:
Observe peer-row behavior.

## Q9. Frame exclusion
Task:
Build running sum per user events but exclude current row from frame.

Tip:
Use `EXCLUDE CURRENT ROW`.
