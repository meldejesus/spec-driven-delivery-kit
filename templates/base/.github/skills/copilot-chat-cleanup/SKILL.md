---
name: copilot-chat-cleanup
description: >
  Safely cleans up old VS Code Copilot chat conversation threads using age and
  exception filters. Always runs in dry-run mode first, preserves protected
  conversations by title/content/session ID, and only deletes after explicit
  confirmation.
---

# Copilot Chat Cleanup

Use this skill when the user asks to delete or prune old Copilot chat threads by age, with exceptions such as specific thread titles.

## Inputs

Collect these inputs from the user before deletion:

1. Age threshold in days (default: 30).
2. Scope:
- Current workspace storage only.
- All workspaceStorage entries on this machine.
3. Exception filters:
- Exact title/content match strings.
- Regex pattern(s).
- Explicit protected session IDs.
4. Mode:
- Preview only.
- Execute deletion.

## Safety Rules

1. Always run a dry-run first and show counts and sample IDs.
2. Never delete protected sessions.
3. Require explicit confirmation before execute mode.
4. Delete only Copilot chat artifacts, never repository source files.
5. After deletion, verify and report remaining matching sessions.

## Storage Paths (macOS)

Primary root:
`$HOME/Library/Application Support/Code/User/workspaceStorage`

Likely artifacts per workspace ID:

1. `chatSessions/<sessionId>.jsonl`
2. `chatEditingSessions/<sessionId>/`
3. `GitHub.copilot-chat/chat-session-resources/<sessionId>/`
4. `GitHub.copilot-chat/debug-logs/<sessionId>/`

## Procedure

### Step 1: Discover workspace targets

List workspace IDs that contain Copilot data:

```bash
BASE="$HOME/Library/Application Support/Code/User/workspaceStorage"
find "$BASE" -type d -name "GitHub.copilot-chat" 2>/dev/null
```

If scope is current workspace only, use the active workspace ID path.

### Step 2: Resolve protected session IDs

From user-provided exception filters, find matching session IDs in `chatSessions/*.jsonl`.

```bash
WS="...workspaceStorage/<workspaceId>"
CHAT="$WS/chatSessions"

# Example for title/content filter
rg -l -i "dropdown navigation issue in profile screen|dropdown.*navigation.*profile" "$CHAT" \
  | sed 's#^.*/##' | sed 's#\.jsonl$##'
```

Merge with any explicit protected IDs provided by the user.

### Step 3: Build dry-run candidate list

Create candidate list: old sessions older than threshold, excluding protected IDs.

```bash
DAYS=30
find "$CHAT" -type f -name "*.jsonl" -mtime +$DAYS | while read -r f; do
  id=$(basename "$f" .jsonl)
  if ! printf "%s\n" "$PROTECTED_IDS" | grep -qx "$id"; then
    echo "$id"
  fi
done > /tmp/copilot_sessions_to_delete.txt
```

Report:

1. Protected ID count.
2. Candidate deletion count.
3. First 20 candidate IDs.

### Step 4: Confirm execution

Only continue when the user explicitly confirms execution.

Confirmation text example:

"Proceed with deleting N Copilot sessions older than X days, excluding protected IDs."

### Step 5: Execute deletion

For each candidate ID, delete only the known Copilot artifacts:

```bash
while read -r id; do
  [[ -z "$id" ]] && continue
  rm -rf \
    "$WS/chatSessions/$id.jsonl" \
    "$WS/chatEditingSessions/$id" \
    "$WS/GitHub.copilot-chat/chat-session-resources/$id" \
    "$WS/GitHub.copilot-chat/debug-logs/$id"
done < /tmp/copilot_sessions_to_delete.txt
```

### Step 6: Verify

Re-run the Step 3 query and confirm zero remaining candidates.

## Output Template

Use this structure in the final response:

1. Applied rule summary (age + exceptions + scope).
2. Protected IDs count and list (or redacted if requested).
3. Deleted count.
4. Remaining count after verification.
5. Note that UI may require a VS Code reload to reflect cleanup.
