# Migrating to a New Kit Version

Use this when pulling a major kit update onto a machine that has an existing workspace with the old directory structure.

---

## What Changed (v1 → v2 Directory Structure)

The old kit scattered work for a single ticket across multiple top-level directories:

```
workflow/tickets/PROJECT-123/     ← ticket artifacts
workflow/spikes/PROJECT-123/      ← spike for the same ticket
workflow/refinement/PROJECT-123   ← refinement for the same ticket
```

The new kit uses one directory per ticket:

```
workflow/PROJECT-123/             ← all artifacts for this ticket
workflow/PROJECT-123/spike/       ← spike lives inside the ticket dir
workflow/PROJECT-123/refinement/  ← refinement lives inside the ticket dir
workflow/code-review/             ← peer reviews (unchanged)
```

---

## Migration Steps

### Step 1 — Archive the old workspace

Run the archive script before pulling anything. It copies your active workflow state into `workflow-archive-private/` using the old structure, so nothing is lost.

```bash
# Dry-run first — review what will be copied
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh

# Apply when it looks right
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

What gets archived: `workflow/tickets/`, `workflow/spikes/`, `workflow/refinement/`, `workflow/code-review/`, `lessons-learned.md`, `worklog/`.

### Step 2 — Pull the updated kit and reinstall

```bash
cd /path/to/spec-driven-delivery-kit
git pull origin main

./install/install-to-workspace.sh --target /path/to/workspace
```

The installer overwrites `.github/`, `AGENTS.md`, and kit config files with the new versions.

### Step 3 — Clean the old workflow directories

```bash
cd /path/to/workspace
rm -rf workflow/tickets workflow/spikes
```

`workflow/refinement/` can stay — it's still used for batch and sprint refinement outputs where no single ticket ID applies.

---

## Notes

- The archive script on the old machine understands the old structure (`workflow/tickets/`, `workflow/spikes/`) — it will archive correctly before you reinstall.
- The `workflow-archive-private/` directory is not overwritten by the installer, so your history is safe.
- After migration, new work follows the new convention: `workflow/PROJECT-123/` with subdirectories for spike and refinement.
- If you had in-flight tickets (mid-workflow, not yet merged), migrate them manually instead of archiving:

```bash
mv workflow/tickets/PROJECT-123 workflow/PROJECT-123
mv workflow/spikes/PROJECT-123 workflow/PROJECT-123/spike
mv workflow/refinement/PROJECT-123.md workflow/PROJECT-123/refinement/
```

Then update `workflow/.active-workflow.md` to point to the new `output_dir`.
