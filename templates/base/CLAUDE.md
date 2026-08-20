# CLAUDE.md

Project instructions for Claude Code. This file is read automatically at the start of every session.

---

## Project Commands

<!-- Replace these with your project's actual commands -->

### Testing
- **Unit tests:** `<command>`
- **Integration tests:** `<command>`
- **Affected tests:** `<command>`
- **Update snapshots:** `<command>`

### Build & Lint
- **Build:** `<command>`
- **Lint:** `<command>`
- **Typecheck:** `<command>`

### Dev Servers
- **Frontend:** `<command>`
- **Backend:** `<command>`

---

## Workflow

This project uses the spec-driven delivery kit. All ticket work follows the contract → plan → implement → review → closeout pipeline.

- **Reference:** `.github/how-to/howToUse.md`
- **Agent registry:** `AGENTS.md`
- **Active ticket state:** `workflow/.active-workflow.md`

Run `run contract ticket=PROJECT-123` to start a new ticket.

## Workflow Commands

| Command | What runs |
|---|---|
| `run contract ticket=<ID>` | Architect + `workflow-contract.prompt.md` |
| `run plan` | Plan-Agent + `workflow-plan.prompt.md` |
| `run implement` | Implementer + `workflow-implement.prompt.md` |
| `run review` | Reviewer + `workflow-review.prompt.md` |
| `run closeout` | Architect + `workflow-closeout.prompt.md` |
| `run sonar pr_number=<N>` | Reviewer + `workflow-sonar.prompt.md` |
| `run peer-review pr_url=<URL>` | Reviewer + `pr-review.prompt.md` |
| `run spike-contract ticket=<ID>` | Architect + `spike-contract.prompt.md` |
| `run spike-investigate` | Spike-Investigator + `spike-investigate.prompt.md` |
| `run spike-review` | Reviewer + `spike-review.prompt.md` |
| `run refinement tickets=<ID>` | Pointing-Analyst + `pointing-plan.prompt.md` |
| `run merge-conflict target_branch=<branch>` | Merge-Conflict-Resolver + `merge-conflict.prompt.md` |

## Compact Behavior

- Compact between stages, not mid-stage — compacting mid-task loses the thread.
- Before compacting, write a State Summary to `workflow/<ticket>/handoff.md`.
- Keep ticket context under 80K tokens per stage.
- When `handoff.md` exceeds 50 lines, invoke the Compactor agent before continuing.
- Accuracy degrades past 100K tokens — do not fill the window just because it is available.

---

## Code Rules

<!-- Add project-specific code rules here. Examples: -->
<!-- - Use TypeScript strict mode -->
<!-- - Prefer named exports over default exports -->
<!-- - No direct DOM manipulation outside of hooks -->

---

## Current Work State

<!-- BEGIN STATE -->
last_session: —
working: —
blocked: —
next: —
recent:
  - —
<!-- END STATE -->

<!--
HOW THIS BLOCK WORKS:
- The worklog skill updates this block automatically at session close.
- On session start, read this block first — it answers "where was I?" in under 10 lines.
- "next" is the single most important action for the incoming session.
- "recent" is a rolling list of the last 3-5 sessions (one line each, newest first).
- Do not manually edit this block — let the worklog skill maintain it.
- For full session history, see worklog/daily-log.md.
-->
