---
name: contract-review
description: Independent second-pass review of prompt.md and reproduce.md before planning begins. Optional gate for larger tickets.
agent: Reviewer
infer: false
target: vscode
auto-read:
  - workflow/.active-workflow.md
  - workflow/${ticket}/prompt.md
  - workflow/${ticket}/reproduce.md
tools: [read, write, search]
---

# Inputs
- ticket: ${input:ticket}         # optional — falls back to active workflow
- output_dir: ${input:output_dir} # optional — defaults to workflow/${ticket}

# 0. Resolve Inputs
Read `workflow/.active-workflow.md` for `ticket` and `output_dir` if not supplied. Ask the user only if still ambiguous.

# 1. Purpose
Fresh-eyes pass on the Strategic Contract before any planning tokens are spent. You are NOT the Architect who wrote the contract. Do not rewrite it. Produce findings the Architect can address.

# 2. What to Check
For each item, reference `prompt.md:<section>` and rate severity (BLOCKER / SHOULD FIX / NICE TO HAVE).

1. **AC testability** — Every Acceptance Criterion must have a concrete, observable pass/fail. Flag ACs that use "properly", "as appropriate", "handle X correctly", "etc.".
2. **Scope creep signals** — Flag ACs or constraints that expand beyond the ticket's stated intent.
3. **Ambiguity** — Undefined domain terms, unstated actors, unspecified error states, missing edge cases.
4. **Hidden assumptions** — Things the contract treats as given that a reviewer would question (data volume, auth model, upstream contracts, timezone, currency, i18n).
5. **Missing NFRs** — Perf targets, accessibility, security posture, observability, rollback strategy — flag any the contract silently ignores.
6. **Reproduction quality** — `reproduce.md` should reproduce the issue in ≤5 steps for a stranger to the codebase. Flag missing preconditions or ambiguous steps.

# 3. Output
Write `${output_dir}/contract-review.md`:

```md
# Contract Review — <ticket>

## Decision
APPROVE | REQUEST REVISION — one sentence why.

## Findings
### BLOCKER
- prompt.md:AC-2 — "handles error gracefully" is not testable. Suggest: define the exact error response shape and status code.

### SHOULD FIX
- ...

### NICE TO HAVE
- ...

## Coverage Gaps
- Missing NFRs: <list>
- Missing edge cases: <list>

## Reviewer Notes
Anything the Architect should know that doesn't fit a finding.
```

# 4. Stage Completion
- Do NOT update `.active-workflow.md`. Contract-review is an add-on to Gate A, not a stage of its own.
- Announce: "Contract Review complete — see `${output_dir}/contract-review.md`."
- If Decision = REQUEST REVISION: instruct the human to revise `prompt.md` and optionally re-run this review.
- If Decision = APPROVE: instruct the human to proceed with `run plan`.

STOP.
