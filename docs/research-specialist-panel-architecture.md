# Research: Specialist Panel Architecture

Exploring a multi-agent collaboration kit where a standing panel of specialists
(Contractor, Planner, Implementer, Reviewer) stays engaged for the full ticket
lifecycle — deliberating before each decision rather than handing off sequentially.

Captured: 2026-10-11

---

## Four Multi-Agent Approaches

A map of all currently identified approaches, from simplest to most complex.

### Approach 1 — Current kit (baseline)
**One terminal. Human is the orchestrator.**

Human triggers each stage (`run contract`, `run plan`, etc.), approves every gate,
and decides when to invoke optional skills. Agents are stateless between runs.
No inter-agent communication — the human carries context between stages.

- Complexity: low
- Infrastructure needed: none beyond the current kit
- Best for: standard single-ticket work, full human oversight

---

### Approach 2 — tmux
**Multiple panes. Automated or semi-automated message passing.**

tmux runs multiple terminal panes in one session. Each pane is an independent
Claude Code (or Codex) session. The orchestrator pane can use `tmux send-keys`
to inject instructions directly into worker panes — removing the copy-paste step.

```
┌─────────────────────┬──────────────────────┐
│   Orchestrator      │   Worker A           │
│   (reads outboxes,  │   (checks inbox,     │
│    writes inboxes,  │    does task,        │
│    routes via       │    writes outbox)    │
│    send-keys)       ├──────────────────────┤
│                     │   Worker B           │
│                     │   (same pattern)     │
└─────────────────────┴──────────────────────┘
```

tmux and the relay file pattern (see Approaches 3 and 4) are not mutually exclusive.
tmux is the display and navigation layer; relay files are the communication layer.
The orchestrator writes to `relay/worker-a/inbox.md` AND uses `send-keys` to
notify the worker pane that a new instruction is waiting.

- Complexity: medium
- Infrastructure needed: tmux, relay directory, orchestrator prompt with send-keys logic
- Best for: same-machine multi-agent work where you want a unified view of all agents

---

### Approach 3 — 1-repo orchestration
**2-3 terminals. Orchestrator + 1 or 2 worker agents in the same repo.**

One orchestrator terminal manages one or two worker agents working on the same
codebase. Workers specialize (e.g., one implements, one reviews in parallel) and
communicate with the orchestrator through a relay directory at the workspace root.

```
workspace/
  relay/
    worker-a/inbox.md    worker-a/outbox.md
    worker-b/inbox.md    worker-b/outbox.md
    orchestrator/log.md
  .github/  (kit files)
  workflow/  (ticket artifacts)
  [repo files]
```

**Orchestrator loop:**
1. Read both outboxes — what did each worker just finish or get blocked on?
2. Decide: can worker B proceed, or does it need worker A's output first?
3. Write to the relevant inbox with the next instruction
4. Optionally notify via tmux send-keys

Workers check their inbox before each task and write to outbox when done or blocked.

- Complexity: medium-high
- Infrastructure needed: relay directory, orchestrator prompt, worker agent prompts
- Best for: tickets where two specialists can genuinely work concurrently
  (e.g., implementer building + reviewer shadowing in real time)

---

### Approach 4 — 2-repo orchestration (producer / consumer)
**3 terminals. Orchestrator managing two agents in separate repos.**

Documented above in the Multi-Repo Variant section. One agent builds a product
(API, library, service), the other consumes it (client, integration, app). The
orchestrator owns the interface contract between them and sequences work so the
consumer is never blocked by an unstable producer interface.

- Complexity: high
- Infrastructure needed: relay directory at workspace root above both repos,
  `interface.md` shared contract, orchestrator prompt
- Best for: the rare scenario where two repos have an actively changing interface
  and need to be developed in lockstep

---

### Summary

| Approach | Terminals | Repos | Human role | Infrastructure |
|---|---|---|---|---|
| Current kit | 1 | 1 | Orchestrator | None |
| tmux | 2-3 | 1-2 | Supervisor | tmux + relay dir |
| 1-repo orchestration | 2-3 | 1 | Supervisor | relay dir + orchestrator prompt |
| 2-repo orchestration | 3 | 2 | Supervisor | relay dir + interface.md + orchestrator prompt |

