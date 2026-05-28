# Level 5: Advanced PostgreSQL

## Q1. Employee hierarchy depth (recursive CTE)
Task:
Build an org hierarchy starting from top manager(s), and show each employee with level depth.

Tip:
Use `WITH RECURSIVE` and start from `manager_id IS NULL`.

Expected output:
| employee_id | employee_name | manager_id | level |
|---|---|---|---|
| 1 | Anil | null | 1 |
| 2 | Bhavna | 1 | 2 |
| 3 | Chetan | 1 | 2 |
| 4 | Divya | 3 | 3 |
| 5 | Esha | 3 | 3 |
| 6 | Farhan | 2 | 3 |
| 7 | Gauri | 2 | 3 |
| 8 | Harsh | 4 | 4 |
| 9 | Ira | 4 | 4 |

## Q2. Reporting chain for Harsh
Task:
Return the full manager chain for employee `Harsh` from top to bottom.

Tip:
Recursive CTE can traverse upward and then reverse with an ordering key.

Expected output:
| reporting_chain |
|---|
| Anil > Chetan > Divya > Harsh |

## Q3. Latest event per user (DISTINCT ON)
Task:
Return each user's latest event.

Tip:
PostgreSQL `DISTINCT ON (user_id)` + `ORDER BY user_id, event_time DESC`.

Expected output:
| user_id | event_type | event_time | device |
|---|---|---|---|
| 1 | login | 2024-07-01 10:00:00 | web |
| 2 | purchase | 2024-06-15 11:00:00 | web |
| 3 | login | 2024-06-11 12:00:00 | app |
| 4 | purchase | 2024-06-01 14:20:00 | store_kiosk |
| 5 | purchase | 2024-06-20 17:40:00 | web |
| 6 | login | 2024-07-10 09:00:00 | app |

## Q4. April cohort retention into July
Task:
Take users who signed up in April 2024 and compute how many logged in during July 2024.

Tip:
Use a cohort CTE and a second CTE for July active users.

Expected output:
| cohort_month | cohort_size | retained_users | retention_pct |
|---|---|---|---|
| 2024-04-01 | 2 | 1 | 50.00 |

## Q5. Monthly revenue via date spine (generate_series)
Task:
Generate monthly buckets using `generate_series`, then left join delivered revenue.

Tip:
Date spine prevents missing months in reports.

Expected output:
| month | delivered_revenue |
|---|---|
| 2024-05-01 | 7300.00 |
| 2024-06-01 | 24900.00 |
| 2024-07-01 | 5000.00 |

## Q6. Tier counts using FILTER
Task:
Return one row with customer counts per tier as separate columns.

Tip:
`COUNT(*) FILTER (WHERE tier = 'gold')` is cleaner than many CASE expressions.

Expected output:
| gold_count | silver_count | bronze_count |
|---|---|---|
| 2 | 3 | 2 |

## Q7. ROLLUP: order count by status and channel
Task:
Use `GROUP BY ROLLUP(status, channel)` for detail + subtotal + grand total.

Tip:
Use `COALESCE` in output labels if you want readable subtotal rows.

Expected output:
| status | channel | order_count |
|---|---|---|
| delivered | app | 4 |
| delivered | store | 1 |
| delivered | web | 3 |
| delivered | null | 8 |
| pending | web | 1 |
| pending | null | 1 |
| returned | web | 1 |
| returned | null | 1 |
| null | null | 10 |

## Q8. Days between consecutive orders per customer
Task:
For each customer with multiple orders, compute day gap between consecutive orders.

Tip:
Use `LAG(order_date)` partitioned by customer.

Expected output:
| customer_id | order_id | order_date | prev_order_date | gap_days |
|---|---|---|---|---|
| 1 | 3 | 2024-05-10 | 2024-05-01 | 9 |
| 1 | 10 | 2024-07-01 | 2024-05-10 | 52 |
| 2 | 8 | 2024-06-15 | 2024-05-02 | 44 |
| 5 | 9 | 2024-06-20 | 2024-06-03 | 17 |

## Q9. Outlier paid transactions
Task:
Find paid transactions where amount is greater than `(avg + stddev_samp)`.

Tip:
Compute threshold in a CTE first.

Expected output:
| payment_id | amount |
|---|---|
| 7 | 12400.00 |

## Q10. Product basket per customer (array_agg)
Task:
For delivered orders, return each customer's distinct purchased products as an array.

Tip:
Use `array_agg(DISTINCT product_name ORDER BY product_name)`.

Expected output:
| customer_id | product_basket |
|---|---|
| 1 | {Keyboard,USB-C Cable,Webcam} |
| 2 | {Laptop Stand,Monitor,Mouse,USB-C Cable} |
| 3 | {Mouse,USB-C Cable} |
| 4 | {USB-C Cable,Webcam} |
| 5 | {Laptop Stand,Mouse} |
| 6 | {Keyboard} |
