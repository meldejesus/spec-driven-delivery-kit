Add a `## Project Tags` section to `workflow/TAGS.md`. Append it after the existing cross-cutting tags section. Content to add:

```markdown
## Project Tags

Project-specific tags for Learnify/Osmosis work. Use `#hashtag` style for quick `rg` searches.

| Tag | Use when |
|---|---|
| `#admin-learnify-tool` | Admin UI for adding, overriding, removing, or reviewing Learnify links |
| `#learnify` | Broad Learnify runtime/migration/linking context |
| `#learnify-links` | Learnify linked-terms data, migration, and correction workflows |
| `#ai-sandbox` | Sandbox-based JSON generation or porting that pipeline |
| `#link-management` | General link-quality/link-governance operations |

### Quick Search

```bash
rg -n --glob '*.md' '#admin-learnify-tool|#learnify|#learnify-links|#ai-sandbox' workflow/
```

### Backfill Discovery

```bash
rg -l --glob '*.md' '(?i)learnify|ai[- ]sandbox|admin.*learnify|linked_terms' workflow/ | sort -u
```
```

Delete this file when done.
