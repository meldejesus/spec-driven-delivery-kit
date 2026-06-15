---
name: standup
description: >
  Update standup/dashboard.md and standup/daily-log.md using the optional
  standup-sync scripts.
---

# Standup Update

Use this skill for routine standup cleanup only.

## Workflow

1. Run the sync report:

```bash
./scripts/standup-sync/standup-sync.sh --report-only
```

2. Scan for ticket IDs needing labels:

```bash
python3 scripts/standup-sync/standup-enrich.py --scan
```

3. If labels are needed, fetch summaries using the workspace's configured issue
   tracker tools, then write a temporary JSON map:

```json
{ "PROJECT-123": "Short ticket summary" }
```

4. Apply labels:

```bash
python3 scripts/standup-sync/standup-enrich.py --labels /tmp/standup-labels.json
```

5. Promote untracked tickets and move completed items:

```bash
python3 scripts/standup-sync/standup-enrich.py --promote-in-progress
python3 scripts/standup-sync/standup-enrich.py --move-done
```

6. Update `Last updated` in `standup/dashboard.md`.

7. Report labels added, items moved, old Done entries pruned, and any merged
   ticket signals.
