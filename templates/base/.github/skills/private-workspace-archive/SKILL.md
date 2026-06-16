---
name: private-workspace-archive
description: Archive private Osmosis workspace files into workflow-archive-private before a machine wipe, workspace cleanup, fresh kit reinstall, or whenever Codex needs to preserve local private workflow state outside the active workspace. Use for exporting root lessons, workflow messages, workflow pointing assessments, worklog, and active workflow tickets into the private archive.
---

# Private Workspace Archive

Use this skill to sync private workspace state into `workflow-archive-private`.
Do not use it to archive cloned application repos, generated folders, secrets,
dependency caches, or the public `spec-driven-delivery-kit`.

## Workflow

1. Confirm the current directory is the workspace root containing
   `workflow-archive-private`.
2. Read `workflow-archive-private/README.md` for the current archive layout and
   restore map.
3. Run the archive script in dry-run mode:

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh
```

4. Review the listed copy operations. The default set is:
   - `.github/lessons-learned.md`
   - `worklog/`
   - `workflow/messages/`
   - `workflow/pointing/`
   - `workflow/tickets/`
   - `workflow/spikes/`
   - `workflow/code-review/`
   - `workflow/lessons/`
   - `workflow/maps/`
   - `workflow/cleanup-log.md`
5. If the operations match the request, apply them:

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

6. If the script refuses a worklog overwrite, restore from
   `workflow-archive-private` first. Use `--force` only when the user explicitly
   confirms that replacing a richer archived worklog with the current workspace
   worklog is intentional.
7. Check `git -C workflow-archive-private status --short` and report the
   archived paths.

## Rules

- Copy into existing archive structure; do not recreate an `other-stuff` repo or
  add duplicate snapshot folders.
- Keep private root files in root-relative archive paths.
- Keep reference-only material under `workflow-archive-private/other/`.
- Keep workflow tickets under `workflow-archive-private/workflow/tickets/`.
- Keep pointing assessments under `workflow-archive-private/workflow/pointing/`.
- Keep spike outputs under `workflow-archive-private/workflow/spikes/`.
- Keep PR review outputs under `workflow-archive-private/workflow/code-review/`.
- Keep worklog files under `workflow-archive-private/worklog/`.
- Never archive `.env`, tokens, key files, dependency folders, build output, or
  cloned app repos.
