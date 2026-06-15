---
name: workflow-promote
description: Standalone promotion step. Identify and propose project-wide rules learned from a completed task. Prefer workflow-closeout in the standard ticket flow.
agent: Architect
---

# Promotion Invocation

> Standard ticket flow should normally use `.github/prompts/workflow-closeout.prompt.md`, which writes `overview.md` first and then runs this promotion analysis. Use this prompt directly only for standalone promotion work.

# Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir} # optional - defaults to workflow/tickets/${ticket}
- context: ${input:context}       # optional - file path(s) to additional context (comma-separated or single path)

# 0. Resolve Paths
Before loading context, resolve `ticket` and `output_dir`:

1. If either value was omitted, read `workflow/tickets/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values.
2. If `ticket` is a full Jira URL, extract the `PROJECT-123` ID.
3. If `output_dir` is still missing, use `workflow/tickets/${ticket}`.
4. If `context` was provided, read each listed file before promotion.
5. Treat any additional inline instructions in the invocation as developer-provided context. If a file path is mentioned, read it before promotion.
6. If `ticket` is still missing after active-state lookup, ask the user for it before proceeding.

# Load context
#read ${output_dir}/handoff.md
#read ${output_dir}/pull-request.md
#read .github/copilot-instructions.md
#read .github/lessons-learned.md

If `${output_dir}/pre-context.md` exists, read it too.

# Instructions
Analyze the task's handoff log and PR summary to extract **generalizable lessons** that apply across the entire codebase.

Only propose updates that fit ALL of these criteria:
- They apply to **all contributors**, not just one workflow
- They improve coding, documentation, security, reliability, or consistency
- They do NOT reference plan.md, prompt.md, handoff.md, or task-scoped mechanics
- They do NOT encode multi-phase workflow logic

# Deliverables
1. **Promotion Candidates**: a bullet list of potential additions to `.github/lessons-learned.md`.
2. **Minimal Proposed Patch**: markdown diff with suggested edits
3. **Rationale**: Why each change benefits the entire project
4. Write the candidates and proposed patch to `${output_dir}/lessons-learned.md`.
5. Announce **"Stage Complete: Promotion"**
6. STOP and wait for human approval before applying any changes to global files.

# End State
After human approves the promotion diff:
1. Apply global file edits only if the current runtime has explicit permission to edit `.github/lessons-learned.md` or `.github/copilot-instructions.md`.
2. If global edits are not permitted, leave the approved patch in `${output_dir}/lessons-learned.md` and tell the human it is ready for a write-enabled agent.
3. If `${output_dir}/overview.md` does not exist, tell the human to run `workflow-closeout` or `workflow-educate` before pushing.
4. STOP.
