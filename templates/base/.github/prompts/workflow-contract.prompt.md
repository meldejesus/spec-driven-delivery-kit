---
name: contract
description: Fetch ticket, create a searchable ticket index, and draft a Strategic Contract and Reproduction Guide for a new task.
agent: Architect
model: claude-3-5-sonnet-20241022
tools: [agent, search, read, write, github, atlassian/atlassian-mcp-server/*]
infer: false
target: vscode
---

# Inputs
- ticket: ${input:ticket}         # short form: PROJECT-123  OR full URL: https://your-domain.atlassian.net/browse/PROJECT-123
- output_dir: ${input:output_dir} # optional — auto-derived from ticket ID if omitted
- context: ${input:context}       # optional — file path(s) to additional context (comma-separated or single path)

# Active Workflow State
This stage starts or switches the active workflow.

After resolving `ticket` and `output_dir`, update:

```text
workflow/tickets/.active-workflow.md
```

Use this format:

```md
# Active Workflow
ticket: <PROJECT-ID>
ticket_url: https://your-domain.atlassian.net/browse/<PROJECT-ID>
output_dir: <resolved output_dir>
last_completed_stage: none
next_stage: contract
updated_by: workflow-contract
```

# 0. Normalize Inputs
Before doing anything else, resolve the working values of `ticket` and `output_dir`:

1. **Ticket ID extraction** — If `ticket` is a short ID (matches `[A-Z][A-Z0-9]+-\d+`), expand it:
   - `ticket` → `https://your-domain.atlassian.net/browse/<ID>`
   - If `output_dir` was not provided, set it to `workflow/tickets/<ID>`
2. **Full URL provided** — If `ticket` is already a full URL, extract the ticket ID from the path segment and set `output_dir` to `workflow/tickets/<ID>` if not explicitly provided.
3. **Context files** — If `context` was provided, read each file path listed. Treat their contents as authoritative developer-provided context alongside `pre-context.md`. They override assumptions from the ticket alone.
4. **Inline context** — Treat any additional instructions in the invocation, such as "draft contract but also consider x.md", as authoritative developer context. If a file path is mentioned, read it before drafting.
5. Confirm the resolved values internally before proceeding. Do not ask the user to confirm — just use them.

# 1. Fetch Ticket Content
Try the following in order — use the first one that succeeds:

**Option A — Atlassian MCP (preferred):**
Use the `atlassian/atlassian-mcp-server/*` tool to fetch the Jira ticket at `${ticket}`.

**Option B — URL fetch fallback:**
If MCP is unavailable, attempt `#fetch ${ticket}` to retrieve the ticket page directly.

**Option C — Manual fallback (if both above fail):**
Do NOT stop. Instead:
1. Inform the user: "Atlassian MCP is unavailable. Please paste the ticket title, description, and acceptance criteria here and I will draft the contract from that."
2. Wait for the user to paste the content, then continue.

---

# 1.5 Initialize Ticket Directory Index
Ensure `${output_dir}` exists. Before writing `prompt.md`, `reproduce.md`, or `handoff.md`, create or update:

```text
${output_dir}/index.md
```

This is the ticket directory's searchable front door. It should make the work findable with repository search, `rg`, or AI context search even before the full contract is read.

Before writing the index, read `${output_dir}/pre-context.md` if it exists and incorporate any developer-provided paths, links, domain terms, or constraints into the metadata.

Use this structure:

```md
# <PROJECT-ID>: <Ticket title>

## Search Metadata
- ticket: <PROJECT-ID>
- ticket_url: <resolved Jira URL>
- workflow_type: standard-ticket
- output_dir: <resolved output_dir>
- status: contract-drafting
- created: <YYYY-MM-DD>
- source: Jira
- summary: <1-2 sentence plain-language description of the problem and intended outcome>
- searchable_terms:
  - <domain or product area>
  - <feature, route, component, service, or data model>
  - <important acceptance-criteria terms>
- related_paths:
  - <repo paths discovered or provided so far>
- related_links:
  - <Jira, PR, Confluence, or design links discovered or provided so far>

## Artifact Map
- `prompt.md` - Strategic Contract
- `reproduce.md` - reproduction and QA guide
- `plan.md` - implementation plan, created after Gate A approval
- `codebase-scan.md` - planning research notes, created after Gate A approval
- `handoff.md` - implementation journal
- `test.md` - acceptance evidence log
- `pull-request.md` - review and PR synthesis
- `overview.md` - closeout walkthrough
- `lessons-learned.md` - promotion candidates

## Notes
- <Any short context that improves searchability but does not belong in the immutable contract>
```

Rules:
- Do not leave placeholder metadata if the ticket content provides a better title, summary, term, path, or link.
- If `index.md` already exists, update its metadata and artifact map without deleting human-authored notes.
- Keep the summary and searchable terms concrete enough that `rg "<term>" workflow/tickets` can rediscover the ticket later.
- For change-request output directories, set `workflow_type: change-request` and include the parent ticket directory under `related_paths`.

# 2. Research & Discovery
Before drafting the contract:

0. **Read pre-context** — If `${output_dir}/pre-context.md` was not already read during index initialization, check for it now and read it in full if it exists. It contains developer-provided context (file paths, API routes, third-party integrations, known constraints) that must be incorporated into the contract and should override any assumptions made from the ticket alone.
1. **Fetch external context** — Use `search` or `agent` to review relevant code, docs, `AGENTS.md`, `.github/copilot-instructions.md`, and `.github/lessons-learned.md`.
2. **Similar-Issue Search** — Scan `.github/archive/` for past handoff logs relating to this feature or domain.
3. **Investigate prior work** — If a GitHub diff or Jira link is provided, summarize relevant findings.
4. **Identify gaps, ambiguities, or missing ACs** — Produce an Open Questions list.

STOP after discovery. Do not create plan.md yet.

---

# 3. Draft the Strategic Contract

Your goal is to distill all ambiguous requirements into a complete, immutable **Strategic Contract** before any plan or code is produced. Wait for **Human Approval (Gate A)** before any Plan-Agent work begins.

## 3.1 Summary (Context + Problem)
- **Context:** Why this work matters.
- **Problem Statement:** What is being solved.
- **In-Scope**
- **Out-of-Scope**

## 3.2 Acceptance Criteria (AC)
Create a list of **observable, testable outcomes.**
Each AC must map to later evidence in `test.md`.

## 3.3 Non-Functional Requirements (NFRs)
Include:
- Performance
- Reliability
- Observability
- Security & Privacy
- Compatibility constraints

## 3.4 Architectural Constraints & Guardrails
Document:
- Boundaries
- Interfaces
- Allowed patterns
- Forbidden patterns
- Design tradeoffs
- Tech debt considerations

## 3.5 Risks & Mitigations
List at least 3 major risks and their mitigations.

## 3.6 Evidence Strategy (for test.md)
For each AC define:
- How it will be validated
- Evidence type (CLI, screenshot, logs, metrics, traces)

## 3.7 Failure & Recovery Protocol
Include pivot logic:
- Task fails ≥3 attempts triggers Backtrack & Pivot
- Human approval required for pivot path

## 3.8 Promotion Targets
List any rules or lessons that should likely be considered during Closeout for `.github/lessons-learned.md` or `.github/copilot-instructions.md`.

## 3.9 Open Questions
List all unresolved ambiguities requiring human clarification.

## 3.10 Reproduction Document (reproduce.md)
Create a detailed, step-by-step guide for reproducing the issue.

`reproduce.md` is a human-facing QA artifact. Write it in plain, scan-friendly language that any teammate can follow without knowing the ticket history.

**Contents:**
- **Prerequisites:** Environment, setup, tools needed
- **Route/URL:** Exact path to navigate to (e.g., `/schedule`, `/dashboard`)
- **Step-by-step instructions:** What to do, what you see, what should happen
- **Summary table:** Current behavior vs. expected behavior
- **Debugging tips:** Browser console, DevTools, accessibility tools
- **Expected outcome after fix:** How to verify the fix works
- **Accessibility verification:** Screen reader + keyboard navigation steps

**Purpose:** This becomes the acceptance test reference for QA and validation — reproducible by any team member without domain knowledge.

Style boundary:
- Apply the plain, scan-friendly style only to `reproduce.md`.
- Keep `prompt.md` in the highly specific Strategic Contract style. It must preserve AC traceability, NFRs, risks, constraints, and evidence strategy.
- Do not simplify or colloquialize contract-oriented sections just because `reproduce.md` is human-facing.

---

# 4. Context Engine Initialization
After drafting the contract, initialize **handoff.md** with:
- Strategic Intent (Why)
- Relevant references (ticket links, diffs, docs)
- Identified risks and ambiguities

Set compaction rule: summarize handoff.md every 10 turns; if >50 lines, trigger Compactor.

---

# 5. Constraints
- **Altitude:** Stay strategic; do NOT produce code, file diffs, or low-level implementation details.
- **Immutable Contract:** Once approved, Contract cannot change; a new contract must be drafted for scope changes.
- **No Plan Creation:** Only Plan-Agent may generate `plan.md`. You only **approve**, revise, or reject plans.
- **Checkpoint Gate A:** STOP after initializing `index.md` and drafting `prompt.md` and `reproduce.md`. Wait for human approval before any planning.

---

# 6. Output
Write **three files**:

1. **`${output_dir}/index.md`** — The searchable ticket directory index
2. **`${output_dir}/prompt.md`** — The Strategic Contract (sections 3.1–3.10)
3. **`${output_dir}/reproduce.md`** — The Reproduction Guide (section 3.10)

`prompt.md` and `reproduce.md` are part of **Gate A** and must be reviewed by the human before proceeding to planning. `index.md` is a search/navigation aid and should be kept current if the title, summary, key terms, paths, or links become clearer during Contract.

Also update `workflow/tickets/.active-workflow.md`:

```md
# Active Workflow
ticket: <PROJECT-ID>
ticket_url: https://your-domain.atlassian.net/browse/<PROJECT-ID>
output_dir: ${output_dir}
last_completed_stage: contract
next_stage: plan
updated_by: workflow-contract
```

---

# 7. Final Prompt to Human
After writing the index and both Gate A files, ask:

> "I have initialized the ticket index and drafted the Strategic Contract and Reproduction Guide.
>
> Review these files:
> - `${output_dir}/index.md` — Searchable ticket index (title, metadata, terms, artifact map)
> - `${output_dir}/prompt.md` — Strategic Contract (ACs, NFRs, risks, etc.)
> - `${output_dir}/reproduce.md` — Reproduction Guide (step-by-step to reproduce the issue)
>
> Shall I proceed to Gate B (Plan-Agent), or do you want revisions?"

---

# 8. Stage Completion
After writing the index and both Gate A files:
- Announce: "Stage Complete: Contract (Gate A)."
- Provide the exact next command:
  ```
  @Plan-Agent
  #read .github/prompts/workflow-plan.prompt.md

  run plan
  ```

STOP. Wait for human approval.
