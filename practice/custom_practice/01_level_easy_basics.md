# Level 1: Easy Basics

## Q1. List all customers
Task:
Return all customers ordered by `customer_id`.

Tip:
Use `ORDER BY customer_id` for deterministic output.

Expected output:
| customer_id | customer_name | city | signup_date | tier |
|---|---|---|---|---|
| 1 | Asha | Mumbai | 2024-01-10 | gold |
| 2 | Ravi | Pune | 2024-02-15 | silver |
| 3 | Neha | Delhi | 2024-03-01 | bronze |
| 4 | Karan | Mumbai | 2024-03-20 | silver |
| 5 | Isha | Bengaluru | 2024-04-05 | gold |
| 6 | Omar | Delhi | 2024-04-18 | bronze |
| 7 | Priya | Chennai | 2024-06-25 | silver |

## Q2. Show active products with price
Task:
Return `product_name` and `price` for active products only, sorted by price ascending.

Tip:
Use `WHERE is_active = TRUE`.

Expected output:
| product_name | price |
|---|---|
| USB-C Cable | 400.00 |
| Mouse | 800.00 |
| Keyboard | 1500.00 |
| Laptop Stand | 2200.00 |
| Webcam | 3500.00 |
| Noise Cancelling Headset | 6500.00 |
| Monitor | 12000.00 |

## Q3. Filter customers by city
Task:
Get customers from Mumbai or Delhi.

Tip:
Use `IN ('Mumbai', 'Delhi')`.

Expected output:
| customer_name | city |
|---|---|
| Asha | Mumbai |
| Neha | Delhi |
| Karan | Mumbai |
| Omar | Delhi |

## Q4. June delivered orders
Task:
Find all delivered orders in June 2024.

Tip:
Use a date range filter with `>=` and `<`.

Expected output:
| order_id | customer_id | order_date | status |
|---|---|---|---|
| 5 | 4 | 2024-06-01 | delivered |
| 7 | 6 | 2024-06-10 | delivered |
| 8 | 2 | 2024-06-15 | delivered |
| 9 | 5 | 2024-06-20 | delivered |

## Q5. Customer count by tier
Task:
Count how many customers are in each tier.

Tip:
Use `GROUP BY tier` and `COUNT(*)`.

Expected output:
| tier | customer_count |
|---|---|
| bronze | 2 |
| gold | 2 |
| silver | 3 |

## Q6. Order count by status
Task:
Count orders by status.

Tip:
Use `GROUP BY status` and sort by status for stable output.

Expected output:
| status | order_count |
|---|---|
| delivered | 8 |
| pending | 1 |
| returned | 1 |

## Q7. Customer count by city
Task:
Count customers per city.

Tip:
Alias your count column for readability.

Expected output:
| city | customer_count |
|---|---|
| Bengaluru | 1 |
| Chennai | 1 |
| Delhi | 2 |
| Mumbai | 2 |
| Pune | 1 |

## Q8. Mid-range active products
Task:
List active products with price between 1000 and 4000.

Tip:
`BETWEEN` is inclusive.

Expected output:
| product_name | price |
|---|---|
| Keyboard | 1500.00 |
| Laptop Stand | 2200.00 |
| Webcam | 3500.00 |

## Q9. Distinct order channels
Task:
Return unique channels used in orders.

Tip:
Use `SELECT DISTINCT channel`.

Expected output:
| channel |
|---|
| app |
| store |
| web |

## Q10. First and last order date
Task:
Return earliest and latest `order_date`.

Tip:
Use `MIN` and `MAX` aggregate functions.

Expected output:
| first_order_date | last_order_date |
|---|---|
| 2024-05-01 | 2024-07-01 |
