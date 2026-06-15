# Workflow Workspace

This directory stores live workflow artifacts after the kit is installed into a
workspace.

Typical ticket output:

```text
workflow/tickets/TICKET-123/
  index.md
  prompt.md
  reproduce.md
  codebase-scan.md
  plan.md
  handoff.md
  test.md
  pull-request.md
  overview.md
  lessons-learned.md
```

Each ticket directory starts with `index.md`, a searchable front door containing
ticket metadata, summary, search terms, related paths, related links, and the
artifact map.

`workflow/tickets/.active-workflow.md` is generated during a workflow run.
