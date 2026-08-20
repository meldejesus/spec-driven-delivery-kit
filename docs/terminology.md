# Terminology Reference

Canonical definitions for the spec-driven delivery kit and AI-assisted software engineering in general.

---

## Core Kit Terms

**Contract**
A Strategic Contract is the gate-A artifact written by the Architect after researching a ticket. It defines: what is being built, acceptance criteria (in EARS notation), scope boundaries, risk assessment, and a reproduction guide. It is the authoritative source of truth for the implementation — not the ticket.

**Plan**
The gate-B artifact written by Plan-Agent. An ordered list of atomic, testable tasks that implement the contract. Each task is a thin tracer bullet (cuts through all layers), has a clear done-when condition, and declares blocking edges (dependencies on other tasks).

**Handoff**
`handoff.md` — the rolling evidence journal written by Implementer after each task. Records what was done, test output, deviations from plan, and decisions. The Compactor agent summarizes it when it grows too long.

**Gate**
A human approval checkpoint in the pipeline. There are four:
- **Gate A** — Contract approved before planning
- **Gate B** — Plan approved before implementation
- **Gate C** — Pivot approval if a task fails 3× during implementation
- **Gate D** — Review findings approved before closing the PR

**Index**
`index.md` in each `workflow/<ticket-id>/` directory. Obsidian-compatible YAML frontmatter (aliases, tags, description) plus links to the contract, plan, handoff, and PR. Used for keyword search and Dataview queries.

**Active Workflow**
`workflow/.active-workflow.md` — agent-maintained state file. Records the current ticket, output directory, last completed stage, next stage, and available next commands. Lets any stage prompt recover context without re-reading the whole handoff.

---

## Skill vs. Workflow

**Skill**
A reusable, self-contained capability with one bounded job. Stateless between invocations — invoked, does its job, hands back a result. Examples: `tailwind-check`, `branch-review`, `message-clarity`.

**Workflow**
A multi-step process with state, ordering, gates, and artifact handoffs between stages. Each stage's output becomes the next stage's input. Example: contract → plan → implement → review → closeout.

The practical tell: if you can describe the task as "do X" it's a skill. If you need "do X, then based on the result either Y or Z, and keep track of where we are," it's a workflow.

---

## Broader AI Patterns

**Tool / Function-calling**
The atomic layer. A single callable capability — run this query, call this API, execute this code. Skills are curated bundles of tool-use + instructions; workflows chain tool calls across steps.

**Autonomous Agent (agentic loop)**
Instead of a predefined sequence, the agent decides what to do next in a perceive → plan → act → observe loop. The steps are not fixed in advance — the agent figures out its own path toward a goal.

**Orchestrator–Worker (multi-agent)**
One orchestrator agent decomposes a task and dispatches subtasks to specialized sub-agents (coding, review, test), then integrates results. The decomposition is dynamic, not a fixed pipeline.

**Evaluator-Optimizer (reflection loop)**
An agent generates output; a second pass critiques it against criteria; the first revises. Useful where first-try reliability is low (code correctness, security review).

**RAG (retrieval-augmented generation)**
A grounding technique — pulling in relevant context (docs, codebase, tickets) before generating, so the agent reasons over current, specific information rather than training-data memory alone. Can be used by any of the above.

**Human-in-the-Loop / Approval Gate**
A mandatory checkpoint where a person approves before the agent proceeds. Layered on top of a workflow or agent loop. The spec-driven kit uses four named gates (A/B/C/D).

---

## Where These Patterns Appear in the Kit

| Kit artifact | Pattern |
|---|---|
| `run contract` / `run plan` / etc. | Workflow (fixed sequence, stateful, gated) |
| `branch-review`, `tailwind-check` | Skills (bounded, single-purpose) |
| Architect researching codebase before drafting | RAG |
| Gate A / B / C / D | Human-in-the-loop |
| Implementer stopping on 3× failure (Gate C) | Evaluator-optimizer signal |
| Compactor summarizing handoff | Skill invoked by workflow |

---

## EARS Notation

Structured requirement pattern for acceptance criteria. Five types:

| Type | Pattern |
|---|---|
| Ubiquitous | The `<system>` shall `<action>` |
| Event-driven | When `<trigger>`, the `<system>` shall `<action>` |
| State-driven | While `<state>`, the `<system>` shall `<action>` |
| Unwanted behavior | If `<condition>`, then the `<system>` shall `<response>` |
| Optional feature | Where `<feature is included>`, the `<system>` shall `<action>` |

---

## Tag Taxonomy

Tags in `index.md` frontmatter use three prefix types. See `workflow/TAGS.md` for the canonical list.

| Prefix | Purpose | Example |
|---|---|---|
| `area/` | Business domain | `area/auth`, `area/payments` |
| `type/` | Work category | `type/bug`, `type/feature`, `type/spike` |
| `component/` | Code component (free-form PascalCase) | `component/LoginForm` |
