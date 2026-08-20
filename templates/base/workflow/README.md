# Workflow Workspace

This directory stores live workflow artifacts after the kit is installed into a
workspace. Each ticket gets a single directory so all related artifacts — contract,
plan, implementation, spike research, and refinement — stay together.

## Structure

```text
workflow/
├── PROJECT-123/       # All artifacts for ticket PROJECT-123
│   ├── spike/         # Spike research lives inside the ticket dir (if applicable)
│   └── refinement/    # Single-ticket refinement lives inside the ticket dir (if applicable)
├── refinement/        # Batch/sprint refinement that spans multiple tickets
├── code-review/       # Reviews of someone else's PRs (not always ticket-tied)
├── .active-workflow.md  # Active workflow pointer
└── cleanup-log.md     # Workspace organization history when worth preserving
```

## Implementation Tickets

Typical implementation ticket output:

```text
workflow/TICKET-123/
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

`workflow/.active-workflow.md` is generated during a workflow run.

## Spike (Research) Tickets

Spike artifacts live inside the ticket directory under a `spike/` subdirectory:

```text
workflow/TICKET-123/spike/
  index.md
  scope.md
  findings.md
  spike-output.md
  explained.md
  overview.md
```

Use this lane for research that answers a question before deciding whether to
build something. Keeping spikes inside the ticket directory preserves the full
story in one place.

> **Note:** A legacy `workflow/spikes/` top-level directory may exist in older
> workspaces. That layout is deprecated. New spike work goes in
> `workflow/<ticket-id>/spike/`.

## Ticket Refinement

### Single-ticket refinement

When refining a specific ticket, output belongs in the ticket's own directory:

```text
workflow/TICKET-123/refinement/
  TICKET-123.md
```

### Batch or sprint refinement

When refining multiple tickets in one run (batch or sprint mode), the output
belongs in the shared refinement directory:

```text
workflow/refinement/
  ticket-assessment-YYYY-MM-DD.md
  <sprint-slug>.md
  tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  tech-debt-tickets.md
  workflow-scan-registry.md
```

Use this lane for early ticket review before the work is assigned or approved:
read the Jira issue, compare it against docs and likely code paths, summarize
the issue in skimmable language, estimate rough complexity, and recommend the
next workflow. It is a proto-contract, not the full Strategic Contract.

When a ticket is selected for implementation, start the standard contract flow
under `workflow/<ticket-id>/`. When the right next step is research, start the
spike flow under `workflow/<ticket-id>/spike/`.

## Code Reviews

Reviews of someone else's PRs belong under:

```text
workflow/code-review/<repo-or-ticket>-pr-123/
  index.md
  triage.md
  review.md
  verdict.md
  testing-notes.md
```

Use this lane for PR review artifacts that need to survive the conversation.
Code review lives here because it is not always tied to a specific ticket.
Reviewing your own implementation ticket before opening a PR still belongs in
that ticket's `workflow/TICKET-123/` folder.
