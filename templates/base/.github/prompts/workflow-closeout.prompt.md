---
name: workflow-closeout
description: Run post-review closeout for a completed ticket: write the education overview first, then extract promotion candidates before pushing.
agent: Architect
tools: [read, write, edit, search, agent]
---

# Closeout Invocation

## Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir} # optional - defaults to workflow/tickets/${ticket}
- context: ${input:context}       # optional - file path(s) to additional context (comma-separated or single path)

## 0. Resolve Paths
Before loading context, resolve `ticket` and `output_dir`:

1. If either value was omitted, read `workflow/tickets/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values.
2. If `ticket` is a full Jira URL, extract the `PROJECT-123` ID.
3. If `output_dir` is still missing, use `workflow/tickets/${ticket}`.
4. If `context` was provided, read each listed file before closeout.
5. Treat any additional inline instructions in the invocation, such as "run closeout but also consider x.md", as developer-provided context. If a file path is mentioned, read it before closeout.
6. If `ticket` is still missing after active-state lookup, ask the user for it before proceeding.

Use the resolved output directory for every artifact below.

## Purpose
Closeout combines the two post-review steps that are easy to forget when run separately:

1. **Educate** - write the task-local mentoring walkthrough to `overview.md`.
2. **Promote** - extract durable lessons and propose global instruction updates.

Run them in that order. Education is task-local and low risk; promotion is broader and must stay approval-gated.

## Context To Load
Read these ticket artifacts before doing any closeout work:

```text
#read ${output_dir}/prompt.md
#read ${output_dir}/plan.md
#read ${output_dir}/handoff.md
#read ${output_dir}/test.md
#read ${output_dir}/pull-request.md
```

Also read:

```text
#read .github/prompts/workflow-educate.prompt.md
#read .github/agents/educator.agent.md
#read .github/prompts/workflow-promote.prompt.md
#read .github/copilot-instructions.md
#read .github/lessons-learned.md
```

If `pre-context.md` exists in the ticket folder, read it too.

## Stage 1 - Education
Complete the education stage first.

Follow the substance of `.github/prompts/workflow-educate.prompt.md` and `.github/agents/educator.agent.md`:

- Read the changed files referenced in `handoff.md` and `pull-request.md`.
- Explain the implementation in broad-to-minor dependency order: source-of-truth first, then adapters/hydration, then mappers, then consumers, then analytics/minor dependencies.
- Focus on touched runtime files. Skip tests, mocks, and type-only files unless they are necessary to understand runtime behavior.
- Answer likely developer questions inline and replace uncertainty with direct answers grounded in the code.
- Cover important compatibility behavior, future cleanup boundaries, and any major plan deviation where it matters.
- Reference code points as `path/to/file.ts:LINE - functionName()`.
- Use only real snippets from the workspace.
- Keep the walkthrough concise and scan-friendly. `overview.md` is a human-facing education artifact.
- Do not apply this conversational style to contract-oriented artifacts. `prompt.md`, `plan.md`, `test.md`, and `handoff.md` should keep their formal workflow structure and traceability.

Write the complete walkthrough to:

```text
${output_dir}/overview.md
```

If the file exists, replace its body. If it does not exist, create it.

Announce:

```text
Stage Complete: Education (Closeout 1/2)
```

Do not stop after education. Continue to promotion.

## Stage 2 - Promotion
After `overview.md` is written, extract project-wide lessons.

Use:

- `${output_dir}/handoff.md`
- `${output_dir}/pull-request.md`
- `${output_dir}/overview.md`
- `.github/lessons-learned.md`
- `.github/copilot-instructions.md`

Only propose lessons that fit all criteria:

- Apply to all contributors, not just one ticket.
- Improve coding, documentation, security, reliability, accessibility, testing, or consistency.
- Do not reference task-scoped mechanics like `plan.md`, `prompt.md`, or `handoff.md`.
- Do not encode multi-phase workflow logic.
- Are durable enough to help future tickets.

Write task-local promotion notes to:

```text
${output_dir}/lessons-learned.md
```

Include:

1. Promotion candidates
2. Rationale for each candidate
3. Minimal proposed patch for `.github/lessons-learned.md`
4. Optional proposed patch for `.github/copilot-instructions.md` if a rule belongs there
5. Recommendation: apply, defer, or skip each candidate

## Approval Gate
Stop before modifying any global files.

Ask the human to approve, revise, or skip the proposed promotion patch.

If the human approves and the current runtime has explicit permission to edit global instruction files:

1. Append approved lessons to `.github/lessons-learned.md` using the existing file format.
2. Apply only approved `.github/copilot-instructions.md` edits, if any.
3. Announce:

```text
Stage Complete: Closeout
```

If the current runtime does not have permission to edit global instruction files, do not work around that boundary. Leave the approved patch in `${output_dir}/lessons-learned.md`, tell the human it is ready to apply with a write-enabled agent, and announce:

```text
Stage Complete: Closeout (global patch proposed)
```

If the human skips promotion:

1. Leave `${output_dir}/overview.md` and `${output_dir}/lessons-learned.md` in place.
2. Announce:

```text
Stage Complete: Closeout (promotion skipped)
```

## End State
After closeout is complete, produce the exact next steps:

First update `workflow/tickets/.active-workflow.md`:

```md
# Active Workflow
ticket: ${ticket}
ticket_url: https://your-domain.atlassian.net/browse/${ticket}
output_dir: ${output_dir}
last_completed_stage: closeout
next_stage: push-pr
updated_by: workflow-closeout
```

```text
Push the branch, open a PR in GitHub using ${output_dir}/pull-request.md, and wait for CI.

After CI finishes and the PR number is known:
#read .github/prompts/workflow-sonar.prompt.md
ticket=${ticket}
pr_number=<PR_NUMBER>
```

Then STOP.
