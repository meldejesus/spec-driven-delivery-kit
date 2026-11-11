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
  --force             Also replace files that differ from the kit but are not in
                      the manifest yet. Each one is backed up first.
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
  - Kit files with no local edits are updated.
  - Kit files with local edits are copied to .kit-backups/<timestamp>/ and
    then updated.
  - Files retired from the kit (in old manifest, not in new kit) are deleted if
    unmodified, or left in place with a warning if locally modified.
  - Files the kit never installed (ticket data, user-added skills, etc.) are
    never touched.
  - With no manifest yet: files identical to the kit are claimed as kit-owned.
    Files that differ are skipped, or backed up and replaced with --force.

Seed files:
  worklog/ (except worklog/scripts/), .github/lessons-learned.md,
  workflow/index.md, workflow/README.md, workflow/future-tickets/, and
  workflow/misc/ are copied only when missing. They hold your own content, so
  the installer never updates, replaces, or removes them.

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
#
# Manifest lines are "<sha256>  <relative path>". The hash is always 64 hex
# characters, so the path starts at column 67. Lookups compare the whole path
# with awk; grep -F cannot anchor on end of line.

manifest_file="$target/.kit-manifest"
old_manifest_tmp=""
new_manifest_tmp=""
backup_root="$target/.kit-backups/$(date +%Y%m%d-%H%M%S)"

init_manifest() {
  old_manifest_tmp="$(mktemp)"
  new_manifest_tmp="$(mktemp)"
  if [ -f "$manifest_file" ]; then
    cp "$manifest_file" "$old_manifest_tmp"
  fi
  trap 'rm -f "$old_manifest_tmp" "$new_manifest_tmp"' EXIT
}

manifest_path_of() {
  echo "$1" | cut -c67-
}

manifest_hash_for() {
  local rel="$1"
  local file="$2"
  awk -v r="$rel" 'substr($0, 67) == r { print $1; exit }' "$file"
}

manifest_lookup() {
  manifest_hash_for "$1" "$old_manifest_tmp"
}

in_new_manifest() {
  [ -n "$(manifest_hash_for "$1" "$new_manifest_tmp")" ]
}

record_manifest() {
  local src="$1"
  local rel="$2"
  echo "$(file_hash "$src")  $rel" >> "$new_manifest_tmp"
}

unrecord_manifest() {
  local rel="$1"
  awk -v r="$rel" 'substr($0, 67) != r' "$new_manifest_tmp" > "${new_manifest_tmp}.tmp"
  mv "${new_manifest_tmp}.tmp" "$new_manifest_tmp"
}

write_manifest() {
  if [ "$dry_run" != "1" ] && [ -s "$new_manifest_tmp" ]; then
    sort -u "$new_manifest_tmp" > "$manifest_file"
    _log "Wrote manifest: $manifest_file"
  fi
}

# --- Path classes ---

# Seed files start as templates and then hold the user's own content. They are
# copied only when missing, never tracked in the manifest, never updated, and
# never retired.
is_seed_path() {
  case "$1" in
    worklog/scripts/*) return 1 ;;
    worklog/*) return 0 ;;
    .github/lessons-learned.md) return 0 ;;
    workflow/index.md|workflow/README.md) return 0 ;;
    workflow/future-tickets/*|workflow/misc/*) return 0 ;;
  esac
  return 1
}

# Always-replace files are fully kit-owned, so local edits are backed up and
# replaced even without --force.
is_always_replace_path() {
  [ "$1" = "workflow/TAGS.md" ]
}

# --- Backups ---

backup_path() {
  local rel="$1"
  run mkdir -p "$(dirname "$backup_root/$rel")"
  run cp -p "$target/$rel" "$backup_root/$rel"
}

replace_with_backup() {
  local src="$1"
  local rel="$2"
  backup_path "$rel"
  run cp "$src" "$target/$rel"
  echo "⚠️  Local edits backed up to ${backup_root#${target}/}/$rel — kit version installed: $rel"
}

retire_legacy_path() {
  local rel="$1"
  [ -e "$target/$rel" ] || return 0
  run mkdir -p "$(dirname "$backup_root/$rel")"
  run mv "$target/$rel" "$backup_root/$rel"
  _log "Moved legacy path to ${backup_root#${target}/}/$rel"
}

# --- Retired kit files ---

remove_retired_file() {
  local old_hash="$1"
  local rel="$2"
  local dest="$target/$rel"

  if in_new_manifest "$rel" || is_seed_path "$rel" || [ ! -f "$dest" ]; then
    return
  fi
  if [ "$(file_hash "$dest")" = "$old_hash" ]; then
    run rm "$dest"
    _log "Removed retired kit file: $rel"
    return
  fi
  echo "⚠️  Retired kit file has local edits, leaving in place: $rel"
}

remove_retired_files() {
  [ -s "$old_manifest_tmp" ] || return 0
  local line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    remove_retired_file "${line%% *}" "$(manifest_path_of "$line")"
  done < "$old_manifest_tmp"
}

# --- File install with manifest awareness ---

install_seed_file() {
  local src="$1"
  local rel="$2"
  [ -e "$target/$rel" ] && return
  run cp "$src" "$target/$rel"
  _log "Seeded: $rel"
}

# Decides what to do with an existing file that differs from the kit version.
update_existing_file() {
  local src="$1"
  local rel="$2"
  local dest_hash
  dest_hash=$(file_hash "$target/$rel")
  local manifest_hash
  manifest_hash=$(manifest_lookup "$rel")

  if [ -n "$manifest_hash" ] && [ "$dest_hash" = "$manifest_hash" ]; then
    run cp "$src" "$target/$rel"
    _log "Updated: $rel"
    return
  fi

  local has_local_edits_to_replace="0"
  if [ -n "$manifest_hash" ] || [ "$force" = "1" ] || is_always_replace_path "$rel"; then
    has_local_edits_to_replace="1"
  fi
  if [ "$has_local_edits_to_replace" = "1" ]; then
    replace_with_backup "$src" "$rel"
    return
  fi

  _log "Skipping (differs from kit, not yet kit-managed; --force backs it up and replaces it): $rel"
  unrecord_manifest "$rel"
}

install_file() {
  local src="$1"
  local dest="$2"
  local rel="${dest#${target}/}"

  [ -f "$src" ] || return 0
  run mkdir -p "$(dirname "$dest")"

  if is_seed_path "$rel"; then
    install_seed_file "$src" "$rel"
    return
  fi

  record_manifest "$src" "$rel"

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

  # Identical files need no copy; the manifest entry claims them as kit-owned.
  [ "$(file_hash "$dest")" = "$(file_hash "$src")" ] && return
  update_existing_file "$src" "$rel"
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

if [ "$include_worklog" = "1" ]; then
  # Paths from the pre-worklog standup extension. Move them to the backup
  # folder instead of deleting them.
  for legacy in standup scripts/standup-sync scripts/worklog-sync .github/skills/standup; do
    retire_legacy_path "$legacy"
  done
  install_dir "$kit_root/extensions/worklog/templates/worklog"               "$target/worklog"
  # The worklog skill itself ships with the base kit in .github/skills/worklog/.
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
