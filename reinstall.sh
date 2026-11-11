#!/usr/bin/env bash
# Quick reinstall: updates an existing workspace from current kit source.
# Usage: ./reinstall.sh /path/to/workspace [--dry-run]
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Usage: ./reinstall.sh /path/to/workspace [--dry-run]"
  echo ""
  echo "Updates kit files in the workspace. Files with local edits are copied to"
  echo ".kit-backups/<timestamp>/ before the kit version replaces them. Ticket data,"
  echo "worklog notes, lessons-learned.md, and files the kit never installed are not"
  echo "touched. Run with --dry-run first."
  echo ""
  echo "Equivalent to:"
  echo "  ./install/install-to-workspace.sh --target <workspace> --mode copy --all --force"
  exit 0
fi

target="$1"
shift

extra_flags=""
if [ "${1:-}" = "--dry-run" ]; then
  extra_flags="--dry-run"
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$script_dir/install/install-to-workspace.sh" \
  --target "$target" \
  --mode copy \
  --all \
  --force \
  $extra_flags
