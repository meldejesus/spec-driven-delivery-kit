---
name: pointing-plan
description: Analyze Jira backlog tickets for estimation readiness and write a sprint markdown report.
agent: pointing-analyst
tools:
   - read
   - edit
   - atlassian/atlassian-mcp-server/*
---

# Inputs
- mode: ${input:mode}                   # tickets | sprint
- tickets: ${input:tickets}             # comma/newline-separated Jira keys for mode=tickets
- sprint: ${input:sprint}               # e.g., Apollo 2.0 (2026), required for mode=sprint
- xx: ${input:xx}                       # optional batch count override, 0..15 preferred
- max_results: ${input:max_results}     # default 15, hard cap 20
- output_dir: ${input:output_dir}       # default pointing
- project_key: ${input:project_key}     # optional
- unpointed_jql_clause: ${input:unpointed_jql_clause} # optional JQL fragment override

# Defaults and bounds
- If output_dir is empty, default to `pointing`.
- If max_results is empty, default to 15.
- Normalize xx/max_results to integer.
- Enforce bounds: hard stop 0..20, operational execution cap 0..15.

# Required behavior
1. Validate mode:
   - `tickets`: requires tickets list.
   - `sprint`: requires sprint name.
2. Fetch Jira data with Atlassian MCP only (read-only).
3. Support resume behavior for sprint mode:
   - Find existing sprint markdown in output_dir.
   - Extract last successfully analyzed ticket key.
   - Continue from subsequent unpointed tickets only.
4. Produce one markdown report named from sprint (or batch label fallback).
5. Include run metadata and summary counts:
   - fetched, analyzed, skipped, failed.
6. Preserve partial success when some ticket fetches fail.
7. Use this estimate rubric in every ticket section:
   - `1` = mostly UI or simple fix
   - `2` = requires some logic and/or has moderate unknowns
   - `3` = larger task with more unknowns or broader complexity
8. Include a likely touch-surface section for each ticket:
   - approximate file count and/or
   - likely directories/files in the codebase that would need changes.

# Output
Write report using deterministic file naming:
- Sprint mode: `${input:output_dir}/<slugified-sprint>.md`
- Tickets mode fallback: `${input:output_dir}/pointing-batch-YYYY-MM-DD.md`

The agent must report the resolved final output path in its response.

After writing:
- Return the output path.
- Return one-line run summary with counts.
