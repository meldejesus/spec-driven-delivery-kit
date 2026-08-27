can# Tag Registry

Canonical tags for finding Learnify admin-tool work across active workflow and archive artifacts.

## Canonical Tags

| Tag | Use when | Typical scope |
|---|---|---|
| `#admin-learnify-tool` | Admin UI/tooling work for adding, overriding, removing, or reviewing Learnify links | Tickets, pre-context, handoff, review |
| `#learnify` | Broad Learnify runtime/migration/linking context | Spikes, overviews, architecture docs |
| `#learnify-links` | Learnify linked-terms data, migration, and correction workflows | Tickets, spikes, refinements |
| `#ai-sandbox` | Work tied to sandbox-based JSON generation or porting that pipeline | Spikes, generator tickets |
| `#link-management` | General link-quality/link-governance operations | Optional cross-topic grouping |

## Where To Add Tags

1. Ticket/spike `index.md` (or top-level file when no index exists).
2. Pre-context, prompt, and handoff files when they are the main entry point.
3. Archived workflow artifacts under `archive/workflow/**`.

Use this exact metadata line in files that already have Search Metadata:

`- tags: learnify-links, learnify-tools, admin-learnify-tool, ai-sandbox`

And add hashtag search tokens near the top:

`Tags: #admin-learnify-tool #learnify #learnify-links #ai-sandbox`

## Quick Search (Active + Archive)

```bash
rg -n --glob '*.md' '#admin-learnify-tool|#learnify|#learnify-links|#ai-sandbox' workflow archive/workflow
```

## One-Pass Candidate Discovery (Backfill Input)

```bash
rg -n --glob '*.md' '(?i)learnify|learnify-links|ai[- ]sandbox|admin.*learnify|linked_terms|ai_generated_linked_terms' workflow archive/workflow
```

## One-Pass Backfill Candidate File List

```bash
rg -l --glob '*.md' '(?i)learnify|learnify-links|ai[- ]sandbox|admin.*learnify|linked_terms|ai_generated_linked_terms' workflow archive/workflow | sort -u
```

## Seed References Already Tagged

| Area | Path |
|---|---|
| Active ticket | `workflow/tickets/OSMS-18283/index.md` |
| Active admin tool summary | `workflow/tickets/OSMS-18283/admin-learnify-links-tool.md` |
| Active pre-context | `workflow/tickets/OSMS-18204-3/pre-context.md` |
| Active refinement | `workflow/refinement/learnify-runtime-override-overlay.md` |
| Archive spike index | `archive/workflow/spikes/OSMS-18204/0-index.md` |
