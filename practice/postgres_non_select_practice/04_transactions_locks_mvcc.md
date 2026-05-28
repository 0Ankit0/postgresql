# 04. Transactions, Locks, and MVCC

## Docs
- Transactions tutorial: https://www.postgresql.org/docs/current/tutorial-transactions.html
- MVCC intro: https://www.postgresql.org/docs/current/mvcc-intro.html
- Explicit locking: https://www.postgresql.org/docs/current/explicit-locking.html
- Transaction isolation: https://www.postgresql.org/docs/current/transaction-iso.html
- BEGIN/COMMIT/ROLLBACK: https://www.postgresql.org/docs/current/sql-begin.html
- SAVEPOINT: https://www.postgresql.org/docs/current/sql-savepoint.html

## Q1. Atomic transfer
Task:
Implement account transfer in one transaction with debit/credit updates.

Verification:
- Force error in middle and confirm rollback integrity.

## Q2. Savepoint recovery
Task:
Use `SAVEPOINT` to partially recover from one failing step while preserving prior valid steps.

Verification:
- Confirm state after `ROLLBACK TO SAVEPOINT` and final `COMMIT`.

## Q3. Isolation-level experiment
Task:
Run two-session scenario comparing READ COMMITTED vs REPEATABLE READ behavior.

Verification:
- Document one anomaly prevented or allowed.

## Q4. Row-level locking pattern
Task:
Build work-queue fetch using `FOR UPDATE SKIP LOCKED`.

Verification:
- Simulate two workers and show no double-claim.

## Q5. Deadlock drill
Task:
Create controlled deadlock with two sessions locking rows in opposite order.

Verification:
- Observe deadlock error and propose lock-order fix.

## Q6. Advisory locks
Task:
Use advisory lock to serialize critical section keyed by logical resource.

Verification:
- Confirm second attempt blocks or fails depending on lock function used.
