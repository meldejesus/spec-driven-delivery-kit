# Codex CLI — Setup and Invocation Guide

Codex reads `AGENTS.md` natively (OpenAI standard). It does not read `CLAUDE.md` or `.github/copilot-instructions.md` automatically.

---

## Session Startup

Open Codex from your workspace root:

```bash
codex
```

Codex loads `AGENTS.md` automatically. For Codex-specific instructions, use `codex.md` in your workspace root or `~/.codex/instructions.md` globally.

---

## Running the Ticket Workflow

The `run X` short commands work in Codex when the dispatcher is defined in `AGENTS.md`. All stages are identical:

```
run contract ticket=PROJECT-123
run plan
run implement
run review
run closeout
```

If the dispatcher does not resolve, use the explicit form:

```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
output_dir=workflow/PROJECT-123
```

---

## MCP Configuration

Codex MCP config location is evolving — check current Codex documentation. MCP is only required for automatic ticket fetching in the contract stage. All other stages read local files only.

---

## Key Differences from Claude Code

| | Codex | Claude Code |
|---|---|---|
| Primary config | `AGENTS.md` only | `CLAUDE.md` + `AGENTS.md` |
| `run X` dispatcher | Requires definition in `AGENTS.md` | Reads from `CLAUDE.md` |
| MCP config | See Codex docs | `.claude/mcp.json` |

---

## If MCP Is Unavailable

Create `workflow/PROJECT-123/pre-context.md` with the ticket content, then run:

```
run contract ticket=PROJECT-123
```

The contract stage reads `pre-context.md` automatically. See `.github/how-to/howToUse-no-tracker.md`.
