---
name: pr-review
description: >
  Three-stage gated PR review for a PR you did not author.
  Stage 1: context + testing guide (you go test).
  Stage 2: full code review + separate author comments run while you test.
  Stage 3: verdict combining code findings + your test results.
agent: Reviewer
tools: [read, grep, glob, bash, write]
infer: false
---

# Inputs
- pr_url: ${input:pr_url}    # e.g. https://github.com/your-org/your-repo/pull/6531
- ticket: ${input:ticket}    # optional — e.g. https://your-domain.atlassian.net/browse/PROJECT-123
- context: ${input:context}  # optional — anything you know about the area, author's intent, or constraints
- output_dir: ${input:output_dir} # optional — defaults to workflow/misc/<pr-title-slug>

# Output Directory
Before fetching the rest of the context, resolve `output_dir`.

1. Extract the repo name and PR number from `pr_url`, then fetch the PR title.
2. Convert the title to a filesystem-safe kebab-case slug:
   - lowercase
   - replace runs of non-alphanumeric characters with `-`
   - collapse repeated `-`
   - trim leading/trailing `-`
3. If `output_dir` was omitted, set it to `workflow/misc/<pr-title-slug>`.
4. If that directory already belongs to a different PR, use `workflow/misc/<pr-title-slug>-<pr-number>`.
5. Ensure `${output_dir}` exists.
6. Create or update `${output_dir}/index.md` with:
   - PR URL
   - PR title
   - ticket URL if provided
   - workflow_type: code-review
   - output_dir
   - status: review-running
   - artifact map for `testing-guide.md`, `review.md`, `author-message.md`, `verdict.md`, and `testing-notes.md`

# Silent Fetch (do this before any output)
1. Use `github` to fetch: PR title, description, changed file paths, full diff, existing review comments
2. Use `atlassian/atlassian-mcp-server/*` (if ticket provided) to fetch: ACs, problem description
3. Read `.github/copilot-instructions.md` for project standards

Gather everything silently, then begin Stage 1.

---

# Stage 1 — Context & Testing Guide

## Discovery Questions *(ask if unclear from PR/ticket)*
Before proceeding, verify your understanding:
1. What user-facing bug or behavior triggered this PR?
2. Is this a compliance fix (WCAG/a11y/standards) or behavioral change?
3. What did the broken state look like (if fixing a bug)?
4. Has the author already addressed standard concerns in the PR description?

If any answers are unclear and `context` input doesn't clarify, **ask 1-2 targeted questions** before continuing.

---

Output sections below, then immediately continue to Stage 2 without stopping.

## What This PR Does
3–5 sentences: what problem it solves, what approach was taken, what files it touches.
Plain language — assume the reader knows the product but not this specific change.

## Files Changed
| File | What changed | Why |
|---|---|---|
| (path) | (what) | (inferred from diff + description) |

## Acceptance Criteria *(skip if no ticket)*
Bullet list from ticket.

## How to Test This

Tailor to what the diff actually changes. Detect from the diff: frontend, backend, or both.

### Manual Steps *(skip if no UI changes)*
1. Start at: [route/URL]
2. Numbered steps — what to do, what to expect
3. Include at least one edge case worth checking (empty state, error path, etc.)

### Backend / API Verification *(skip if no backend changes)*
- What to run or query to confirm the change took effect
- Expected state before and after
- Any setup, flags, or env vars needed

### Automated Tests
- Where the tests live and how to run them (exact command)

Write Stage 1 to `${output_dir}/testing-guide.md`.

---

*Go test. The code review is running below — read it when you're back.*

---

# Stage 2 — Code Review

Run immediately after Stage 1. Do not stop for input.

## Review Discipline — Avoid False Alarms

**Before classifying anything as a finding:**
1. Could this be an intentional decision with context you don't have?
2. Does the code match a documented pattern (WAI-ARIA, React, Next.js best practices)?
3. For accessibility fixes: Does the implementation follow W3C/MDN guidance for that pattern?
4. **Functional equivalence is often correct** — if behavior is unchanged but code quality improved, that's the goal

**Common false alarm scenarios:**
- **Compliance fixes:** Same UX, better semantics (e.g., `<Icon tabIndex={0}>` → `<button>`) — this is SUCCESS
- **Tooltip patterns:** Auto-show on focus is correct per WAI-ARIA Tooltip Pattern — don't require activation
- **ARIA semantics:** Accessible names without visible labels are valid (e.g., icon buttons with `aria-label`)

**Severity ladder:**
- **BLOCKER:** Confident it's wrong AND breaks functionality/standards — cite specific standard violated
- **SHOULD FIX:** Important correctness, maintainability, performance, or UX issue that should be addressed but does not independently require rejection
- **QUESTION:** Looks unusual but may be intentional — phrase as genuine question for author
- **NICE TO HAVE:** Low-risk improvement that should not distract from more serious findings

**If unsure → QUESTION, not BLOCKER.**

## What Works Well
Bullet list of non-obvious good decisions. Skip anything trivially fine.

