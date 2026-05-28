-- PostgreSQL Practice Reference Solutions
-- Try solving on your own before reading this file.

-- =====================
-- Level 1 Solutions
-- =====================

-- L1 Q1
SELECT customer_id, customer_name, city, signup_date, tier
FROM customers
ORDER BY customer_id;

-- L1 Q2
SELECT product_name, price
FROM products
WHERE is_active = TRUE
ORDER BY price;

-- L1 Q3
SELECT customer_name, city
FROM customers
WHERE city IN ('Mumbai', 'Delhi')
ORDER BY customer_id;

-- L1 Q4
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'delivered'
  AND order_date >= DATE '2024-06-01'
  AND order_date < DATE '2024-07-01'
ORDER BY order_id;

-- L1 Q5
SELECT tier, COUNT(*) AS customer_count
FROM customers
GROUP BY tier
ORDER BY tier;

-- L1 Q6
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;

-- L1 Q7
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY city;

-- L1 Q8
SELECT product_name, price
FROM products
WHERE is_active = TRUE
  AND price BETWEEN 1000 AND 4000
ORDER BY price;

-- L1 Q9
SELECT DISTINCT channel
FROM orders
ORDER BY channel;

-- L1 Q10
SELECT MIN(order_date) AS first_order_date,
       MAX(order_date) AS last_order_date
FROM orders;

-- =====================
-- Level 2 Solutions
-- =====================

-- L2 Q1
SELECT order_id,
       SUM(quantity * unit_price)::NUMERIC(12, 2) AS order_total
FROM order_items
GROUP BY order_id
ORDER BY order_id;

-- L2 Q2
SELECT SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered';

-- L2 Q3
SELECT product_name, price
FROM products
WHERE is_active = TRUE
ORDER BY price DESC
LIMIT 3;

-- L2 Q4
SELECT r.product_id,
       ROUND(AVG(r.rating)::NUMERIC, 2) AS avg_rating,
       COUNT(*) AS review_count
FROM reviews r
GROUP BY r.product_id
HAVING COUNT(*) >= 2
ORDER BY r.product_id;

-- L2 Q5
SELECT c.customer_id,
       c.customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY c.customer_id;

-- L2 Q6
SELECT DATE_TRUNC('month', order_date)::DATE AS month,
       COUNT(*) AS order_count
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- L2 Q7
SELECT method,
       SUM(amount)::NUMERIC(12, 2) AS total_paid
FROM payments
WHERE payment_status = 'paid'
GROUP BY method
ORDER BY method;

-- L2 Q8
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- L2 Q9
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- L2 Q10
WITH delivered_order_totals AS (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id
)
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM delivered_order_totals;

-- =====================
-- Level 3 Solutions
-- =====================

-- L3 Q1
WITH delivered_customer_spend AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
)
SELECT c.customer_id,
       c.customer_name,
       COALESCE(dcs.spend, 0)::NUMERIC(12, 2) AS lifetime_spend
FROM customers c
LEFT JOIN delivered_customer_spend dcs ON dcs.customer_id = c.customer_id
ORDER BY lifetime_spend DESC, c.customer_id;

-- L3 Q2
WITH delivered_customer_spend AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
)
SELECT c.customer_name, dcs.spend AS lifetime_spend
FROM delivered_customer_spend dcs
JOIN customers c ON c.customer_id = dcs.customer_id
ORDER BY dcs.spend DESC
LIMIT 1;

-- L3 Q3
SELECT channel, COUNT(*) AS delivered_orders
FROM orders
WHERE status = 'delivered'
GROUP BY channel
ORDER BY channel;

-- L3 Q4
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
  AND p.product_name = 'Monitor'
ORDER BY c.customer_id;

-- L3 Q5
SELECT DISTINCT p2.product_name
FROM orders o
JOIN order_items oi1 ON oi1.order_id = o.order_id
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN order_items oi2 ON oi2.order_id = o.order_id
JOIN products p2 ON p2.product_id = oi2.product_id
WHERE p1.product_name = 'USB-C Cable'
  AND p2.product_name <> 'USB-C Cable'
ORDER BY p2.product_name;

-- L3 Q6
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'returned'
)
ORDER BY c.customer_id;

