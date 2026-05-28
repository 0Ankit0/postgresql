# 08. Roles, Privileges, and Row-Level Security

## Docs
- Role and privilege management: https://www.postgresql.org/docs/current/user-manag.html
- GRANT/REVOKE: https://www.postgresql.org/docs/current/sql-grant.html
- CREATE ROLE: https://www.postgresql.org/docs/current/sql-createrole.html
- Row security policies: https://www.postgresql.org/docs/current/ddl-rowsecurity.html

## Q1. Least privilege role design
Task:
Create app roles: read-only, writer, admin-lite.

Verification:
- Prove each role has only expected capabilities.

## Q2. Schema/table/column grants
Task:
Apply grants at schema and table levels plus one column-level restriction.

Verification:
- Run role-based test queries.

## Q3. Default privileges
Task:
Set default privileges for future tables in a schema.

Verification:
- Create new table and confirm grants inherited.

## Q4. Enable row-level security
Task:
Enable RLS on multi-tenant table.

Verification:
- Create policies for read/write by tenant context.

## Q5. RLS policy drill with `USING` and `WITH CHECK`
Task:
Define separate read and write guard policies.

Verification:
- Show blocked cross-tenant read and blocked cross-tenant insert.

## Q6. Security definer caution drill
Task:
Create a security-definer function and harden search path.

Verification:
- Document one misuse risk and mitigation.