## Blockers *(must fix — confident)*
`[file.ts:L##] What — plain-language impact`

## Should Fix *(important, non-blocking)*
`[file.ts:L##] What — why it matters`

## Questions for Author *(intent unclear — don't block on these)*
`[file.ts:L##] What looks off — what you'd need to know`

## Nice to Have *(optional; keep brief)*
`[file.ts:L##] Small improvement — expected benefit`

## Quality Audit (automatic — changed UI files)
For each changed `.tsx` / `.jsx` file in the diff, apply the full checklist in `.github/prompts/quality-audit.prompt.md` against the **whole file** (not just the diff lines). Rate each issue: BLOCKER / SHOULD FIX / NICE TO HAVE. Skip this section only if no UI files changed.

## Edge Cases & Breaking Risks
Specific uncovered scenarios or potential regressions.

## AC Coverage *(skip if no ticket)*
| AC | Status | Notes |
|---|---|---|
| (text) | ✅ / ❌ / ⚠️ | |

Write Stage 2 to `${output_dir}/review.md`.

## Author Messages (required)

After writing `review.md`, create `${output_dir}/author-message.md` for comments the reviewer can paste directly into GitHub.

### Selection rules

1. Include only BLOCKER and SHOULD FIX findings.
2. Rank BLOCKERs first, then SHOULD FIX findings. Within a severity, prioritize user impact, correctness, security, data loss, and regression risk.
3. Include no more than the top 3 findings total. Prefer 1–2 when those capture the meaningful risk; do not overwhelm the author.
4. Never combine separate findings into one comment. Each selected finding gets its own self-contained GitHub comment.
5. Do not include QUESTION or NICE TO HAVE items. Keep lower-priority findings in `review.md` so the user can request them later.
6. If there are no BLOCKER or SHOULD FIX findings, still create `author-message.md` with: `No author comments recommended.`

### Required file structure

Order findings from most to least serious:

```markdown
# Author Messages

## Comment 1 — <short finding name>

**Severity:** BLOCKER | SHOULD FIX
**Location:** `path/to/file.ts:line`

### GitHub Comment

<paste-ready comment>

### How to Test Manually

1. <setup or starting route>
2. <action>
3. <expected broken behavior before the fix>
4. <expected behavior after the fix>
```

Repeat the `Comment N` block for each selected finding.

### GitHub comment style

- Write for the PR author in a friendly, informal, collaborative tone.
- Keep each comment concise: normally 60–140 words, never more than 170 words.
- Explain the problem and its user/system impact in plain language so it is obvious why a blocker blocks or why a SHOULD FIX matters.
- Include a specific fix or a concrete hint toward the right implementation seam.
- Keep the problem and proposed fix together in the paste-ready comment.
- Do not include the manual walkthrough inside the GitHub comment.
- Mention code symbols or paths only when the author needs them to act.
- Avoid audit language, long evidence dumps, multi-issue lists, and formal review boilerplate.
- Do not repeat the same finding in another author comment.

### Concision model

Use this level of directness and detail. Adapt it to the actual finding; do not copy it mechanically:

> Thanks for the PR. I don't think this fixes the user-facing path yet because the new filter lives in a provider the app doesn't use. Transcript links are generated on the server before this component renders, so users can still receive the archived link even though the new endpoint returns the right data. Could we move the retirement check into the shared server-side link builder and return plain text for retired targets? That would fix the active path and protect every feature that uses the same link builder.

### Manual test style

- Keep the walkthrough outside the paste-ready comment.
- Use a concrete local route, command, input, or state when available.
- State what reproduces the issue before the fix and what proves the fix afterward.
- Prefer 3–6 steps. If no UI/manual route exists, provide the smallest API, CLI, or source-level walkthrough that demonstrates the behavior.

---

**STOP — Code review complete.**
Come back with your test results and I'll produce the final verdict. The highest-priority paste-ready comments are already in `author-message.md`.
Say what passed, what failed, or anything unexpected. Say `skip testing` to go straight to verdict.

---

# Stage 3 — Verdict

Incorporate the user's test results into the final output. If testing revealed new issues, add them to the verdict.
If the user provides test results, write them to `${output_dir}/testing-notes.md`. If the user says `skip testing`, write that note instead.

Re-rank the BLOCKER and SHOULD FIX findings after incorporating test results. Update `author-message.md` so it still contains only the top 3 findings, each as a separate comment with its own manual walkthrough. Remove or downgrade comments disproved by testing.

## Final Verdict
**APPROVE** or **REQUEST CHANGES** — one sentence.

## Change Requests *(if REQUEST CHANGES)*
Numbered list. Each: what to fix and why.

## Posting Guidance
- List the author-message comments to post, in priority order.
- Do not merge multiple findings into a single GitHub comment.
- If the verdict is APPROVE and there are no author messages, provide one short approval sentence.

Write Stage 3 to `${output_dir}/verdict.md`.

STOP. Point the user to `author-message.md` for the separate copy-paste comments.
