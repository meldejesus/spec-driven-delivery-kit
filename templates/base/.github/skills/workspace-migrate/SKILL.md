---
name: workspace-migrate
description: Migrate a workspace from the old nested workflow layout (workflow/tickets/, workflow/spikes/, workflow/refinement/, workflow/code-review/) to the new flat layout (workflow/OSMS-XXXX/, workflow/misc/, workflow/future-tickets/).
---

# Workspace Migration

Use this skill to migrate an existing workspace to the flat workflow structure.

## When to Use

Run this when the workspace still has any of these old directories:
- `workflow/tickets/`
- `workflow/spikes/`
- `workflow/refinement/`
- `workflow/code-review/`

## Workflow

1. Confirm the current directory is the workspace root.
2. Run the migration script in dry-run mode and review the output:

```bash
.github/skills/workspace-migrate/scripts/migrate-workspace.sh
```

3. Review the listed operations. Confirm nothing looks wrong.
4. Apply:

```bash
.github/skills/workspace-migrate/scripts/migrate-workspace.sh --apply
```

5. Re-archive to capture the new layout:

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

6. Commit and push `workflow-archive-private`.

## Rules

- Always dry-run first.
- Do not delete old directories until all moves succeed.
- If a filename conflict exists between `refinement/` and `code-review/`, the script will report it and stop — resolve manually before re-running.
- The workspace does not need to be a git repo. The script uses `mv` by default and `git mv` when inside a git repo.
