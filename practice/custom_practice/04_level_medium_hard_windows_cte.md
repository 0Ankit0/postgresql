# Level 4: Medium-Hard (Window Functions and CTEs)

## Q1. Monthly delivered revenue + running total
Task:
Return delivered revenue per month and cumulative revenue over time.

Tip:
Use a monthly CTE and `SUM(month_revenue) OVER (ORDER BY month)`.

Expected output:
| month | month_revenue | running_revenue |
|---|---|---|
| 2024-05-01 | 7300.00 | 7300.00 |
| 2024-06-01 | 24900.00 | 32200.00 |
| 2024-07-01 | 5000.00 | 37200.00 |

## Q2. Rank customers by delivered spend
Task:
Rank all customers by delivered spend (highest first).

Tip:
Use `DENSE_RANK()` and `COALESCE` for customers with no spend.

Expected output:
| spend_rank | customer_name | delivered_spend |
|---|---|---|
| 1 | Ravi | 15400.00 |
| 2 | Asha | 7300.00 |
| 3 | Isha | 5200.00 |
| 4 | Karan | 4300.00 |
| 5 | Omar | 3000.00 |
| 6 | Neha | 2000.00 |
| 7 | Priya | 0.00 |

## Q3. Top-selling product in each category (by delivered quantity)
Task:
For each category, return the top product by delivered quantity.

Tip:
Aggregate first, then rank inside each category partition.

Expected output:
| category | product_name | sold_qty |
|---|---|---|
| Accessories | USB-C Cable | 8 |
| Displays | Monitor | 1 |
| Electronics | Webcam | 2 |

## Q4. Compare each delivered order against that customer's average delivered order value
Task:
For each delivered order, show order total, customer average, and difference.

Tip:
Build order totals first, then use `AVG(...) OVER (PARTITION BY customer_id)`.

Expected output:
| order_id | customer_id | order_total | customer_avg | diff_from_avg |
|---|---|---|---|---|
| 1 | 1 | 2300.00 | 3650.00 | -1350.00 |
| 10 | 1 | 5000.00 | 3650.00 | 1350.00 |
| 2 | 2 | 3000.00 | 7700.00 | -4700.00 |
| 8 | 2 | 12400.00 | 7700.00 | 4700.00 |
| 4 | 3 | 2000.00 | 2000.00 | 0.00 |
| 5 | 4 | 4300.00 | 4300.00 | 0.00 |
| 9 | 5 | 5200.00 | 5200.00 | 0.00 |
| 7 | 6 | 3000.00 | 3000.00 | 0.00 |

## Q5. Month-over-month revenue growth (%)
Task:
Compute MoM growth percentage for delivered revenue.

Tip:
Use `LAG(month_revenue)` and calculate percentage carefully.

Expected output:
| month | month_revenue | prev_month_revenue | mom_growth_pct |
|---|---|---|---|
| 2024-05-01 | 7300.00 | null | null |
| 2024-06-01 | 24900.00 | 7300.00 | 241.10 |
| 2024-07-01 | 5000.00 | 24900.00 | -79.92 |

## Q6. First delivered order date per customer
Task:
Return each customer with their first delivered order date.

Tip:
Use `MIN(order_date) FILTER (WHERE status = 'delivered')`.

Expected output:
| customer_name | first_delivered_date |
|---|---|
| Asha | 2024-05-01 |
| Ravi | 2024-05-02 |
| Neha | 2024-05-11 |
| Karan | 2024-06-01 |
| Isha | 2024-06-20 |
| Omar | 2024-06-10 |
| Priya | null |

## Q7. Sequence number of orders per customer
Task:
Assign sequence number to each order by customer order history.

Tip:
Use `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id)`.

Expected output:
| customer_id | order_id | order_date | order_sequence |
|---|---|---|---|
| 1 | 1 | 2024-05-01 | 1 |
| 1 | 3 | 2024-05-10 | 2 |
| 1 | 10 | 2024-07-01 | 3 |
| 2 | 2 | 2024-05-02 | 1 |
| 2 | 8 | 2024-06-15 | 2 |
| 3 | 4 | 2024-05-11 | 1 |
| 4 | 5 | 2024-06-01 | 1 |
| 5 | 6 | 2024-06-03 | 1 |
| 5 | 9 | 2024-06-20 | 2 |
| 6 | 7 | 2024-06-10 | 1 |

## Q8. Engaged users by event behavior
Task:
Find users with at least 2 login events and at least 1 purchase event.

Tip:
Use conditional aggregation with `COUNT(*) FILTER (WHERE ...)`.

Expected output:
| user_id |
|---|
| 1 |
| 2 |
| 5 |
| 6 |

## Q9. Running count of orders over time
Task:
Return each order with cumulative number of orders so far.

Tip:
Use `COUNT(*) OVER (ORDER BY order_date, order_id)`.

Expected output:
| order_id | order_date | running_order_count |
|---|---|---|
| 1 | 2024-05-01 | 1 |
| 2 | 2024-05-02 | 2 |
| 3 | 2024-05-10 | 3 |
| 4 | 2024-05-11 | 4 |
| 5 | 2024-06-01 | 5 |
| 6 | 2024-06-03 | 6 |
| 7 | 2024-06-10 | 7 |
| 8 | 2024-06-15 | 8 |
| 9 | 2024-06-20 | 9 |
| 10 | 2024-07-01 | 10 |

## Q10. Median paid transaction amount
Task:
Find median payment amount among paid transactions.

Tip:
In PostgreSQL use `percentile_cont(0.5) WITHIN GROUP (ORDER BY amount)`.

Expected output:
| median_paid_amount |
|---|
| 3650.00 |
