# 16. Docs Coverage Checklist (Non-SELECT Track)

Use this checklist to ensure you practiced all major non-selection PostgreSQL concepts covered in this track.

## DDL and Schema Lifecycle
- [ ] Create schema and control `search_path`
- [ ] Create tables with defaults/identity/constraints
- [ ] Safe ALTER pattern (add/backfill/validate/swap)
- [ ] Dependency-aware DROP strategy (`RESTRICT` vs `CASCADE`)

## System Catalogs and Introspection
- [ ] Inspect table metadata via `pg_catalog`
- [ ] Inspect metadata via `information_schema`
- [ ] List/interpret constraints using `pg_constraint`
- [ ] Use system columns safely (`ctid`, `xmin`, `tableoid`)

## Inheritance and Partitioning
- [ ] Inheritance (`ONLY` vs inherited scan)
- [ ] Range/list/hash partitioning basics
- [ ] Attach/detach partition workflow
- [ ] Partition pruning checked with EXPLAIN

## Constraints and Integrity
- [ ] PK/UK/FK/Check/Not Null
- [ ] Deferrable constraints
- [ ] Exclusion constraints
- [ ] Domain validation
- [ ] Generated columns

## Indexing
- [ ] B-tree baseline usage
- [ ] Multicolumn behavior
- [ ] Expression index
- [ ] Partial index
- [ ] Include columns / index-only scan reasoning

## Transactions and Locks
- [ ] Transaction atomicity workflow
- [ ] Savepoints
- [ ] Isolation level behavior comparison
- [ ] Row locking and SKIP LOCKED queue pattern
- [ ] Deadlock scenario and prevention rule

## Views and Materialized Views
- [ ] Updatable view behavior
- [ ] Materialized view refresh pattern
- [ ] Concurrent refresh requirement

## Functions and Triggers
- [ ] Function volatility classes
- [ ] Procedure usage
- [ ] BEFORE trigger normalization
- [ ] AFTER trigger auditing
- [ ] Row vs statement trigger behavior

## Security
- [ ] Role hierarchy and grants
- [ ] Default privileges
- [ ] RLS policies (`USING`, `WITH CHECK`)
- [ ] Security-definer hardening note

## Types and Extensions
- [ ] Enum lifecycle
- [ ] Composite type usage
- [ ] Sequence control
- [ ] Extension install and use
- [ ] FDW basic integration

## Data Types and Type Conversion
- [ ] Use typed design (`uuid`, `timestamptz`, `jsonb`, `inet`, ranges)
- [ ] Explicit cast behavior and operator resolution
- [ ] Domain-driven validation
- [ ] JSONB expression indexing

## Full Text Search
- [ ] Build/search `tsvector` + `tsquery`
- [ ] Compare query parsers (`plainto`, `phrase`, `websearch`)
- [ ] Ranking and weighting with `ts_rank` and `setweight`
- [ ] GIN index plan improvement check

## Functions and Operators
- [ ] Volatility classes and deterministic expression design
- [ ] NULL-safe expression patterns (`IS DISTINCT FROM`, `COALESCE`, `CASE`)
- [ ] Function or expression index usage
- [ ] Pattern matching strategy (`LIKE`, regex, trigram)

## Operations
- [ ] VACUUM/ANALYZE purpose and usage
- [ ] Estimate quality before/after stats updates
- [ ] Monitoring using stats views and/or pg_stat_statements
- [ ] Change runbook with rollback and validation
- [ ] Wraparound-risk awareness and response
- [ ] Bloat triage (`VACUUM` vs `VACUUM FULL` vs `REINDEX`)

## Docs Index and Tutorial Completion
- [ ] Complete `15_docs_index_tutorial_coverage_matrix.md`
- [ ] Complete query-focused checklist in `postgres_docs_practice/08_docs_completeness_checklist.md`

Completion rule:
- Mark this track complete only when every item is checked with at least one SQL implementation attempt.
