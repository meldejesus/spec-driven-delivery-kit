# Agent Collaboration Guide

> This file has been consolidated into `README.md` in this directory.
> See `.github/agents/README.md` for the current version.


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
@Architect → @targeted-writer → @tester → @reviewer → @targeted-writer (if fixes needed)
```

### Quick Fix
```
@reviewer (optional) → @targeted-writer
```

### Refactoring
```
@Architect (design) → @targeted-writer (implement) → @tester (validate)
```

### Formal Pipeline (ticket-based)
```
@Architect (contract) → @Plan-Agent (plan) → @Implementer (code + handoff) → @reviewer (review) → @targeted-writer (fixes)
```

### Addressing Review Feedback
- **Single BLOCKER**: `@writer-standards`
- **Multiple coordinated fixes**: `@developer`
- **Broad refactor suggestions**: `@developer`

### Merge Conflicts
```
@merge-conflict-resolver (analyze) → @writer-standards (apply resolution)
```

---

## Tool Permissions Guide

### Advisory Agents (Read-Only)
**architect, reviewer, merge-conflict-resolver**
- Cannot edit files
- Produce recommendations, decisions, and analysis
- Use `infer: false` in frontmatter

### Implementation Agents (Can Edit)
**developer, writer-standards, tester**
- Can modify files and run commands
- Must validate changes (lint, format, test)
- Use `infer: true` in frontmatter

### Terminal Access
Agents with terminal access can:
- Run git commands (fetch, diff, status)
- Execute test commands
- Run lint/format tools
- **Never** make destructive changes without approval

---

## Standards Reference

All agents reference and enforce standards from:
- **`.github/copilot-instructions.md`** - Primary developer guidelines
- **Project-specific configs** - ESLint, Prettier, TypeScript, Tailwind
- **Nx workspace conventions** - Library boundaries, naming, structure

When standards conflict with prompts, agents will:
1. Follow documented standards
2. Explain the conflict
3. Ask for clarification if needed