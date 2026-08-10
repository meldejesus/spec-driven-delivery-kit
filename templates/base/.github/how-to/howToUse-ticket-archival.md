# How to Manage Tickets After Merge

> What to keep, what to delete, and why — once a ticket is merged and archived.

---

## Context

Once a ticket is merged, its directory moves to `workflow-archive/workflow/tickets/<ticket-id>/`.
At that point, the workflow artifacts (plan, handoff, codebase-scan, etc.) have served their
primary purpose. This guide describes two defensible approaches for pruning that directory,
with the trade-offs of each.

The worst-case scenarios to plan for:
1. **Bug resurfaces** — the same area breaks again; a developer needs to understand original intent and what changed.
2. **Follow-up work** — a new ticket addresses the same feature or system; an agent needs to re-orient quickly.

In both cases, the git history and the merged PR are always available as ground truth for *what changed*.
The archive artifacts add context that isn't easily recovered from git alone.

---

## The Two Approaches

### Option A — Minimal (3 files)

Keep only:
- `prompt.md` — original scope, constraints, and acceptance criteria (the *why*)
- `pull-request.md` — what actually shipped, reviewer comments, PR description
- `lessons-learned.md` — generalizable takeaways (delete if it doesn't exist or is empty)

Delete:
- `index.md`
- `plan.md`
- `handoff.md`
- `codebase-scan.md`
- `test.md`
- `reproduce.md`
- `overview.md`
- `file-change-summary.md`

**Pros:**
- Dramatically reduces noise in the archive — each directory is a quick read
- The archive `README.md` index (one-liner per ticket) plus `prompt.md` + `pull-request.md` is
  sufficient to re-orient any agent or developer on what happened
- `lessons-learned.md` captures the only genuinely forward-looking artifact
- Forces distillation: if it mattered, it made it into the PR description or lessons

**Cons:**
- `plan.md` + `handoff.md` together document *pivot decisions* — cases where the original plan changed
  mid-implementation; those pivots are not always visible in the PR description
- If a bug resurfaces in a subtle area (e.g., edge case behavior that was a deliberate choice),
  `reproduce.md` would have captured the exact repro steps that may not be in the PR
- `codebase-scan.md`, while stale, sometimes contains system-level reasoning about *why* a file
  was or wasn't touched — useful context that doesn't appear elsewhere
- Relies heavily on PR description quality: if the PR description was thin, you lose a lot

**Best for:** tickets that are clearly finished, low risk of return, and whose PR descriptions were thorough.

---

### Option B — Selective (7 files, drop the 2 most transient)

Keep:
- `index.md` — searchable metadata, keywords, related paths
- `prompt.md` — original scope, constraints, AC
- `plan.md` — what was planned (illuminates pivot decisions in handoff)
- `handoff.md` — pivot journal; documents decisions made mid-implementation
- `reproduce.md` — repro steps (especially valuable for bug tickets)
- `pull-request.md` — what shipped
- `lessons-learned.md` — generalizable takeaways

Delete:
- `codebase-scan.md` — pre-implementation file survey; code has changed, no longer accurate
- `test.md` — implementation-time evidence log; the live test suite is the current truth
- `overview.md` and `file-change-summary.md` — covered by `pull-request.md`

**Pros:**
- `plan.md` + `handoff.md` together tell the full story of intent vs. reality — invaluable when
  a bug surfaces in code that looks "wrong" but was a deliberate tradeoff
- `reproduce.md` means a developer doesn't have to reconstruct repro steps from scratch if
  the exact same bug resurfaces (common in edge cases, auth flows, race conditions)
- `index.md` provides structured search metadata that the README index can't fully replace —
  especially useful when an AI agent is re-orienting on the ticket in a new context window
- Aligns with the `howToUse.md` audit trail guidance while still removing the two most transient files

**Cons:**
- More files to skim — a developer revisiting the archive has to read more before finding signal
- `handoff.md` can be very long and detailed in ways that add noise rather than clarity after the fact
- `reproduce.md` is often only valuable for bug tickets — for feature tickets it's just "here's
  how to see the feature work," which is redundant with the PR
- Requires ongoing discipline to maintain if the directory ever gets touched again

**Best for:** complex tickets, bug fixes in tricky areas, tickets likely to have follow-up work, or
tickets where the implementation deviated significantly from the original plan.

---

## Recommended Decision Rule

| Ticket type | Recommended approach |
|---|---|
| Feature ticket, clean implementation, thorough PR | **Option A** (3 files) |
| Bug fix, especially in edge-case or auth/payment areas | **Option B** (7 files) |
| Large refactor with significant pivots documented in handoff | **Option B** (7 files) |
| Small cleanup or dependency update | **Option A** (3 files) |
| Ticket with a known follow-up already planned | **Option B** — delete later when follow-up ships |

When in doubt, the question to ask is: **would the PR description alone be enough to explain a
future bug in this area?** If yes, Option A is fine. If the answer requires nuance — "well, we
deliberately chose X over Y because of Z" — keep `handoff.md`.

---

## Notes on the Audit Trail Guidance in howToUse.md

`howToUse.md` states that `prompt.md + plan.md + handoff.md + pull-request.md` form an audit trail
and "must stay intact." That guidance was written for **active tickets** — specifically to prevent
overwriting files when a change request arrives mid-pipeline.

For cold archive (tickets merged months ago with no active follow-up), that guidance is
overcautious. The "must stay intact" language is protective, not archival. This guide supersedes it
for archive pruning decisions.

---

## Related

- `howToUse.md` — full ticket lifecycle and artifact descriptions
- `workflow-archive/workflow/tickets/README.md` — grouped index of all archived tickets
