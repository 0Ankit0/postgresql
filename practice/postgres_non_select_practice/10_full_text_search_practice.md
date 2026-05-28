# 10. Full Text Search End-to-End

## Docs
- Full text search: https://www.postgresql.org/docs/current/textsearch.html
- Text search types (`tsvector`, `tsquery`): https://www.postgresql.org/docs/current/datatype-textsearch.html
- Text search functions/operators: https://www.postgresql.org/docs/current/functions-textsearch.html
- Parsing queries: https://www.postgresql.org/docs/current/textsearch-controls.html
- Dictionaries/configurations/features: https://www.postgresql.org/docs/current/textsearch-features.html
- Preferred index types for text search: https://www.postgresql.org/docs/current/textsearch-indexes.html

## Q1. Build searchable document store
Task:
Create table `article_search` with title/body and generated `tsvector` column.

Verification:
- Populate data and return ranked matches with `ts_rank`.

## Q2. Query parsing variants
Task:
Compare:
- `plainto_tsquery`
- `phraseto_tsquery`
- `websearch_to_tsquery`

Verification:
- Show differences in matched rows for the same raw input.

## Q3. Weighted search vectors
Task:
Weight title higher than body using `setweight` and concatenated vectors.

Verification:
- Confirm ranking favors title hits.

## Q4. Indexing strategy
Task:
Create GIN index on `tsvector` and compare plans with/without index.

Verification:
- Use `EXPLAIN (ANALYZE, BUFFERS)` to compare.

## Q5. Highlighting and snippets
Task:
Use `ts_headline` to return contextual snippets for results.

Verification:
- Return top 10 search hits with highlighted terms.

## Q6. Trigger-driven maintenance variant
Task:
Replace generated column with trigger-based maintenance using `tsvector_update_trigger`.

Verification:
- Show vector updates on INSERT and UPDATE.

## Tip
Use language-aware configurations (`english`, custom dictionaries) and test with real user queries.
