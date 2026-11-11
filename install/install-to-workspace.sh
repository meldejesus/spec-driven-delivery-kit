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
  --with-codex        Also install optional Codex helper scripts.
  --all               Install core files and optional extension templates.
  --github-only       Install only .github/ (safe for Desktop or shared roots).
  --force             Overwrite all kit-managed files, even locally modified ones.
  --dry-run           Print actions without changing files.
  -h, --help          Show this help.

Core install paths:
  AGENTS.md
  TAGS.md
  .github/
  .copilot/
  .claude/            Claude Code slash commands (/contract, /plan, /implement, /workflow-review)
  workflow/           copied from templates/base/workflow/

Optional install paths:
  worklog/
  .github/skills/worklog/
  scripts/cleanup/
  scripts/codex/

Manifest:
  .kit-manifest is written to the workspace after each install. On reinstall:
  - Kit-managed files with no local edits are updated silently.
  - Locally modified kit files are backed up (.kit-backup) and then updated.
  - Files retired from the kit (in old manifest, not in new kit) are deleted if
    unmodified, or left in place with a warning if locally modified.
  - Files not in the manifest (ticket data, worklog, user-added skills, etc.)
    are never touched.
  - With no manifest yet: files identical to the current kit are treated as
    kit-owned; files that differ are left alone.
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kit_root="$(cd "${script_dir}/.." && pwd)"

target=""
mode="copy"
include_worklog="0"
include_cleanup="0"
include_codex="0"
github_only="0"
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
    --github-only)
      github_only="1"
      shift
      ;;
    --with-tools|--all)
      include_worklog="1"
      include_cleanup="1"
      include_codex="1"
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
    --with-codex)
      include_codex="1"
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

# --- Utilities ---

