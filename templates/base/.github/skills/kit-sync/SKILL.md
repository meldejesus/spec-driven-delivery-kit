---
name: kit-sync
description: >
  Sync workflow file changes between the installed workspace (.github/) and the
  spec-driven-delivery-kit source (spec-driven-delivery-kit/templates/base/.github/).
  The kit is the source of truth. Run this skill whenever a workflow file is
  changed in either location to keep them in mirror.
---

# Kit Sync

Use this skill when you have edited a workflow file (prompt, agent, or skill)
and need to propagate the change to the other location, or to audit whether the
two locations have drifted.

## Mirrored paths

The following directories must stay identical between the two roots:

| Workspace (installed) | Kit (source of truth) |
|---|---|
| `.github/prompts/` | `spec-driven-delivery-kit/templates/base/.github/prompts/` |
| `.github/agents/` | `spec-driven-delivery-kit/templates/base/.github/agents/` |
| `.github/skills/` | `spec-driven-delivery-kit/templates/base/.github/skills/` |
| `.github/how-to/` | `spec-driven-delivery-kit/templates/base/.github/how-to/` |
| `.github/copilot-instructions.md` | `spec-driven-delivery-kit/templates/base/.github/copilot-instructions.md` |

> ⚠️ Do **not** sync `workflow/`, `AGENTS.md` at workspace root, or any
> ticket/artifact files — those are workspace-local and must not be overwritten.

## Workflow

### Audit (diff only — no writes)

1. For each mirrored file pair, run:
   ```
   diff <workspace-file> <kit-file>
   ```
2. Report a table of files that differ, with a one-line summary of the delta.
3. Stop. Do not apply changes without explicit human approval.

### Sync kit → workspace (propagate a kit change to the installed copy)

1. Run the audit above to identify drifted files.
2. For each drifted file, show the diff and ask for confirmation before copying.
3. Copy the kit version over the workspace version:
   ```
   cp <kit-file> <workspace-file>
   ```
4. Confirm each file was updated.
5. Remind the human to commit both repositories.

### Sync workspace → kit (promote a local edit back to source of truth)

1. Run the audit above to identify drifted files.
2. For each drifted file, show the diff and ask for confirmation before promoting.
3. Copy the workspace version over the kit version:
   ```
   cp <workspace-file> <kit-file>
   ```
4. Confirm each file was updated.
5. Remind the human to commit both repositories separately with matching messages.

## Rules

- Always diff before copying. Never blindly overwrite.
- Never sync `workflow/`, live ticket artifacts, credentials, or workspace-local
  config into the kit templates.
- After syncing, run the kit install dry-run to confirm the template is still valid:
  ```
  bash spec-driven-delivery-kit/install/install-to-workspace.sh \
    --target /private/tmp/spec-kit-install-check --dry-run
  ```
- If the dry-run fails, revert the kit change and report the error.
