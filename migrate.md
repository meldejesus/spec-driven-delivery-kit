# Migrate Workspace to Flat Workflow Structure

Use these steps to migrate an existing workspace from the old nested layout
(`workflow/tickets/`, `workflow/spikes/`, `workflow/refinement/`, `workflow/code-review/`)
to the new flat layout (`workflow/OSMS-XXXX/`, `workflow/misc/`, `workflow/future-tickets/`).

---

## Step 1 — Archive first (safety net)

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

Commit and push in `workflow-archive-private` before touching anything.

---

## Step 2 — Pull the latest kit and reinstall

```bash
cd ~/path/to/spec-driven-delivery-kit && git pull
bash install/install-to-workspace.sh --target /path/to/workspace --force
```

This drops in the new `workflow/misc/`, `workflow/future-tickets/`, and updated `TAGS.md`.

---

## Step 3 — Flatten tickets

> If the workspace is a git repo, use `git mv`. Otherwise use `mv`.

```bash
cd /path/to/workspace
for d in workflow/tickets/*/; do
  git mv "$d" "workflow/$(basename $d)"
done
```

---

## Step 4 — Merge spikes into ticket folders

Skip this step if `workflow/spikes/` does not exist.

```bash
for d in workflow/spikes/*/; do
  ticket=$(basename "$d")
  mkdir -p "workflow/$ticket/spike"
  git mv "$d" "workflow/$ticket/spike"
done
```

---

## Step 5 — Move refinement and code-review into misc

Check for filename conflicts first:

```bash
ls workflow/refinement/ workflow/code-review/
```

Then move:

```bash
for f in workflow/refinement/*; do git mv "$f" "workflow/misc/$(basename $f)"; done
for f in workflow/code-review/*; do git mv "$f" "workflow/misc/$(basename $f)"; done
```

---

## Step 6 — Remove empty old directories

```bash
git rm -r workflow/tickets workflow/spikes workflow/refinement workflow/code-review 2>/dev/null
```

Or if not a git repo:

```bash
rm -rf workflow/tickets workflow/spikes workflow/refinement workflow/code-review
```

---

## Step 7 — Commit

```bash
git add -A && git commit -m "refactor: migrate workflow to flat structure"
```

---

## Step 8 — Re-archive to capture the new layout

```bash
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh
.github/skills/private-workspace-archive/scripts/archive-private-workspace.sh --apply
```

Commit and push in `workflow-archive-private`.

---

## New Structure Reference

```
workflow/
├── OSMS-XXXX/              # all ticket work (impl, spike, code review with ticket)
│   └── spike/              # spike artifacts if applicable
├── misc/                   # non-ticket items — tagged #code-review, #refinement, etc.
├── future-tickets/         # planned or queued work
├── .active-workflow.md
├── TAGS.md
├── README.md
└── index.md
```

Delete this file when migration is complete.