run() {
  if [ "$dry_run" = "1" ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

_log() {
  if [ "$dry_run" = "1" ]; then
    echo "[dry-run] $1"
  else
    echo "$1"
  fi
}

file_hash() {
  shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
}

# --- Manifest ---

manifest_file="$target/.kit-manifest"
old_manifest_tmp=""
new_manifest_tmp=""

init_manifest() {
  old_manifest_tmp="$(mktemp)"
  new_manifest_tmp="$(mktemp)"
  if [ -f "$manifest_file" ]; then
    cp "$manifest_file" "$old_manifest_tmp"
  fi
  trap 'rm -f "$old_manifest_tmp" "$new_manifest_tmp"' EXIT
}

manifest_lookup() {
  local rel="$1"
  if [ -s "$old_manifest_tmp" ]; then
    grep -F "  ${rel}$" "$old_manifest_tmp" 2>/dev/null | awk '{print $1}' | head -1
  fi
}

record_manifest() {
  local src="$1"
  local rel="$2"
  local hash
  hash=$(file_hash "$src")
  echo "$hash  $rel" >> "$new_manifest_tmp"
}

write_manifest() {
  if [ "$dry_run" != "1" ] && [ -s "$new_manifest_tmp" ]; then
    sort "$new_manifest_tmp" > "$manifest_file"
    _log "Wrote manifest: $manifest_file"
  fi
}

remove_retired_files() {
  [ -s "$old_manifest_tmp" ] || return
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local old_hash
    old_hash=$(echo "$line" | awk '{print $1}')
    local rel
    rel=$(echo "$line" | awk '{$1=""; sub(/^  /, ""); print}')
    # Skip if still in new kit
    if grep -qF "  ${rel}$" "$new_manifest_tmp" 2>/dev/null; then
      continue
    fi
    local dest="$target/$rel"
    [ -f "$dest" ] || continue
    local dest_hash
    dest_hash=$(file_hash "$dest")
    if [ "$dest_hash" = "$old_hash" ]; then
      run rm "$dest"
      _log "Removed retired kit file: $rel"
    else
      echo "⚠️  Retired kit file has local edits, leaving in place: $rel"
    fi
  done < "$old_manifest_tmp"
}

# --- File install with manifest awareness ---

install_file() {
  local src="$1"
  local dest="$2"
  local rel="${dest#${target}/}"

  [ -f "$src" ] || return

  local src_hash
  src_hash=$(file_hash "$src")
  record_manifest "$src" "$rel"

  run mkdir -p "$(dirname "$dest")"

  if [ "$mode" = "symlink" ]; then
    if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
      run ln -s "$src" "$dest"
      _log "Linked: $rel"
    fi
    return
  fi

  if [ ! -e "$dest" ]; then
    run cp "$src" "$dest"
    _log "Installed: $rel"
    return
  fi

  local dest_hash
  dest_hash=$(file_hash "$dest")
  local manifest_hash
  manifest_hash=$(manifest_lookup "$rel")

  if [ "$force" = "1" ]; then
    run cp "$src" "$dest"
    _log "Force-updated: $rel"
    return
  fi

  if [ -n "$manifest_hash" ]; then
    # Kit-managed file from a previous install
    if [ "$dest_hash" = "$manifest_hash" ]; then
      # Unmodified since install
      if [ "$dest_hash" != "$src_hash" ]; then
        run cp "$src" "$dest"
        _log "Updated: $rel"
      fi
      # else: already up to date, silent
    else
      # Locally modified — back up, then apply kit update
      local backup="${dest}.kit-backup"
      run cp "$dest" "$backup"
      run cp "$src" "$dest"
      echo "⚠️  Local edits backed up to ${rel}.kit-backup — kit update applied"
    fi
  else
    # No manifest entry: bootstrap check
    if [ "$dest_hash" = "$src_hash" ]; then
      # Identical to kit — claim as kit-owned (record in manifest, no copy needed)
      _log "Claimed (bootstrap): $rel"
    else
      # Differs, not kit-managed — leave alone
      _log "Skipping (user file): $rel"
      # Remove from new manifest since we're not managing it
      if [ "$dry_run" != "1" ]; then
        grep -vF "  ${rel}$" "$new_manifest_tmp" > "${new_manifest_tmp}.tmp" && mv "${new_manifest_tmp}.tmp" "$new_manifest_tmp" || true
      fi
    fi
  fi
}

install_dir() {
  local src_dir="$1"
  local dest_dir="$2"

  [ -d "$src_dir" ] || { echo "Skipping missing source: $src_dir"; return; }

  run mkdir -p "$dest_dir"

  while IFS= read -r -d '' src_file; do
    local rel_in_src="${src_file#${src_dir}/}"
    install_file "$src_file" "${dest_dir}/${rel_in_src}"
  done < <(find "$src_dir" -type f -print0 | sort -z)
}

# --- Main ---

echo "Kit root:  $kit_root"
echo "Target:    $target"
echo "Mode:      $mode"

if [ "$github_only" = "1" ]; then
  init_manifest
  install_dir "$kit_root/templates/base/.github" "$target/.github"
  remove_retired_files
  write_manifest
  echo "Done (github-only). Skills and prompts installed to: $target/.github"
  exit 0
fi

init_manifest

install_file "$kit_root/templates/base/AGENTS.md"    "$target/AGENTS.md"
install_file "$kit_root/templates/base/TAGS.md"      "$target/TAGS.md"
install_dir  "$kit_root/templates/base/.github"      "$target/.github"
install_dir  "$kit_root/templates/base/.copilot"     "$target/.copilot"
install_dir  "$kit_root/templates/base/.claude"      "$target/.claude"
install_dir  "$kit_root/templates/base/workflow"     "$target/workflow"

# workflow/TAGS.md is always kit-managed (overwrite even if edited)
if [ "$dry_run" != "1" ]; then
  mkdir -p "$target/workflow"
  cp "$kit_root/templates/base/workflow/TAGS.md" "$target/workflow/TAGS.md"
fi
_log "Installed (always): workflow/TAGS.md"

if [ "$include_worklog" = "1" ]; then
  run rm -rf "$target/standup" "$target/scripts/standup-sync" \
             "$target/scripts/worklog-sync" "$target/.github/skills/standup" 2>/dev/null || true
  install_dir "$kit_root/extensions/worklog/templates/worklog"               "$target/worklog"
  install_dir "$kit_root/extensions/worklog/templates/.github/skills/worklog" "$target/.github/skills/worklog"
fi

if [ "$include_cleanup" = "1" ]; then
  install_dir "$kit_root/extensions/cleanup/templates/scripts/cleanup" "$target/scripts/cleanup"
fi

if [ "$include_codex" = "1" ]; then
  install_dir "$kit_root/extensions/codex/templates/scripts/codex" "$target/scripts/codex"
fi

remove_retired_files
write_manifest

echo "Done. Open your CLI or editor from: $target"
