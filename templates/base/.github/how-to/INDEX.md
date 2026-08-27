# How-To Index

Reference docs shipped with the kit. These live in `.github/how-to/` in your installed workspace.

---

## Daily Use

| File | What it covers |
|---|---|
| [`howToUse.md`](howToUse.md) | **Start here for daily work.** All workflow commands in one place — ticket pipeline, peer review, spike, refinement, merge conflict, artifacts, archival. |

## Setup & Migration

| File | What it covers |
|---|---|
| [`howToUse-migration.md`](howToUse-migration.md) | Migrating an existing workspace to a new kit version — archive old structure, reinstall, clean up. |
| [`howToUse-no-tracker.md`](howToUse-no-tracker.md) | Working without a ticket tracker — `pre-context.md` pattern, naming convention, switching to a tracker later. |
| [`howToUse-context-md.md`](howToUse-context-md.md) | What `CONTEXT.md` is, when to update it, and what each section should contain. |
| [`mcp-setup.md`](mcp-setup.md) | One-time setup for MCP servers (Atlassian, GitHub) across Claude Code, Copilot, and Codex. |
| [`instructions-setup.md`](instructions-setup.md) | How the instruction layer works — which files each CLI reads, what belongs in AGENTS.md vs CLAUDE.md vs copilot-instructions.md. |
| [`howToUse-claude-code.md`](howToUse-claude-code.md) | Claude Code CLI — startup, MCP config, `run X` commands, permission notes. |
| [`howToUse-codex.md`](howToUse-codex.md) | Codex CLI — startup, AGENTS.md as config, MCP notes, fallback invocation. |

## Writing Workflow

| File | What it covers |
|---|---|
| [`howToUse-message.md`](howToUse-message.md) | Message-Writer workflow — translating dense technical docs into stakeholder-appropriate messages (email, FAQ, one-pager, Slack). |

## Deep Dives

| File | What it covers |
|---|---|
| [`howToUse-ticket-archival.md`](howToUse-ticket-archival.md) | What to keep and what to delete once a ticket is merged — Option A (3 files) vs Option B (7 files) with rationale. |
| [`spec-driven-workflow.md`](spec-driven-workflow.md) | Why the workflow is designed this way — the philosophy behind contracts, gates, and evidence-gated delivery. |
| [`authoring-agents-prompts-skills.md`](authoring-agents-prompts-skills.md) | How to write and extend agents, prompts, and skills — for contributors and kit maintainers. |
