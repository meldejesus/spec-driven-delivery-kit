---
name: ticket-refinement
description: Refine a backlog ticket through a structured dialogue — fetch the Jira ticket, find relevant code, confirm understanding with the developer, then write a concise plain-English refinement document.
agent: pointing-analyst
tools:
   - read
   - edit
   - search
   - atlassian/atlassian-mcp-server/*
---

# Inputs
- mode: ${input:mode}                   # tickets | sprint | tech-debt
- tickets: ${input:tickets}             # comma/newline-separated Jira keys for mode=tickets
- sprint: ${input:sprint}               # e.g., Apollo 2.0 (2026), required for mode=sprint
- xx: ${input:xx}                       # optional batch count override, 0..15 preferred
- max_results: ${input:max_results}     # default 15, hard cap 20
- output_dir: ${input:output_dir}       # default workflow/refinement (batch/sprint) or workflow/<ticket>/refinement (single ticket)
- project_key: ${input:project_key}     # optional
- unpointed_jql_clause: ${input:unpointed_jql_clause} # optional JQL fragment override
- source_file: ${input:source_file}     # mode=tech-debt only

# Defaults and bounds
- If output_dir is empty and mode=tickets with a single ticket key, default to `workflow/<ticket>/refinement`.
- If output_dir is empty and mode=sprint or mode=tickets with multiple tickets, default to `workflow/refinement`.
- If max_results is empty, default to 15.
- Normalize xx/max_results to integer.
- Enforce bounds: hard stop 0..20, operational execution cap 0..15.

# Required behavior
1. Validate mode:
   - `tickets`: requires tickets list.
   - `sprint`: requires sprint name.
   - `tech-debt`: requires source_file or inline ticket drafts.
2. For tickets/sprint modes, fetch Jira data with Atlassian MCP only
   (read-only). For tech-debt mode, read the local source file or inline drafts.
3. Find the relevant code:
   - search for ticket terms, feature names, routes, components, and domain docs.
   - cite actual file paths — not guesses.
4. **Complete the Dialogue Phase before writing anything.**
   - Present your plain-English understanding of the ticket and the code you found.
   - Ask 1-2 clarifying questions. Wait for the developer to respond.
   - Confirm the understanding is correct before producing the output document.
   - If the developer corrects you, revise and re-confirm.
5. Support resume behavior for sprint mode:
   - Find existing sprint markdown in output_dir.
   - Extract last successfully analyzed ticket key.
   - Continue from subsequent unpointed tickets only.
6. Produce one markdown report named from sprint, single ticket, or batch fallback.
7. Include run metadata and summary counts:
   - fetched, analyzed, skipped, failed.
8. Preserve partial success when some ticket fetches fail.
9. Use this estimate rubric in every ticket section:
   - `1` = mostly UI or simple fix
   - `2` = requires some logic and/or has moderate unknowns
   - `3` = larger task with more unknowns or broader complexity
10. Recommend the next workflow for each ticket:
   - standard ticket workflow: `workflow/<ticket-id>/`
   - spike workflow: `workflow/<ticket-id>/spike/`
   - backlog clarification, split/merge, or defer.

# Output
Write report using deterministic file naming:
- Sprint mode: `${input:output_dir}/<slugified-sprint>.md`
- Single-ticket mode: `${input:output_dir}/<JIRA-KEY>.md`
- Multi-ticket mode fallback: `${input:output_dir}/ticket-refinement-YYYY-MM-DD.md`

The agent must report the resolved final output path in its response.

After writing:
- Return the output path.
- Return one-line run summary with counts.
