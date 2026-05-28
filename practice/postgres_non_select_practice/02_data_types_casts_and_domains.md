# 02. Data Types, Casts, Domains, and Type Design

## Docs
- Data types overview: https://www.postgresql.org/docs/current/datatype.html
- Type conversion: https://www.postgresql.org/docs/current/typeconv.html
- Numeric/date/time/uuid/json/network/range types: https://www.postgresql.org/docs/current/datatype.html
- Domain types: https://www.postgresql.org/docs/current/domains.html
- Enumerated types: https://www.postgresql.org/docs/current/datatype-enum.html
- Range types: https://www.postgresql.org/docs/current/rangetypes.html

## Q1. Type choice design table
Task:
Create an `event_data` table that uses at least:
- `uuid`
- `timestamptz`
- `numeric`
- `jsonb`
- `inet`
- `int4range` or `tstzrange`

Verification:
- Insert realistic rows and run type-specific queries.

## Q2. Cast behavior and operator resolution
Task:
Test explicit casts (`::`) vs implicit casts in expressions and joins.

Verification:
- Show one case where explicit cast avoids ambiguity or bad plan.

## Q3. Domain-driven validation
Task:
Create domains for email and percentage/rate values and use them in tables.

Verification:
- Show domain check failures.
- Compare with inline CHECK constraints.

## Q4. Enum evolution and tradeoffs
Task:
Create enum-backed status column, then add a new value and update old rows.

Verification:
- Show migration-safe update flow.

## Q5. Range semantics drill
Task:
Store booking windows with range types and enforce no-overlap using exclusion constraints.

Verification:
- Demonstrate inclusive/exclusive bound behavior (`[)`, `[]`).

## Q6. JSONB and typed columns split
Task:
Design a table with stable typed columns plus flexible JSONB attributes.

Verification:
- Add expression index on a JSONB path and verify plan change.

## Tip
Prefer explicit, constrained types for core fields; reserve JSONB for evolving edge attributes.
