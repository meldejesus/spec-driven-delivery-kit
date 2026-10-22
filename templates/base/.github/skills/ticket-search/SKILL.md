---
name: ticket-search
description: Search across all ticket index.md files in workflow/ and workflow-archive-private/workflow/ for tickets related to a topic or keyword. Returns ranked matches with ticket ID, title, and context. Not a literal string match — the agent reads each candidate and judges relevance.
---

# When to run

When you need to find a past ticket by topic, feature area, or technology — e.g.,
"find tickets related to adobe analytics", "what tickets touched the auth flow",
"any spike on linked_terms download".

Invocation: `use the ticket-search skill to find tickets about <topic>`

# Search paths

Search both locations from the workspace root:

- `workflow/` — active and recent tickets
- `workflow-archive-private/workflow/` — archived tickets (sibling directory, may not exist)

Within each, search:
- `<ticket-id>/index.md` — standard tickets
- `<ticket-id>/spike/index.md` — spike tickets (if present)
- `workflow/misc/*.md` — refinement and non-ticket items

If `workflow-archive-private/` does not exist at the workspace root, skip it and
note that no archive was found.

# Process

## Step 1 — Keyword sweep

Run a grep across all index.md files in both locations to find initial candidates:

```bash
grep -ril "<query terms>" workflow/ 2>/dev/null
grep -ril "<query terms>" ../workflow-archive-private/workflow/ 2>/dev/null
```

Use `-i` (case-insensitive) and `-l` (filenames only). Split multi-word queries
into individual terms and run each. Collect the union of matching files.

## Step 2 — Expand candidates

For any ticket directory where grep matched, also collect neighboring index.md
files — tickets created around the same time or sharing a tag often cover related
work. Read up to 5 additional candidates beyond the direct grep matches.

## Step 3 — Read and judge

Read each candidate index.md in full. For each one, assess:
- Does this ticket genuinely relate to the query topic?
- What is the specific connection (same feature, same technology, dependency, follow-up)?
- How strong is the match (direct / related / tangential)?

Do not include tangential matches unless the result set would otherwise be empty.

## Step 4 — Return results

Present results grouped by match strength, most relevant first:

```
## Tickets matching "<query>"

### Direct matches
- PROJECT-123 — "Implement linked_terms download endpoint" (workflow/PROJECT-123/)
  Adobe Analytics event fired on download; see prompt.md constraints section.

- PROJECT-089 — "Adobe Analytics migration to v3 SDK" [archived]
  Full SDK migration; handoff.md has notes on event naming conventions.

### Related
- PROJECT-145 — "Add download tracking to asset library" (workflow/PROJECT-145/)
  Uses same analytics pattern; no direct Adobe Analytics reference but same event bus.
```

Include:
- Ticket ID and title
- Location (`workflow/` or `[archived]`)
- One sentence on the specific connection to the query
- Path to the ticket folder

If no matches found: say so plainly and suggest alternate search terms.

# Notes

- This skill reads files — it does not modify anything.
- If `index.md` is missing from a ticket folder, check for `prompt.md` as a fallback
  (it contains the AC summary and ticket title in its frontmatter).
- For very large archives (50+ tickets), prioritize the grep matches over the
  expanded candidate set to keep context lean.
