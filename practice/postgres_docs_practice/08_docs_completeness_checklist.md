# 08. Docs Completeness Checklist

Purpose:
Use this checklist to verify that all tracked PostgreSQL documentation concepts in this practice track are covered and practiced.

Primary docs root:
- https://devdocs.io/postgresql/

## A. SELECT and Joins Coverage
Docs:
- https://devdocs.io/postgresql/sql-select
- https://devdocs.io/postgresql/tutorial-join

Checklist:
- [ ] SELECT processing order understood
- [ ] explicit JOIN vs implicit join syntax practiced
- [ ] LEFT/FULL outer join null-extension behavior practiced
- [ ] DISTINCT ON with leftmost ORDER BY practiced
- [ ] LATERAL pattern practiced
- [ ] USING vs ON output-shape difference practiced
- [ ] UNION vs UNION ALL practiced
- [ ] INTERSECT practiced
- [ ] EXCEPT practiced
- [ ] LIMIT/OFFSET vs FETCH practiced
- [ ] TABLE command practiced
- [ ] basic row-locking query form practiced (`FOR UPDATE`, `SKIP LOCKED`, `NOWAIT`)

Mapped files:
- 01_select_processing_and_joins.md
- 07_doc_section_drills.md

## B. WITH and Recursive CTE Coverage
Docs:
- https://devdocs.io/postgresql/queries-with

Checklist:
- [ ] multi-step non-recursive CTE decomposition practiced
- [ ] recursive seed + recursive term pattern practiced
- [ ] manual cycle detection with path array practiced
- [ ] CYCLE clause practiced
- [ ] SEARCH depth/breadth ordering practiced
- [ ] MATERIALIZED vs NOT MATERIALIZED behavior compared
- [ ] data-modifying CTE with RETURNING practiced safely

Mapped files:
- 02_with_and_recursive_cte.md
- 07_doc_section_drills.md

## C. Window Functions Coverage
Docs:
- https://devdocs.io/postgresql/tutorial-window
- https://devdocs.io/postgresql/sql-select

Checklist:
- [ ] PARTITION BY and ORDER BY window semantics practiced
- [ ] row_number/rank/dense_rank differences practiced
- [ ] default frame behavior observed
- [ ] ROWS frame with explicit boundaries practiced
- [ ] RANGE/ROWS contrast practiced
- [ ] frame exclusion (`EXCLUDE CURRENT ROW`) practiced
- [ ] named WINDOW clause reuse practiced
- [ ] filter-after-window via subquery pattern practiced

Mapped files:
- 03_window_functions.md
- 07_doc_section_drills.md

## D. Aggregates and Grouping Coverage
Docs:
- https://devdocs.io/postgresql/functions-aggregate

Checklist:
- [ ] aggregate null behavior (`sum` over empty set) practiced
- [ ] FILTER clause aggregates practiced
- [ ] ordered aggregate input ordering (`string_agg ... ORDER BY`) practiced
- [ ] percentile_cont and percentile_disc practiced
- [ ] mode() within group practiced
- [ ] hypothetical-set aggregate rank practiced
- [ ] ROLLUP + GROUPING() bitmask practiced
- [ ] GROUPING SETS practiced
- [ ] CUBE practiced

Mapped files:
- 04_aggregates_grouping_sets.md
- 07_doc_section_drills.md

## E. Arrays and JSON Coverage
Docs:
- https://devdocs.io/postgresql/functions-array
- https://devdocs.io/postgresql/functions-json

Checklist:
- [ ] array containment/overlap operators practiced
- [ ] array_agg with ordering practiced
- [ ] unnest with ordinality practiced
- [ ] array_position / array_remove / cardinality practiced
- [ ] basic JSON extraction operators practiced
- [ ] jsonpath query and exists checks practiced
- [ ] strict vs lax jsonpath behavior compared
- [ ] JSON mutation helpers practiced (`jsonb_set`, concat, delete)
- [ ] relational-to-JSON aggregation practiced
- [ ] JSON array/object expansion to rows practiced

Mapped files:
- 05_arrays_and_json.md
- 07_doc_section_drills.md

## F. EXPLAIN and Planner Coverage
Docs:
- https://devdocs.io/postgresql/using-explain
- https://devdocs.io/postgresql/sql-explain

Checklist:
- [ ] plan tree node reading (scan/join/sort) practiced
- [ ] estimate vs actual (`ANALYZE`) checked
- [ ] buffer usage read (`BUFFERS`) checked
- [ ] LIMIT-driven plan changes observed
- [ ] index condition vs filter distinction observed
- [ ] join strategy change experiments done
- [ ] subplan/hashed subplan observed
- [ ] initplan observed
- [ ] data-modifying EXPLAIN ANALYZE run safely in transaction rollback block

Mapped files:
- 06_explain_and_planning.md
- 07_doc_section_drills.md

## Completion Rule

Mark this track complete only when all checklist items are checked and at least one SQL attempt was written for each checked item.
