# Agent Guide — `.github/agents/`

> For the full agent registry (names, roles, definition paths) see [`/AGENTS.md`](/AGENTS.md) at the repo root.

This file explains **how agents work together**, tool permissions, and which agent to reach for in common scenarios.

---

## Global Rules (all agents)

- Never commit secrets or modify `infra/prod` configs.
- Follow repo standards in `.github/copilot-instructions.md`.
- Keep changes minimal and reviewable; favor small PRs.
- Always run the project's test command before proposing a PR summary.

---

## Implementation Agent

### targeted-writer (replaces developer + writer-standards)

`@targeted-writer` is the single approval-gated writer for all code changes. It auto-detects which mode to use:

| Mode | When | Approval gate |
|------|------|---------------|
| **Surgical** | Single known fix, exact patch, BLOCKER | Handshake → "Yes, apply now" |
| **Planned** | Multi-file, feature, refactor, exploratory | Plan → "Proceed" → step-by-step checkpoints |

Both modes always run lint + format + tests after applying changes.

---

## Common Workflows

### Feature Development (Full Cycle)
```
@Architect → @targeted-writer → @tester → @Reviewer → @targeted-writer (if fixes needed)
```

### Quick Fix
```
@Reviewer (optional) → @targeted-writer
```

### Refactoring
```
@Architect (design) → @targeted-writer (implement) → @tester (validate)
```

### Formal Pipeline (ticket-based)
```
@Architect (contract) → @Plan-Agent (plan) → @Implementer (code + handoff) → @Reviewer (review) → @targeted-writer (fixes)
```

### Message Writing
```
@Message-Writer (approach → outline → draft → review → lessons)
```

Use for turning dense technical docs into clearer technical, mixed-audience, or non-technical messages. File-backed output is optional and limited to `workflow/messages/**`.

### Addressing Review Feedback
- **Single BLOCKER**: `@targeted-writer` (surgical mode)
- **Multiple coordinated fixes**: `@targeted-writer` (planned mode)
- **Broad refactor suggestions**: `@targeted-writer` (planned mode)

### Merge Conflicts
```
@merge-conflict-resolver (analyze) → @targeted-writer (apply resolution)
```

---

## Tool Permissions Guide

### Advisory Agents (Read-Only)
**Architect, Reviewer, merge-conflict-resolver**
- Cannot edit files
- Produce recommendations, decisions, and analysis
- Use `infer: false` in frontmatter

### Implementation Agents (Can Edit)
**targeted-writer, Implementer, tester**
- Can modify files and run commands
- Must validate changes (lint, format, test)
- Use `infer: true` in frontmatter

### Limited Writing Agents
**Message-Writer**
- Can write only under `workflow/messages/**`
- Pauses after approach and outline
- Does not edit code, ticket artifacts, or global instructions

### Terminal Access
Agents with terminal access can:
- Run git commands (fetch, diff, status)
- Execute test commands
- Run lint/format tools
- **Never** make destructive changes without approval

---

## Standards Reference

All agents reference and enforce standards from:
- **`.github/copilot-instructions.md`** - Primary developer guidelines (includes Tailwind token rules and the `tailwind-check` skill reference)
- **`.github/lessons-learned.md`** - Distilled per-ticket lessons; Plan-Agent reads this before planning and surfaces relevant entries as pre-flight notes
- **Project-specific configs** - ESLint, Prettier, TypeScript, Tailwind
- **Nx workspace conventions** - Library boundaries, naming, structure

When standards conflict with prompts, agents will:
1. Follow documented standards
2. Explain the conflict
3. Ask for clarification if needed
