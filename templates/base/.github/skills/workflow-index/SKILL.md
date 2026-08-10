---
name: workflow-index
description: Update and inspect the cross-lane workflow inventory for tickets, spikes, and refinement artifacts. Use when Codex needs to refresh workflow/index.md, find where recent workflow work lives, summarize the active workflow inventory, or reconcile workflow/tickets, workflow/spikes, and workflow/refinement entries.
---

# Workflow Index

Use this skill to keep `workflow/index.md` synchronized with workflow artifacts.

## Procedure

1. Run the deterministic updater from the workspace root:

```bash
python3 workflow/scripts/update-index.py
```

2. Review the resulting `workflow/index.md` for obvious parse issues:
   - missing issue/topic names
   - empty summaries
   - wrong lane classification
   - unexpected missing artifacts

3. If parsing is wrong, fix the source artifact when possible:
   - ticket and spike directories should prefer an `index.md` with `## Search Metadata`
   - refinement files should have a clear heading and, when practical, a `Summary:` line

4. Do not hand-maintain generated table rows unless the script cannot infer the needed value. Prefer improving `workflow/scripts/update-index.py` or the source artifact metadata.

5. Report the number of entries updated and call out any artifacts that need cleaner metadata.
