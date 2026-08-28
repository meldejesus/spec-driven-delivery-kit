# Migrating to a New Kit Version

Use this when pulling a major kit update onto a machine that has an existing workspace with the old directory structure.

---

## What Changed (v2 → v3 Directory Structure)

The v3 kit simplifies the top-level workflow layout by eliminating all subdirectory lanes except for ticket directories and two utility directories:

**Eliminated directories:**
- `workflow/tickets/` — tickets now go flat at `workflow/<ticket-id>/`
- `workflow/spikes/` — spikes now live inside `workflow/<ticket-id>/spike/`
- `workflow/refinement/` — batch refinement output goes to `workflow/misc/`
- `workflow/code-review/` — standalone PR reviews go to `workflow/misc/<repo>-pr-<number>/`

**New structure:**
```
workflow/
├── OSMS-1234/           # full ticket work (flat, no tickets/ subdirectory)
├── OSMS-1234-2/         # follow-up on same ticket (index.md has related_to: OSMS-1234)
├── misc/                # ad-hoc, one-off, or non-ticket items
├── future-tickets/      # queued/planned future work
├── .active-workflow.md
├── TAGS.md
├── README.md
└── index.md
```

**Follow-up workflows** use a `-2`, `-3` suffix on the ticket ID. The follow-up's `index.md` uses `related_to:` in its frontmatter to link back to the original ticket.

---

## What Changed (v1 → v2 Directory Structure)

The v1 kit scattered work for a single ticket across multiple top-level directories:

```
workflow/tickets/PROJECT-123/     ← ticket artifacts
workflow/spikes/PROJECT-123/      ← spike for the same ticket
workflow/refinement/PROJECT-123   ← refinement for the same ticket
```

The v2 kit consolidated to one directory per ticket:

```
workflow/PROJECT-123/             ← all artifacts for this ticket
workflow/PROJECT-123/spike/       ← spike lives inside the ticket dir
workflow/code-review/             ← peer reviews
workflow/refinement/              ← batch/sprint refinement output
```

---

## Migration Steps (v2 → v3)

### Step 1 — Archive the current workspace

Run the archive script before pulling anything. It copies your active workflow state into `workflow-archive-private/`, so nothing is lost.

```bash
# Dry-run first — review what will be copied
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh

# Apply when it looks right
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

### Step 2 — Pull the updated kit and reinstall

```bash
cd /path/to/spec-driven-delivery-kit
git pull origin main

./install/install-to-workspace.sh --target /path/to/workspace
```

The installer overwrites `.github/`, `AGENTS.md`, and kit config files with the new versions.

### Step 3 — Migrate old code-review and refinement output

```bash
cd /path/to/workspace

# Move standalone PR reviews into misc/
mkdir -p workflow/misc
mv workflow/code-review/* workflow/misc/ 2>/dev/null || true
rmdir workflow/code-review 2>/dev/null || true

# Move batch refinement output into misc/
mv workflow/refinement/* workflow/misc/ 2>/dev/null || true
rmdir workflow/refinement 2>/dev/null || true
```

Ticket directories that are already flat at `workflow/PROJECT-123/` need no migration. Any `workflow/PROJECT-123/refinement/` subdirectory can stay in place — it is not a reserved top-level name in v3.

---

## Migration Steps (v1 → v2 Legacy)

### Step 1 — Archive the old workspace

What gets archived: `workflow/tickets/`, `workflow/spikes/`, `workflow/refinement/`, `workflow/code-review/`, `lessons-learned.md`, `worklog/`.

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

### Step 2 — Clean the old workflow directories

```bash
cd /path/to/workspace
rm -rf workflow/tickets workflow/spikes
```

### Step 3 — Migrate in-flight tickets manually

```bash
mv workflow/tickets/PROJECT-123 workflow/PROJECT-123
mv workflow/spikes/PROJECT-123 workflow/PROJECT-123/spike
```

Then update `workflow/.active-workflow.md` to point to the new `output_dir`.

---

## Notes

- The `workflow-archive-private/` directory is not overwritten by the installer, so your history is safe.
- After migration to v3, new work follows the convention: `workflow/PROJECT-123/` for tickets, `workflow/misc/` for non-ticket artifacts, `workflow/future-tickets/` for queued work.
- The archive script archives everything under `workflow/` flat — the v3 structure is already flat, so no special handling is needed.