-- L3 Q7
WITH delivered_customer_spend AS (
    SELECT c.customer_name,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS lifetime_spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY c.customer_name
), ranked AS (
    SELECT customer_name,
           lifetime_spend,
           DENSE_RANK() OVER (ORDER BY lifetime_spend DESC) AS rnk
    FROM delivered_customer_spend
)
SELECT customer_name, lifetime_spend
FROM ranked
WHERE rnk = 2;

-- L3 Q8
SELECT p.category,
       SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY p.category;

-- L3 Q9
SELECT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) FILTER (
    WHERE o.order_date >= DATE '2024-05-01'
      AND o.order_date < DATE '2024-06-01'
) > 0
AND COUNT(*) FILTER (
    WHERE o.order_date >= DATE '2024-06-01'
      AND o.order_date < DATE '2024-07-01'
) > 0
ORDER BY c.customer_id;

-- L3 Q10
WITH ranked_orders AS (
    SELECT o.*,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC, order_id DESC
           ) AS rn
    FROM orders o
)
SELECT c.customer_id,
       c.customer_name,
       ro.order_date AS latest_order_date,
       ro.status AS latest_status
FROM customers c
LEFT JOIN ranked_orders ro
  ON ro.customer_id = c.customer_id
 AND ro.rn = 1
ORDER BY c.customer_id;

-- =====================
-- Level 4 Solutions
-- =====================

-- L4 Q1
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', o.order_date)::DATE AS month,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS month_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT month,
       month_revenue,
       SUM(month_revenue) OVER (ORDER BY month) AS running_revenue
FROM monthly_revenue
ORDER BY month;

-- L4 Q2
WITH spend AS (
    SELECT c.customer_id,
           c.customer_name,
           COALESCE(SUM(CASE WHEN o.status = 'delivered'
                             THEN oi.quantity * oi.unit_price ELSE 0 END), 0)::NUMERIC(12, 2) AS delivered_spend
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT DENSE_RANK() OVER (ORDER BY delivered_spend DESC) AS spend_rank,
       customer_name,
       delivered_spend
FROM spend
ORDER BY spend_rank, customer_name;

-- L4 Q3
WITH category_sales AS (
    SELECT p.category,
           p.product_name,
           SUM(oi.quantity) AS sold_qty
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category, p.product_name
), ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sold_qty DESC, product_name) AS rn
    FROM category_sales
)
SELECT category, product_name, sold_qty
FROM ranked
WHERE rn = 1
ORDER BY category;

-- L4 Q4
WITH delivered_order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT order_id,
       customer_id,
       order_total,
       ROUND(AVG(order_total) OVER (PARTITION BY customer_id), 2) AS customer_avg,
       ROUND(order_total - AVG(order_total) OVER (PARTITION BY customer_id), 2) AS diff_from_avg
FROM delivered_order_totals
ORDER BY customer_id, order_id;

-- L4 Q5
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', o.order_date)::DATE AS month,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS month_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT month,
       month_revenue,
       LAG(month_revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(
           ((month_revenue - LAG(month_revenue) OVER (ORDER BY month))
            / NULLIF(LAG(month_revenue) OVER (ORDER BY month), 0)) * 100,
           2
       ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- L4 Q6
SELECT c.customer_name,
       MIN(o.order_date) FILTER (WHERE o.status = 'delivered') AS first_delivered_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_name, c.customer_id
ORDER BY c.customer_id;

-- L4 Q7
SELECT customer_id,
       order_id,
       order_date,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
       ) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;

-- L4 Q8
SELECT user_id
FROM events
GROUP BY user_id
HAVING COUNT(*) FILTER (WHERE event_type = 'login') >= 2
   AND COUNT(*) FILTER (WHERE event_type = 'purchase') >= 1
ORDER BY user_id;

-- L4 Q9
SELECT order_id,
       order_date,
       COUNT(*) OVER (ORDER BY order_date, order_id) AS running_order_count
FROM orders
ORDER BY order_date, order_id;

-- L4 Q10
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY amount)::NUMERIC(12, 2) AS median_paid_amount
FROM payments
WHERE payment_status = 'paid';

-- =====================
-- Level 5 Solutions
-- =====================

