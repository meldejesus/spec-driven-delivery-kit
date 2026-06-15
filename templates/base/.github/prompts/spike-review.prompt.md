---
name: spike-review
description: Review a completed spike — validate that the question was answered, check for gaps, and approve or request changes before follow-up tickets are filed.
agent: Reviewer
tools: [read, search, write]
infer: false
target: vscode
---

# Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir}

# Context to Load
1. `${output_dir}/scope.md` — the original question and boundaries
2. `${output_dir}/findings.md` — the investigation audit trail
3. `${output_dir}/spike-output.md` — the output to review
4. `${output_dir}/explained.md` — the readable front-door summary

# Review Rules

This is a **document review**, not a code review. Your job is to answer:

1. **Did the investigation answer the scoped question?**
   - Is the Executive Summary a direct answer to the question in `scope.md`?
   - If not, flag as BLOCKER: "Question not answered"

2. **Are the findings grounded in evidence?**
   - Every claim in the Technical Findings section should trace to a source in `findings.md`
   - Flag any unsupported assertions

3. **Are gaps honestly represented?**
   - Gaps should be explicit, not hidden in vague language
   - If the confidence level seems inflated relative to the gaps listed, flag it

4. **Is scope respected?**
   - Did the investigation stay within the bounds of `scope.md`?
   - Out-of-scope material is fine in "Suggested Follow-ups" but not in findings

5. **Are follow-up tickets clearly justified?**
   - Each suggested ticket should trace to a specific finding
   - Remove or flag any that feel speculative

6. **Is explained.md useful and accurate?**
   - It should start with known quantities: the basic goal and target page/route/endpoint/admin surface
   - It should be shorter and easier to read than `spike-output.md`
   - It should not contradict `spike-output.md` or introduce unsupported claims
   - It should preserve implementation-critical details such as data targets, permissions, safety behavior, and cache/index/purge work

# Severity Scale
- **BLOCKER** — question not answered, major gap unacknowledged, or confidence level misleading
- **SHOULD FIX** — finding unsupported by evidence, scope breach, vague gap description
- **SUGGESTION** — wording, structure, or missing context that would improve usefulness

# Deliverables

## Decision
**APPROVE** or **REQUEST CHANGES** — one sentence why. Include whether both `spike-output.md` and `explained.md` are acceptable.

## Summary
3–5 bullets on overall quality and coverage.

## Findings
Severity-rated list. Each with: what the issue is, where it appears in the document, and suggested fix.

## Approved Follow-up Tickets
If APPROVE: confirm which suggested follow-up tickets (if any) should be filed, and flag any that should be dropped.

# End State
1. If **APPROVE**:
   - Write review decision to `${output_dir}/spike-output.md` as a footer block:
     ```
     ---
     ## Review
     **Decision:** APPROVED
     **Reviewer note:** <one sentence>
     **Reviewed:** <date>
     ```
   - Announce **"Stage Complete: Review (Gate D)"**
   - Provide next CLI invocation for follow-up ticket filing (optional):
     ```
     File follow-up tickets from workflow/tickets/PROJECT-123/spike-output.md — Suggested Follow-up Tickets section
     ```

2. If **REQUEST CHANGES**: list BLOCKER items with exact fix guidance. Do not write to `spike-output.md`. STOP.
