# Level 3: Medium (Joins and Subqueries)

## Q1. Customer lifetime spend (delivered only)
Task:
Return each customer and total delivered spend.

Tip:
Use `LEFT JOIN` so customers with no orders still appear.

Expected output:
| customer_id | customer_name | lifetime_spend |
|---|---|---|
| 2 | Ravi | 15400.00 |
| 1 | Asha | 7300.00 |
| 5 | Isha | 5200.00 |
| 4 | Karan | 4300.00 |
| 6 | Omar | 3000.00 |
| 3 | Neha | 2000.00 |
| 7 | Priya | 0.00 |

## Q2. Highest spending customer
Task:
Find the customer with the highest delivered spend.

Tip:
Reuse lifetime-spend logic in a CTE, then pick top 1.

Expected output:
| customer_name | lifetime_spend |
|---|---|
| Ravi | 15400.00 |

## Q3. Delivered orders by channel
Task:
Count delivered orders grouped by channel.

Tip:
This checks your grouped filtering logic.

Expected output:
| channel | delivered_orders |
|---|---|
| app | 4 |
| store | 1 |
| web | 3 |

## Q4. Customers who bought a Monitor in delivered orders
Task:
Find distinct customers who purchased product `Monitor` in delivered orders.

Tip:
Join `orders`, `order_items`, `products`, and `customers`.

Expected output:
| customer_id | customer_name |
|---|---|
| 2 | Ravi |

## Q5. Products bought with USB-C Cable
Task:
Find products that appeared in the same order as `USB-C Cable` (excluding `USB-C Cable`).

Tip:
Self-join `order_items` by `order_id`.

Expected output:
| product_name |
|---|
| Keyboard |
| Monitor |
| Mouse |
| Webcam |

## Q6. Customers with at least one returned order
Task:
List customers who ever had an order with status `returned`.

Tip:
Use `EXISTS` for readable intent.

Expected output:
| customer_id | customer_name |
|---|---|
| 1 | Asha |

## Q7. Second highest spender
Task:
Get the customer with the second highest delivered spend.

Tip:
Use `DENSE_RANK()` or `ORDER BY ... OFFSET 1 LIMIT 1`.

Expected output:
| customer_name | lifetime_spend |
|---|---|
| Asha | 7300.00 |

## Q8. Revenue by category (delivered only)
Task:
Compute delivered revenue by product category.

Tip:
Category comes from `products`; revenue comes from `order_items`.

Expected output:
| category | revenue |
|---|---|
| Accessories | 18200.00 |
| Displays | 12000.00 |
| Electronics | 7000.00 |

## Q9. Customers with orders in both May and June 2024
Task:
Find customers who placed at least one order in May and at least one order in June.

Tip:
Use conditional aggregation with `COUNT(*) FILTER (...)`.

Expected output:
| customer_id | customer_name |
|---|---|
| 2 | Ravi |

## Q10. Latest order per customer
Task:
For each customer, return latest order date and status.

Tip:
Use `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC)`.

Expected output:
| customer_id | customer_name | latest_order_date | latest_status |
|---|---|---|---|
| 1 | Asha | 2024-07-01 | delivered |
| 2 | Ravi | 2024-06-15 | delivered |
| 3 | Neha | 2024-05-11 | delivered |
| 4 | Karan | 2024-06-01 | delivered |
| 5 | Isha | 2024-06-20 | delivered |
| 6 | Omar | 2024-06-10 | delivered |
| 7 | Priya | null | null |
