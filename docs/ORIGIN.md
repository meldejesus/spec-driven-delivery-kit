# Origin: The Sovereign Context Engine

This document records the research and thinking that motivated the spec-driven-delivery-kit. The ideas here have since been built out into the kit's agents, prompts, skills, and workflow artifacts.

---

## The Core Insight

The early research framed the problem as: AI chat windows are ephemeral. Once a thread grows long, the model forgets the beginning. The solution was to move the AI's "memory" out of the chat window and into transparent, human-readable Markdown files stored in the repository — giving the human a permanent "kill switch" and "steering wheel."

The operating principle: **"The System is the Memory. The Markdown is the Code."**

---

## Foundational Concepts (What Crystallized)

These ideas emerged from the research and became the kit's core primitives:

| Concept | Definition | Kit Artifact Today |
|---|---|---|
| **The Contract** | An immutable agreement of what is being built. Prevents scope creep. If the goal changes, the session ends and a new contract is drafted. | `workflow/tickets/<id>/prompt.md` |
| **The Blueprint** | A task list the AI must follow. Proves the agent understands the path before it touches code. | `workflow/tickets/<id>/plan.md` |
| **The Live Diary** | Real-time log of successes and failures. The "short-term memory" of the task. | `workflow/tickets/<id>/handoff.md` |
| **The Scorecard** | Evidence log mapping every task to a test result. No task is "done" until verified here. | `workflow/tickets/<id>/test.md` |
| **Altitude Control** | Humans handle Strategy (the What). AI handles Tactics (the How). The contract stays at the right altitude — intent, not micro-management. | Enforced by `@Architect` agent |
| **Context Compaction** | Every 5–10 tasks, the agent summarizes `handoff.md` to preserve the context window and prevent "token fog." | `@Compactor` agent |
| **Promotion** | After a PR closes, recurring lessons from `handoff.md` move into the project's global DNA (`CLAUDE.md`). The project's "IQ" increases over time. | `workflow-closeout` prompt |
| **Checkpoint Gates** | Human approval required at: (A) Contract, (B) Plan, (C) Pivot after 3 failures. No agent "runs away" with a bad plan. | Gates A–D in workflow |

---

## The Role Model (Early Personas)

Three roles defined in the original research:

- **The Architect** — Strategic leader. Researches the codebase, drafts the contract, guards the "why." Motto: "Measure twice, cut once."
- **The Reviewer** — Skeptic. Breaks the code, checks the logs, drafts the PR. Motto: "Show me the evidence."
- **The Implementer** — Workhorse. Fast, iterative, focused on checking off `plan.md`. Motto: "Get it done."

These became the named agents now defined in `.github/agents/`.

---

## The Backtrack Protocol

Formalized early as a recovery mechanism when an agent gets stuck:

1. If a task fails 3+ times, stop the agent.
2. Log the failure in `handoff.md`.
3. Mark the task `[FAILED]` in `plan.md`.
4. Propose a "New Path" for human approval before resuming.

---

## Evolution Log

The research iterated through several named versions before stabilizing:

- **v1.0** — Initial concept. `prompt.md` as an immutable contract. Three-phase pipeline: Research → Plan → Execute.
- **v1.3** — Added altitude control (from Anthropic engineering docs) and context compaction. Formalized the `handoff.md` structure.
- **v1.6** — Added human checkpoint gates, "Similar Issue Search" (scan past handoffs before starting a new contract), auto-commit hook logic.
- **v2.4** — Added orchestration matrix: Local / Subagent / Background / Cloud tiers. Added "Glass Box Trace" requirement — agents must explain *why* a path was chosen, not just what was done.
- **v3.x** — Added AGENTS.md as native registry, compactor as a dedicated agent, skills library concept, worktree isolation.
- **Kit** — All of the above formalized into installable templates, 13+ named agents, 30+ prompts, 30+ skills, and a full workflow artifact structure.

---

## Key Resources from the Research Phase

- *AI Agents in Action* — Michael Lanham (Manning, 2025) — best introductory overview
- *Context Engineering for Multi-Agent Systems* — Denis Rothman (Packt, 2025) — technical foundation for the handoff/context engine logic
- *AI Engineering* — Chip Huyen (2025) — infrastructure of reliable AI products
- Nate Jones (YouTube / Substack) — "Markdown-based workflows" closest spiritual match to the original system design
- Anthropic Engineering Blog — altitude control and context compaction principles
- GitHub Engineering Blog — agentic primitives, CLI runtimes, scoped context via `applyTo`
