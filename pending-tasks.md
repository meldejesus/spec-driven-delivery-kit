---
created: 2026-08-21
updated: 2026-10-10
---

# Pending Tasks — spec-driven-delivery-kit

---

## Priority

### 1. Specialist panel kit — next steps

Research doc: `docs/research-specialist-panel-architecture.md`

Suggested order:
- [ ] Sketch `team-notes.md` and `briefing.md` formats
- [ ] Write Orchestrator prompt — convene/express classification logic only
- [ ] Simulate the panel manually on one real ticket (switch agents by hand, no new infrastructure)
- [ ] Evaluate Claude Code Agent tool for subagent spawning on a throwaway project
- [ ] Decide: new repo or continue simulating

Hold until at least 3-4 tickets run through the current kit. The friction points will
clarify what the panel actually needs to solve.

---

### 3. Audit generated workflow artifacts

Review each file the kit generates per ticket to confirm it still earns its place. Files to audit:
- `prompt.md` — immutable contract
- `plan.md` — task list + Perf-Gate flag
- `handoff.md` — per-task journal
- `test.md` — evidence log
- `index.md` — ticket summary (least clearly used downstream — check which stages load it)
- `pull-request.md` — PR synthesis
- `.active-workflow.md` — recovery anchor

Questions to answer: Is `index.md` read by any stage after contract? Does `test.md` provide enough signal at review time, or should it be structured differently?

---

## Carry-forward (from 2026-08-21 — completed 2026-10-11)

All three tasks below were completed and can be removed on next cleanup pass.

Three small tasks to complete when back on the coding machine.
The `.claude/commands/` files are already in `templates/base/` and will be there when you pull.

---

## 1. Update the install script

In `install/install-to-workspace.sh`, add one line after the `.copilot` install:

```bash
install_path "$kit_root/templates/base/.claude" "$target/.claude"
```

Also add `.claude/` to the usage/help block under "Core install paths":
```
.claude/            Claude Code slash commands (/contract, /plan, /implement, /workflow-review)
```

---

## 2. Add Claude Code Commands section to AGENTS.md

Add this section after the Skills table:

```markdown
## Claude Code Commands

For Claude Code users, slash commands in `.claude/commands/` dispatch directly
to the right prompt without copy-pasting the full invocation.

| Command             | Dispatches to                      | Equivalent to                          |
|---------------------|------------------------------------|----------------------------------------|
| `/contract [ticket]`   | `workflow-contract.prompt.md`   | `@Architect #read workflow-contract`   |
| `/plan [ticket]`       | `workflow-plan.prompt.md`       | `@Plan-Agent #read workflow-plan`      |
| `/implement`           | `workflow-implement.prompt.md`  | `@Implementer #read workflow-implement`|
| `/workflow-review [ticket]` | `workflow-review.prompt.md` | `@Reviewer #read workflow-review`   |

All commands fall back to `workflow/.active-workflow.md` if no ticket is provided.

> `/workflow-review` is intentionally named to avoid collision with Claude Code's
> built-in `/review` command. Use `/review` for quick diff-only review;
> use `/workflow-review` for full contract-traced, evidence-gated review.
```

---

## 3. Add Skills 12/13 pointer to message-clarity

In `.github/skills/message-clarity/SKILL.md`, add at the bottom:

```markdown
## When This Skill Is Not Enough

`message-clarity` is a lightweight conversational rewrite — 5 steps, chat output.
For rigorous audience translation or systematic explanation-debt elimination, use
the writing kit's dedicated skills instead:

- **Skill 12: Non-Technical Audience Translation** — full procedure with audience
  modeling, dependency ordering, and fidelity verification. Use when the piece
  needs to reach a reader with no domain background.
- **Skill 13: Clarity Loop Revision** — iterative elimination of explanation debt.
  Use when an argument must be followable step-by-step by a newcomer.

Writing kit: `github.com/meldejesus/writing-kit`
```

---

## Context

These changes close the Claude Code usability gap identified in the Aug 2026
workflow review session. The four command files already exist in:
`templates/base/.claude/commands/` — contract.md, plan.md, implement.md, workflow-review.md
