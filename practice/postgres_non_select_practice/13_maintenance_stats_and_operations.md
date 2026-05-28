# 13. Maintenance, Statistics, and Operations

## Docs
- VACUUM/ANALYZE: https://www.postgresql.org/docs/current/routine-vacuuming.html
- VACUUM command: https://www.postgresql.org/docs/current/sql-vacuum.html
- ANALYZE command: https://www.postgresql.org/docs/current/sql-analyze.html
- EXPLAIN: https://www.postgresql.org/docs/current/sql-explain.html
- Monitoring stats views: https://www.postgresql.org/docs/current/monitoring-stats.html
- pg_stat_statements: https://www.postgresql.org/docs/current/pgstatstatements.html

## Q1. Statistics refresh effect
Task:
Create skewed data distribution, run query plan before and after `ANALYZE`.

Verification:
- Compare estimate changes.

## Q2. Autovacuum awareness drill
Task:
Inspect reloptions/autovacuum settings on chosen tables.

Verification:
- Propose adjusted settings for write-heavy table.

## Q3. Bloat and cleanup thought exercise
Task:
Simulate updates/deletes and reason when `VACUUM`, `VACUUM FULL`, or `REINDEX` is appropriate.

Verification:
- Explain tradeoffs in lock and disk usage.

## Q4. Query performance observation
Task:
Enable `pg_stat_statements` (if available) and list top total time queries.

Verification:
- Provide one index or query rewrite improvement idea.

## Q5. Safe change runbook
Task:
Write a short SQL change runbook for production-safe rollout:
- pre-checks
- transactional steps
- rollback strategy
- post-check validation

Verification:
- Include concrete SQL checks in each phase.
