#!/usr/bin/env bash
set -euo pipefail

# Cross-reference ticket IDs in worklog/dashboard.md against git history.
#
# Optional environment:
#   WORKLOG_REPO_PATH=/path/to/source/repo
#   WORKLOG_TICKET_PATTERN='[A-Z][A-Z0-9]+-[0-9]+'
#   WORKLOG_GIT_AUTHOR_PATTERN='your.name|your.email'

script_dir="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
dashboard="$root/worklog/dashboard.md"
daily_log="$root/worklog/daily-log.md"
repo="${WORKLOG_REPO_PATH:-$root}"
ticket_pattern="${WORKLOG_TICKET_PATTERN:-[A-Z][A-Z0-9]+-[0-9]+}"
author_pattern="${WORKLOG_GIT_AUTHOR_PATTERN:-}"
enrich="$script_dir/worklog-enrich.py"
report_only=0

if [ "${1:-}" = "--report-only" ]; then
  report_only=1
elif [ -n "${1:-}" ]; then
  echo "Usage: ./worklog/scripts/worklog-sync.sh [--report-only]" >&2
  exit 2
fi

if [ ! -f "$dashboard" ]; then
  echo "worklog dashboard not found at $dashboard" >&2
  exit 1
fi

if [ ! -f "$daily_log" ]; then
  echo "worklog daily log not found at $daily_log" >&2
  exit 1
fi

if [ ! -d "$repo/.git" ]; then
  echo "source repo not found at $repo" >&2
  exit 1
fi

since=$(grep -m1 "Last updated:" "$dashboard" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || date -v-30d +%Y-%m-%d)
echo "Checking commits since: $since"

if git -C "$repo" rev-parse --verify origin/main >/dev/null 2>&1; then
  ref="origin/main"
else
  ref="HEAD"
fi

echo
echo "Merged ticket signals:"
echo

in_scope=0
found_any=0

while IFS= read -r line; do
  if echo "$line" | grep -q "^### To Do$\|^### In Progress$\|^### Code Review / Waiting$\|^### Testing$"; then
    in_scope=1
  elif echo "$line" | grep -q "^#"; then
    in_scope=0
  fi

  if [ "$in_scope" -eq 1 ]; then
    tickets=$(echo "$line" | grep -oE "$ticket_pattern" || true)
    for ticket in $tickets; do
      match=$(git -C "$repo" --no-pager log "$ref" --oneline --since="$since" | grep -iE "(^|[[:space:]]|\\[)${ticket}(\\]|[[:space:]]|$)" | head -1 || true)
      if [ -n "$match" ]; then
        echo "  MERGED: $ticket - $match"
        found_any=1
      fi
    done
  fi
done < "$dashboard"

if [ "$found_any" -eq 0 ]; then
  echo "  No merged tickets found in active dashboard sections."
fi

echo
echo "Recent commits:"
echo

if [ -n "$author_pattern" ]; then
  git -C "$repo" --no-pager log --all --oneline --regexp-ignore-case --extended-regexp --author="$author_pattern" --since="7 days ago" --format="  %as  [%D] %s" | head -20
else
  git -C "$repo" --no-pager log --all --oneline --since="7 days ago" --format="  %as  [%D] %s" | head -20
fi

echo
echo "Tickets in daily log needing labels:"
echo
python3 "$enrich" --scan 2>/dev/null || true

if [ "$report_only" -eq 0 ]; then
  echo
  python3 "$enrich" --move-done 2>/dev/null || true
  python3 "$enrich" --promote-in-progress 2>/dev/null || true
fi
