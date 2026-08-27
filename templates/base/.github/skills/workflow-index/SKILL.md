---
name: workflow-index
description: Regenerate the static table in workflow/index.md from all index.md files in the workflow directory. Use when the static fallback table is stale or when the user asks to refresh the workflow index.
---

# Workflow Index

Keeps `workflow/index.md` synchronized with the actual workflow artifacts on disk.

**Obsidian users:** the Dataview queries in `workflow/index.md` stay current automatically — you don't need this skill unless you want to refresh the static fallback table.

**Non-Obsidian users:** run this skill to regenerate the static table.

## Procedure

1. Find all `index.md` files under `workflow/`:

```bash
find workflow -name "index.md" ! -path "workflow/index.md"
```

2. For each `index.md`, read the YAML frontmatter and extract:
   - `ticket`
   - `title`
   - `type`
   - `status`
   - `tags` (join as comma-separated)
   - `created`

3. Sort entries by `created` descending.

4. Rewrite the **Static Index** table in `workflow/index.md` (the section under `## Static Index`). Do not modify anything above that section — the Dataview queries must stay intact.

5. Report how many entries were written and flag any `index.md` files with missing or empty frontmatter fields.

## Source artifact quality

If an `index.md` is missing frontmatter (uses the old `## Search Metadata` format), flag it — it needs to be updated to YAML frontmatter for Obsidian compatibility. See `workflow/TAGS.md` for the canonical tag taxonomy and field definitions.

## Rules

- Never hand-edit individual table rows. Always regenerate from source frontmatter.
- Do not remove or modify the Dataview query blocks.
- If a field is missing, use `—` in the table rather than leaving it blank.
