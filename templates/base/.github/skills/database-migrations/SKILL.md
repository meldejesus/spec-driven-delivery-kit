---
name: database-migrations
description: >
  Review or implement database migrations using the target project's migration
  conventions.
---

# Database Migrations

Use this skill when creating or reviewing schema changes.

## Workflow

1. Locate the project's existing migration directory and recent migration files.
2. Follow the existing migration shape, naming convention, and rollback pattern.
3. Confirm whether column names are transformed by the data-access layer before
   flagging casing issues.
4. For new tables, verify:
   - primary key convention
   - timestamp convention
   - required indexes
   - character set/collation convention
   - reversible down migration when the project expects one
5. Run the project's migration tests or dry-run command when available.

## Safety

- Do not run migrations against shared, staging, or production databases unless
  the user explicitly approves that environment.
- Prefer local dry-runs and generated SQL inspection first.
