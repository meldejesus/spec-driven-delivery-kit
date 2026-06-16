---
name: spike-investigate
description: Run a spike investigation using the approved scope.md. Produces findings.md, spike-output.md, and explained.md.
agent: Spike-Investigator
tools: [read, search, write, terminal, github, "atlassian/atlassian-mcp-server/*"]
infer: false
target: vscode
---

# Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir}

# 1. Load scope
Read `${output_dir}/scope.md` before doing anything else.
Confirm you understand:
- The question being answered
- What is in and out of scope
- The sources to consult

If `scope.md` does not exist, stop and tell the user: "No scope.md found — run spike-contract.prompt.md first."

# 2. Investigate
Work through the sources listed in scope.md in order. For each source:
- Read the file, run the query, or fetch the page
- Log what you found to `${output_dir}/findings.md` immediately

Use all available tools:
- `read` / `search` for code and local files
- `terminal` for git log, grep, bash queries
- `atlassian/atlassian-mcp-server/*` for Jira and Confluence
- `github` for PR history, blame, related issues

When you encounter a gap (something you can't determine from available sources), log it explicitly. Do not guess.

# 3. Write findings.md
Structure:
```
## [Source name or path]
**Consulted:** [what you read/ran]
**Finding:** [2–4 sentences on what it showed]
**Gap:** [what this source couldn't answer, if anything]
```
Add a new entry after each significant source. This file is the audit trail.

# 4. Write spike-output.md
When investigation is complete, write `${output_dir}/spike-output.md`:

## Executive Summary
2–3 sentences answering the scoped question in plain language. Assume a non-technical reader.

## Technical Findings
Structured detail. Use headers per finding area. Include file:line references and short snippets where they're the clearest explanation.

## Confidence Level
**High / Medium / Low** — explain why. Call out if the answer depends on assumptions.

## Gaps & Assumptions
What remains unknown. What assumptions were made to reach the conclusion.

## Suggested Follow-up Tickets
Optional. Only include if the investigation surfaced clear next actions that weren't in scope. Format:
- `[Story/Bug/Spike]: <title>` — one sentence on why it's needed

# 5. Write explained.md
Also write `${output_dir}/explained.md` as the human-readable front door for the spike.

Purpose:
- Make the answer easy to read before someone opens the denser `spike-output.md`.
- Start with known quantities and practical orientation, not source-by-source research detail.
- Explain what the spike found in plain language without losing the implementation-critical details.

Required shape:

## What This Ticket Is
Start with the basic goal in 1–2 short paragraphs.

## Where This Would Live
Name the target page, route, endpoint, admin surface, or user entry point. If there are multiple targets, list them separately and say why.

## How The Workflow Works
Explain the expected user/system flow in simple steps.

## What Data Changes
Name the key tables, fields, records, APIs, or data stores that would receive changes. Be precise about "same table but different records" when relevant.

## Safety And Validation
Summarize dry-run behavior, row-level errors, permissions, change tracking, cache/index/purge work, and other operational guardrails.

## Open Product Or Engineering Decisions
List only decisions that still need a human call before implementation.

## Bottom Line
End with the recommended shape in 2–4 sentences.

Writing rules:
- Keep it shorter and more readable than `spike-output.md`.
- Prefer plain-language headings and bullets over deep technical nesting.
- Do not include every source consulted; that belongs in `findings.md` and `spike-output.md`.
- Include exact page routes/endpoints and table/field names when known.
- If a prior spike contains a transferable lesson, include it only when it changes the recommendation or risk framing.

# 6. Stage Completion
After writing all three files:
- Announce **"Stage Complete: Investigation"**
- Provide the exact next CLI invocation:

```
Read .github/agents/reviewer.agent.md and .github/prompts/spike-review.prompt.md

ticket=PROJECT-123
output_dir=workflow/spikes/PROJECT-123
```
STOP. Wait for human to review `explained.md` and `spike-output.md` before proceeding.
