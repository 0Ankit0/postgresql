# 05. Views, Materialized Views, and Rules

## Docs
- CREATE VIEW: https://www.postgresql.org/docs/current/sql-createview.html
- Materialized views: https://www.postgresql.org/docs/current/rules-materializedviews.html
- CREATE MATERIALIZED VIEW: https://www.postgresql.org/docs/current/sql-creatematerializedview.html
- REFRESH MATERIALIZED VIEW: https://www.postgresql.org/docs/current/sql-refreshmaterializedview.html
- Rule system: https://www.postgresql.org/docs/current/rules.html

## Q1. Security barrier view
Task:
Create a view exposing only safe columns and apply access for limited role.

Verification:
- Ensure role can query view but not base table directly.

## Q2. Updatable view behavior
Task:
Create simple updatable view and test INSERT/UPDATE through view.

Verification:
- Observe conditions under which updates are accepted.

## Q3. Materialized view pipeline
Task:
Create matview for expensive aggregation.

Verification:
- Insert new base data and show staleness until refresh.

## Q4. Concurrent refresh requirements
Task:
Enable `REFRESH MATERIALIZED VIEW CONCURRENTLY` by adding required unique index.

Verification:
- Confirm concurrent refresh command succeeds.

## Q5. Rule vs trigger comparison drill
Task:
Implement one behavior with rule system and discuss when trigger is preferable.

Verification:
- Brief note on maintainability and modern usage preference.
