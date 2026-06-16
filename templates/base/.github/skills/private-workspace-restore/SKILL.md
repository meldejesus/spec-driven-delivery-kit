---
name: private-workspace-restore
description: Restore private Osmosis workspace files from workflow-archive-private into a fresh or reinstalled workspace after cloning the kit. Use when Codex needs to repopulate root lessons, workflow messages, worklog, active workflow pointers, optional pointing history, optional ticket archives, or optional local rebuild notes.
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
   - `workflow/messages/`
   - `workflow/tickets/.active-workflow.md`
5. Apply the default restore:

```bash
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --apply
```

6. Use optional flags only when the user asks:

```bash
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-tickets
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-pointing
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-spikes
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-code-review
.github/skills/private-workspace-restore/scripts/restore-private-workspace.sh --include-workflow-history
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
- Restore pointing assessments only with `--include-pointing` or
  `--include-workflow-history`.
- Restore full spike, code-review, lesson, and map histories only with their
  explicit flags or `--include-workflow-history`.
