# Code Review Workflow — Quick Reference

Pipeline: **Context + Testing Guide → [you test / agent reviews in parallel] → Verdict**

> For reviewing **someone else's PR** from a GitHub URL + Jira ticket.
> No local branch checkout or standup files needed.
>
> For reviewing **your own PR** before opening it, use `.github/how-to/howToUse.md` Step 5.

**Agent:** `@Reviewer` — has `github` + `atlassian` tools built in. No new agent needed.

---

## Steps Involved

### Optional — Triage A Large PR First

```text
Act as Reviewer following .github/prompts/pr-review-triage.prompt.md

pr_url=https://github.com/your-org/your-repo/pull/<PR_NUMBER>
output_dir=workflow/code-review/<repo>-pr-<PR_NUMBER>
```

### Step 1 — Run The Review

```text
Act as Reviewer following .github/prompts/pr-review.prompt.md

worktree=monorepo
pr_url=https://github.com/your-org/your-repo/pull/<PR_NUMBER>
ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/code-review/<repo>-pr-<PR_NUMBER>
context=<anything you know about the area>
```

### Step 2 — Report Test Results

```text
Here's what I found testing:
- [step X] worked as expected
- [step Y] failed because <what happened>
- I did not check <area>
```

### Step 2 Alternative — Skip Testing

```text
skip testing
```

---

## The flow

The review runs in three stages designed so your time and the agent's time overlap:

1. **Stage 1** — Agent explains the PR and gives you a testing guide. You go test.
2. **Stage 2** — Agent does the full code review immediately while you're testing. One stop.
3. **Stage 3** — You come back with test results. Agent combines findings + results → verdict + GitHub comment.

---

## Step 1 — Gather inputs

- **GitHub PR URL** — e.g. `https://github.com/your-org/your-repo/pull/6531`
- **Jira ticket URL** — optional, enables AC coverage check
- **Your context** — anything you know: area familiarity, author's known constraints, prior conversations
- **Output directory** — optional; defaults to `workflow/code-review/<repo>-pr-<PR_NUMBER>`

Context doesn't need to be formal. A sentence helps.

---

If you have trouble loading the branch or ticket, retry 1-2 times. After that, stop and let me know so I can paste the relevant PR description, ticket description, acceptance criteria, comments, or other review context.


## Step 2 — Run the review

**You say:**
```
Act as Reviewer following .github/prompts/pr-review.prompt.md

worktree=monorepo
pr_url=https://github.com/your-org/your-repo/pull/<PR_NUMBER>
ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/code-review/<repo>-pr-<PR_NUMBER>
context=<anything you know>
```

**What happens:**

**Stage 1 output (read this, then go test):**
- What the PR does in plain language
- Files changed + why
- AC list from ticket
- Testing guide — manual steps and/or backend verification, tailored to the diff
- Also written to `workflow/code-review/<repo>-pr-<PR_NUMBER>/testing-guide.md`

**Stage 2 output (ready when you're back from testing):**
- What works well
- Concerns (non-blocking)
- Blockers (must fix — only when the agent is confident)
- Questions for Author (looks off but may be intentional — phrased as questions)
- Edge cases & breaking risks
- AC coverage table
- Also written to `workflow/code-review/<repo>-pr-<PR_NUMBER>/review.md`

**One stop point** after Stage 2, asking for your test results.

---

## Step 3 — Report test results

Come back with what you found: what passed, what failed, anything unexpected.

**You say:**
```
Here's what I found testing:
- [step X] worked as expected
- [step Y] the modal didn't close on Escape
- didn't check the backend path
```

Or say `skip testing` to go straight to the verdict.

**Stage 3 output:**
- Final verdict: APPROVE or REQUEST CHANGES
- Numbered change requests (if any)
- GitHub comment ready to paste (≤ 200 words, plain language)
- Also written to `workflow/code-review/<repo>-pr-<PR_NUMBER>/verdict.md`; your testing notes are written to `testing-notes.md`

---

## Step 4 — Post to GitHub *(human action)*

Paste the GitHub comment on the PR. Add inline comments for specific file/line findings if needed.

---

## Handling findings

| Finding type            | What to do                                                     |
| ----------------------- | -------------------------------------------------------------- |
| **Blocker**             | Request change — reference the line                            |
| **Concern**             | Your call — suggest it or leave a comment                      |
| **Question for Author** | Post as a genuine question, don't block                        |
| **Edge case**           | Discuss with author — decide if it needs handling before merge |

---

## Tips

- **`context=` is the most valuable input.** Even one sentence reduces false alarms. Include: bug symptoms, standards being fixed (WCAG, a11y), or author's known constraints.
- **Triage first for large PRs (20+ files):** Run `pr-review-triage.prompt.md` to get a quick file table and risk level before committing to the full review.
- **Disagree with a finding?** Say so — the agent will reassess or drop it.
- **Author already addressed something?** Include it in `context=` so it doesn't get re-raised.
- **Want a fix suggestion for a specific blocker?** Ask: "Give me a concrete fix for blocker #2."

---

## Common False Alarms to Watch For

### "It Works the Same as Before"
✅ **This is often CORRECT for compliance fixes**
- Semantic HTML upgrades (e.g., `<div onClick>` → `<button>`)
- Accessible name additions (e.g., `aria-label` on icon buttons)
- ARIA compliance improvements

❌ Don't assume "same behavior = not fixed"

If manual testing shows identical UX but code quality improved → **that's success.**

### Tooltip vs Popover Confusion
- **Tooltip:** Auto-shows on hover/focus — no activation needed (WAI-ARIA standard)
- **Popover/Dialog:** Requires Space/Enter to open

ℹ️ Agent may incorrectly flag auto-show tooltips as "requiring activation" — verify against W3C tooltip pattern if flagged.

### When the Agent Should Stop and Ask

If you see the agent:
- Issuing BLOCKERs for patterns that match documented standards
- Calling correct WAI-ARIA implementations "violations"
- Contradicting your manual test results

→ **Push back.** Provide the standard/doc reference and ask for reassessment.

Agent should ask clarifying questions when:
- Unfamiliar with the pattern being implemented
- PR mentions a specific standard/pattern not fully understood
- Manual testing contradicts code review findings