The specialist panel architecture described in the rest of this document is an
evolution of Approach 3 — the 1-repo orchestration — with a richer deliberation
protocol (team-notes.md, briefing.md, convene/express classification).

---

## What Category Is Each Kit?

These are real distinctions in the AI agent ecosystem:

### Current kit — Human-Orchestrated Workflow Kit
Also called: **prompt scaffolding**, **workflow kit**, **human-in-the-loop pipeline**

- Human is the orchestrator — you trigger each stage
- Agents are stateless between runs (fresh context each `run X`)
- Sequential: each stage depends on the last
- Human approves every gate
- Agents assist; humans decide

Examples in the wild: GitHub Spec Kit, this kit, most `.claude/commands/` setups

### Proposed kit — Specialist Panel / Multi-Agent Collaboration Framework
Also called: **crew-based architecture**, **society of agents**, **multi-agent debate**, **specialist panel**

- Agents are persistent across the ticket lifecycle — each holds its specialty role
- Agents communicate with each other, not just with the human
- Deliberative: the panel confers before each major action
- Human supervises outcomes rather than orchestrating steps
- Agents coordinate; humans course-correct

Examples in the wild: CrewAI, Microsoft AutoGen, pstack `/swarm`, LangGraph agent graphs

These are genuinely different products. The current kit is scaffolding. The proposed kit is a coordination layer.

---

## The Architecture

### The panel

| Role | Specialty | Owns | Never touches |
|---|---|---|---|
| **Contractor** | Requirements, ACs, constraints | `prompt.md`, `index.md` | `plan.md`, code |
| **Planner** | Task decomposition, sequencing | `plan.md` | `prompt.md`, code |
| **Implementer** | Code execution | commits, `handoff.md`, `test.md` | `prompt.md`, `plan.md` |
| **Reviewer** | Standards, correctness, risk | `pull-request.md`, review findings | — reads everything |
| **Orchestrator** | Routing, convening, state | `team-notes.md`, `.active-workflow.md` | code, specs |

### How deliberation works

The key difference from the current kit: before the Implementer acts on each task,
the Orchestrator convenes the other three. They each append their read to
`team-notes.md`. The Orchestrator synthesizes a briefing. The Implementer acts on
the briefing, not just plan.md.

```
[Implementer completes task N]
        ↓
[Orchestrator reads handoff.md + team-notes.md]
        ↓
[Convenes panel: Reviewer flags risk, Planner adjusts task N+1, Contractor confirms AC still holds]
        ↓
[Orchestrator synthesizes briefing for task N+1]
        ↓
[Implementer acts on briefing]
```

The panel doesn't always need to meet. The Orchestrator decides:
- **Express**: no flags from any specialist → Implementer gets next task immediately
- **Partial convene**: one specialist has a concern → only that specialist + affected role respond
- **Full convene**: Reviewer flags something that touches the spec → all three deliberate

### Shared state: team-notes.md

All agents read and append to this file. It is the communication bus.

Proposed format per entry:
```markdown
## [Role] — Task N — [timestamp]
**Read:** one sentence on current state
**Concern:** specific issue, or "none"
**Recommendation:** what should change, or "proceed"
```

The Orchestrator reads all current entries before synthesizing the next briefing.

---

## What It Would Take to Build

### Layer 1 — Specialist agent definitions
Five `.agent.md` files with strict specialty discipline. Each agent's write-allow
paths are locked to only the files it owns. This prevents a Planner from accidentally
modifying `prompt.md` or a Reviewer from touching `plan.md`.

This is the same mechanism the current kit uses — just extended to five agents with
tighter path constraints.

### Layer 2 — Shared state protocol
`team-notes.md` needs a defined format that all agents can write to and the
Orchestrator can parse reliably. The format above is a starting point.

