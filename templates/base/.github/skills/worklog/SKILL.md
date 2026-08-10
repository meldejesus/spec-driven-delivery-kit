---
name: worklog
description: >
  Update worklog/dashboard.md and worklog/daily-log.md using the optional
  worklog scripts.
---

# Worklog Update

Use this skill for routine worklog cleanup only.

## Workflow

1. Run the sync report:

```bash
./worklog/scripts/worklog-sync.sh --report-only
```

2. Scan for ticket IDs needing labels:

```bash
python3 worklog/scripts/worklog-enrich.py --scan
```

3. If labels are needed, fetch summaries using the workspace's configured issue
   tracker tools, then write a temporary JSON map:

```json
{ "PROJECT-123": "Short ticket summary" }
```

4. Apply labels:

```bash
python3 worklog/scripts/worklog-enrich.py --labels /tmp/worklog-labels.json
```

5. Promote untracked tickets and move completed items:

```bash
python3 worklog/scripts/worklog-enrich.py --promote-in-progress
python3 worklog/scripts/worklog-enrich.py --move-done
```

6. Update `Last updated` in `worklog/dashboard.md`.

7. Report labels added, items moved, old Done entries pruned, and any merged
   ticket signals.
