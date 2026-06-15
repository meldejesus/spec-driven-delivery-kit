#!/bin/zsh
# cleanup-safe.sh
# Runs clean.sh with a conservative category set safe for active dev environments.
# Excludes: editors_cache (VS Code state), user_caches (broad), xcode_simulators (slow to rebuild)
# Includes: node_caches, pip_cache, brew_cleanup, gradle_caches, xcode_derived, logs_old, trash_empty
# node_caches also clears Yarn Berry, npm _npx, Cypress, and Puppeteer caches.
#
# Usage:
#   ./scripts/cleanup/cleanup-safe.sh            # dry-run (safe preview)
#   ./scripts/cleanup/cleanup-safe.sh --yes      # execute

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SAFE_ONLY="node_caches,pip_cache,brew_cleanup,gradle_caches,xcode_derived,logs_old,trash_empty"

exec "$SCRIPT_DIR/clean.sh" \
  --only "$SAFE_ONLY" \
  --fast \
  "$@"
