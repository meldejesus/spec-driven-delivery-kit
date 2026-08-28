# index.md Template

Use this format when creating `index.md` for a ticket, spike, or misc item.

```md
---
ticket: <PROJECT-ID>
title: <Ticket title>
type: standard-ticket
status: contract-drafting
created: <YYYY-MM-DD>
jira_url: <resolved Jira URL>
pr_url: ""
tags:
  - area/<product-area>
  - type/<bug|feature|refactor|chore>
  - component/<ComponentOrServiceName>
description: <2-3 sentence plain-language description of the problem and intended outcome. Write this as you would explain it to a teammate in Slack — no jargon, no ticket-speak.>
aliases:
  - <common search term 1>
  - <common search term 2>
  - <feature or component name as a developer would say it>
  - <user-facing terminology for the problem>
  - <synonym or abbreviation>
paths:
  - <repo path 1>
  - <repo path 2>
links:
  - <jira_url>
  - <any PR, Confluence, or design link>
related:
  - "[[RELATED-TICKET-ID]]"
related_to: ""
---

# <PROJECT-ID>: <Ticket title>

## Artifacts
- `prompt.md` — Strategic Contract
- `reproduce.md` — QA reproduction guide
- `plan.md` — task checklist (written after Gate A approval)
- `codebase-scan.md` — planning research notes (written after Gate A approval)
- `handoff.md` — implementation journal
- `test.md` — acceptance evidence log
- `pull-request.md` — PR description
- `overview.md` — closeout walkthrough
- `lessons-learned.md` — promotion candidates

## Notes
<!-- Anything that improves findability but does not belong in the immutable contract -->
```
