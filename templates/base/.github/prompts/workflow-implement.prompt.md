---
name: workflow-implement
description: Run the implementation phase for a ticket. Executes plan.md tasks, validates final build, and journals to handoff.md and test.md after every task.
tools: [read, write, edit, terminal, search, agent]
agent: Implementer
auto-read:
  - workflow/.active-workflow.md
  - workflow/${ticket}/prompt.md
  - workflow/${ticket}/plan.md
---

# Implementation Invocation

## Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir} # optional - defaults from active workflow or workflow/${ticket}
- context: ${input:context}       # optional - file path(s) to additional context (comma-separated or single path)

## 0. Resolve Inputs
Before loading context, resolve `ticket` and `output_dir`:

1. If either value was omitted, read `workflow/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values.
2. If `ticket` is a full Jira URL, extract the `PROJECT-123` ID.
3. If `output_dir` is still missing, use `workflow/${ticket}`.
4. If `context` was provided, read each listed file before implementing.
5. Treat any additional inline instructions in the invocation, such as "run implement but also consider x.md", as developer-provided context. If a file path is mentioned, read it before implementing.
6. If `ticket` is still missing after active-state lookup, ask the user for it before proceeding.

**Handoff context:** Read only the last 40 lines of `${output_dir}/handoff.md` unless you need to investigate a specific prior decision. Use the `offset` parameter to read from the end. This keeps context lean as the journal grows.

## Context to Load
1. `#read ${output_dir}/prompt.md` — the immutable contract (ACs, constraints)
2. `#read ${output_dir}/plan.md` — find first `[ ]` task and execute from there
3. `#read ${output_dir}/handoff.md` — last known state; if it does not exist, use `create_file` to create it before writing
4. `#read ${output_dir}/test.md` — existing evidence log; if it does not exist, use `create_file` to create it before writing

If `${output_dir}/pre-context.md` exists, read it too.

> ⚠️ **File creation rule:** Always use `create_file` for handoff.md and test.md on the first run. Never use `replace_string_in_file` on a file that does not yet exist.

## Execution Rules
- Execute tasks **one at a time**, in order from plan.md.
- **After every task**, before moving to the next:
  1. **Update `${output_dir}/handoff.md`** with Success, Friction, and State Summary.
  2. **Update `${output_dir}/test.md`** with PASS/FAIL evidence (or N/A if no test artifact).
  3. **Mark task `[x]`** in plan.md.
  4. **Commit the task** — run `git add -A && git commit -m "<message>"` where `<message>` is a verb-first imperative sentence describing only what this task did. Max 72 chars. No ticket prefix needed.

> **Optional:** For test-first implementation, invoke the `tdd` skill before writing code: `use the tdd skill on <task description>`.
     - Good: `Add search endpoint to API`, `Extract ranking logic into standalone module`, `Add unit tests for session reducer`
     - Bad: `WIP`, `Fix stuff`, `PROJECT-123 changes`
     - If terminal is unavailable, record the intended commit message in `${output_dir}/handoff.md` under `## Pending Commit` so it can be applied manually.
- Never skip journaling, even for trivial tasks — handoff.md is the context survival file.
- If a task fails ≥3 times: mark `[FAILED]`, propose Pivot, stop and wait for Gate C approval.
- **Final build validation is mandatory before implementation can complete.**
  - After all code/doc tasks are done and before the End State update, run:
    `yarn nx affected --target=build`
  - If the plan names a more specific build command, run that command instead and state why it covers the final diff.
  - Append the command and PASS/FAIL result to `${output_dir}/test.md` under `### Final build validation`.
  - Append the build outcome and any fixes made after the first build attempt to `${output_dir}/handoff.md`.
  - If the build fails, fix the failure and rerun the build. Do **not** announce Stage Complete while the build is failing.
  - If the build cannot run because of environment or terminal constraints, stop before End State and ask the human whether to run it locally, provide a different command, or explicitly waive the build gate.
- **If terminal tools are disabled:** mark any terminal-dependent task (lint, test runs, type-check, git commands) as `[SKIPPED — terminal unavailable]` in plan.md. Add a `## Blocked` section in handoff.md listing each skipped task. Continue executing all non-terminal tasks, but the final build gate still blocks End State unless the human explicitly waives it.

## handoff.md entry format (append after each task)
```md
## Task: <task name> — <timestamp or task number>
### Success
- <what was done, what worked>
### Friction
- <what was hard, errors hit, surprises> (or "none")
### State Summary
- Done: <cumulative list>
- In progress: <current>
- Blocked: <if any, else "none">
- Next: <next task from plan.md>
```

## test.md entry format (append after each task)
```md
### <task name>
<PASS|FAIL> — <1 key line of output or observation>
Log: ${output_dir}/logs/<name>.log  (if saved)
```
If no test was run: `N/A — no test artifact for this task`

> **Optional:** Run a quality check before Gate D: `use the branch-review skill` — a two-axis review (Standards + Spec) of the full diff. Gate D (`run review`) remains the required review gate; this is an optional pre-flight.

## End State
When all tasks are `[x]`:
1. Confirm `${output_dir}/test.md` contains a passing `### Final build validation` entry for the final diff, or a human-approved waiver recorded in `${output_dir}/handoff.md`.
2. Update `workflow/.active-workflow.md`:
   ```md
   # Active Workflow
   ticket: ${ticket}
   ticket_url: https://your-domain.atlassian.net/browse/${ticket}
   output_dir: ${output_dir}
   last_completed_stage: implement
   next_stage: review
   available_next_commands: "run review"
   updated_by: workflow-implement
   ```
3. Announce **"Stage Complete: Implementation"**
4. Produce the exact next command:

```
@Reviewer
#read .github/prompts/workflow-review.prompt.md
run review
```
5. STOP and wait for human to invoke the Reviewer.
