#!/bin/bash
# Pre-tool-use security gate for GitHub Copilot CLI agent.
#
# This hook ONLY hard-denies truly catastrophic, unrecoverable commands.
# Everything else — including rm, mysql, curl mutations — falls through to
# Copilot's native approval prompt, where you can approve or reject per use.
#
# Add to HARD_DENY only commands that should NEVER run unattended under any
# circumstances (e.g., wiping the entire filesystem or disk).
#
# Input:  JSON on stdin  { toolName, toolArgs, cwd, timestamp }
# Output: JSON to stdout { permissionDecision, permissionDecisionReason }
#         exit 0 always — decisions are communicated via JSON, not exit codes.

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs')

# Only gate bash/shell execution.
if [ "$TOOL_NAME" != "bash" ]; then
  exit 0
fi

COMMAND=$(echo "$TOOL_ARGS" | jq -r '.command // empty')

# ── Hard deny — catastrophic / unrecoverable only ────────────────────────────
# These are NEVER allowed, even with approval. Keep this list very short.
# For anything else (rm, mysql, curl -X DELETE, etc.) — remove it from here
# and let Copilot's native approval prompt handle it.
HARD_DENY_PATTERNS=(
  "rm[[:space:]]+-[a-zA-Z]*rf[[:space:]]*/([[:space:]]|$)"   # rm -rf / (root wipe)
  "rm[[:space:]]+-[a-zA-Z]*rf[[:space:]]*~([[:space:]]|$)"   # rm -rf ~ (home wipe)
  "rm[[:space:]]+-[a-zA-Z]*rf[[:space:]]*\*([[:space:]]|$)"  # rm -rf * (cwd wipe)
  "mkfs\."                                                    # disk formatting
  "dd[[:space:]]+.*of=/dev/"                                  # disk overwrite
  ":(){:|:&};:"                                               # fork bomb
)

deny() {
  local reason="$1"
  jq -n --arg r "$reason" '{permissionDecision:"deny",permissionDecisionReason:$r}'
  exit 0
}

for pattern in "${HARD_DENY_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    deny "Permanently blocked — this command is catastrophic and unrecoverable. Run nothing; stop here."
  fi
done

# All other commands fall through to Copilot's native approval prompt.
exit 0
