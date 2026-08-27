# Tag Taxonomy

Canonical tags for `index.md` files across all workflow artifacts. Use this as the reference when writing or searching tags. If a concept you need isn't here, add it — but check for synonyms first.

---

## How tags work in this workflow

Every `index.md` has three discoverability mechanisms:

| Field | Purpose | Example |
|---|---|---|
| `tags:` | Structured browsing — filter by area, type, component | `area/auth`, `type/bug` |
| `aliases:` | Keyword search — synonyms a developer would actually type | `login modal`, `ESC key`, `session expiry` |
| `description:` | Full-text search — plain-language summary shown in Obsidian hover | `The login modal doesn't close on Escape...` |

If you can't find a ticket, search by alias first (`rg "login modal" workflow/`), then browse by tag.

---

## `area/` — Product or system area

| Tag | Use for |
|---|---|
| `area/auth` | Login, logout, session, tokens, SSO, MFA, permissions |
| `area/payments` | Checkout, billing, subscriptions, invoices, Stripe |
| `area/onboarding` | Registration, first-run, account setup, welcome flows |
| `area/content` | Articles, videos, questions, qbank, media, CMS |
| `area/search` | Search UI, indexing, relevance, filters |
| `area/notifications` | Email, push, in-app alerts, preferences |
| `area/navigation` | Routing, menus, breadcrumbs, deep links |
| `area/accessibility` | a11y, WCAG, ARIA, keyboard navigation, screen reader |
| `area/performance` | Load time, bundle size, caching, lazy loading |
| `area/infra` | CI/CD, deployments, environment config, secrets |
| `area/data` | Database, migrations, data models, APIs, sync |
| `area/admin` | Internal tools, dashboards, ops tooling |
| `area/mobile` | iOS, Android, React Native, native-specific behavior |

Add new `area/` tags when a product area consistently appears across multiple tickets. Do not create an area tag for a one-off.

---

## `type/` — Work classification

| Tag | Use for |
|---|---|
| `type/bug` | Something broken — incorrect behavior, crash, data loss |
| `type/feature` | New capability that didn't exist before |
| `type/refactor` | Code quality improvement with no behavior change |
| `type/chore` | Dependency update, config change, cleanup, tooling |
| `type/spike` | Research question — output is a document, not code |
| `type/a11y` | Accessibility fix or improvement |
| `type/perf` | Performance improvement |
| `type/security` | Security fix, vulnerability, audit finding |
| `type/change-request` | A change request on a completed ticket |

Every ticket should have exactly one `type/` tag.

---

## `component/` — Specific component, service, or module

Use `component/` for named things in the codebase — components, services, hooks, API routes, data models. Create these freely; they don't need to be in this list first.

Examples: `component/LoginModal`, `component/PaymentForm`, `component/useAuth`, `component/QBankService`, `component/UserProfile`

Convention: use PascalCase for React components, camelCase for hooks and utilities, kebab-case for API routes.

---

## Cross-cutting tags (no prefix)

Use these without a prefix when the concern cuts across multiple areas:

| Tag | Use for |
|---|---|
| `breaking-change` | API or behavior change that affects callers |
| `regression` | A previously working thing broke again |
| `data-migration` | Requires a DB migration |
| `needs-qa` | Requires manual QA beyond automated tests |
| `third-party` | Involves an external service or vendor |
| `hotfix` | Urgent production fix |

---

## Searching without knowing the tag

If you can't remember the canonical tag, use these approaches:

**By alias (fastest):**
```bash
rg "login modal" workflow/
rg "session expiry" workflow/
```

**By tag in Obsidian:** Tag Explorer pane → browse `area/`, `type/`, `component/` hierarchies.

**By Dataview query in `workflow/index.md`:**
```dataview
TABLE title, status, tags FROM ""
WHERE contains(tags, "area/auth")
```

**By full-text in description:**
```bash
rg "keyboard navigation" workflow/ --include="index.md"
```
