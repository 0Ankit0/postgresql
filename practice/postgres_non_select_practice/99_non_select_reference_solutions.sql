-- PostgreSQL Non-SELECT Practice Reference (Skeleton + runnable examples)
-- Recommended: run in a local dev database.

BEGIN;

CREATE SCHEMA IF NOT EXISTS ns_lab;
SET search_path TO ns_lab, public;

-- ============================================================
-- 00_ddl_schemas_and_table_lifecycle.md
-- ============================================================

CREATE SCHEMA IF NOT EXISTS practice_core;
SET search_path TO practice_core, ns_lab, public;

DROP TABLE IF EXISTS orders_core_lifecycle CASCADE;
DROP TABLE IF EXISTS users_lifecycle CASCADE;

CREATE TABLE users_lifecycle (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders_core_lifecycle (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users_lifecycle(user_id),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO users_lifecycle(email, full_name)
VALUES ('user1@example.com', 'User One'), ('user2@example.com', 'User Two');

INSERT INTO orders_core_lifecycle(user_id, amount, status)
VALUES (1, 250.00, 'pending'), (2, 99.90, 'paid');

-- Safe ALTER flow: add nullable -> backfill -> set not null
ALTER TABLE orders_core_lifecycle ADD COLUMN billing_currency TEXT;
UPDATE orders_core_lifecycle SET billing_currency = 'INR' WHERE billing_currency IS NULL;
ALTER TABLE orders_core_lifecycle ALTER COLUMN billing_currency SET NOT NULL;

-- Rename + type conversion example
ALTER TABLE orders_core_lifecycle RENAME COLUMN amount TO total_amount;

-- Constraint migration pattern
ALTER TABLE orders_core_lifecycle
ADD CONSTRAINT orders_total_nonnegative CHECK (total_amount >= 0) NOT VALID;
ALTER TABLE orders_core_lifecycle VALIDATE CONSTRAINT orders_total_nonnegative;

SELECT current_schema(), current_schemas(true);

SET search_path TO ns_lab, public;

-- ============================================================
-- 11_inheritance_and_partitioning.md
-- ============================================================

-- Q1, Q2: basic inheritance
DROP TABLE IF EXISTS building_asset CASCADE;
DROP TABLE IF EXISTS vehicle_asset CASCADE;
DROP TABLE IF EXISTS asset CASCADE;

CREATE TABLE asset (
    asset_id BIGSERIAL PRIMARY KEY,
    asset_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active'
);

CREATE TABLE vehicle_asset (
    vin TEXT NOT NULL,
    wheel_count INT NOT NULL CHECK (wheel_count > 0)
) INHERITS (asset);

CREATE TABLE building_asset (
    address TEXT NOT NULL,
    floor_count INT NOT NULL CHECK (floor_count >= 1)
) INHERITS (asset);

INSERT INTO vehicle_asset(asset_name, status, vin, wheel_count)
VALUES ('Truck A', 'active', 'VIN-001', 6);

INSERT INTO building_asset(asset_name, status, address, floor_count)
VALUES ('HQ', 'active', 'Main St', 5);

-- Parent includes inherited rows
SELECT asset_id, asset_name, status FROM asset ORDER BY asset_id;

-- ONLY restricts to parent table rows
SELECT asset_id, asset_name, status FROM ONLY asset ORDER BY asset_id;

-- Q3: parent constraint behavior on children
ALTER TABLE asset
ADD CONSTRAINT asset_status_chk CHECK (status IN ('active', 'retired', 'maintenance'));

-- Should fail if uncommented:
-- INSERT INTO vehicle_asset(asset_name, status, vin, wheel_count)
-- VALUES ('Bad Asset', 'invalid_status', 'VIN-999', 4);

-- Q4-Q8: declarative partitioning
DROP TABLE IF EXISTS event_log CASCADE;

CREATE TABLE event_log (
    event_id BIGINT GENERATED ALWAYS AS IDENTITY,
    event_date DATE NOT NULL,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (event_id, event_date)
) PARTITION BY RANGE (event_date);

CREATE TABLE event_log_2024_01 PARTITION OF event_log
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE event_log_2024_02 PARTITION OF event_log
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

CREATE TABLE event_log_2024_03 PARTITION OF event_log
FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

CREATE TABLE event_log_default PARTITION OF event_log DEFAULT;

INSERT INTO event_log(event_date, event_type, payload)
VALUES
('2024-01-10', 'login', '{"u":1}'),
('2024-02-03', 'purchase', '{"u":2}'),
('2024-07-09', 'unknown', '{"u":3}');

-- Attach existing table as a partition
DROP TABLE IF EXISTS event_log_2024_04_staging;
CREATE TABLE event_log_2024_04_staging (
    LIKE event_log INCLUDING DEFAULTS INCLUDING CONSTRAINTS
);

ALTER TABLE event_log_2024_04_staging
ADD CONSTRAINT event_log_2024_04_bounds
CHECK (event_date >= DATE '2024-04-01' AND event_date < DATE '2024-05-01');

ALTER TABLE event_log
ATTACH PARTITION event_log_2024_04_staging
FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');

-- Partition pruning check
EXPLAIN SELECT * FROM event_log WHERE event_date = DATE '2024-02-03';

-- Index strategy example
CREATE INDEX IF NOT EXISTS idx_event_log_parent_date ON event_log(event_date);
CREATE INDEX IF NOT EXISTS idx_event_log_2024_02_type ON event_log_2024_02(event_type);

-- ============================================================
-- 01_constraints_and_integrity.md
-- ============================================================

DROP TABLE IF EXISTS orders_line CASCADE;
DROP TABLE IF EXISTS orders_core CASCADE;
DROP TABLE IF EXISTS customer_core CASCADE;

CREATE TABLE customer_core (
    customer_id BIGSERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders_core (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer_core(customer_id),
    order_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending','paid','cancelled')),
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE orders_line (
    order_id BIGINT NOT NULL REFERENCES orders_core(order_id),
    line_no INT NOT NULL,
    sku TEXT NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, line_no)
);

-- DEFERRABLE example (cyclic refs)
DROP TABLE IF EXISTS node_a CASCADE;
DROP TABLE IF EXISTS node_b CASCADE;

CREATE TABLE node_a (
    id INT PRIMARY KEY,
    b_id INT UNIQUE
);

CREATE TABLE node_b (
    id INT PRIMARY KEY,
    a_id INT UNIQUE
);

ALTER TABLE node_a
ADD CONSTRAINT fk_a_b FOREIGN KEY (b_id)
REFERENCES node_b(id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE node_b
ADD CONSTRAINT fk_b_a FOREIGN KEY (a_id)
REFERENCES node_a(id)
DEFERRABLE INITIALLY DEFERRED;

BEGIN;
INSERT INTO node_a(id, b_id) VALUES (1, 1);
INSERT INTO node_b(id, a_id) VALUES (1, 1);
COMMIT;

-- Exclusion constraint (booking overlap)
CREATE EXTENSION IF NOT EXISTS btree_gist;
DROP TABLE IF EXISTS room_booking CASCADE;

CREATE TABLE room_booking (
    booking_id BIGSERIAL PRIMARY KEY,
    room_id INT NOT NULL,
    start_ts TIMESTAMPTZ NOT NULL,
    end_ts TIMESTAMPTZ NOT NULL,
    CONSTRAINT room_booking_valid_time CHECK (start_ts < end_ts)
);

ALTER TABLE room_booking
ADD CONSTRAINT room_booking_no_overlap
EXCLUDE USING gist (
    room_id WITH =,
    tstzrange(start_ts, end_ts, '[)') WITH &&
);

-- Generated column + check
DROP TABLE IF EXISTS invoice_line CASCADE;
CREATE TABLE invoice_line (
    id BIGSERIAL PRIMARY KEY,
    qty INT NOT NULL CHECK (qty > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(14,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
    CONSTRAINT line_total_nonnegative CHECK (line_total >= 0)
);

-- Domain
DROP DOMAIN IF EXISTS email_addr CASCADE;
CREATE DOMAIN email_addr AS TEXT
CHECK (VALUE ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$');

DROP TABLE IF EXISTS contact_book CASCADE;
CREATE TABLE contact_book (
    id BIGSERIAL PRIMARY KEY,
    email email_addr NOT NULL UNIQUE
);

-- NOT VALID then validate
ALTER TABLE orders_core
ADD CONSTRAINT orders_core_total_nonzero_chk
CHECK (total_amount >= 0)
NOT VALID;

ALTER TABLE orders_core
VALIDATE CONSTRAINT orders_core_total_nonzero_chk;

-- ============================================================
-- 03_indexes_and_access_paths.md
-- ============================================================

DROP TABLE IF EXISTS idx_test CASCADE;
CREATE TABLE idx_test (
    id BIGSERIAL PRIMARY KEY,
    a INT NOT NULL,
    b INT NOT NULL,
    email TEXT NOT NULL,
    is_active BOOLEAN NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO idx_test(a, b, email, is_active, amount)
SELECT
    (random() * 1000)::INT,
    (random() * 1000)::INT,
    'user' || gs || '@example.com',
    (gs % 4 <> 0),
    (random() * 10000)::NUMERIC(10,2)
FROM generate_series(1, 5000) AS gs;

-- Baseline and indexed plan compare
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM idx_test WHERE a = 42;

CREATE INDEX idx_test_a ON idx_test(a);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM idx_test WHERE a = 42;

-- Multicolumn order behavior
CREATE INDEX idx_test_a_b ON idx_test(a, b);
EXPLAIN SELECT * FROM idx_test WHERE a = 42 AND b = 77;
EXPLAIN SELECT * FROM idx_test WHERE b = 77;

-- Expression index
CREATE INDEX idx_test_lower_email ON idx_test ((lower(email)));
EXPLAIN SELECT * FROM idx_test WHERE lower(email) = 'user10@example.com';

-- Partial index
CREATE INDEX idx_test_active_a ON idx_test(a) WHERE is_active;
EXPLAIN SELECT * FROM idx_test WHERE is_active AND a = 42;

-- Covering index
CREATE INDEX idx_test_a_include ON idx_test(a) INCLUDE (amount, created_at);
EXPLAIN SELECT a, amount, created_at FROM idx_test WHERE a = 42;

-- Unique business rule via partial unique index
DROP TABLE IF EXISTS subscription_state CASCADE;
CREATE TABLE subscription_state (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    plan_code TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX uq_subscription_active_per_user
ON subscription_state(user_id)
WHERE is_active;

-- ============================================================
-- 04_transactions_locks_mvcc.md
-- ============================================================

DROP TABLE IF EXISTS account_tx CASCADE;
CREATE TABLE account_tx (
    account_id BIGINT PRIMARY KEY,
    balance NUMERIC(12,2) NOT NULL CHECK (balance >= 0)
);
INSERT INTO account_tx(account_id, balance) VALUES (1, 1000.00), (2, 500.00)
ON CONFLICT (account_id) DO NOTHING;

-- Q1 atomic transfer
BEGIN;
UPDATE account_tx SET balance = balance - 150 WHERE account_id = 1;
UPDATE account_tx SET balance = balance + 150 WHERE account_id = 2;
COMMIT;

-- Q2 savepoint
BEGIN;
SAVEPOINT s1;
UPDATE account_tx SET balance = balance - 50 WHERE account_id = 1;
-- Simulate failing step by uncommenting
-- UPDATE account_tx SET balance = -1 WHERE account_id = 2;
ROLLBACK TO SAVEPOINT s1;
UPDATE account_tx SET balance = balance - 10 WHERE account_id = 1;
COMMIT;

-- Q3-Q6 need multi-session exercises; templates:
-- Session A:
-- BEGIN;
-- SELECT * FROM account_tx WHERE account_id = 1 FOR UPDATE;
--
-- Session B:
-- BEGIN;
-- SELECT * FROM account_tx WHERE account_id = 1 FOR UPDATE;

-- Queue pattern with SKIP LOCKED
DROP TABLE IF EXISTS work_queue CASCADE;
CREATE TABLE work_queue (
    id BIGSERIAL PRIMARY KEY,
    job_state TEXT NOT NULL CHECK (job_state IN ('pending','running','done')),
    payload JSONB NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO work_queue(job_state, payload)
SELECT 'pending', jsonb_build_object('n', gs)
FROM generate_series(1, 10) AS gs;

-- Worker claim query
WITH cte AS (
    SELECT id
    FROM work_queue
    WHERE job_state = 'pending'
    ORDER BY id
    FOR UPDATE SKIP LOCKED
    LIMIT 1
)
UPDATE work_queue w
SET job_state = 'running'
FROM cte
WHERE w.id = cte.id
RETURNING w.*;

-- Advisory lock example
SELECT pg_try_advisory_lock(1001) AS got_lock;
SELECT pg_advisory_unlock(1001);

-- ============================================================
-- 05_views_matviews_and_rules.md
-- ============================================================

DROP TABLE IF EXISTS sales_base CASCADE;
CREATE TABLE sales_base (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    amount NUMERIC(12,2) NOT NULL
);

INSERT INTO sales_base(customer_id, order_date, amount)
VALUES (1, CURRENT_DATE - 1, 100), (1, CURRENT_DATE, 200), (2, CURRENT_DATE, 300);

-- View
CREATE OR REPLACE VIEW v_sales_safe AS
SELECT id, customer_id, order_date, amount
FROM sales_base;

-- Updatable view demo
INSERT INTO v_sales_safe(customer_id, order_date, amount)
VALUES (3, CURRENT_DATE, 150);

-- Materialized view
DROP MATERIALIZED VIEW IF EXISTS mv_sales_daily;
CREATE MATERIALIZED VIEW mv_sales_daily AS
SELECT order_date, SUM(amount) AS total_amount
FROM sales_base
GROUP BY order_date;

-- Required for CONCURRENTLY refresh
CREATE UNIQUE INDEX mv_sales_daily_uk ON mv_sales_daily(order_date);
REFRESH MATERIALIZED VIEW mv_sales_daily;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_sales_daily;

-- Rule system basic sample
DROP TABLE IF EXISTS sales_log CASCADE;
CREATE TABLE sales_log (
    log_id BIGSERIAL PRIMARY KEY,
    msg TEXT NOT NULL
);

CREATE OR REPLACE RULE sales_base_insert_log AS
ON INSERT TO sales_base
DO ALSO INSERT INTO sales_log(msg)
VALUES ('Inserted sale id=' || NEW.id::TEXT);

-- ============================================================
-- 07_functions_procedures_triggers.md
-- ============================================================

-- Volatility examples
CREATE OR REPLACE FUNCTION f_immutable_add(a INT, b INT)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$ SELECT a + b $$;

CREATE OR REPLACE FUNCTION f_stable_now_date()
RETURNS DATE
LANGUAGE sql
STABLE
AS $$ SELECT CURRENT_DATE $$;

CREATE OR REPLACE FUNCTION f_volatile_rand()
RETURNS FLOAT8
LANGUAGE sql
VOLATILE
AS $$ SELECT random() $$;

-- Procedure sample
CREATE OR REPLACE PROCEDURE p_bonus(p_user BIGINT, p_amt NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales_log(msg) VALUES ('Bonus to user=' || p_user || ', amt=' || p_amt);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Procedure failed: %', SQLERRM;
END;
$$;

CALL p_bonus(1, 25.00);

-- Trigger normalization + audit
DROP TABLE IF EXISTS user_profile CASCADE;
CREATE TABLE user_profile (
    user_id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    phone TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TABLE IF EXISTS user_profile_audit CASCADE;
CREATE TABLE user_profile_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    old_email TEXT,
    new_email TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION trg_user_profile_normalize()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.email := lower(trim(NEW.email));
    NEW.phone := regexp_replace(COALESCE(NEW.phone, ''), '[^0-9+]', '', 'g');
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION trg_user_profile_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO user_profile_audit(user_id, old_email, new_email)
    VALUES (OLD.user_id, OLD.email, NEW.email);
    RETURN NEW;
END;
$$;

CREATE TRIGGER user_profile_norm_biu
BEFORE INSERT OR UPDATE ON user_profile
FOR EACH ROW
EXECUTE FUNCTION trg_user_profile_normalize();

CREATE TRIGGER user_profile_audit_au
AFTER UPDATE ON user_profile
FOR EACH ROW
EXECUTE FUNCTION trg_user_profile_audit();

INSERT INTO user_profile(email, phone) VALUES ('  TEST@EXAMPLE.COM ', '(+1) 555-01 02');
UPDATE user_profile SET email = 'NewMail@Example.com' WHERE user_id = 1;

-- ============================================================
-- 08_roles_privileges_and_rls.md
-- ============================================================

-- Requires elevated privileges in many environments.
-- Example templates:
-- CREATE ROLE app_read NOLOGIN;
-- CREATE ROLE app_write NOLOGIN;
-- CREATE ROLE app_user LOGIN PASSWORD 'change_me';
-- GRANT app_read TO app_user;

DROP TABLE IF EXISTS tenant_doc CASCADE;
CREATE TABLE tenant_doc (
    id BIGSERIAL PRIMARY KEY,
    tenant_id INT NOT NULL,
    content TEXT NOT NULL
);

ALTER TABLE tenant_doc ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_doc_read_policy
ON tenant_doc
FOR SELECT
USING (tenant_id = current_setting('app.tenant_id', true)::INT);

CREATE POLICY tenant_doc_write_policy
ON tenant_doc
FOR INSERT, UPDATE
WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::INT);

-- Session context simulation
SELECT set_config('app.tenant_id', '10', false);
INSERT INTO tenant_doc(tenant_id, content) VALUES (10, 'ok for tenant 10');

-- ============================================================
-- 12_types_sequences_extensions_fdw.md
-- ============================================================

-- Enum lifecycle
DROP TYPE IF EXISTS order_state CASCADE;
CREATE TYPE order_state AS ENUM ('pending', 'paid', 'cancelled');
ALTER TYPE order_state ADD VALUE IF NOT EXISTS 'refunded';

DROP TABLE IF EXISTS order_state_demo CASCADE;
CREATE TABLE order_state_demo (
    id BIGSERIAL PRIMARY KEY,
    state order_state NOT NULL
);

-- Composite type
DROP TYPE IF EXISTS address_type CASCADE;
CREATE TYPE address_type AS (
    city TEXT,
    postal_code TEXT
);

DROP TABLE IF EXISTS profile_with_address CASCADE;
CREATE TABLE profile_with_address (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    addr address_type
);

INSERT INTO profile_with_address(name, addr)
VALUES ('Ankit', ROW('Delhi', '110001')::address_type);

SELECT (addr).city, (addr).postal_code FROM profile_with_address;

-- Sequence control
DROP SEQUENCE IF EXISTS seq_ticket;
CREATE SEQUENCE seq_ticket START 1000 INCREMENT 1;
SELECT nextval('seq_ticket');
SELECT setval('seq_ticket', 2000, true);
SELECT nextval('seq_ticket');

-- Extension example
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- FDW setup is environment-dependent; template only:
-- CREATE EXTENSION IF NOT EXISTS postgres_fdw;
-- CREATE SERVER loopback FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', dbname 'postgres', port '5432');
-- CREATE USER MAPPING FOR CURRENT_USER SERVER loopback OPTIONS (user 'postgres', password '...');

-- ============================================================
-- 13_maintenance_stats_and_operations.md
-- ============================================================

-- Stats refresh
EXPLAIN SELECT * FROM idx_test WHERE a BETWEEN 10 AND 20;
ANALYZE idx_test;
EXPLAIN SELECT * FROM idx_test WHERE a BETWEEN 10 AND 20;

-- Vacuum/analyze commands
VACUUM (ANALYZE) idx_test;

-- Monitoring view examples
SELECT schemaname, relname, seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables
ORDER BY relname
LIMIT 20;

-- pg_stat_statements (if extension enabled)
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- SELECT query, calls, total_exec_time
-- FROM pg_stat_statements
-- ORDER BY total_exec_time DESC
-- LIMIT 10;

-- ============================================================
-- 09_system_catalogs_information_schema_and_introspection.md
-- ============================================================

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    r.rolname AS owner,
    c.reltuples::BIGINT AS est_rows,
    pg_total_relation_size(c.oid) AS total_bytes
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.oid = c.relowner
WHERE c.relkind = 'r'
AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY total_bytes DESC
LIMIT 20;

SELECT
    n.nspname,
    c.relname,
    con.conname,
    con.contype,
    pg_get_constraintdef(con.oid) AS condef
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY n.nspname, c.relname, con.conname;

SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'ns_lab'
ORDER BY table_name, ordinal_position;

SELECT id, ctid, xmin, tableoid FROM idx_test ORDER BY id LIMIT 5;

-- ============================================================
-- 02_data_types_casts_and_domains.md
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS event_data_typed CASCADE;
CREATE TABLE event_data_typed (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cost NUMERIC(12,2) NOT NULL CHECK (cost >= 0),
    attrs JSONB NOT NULL DEFAULT '{}'::jsonb,
    source_ip INET,
    active_window TSTZRANGE
);

INSERT INTO event_data_typed(cost, attrs, source_ip, active_window)
VALUES
(19.99, '{"tier":"basic","region":"ap-south-1"}', '10.0.0.7', tstzrange(NOW(), NOW() + INTERVAL '2 hours', '[)')),
(149.50, '{"tier":"pro","region":"eu-west-1"}', '10.0.0.8', tstzrange(NOW(), NOW() + INTERVAL '4 hours', '[)'));

DROP DOMAIN IF EXISTS pct_rate CASCADE;
CREATE DOMAIN pct_rate AS NUMERIC(5,2) CHECK (VALUE >= 0 AND VALUE <= 100);

DROP TABLE IF EXISTS discount_policy CASCADE;
CREATE TABLE discount_policy (
    id BIGSERIAL PRIMARY KEY,
    policy_name TEXT NOT NULL,
    rate pct_rate NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_event_data_region
ON event_data_typed ((attrs ->> 'region'));

SELECT event_id, attrs ->> 'region' AS region
FROM event_data_typed
WHERE (attrs ->> 'region') = 'eu-west-1';

-- ============================================================
-- 10_full_text_search_practice.md
-- ============================================================

DROP TABLE IF EXISTS article_search CASCADE;
CREATE TABLE article_search (
    article_id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    search_doc TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(body, '')), 'B')
    ) STORED
);

INSERT INTO article_search(title, body)
VALUES
('PostgreSQL text search basics', 'Learn tsvector, tsquery, and indexing for fast search.'),
('Schema migration workflow', 'Safe ALTER TABLE patterns with validation and rollback.'),
('Operator classes in PostgreSQL', 'Understand indexes, operators, and planner choices.');

CREATE INDEX IF NOT EXISTS idx_article_search_doc ON article_search USING gin (search_doc);

SELECT
    article_id,
    title,
    ts_rank(search_doc, websearch_to_tsquery('english', 'postgresql search')) AS rank
FROM article_search
WHERE search_doc @@ websearch_to_tsquery('english', 'postgresql search')
ORDER BY rank DESC;

SELECT ts_headline('english', body, websearch_to_tsquery('english', 'search workflow'))
FROM article_search;

-- ============================================================
-- 06_functions_operators_and_expressions.md
-- ============================================================

SELECT
    COALESCE(NULL, 'fallback') AS c1,
    NULLIF('same', 'same') AS n1,
    (1 IS DISTINCT FROM NULL) AS d1,
    CASE WHEN 5 > 3 THEN 'ok' ELSE 'nope' END AS c2;

CREATE OR REPLACE FUNCTION fx_title_key(p_text TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$ SELECT lower(trim(p_text)) $$;

CREATE INDEX IF NOT EXISTS idx_article_title_key
ON article_search (fx_title_key(title));

SELECT article_id, title
FROM article_search
WHERE fx_title_key(title) = 'postgresql text search basics';

SELECT
    'Abc'::TEXT || 'Def'::TEXT AS concat_text,
    POSITION('search' IN lower(body)) AS search_pos
FROM article_search
ORDER BY article_id;

-- ============================================================
-- 14_maintenance_and_admin_workflows.md
-- ============================================================

-- Autovacuum posture snapshot
SELECT
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Wraparound awareness example
SELECT
    datname,
    age(datfrozenxid) AS xid_age
FROM pg_database
ORDER BY age(datfrozenxid) DESC;

-- Quick maintenance commands for practice
ANALYZE VERBOSE idx_test;
REINDEX TABLE idx_test;

COMMIT;
