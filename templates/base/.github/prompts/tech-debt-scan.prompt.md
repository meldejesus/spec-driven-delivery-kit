---
name: tech-debt-scan
description: Scans a specific app workflow for tech debt and produces Jira-ready ticket drafts covering error handling gaps, performance anti-patterns, complexity hotspots, null safety issues, stale abstractions, and UX flow gaps.
tools: [read, search, terminal]
---

# Tech Debt Scan

## Inputs
- workflow: ${input:workflow}   # account-creation-tracking | purchase | learn-page | edit-learn | answer-page | admin-pages | study-schedule
- sub_workflow: ${input:sub_workflow}   # optional — target a specific sub-flow within the workflow (see Phase 1b)

## Phase 1 — Load Domain Context

1. Read `monorepo/docs/index.md` to identify which doc(s) map to the requested workflow.
2. Use the Debugging Cheatsheet in that file to select the relevant doc(s):

   | Workflow | Docs to read |
   |---|---|
   | `account-creation-tracking` | `monorepo/docs/db/navigation.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |
   | `learn-page` | `monorepo/docs/db/nodes.md`, `monorepo/docs/codebase/routing-caching-background-jobs.md` |
   | `edit-learn` | `monorepo/docs/db/nodes.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |
   | `answer-page` | `monorepo/docs/db/nodes.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |
   | `admin-pages` | `monorepo/docs/db/nodes.md`, `monorepo/docs/db/purchase.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |
   | `study-schedule` | `monorepo/docs/db/nodes.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |
   | `purchase` | `monorepo/docs/db/purchase.md`, `monorepo/docs/codebase/api-endpoints-and-handlers.md` |

3. Record: intended data flow, expected error states, key invariants, and any documented known issues for the workflow.

### Phase 1b — Enumerate Sub-Workflows

Before scanning, list all distinct user-facing sub-flows within the requested workflow. Each sub-flow is a meaningful variation in the happy path or a separate entry point that could carry its own debt surface.

**Known sub-workflows per top-level workflow:**

| Workflow | Sub-workflows |
|---|---|
| `account-creation-tracking` | B2C standard email/password, gated CTA (lockout modal), plans-page Try Now, guest checkout (logged-out purchase), B2B/SSO cohort create, mobile register/verify, social auth (Google/Apple), email verification re-send, account recovery/password reset |
| `purchase` | B2C logged-out guest checkout, B2C logged-in direct purchase, subscription change/upgrade, plans-page Try Now flow, B2B pre-assigned/cohort, mobile IAP (iOS/Android), coupon/promo code apply, purchase preview/tax calculation |
| `learn-page` | Video learn page, flashcard learn page, question learn page, locked/gated content (free tier), lockout modal CTA, mobile learn page, learn page with attachments/references |
| `edit-learn` | Rich text content edit, video attachment/replace, question attach/detach, tag and metadata edit, publish/draft state toggle, collaborative edit (multi-author), bulk edit |
| `answer-page` | Answer reveal, explanation display, question flagging, answer feedback submission, related content linking, answer page in QBank context vs. learn page context |
| `admin-pages` | User management (search/edit/subscription), content moderation, plan/subscription admin, cohort/B2B management, feature flag management, analytics/reporting views |
| `study-schedule` | Schedule builder (initial setup), daily plan view, streak tracking, exam date setting, planner recommendation engine, schedule reset/rebuild |

If `sub_workflow` was provided, focus the scan on that sub-flow only and note that others were skipped.
If `sub_workflow` was not provided, list all sub-workflows at the top of your output, then pick the **highest-risk sub-flow** (based on user volume, revenue impact, or known instability) and scan that one. State clearly which sub-flow you chose and why.

---

## Phase 2 — Explore Implementation

Search for actual implementation across these paths (check all three — do not limit to one):

- `monorepo/apps/next-webapp/src/` — pages, components, hooks, API routes
- `monorepo/apps/legacy/client/` — legacy React client code
- `monorepo/libs/` — shared libraries, utilities, and components

### Search strategy per workflow

| Workflow | Key terms to search |
|---|---|
| `account-creation-tracking` | `onboarding`, `signup`, `auth`, `register`, `createUser`, `trackCreateAccount`, `productID`, `verifyEmail`, `ssoCreate`, `guestCheckout` |
| `learn-page` | `learn`, `LearnPage`, `node`, `video`, `content`, `lockout`, `gated` |
| `edit-learn` | `editLearn`, `edit`, `publish`, `draft`, `richText`, `attachment`, `contentEdit` |
| `answer-page` | `answer`, `explanation`, `AnswerPage`, `question`, `flag`, `feedback` |
| `admin-pages` | `admin`, `manage`, `AdminPage`, `userManage`, `featureFlag`, `cohort` |
| `study-schedule` | `study`, `schedule`, `StudySchedule`, `planner`, `streak` |
| `purchase` | `purchase`, `subscription`, `checkout`, `plan`, `payment`, `payment-provider` |

For each relevant file found:
- Read the full file (not just the match).
- Note function signatures, API calls, error handling patterns, and data shapes.

---

## Phase 3 — Compare Intent vs Reality

For each of the six debt categories below, identify specific instances where implementation diverges from documented intent or violates platform-wide standards.

### 🔴 Missing Error Handling
- API calls without `.catch` or error boundary
- `async`/`await` without `try/catch`
- Missing loading and error UI states
- Silent failures (errors caught but not surfaced to the user)

### ⚡ Performance Anti-Patterns
- Sequential `await` chains replaceable by `Promise.all`
- Unbounded queries (no `LIMIT`) on read paths
- `useEffect` data fetching that could be server-side in Next.js
- Full library imports where a single function suffices
- Same query/API call duplicated in the same render cycle

### 🌀 Complexity Hotspots
- Functions over ~60 lines doing more than one thing
- Components with more than ~5 props and no composition pattern
- Deeply nested conditional rendering (3+ levels)
- Mixed responsibilities (data fetching + business logic + rendering in one component)

### 🛡️ Missing Null Safety
- Optional chaining absent where nullability is plausible
- Unchecked array index access (`arr[0]` without length guard)
- Props or API response fields used without default values or guards
- Possible `undefined is not a function` or `Cannot read properties of null` paths

### 🗃️ Stale Abstractions
- Utility functions or hooks that duplicate logic already in `monorepo/libs/`
- Patterns replaced platform-wide but persisting here (e.g., class components, old fetch wrappers)
- Commented-out code or dead branches that are never reached
- TODO/FIXME comments that have not been addressed

### 🎨 UX Flow Gaps
- Missing empty states for lists or async data
- Loading spinners absent while awaiting data
- Navigation that skips steps documented as required in the workflow
- Error messages that are not user-readable (raw error objects surfaced as strings)

---

## Phase 4 — Produce Ticket Drafts

Output ticket drafts for the scanned sub-workflow. There is no hard cap — produce as many tickets as the evidence supports. Prioritize issues with the highest user-visible impact or risk of data loss. Merge issues only when they share the same root cause and the same files. Do not merge distinct problems just to reduce count. Skip low-signal style issues.

**Ticket types:**
- **Standard ticket** — clear problem with a known fix. Use the canonical structure in `workflow/pointing/tech-debt-tickets.md`.
- **Spike ticket** — use when the signal is real but the fix requires investigation first, or when the impact is uncertain. A spike ticket should include: the question to answer, why it matters, files to read, and expected output (e.g. "a decision and a follow-on ticket or a pass"). Label effort as `S/M/L (spike)`.

Use spike tickets instead of skipping findings you're uncertain about. The Skipped Signals section is for findings that are clearly below the ticket bar, not for findings where you're unsure.

Use the canonical ticket structure defined in `workflow/pointing/tech-debt-tickets.md`.

---

## Output Requirements

- Begin with a **Sub-Workflow Map** — a bullet list of all sub-workflows for this top-level workflow, with the scanned one marked `(scanning this one)`.
- Follow with a one-paragraph **Scan Summary** covering: sub-workflow selected, files explored, debt categories with the most findings, and overall risk signal.
- List tickets in descending order of severity (highest impact first).
- After the last ticket, add a **Skipped Signals** section listing patterns noticed that did not meet the ticket threshold, with a one-line reason each was skipped.
- If the user asks to save the output, write two files:
  1. **Tickets file** — `workflow/pointing/tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md` — standard and spike tickets only (no Skipped Signals here)
  2. **Spike file** — `workflow/pointing/spikes-<workflow>-<sub-workflow>-YYYY-MM-DD.md` — only if spike tickets were produced. Contains the same spike tickets duplicated here in a watchlist format (fields: Question, Why it matters, Files to read, Expected output, Status: `open`). This file is the living investigation backlog for the sub-workflow; status updates to `answered` or `closed` as spikes are resolved.
  - Skipped Signals belong in the tickets file after the last ticket, not in the spike file.

---

## Phase 5 — Handoff to Next Sub-Workflow

After completing the scan and saving output:

1. Read `workflow/pointing/workflow-scan-registry.md`.
2. Find the next **pending** sub-workflow for the same top-level workflow (first row with `⬜ pending` status).
3. Announce it clearly:
   > **Next sub-workflow:** `<name>` — `<key files>`. Ready to scan when you are.
4. Do **not** start scanning the next sub-workflow automatically. Wait for explicit user confirmation.
5. If all sub-workflows for this workflow are done, announce:
   > **Workflow `<name>` complete.** Suggest moving to `<next top-level workflow>` (see registry priority order).
