# PostgreSQL Practice Track (Basics to Advanced)

This folder is a complete, step-by-step PostgreSQL practice track.

It includes:
- A reusable dataset and schema
- Multi-level question sets from easy to advanced
- A short tip for each question
- Expected output for each question (based on the provided dataset)
- A reference solution file for self-checking
- Source inspiration notes from common SQL learning/interview platforms

## Learning Path

1. `00_schema_and_data.sql`
2. `01_level_easy_basics.md`
3. `02_level_easy_to_medium.md`
4. `03_level_medium_joins_subqueries.md`
5. `04_level_medium_hard_windows_cte.md`
6. `05_level_advanced_postgres.md`
7. `06_level_query_tuning_challenges.md`
8. `99_reference_solutions.sql`

## How To Use

1. Load data first:
   - Run `00_schema_and_data.sql` in PostgreSQL.
2. Solve level files in order.
3. Use the tip only if you are stuck.
4. Match your output with expected output.
5. Use `99_reference_solutions.sql` only after attempting on your own.

## Notes

- Questions are written in PostgreSQL style.
- Expected outputs assume exact dataset values from `00_schema_and_data.sql`.
- Some advanced questions can have multiple valid SQL approaches.
- If your output differs in row order, add explicit `ORDER BY`.
