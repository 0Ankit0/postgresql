# PostgreSQL Non-SELECT Practice Track

This track is focused on PostgreSQL concepts beyond plain data-selection queries.

## Focus Areas

- DDL basics: create/alter/drop tables and schema lifecycle
- Table inheritance and declarative partitioning
- Constraints and data integrity design
- Index design (B-tree, partial, expression, multicolumn)
- Transactions, locks, isolation, and concurrency patterns
- Views, materialized views, and refresh strategy
- Functions, procedures, triggers, and automation
- Roles, privileges, and row-level security
- System catalogs, information schema, and introspection
- Broader data type design, casts, and domains
- Full text search end-to-end workflow
- Functions/operators and expression semantics
- Types, sequences, extensions, and interoperability
- Maintenance, statistics, and operational checks (including runbooks)
- Explicit docs index/tutorial coverage mapping

## Recommended Order

1. `00_ddl_schemas_and_table_lifecycle.md`
2. `01_constraints_and_integrity.md`
3. `02_data_types_casts_and_domains.md`
4. `03_indexes_and_access_paths.md`
5. `04_transactions_locks_mvcc.md`
6. `05_views_matviews_and_rules.md`
7. `06_functions_operators_and_expressions.md`
8. `07_functions_procedures_triggers.md`
9. `08_roles_privileges_and_rls.md`
10. `09_system_catalogs_information_schema_and_introspection.md`
11. `10_full_text_search_practice.md`
12. `11_inheritance_and_partitioning.md`
13. `12_types_sequences_extensions_fdw.md`
14. `13_maintenance_stats_and_operations.md`
15. `14_maintenance_and_admin_workflows.md`
16. `15_docs_index_tutorial_coverage_matrix.md`
17. `16_non_select_completion_checklist.md`
18. `99_non_select_reference_solutions.sql`

## Notes

- Every section includes documentation links for quick reading.
- Most tasks are DDL/DML/admin-oriented and include verification steps.
- Prefer running these in a scratch schema or local dev database.
- Use `15_docs_index_tutorial_coverage_matrix.md` to ensure no major docs-index/tutorial topic is skipped.
- Use `99_non_select_reference_solutions.sql` as an answer key and runnable scaffold.
