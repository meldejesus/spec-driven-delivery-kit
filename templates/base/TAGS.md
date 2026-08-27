# Tag Registry

Use this file to keep a small, stable tag vocabulary for workflow artifacts so
you can quickly find related tickets, spikes, and archived work.

## How To Use

1. Define canonical tags once in this file.
2. Add tags to ticket/spike entry files (`index.md`, pre-context, or top-level
   artifact when no index exists).
3. Reuse exact spellings to avoid fragmented search results.

## Suggested Starter Tags

Replace these with your domain topics:

- `#admin-tooling`
- `#content-pipeline`
- `#ai-integration`
- `#migration`
- `#runtime`

## Metadata Pattern

For files with Search Metadata:

`- tags: admin-tooling, content-pipeline, ai-integration`

Optional inline hashtags near the top of a file:

`Tags: #admin-tooling #content-pipeline #ai-integration`

## Search Commands

Active workflow:

```bash
rg -n --glob '*.md' '#admin-tooling|#content-pipeline|#ai-integration' workflow
```

Workflow + archive (if your workspace keeps an archive directory):

```bash
rg -n --glob '*.md' '#admin-tooling|#content-pipeline|#ai-integration' workflow archive/workflow
```

Candidate discovery for backfilling tags:

```bash
rg -l --glob '*.md' '(?i)admin|pipeline|integration|migration|runtime' workflow archive/workflow | sort -u
```
