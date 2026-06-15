# Codex Helper Scripts

Optional helpers for launching Codex in a workspace.

## MCP Login Preflight

`codex-mcp-start.sh` checks configured MCP server login before starting Codex.
This moves OAuth prompts to startup instead of letting Codex emit warnings after
the session has already opened.

By default, no MCP servers are checked. Set a space-separated list:

```bash
CODEX_MCP_LOGIN_SERVERS="server-a server-b" ./scripts/codex/codex-mcp-start.sh
```

Forward normal Codex arguments after the script:

```bash
CODEX_MCP_LOGIN_SERVERS="server-a" ./scripts/codex/codex-mcp-start.sh status
```

Make login failures block Codex startup:

```bash
CODEX_MCP_LOGIN_STRICT=1 CODEX_MCP_LOGIN_SERVERS="server-a" ./scripts/codex/codex-mcp-start.sh
```
