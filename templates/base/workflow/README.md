# Workflow Workspace

This directory stores live workflow artifacts after the kit is installed into a
workspace. Keep different workflow types in different subdirectories so search,
restore, and cleanup stay predictable.

## Structure

```text
workflow/
├── tickets/       # Implementation ticket delivery: contract, plan, implement, review, closeout
├── pointing/      # Backlog ticket assessment, estimation prep, and proto-contract notes
├── spikes/        # Time-boxed research: scope, findings, output, review, optional overview
├── code-review/   # Reviews of someone else's PRs: triage, testing guide, findings, verdict
├── messages/      # Durable message-writing workflow outputs
├── lessons/       # Promotion audits and other lesson-maintenance artifacts
├── maps/          # Durable product/codebase workflow maps
└── cleanup-log.md # Workspace organization history when worth preserving
```

## Implementation Tickets

Typical implementation ticket output:

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

## Pointing / Ticket Assessment

Pointing outputs belong under:

```text
workflow/pointing/
  TICKET-123.md
  ticket-assessment-YYYY-MM-DD.md
  tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  spikes-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  tech-debt-tickets.md
  workflow-scan-registry.md
```

Use this lane for early ticket review before the work is assigned or approved:
read the Jira issue, compare it against docs and likely code paths, summarize
the issue in skimmable language, estimate rough complexity, and recommend the
next workflow. It is a proto-contract, not the full Strategic Contract.

When a ticket is selected for implementation, start the standard contract flow
under `workflow/tickets/<ticket-id>/`. When the right next step is research,
start the spike flow under `workflow/spikes/<ticket-id>/`.

## Spikes

Spike outputs belong under:

```text
workflow/spikes/TICKET-123/
  index.md
  scope.md
  findings.md
  spike-output.md
  explained.md
  overview.md
```

Use this lane for research that answers a question before deciding whether to
build something. Do not mix spike outputs into implementation ticket folders
unless the spike is part of an already-running implementation ticket.

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
Reviewing your own implementation ticket before opening a PR still belongs in
that ticket's `workflow/tickets/TICKET-123/` folder.

## Messages

Durable message-writing outputs belong under:

```text
workflow/messages/<message-name>/
  approach.md
  outline.md
  draft.md
  review.md
  final.md
  lessons-learned.md
```

Use this lane only when a rewritten message should survive beyond the chat
session. Quick message rewrites can stay conversation-only.
