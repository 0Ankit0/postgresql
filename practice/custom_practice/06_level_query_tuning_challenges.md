# Level 6: Advanced Logic + Query Tuning Challenges

These are result-oriented questions with a performance mindset. Solve correctly first, then optimize.

## Q1. Top 2 cities by delivered revenue
Task:
Find top 2 cities ranked by delivered revenue.

Tip:
Join customers -> orders -> order_items, filter delivered, aggregate by city.

Expected output:
| city | delivered_revenue |
|---|---|
| Pune | 15400.00 |
| Mumbai | 11600.00 |

## Q2. June login-to-purchase conversion rate
Task:
Among users who logged in during June, what percent also made at least one purchase event in June?

Tip:
Build user-level flags with conditional aggregation.

Expected output:
| june_login_users | june_converted_users | conversion_pct |
|---|---|---|
| 6 | 5 | 83.33 |

## Q3. Repeat customer rate (delivered orders)
Task:
Among customers with at least one delivered order, what percent have 2+ delivered orders?

Tip:
Count delivered orders per customer in a CTE, then calculate the ratio.

Expected output:
| customers_with_delivered | repeat_customers | repeat_rate_pct |
|---|---|---|
| 6 | 2 | 33.33 |

## Q4. Payment success rate
Task:
Compute payment success rate as `paid / total_payments * 100`.

Tip:
Use `COUNT(*) FILTER (WHERE payment_status = 'paid')`.

Expected output:
| total_payments | paid_payments | payment_success_pct |
|---|---|---|
| 9 | 8 | 88.89 |

## Q5. Highest-rated product with at least 2 reviews
Task:
Find product with highest average rating among products having at least 2 reviews.

Tip:
Use `HAVING COUNT(*) >= 2` and `ORDER BY avg_rating DESC`.

Expected output:
| product_name | avg_rating | review_count |
|---|---|---|
| Keyboard | 4.50 | 2 |

## Q6. Customers whose latest order is delivered but previous order was not delivered
Task:
Find customers where latest order is delivered and immediately previous order was pending/returned.

Tip:
Use `LAG(status)` on each customer's ordered history.

Expected output:
| customer_id | customer_name | latest_order_id | latest_status | prev_status |
|---|---|---|---|---|
| 1 | Asha | 10 | delivered | returned |
| 5 | Isha | 9 | delivered | pending |

## Q7. Revenue share by customer
Task:
For delivered orders, show each customer's spend and percentage contribution to total delivered revenue.

Tip:
Use window sum for denominator.

Expected output:
| customer_name | delivered_spend | revenue_share_pct |
|---|---|---|
| Ravi | 15400.00 | 41.40 |
| Asha | 7300.00 | 19.62 |
| Isha | 5200.00 | 13.98 |
| Karan | 4300.00 | 11.56 |
| Omar | 3000.00 | 8.06 |
| Neha | 2000.00 | 5.38 |
| Priya | 0.00 | 0.00 |

## Q8. 90th percentile delivered order value
Task:
Find the 90th percentile of delivered order totals.

Tip:
Use `percentile_cont(0.9)` with `WITHIN GROUP`.

Expected output:
| p90_order_value |
|---|
| 7360.00 |

## Q9. Tuning prompt: delivered revenue by month
Task:
Write a query for monthly delivered revenue, then compare plan before/after adding useful indexes.

Tip:
Try `EXPLAIN (ANALYZE, BUFFERS)` and check if index scan appears.

Expected output:
| month | delivered_revenue |
|---|---|
| 2024-05-01 | 7300.00 |
| 2024-06-01 | 24900.00 |
| 2024-07-01 | 5000.00 |

## Q10. Tuning prompt: latest event per user
Task:
Return latest event row per user efficiently and evaluate alternative SQL forms.

Tip:
Compare `DISTINCT ON`, window function, and lateral join approaches.

Expected output:
| user_id | event_type | event_time | device |
|---|---|---|---|
| 1 | login | 2024-07-01 10:00:00 | web |
| 2 | purchase | 2024-06-15 11:00:00 | web |
| 3 | login | 2024-06-11 12:00:00 | app |
| 4 | purchase | 2024-06-01 14:20:00 | store_kiosk |
| 5 | purchase | 2024-06-20 17:40:00 | web |
| 6 | login | 2024-07-10 09:00:00 | app |
