#!/usr/bin/env bash
set -euo pipefail

apply=0
force=0

for arg in "$@"; do
  case "$arg" in
    --apply)
      apply=1
      ;;
    --dry-run)
      apply=0
      ;;
    --force)
      force=1
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

copy_file() {
  local source_rel=$1
  local dest_rel=$2
  local source="$workspace_root/$source_rel"
  local dest="$archive_root/$dest_rel"

  if [ ! -f "$source" ]; then
    printf 'skip missing file: %s\n' "$source_rel"
    return
  fi

  printf 'file %s -> workflow-archive-private/%s\n' "$source_rel" "$dest_rel"
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$(dirname "$dest")"
    cp -p "$source" "$dest"
  fi
}

is_template_worklog_file() {
  local source=$1
  case "$source" in
    */worklog/dashboard.md)
      grep -q 'Example upcoming ticket\|Last updated: YYYY-MM-DD' "$source"
      ;;
    */worklog/daily-log.md)
      grep -q 'Auto-updated by git hooks. Newest first.' "$source"
      ;;
    *)
      return 1
      ;;
  esac
}

copy_dir() {
  local source_rel=$1
  local dest_rel=$2
  local source="$workspace_root/$source_rel"
  local dest="$archive_root/$dest_rel"

  if [ ! -d "$source" ]; then
    printf 'skip missing dir: %s\n' "$source_rel"
    return
  fi

  if [ "$dest_rel" = "worklog" ] && [ "$force" -eq 0 ] && [ -d "$dest" ]; then
    for file in dashboard.md daily-log.md; do
      if [ -f "$source/$file" ] && [ -f "$dest/$file" ] && is_template_worklog_file "$source/$file" && ! cmp -s "$source/$file" "$dest/$file"; then
        printf 'refuse template overwrite: %s/%s -> workflow-archive-private/%s/%s\n' "$source_rel" "$file" "$dest_rel" "$file" >&2
        printf 'Restore from workflow-archive-private first, or re-run with --force if this overwrite is intentional.\n' >&2
        exit 1
      fi
    done
  fi

  printf 'dir  %s/ -> workflow-archive-private/%s/\n' "$source_rel" "$dest_rel"
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$dest"
    rsync -a "$source/" "$dest/"
  fi
}

if [ "$apply" -eq 0 ]; then
  printf 'Dry run. Re-run with --apply to copy files.\n'
fi

copy_file ".github/lessons-learned.md" ".github/lessons-learned.md"
copy_dir "worklog" "worklog"
copy_dir "workflow/messages" "workflow/messages"
copy_dir "workflow/pointing" "workflow/pointing"
copy_dir "workflow/tickets" "workflow/tickets"
copy_dir "workflow/spikes" "workflow/spikes"
copy_dir "workflow/code-review" "workflow/code-review"
copy_dir "workflow/lessons" "workflow/lessons"
copy_dir "workflow/maps" "workflow/maps"
copy_file "workflow/cleanup-log.md" "workflow/cleanup-log.md"

printf 'Done.\n'