-- L5 Q1
WITH RECURSIVE org AS (
    SELECT e.employee_id,
           e.employee_name,
           e.manager_id,
           1 AS level
    FROM employees e
    WHERE e.manager_id IS NULL

    UNION ALL

    SELECT e.employee_id,
           e.employee_name,
           e.manager_id,
           o.level + 1 AS level
    FROM employees e
    JOIN org o ON e.manager_id = o.employee_id
)
SELECT employee_id, employee_name, manager_id, level
FROM org
ORDER BY level, employee_id;

-- L5 Q2
WITH RECURSIVE chain AS (
    SELECT e.employee_id,
           e.employee_name,
           e.manager_id,
           1 AS depth
    FROM employees e
    WHERE e.employee_name = 'Harsh'

    UNION ALL

    SELECT m.employee_id,
           m.employee_name,
           m.manager_id,
           c.depth + 1 AS depth
    FROM employees m
    JOIN chain c ON c.manager_id = m.employee_id
)
SELECT STRING_AGG(employee_name, ' > ' ORDER BY depth DESC) AS reporting_chain
FROM chain;

-- L5 Q3
SELECT DISTINCT ON (user_id)
       user_id,
       event_type,
       event_time,
       device
FROM events
ORDER BY user_id, event_time DESC;

-- L5 Q4
WITH april_cohort AS (
    SELECT customer_id
    FROM customers
    WHERE signup_date >= DATE '2024-04-01'
      AND signup_date < DATE '2024-05-01'
), july_retained AS (
    SELECT DISTINCT e.user_id
    FROM events e
    JOIN april_cohort ac ON ac.customer_id = e.user_id
    WHERE e.event_type = 'login'
      AND e.event_time >= TIMESTAMP '2024-07-01 00:00:00'
      AND e.event_time < TIMESTAMP '2024-08-01 00:00:00'
)
SELECT DATE '2024-04-01' AS cohort_month,
       (SELECT COUNT(*) FROM april_cohort) AS cohort_size,
       (SELECT COUNT(*) FROM july_retained) AS retained_users,
       ROUND(((SELECT COUNT(*) FROM july_retained)::NUMERIC
             / NULLIF((SELECT COUNT(*) FROM april_cohort), 0)) * 100, 2) AS retention_pct;

