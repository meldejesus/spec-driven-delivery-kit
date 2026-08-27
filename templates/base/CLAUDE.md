# CLAUDE.md

Project instructions for Claude Code. This file is read automatically at the start of every session.

---

## Project Commands

<!-- Fill in project-specific commands when installing into a workspace -->
- **Tests:** `<command>`
- **Build:** `<command>`
- **Dev server:** `<command>`

---

## Workflow

This project uses the spec-driven delivery kit. All ticket work follows the contract → plan → implement → review → closeout pipeline.

- **Reference:** `.github/how-to/howToUse.md`
- **Agent registry:** `AGENTS.md`
- **Active ticket state:** `workflow/.active-workflow.md`

Run `run contract ticket=PROJECT-123` to start a new ticket.

## Workflow Commands

For workflow commands, see `AGENTS.md`.

## Compact Behavior

- Compact between stages, not mid-stage — compacting mid-task loses the thread.
- Before compacting, write a State Summary to `workflow/<ticket>/handoff.md`.
- Keep ticket context under 80K tokens per stage.
- When `handoff.md` exceeds 50 lines, invoke the Compactor agent before continuing.
- Accuracy degrades past 100K tokens — do not fill the window just because it is available.

---

## Code Rules

<!-- Add project-specific code rules here -->

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
