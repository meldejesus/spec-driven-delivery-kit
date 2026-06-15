# Prompt Flows — Quick Reference

> Deep dives: `.github/how-to/howToUse.md` · `.github/how-to/howToUse-spike.md` · `.github/how-to/howToUse-codeReview.md` · `.github/how-to/howToUse-message.md`
>
> Conceptual overview: `.github/how-to/spec-driven-workflow.md`
>
> Authoring guide: `.github/how-to/authoring-agents-prompts-skills.md`

---

## Steps Involved

### Standard Ticket — Contract

```text
@Architect
#read .github/prompts/workflow-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

### Standard Ticket — Later Stages

```text
run plan
run implement
run review
run closeout
```

### Standard Ticket — Sonar

```text
run sonar
pr_number=<PR_NUMBER>
```

### PR Review

```text
@Reviewer
#read .github/prompts/pr-review.prompt.md

pr_url=https://github.com/your-org/your-repo/pull/XXXX
ticket=https://your-domain.atlassian.net/browse/PROJECT-123
context=<anything you know about the area>
```

### Spike

```text
Read .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

### Message Workflow

```text
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on user experience, points of confusion, and language to avoid.
```

### Pointing

```text
@pointing-analyst
#read .github/prompts/pointing-plan.prompt.md

mode=sprint
sprint=Apollo 2.0 (2026)
```

### Dev Starters

```text
Read .github/prompts/legacy-dev-start.prompt.md
```

```text
Read .github/prompts/mobile-start.prompt.md
```

### Standalone Skills

```text
use the sonar-check skill on PR #6531
use the tailwind-check skill on src/components/MyComponent.tsx
use the copilot-chat-cleanup skill
```

---

## `workflow-*` — Building a Jira ticket into a PR
**Agents:** `@Architect` → `@Plan-Agent` → `@Implementer` → `@Reviewer` → closeout (`@Educator` + `@Architect`)

Steps: contract → plan → implement → review → closeout → sonar

After `workflow-contract` writes `workflow/tickets/.active-workflow.md`, later stages can be invoked with short commands:

```text
run plan
run implement
run review
run closeout
```

Add extra context inline or with `context=<file>`:

```text
run review but also consider workflow/tickets/PROJECT-123/manual-test-notes.md
```

| Prompt | Purpose |
|---|---|
| `workflow-contract` | Fetch ticket, create searchable `index.md`, draft Strategic Contract. Gate A — you approve. |
| `workflow-plan` | Break contract into atomic tasks. Gate B — you approve. Reads active state if inputs are omitted. |
| `workflow-implement` | Execute tasks, journal progress, run final build validation, stop on failures. Reads active state if inputs are omitted. |
| `workflow-review` | Review diff + AC/build coverage, write PR description. Gate D. Reads active state if inputs are omitted. |
| `workflow-closeout` | Write `overview.md`, then extract promotion candidates before push. |
| `workflow-promote` | Standalone global lesson promotion. Usually called through closeout. |
| `workflow-educate` | Standalone walkthrough of what changed and why. Usually called through closeout. |
| `workflow-sonar` | Post-CI SonarQube check — PASS or BLOCK verdict. |

**Start with:**
```
@Architect
#read .github/prompts/workflow-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

---

## `pr-review-*` — Reviewing a teammate's PR
**Agent:** `@Reviewer`

Steps: (triage) → review + testing guide → you test → verdict + GitHub comment

| Prompt | Purpose |
|---|---|
| `pr-review-triage` | File table + risk level. *(optional — skip for small PRs)* |
| `pr-review` | Context, testing guide, code review, GitHub comment. One stop. |

**Start with:**
```
@Reviewer
#read .github/prompts/pr-review.prompt.md

pr_url=https://github.com/your-org/your-repo/pull/XXXX
ticket=https://your-domain.atlassian.net/browse/PROJECT-123
context=<anything you know about the area>
```

---

## `spike-*` — Researching a question before building
**Agents:** `@Architect` → `@Spike-Investigator` → `@Reviewer`

Steps: scope → investigate → review → (educate + file follow-up tickets)

| Prompt | Purpose |
|---|---|
| `spike-contract` | Create searchable `index.md`, then draft scope doc — question, boundaries, timebox, sources. Gate A. |
| `spike-investigate` | Work through sources, journal findings, write detailed output plus a readable `explained.md`. |
| `spike-review` | Verify question was answered, findings are grounded, and `explained.md` is accurate. |

**Start with:**
```
Read .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

---

## `message-*` — Turning dense docs into clearer communication
**Agent:** `@Message-Writer`

Steps: approach → outline → draft → review → lessons learned

Use this when source material is technically dense and the output needs to be easier for a specific audience to consume. This is not only for non-technical readers; use `audience=technical`, `audience=mixed`, or `audience=non-technical`.

| Prompt | Purpose |
|---|---|
| `message-workflow` | Read context docs and a request, propose an approach, outline, draft, review, final message, and reusable style lessons. |

**CLI start with:**
```
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on user experience, points of confusion, and language to avoid.
```

Use `output_mode=conversation` by default. Add `output_mode=final` or `output_mode=full` with `output_dir=messages/<name>` when the message should be preserved.

---

## `pointing-*` — Sprint estimation
**Agent:** `@pointing-analyst`

```
@pointing-analyst
#read .github/prompts/pointing-plan.prompt.md

mode=sprint
sprint=Apollo 2.0 (2026)
```

---

## Dev starters
**Agents:** `@Legacy-Dev` · `@Mobile-Dev`

```
# Legacy
Read .github/prompts/legacy-dev-start.prompt.md

# Mobile
Read .github/prompts/mobile-start.prompt.md
```

---

## Standalone tools
No workflow — invoke directly.

### `quality-audit` — Perf, a11y, and SEO audit
**Automatically runs** inside `workflow-review` and `pr-review` on every changed `.tsx`/`.jsx` file — you don't need to trigger it separately during reviews.

**Use it standalone** when you want to audit a file that *isn't* in a current PR diff — e.g., a page you're about to refactor, a flagged component, or any file from a previous review.

```
#read .github/prompts/quality-audit.prompt.md
target=apps/next-webapp/src/pages/learn/[id].tsx
```

### Other standalones

| Prompt | Use for |
|---|---|
| `tech-debt-scan` | Prioritized tech debt list for a given area |
| `fix-docs-index` | Repair the docs index file |

---

## Skills

Skills are self-contained tools invoked by name — no prompt file needed. Just describe what you want.

### `sonar-check` — SonarQube code quality & coverage
Queries the configured SonarQube instance for code smells and test coverage. Use this **instead of `workflow-sonar`** when you want a quick targeted check on a file, component, or PR.

```
use the sonar-check skill on src/components/MyComponent.tsx
use the sonar-check skill on PR #6531
```

Presents findings with prioritized recommendations. Will apply fixes only with your explicit approval.

### `tailwind-check` — Tailwind CSS audit
Runs ESLint + manual inspection on a file for Tailwind violations (arbitrary values, unapproved colors, etc.) and suggests standard token replacements.

```
use the tailwind-check skill on src/components/MyComponent.tsx
```

Defined in `.github/skills/tailwind-check/SKILL.md`. Also runs automatically inside `workflow-review` and `pr-review` on changed `.tsx`/`.jsx` files.

### `copilot-chat-cleanup` — Clean up old chat threads
Safely removes old VS Code Copilot chat conversation threads. Always shows a dry-run first and asks for confirmation before deleting anything. Preserves threads by title, content, or session ID.

```
use the copilot-chat-cleanup skill
```
