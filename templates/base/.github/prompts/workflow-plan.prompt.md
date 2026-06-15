---
name: plan
description: Generate plan.md and codebase-scan.md from the approved contract.
agent: Plan-Agent
infer: false
target: vscode
tools:
  - read
  - write
  - search
  - atlassian/atlassian-mcp-server/*
---

# Inputs
- ticket: ${input:ticket}         # short form: PROJECT-123  OR full URL: https://your-domain.atlassian.net/browse/PROJECT-123
- output_dir: ${input:output_dir} # optional — auto-derived from ticket ID if omitted
- context: ${input:context}       # optional — file path(s) to additional context (comma-separated or single path)

# 0. Normalize Inputs
Before doing anything else, resolve the working values of `ticket` and `output_dir`:

0. **Active workflow fallback** — If `ticket` or `output_dir` was omitted, read `workflow/tickets/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values. If the file is missing and the input is still ambiguous, ask the user for the missing value before proceeding.
1. **Ticket ID extraction** — If `ticket` is a short ID (matches `[A-Z][A-Z0-9]+-\d+`), expand it:
   - `ticket` → `https://your-domain.atlassian.net/browse/<ID>`
   - If `output_dir` was not provided and active state did not provide one, set it to `workflow/tickets/<ID>`
2. **Full URL provided** — If `ticket` is already a full URL, extract the ticket ID from the path segment and set `output_dir` to `workflow/tickets/<ID>` if not explicitly provided.
3. **Context files** — If `context` was provided, read each file path listed. Treat their contents as authoritative developer-provided context alongside the approved contract. They override assumptions from the ticket alone.
4. **Inline context** — Treat any additional instructions in the invocation, such as "run plan but also consider x.md", as authoritative developer context. If a file path is mentioned, read it before planning.
5. Confirm the resolved values internally before proceeding. Do not ask the user to confirm — just use them.

# Context to Load
Before generating any plan, read:

```
#read ${output_dir}/prompt.md
```

If `${output_dir}/pre-context.md` exists, read it too.

Also review relevant code in the workspace, global rules in `.github/copilot-instructions.md`, agent roles in `AGENTS.md`, and prior lessons in `.github/lessons-learned.md`. Surface any lessons relevant to the ticket's domain or components as pre-flight notes at the top of `plan.md`.

Do **not** modify or reinterpret the Contract.

---

# 🏗️ Blueprint Generator (Plan-Agent)
Your mission is to transform the **approved Strategic Contract (`prompt.md`)** into a complete, atomic, testable **plan.md** and **codebase-scan.md**.

You operate at the **Tactical Layer**.
You **must not** redefine requirements, Acceptance Criteria, scope, or architecture.
You only determine **how** to fulfill the approved Contract.

---

# 1. Analyze the Contract
Extract from `prompt.md`:

1. **Acceptance Criteria (ACs)**
2. **Constraints & non-functional requirements (NFRs)**
3. **Risks & mitigations**
4. **Evidence Strategy** (how each AC must be validated)

---

# 2. Decompose Into Atomic Tasks
- Each task must take **≤ 15 minutes**.
- Each AC must map to **one or more tasks**.
- Every task must include:
  - Clear description of the work
  - Expected output (code change or evidence)
  - An orchestration tag (`@local`, `@subagent`, `@background`)
- Always include a final validation task after all implementation tasks:
  - Run the focused tests/lint required by the plan.
  - Run the affected build check for the final diff:
    `yarn nx affected --target=build`
  - Record the command and PASS/FAIL evidence in `test.md`.
  - If the repo or ticket requires a narrower build command, name that command explicitly and explain why it replaces the affected build.

---

# 3. Task Tagging (Orchestration Matrix)
Assign **exactly one** tag per task:

- `@local` → Standard coding work
- `@subagent` → Requires a specialist (SQL, Regex, CSS, security, ML)
- `@background` → Test runs, long-running checks, PR drafting, static analysis

---

# 4. Failure & Pivot Protocol
For any task with potential risk, add a *Pivot branch*:
- If task fails ≥3 attempts → mark `[FAILED]`, propose alternative path, STOP for human approval (Gate C).
- The final build-validation task is mandatory. If the build cannot run or fails, the plan must treat implementation as incomplete until there is passing build evidence or an explicit human waiver.

---

# 5. Output

## File 1: plan.md — `${output_dir}/plan.md`
Atomic task list with every AC mapped to one or more tasks, each tagged and with pivot branches where needed.
Include an **Evidence Mapping table**: Tasks → ACs → Evidence.

## File 2: codebase-scan.md — `${output_dir}/codebase-scan.md`
Produce this file whenever real file paths and code are identified during planning. Required sections:

1. **Workflow position block** — where this file sits relative to prompt.md / plan.md / handoff.md
2. **Systemic risks** — infrastructure-level issues affecting all target files (e.g., default accessibility props on containers)
3. **Per-file entries** — one entry per file targeted in plan.md, each with:
   - Full file path and plan task reference
   - Pre-edit checklist
   - Current broken code block with inline problem comments
   - Fix code block with inline explanation comments
   - Platform notes table (iOS VoiceOver vs Android TalkBack)
   - Post-edit checklist
4. **Misplaced-header log** — table tracking any semantic tag demotions discovered during planning
5. **Cross-cutting platform matrix** — one row per fix pattern, columns for iOS VoiceOver / Android TalkBack / Samsung One UI
6. **Quick verification greps** — before/after shell commands to confirm fixes and catch regressions

**Sync rule:** Any time a plan.md task is added, removed, or re-targeted to a different file, update the corresponding codebase-scan.md entry in the **same operation**. These two files are treated as a pair.

---

# 6. Stage Completion
After writing both files:
- Update `workflow/tickets/.active-workflow.md`:
  ```md
  # Active Workflow
  ticket: <PROJECT-ID>
  ticket_url: https://your-domain.atlassian.net/browse/<PROJECT-ID>
  output_dir: ${output_dir}
  last_completed_stage: plan
  next_stage: implement
  updated_by: workflow-plan
  ```
- Announce: "Stage Complete: Plan (Gate B)."
- Provide the exact next command:
  ```
  @Implementer
  #read .github/prompts/workflow-implement.prompt.md

  run implement
  ```

STOP. Wait for human to review plan.md before implementation begins.
