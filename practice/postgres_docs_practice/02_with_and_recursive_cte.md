# 02. WITH and Recursive CTE

DevDocs links:
- WITH queries: https://devdocs.io/postgresql/queries-with
- SELECT WITH clause details: https://devdocs.io/postgresql/sql-select

Concepts from docs:
- Non-recursive CTE readability
- Recursive `WITH`
- cycle-safe recursion patterns
- `SEARCH` / `CYCLE` concepts
- materialization behavior (`MATERIALIZED` / `NOT MATERIALIZED`)
- data-modifying statements in `WITH` + `RETURNING`

## Q1. Basic multi-CTE pipeline
Task:
Build a two-step CTE:
1. customer delivered spend
2. customers above overall average spend
Return top customers.

Tip:
This mirrors docs-style decomposition of complex query into named steps.

## Q2. Recursive integer series
Task:
Generate integers 1..20 using `WITH RECURSIVE` and return their sum.

Tip:
Use non-recursive seed + recursive term with stopping condition.

## Q3. Hierarchy traversal on employees
Task:
From top manager(s), recursively list employee tree with depth.

Tip:
Start from `manager_id IS NULL`.

## Q4. Detect cycle in docs_graph manually
Task:
Traverse from `id = 1` and prevent infinite loops by tracking visited IDs in an array.

Tip:
Use `id = ANY(path)` flag and stop recursing when cycle detected.

Expected characteristic:
You should detect a cycle through `2 -> 3 -> 4 -> 2`.

## Q5. Recursive CTE with cycle clause
Task:
Rewrite cycle-safe traversal using built-in `CYCLE` syntax.

Tip:
Use `CYCLE id SET is_cycle USING path_col`.

## Q6. Breadth-like ordering key
Task:
Produce recursion output ordered by depth then id.

Tip:
Even though execution is iterative, explicit ordering gives stable presentation.

## Q7. CTE folding thought exercise
Task:
Write two equivalent queries:
1. `WITH w AS (...) SELECT ... FROM w WHERE ...`
2. plain direct query
Then `EXPLAIN` both and compare for single-reference CTE.

Tip:
For side-effect free and single-use CTE, planner usually folds.

## Q8. MATERIALIZED vs NOT MATERIALIZED
Task:
Create one query with a CTE referenced twice and compare plans with default, `MATERIALIZED`, and `NOT MATERIALIZED`.

Tip:
Use `EXPLAIN` and look for duplicate scans vs shared materialization.

## Q9. Data-modifying CTE with RETURNING
Task:
In one statement, update a subset of rows in a scratch temp table and read updated rows from CTE `RETURNING` output.

Tip:
Use temp tables for safe practice.

## Q10. Parent query snapshot behavior
Task:
Demonstrate that selecting from base table vs selecting from CTE output can show different values in data-modifying CTE pattern.

Tip:
Mirror docs pattern with `UPDATE ... RETURNING`.

## Q11. SEARCH clause practice
Task:
Use recursive traversal with `SEARCH DEPTH FIRST BY id SET ordercol` and sort by `ordercol`.

Tip:
Compare output ordering to manual path ordering.
