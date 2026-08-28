#!/usr/bin/env bash
set -euo pipefail

apply=0

for arg in "$@"; do
  case "$arg" in
    --apply)
      apply=1
      ;;
    --dry-run)
      apply=0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
workspace_root=$(cd "$script_dir/../../../.." && pwd)

if [ "$apply" -eq 0 ]; then
  printf 'Dry run. Re-run with --apply to apply changes.\n\n'
fi

# Detect git repo
use_git=0
if git -C "$workspace_root" rev-parse --git-dir > /dev/null 2>&1; then
  use_git=1
fi

move() {
  local src="$1"
  local dest="$2"
  printf 'move %s -> %s\n' "${src#$workspace_root/}" "${dest#$workspace_root/}"
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$(dirname "$dest")"
    if [ "$use_git" -eq 1 ]; then
      git -C "$workspace_root" mv "$src" "$dest"
    else
      mv "$src" "$dest"
    fi
  fi
}

remove_dir() {
  local dir="$1"
  printf 'remove %s/\n' "${dir#$workspace_root/}"
  if [ "$apply" -eq 1 ]; then
    if [ "$use_git" -eq 1 ]; then
      git -C "$workspace_root" rm -rf "$dir" 2>/dev/null || rm -rf "$dir"
    else
      rm -rf "$dir"
    fi
  fi
}

# --- Step 1: Flatten workflow/tickets/ ---
tickets_dir="$workspace_root/workflow/tickets"
if [ -d "$tickets_dir" ]; then
  printf '\n## Flatten workflow/tickets/\n'
  for d in "$tickets_dir"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    dest="$workspace_root/workflow/$name"
    if [ -e "$dest" ]; then
      printf 'CONFLICT: workflow/%s already exists — skipping %s\n' "$name" "$name" >&2
      continue
    fi
    move "$d" "$dest"
  done
fi

# --- Step 2: Merge workflow/spikes/ into ticket folders ---
spikes_dir="$workspace_root/workflow/spikes"
if [ -d "$spikes_dir" ]; then
  printf '\n## Merge workflow/spikes/ into ticket folders\n'
  for d in "$spikes_dir"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    dest="$workspace_root/workflow/$name/spike"
    if [ -e "$dest" ]; then
      printf 'CONFLICT: workflow/%s/spike already exists — skipping %s\n' "$name" "$name" >&2
      continue
    fi
    move "$d" "$dest"
  done
fi

# --- Step 3: Move workflow/refinement/* into workflow/misc/ ---
refinement_dir="$workspace_root/workflow/refinement"
if [ -d "$refinement_dir" ]; then
  printf '\n## Move workflow/refinement/ into workflow/misc/\n'
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$workspace_root/workflow/misc"
  fi
  for f in "$refinement_dir"/*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    dest="$workspace_root/workflow/misc/$name"
    if [ -e "$dest" ]; then
      printf 'CONFLICT: workflow/misc/%s already exists — stopping. Resolve manually.\n' "$name" >&2
      exit 1
    fi
    move "$f" "$dest"
  done
fi

# --- Step 4: Move workflow/code-review/* into workflow/misc/ ---
codereview_dir="$workspace_root/workflow/code-review"
if [ -d "$codereview_dir" ]; then
  printf '\n## Move workflow/code-review/ into workflow/misc/\n'
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$workspace_root/workflow/misc"
  fi
  for f in "$codereview_dir"/*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    dest="$workspace_root/workflow/misc/$name"
    if [ -e "$dest" ]; then
      printf 'CONFLICT: workflow/misc/%s already exists — stopping. Resolve manually.\n' "$name" >&2
      exit 1
    fi
    move "$f" "$dest"
  done
fi

# --- Step 5: Remove old empty directories ---
printf '\n## Remove old directories\n'
for dir in "$tickets_dir" "$spikes_dir" "$refinement_dir" "$codereview_dir"; do
  [ -d "$dir" ] || continue
  if [ -z "$(ls -A "$dir")" ] || [ "$apply" -eq 1 ]; then
    remove_dir "$dir"
  fi
done

printf '\nDone.\n'
if [ "$apply" -eq 0 ]; then
  printf 'Re-run with --apply to apply.\n'
else
  printf 'Migration complete. Run the archive skill to capture the new layout.\n'
fi
