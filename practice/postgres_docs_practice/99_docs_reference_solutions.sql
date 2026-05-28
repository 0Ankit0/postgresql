-- PostgreSQL Docs Practice - Reference Solutions
-- Run setup files first.

-- =============================
-- 01 SELECT / JOINS
-- =============================

-- Q1 explicit
SELECT o.order_id, c.customer_name, o.order_date
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'
ORDER BY o.order_id;

-- Q1 implicit
SELECT o.order_id, c.customer_name, o.order_date
FROM orders o, customers c
WHERE c.customer_id = o.customer_id
  AND o.status = 'delivered'
ORDER BY o.order_id;

-- Q2
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

-- Q3
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
FULL OUTER JOIN orders o ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL OR o.order_id IS NULL
ORDER BY c.customer_id NULLS LAST, o.order_id NULLS LAST;

-- Q4
SELECT DISTINCT ON (o.customer_id)
       o.customer_id,
       o.order_id,
       o.order_date,
       o.status
FROM orders o
ORDER BY o.customer_id, o.order_date DESC, o.order_id DESC;

-- Q5
SELECT product_name, price
FROM products
ORDER BY price DESC
FETCH FIRST 3 ROWS WITH TIES;

-- Q6 stable paging version
SELECT order_id, order_date
FROM orders
ORDER BY order_date, order_id
OFFSET 2 ROWS FETCH NEXT 3 ROWS ONLY;

-- Q7
SELECT o.order_id,
       x.order_item_id,
       x.product_id,
       x.line_value
FROM orders o
LEFT JOIN LATERAL (
    SELECT oi.order_item_id,
           oi.product_id,
           (oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS line_value
    FROM order_items oi
    WHERE oi.order_id = o.order_id
    ORDER BY line_value DESC, oi.order_item_id
    LIMIT 1
) x ON TRUE
ORDER BY o.order_id;

-- Q8 USING
SELECT o.order_id, o.status, p.method, p.payment_status
FROM orders o
JOIN payments p USING (order_id)
ORDER BY o.order_id;

-- =============================
-- 02 WITH / RECURSIVE
-- =============================

-- Q1
WITH delivered_spend AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
), top_customers AS (
    SELECT customer_id, spend
    FROM delivered_spend
    WHERE spend > (SELECT AVG(spend) FROM delivered_spend)
)
SELECT c.customer_name, t.spend
FROM top_customers t
JOIN customers c ON c.customer_id = t.customer_id
ORDER BY t.spend DESC;

-- Q2
WITH RECURSIVE nums(n) AS (
    VALUES (1)
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 20
)
SELECT SUM(n) AS sum_1_to_20
FROM nums;

-- Q3
WITH RECURSIVE org AS (
    SELECT e.employee_id, e.employee_name, e.manager_id, 1 AS depth
    FROM employees e
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, o.depth + 1
    FROM employees e
    JOIN org o ON o.employee_id = e.manager_id
)
SELECT * FROM org
ORDER BY depth, employee_id;

-- Q4 manual cycle detection
WITH RECURSIVE gwalk AS (
    SELECT g.id,
           g.link,
           g.label,
           ARRAY[g.id] AS path,
           FALSE AS is_cycle
    FROM docs_graph g
    WHERE g.id = 1

    UNION ALL

    SELECT g.id,
           g.link,
           g.label,
           gw.path || g.id,
           g.id = ANY(gw.path) AS is_cycle
    FROM docs_graph g
    JOIN gwalk gw ON g.id = gw.link
    WHERE NOT gw.is_cycle
)
SELECT * FROM gwalk;

-- Q5 CYCLE syntax
WITH RECURSIVE gwalk(id, link, label) AS (
    SELECT id, link, label
    FROM docs_graph
    WHERE id = 1

    UNION ALL

    SELECT g.id, g.link, g.label
    FROM docs_graph g
    JOIN gwalk w ON g.id = w.link
)
CYCLE id SET is_cycle USING cycle_path
SELECT * FROM gwalk;

-- =============================
-- 03 WINDOWS
-- =============================

-- Q1
WITH order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT order_id,
       customer_id,
       order_total,
       ROUND(AVG(order_total) OVER (PARTITION BY customer_id), 2) AS customer_avg
FROM order_totals
ORDER BY customer_id, order_id;

-- Q2
WITH order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT customer_id,
       order_id,
       order_total,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_total DESC, order_id) AS row_num,
       RANK() OVER (PARTITION BY customer_id ORDER BY order_total DESC, order_id) AS rank_num,
       DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_total DESC, order_id) AS dense_rank_num
FROM order_totals
ORDER BY customer_id, row_num;

-- Q3
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date)::DATE AS month,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_revenue
FROM monthly
ORDER BY month;

