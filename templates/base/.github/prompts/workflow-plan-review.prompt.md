---
name: plan-review
description: Independent second-pass review of plan.md before implementation begins. Includes premortem. Optional gate for larger tickets.
agent: Reviewer
infer: false
target: vscode
auto-read:
  - workflow/.active-workflow.md
  - workflow/${ticket}/prompt.md
  - workflow/${ticket}/plan.md
  - workflow/${ticket}/codebase-scan.md
tools: [read, write, search]
---

# Inputs
- ticket: ${input:ticket}         # optional — falls back to active workflow
- output_dir: ${input:output_dir} # optional — defaults to workflow/${ticket}
- mode: ${input:mode}             # optional — "premortem-only" skips risk review sections

# 0. Resolve Inputs
Read `workflow/.active-workflow.md` for `ticket` and `output_dir` if not supplied. If `mode=premortem-only`, skip sections 2A–2C and produce only the Premortem.

# 1. Purpose
Fresh-eyes pass on the Plan before any implement tokens are spent. You are NOT the Plan-Agent. Do not rewrite the plan. Produce findings and a premortem.

# 2. What to Check

## 2A. AC coverage
Every AC in `prompt.md` must map to one or more tasks in `plan.md`. Flag any AC with zero mapped tasks.

## 2B. Approach soundness
- Are tasks truly ≤15 minutes and vertically sliced (tracer-bullet), or are they horizontal batches?
- Are blocking edges (dependencies) correctly ordered?
- Does the plan touch systems the contract didn't mention? Flag scope drift.
- Does the final build validation task exist and name the right command?

## 2C. Technical risk
- Concurrency, race conditions, transaction boundaries
- Backward compatibility (API contracts, DB migrations, feature flags)
- Rollback story — can this be reverted safely?
- Observability — will we know if it breaks in prod?

## 2D. Premortem (always required)
Write the section titled `## Premortem` in the output. Use this exact framing:

> "It is two weeks after ship. Production is broken because of this change. Tell me the story of what happened."

Produce **three concrete failure stories**. Each story must:
- Name a specific sequence of events (not "something might go wrong")
- Reference a specific plan.md task or file touched
- Suggest one design change or new task that would prevent it

Vagueness is not allowed. If you cannot make a story concrete, drop it and write a better one.

# 3. Output
Write `${output_dir}/plan-review.md`:

```md
# Plan Review — <ticket>

## Decision
APPROVE | REQUEST REVISION — one sentence why.

## Findings
### BLOCKER
- plan.md:Task 4 — no rollback path if the migration partially applies. Suggest: split into additive-only migration + separate cutover task.

### SHOULD FIX
- ...

### NICE TO HAVE
- ...

## AC Coverage
- AC-1 → Task 2, 5 ✓
- AC-2 → (no tasks mapped) ✗ BLOCKER
- ...

## Premortem
### Failure Story 1: <short name>
Two weeks post-ship, prod is broken. Here's what happened:
1. <specific event>
2. <specific event>
3. <specific event>
**Root cause:** <the design decision that made this possible>
**Prevention:** <specific plan.md change or new task>

### Failure Story 2: <short name>
...

### Failure Story 3: <short name>
...

## Reviewer Notes
Anything the Plan-Agent should know that doesn't fit a finding.
```

If `mode=premortem-only`, output only the Premortem section (no Findings, no Decision) and title the file `${output_dir}/premortem.md`.

# 4. Stage Completion
- Do NOT update `.active-workflow.md`. Plan-review is an add-on to Gate B, not a stage of its own.
- Announce: "Plan Review complete — see `${output_dir}/plan-review.md`." (or `premortem.md`)
- If Decision = REQUEST REVISION: instruct the human to revise `plan.md` and optionally re-run this review.
- If Decision = APPROVE: instruct the human to proceed with `run implement`.

STOP.
