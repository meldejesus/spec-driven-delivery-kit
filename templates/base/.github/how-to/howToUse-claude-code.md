# Claude Code — Setup and Invocation Guide

Claude Code reads `CLAUDE.md` first, then `AGENTS.md`. Both must be in your workspace root.

---

## Session Startup

Open Claude Code from your workspace root (not the kit directory):

```bash
claude
```

Claude Code automatically reads `CLAUDE.md` and `AGENTS.md` on startup. No `#read` or `@` syntax needed for these files.

---

## MCP Configuration

Claude Code reads MCP config from `.claude/mcp.json` in your workspace root, or `~/.claude/claude_mcp_config.json` globally.

A template config is at `.claude/mcp.json` in this kit. Copy it to your workspace root and fill in credentials. See `.github/how-to/mcp-setup.md` for server setup and credential instructions.

---

## Running the Ticket Workflow

All stages use `run` commands resolved via the dispatcher table in `CLAUDE.md`.

**Start a ticket:**
```
run contract ticket=PROJECT-123
```

Or with a full Jira URL:
```
run contract ticket=https://your-domain.atlassian.net/browse/PROJECT-123
```

**Continue through the workflow:**
```
run plan
run implement
run review
run closeout
```

**After CI completes (~20 min after push):**
```
run sonar pr_number=<PR_NUMBER>
```

Full command reference: `.github/how-to/howToUse.md`

---

## Other Workflows

```
run peer-review pr_url=https://github.com/your-org/repo/pull/XXXX
run spike-contract ticket=PROJECT-123
run refinement tickets=PROJECT-123
run merge-conflict target_branch=origin/main
```

---

## Key Differences from Copilot CLI

| | Claude Code | Copilot CLI |
|---|---|---|
| Session start | `claude` | `copilot` |
| Primary config | `CLAUDE.md` (read first) | `.github/copilot-instructions.md` |
| MCP config | `.claude/mcp.json` | `.github/copilot/mcp.json` |
| Agent invocation | `run X` (via CLAUDE.md dispatcher) | `@AgentName #read prompt` |

---

## Permission Notes

Claude Code prompts for approval on file writes outside the workspace, shell commands, and network requests beyond MCP servers. The kit's agents write only to `workflow/`, `.github/`, and specified output directories — all within workspace scope.

If MCP is unavailable, create `workflow/PROJECT-123/pre-context.md` with the ticket content before running `run contract`. See `.github/how-to/howToUse-no-tracker.md`.
