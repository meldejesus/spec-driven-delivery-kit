---
name: workflow-educate
description: Generate a junior-dev mentoring walkthrough for a completed implementation or spike. Explains code flow, trade-offs, hard decisions, plan deviations, or research findings with file/source references.
agent: Educator
tools: [read, search]
---

# Education Invocation

> Standard ticket flow should normally use `.github/prompts/workflow-closeout.prompt.md`, which runs this education step before promotion. Use this prompt directly for standalone education or spike education.

## Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir} # optional - defaults from active workflow or workflow/tickets/${ticket}
- context: ${input:context}       # optional - file path(s) to additional context (comma-separated or single path)

## 0. Resolve Inputs
Before loading context, resolve `ticket` and `output_dir`:

1. If either value was omitted, read `workflow/tickets/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values.
2. If `ticket` is a full Jira URL, extract the `PROJECT-123` ID.
3. If `output_dir` is still missing, use `workflow/tickets/${ticket}` for standard implementation tickets. For spike education, the caller should pass `output_dir=workflow/spikes/${ticket}`.
4. If `context` was provided, read each listed file before education.
5. Treat any additional inline instructions in the invocation, such as "run educate but also consider x.md", as developer-provided context. If a file path is mentioned, read it before education.
6. If `ticket` is still missing after active-state lookup, ask the user for it before proceeding.

## Context to Load
If `${output_dir}/scope.md` exists, treat this as spike education:

1. `#read ${output_dir}/scope.md` — approved research question and boundaries
2. `#read ${output_dir}/findings.md` — investigation audit trail
3. `#read ${output_dir}/spike-output.md` — final research output
4. `#read ${output_dir}/explained.md` — readable summary

Then produce a walkthrough of the question, investigation path, evidence, decision points, and recommended next action. Do not require implementation-only files for spike education.

Otherwise, treat this as standard implementation education:

1. `#read ${output_dir}/prompt.md` — original contract (ACs, intent)
2. `#read ${output_dir}/plan.md` — what was planned
3. `#read ${output_dir}/handoff.md` — what actually happened, friction, pivots
4. `#read ${output_dir}/test.md` — evidence of what was validated
5. `#read ${output_dir}/pull-request.md` — summary of what shipped

If `${output_dir}/pre-context.md` exists, read it too.

For implementation education: explore the changed files referenced in `handoff.md` and `pull-request.md`. Read the relevant functions and lines directly from the workspace.

For spike education: consult source files referenced in `findings.md` or `spike-output.md` only when needed to explain the evidence. Do not invent changed-code sections if no code changed.

## Instructions

Using the Educator agent rules in `.github/agents/educator.agent.md`, produce a concise understanding guide. Its job is to help the developer understand the completed work after review, not to restate the contract or scope.

Required structure:

1. **The basic problem** — one short paragraph.
2. **What changed, broad to minor** — numbered sections ordered by dependency: source-of-truth/broadest code first, then hydration/adapters, then mappers, then consumers, then analytics/minor dependencies.
3. **Key questions answered** — answer likely developer questions inline. Do not leave open questions in the artifact.
4. **Final mental model** — 2-4 bullets summarizing how to think about the change next time.

For each implementation changed-code section:
- Name the touched runtime file(s).
- Explain what changed and why in simple language.
- Mention important compatibility behavior and future cleanup boundaries.
- Skip tests, mocks, and type-only changes unless they are necessary to understand the runtime behavior.

For spike sections:
- Name the consulted source, system, route, table, or document.
- Explain what evidence it provided and how it changed the recommendation.
- Separate confirmed facts from assumptions or remaining gaps.
- End with the practical decision or next-ticket shape the spike supports.

## Output Rules
- Reference implementation code points as: `path/to/file.ts:LINE — functionName()`
- Reference spike evidence with the source path, link, query, or document section available in the spike artifacts.
- Include short snippets only when code is the clearest explanation.
- Keep total output under ~800 words. Prefer the simple breakdown over a narrative essay.
- `overview.md` is human-facing. Use plain, scan-friendly language with short sections and practical explanations.
- Do not apply this style to contract-oriented artifacts. `prompt.md`, `plan.md`, `test.md`, and `handoff.md` should keep their formal workflow structure and traceability.
- Do NOT invent code or evidence — all snippets must come from the actual workspace files or spike artifacts

## ⚠️ File Write (mandatory — do this before announcing completion)

The walkthrough MUST be written to disk at:
```
${output_dir}/overview.md
```

Procedure:
1. Call `read_file` on `${output_dir}/overview.md` to check if it exists.
2. If it does **not** exist → call `create_file` with:
   - `filePath`: `${output_dir}/overview.md`
   - `content`: the complete walkthrough markdown
3. If it **already exists** → call `replace_string_in_file` to replace the full body.

> Outputting the walkthrough in chat only, without writing the file, is an **incomplete execution**.

## End State
1. Confirm the file was written (tool call result visible).
2. Output the walkthrough in chat so it’s immediately readable.
3. Announce **"Stage Complete: Education"**
4. STOP.
