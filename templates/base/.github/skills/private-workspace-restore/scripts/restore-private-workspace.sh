#!/usr/bin/env bash
set -euo pipefail

apply=0
include_workflow_history=0
include_code_review=0
include_refinement=0
include_local_notes=0

for arg in "$@"; do
  case "$arg" in
    --apply)
      apply=1
      ;;
    --dry-run)
      apply=0
      ;;
    --include-workflow-history)
      include_workflow_history=1
      include_code_review=1
      include_refinement=1
      ;;
    --include-code-review)
      include_code_review=1
      ;;
    --include-refinement)
      include_refinement=1
      ;;
    --include-local-notes)
      include_local_notes=1
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
workspace_root=$(cd "$script_dir/../../../.." && pwd)
archive_root="$workspace_root/workflow-archive-private"

if [ ! -d "$archive_root" ]; then
  printf 'Missing workflow-archive-private at %s\n' "$archive_root" >&2
  exit 1
fi

restore_file() {
  local source_rel=$1
  local dest_rel=$2
  local source="$archive_root/$source_rel"
  local dest="$workspace_root/$dest_rel"

  if [ ! -f "$source" ]; then
    printf 'skip missing file: workflow-archive-private/%s\n' "$source_rel"
    return
  fi

  printf 'file workflow-archive-private/%s -> %s\n' "$source_rel" "$dest_rel"
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$(dirname "$dest")"
    cp -p "$source" "$dest"
  fi
}

restore_dir() {
  local source_rel=$1
  local dest_rel=$2
  local source="$archive_root/$source_rel"
  local dest="$workspace_root/$dest_rel"

  if [ ! -d "$source" ]; then
    printf 'skip missing dir: workflow-archive-private/%s\n' "$source_rel"
    return
  fi

  printf 'dir  workflow-archive-private/%s/ -> %s/\n' "$source_rel" "$dest_rel"
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$dest"
    rsync -a "$source/" "$dest/"
  fi
}

if [ "$apply" -eq 0 ]; then
  printf 'Dry run. Re-run with --apply to restore files.\n'
fi

# Default restore — always included
restore_file ".github/lessons-learned.md" ".github/lessons-learned.md"
restore_dir "worklog" "worklog"
restore_file "workflow/.active-workflow.md" "workflow/.active-workflow.md"

# Full ticket history — all tickets live flat under workflow/
if [ "$include_workflow_history" -eq 1 ]; then
  restore_dir "workflow" "workflow"
  restore_file "workflow/cleanup-log.md" "workflow/cleanup-log.md"
fi

# Code reviews (peer reviews of teammates' PRs)
if [ "$include_code_review" -eq 1 ]; then
  restore_dir "workflow/code-review" "workflow/code-review"
fi

# Batch refinement assessments
if [ "$include_refinement" -eq 1 ]; then
  restore_dir "workflow/refinement" "workflow/refinement"
fi

if [ "$include_local_notes" -eq 1 ]; then
  restore_dir "other/local-notes" "workspace-local"
fi

printf 'Done.\n'