Also needed: a `briefing.md` that the Orchestrator writes before each Implementer
task — the synthesized output of the panel deliberation. The Implementer reads this
instead of reading team-notes.md directly.

### Layer 3 — Orchestrator prompt
The most complex piece. The Orchestrator needs to:
1. Read `team-notes.md` and `handoff.md` after each Implementer task
2. Classify: express / partial convene / full convene
3. If convening: invoke the right specialists (via `@Role` mentions or sequential
   sub-prompts), collect their entries, synthesize `briefing.md`
4. Hand off to Implementer with the briefing

This is essentially the `poteto-mode` pattern from pstack — a router that reads
state, decides who needs to speak, and coordinates the output.

### Layer 4 — Installation model
Same as the current kit: a set of files installed into a workspace via an installer
script. The panel agents, shared state templates, and orchestrator prompt live in
`templates/base/.github/agents/` and `templates/base/.github/prompts/`.

A separate kit repo (`specialist-panel-kit` or similar) inheriting the artifact
model from this kit (same `prompt.md`, `plan.md`, `handoff.md`, `test.md` structure)
but replacing the sequential stage prompts with the panel orchestration layer.

### Layer 5 — Convening mechanism
The hardest part. In Claude Code, the Agent tool can spawn subagents with isolated
context windows. An orchestrator could theoretically spawn the Reviewer, collect its
output, spawn the Planner, collect its output, synthesize — all within one
orchestrator turn.

Without the Agent tool (e.g., in Codex CLI), the convening has to be file-based:
the Orchestrator writes a `convene-request.md`, each specialist reads it and appends
to `team-notes.md` in sequence, the Orchestrator reads back and synthesizes.
More manual but works across any CLI.

---

## CLI Compatibility

### Claude Code
Best fit. The Agent tool supports spawning subagents with isolated contexts, which
maps directly to the panel model. Each specialist could be a true subagent rather
than a persona switch. The Orchestrator runs in the main context; specialists run in
isolated subagent contexts.

Limitation: subagents don't share the parent's context — all state must flow through
files. This is actually fine for this architecture since `team-notes.md` and
`briefing.md` are the intended communication channels.

### Codex CLI (OpenAI)
Workable with the file-based convening model. Codex doesn't have an Agent tool
equivalent for spawning subagents, so the Orchestrator would need to invoke
specialists sequentially via prompt chaining rather than true parallel spawning.
The deliberation is slower but the output is the same.

Codex's strength: strong code execution, good at following procedural prompts. The
specialist discipline (Implementer only touches code, Planner only touches plan.md)
maps well to its instruction-following.

### GitHub Copilot
More limited. Copilot doesn't support multi-agent coordination natively. Could work
for the Implementer role only, with the other specialists running in Claude Code or
Codex. A hybrid setup where the panel deliberates in Claude Code and the Implementer
executes in Copilot is plausible but adds coordination overhead.

### Multi-CLI setup (most powerful)
Route by strength:
- **Contractor + Reviewer**: Claude Code (strongest reasoning, best at spec analysis)
- **Planner**: Claude Code or Codex (both handle task decomposition well)
- **Implementer**: Codex CLI (strong code execution, good at following briefings)
- **Orchestrator**: Claude Code (needs the Agent tool for subagent spawning)

---

## Compared to Existing Frameworks

| Framework | Model | Closest to |
|---|---|---|
| **CrewAI** | Role-based crews, sequential or parallel tasks | This architecture directly |
| **AutoGen** | Agent conversations, human-in-the-loop optional | Panel deliberation model |
| **LangGraph** | Graph-based agent state machines | Orchestrator routing logic |
| **pstack /swarm** | Multi-agent with coordinator | Orchestrator + specialists |
| **Current kit** | Human-orchestrated sequential | Nothing in this table |

The proposed kit is closest to CrewAI's model but file-native (no Python framework
dependency) and installed into a workspace like the current kit.

---

## Key Design Decisions to Resolve

