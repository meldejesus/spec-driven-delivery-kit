---
name: private-workspace-restore
description: Restore private Osmosis workspace files from workflow-archive-private into a fresh or reinstalled workspace after cloning the kit. Use when Codex needs to repopulate root lessons, worklog, active workflow pointers, optional refinement history, optional ticket archives, or optional local rebuild notes.
---

# Private Workspace Restore

Use this skill after cloning/installing the public kit and cloning
`workflow-archive-private` into the workspace root.

## Workflow

1. Confirm the current directory is the workspace root containing
   `workflow-archive-private`.
2. Read `workflow-archive-private/README.md` for the restore map.
3. Run the restore script in dry-run mode:

```bash
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh
```

4. Review the listed copy operations. The default restore set is:
   - `.github/lessons-learned.md`
   - `worklog/`
   - `workflow/.active-workflow.md`
5. Apply the default restore:

```bash
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --apply
```

6. Use optional flags only when the user asks:

```bash
# Restore full ticket history (all workflow/<ticket-id>/ directories)
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-workflow-history

# Restore only peer code reviews
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-code-review

# Restore only batch refinement assessments
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-refinement

# Restore local notes
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-local-notes
```

7. Check `git status --short` where applicable and report restored paths.

## Rules

- Restore only from `workflow-archive-private`; do not use `other-stuff`.
- Do not overwrite a fresh workspace silently. Always dry-run first unless the
  user explicitly asks for immediate apply.
- Do not restore secrets, `.env` files, dependency folders, build output, or
  cloned app repos.
- Restore full archived tickets only with `--include-tickets`; default restore
  should keep active workflow state lightweight.
- Restore refinement assessments only with `--include-refinement` or
  `--include-workflow-history`.
- Restore full spike and code-review histories only with their explicit flags
  or `--include-workflow-history`.
