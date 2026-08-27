# Ticket Refinement

This directory stores batch and sprint refinement assessments that span multiple
tickets. Single-ticket refinement now lives inside the ticket's own directory at
`workflow/<ticket-id>/refinement/`.

## When to use this directory

Use `workflow/refinement/` when running in batch or sprint mode — reviewing
multiple tickets in one run for grooming, estimation, scope discovery, or
prioritization.

For a single ticket being refined, prefer `workflow/<ticket-id>/refinement/`
so all work related to that ticket stays in one place.

## Output Shape

```text
workflow/refinement/
  ticket-assessment-YYYY-MM-DD.md
  <sprint-slug>.md
  tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  spikes-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  tech-debt-tickets.md
  workflow-scan-registry.md
```

Each assessment should answer:

- What issue is the ticket really about?
- What docs or codebase signals support that reading?
- What likely needs to be done?
- How could it be done, specifically but without implementation detail?
- What files, systems, or teams are likely involved?
- What is the rough estimate, confidence, and readiness?
- What questions or dependencies remain?
- What is the recommended next workflow?

## Boundary

Refinement output is a proto-contract. It can recommend one of these next steps:

- Run the standard ticket workflow under `workflow/<ticket-id>/`.
- Run the spike workflow under `workflow/<ticket-id>/spike/`.
- Keep the ticket in backlog pending clarification.
- Split, merge, or defer the ticket.

Do not mutate a refinement report into a Strategic Contract. If the ticket is
selected for delivery, create a fresh contract in `workflow/<ticket-id>/`
so the gated ticket workflow starts cleanly.