**1. When does the panel convene vs. express?**
The Orchestrator needs clear rules. Proposal: the Reviewer always gets a voice after
any task touching auth, external APIs, or data persistence. All others: express by
default unless a specialist has explicitly flagged a concern in team-notes.md.

**2. Does the Implementer read briefing.md or team-notes.md?**
briefing.md — the Implementer should act on synthesized guidance, not raw deliberation.
team-notes.md can grow large; briefing.md is reset per task.

**3. How does the Orchestrator avoid over-convening?**
Token cost is real. A full panel deliberation before every task is expensive. The
express / partial / full classification needs to be fast — the Orchestrator should be
able to make the call from a 20-line read of team-notes.md, not a full context load.

**4. What happens when specialists disagree?**
The Orchestrator synthesizes — it doesn't put the conflict to a vote. If Reviewer
says "this approach is risky" and Planner says "the plan is fine," the Orchestrator
escalates to the human rather than picking a side. Human decision, then proceed.

**5. Is this a new repo or a mode of this kit?**
New repo. The collaboration model is different enough that the install, the agent
definitions, and the orchestration prompts warrant their own source. But the artifact
model (prompt.md, plan.md, handoff.md, test.md) is shared — this kit's templates
become a dependency, not a competitor.

---

## Open Questions

- Can Claude Code's Agent tool be used reliably enough for the subagent spawning
  pattern, or does the file-based convening model need to be the primary path?
- What is the right token budget per panel deliberation? Full convene should probably
  cap at 20K tokens total across all specialists.
- Should the Orchestrator be a Claude Code agent definition, or a Claude Code
  slash command that the human invokes between tasks?
- Is there value in a "shadow reviewer" that reads every Implementer commit in real
  time without convening — just appending low-priority flags to team-notes.md for
  the next full convene?

---

## Multi-Repo Variant: Producer / Consumer

A rarer but real scenario: two agents working in separate repos simultaneously —
one building a product the other consumes (e.g., an API and its client, a library
and its integration).

The orchestrator manages the dependency relationship between them: the consumer
can't proceed until the producer delivers a stable interface. The orchestrator's
job is to sequence work so the consumer is never blocked, and to propagate interface
changes from producer to consumer when the contract shifts.

### Relay structure

With three terminals (orchestrator + two workers), the natural communication bus
is a shared relay directory at the workspace root above both repos:

```
workspace/
  relay/
    producer/
      inbox.md    ← orchestrator writes assignments
      outbox.md   ← producer writes status, blockers, and interface decisions
    consumer/
      inbox.md    ← orchestrator writes assignments
      outbox.md   ← consumer writes status, blockers, and integration questions
    orchestrator/
      log.md      ← running record of routing decisions
  interface.md    ← shared contract between producer and consumer; orchestrator owns
  producer-repo/
  consumer-repo/
```

Each agent checks its `inbox.md` before starting work and writes to `outbox.md`
when done or blocked. The orchestrator reads both outboxes to get a unified view,
updates `interface.md` when the producer changes its contract, and writes to inboxes
to dispatch next instructions. The human supervises the orchestrator only — not the
two workers directly.

### Key difference from the single-repo panel

In the single-repo panel, all agents share the same artifact files (prompt.md,
plan.md, etc.). In the multi-repo variant, each worker has its own ticket artifacts
inside its own repo. The shared state lives only in `relay/` and `interface.md`.
The orchestrator is the only agent that reads across both repos.

### When this matters

Only worth setting up when the two repos have an active, changing interface — e.g.,
the producer is defining an API while the consumer is implementing against it. For
stable interfaces where the contract is already known, two independent terminals
running the standard kit (no relay) is simpler and sufficient.

---

## Suggested Next Steps

1. Sketch `team-notes.md` and `briefing.md` formats in detail
2. Write the Orchestrator prompt — just the convene/express classification logic
3. Test the file-based convening model manually on one ticket using the current kit
   as a base (simulate the panel by switching agents manually)
4. Evaluate Claude Code Agent tool reliability for subagent spawning on a throwaway
5. Decide: new repo now, or wait until step 3 reveals the real friction points
