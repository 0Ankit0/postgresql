# 07. Functions, Procedures, and Triggers

## Docs
- SQL functions: https://www.postgresql.org/docs/current/xfunc.html
- PL/pgSQL: https://www.postgresql.org/docs/current/plpgsql.html
- CREATE FUNCTION: https://www.postgresql.org/docs/current/sql-createfunction.html
- CREATE PROCEDURE: https://www.postgresql.org/docs/current/sql-createprocedure.html
- CREATE TRIGGER: https://www.postgresql.org/docs/current/sql-createtrigger.html
- Trigger behavior: https://www.postgresql.org/docs/current/trigger-definition.html

## Q1. Immutable/stable/volatile function behavior
Task:
Create 3 functions with different volatility classes and explain optimizer implications.

Verification:
- Demonstrate usage context where volatility matters.

## Q2. Procedure with transaction control
Task:
Create procedure that performs multi-step operation and handles controlled exceptions.

Verification:
- Confirm state changes across call behavior.

## Q3. BEFORE trigger for data normalization
Task:
Create trigger to normalize email/phone before insert/update.

Verification:
- Insert messy input and verify normalized persisted value.

## Q4. AFTER trigger for audit logging
Task:
Create audit table and after trigger capturing old/new row data.

Verification:
- Run update/delete and check audit trail.

## Q5. Trigger recursion and guard
Task:
Create scenario where trigger could recurse and add guard condition.

Verification:
- Confirm no infinite recursion.

## Q6. Statement vs row triggers
Task:
Implement one row-level and one statement-level trigger and compare fired records.

Verification:
- Run batch update and compare counts.
