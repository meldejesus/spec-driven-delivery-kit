---
name: spike-contract
description: Fetch a spike ticket, create a searchable ticket index, and draft a Scope Document defining the research question, boundaries, timebox, and sources.
agent: Architect
tools: [read, search, write, github, "atlassian/atlassian-mcp-server/*"]
infer: false
target: vscode
---

# Inputs
- ticket: ${input:ticket}         # short form: PROJECT-123  OR full URL: https://your-domain.atlassian.net/browse/PROJECT-123
- output_dir: ${input:output_dir} # optional — auto-derived from ticket ID if omitted
- context: ${input:context}       # optional — file path(s) to additional context (comma-separated or single path)

# 0. Normalize Inputs
Before doing anything else, resolve the working values of `ticket` and `output_dir`:

1. **Ticket ID extraction** — If `ticket` is a short ID (matches `[A-Z][A-Z0-9]+-\d+`), expand it:
   - `ticket` → `https://your-domain.atlassian.net/browse/<ID>`
   - If `output_dir` was not provided, set it to `workflow/spikes/<ID>`
2. **Full URL provided** — If `ticket` is already a full URL, extract the ticket ID from the path segment and set `output_dir` to `workflow/spikes/<ID>` if not explicitly provided.
3. **Context files** — If `context` was provided, read each file path listed. Treat their contents as authoritative developer-provided context alongside `pre-context.md`. They override assumptions from the ticket alone.
4. Confirm the resolved values internally before proceeding. Do not ask the user to confirm — just use them.

# 1. Fetch ticket content
Try the following in order — use the first that succeeds:

**Option A — Atlassian MCP (preferred):**
Use `atlassian/atlassian-mcp-server/*` to fetch the Jira ticket at `${ticket}`.

**Option B — URL fetch fallback:**
Attempt `#fetch ${ticket}` to retrieve the ticket page directly.

**Option C — Manual fallback:**
Inform the user: "Atlassian MCP is unavailable. Please paste the ticket title, description, and acceptance criteria and I will draft the scope from that." Wait, then continue.

# 1.5 Initialize Ticket Directory Index
Ensure `${output_dir}` exists. Before writing `scope.md`, create or update:

```text
${output_dir}/index.md
```

This is the spike directory's searchable front door. It should make the research findable with repository search, `rg`, or AI context search even before the full spike output is read.

Before writing the index, read `${output_dir}/pre-context.md` if it exists and incorporate any developer-provided paths, links, domain terms, or constraints into the metadata.

Use this structure:

```md
# <PROJECT-ID>: <Ticket title>

## Search Metadata
- ticket: <PROJECT-ID>
- ticket_url: <resolved Jira URL>
- workflow_type: spike
- output_dir: <resolved output_dir>
- status: scope-drafting
- created: <YYYY-MM-DD>
- source: Jira
- summary: <1-2 sentence plain-language description of the research question and decision this spike will unblock>
- searchable_terms:
  - <domain or product area>
  - <feature, route, component, service, or data model>
  - <important research terms>
- related_paths:
  - <repo paths discovered or provided so far>
- related_links:
  - <Jira, PR, Confluence, or design links discovered or provided so far>

## Artifact Map
- `scope.md` - approved research question, boundaries, timebox, and sources
- `findings.md` - running investigation journal
- `spike-output.md` - final evidence-backed research output
- `explained.md` - readable front-door summary
- `overview.md` - optional education walkthrough

## Notes
- <Any short context that improves searchability but does not belong in the scoped research question>
```

Rules:
- Do not leave placeholder metadata if the ticket content provides a better title, summary, term, path, or link.
- If `index.md` already exists, update its metadata and artifact map without deleting human-authored notes.
- Keep the summary and searchable terms concrete enough that `rg "<term>" workflow/spikes workflow/tickets` can rediscover the spike later.

# 2. Scan for prior related spikes
Search `workflow/spikes/` first, then `workflow/tickets/` for legacy spike outputs, for any existing `scope.md` or `spike-output.md` files whose title or content overlaps with this ticket. Note any relevant prior findings in the scope document.

# 3. Draft the Scope Document
Write `${output_dir}/scope.md` with the following sections:

## Question
One sentence: what specific question is this spike trying to answer?

## Why it matters
1–2 sentences on the decision or action this spike is unblocking.

## In scope
Bullet list of sources, systems, and areas to investigate.

## Out of scope
Bullet list of what should explicitly be skipped — even if related.

## Timebox
Estimated investigation time. Default: 2–4 hours.

## What a good output looks like
Describe the shape of a satisfying answer: a recommendation, a comparison table, a confidence assessment, a list of blockers, etc.

## Sources to consult
Ordered list of where the investigator should look first:
- Relevant code paths (include file paths if known)
- Jira tickets (linked or related)
- Confluence pages
- External docs or PRs

# 4. Stage Completion
After writing `index.md` and `scope.md`:
- Announce **"Stage Complete: Scope (Gate A)"**
- Provide the exact next CLI invocation:

```
Read .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md

ticket=PROJECT-123
output_dir=workflow/spikes/PROJECT-123
```
STOP. Wait for human approval before investigation begins.
