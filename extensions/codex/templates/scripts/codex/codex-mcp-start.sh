#!/usr/bin/env bash
set -u

# Preflight MCP OAuth before starting Codex so auth prompts happen up front,
# instead of after Codex has already started and emitted startup warnings.
#
# Configure the server list with:
#   CODEX_MCP_LOGIN_SERVERS="server-a server-b" ./scripts/codex/codex-mcp-start.sh
#
# Make failed MCP login block Codex startup with:
#   CODEX_MCP_LOGIN_STRICT=1 ./scripts/codex/codex-mcp-start.sh

servers=${CODEX_MCP_LOGIN_SERVERS:-}
failed_servers=()

if ! command -v codex >/dev/null 2>&1; then
  printf 'Codex CLI is not available on PATH.\n' >&2
  exit 127
fi

if [ -n "$servers" ]; then
  for server in $servers; do
    if ! codex mcp get "$server" >/dev/null 2>&1; then
      printf 'Skipping MCP server "%s": not configured in Codex.\n' "$server" >&2
      continue
    fi

    printf 'Checking MCP login for "%s"...\n' "$server"
    if ! codex mcp login "$server"; then
      failed_servers+=("$server")
      printf 'MCP login failed for "%s". Codex may still show a startup warning for this server.\n' "$server" >&2
    fi
  done
fi

if [ "${#failed_servers[@]}" -gt 0 ] && [ "${CODEX_MCP_LOGIN_STRICT:-0}" = "1" ]; then
  printf 'Not starting Codex because MCP login failed for: %s\n' "${failed_servers[*]}" >&2
  exit 1
fi

exec codex "$@"
