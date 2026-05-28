# Level 2: Easy to Medium (Aggregates and Core Logic)

## Q1. Compute total for each order
Task:
For each order, compute `order_total = SUM(quantity * unit_price)`.

Tip:
Aggregate on `order_id` from `order_items`.

Expected output:
| order_id | order_total |
|---|---|
| 1 | 2300.00 |
| 2 | 3000.00 |
| 3 | 12000.00 |
| 4 | 2000.00 |
| 5 | 4300.00 |
| 6 | 6500.00 |
| 7 | 3000.00 |
| 8 | 12400.00 |
| 9 | 5200.00 |
| 10 | 5000.00 |

## Q2. Total delivered revenue
Task:
Find total revenue from delivered orders only.

Tip:
Join `orders` to `order_items` and filter by `status = 'delivered'`.

Expected output:
| delivered_revenue |
|---|
| 37200.00 |

## Q3. Top 3 most expensive active products
Task:
Return top 3 active products by price descending.

Tip:
Use `ORDER BY price DESC LIMIT 3`.

Expected output:
| product_name | price |
|---|---|
| Monitor | 12000.00 |
| Noise Cancelling Headset | 6500.00 |
| Webcam | 3500.00 |

## Q4. Average product rating (only products with 2+ reviews)
Task:
Show products with at least 2 reviews and their average rating.

Tip:
Use `HAVING COUNT(*) >= 2`.

Expected output:
| product_id | avg_rating | review_count |
|---|---|---|
| 1 | 4.50 | 2 |
| 3 | 3.50 | 2 |

## Q5. Customers with more than one order
Task:
Return customers who placed at least 2 orders.

Tip:
Group by `customer_id` and filter in `HAVING`.

Expected output:
| customer_id | customer_name | order_count |
|---|---|---|
| 1 | Asha | 3 |
| 2 | Ravi | 2 |
| 5 | Isha | 2 |

## Q6. Monthly order volume
Task:
Count orders per month.

Tip:
Use `date_trunc('month', order_date)`.

Expected output:
| month | order_count |
|---|---|
| 2024-05-01 | 4 |
| 2024-06-01 | 5 |
| 2024-07-01 | 1 |

## Q7. Paid amount by payment method
Task:
Find total paid amount by payment method (exclude refunded/failed).

Tip:
Filter `payment_status = 'paid'`.

Expected output:
| method | total_paid |
|---|---|
| card | 20400.00 |
| cash | 4300.00 |
| upi | 12500.00 |

## Q8. Products never ordered
Task:
Find products that do not appear in `order_items`.

Tip:
Use `LEFT JOIN ... WHERE order_items.product_id IS NULL`.

Expected output:
| product_id | product_name |
|---|---|
| 8 | Mechanical Keyboard Pro |

## Q9. Customers with zero orders
Task:
Find customers who never placed an order.

Tip:
Left join `customers` to `orders` and filter null order side.

Expected output:
| customer_id | customer_name |
|---|---|
| 7 | Priya |

## Q10. Average order value for delivered orders
Task:
Compute average `order_total` for delivered orders.

Tip:
First compute order totals in a subquery/CTE, then average.

Expected output:
| avg_order_value |
|---|
| 4650.00 |
