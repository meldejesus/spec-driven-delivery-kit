#!/usr/bin/env bash
# Install worklog git hooks into the workspace repo.
# Run this from the workspace root after installing the kit.
set -euo pipefail

workspace="${1:-.}"

hooks_src="$workspace/worklog/scripts/hooks"
hooks_dest="$workspace/.git/hooks"

if [ ! -d "$hooks_src" ]; then
  echo "Worklog hooks not found at $hooks_src — is the worklog extension installed?" >&2
  exit 1
fi

if [ ! -d "$hooks_dest" ]; then
  echo "No .git/hooks directory at $hooks_dest — is this a git repo?" >&2
  exit 1
fi

for hook in post-commit pre-commit post-checkout; do
  cp "$hooks_src/$hook" "$hooks_dest/$hook"
  chmod +x "$hooks_dest/$hook"
  echo "Installed: .git/hooks/$hook"
done

echo "Done. Worklog hooks are active."