-- L5 Q5
WITH month_spine AS (
    SELECT generate_series(DATE '2024-05-01', DATE '2024-07-01', INTERVAL '1 month')::DATE AS month
), monthly_revenue AS (
    SELECT DATE_TRUNC('month', o.order_date)::DATE AS month,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS delivered_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT ms.month,
       COALESCE(mr.delivered_revenue, 0)::NUMERIC(12, 2) AS delivered_revenue
FROM month_spine ms
LEFT JOIN monthly_revenue mr ON mr.month = ms.month
ORDER BY ms.month;

-- L5 Q6
SELECT COUNT(*) FILTER (WHERE tier = 'gold') AS gold_count,
       COUNT(*) FILTER (WHERE tier = 'silver') AS silver_count,
       COUNT(*) FILTER (WHERE tier = 'bronze') AS bronze_count
FROM customers;

-- L5 Q7
SELECT status,
       channel,
       COUNT(*) AS order_count
FROM orders
GROUP BY ROLLUP(status, channel)
ORDER BY status NULLS LAST, channel NULLS LAST;

-- L5 Q8
WITH ordered AS (
    SELECT customer_id,
           order_id,
           order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_order_date
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date,
       prev_order_date,
       (order_date - prev_order_date) AS gap_days
FROM ordered
WHERE prev_order_date IS NOT NULL
ORDER BY customer_id, order_id;

-- L5 Q9
WITH stats AS (
    SELECT AVG(amount) AS avg_amount,
           STDDEV_SAMP(amount) AS std_amount
    FROM payments
    WHERE payment_status = 'paid'
)
SELECT p.payment_id, p.amount
FROM payments p
CROSS JOIN stats s
WHERE p.payment_status = 'paid'
  AND p.amount > (s.avg_amount + s.std_amount)
ORDER BY p.payment_id;

-- L5 Q10
SELECT o.customer_id,
       ARRAY_AGG(DISTINCT p.product_name ORDER BY p.product_name) AS product_basket
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
GROUP BY o.customer_id
ORDER BY o.customer_id;

-- =====================
-- Level 6 Solutions
-- =====================

-- L6 Q1
SELECT c.city,
       SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS delivered_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY c.city
ORDER BY delivered_revenue DESC
LIMIT 2;

-- L6 Q2
WITH june_events AS (
    SELECT user_id,
           COUNT(*) FILTER (WHERE event_type = 'login') AS login_cnt,
           COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchase_cnt
    FROM events
    WHERE event_time >= TIMESTAMP '2024-06-01 00:00:00'
      AND event_time < TIMESTAMP '2024-07-01 00:00:00'
    GROUP BY user_id
)
SELECT COUNT(*) FILTER (WHERE login_cnt > 0) AS june_login_users,
       COUNT(*) FILTER (WHERE login_cnt > 0 AND purchase_cnt > 0) AS june_converted_users,
       ROUND(
           (COUNT(*) FILTER (WHERE login_cnt > 0 AND purchase_cnt > 0)::NUMERIC
            / NULLIF(COUNT(*) FILTER (WHERE login_cnt > 0), 0)) * 100,
           2
       ) AS conversion_pct
FROM june_events;

-- L6 Q3
WITH delivered_counts AS (
    SELECT customer_id,
           COUNT(*) AS delivered_order_count
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
)
SELECT COUNT(*) AS customers_with_delivered,
       COUNT(*) FILTER (WHERE delivered_order_count >= 2) AS repeat_customers,
       ROUND(
           (COUNT(*) FILTER (WHERE delivered_order_count >= 2)::NUMERIC
            / NULLIF(COUNT(*), 0)) * 100,
           2
       ) AS repeat_rate_pct
FROM delivered_counts;

-- L6 Q4
SELECT COUNT(*) AS total_payments,
       COUNT(*) FILTER (WHERE payment_status = 'paid') AS paid_payments,
       ROUND(
           (COUNT(*) FILTER (WHERE payment_status = 'paid')::NUMERIC / COUNT(*)) * 100,
           2
       ) AS payment_success_pct
FROM payments;

-- L6 Q5
SELECT p.product_name,
       ROUND(AVG(r.rating)::NUMERIC, 2) AS avg_rating,
       COUNT(*) AS review_count
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 2
ORDER BY avg_rating DESC, p.product_name
LIMIT 1;

-- L6 Q6
WITH customer_order_history AS (
    SELECT o.customer_id,
           o.order_id,
           o.status,
           o.order_date,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC, o.order_id DESC) AS rn,
           LEAD(o.status) OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC, o.order_id DESC) AS prev_status
    FROM orders o
), latest AS (
    SELECT *
    FROM customer_order_history
    WHERE rn = 1
)
SELECT l.customer_id,
       c.customer_name,
       l.order_id AS latest_order_id,
       l.status AS latest_status,
       l.prev_status
FROM latest l
JOIN customers c ON c.customer_id = l.customer_id
WHERE l.status = 'delivered'
  AND l.prev_status IS NOT NULL
  AND l.prev_status <> 'delivered'
ORDER BY l.customer_id;

-- L6 Q7
WITH spend AS (
    SELECT c.customer_id,
           c.customer_name,
           COALESCE(SUM(CASE WHEN o.status = 'delivered'
                             THEN oi.quantity * oi.unit_price ELSE 0 END), 0)::NUMERIC(12, 2) AS delivered_spend
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name,
       delivered_spend,
       ROUND((delivered_spend / NULLIF(SUM(delivered_spend) OVER (), 0)) * 100, 2) AS revenue_share_pct
FROM spend
ORDER BY delivered_spend DESC, customer_name;

-- L6 Q8
WITH delivered_order_totals AS (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id
)
SELECT percentile_cont(0.9) WITHIN GROUP (ORDER BY order_total)::NUMERIC(12, 2) AS p90_order_value
FROM delivered_order_totals;

-- L6 Q9
SELECT DATE_TRUNC('month', o.order_date)::DATE AS month,
       SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- L6 Q10
SELECT DISTINCT ON (e.user_id)
       e.user_id,
       e.event_type,
       e.event_time,
       e.device
FROM events e
ORDER BY e.user_id, e.event_time DESC;
