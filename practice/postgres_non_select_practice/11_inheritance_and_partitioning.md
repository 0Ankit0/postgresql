# 11. Inheritance and Partitioning Practice

## Docs
- Inheritance: https://www.postgresql.org/docs/current/ddl-inherit.html
- Declarative partitioning: https://www.postgresql.org/docs/current/ddl-partitioning.html
- CREATE TABLE: https://www.postgresql.org/docs/current/sql-createtable.html
- ATTACH/DETACH partition (ALTER TABLE): https://www.postgresql.org/docs/current/sql-altertable.html

## Q1. Basic table inheritance
Task:
Create a parent table `asset` and child tables `vehicle_asset` and `building_asset` using inheritance.

Verification:
- Insert rows into child tables.
- Query parent with and without `ONLY` and compare row visibility.

## Q2. Inherited columns and local columns
Task:
Add shared columns in parent (`created_at`, `status`) and child-specific columns in each child table.

Verification:
- Verify parent query includes child rows with NULLs for non-shared columns.

## Q3. Inheritance caveat drill
Task:
Add a constraint in the parent and test how it behaves for children.

Verification:
- Attempt violating inserts in children and document result.

## Q4. Range partitioned table
Task:
Create partitioned table `event_log` partitioned by month on `event_date`.

Verification:
- Create at least 3 monthly partitions.
- Insert sample rows across months and verify routing.

## Q5. Default partition behavior
Task:
Add a `DEFAULT` partition and insert out-of-range rows.

Verification:
- Confirm rows land in default partition.

## Q6. Attach existing table as partition
Task:
Create standalone table with compatible structure and attach it as a partition.

Verification:
- Validate attach succeeds only when constraint boundaries match.

## Q7. Partition pruning
Task:
Run `EXPLAIN` on date-filtered queries over `event_log`.

Verification:
- Confirm planner scans only relevant partitions where possible.

## Q8. Local indexes vs partitioned indexes
Task:
Create index on partition key and a non-key column strategy.

Verification:
- Inspect index objects on parent/children and compare behavior.
