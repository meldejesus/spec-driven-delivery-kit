# Project Context

> One-page project orientation for any agent opening this workspace.
> Keep this current — agents read it before starting work.

---

## What This Project Is

<!-- 2-3 sentences: what the product does, who uses it, what tech stack it runs on -->

---

## Architecture

<!-- Key layers, services, or modules. Bullet list or short paragraph. -->
<!-- Example: -->
<!-- - **API** — Express/Node, lives in `src/api/` -->
<!-- - **Frontend** — React + Tailwind, lives in `src/web/` -->
<!-- - **Database** — PostgreSQL via Prisma, schema in `prisma/schema.prisma` -->

---

## Key Conventions

<!-- Things an agent should know before touching any file. -->
<!-- Examples: -->
<!-- - All new routes must have an OpenAPI schema annotation -->
<!-- - Tests live next to source files (`*.test.ts`) -->
<!-- - Feature flags gate all user-facing changes -->

---

## Where Things Live

| What | Where |
|---|---|
| Source code | `src/` |
| Tests | `src/` (co-located) |
| API types | `src/types/` |
| Docs | `docs/` |
| Workflow artifacts | `workflow/<ticket-id>/` |
| Environment variables | `.env` (local), `.env.example` (committed) |

---

## Local Dev Setup

```bash
# Install
<install command>

# Start dev server
<dev server command>

# Run tests
<test command>
```

---

## Gotchas

<!-- Non-obvious constraints that would surprise an agent without this context. -->
<!-- Examples: -->
<!-- - The `payments` module uses a sandbox Stripe key in dev; never use real keys locally -->
<!-- - `src/legacy/` is frozen — do not refactor without a ticket -->
<!-- - Migrations must be run manually after schema changes (`npx prisma migrate dev`) -->
