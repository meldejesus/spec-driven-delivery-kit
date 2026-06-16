---
name: pr-review
description: >
  Three-stage gated PR review for a PR you did not author.
  Stage 1: context + testing guide (you go test).
  Stage 2: full code review runs immediately while you test.
  Stage 3: verdict combining code findings + your test results.
agent: Reviewer
tools: [read, search, github, atlassian/atlassian-mcp-server/*]
infer: false
target: vscode
---

# Inputs
- pr_url: ${input:pr_url}    # e.g. https://github.com/your-org/your-repo/pull/6531
- ticket: ${input:ticket}    # optional — e.g. https://your-domain.atlassian.net/browse/PROJECT-123
- context: ${input:context}  # optional — anything you know about the area, author's intent, or constraints
- output_dir: ${input:output_dir} # optional — defaults to workflow/code-review/<repo>-pr-<number>

# Output Directory
Before fetching context, resolve `output_dir`.

1. Extract the repo name and PR number from `pr_url`.
2. If `output_dir` was omitted, set it to `workflow/code-review/<repo>-pr-<number>`.
3. Ensure `${output_dir}` exists.
4. Create or update `${output_dir}/index.md` with:
   - PR URL
   - ticket URL if provided
   - workflow_type: code-review
   - output_dir
   - status: review-running
   - artifact map for `testing-guide.md`, `review.md`, `verdict.md`, and `testing-notes.md`

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
- **CONCERN:** Suboptimal but not breaking — suggest improvement
- **QUESTION:** Looks unusual but may be intentional — phrase as genuine question for author

**If unsure → QUESTION, not BLOCKER.**

## What Works Well
Bullet list of non-obvious good decisions. Skip anything trivially fine.

## Concerns *(non-blocking)*
`[file.ts:L##] What — why it matters`

## Blockers *(must fix — confident)*
`[file.ts:L##] What — plain-language impact`

## Questions for Author *(intent unclear — don't block on these)*
`[file.ts:L##] What looks off — what you'd need to know`

## Quality Audit (automatic — changed UI files)
For each changed `.tsx` / `.jsx` file in the diff, apply the full checklist in `.github/prompts/quality-audit.prompt.md` against the **whole file** (not just the diff lines). Rate each issue: BLOCKER / CONCERN / NICE TO HAVE. Skip this section only if no UI files changed.

## Edge Cases & Breaking Risks
Specific uncovered scenarios or potential regressions.

## AC Coverage *(skip if no ticket)*
| AC | Status | Notes |
|---|---|---|
| (text) | ✅ / ❌ / ⚠️ | |

Write Stage 2 to `${output_dir}/review.md`.

---

**STOP — Code review complete.**
Come back with your test results and I'll produce the final verdict + GitHub comment.
Say what passed, what failed, or anything unexpected. Say `skip testing` to go straight to verdict.

---

# Stage 3 — Verdict

Incorporate the user's test results into the final output. If testing revealed new issues, add them to the verdict.
If the user provides test results, write them to `${output_dir}/testing-notes.md`. If the user says `skip testing`, write that note instead.

## Final Verdict
**APPROVE** or **REQUEST CHANGES** — one sentence.

## Change Requests *(if REQUEST CHANGES)*
Numbered list. Each: what to fix and why.

## GitHub Comment *(paste-ready)*
- Plain English, no file paths in the opening
- Blockers as user/system impact
- Questions as genuine questions
- Change requests numbered for easy author response
- Closes with what would move this to approval (or a clear approval statement)
- **Max 200 words**

Write Stage 3 to `${output_dir}/verdict.md`.

STOP. GitHub Comment last for easy copy-paste.
