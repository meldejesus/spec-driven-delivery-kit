#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Install the spec-driven delivery kit into an active workspace.

Usage:
  install-to-workspace.sh --target /path/to/workspace [options]

Options:
  --target PATH       Workspace root where agents should discover the kit files.
  --mode copy         Copy files into the workspace. Default.
  --mode symlink      Symlink files from this kit into the workspace.
  --with-tools        Also install optional extension templates.
  --with-worklog      Also install the optional worklog extension.
  --with-cleanup      Also install the optional cleanup extension.
  --all               Install core files and optional extension templates.
  --force             Replace existing installed paths.
  --dry-run           Print actions without changing files.
  -h, --help          Show this help.

Core install paths:
  AGENTS.md
  .github/
  .copilot/
  workflow/           copied from templates/base/workflow/

Optional install paths:
  messages/
  worklog/
  .github/skills/worklog/
  scripts/cleanup/
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kit_root="$(cd "${script_dir}/.." && pwd)"

target=""
mode="copy"
include_messages="0"
include_worklog="0"
include_cleanup="0"
force="0"
dry_run="0"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --with-tools|--all)
      include_messages="1"
      include_worklog="1"
      include_cleanup="1"
      shift
      ;;
    --with-worklog)
      include_worklog="1"
      shift
      ;;
    --with-cleanup)
      include_cleanup="1"
      shift
      ;;
    --force)
      force="1"
      shift
      ;;
    --dry-run)
      dry_run="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$target" ]; then
  echo "Missing required --target PATH." >&2
  usage >&2
  exit 2
fi

case "$mode" in
  copy|symlink) ;;
  *)
    echo "Invalid --mode '${mode}'. Use 'copy' or 'symlink'." >&2
    exit 2
    ;;
esac

target="$(cd "$target" && pwd)"

if [ "$target" = "$kit_root" ]; then
  echo "Refusing to install the kit into itself: $target" >&2
  exit 2
fi

case "$target/" in
  "$kit_root"/*)
    echo "Refusing to install into a child of the kit repo: $target" >&2
    exit 2
    ;;
esac

run() {
  if [ "$dry_run" = "1" ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

install_path() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "Skipping missing source: $src"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$force" != "1" ]; then
      echo "Skipping existing path: $dest"
      return
    fi
    run rm -rf "$dest"
  fi

  run mkdir -p "$(dirname "$dest")"

  if [ "$mode" = "symlink" ]; then
    run ln -s "$src" "$dest"
  else
    if [ -d "$src" ]; then
      run cp -R "$src" "$dest"
    else
      run cp "$src" "$dest"
    fi
  fi

  if [ "$dry_run" = "1" ]; then
    echo "Would install: $dest"
  else
    echo "Installed: $dest"
  fi
}

remove_legacy_path() {
  local path="$1"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return
  fi

  if [ "$force" != "1" ]; then
    echo "Legacy path remains because --force was not passed: $path"
    return
  fi

  run rm -rf "$path"

  if [ "$dry_run" = "1" ]; then
    echo "Would remove legacy path: $path"
  else
    echo "Removed legacy path: $path"
  fi
}

echo "Kit root: $kit_root"
echo "Target workspace: $target"
echo "Mode: $mode"

install_path "$kit_root/templates/base/AGENTS.md" "$target/AGENTS.md"
install_path "$kit_root/templates/base/.github" "$target/.github"
install_path "$kit_root/templates/base/.copilot" "$target/.copilot"
install_path "$kit_root/templates/base/workflow" "$target/workflow"

if [ "$include_worklog" = "1" ]; then
  remove_legacy_path "$target/standup"
  remove_legacy_path "$target/scripts/standup-sync"
  remove_legacy_path "$target/scripts/worklog-sync"
  remove_legacy_path "$target/.github/skills/standup"
fi

if [ "$include_messages" = "1" ]; then
  install_path "$kit_root/extensions/messages/templates/messages" "$target/messages"
fi

if [ "$include_worklog" = "1" ]; then
  install_path "$kit_root/extensions/worklog/templates/worklog" "$target/worklog"
  install_path "$kit_root/extensions/worklog/templates/.github/skills/worklog" "$target/.github/skills/worklog"
fi

if [ "$include_cleanup" = "1" ]; then
  install_path "$kit_root/extensions/cleanup/templates/scripts/cleanup" "$target/scripts/cleanup"
fi

echo "Done. Open your CLI or editor from: $target"
