---
name: pointing-plan
description: Review backlog or unassigned Jira tickets against docs/codebase and write skim-friendly ticket assessments with readiness notes and rough estimates.
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
- output_dir: ${input:output_dir}       # default workflow/pointing
- project_key: ${input:project_key}     # optional
- unpointed_jql_clause: ${input:unpointed_jql_clause} # optional JQL fragment override
- source_file: ${input:source_file}     # mode=tech-debt only

# Defaults and bounds
- If output_dir is empty, default to `workflow/pointing`.
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
3. Compare each ticket against available docs and likely code paths:
   - search for ticket terms, feature names, routes, components, and domain docs.
   - cite the strongest docs/codebase signals in the ticket section.
   - keep implementation detail concrete enough to estimate, but do not write a full plan.
4. Support resume behavior for sprint mode:
   - Find existing sprint markdown in output_dir.
   - Extract last successfully analyzed ticket key.
   - Continue from subsequent unpointed tickets only.
5. Produce one markdown report named from sprint, single ticket, or batch fallback.
6. Include run metadata and summary counts:
   - fetched, analyzed, skipped, failed.
7. Preserve partial success when some ticket fetches fail.
8. Use this estimate rubric in every ticket section:
   - `1` = mostly UI or simple fix
   - `2` = requires some logic and/or has moderate unknowns
   - `3` = larger task with more unknowns or broader complexity
9. Include a likely touch-surface section for each ticket:
   - approximate file count and/or
   - likely directories/files in the codebase that would need changes.
10. Recommend the next workflow for each ticket:
   - standard ticket workflow: `workflow/tickets/<ticket-id>/`
   - spike workflow: `workflow/spikes/<ticket-id>/`
   - backlog clarification, split/merge, or defer.

# Output
Write report using deterministic file naming:
- Sprint mode: `${input:output_dir}/<slugified-sprint>.md`
- Single-ticket mode: `${input:output_dir}/<JIRA-KEY>.md`
- Multi-ticket mode fallback: `${input:output_dir}/ticket-assessment-YYYY-MM-DD.md`

The agent must report the resolved final output path in its response.

After writing:
- Return the output path.
- Return one-line run summary with counts.
