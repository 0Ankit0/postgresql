# 05. Arrays and JSON/JSONB

DevDocs links:
- Array functions/operators: https://devdocs.io/postgresql/functions-array
- JSON functions/operators: https://devdocs.io/postgresql/functions-json

Concepts from docs:
- array operators (`@>`, `<@`, `&&`, `||`)
- array functions (`array_position`, `array_remove`, `cardinality`, `unnest`)
- JSON extraction operators (`->`, `->>`, `#>`, `#>>`)
- JSON path functions (`jsonb_path_query`, `jsonb_path_exists`)
- JSON aggregation (`jsonb_agg`, `jsonb_object_agg`)
- JSON mutation helpers (`jsonb_set`, concat, delete)
- JSON-to-relational extraction patterns (`jsonb_array_elements`, JSON_TABLE style thinking)

## Q1. Build arrays with ordered aggregate
Task:
For each customer, create ordered array of distinct delivered product names.

Tip:
Use `array_agg(DISTINCT ... ORDER BY ...)`.

## Q2. Array containment and overlap
Task:
Using literal arrays, write small queries demonstrating `@>`, `<@`, and `&&`.

Tip:
Show at least one true and one false case per operator.

## Q3. Unnest with ordinality
Task:
Take one sample array literal and unnest it with ordinality.

Tip:
Use `WITH ORDINALITY` in `FROM`.

## Q4. Basic JSON field extraction
Task:
From `docs_json_feed.feed_id = 1`, extract:
- first segment HR
- second segment location[1]
- first segment start_time as text

Tip:
Mix `->`, `->>`, and path operators.

## Q5. JSON path query
Task:
Return all HR values greater than 100 from feed 1.

Tip:
`jsonb_path_query(payload, '$.track.segments[*].HR ? (@ > 100)')`.

## Q6. JSON path exists check
Task:
Return whether feed 1 contains any segment with HR > 130.

Tip:
Use `jsonb_path_exists` or `@?`.

## Q7. JSON aggregation from relational rows
Task:
Create JSON object mapping customer name -> delivered spend.

Tip:
Use `jsonb_object_agg(key, value)` from an aggregated subquery.

## Q8. Explode nested films to rows
Task:
From `docs_json_feed.feed_id = 2`, return rows of `(kind, title, director)`.

Tip:
Use `jsonb_array_elements` twice: favorites then films.

## Q9. Array utility drills
Task:
Run one query each that demonstrates:
- `array_position`
- `array_remove`
- `cardinality`

Tip:
Use literals so output is deterministic.

## Q10. JSON mutation
Task:
Take a jsonb literal and:
1. update one nested field with `jsonb_set`
2. remove one key with `-`
3. merge object with `||`

Tip:
Keep all operations in select-only expressions.

## Q11. Strict vs lax path behavior
Task:
Write one `jsonb_path_query` in lax mode and one in strict mode for a path that requires array unwrap.

Tip:
Use feed 1 `track.segments` structure.
