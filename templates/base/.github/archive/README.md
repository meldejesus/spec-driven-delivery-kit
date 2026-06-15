# `.github/archive/`

This folder stores completed ticket summaries that agents use as a **prior-friction library** — scanning here before starting new work helps avoid repeating known mistakes.

---

## Naming Convention

```
PROJECT-123-summary.md
```

One file per ticket. Use the Jira ticket number as the prefix.

---

## File Format

Each archive file should contain:

```markdown
# PROJECT-123 — <Short Title>

## What Changed
Brief description of what was implemented.

## Frictions
- <Thing that slowed us down or caused a wrong turn>
- <Edge case that bit us>

## Key Decisions
- <Why we chose X over Y>

## Reusable Patterns
- <Pattern or snippet future work can copy>
```

---

## How Agents Use This

- **@Architect** scans for similar past frictions before drafting a contract.
- **@Reviewer** checks if a flagged pattern was already resolved in a prior ticket.
- **@Plan-Agent** avoids re-discovering known pitfalls during codebase scan.

Populate this folder at the end of each ticket's Promotion step.
