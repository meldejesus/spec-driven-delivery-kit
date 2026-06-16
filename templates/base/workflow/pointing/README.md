# Ticket Assessment / Pointing Prep

This directory stores lightweight ticket assessments before a ticket becomes an
active implementation or spike workflow.

Use this lane when reviewing backlog or unassigned Jira tickets for grooming,
estimation, scope discovery, or prioritization. The output should be easy to
skim and specific enough to support a planning conversation without becoming a
full implementation plan.

## Output Shape

```text
workflow/pointing/
  TICKET-123.md
  ticket-assessment-YYYY-MM-DD.md
  <sprint-or-batch>.md
  tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  spikes-<workflow>-<sub-workflow>-YYYY-MM-DD.md
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

Pointing output is a proto-contract. It can recommend one of these next steps:

- Run the standard ticket workflow under `workflow/tickets/<ticket-id>/`.
- Run the spike workflow under `workflow/spikes/<ticket-id>/`.
- Keep the ticket in backlog pending clarification.
- Split, merge, or defer the ticket.

Do not mutate a pointing report into a Strategic Contract. If the ticket is
selected for delivery, create a fresh contract in `workflow/tickets/<ticket-id>/`
so the gated ticket workflow starts cleanly.
