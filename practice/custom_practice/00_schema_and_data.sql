-- PostgreSQL Practice Dataset
-- Run this file in psql or PgAdmin before solving questions.

BEGIN;

DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL,
    signup_date DATE NOT NULL,
    tier TEXT NOT NULL CHECK (tier IN ('bronze', 'silver', 'gold'))
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'delivered', 'returned')),
    channel TEXT NOT NULL
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    paid_at DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    method TEXT NOT NULL,
    payment_status TEXT NOT NULL CHECK (payment_status IN ('paid', 'refunded', 'failed'))
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    reviewed_at DATE NOT NULL
);

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES customers(customer_id),
    event_type TEXT NOT NULL CHECK (event_type IN ('login', 'purchase')),
    event_time TIMESTAMP NOT NULL,
    device TEXT NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name TEXT NOT NULL,
    manager_id INT NULL REFERENCES employees(employee_id),
    department TEXT NOT NULL,
    salary NUMERIC(10, 2) NOT NULL CHECK (salary > 0),
    hired_at DATE NOT NULL
);

INSERT INTO customers (customer_id, customer_name, city, signup_date, tier) VALUES
(1, 'Asha', 'Mumbai', '2024-01-10', 'gold'),
(2, 'Ravi', 'Pune', '2024-02-15', 'silver'),
(3, 'Neha', 'Delhi', '2024-03-01', 'bronze'),
(4, 'Karan', 'Mumbai', '2024-03-20', 'silver'),
(5, 'Isha', 'Bengaluru', '2024-04-05', 'gold'),
(6, 'Omar', 'Delhi', '2024-04-18', 'bronze'),
(7, 'Priya', 'Chennai', '2024-06-25', 'silver');

INSERT INTO products (product_id, product_name, category, price, is_active) VALUES
(1, 'Keyboard', 'Accessories', 1500.00, TRUE),
(2, 'Mouse', 'Accessories', 800.00, TRUE),
(3, 'Monitor', 'Displays', 12000.00, TRUE),
(4, 'USB-C Cable', 'Accessories', 400.00, TRUE),
(5, 'Laptop Stand', 'Accessories', 2200.00, TRUE),
(6, 'Webcam', 'Electronics', 3500.00, TRUE),
(7, 'Noise Cancelling Headset', 'Electronics', 6500.00, TRUE),
(8, 'Mechanical Keyboard Pro', 'Accessories', 5000.00, FALSE);

INSERT INTO orders (order_id, customer_id, order_date, status, channel) VALUES
(1, 1, '2024-05-01', 'delivered', 'web'),
(2, 2, '2024-05-02', 'delivered', 'app'),
(3, 1, '2024-05-10', 'returned', 'web'),
(4, 3, '2024-05-11', 'delivered', 'app'),
(5, 4, '2024-06-01', 'delivered', 'store'),
(6, 5, '2024-06-03', 'pending', 'web'),
(7, 6, '2024-06-10', 'delivered', 'app'),
(8, 2, '2024-06-15', 'delivered', 'web'),
(9, 5, '2024-06-20', 'delivered', 'web'),
(10, 1, '2024-07-01', 'delivered', 'app');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 1500.00),
(2, 1, 4, 2, 400.00),
(3, 2, 2, 1, 800.00),
(4, 2, 5, 1, 2200.00),
(5, 3, 3, 1, 12000.00),
(6, 4, 4, 3, 400.00),
(7, 4, 2, 1, 800.00),
(8, 5, 6, 1, 3500.00),
(9, 5, 4, 2, 400.00),
(10, 6, 7, 1, 6500.00),
(11, 7, 1, 2, 1500.00),
(12, 8, 3, 1, 12000.00),
(13, 8, 4, 1, 400.00),
(14, 9, 5, 2, 2200.00),
(15, 9, 2, 1, 800.00),
(16, 10, 6, 1, 3500.00),
(17, 10, 1, 1, 1500.00);

INSERT INTO payments (payment_id, order_id, paid_at, amount, method, payment_status) VALUES
(1, 1, '2024-05-01', 2300.00, 'upi', 'paid'),
(2, 2, '2024-05-02', 3000.00, 'card', 'paid'),
(3, 3, '2024-05-12', 12000.00, 'card', 'refunded'),
(4, 4, '2024-05-11', 2000.00, 'upi', 'paid'),
(5, 5, '2024-06-01', 4300.00, 'cash', 'paid'),
(6, 7, '2024-06-10', 3000.00, 'upi', 'paid'),
(7, 8, '2024-06-15', 12400.00, 'card', 'paid'),
(8, 9, '2024-06-20', 5200.00, 'upi', 'paid'),
(9, 10, '2024-07-01', 5000.00, 'card', 'paid');

INSERT INTO reviews (review_id, customer_id, product_id, rating, reviewed_at) VALUES
(1, 1, 1, 5, '2024-05-05'),
(2, 2, 2, 4, '2024-05-08'),
(3, 3, 4, 3, '2024-05-14'),
(4, 4, 6, 5, '2024-06-04'),
(5, 5, 7, 4, '2024-06-21'),
(6, 2, 3, 5, '2024-06-18'),
(7, 6, 1, 4, '2024-06-11'),
(8, 1, 3, 2, '2024-07-02'),
(9, 5, 5, 5, '2024-06-25');

INSERT INTO events (event_id, user_id, event_type, event_time, device) VALUES
(1, 1, 'login', '2024-06-01 09:00:00', 'mobile'),
(2, 1, 'purchase', '2024-06-01 09:15:00', 'mobile'),
(3, 1, 'login', '2024-07-01 10:00:00', 'web'),
(4, 2, 'login', '2024-06-02 08:30:00', 'web'),
(5, 2, 'login', '2024-06-05 19:00:00', 'mobile'),
(6, 2, 'purchase', '2024-06-15 11:00:00', 'web'),
(7, 3, 'login', '2024-06-11 12:00:00', 'app'),
(8, 4, 'login', '2024-06-01 14:00:00', 'web'),
(9, 4, 'purchase', '2024-06-01 14:20:00', 'store_kiosk'),
(10, 5, 'login', '2024-06-03 16:00:00', 'mobile'),
(11, 5, 'login', '2024-06-20 17:00:00', 'mobile'),
(12, 5, 'purchase', '2024-06-20 17:40:00', 'web'),
(13, 6, 'login', '2024-06-10 09:10:00', 'app'),
(14, 6, 'purchase', '2024-06-10 09:35:00', 'app'),
(15, 6, 'login', '2024-07-10 09:00:00', 'app');

INSERT INTO employees (employee_id, employee_name, manager_id, department, salary, hired_at) VALUES
(1, 'Anil', NULL, 'executive', 220000.00, '2021-01-01'),
(2, 'Bhavna', 1, 'sales', 150000.00, '2021-03-10'),
(3, 'Chetan', 1, 'engineering', 180000.00, '2021-05-12'),
(4, 'Divya', 3, 'engineering', 130000.00, '2022-02-01'),
(5, 'Esha', 3, 'engineering', 125000.00, '2022-04-15'),
(6, 'Farhan', 2, 'sales', 90000.00, '2022-06-20'),
(7, 'Gauri', 2, 'sales', 95000.00, '2022-07-08'),
(8, 'Harsh', 4, 'data', 85000.00, '2023-01-03'),
(9, 'Ira', 4, 'data', 80000.00, '2023-03-11');

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_events_user_time ON events(user_id, event_time);

COMMIT;
