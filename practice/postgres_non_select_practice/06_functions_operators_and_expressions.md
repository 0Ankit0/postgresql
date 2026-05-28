# 06. Functions, Operators, and Expression Semantics

## Docs
- Functions and operators root: https://www.postgresql.org/docs/current/functions.html
- Expressions and evaluation rules: https://www.postgresql.org/docs/current/sql-expressions.html
- Operator precedence and lexical syntax: https://www.postgresql.org/docs/current/sql-syntax-lexical.html
- Conditional expressions: https://www.postgresql.org/docs/current/functions-conditional.html
- Pattern matching: https://www.postgresql.org/docs/current/functions-matching.html
- String/date/time/math/comparison/logical functions:
  - https://www.postgresql.org/docs/current/functions-string.html
  - https://www.postgresql.org/docs/current/functions-datetime.html
  - https://www.postgresql.org/docs/current/functions-math.html
  - https://www.postgresql.org/docs/current/functions-comparison.html
  - https://www.postgresql.org/docs/current/functions-logical.html

## Q1. Expression correctness and NULL behavior
Task:
Create examples using `COALESCE`, `NULLIF`, `CASE`, `IS DISTINCT FROM`, and boolean logic.

Verification:
- Demonstrate at least one bug avoided by `IS DISTINCT FROM`.

## Q2. Function volatility and planner impact
Task:
Create one `IMMUTABLE`, one `STABLE`, and one `VOLATILE` function.

Verification:
- Show where they are valid/invalid in index expressions and generated columns.

## Q3. Operator and cast resolution
Task:
Build examples where operator selection changes with explicit cast.

Verification:
- Explain chosen operator/type resolution path.

## Q4. Functional indexing with deterministic expressions
Task:
Create a functional index (for example `lower(email)`) and compare plans.

Verification:
- Show index usage with matching expression in WHERE.

## Q5. Pattern matching strategy
Task:
Compare `LIKE`, `ILIKE`, regex (`~`), and trigram similarity (`pg_trgm` if available).

Verification:
- Explain tradeoffs in speed and semantics.

## Q6. Safe dynamic SQL helper
Task:
Write a PL/pgSQL utility that builds SQL with `quote_ident`/`quote_literal`.

Verification:
- Demonstrate safety against SQL injection in identifiers/literals.

## Tip
Treat expression determinism and operator resolution as performance topics, not only syntax topics.