-- Q4
SELECT amount,
       SUM(amount) OVER (ORDER BY amount) AS running_amount_default_frame
FROM payments
WHERE payment_status = 'paid'
ORDER BY amount;

-- Q5
SELECT user_id,
       event_time,
       COUNT(*) OVER (
           PARTITION BY user_id
           ORDER BY event_time
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS local_frame_count
FROM events
ORDER BY user_id, event_time;

-- Q6
WITH ranked AS (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id
               ORDER BY SUM(oi.quantity * oi.unit_price) DESC, o.order_id
           ) AS rn
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT *
FROM ranked
WHERE rn <= 2
ORDER BY customer_id, rn;

-- Q7 named window
WITH order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT order_id,
       customer_id,
       order_total,
       SUM(order_total) OVER w AS running_sum,
       AVG(order_total) OVER w AS running_avg
FROM order_totals
WINDOW w AS (
    PARTITION BY customer_id
    ORDER BY order_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
ORDER BY customer_id, order_id;

-- =============================
-- 04 AGGREGATES / GROUPING SETS
-- =============================

-- Q1
SELECT SUM(amount) AS raw_sum,
       COALESCE(SUM(amount), 0) AS sum_with_default
FROM payments
WHERE paid_at < DATE '2000-01-01';

-- Q2
SELECT COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_count,
       COUNT(*) FILTER (WHERE status = 'pending') AS pending_count,
       COUNT(*) FILTER (WHERE status = 'returned') AS returned_count
FROM orders;

-- Q3
SELECT oi.order_id,
       STRING_AGG(p.product_name, ', ' ORDER BY p.product_name) AS products_csv
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.order_id
ORDER BY oi.order_id;

-- Q4
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY amount) AS p50_cont,
       percentile_disc(0.5) WITHIN GROUP (ORDER BY amount) AS p50_disc
FROM payments
WHERE payment_status = 'paid';

-- Q5
SELECT status,
       channel,
       GROUPING(status, channel) AS grouping_mask,
       COUNT(*) AS order_count
FROM orders
GROUP BY ROLLUP(status, channel)
ORDER BY status NULLS LAST, channel NULLS LAST;

-- Q6
SELECT status,
       channel,
       SUM(CASE WHEN status = 'delivered' THEN oi.quantity * oi.unit_price ELSE 0 END)::NUMERIC(12, 2) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY GROUPING SETS ((status), (channel), ())
ORDER BY status NULLS LAST, channel NULLS LAST;

-- =============================
-- 05 ARRAYS / JSON
-- =============================

-- Q1
SELECT o.customer_id,
       ARRAY_AGG(DISTINCT p.product_name ORDER BY p.product_name) AS product_array
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
GROUP BY o.customer_id
ORDER BY o.customer_id;

-- Q2 literals
SELECT ARRAY[1,4,3] @> ARRAY[3,1] AS contains_case,
       ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6] AS contained_case,
       ARRAY[1,4,3] && ARRAY[2,5] AS overlap_case_false,
       ARRAY[1,4,3] && ARRAY[2,1] AS overlap_case_true;

-- Q3 unnest with ordinality
SELECT *
FROM UNNEST(ARRAY['alpha','beta','gamma']) WITH ORDINALITY AS t(val, ord)
ORDER BY ord;

-- Q4 extraction
SELECT payload #>> '{track,segments,0,HR}' AS first_hr_text,
       payload #>> '{track,segments,1,location,1}' AS second_location_lon,
       payload #>> '{track,segments,0,start_time}' AS first_start_time
FROM docs_json_feed
WHERE feed_id = 1;

-- Q5 path query
SELECT jsonb_path_query(payload, '$.track.segments[*].HR ? (@ > 100)') AS hr_over_100
FROM docs_json_feed
WHERE feed_id = 1;

-- Q6 path exists
SELECT jsonb_path_exists(payload, '$.track.segments[*] ? (@.HR > 130)') AS has_hr_gt_130
FROM docs_json_feed
WHERE feed_id = 1;

-- Q7 json object agg
WITH delivered_spend AS (
    SELECT c.customer_name,
           SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY c.customer_name
)
SELECT jsonb_object_agg(customer_name, spend ORDER BY customer_name) AS spend_by_customer
FROM delivered_spend;

-- Q8 explode nested arrays
SELECT f->>'kind' AS kind,
       film->>'title' AS title,
       film->>'director' AS director
FROM docs_json_feed d,
     LATERAL jsonb_array_elements(d.payload->'favorites') AS f,
     LATERAL jsonb_array_elements(f->'films') AS film
WHERE d.feed_id = 2
ORDER BY kind, title;
