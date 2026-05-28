# 14. Maintenance and Admin Workflows (Expanded)

## Docs
- Maintenance overview: https://www.postgresql.org/docs/current/maintenance.html
- Routine vacuuming and wraparound: https://www.postgresql.org/docs/current/routine-vacuuming.html
- Routine reindexing: https://www.postgresql.org/docs/current/routine-reindex.html
- Monitoring database activity: https://www.postgresql.org/docs/current/monitoring.html
- Monitoring stats: https://www.postgresql.org/docs/current/monitoring-stats.html
- WAL basics: https://www.postgresql.org/docs/current/wal.html
- Backup and restore: https://www.postgresql.org/docs/current/backup.html
- VACUUM / ANALYZE / REINDEX commands:
  - https://www.postgresql.org/docs/current/sql-vacuum.html
  - https://www.postgresql.org/docs/current/sql-analyze.html
  - https://www.postgresql.org/docs/current/sql-reindex.html

## Q1. Autovacuum posture review
Task:
Inspect table-level and global autovacuum settings for hot tables.

Verification:
- Produce a table of current values and tuning recommendations.

## Q2. Wraparound risk drill
Task:
Use age functions and catalog views to detect relation age risk.

Verification:
- Identify top candidate tables that need aggressive vacuum.

## Q3. Bloat triage playbook
Task:
Build a decision matrix for `VACUUM`, `VACUUM FULL`, `REINDEX`, and `CLUSTER`.

Verification:
- Apply to at least two simulated scenarios.

## Q4. Stats-driven tuning loop
Task:
Use `pg_stat_user_tables` and `pg_stat_user_indexes` to find hotspots.

Verification:
- Propose one concrete index/query/schema improvement per hotspot.

## Q5. Backup and restore smoke check
Task:
Write commands/checks for logical backup and restore verification in staging.

Verification:
- Include row-count/checksum style validation queries.

## Q6. Incident runbook exercise
Task:
Create a maintenance incident runbook for:
- lock contention spikes
- autovacuum lag
- sudden query regression

Verification:
- Include immediate, short-term, and long-term actions.

## Tip
Maintenance quality is measured by predictable recovery behavior, not just daily command execution.
