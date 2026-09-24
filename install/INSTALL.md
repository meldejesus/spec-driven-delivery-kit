# Install & Migration Guide

Self-contained instructions for installing this kit into a workspace, updating an existing install, and migrating to a different computer. A fresh agent should be able to read this file and execute it end-to-end.

Install mode is **copy** — every workspace gets its own copy of the kit files. Kit source updates do not propagate automatically; when the kit changes, re-run the installer with `--force` to update the workspace.

---

## Concepts (read once, then skip)

**Kit source vs installed workspace.** The kit source is this repository (`spec-driven-delivery-kit/`). An installed workspace is any directory where you actually run tickets. AI tools (Claude Code, Copilot, etc.) discover kit files by walking up the directory tree from wherever you invoke them — they find `AGENTS.md`, `.github/`, `.copilot/` at the workspace root.

**Per-repo overrides.** If a specific repo under the workspace needs a different `AGENTS.md` or `CLAUDE.md` than the shared defaults, drop a local file inside that repo. AI tools pick the closest one first. `CLAUDE.md` is always per-project — it holds project-specific `Tests:`, `Build:`, `Dev server:` commands.

---

## Fresh install

Use when there is no existing workspace yet.

### 1. Pick a workspace root

The workspace root is the parent folder that contains every repo/directory you'll run tickets against. Example:

```
/Users/you/Desktop/work/
  apps-project-a/
  apps-project-b/
  essays/
```

Single install at `/work/` covers every child directory.

### 2. Dry-run

```bash
cd /path/to/spec-driven-delivery-kit
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all --dry-run
```

Read the output. Confirm the paths look right.

### 3. Run for real

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all
```

`--all` includes optional extensions (worklog, cleanup, codex helpers). Omit it for core-only.

### 4. Verify

```bash
ls -la /path/to/workspace/
```

You should see `AGENTS.md`, `TAGS.md`, `.github/`, `.copilot/`, `workflow/` — plus `worklog/` and `scripts/` if you passed `--all`.

### 5. First ticket

Open a session from the workspace root or any child directory:

```
run contract ticket=PROJECT-123
```

Artifacts land at `<workspace>/workflow/PROJECT-123/`. To place them inside a specific repo instead, pass `output_dir` explicitly:

```
run contract ticket=PROJECT-123 output_dir=/path/to/workspace/apps-project-a/workflow/PROJECT-123
```

---

## Update an existing install after kit changes

The workspace has its own copies of the kit files, so kit source updates do not appear automatically. To pull them in:

```bash
cd /path/to/spec-driven-delivery-kit
git pull                                     # if the kit source is behind
./install/install-to-workspace.sh \
  --target /path/to/workspace --mode copy --all --force
```

`--force` replaces `AGENTS.md`, `TAGS.md`, `.github/`, `.copilot/`, `worklog/`, `scripts/` from the kit source. It does **not** wipe `workflow/` ticket data — the installer preserves existing ticket directories inside `workflow/` and only overwrites `workflow/TAGS.md` (which is kit-managed).

> **Before running `--force`,** back up any hand-edited files inside `.github/`, `.copilot/`, or `AGENTS.md` at the workspace root — those will be overwritten. Per-repo overrides (files living *inside* a specific repo under the workspace) are not touched.

---

## Migrate to a different computer

You have a working install on computer A. You want the same setup on computer B (a fresh machine, or an existing one that needs an update).

### 1. Sync the kit source

The kit source is a git repo. On the new computer:

```bash
cd /wherever/you/keep/kits
git clone <your-kit-repo-url> spec-driven-delivery-kit
# or if it already exists:
cd spec-driven-delivery-kit && git pull
```

### 2. Back up existing ticket work on the target computer

```bash
cp -R /path/to/workspace/workflow /path/to/workspace/workflow.backup-$(date +%Y%m%d)
```

The installer preserves `workflow/` when it already exists, but a backup is cheap insurance.

### 3. Install on the target computer

Fresh workspace:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all
```

Or, updating an existing install to match the latest kit source:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all --force
```

### 4. If the target computer had per-repo overlays

Per-repo overrides (a local `AGENTS.md`, `CLAUDE.md`, or extra files *inside* individual repos) live inside those repos and were never touched by the installer — they will still be there after migration.

If you keep a separate `spec-driven-delivery-overlay/` directory (as the kit's public-readiness notes suggest), copy that from the source machine and re-apply its files to the workspace as needed.

### 5. Verify

Run a read-only command against an existing ticket (e.g., `run review`) to confirm agents load, prompts resolve, and workflow paths point where you expect.

---

## Common troubleshooting

- **`Refusing to install into a child of the kit repo`** — the target path is inside `spec-driven-delivery-kit/`. Move the target elsewhere. Kit source and workspace must be separate directories.
- **Kit updates aren't visible in the workspace** — this is expected in copy mode. Re-run the installer with `--force` to pull the latest kit files.
- **`AGENTS.md` conflicts between shared workspace and a specific repo** — the closest file wins. Put the per-repo override *inside* the repo, not at the workspace root.

---

## Files this doc governs

If you change the installer or install layout, update this file in the same PR:

- `install/install-to-workspace.sh`
- `install/INSTALL.md` (this file)
- `README.md` (kit root — should point here for detailed install docs)
