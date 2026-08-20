---
name: worklog
description: >
  Update the session log, dashboard, and CLAUDE.md state block at the end of a
  work session. Generates the dashboard from workflow ticket metadata. Keeps the
  CLAUDE.md state block current so the next session can recover context in under
  10 lines. Run this at the end of any meaningful work session.
---

# Worklog Update

Use this skill at session close to record what happened and set up the next session for fast recovery.

## When to run

- At the end of any session where ticket state changed
- After completing a Gate (A, B, C, or D)
- After getting blocked
- Before switching tickets or ending a long session

For explicit session handoff to a fresh agent, also run the `handoff` skill after this one.

## Procedure

### Step 1 — Write the session log entry

Append a new entry to `worklog/daily-log.md` (newest first, below the `<!-- Sessions appear below this line -->` marker):

```
## YYYY-MM-DD HH:MM — <TICKET-ID> — <started|progressed|completed|blocked>

**Done:** <specific outcomes — what changed, what was verified, what passed>
**Open:** <unresolved threads — each should reference a ticket or be noted on the ticket>
**Blocked:** <what is blocking and which ticket owns it — or "nothing">
**Decisions:** <locked choices made this session — also add these as notes to the ticket file>
```

Rules:
- **Done** must be outcome-focused, not activity-focused. "Tests passing (3/3)" not "worked on tests."
- **Decisions** that appear here must also be appended as a note in `workflow/<ticket-id>/index.md` or `handoff.md`.
- Keep the entry under 10 lines. Git carries the file-level record; this log carries outcomes and decisions.
- Do not copy commit hashes or file lists into this log — git already has those.

### Step 2 — Update the CLAUDE.md state block

Update the `<!-- BEGIN STATE --> ... <!-- END STATE -->` block in `CLAUDE.md`:

```
<!-- BEGIN STATE -->
last_session: <YYYY-MM-DD HH:MM>
working: <TICKET-ID> — <one-line description of where we are in the ticket>
blocked: <what is blocking, or "nothing">
next: <the single most important action for the next session — one sentence>
recent:
  - <YYYY-MM-DD>: <one-line outcome from this session>
  - <previous entry>
  - <previous entry>
  - <previous entry>
  - <previous entry>
<!-- END STATE -->
```

Rules:
- `next` is the most important field — it is what the next session reads first.
- `recent` keeps the last 5 sessions only (drop the oldest when adding a new one).
- `working` should describe both the ticket and *where in the workflow* you are ("OSMS-123 — implement, task 4/7 done").

### Step 3 — Regenerate the dashboard

Regenerate `worklog/dashboard.md` from current ticket state:

1. Scan `workflow/*/index.md` for tickets with `status: in-progress` or `status: blocked` in their YAML frontmatter.
2. Scan `worklog/daily-log.md` for entries in the last 7 days.
3. Write `worklog/dashboard.md` using the template structure:
   - **In Progress** — tickets with `status: in-progress`
   - **Blocked** — tickets with `status: blocked`, include the blocking ticket ID
   - **Done This Week** — tickets closed in the last 7 days (from session log entries with `completed`)
   - **Recent Sessions** — last 5 session log entries (ticket ID, status word, one-line outcome)

Do not add tickets to the dashboard by hand. The dashboard is always generated from source files.

### Step 4 — Report

Output a brief summary:
- Session entry written to `daily-log.md`
- CLAUDE.md state block updated
- Dashboard updated: N in-progress, N blocked, N done this week
- Any tickets whose `index.md` frontmatter is missing `status` (needs manual fix)

## Recovery path (if shell scripts are unavailable)

This skill works without any shell scripts. All steps above are agent-native:
- Read `workflow/*/index.md` frontmatter directly
- Append to `daily-log.md` by reading the current file and prepending the new entry
- Edit the `<!-- BEGIN STATE -->` block in `CLAUDE.md` by reading and editing the file

The shell scripts (`worklog-sync.sh`, `worklog-enrich.py`) in your private workspace can accelerate steps 1–3 if available, but this skill does not require them.
