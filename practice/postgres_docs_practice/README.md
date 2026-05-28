# PostgreSQL Documentation Practice Track

This track converts official PostgreSQL documentation concepts into hands-on query questions.

## DevDocs Access

- PostgreSQL docs root on DevDocs:
  - https://devdocs.io/postgresql/

## Coverage Map

- `01_select_processing_and_joins.md`
  - SELECT processing order, DISTINCT ON, JOIN styles, LATERAL, LIMIT/FETCH.
- `02_with_and_recursive_cte.md`
  - CTE basics, recursive CTE, SEARCH/CYCLE patterns, materialization behavior.
- `03_window_functions.md`
  - PARTITION BY, ORDER BY in windows, frames, ranking, top-N per group.
- `04_aggregates_grouping_sets.md`
  - FILTER aggregates, ordered-set aggregates, GROUPING SETS/ROLLUP/CUBE.
- `05_arrays_and_json.md`
  - Array operators/functions, JSON/JSONB operators, path queries, JSON_TABLE style usage.
- `06_explain_and_planning.md`
  - Reading plans, comparing strategies, ANALYZE caveats.
- `07_doc_section_drills.md`
  - Direct doc section to focused 3-drill practice mapping.
- `08_docs_completeness_checklist.md`
  - Full coverage checklist to ensure no tracked concept is skipped.

## Setup

1. Load the original dataset first:
   - `../custom_practice/00_schema_and_data.sql`
2. Then run:
   - `00_docs_setup.sql`

## Notes

- Question statements are original, inspired by official PostgreSQL docs.
- Several exercises intentionally ask for behavior understanding (not just syntax), matching how docs explain execution.
- Reference solutions are in `99_docs_reference_solutions.sql`.
- Use `08_docs_completeness_checklist.md` as the completion gate for this track.
