---
name: pr-review-triage
description: Stage 1 — triage a GitHub PR you did not author. Gathers all available context before committing to a full review.
agent: Reviewer
tools: [read, search, github, atlassian/atlassian-mcp-server/*]
infer: false
target: vscode
---

# Inputs
- pr_url: ${input:pr_url}     # e.g. https://github.com/your-org/your-repo/pull/6531
- ticket: ${input:ticket}     # optional — e.g. https://your-domain.atlassian.net/browse/PROJECT-123
- context: ${input:context}   # optional — anything you already know about the area, author's intent, or known constraints
- output_dir: ${input:output_dir} # optional — defaults to workflow/code-review/<repo>-pr-<number>

# 0. Normalize Output Directory
Before fetching context, resolve `output_dir`.

1. Extract the repo name and PR number from `pr_url`.
2. If `output_dir` was omitted, set it to `workflow/code-review/<repo>-pr-<number>`.
3. Ensure `${output_dir}` exists.
4. Create or update `${output_dir}/index.md` with:
   - PR URL
   - ticket URL if provided
   - workflow_type: code-review
   - output_dir
   - status: triage
   - artifact map for `triage.md`, `review.md`, `verdict.md`, and `testing-notes.md`

# 1. Fetch All Available Context
Use every source available before forming opinions. Pull:

**From GitHub:**
- PR title, description/body, and target branch
- All existing review comments (other reviewers may have already raised issues)
- Linked issues or referenced PRs in the description
- List of changed file paths

**From Jira (if ticket provided):**
- Acceptance Criteria
- Problem statement / description
- Any linked sub-tasks or related tickets

**From the diff itself:**
- Any inline comments or TODO/FIXME markers in changed code

# 2. Synthesize Context
Before producing any output, consolidate what you know:
- What problem is this PR solving?
- What constraints or decisions can be inferred from the description?
- What is NOT explained anywhere (gaps you'll need to ask the author about)?

# 3. Triage Output
Keep compact.

## Changed Files
| File | Feature Area | Risk Signal |
|---|---|---|
| (path) | (area) | Low / Med / High — one reason |

## Acceptance Criteria
Bullet list from ticket. If none: "(none provided)"

## Context Summary
2–4 sentences: what you understand about the intent of this PR based on all available sources.

## Context Gaps
Things you don't know that could change how findings are classified. These become questions for the author in the full review.

## Risk Level
**Low / Medium / High** — one sentence.

## Recommended Focus
2–3 areas to prioritize (or flag as unclear and needing author input).

# 4. Stage Completion
- Write the full triage output to `${output_dir}/triage.md`.
- Announce: "Stage Complete: Triage"
- Ask: "Does this scope look right? Anything to add about the author's intent or constraints before I do the full review?"
- Provide next command:
  ```
  @Reviewer
  #read .github/prompts/pr-review.prompt.md

  pr_url=${pr_url}
  ticket=${ticket}
  output_dir=${output_dir}
  context=<add anything from triage or your own knowledge>
  ```

STOP. Wait for human confirmation.
