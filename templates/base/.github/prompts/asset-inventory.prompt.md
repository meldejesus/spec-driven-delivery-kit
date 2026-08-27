---
name: asset-inventory
description: Inventory all workflow assets on this machine — skills, agents, prompts, hooks, MCP config, and AGENTS.md files — and write a portable asset-inventory.md for use when migrating to a new machine or consolidating into the kit.
tools: [read, search, write, terminal]
---

# Asset Inventory

Run this prompt on any machine to produce a complete picture of every workflow
asset installed there. The output (`workflow/asset-inventory.md`) can be carried
to another machine and used to audit what is missing from the kit.

---

# What to Find

Search all of the following locations — do not stop at the first hit:

1. `~/.claude/plugins/` — Claude Code plugins, skills, agents, and commands
2. `~/Desktop/` and `~/Documents/` — any `.github/skills/`, `.github/agents/`,
   `.github/prompts/`, `.github/hooks/` directories in project folders
3. Any directory named `spec-driven-delivery-kit`, `spec-kit`, or similar
4. Any `CLAUDE.md` or `AGENTS.md` files at the root of Desktop project directories
5. Any `writing-spec-kit`, `workflow-kit`, or similar workflow kit directories
6. `~/.claude/settings.json` and `~/.claude/settings.local.json` — for hooks and
   any plugin/skill references

---

# What to Record Per File

For each file found, capture:

- **Full file path**
- **Name / title** — from frontmatter `name:` field or first heading
- **One-line description** — from frontmatter `description:` field, or first sentence
- **System** — which tool activates it:
  - `Claude Code plugin` — lives in `~/.claude/plugins/`
  - `Claude Code command` — lives in `.claude/commands/`
  - `VS Code Copilot skill` — lives in `.github/skills/`
  - `VS Code Copilot agent` — lives in `.github/agents/`
  - `VS Code Copilot prompt` — lives in `.github/prompts/`
  - `Writing kit skill` — lives in a writing-spec-kit or similar
  - `Other` — anything else, note the path
- **Source / author** — from frontmatter, README, or LICENSE file if present
  (e.g., `original`, `Anthropic / Boris Cherny`, `Apache 2.0`, etc.)
- **Kit present?** — is this file already in the installed spec-driven-delivery-kit?
  Check `templates/base/.github/` for agents/prompts/skills, and
  `~/.claude/plugins/` for Claude Code plugins.

---

# Hooks

Check for:
- `~/.claude/settings.json` — `hooks` array entries
- `.github/hooks/hooks.json`
- `.github/hooks/*.sh` shell scripts

For each hook, record: file path, trigger event, and one-line description of what it does.

---

# MCP Config

Check for:
- `.github/copilot/mcp.json`
- `.copilot/mcp.json`
- Any `mcp.json` in project root or `.claude/` directories

For each, record: file path and the list of MCP servers it configures.

---

# AGENTS.md / CLAUDE.md Files

List every `AGENTS.md` and `CLAUDE.md` found on the machine (excluding
`node_modules`). For each, record: path and a one-line summary of what project
or scope it governs.

---

# Output

Write everything to `workflow/asset-inventory.md` using this structure:

```markdown
---
generated: <YYYY-MM-DD>
machine: <hostname>
---

# Workflow Asset Inventory

## Claude Code Plugins & Skills

| Name | Description | Plugin | Source | In Kit? |
|------|-------------|--------|--------|---------|

## Kit Agents (.github/agents/)

| Name | Description | Kit / Repo | Source | In Kit? |
|------|-------------|------------|--------|---------|

## Kit Prompts (.github/prompts/)

| Name | Description | Stage | Kit / Repo | In Kit? |
|------|-------------|-------|------------|---------|

## Kit Skills (.github/skills/)

| Name | Description | Kit / Repo | Source | In Kit? |
|------|-------------|------------|--------|---------|

## Hooks

| File | Location | Trigger | What it does |
|------|----------|---------|--------------|

## MCP Config

| Server Name | Config File | What it connects to |
|-------------|-------------|---------------------|

## AGENTS.md / CLAUDE.md Files

| Path | Governs |
|------|---------|

## Gaps & Notes

Note anything that:
- Seems like it should exist but does not
- Exists in multiple places with overlap or conflict
- Is present on this machine but missing from the kit
- Would be lost if this machine were wiped without migrating the kit
```

---

# After Writing

Report a summary:
- Total assets found by category
- How many are already in the kit vs. machine-only
- Top gaps: assets on this machine that should be added to the kit

Do not make any changes to the kit or other files — this is a read-and-report task only.
