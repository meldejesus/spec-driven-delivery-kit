# Architecture Review — Invocation, Naming, and Integration

A deeper look at how the kit's agents, prompts, and skills fit together — and where the architecture is working against itself.

---

## The Three-Layer Invocation Problem

The kit currently has three distinct invocation surfaces, and they don't feel like one system:

| Layer | How you invoke it | Example |
|---|---|---|
| **Prompts** (first use) | Verbose: agent + path + inputs | `Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md` |
| **Prompts** (subsequent) | Short command | `run plan` / `run implement` |
| **Skills** | Name reference | `use the sonar-check skill` or `/code-review` |

The `run X` shortcuts are good — but they only activate *after* the contract stage creates `.active-workflow.md`. The very first invocation is still the full verbose form. A first-time user sees that wall of text and doesn't know which parts matter, which parts are boilerplate, and which parts differ between CLIs.

The underlying tension: the agent+prompt split made sense for VS Code's native agent mode, where the editor reads `.agent.md` frontmatter and auto-binds an agent to a prompt file. In Claude Code and Codex CLI, that binding doesn't happen automatically — the user has to supply both files manually, every time.

There's an additional tell in the architecture: `workflow-contract.prompt.md` already declares `agent: Architect` in its frontmatter. The relationship is defined in the file. The user shouldn't need to re-declare it on the command line.

---

## Suggestion: Collapse to a Single Invocation Surface

**Make `run X` work from the very first command**, and let the dispatcher resolve agent + prompt internally.

The simplest implementation: add a `run` resolution table to `CLAUDE.md` (and AGENTS.md for other CLIs):

```md
## Workflow Commands

`run contract ticket=<ID>` → Architect + workflow-contract.prompt.md
`run plan`                 → Plan-Agent + workflow-plan.prompt.md
`run implement`            → Implementer + workflow-implement.prompt.md
`run review`               → Reviewer + workflow-review.prompt.md
`run closeout`             → Architect + workflow-closeout.prompt.md
`run sonar pr_number=<N>`  → Reviewer + workflow-sonar.prompt.md
```

Then `run contract ticket=PROJECT-123` is the first command, not the verbose form. The active-workflow.md gets created as normal. Everything subsequent still works with `run plan`, `run implement`, etc.

This means:
- One consistent verb (`run`) for the entire ticket lifecycle
- No need to remember file paths or agent names during ticket work
- Skills stay separate (`use the X skill` or `/X`) — they're off the main workflow track

For CLIs that don't support CLAUDE.md resolution (Codex, Copilot), the prompt frontmatter already has `agent:` declared. Adding a `commands:` block to the frontmatter lets each CLI that supports it auto-resolve the same way:

```yaml
---
name: contract
agent: Architect
commands: ["run contract"]
---
```

---

## The Agent + Prompt Split: Worth Keeping?

The split was designed so agent identity (who the agent is) stays stable while procedures (what it does each stage) can evolve independently. That's a real benefit — the Architect's constraints, prohibitions, and re-entry protocol don't need to change every time the contract procedure gets refined.

But there's a cost: the user has to mentally maintain a mapping between agents and the stages they run. Most users don't need to know that `@Architect` runs both `workflow-contract` and `workflow-closeout`. They just need to know `run contract` and `run closeout`.

**Keep the split for authors, hide it from operators.** The `.agent.md` and `.prompt.md` files stay as they are — they're the right unit for maintenance. But the operator interface (how you invoke a stage) should not expose this split. The `run X` dispatcher is the abstraction layer that hides it.

One concrete improvement: the `target: vscode` field in `architect.agent.md` frontmatter signals that the agent is optimized for VS Code. Claude Code and Codex don't read this field — they need explicit tool permission guidance. Either remove `target:` from agent files and make them CLI-neutral, or add `target: claude-code` variants.

---

## The `.active-workflow.md` State Machine

Currently `.active-workflow.md` stores:

```md
ticket: PROJECT-123
output_dir: workflow/tickets/PROJECT-123
last_completed_stage: contract
next_stage: plan
```

This is passive — it records where you are but doesn't drive what happens next. When a user types `run plan`, the `workflow-plan.prompt.md` reads the file to know the ticket and output directory. The file doesn't tell the CLI *how* to run plan.

**Make it an active state machine.** After each stage completes, write the exact next command(s) into the file:

```md
# Active Workflow
ticket: PROJECT-123
output_dir: workflow/tickets/PROJECT-123
last_completed_stage: contract
stage_status: awaiting-gate-a

## Available Next Commands

run plan
  → Plan-Agent reads workflow-plan.prompt.md
  → Requires: Gate A approval above

run contract ticket=PROJECT-123 (redo)
  → Restart contract if scope changes

## Completed Stages
- contract (2026-08-13)
```

Now `run next` can work too — it reads the available commands and runs the first one. Session recovery after a context reset is also easier: the user types `run next` and the state file tells the CLI exactly what to do without needing to remember where they were.

---

## The Review Naming Problem

The kit has three review mechanisms that share a name but do different things:

| Name | Where | What it actually does |
|---|---|---|
| `workflow-review` prompt | Gate D of the ticket workflow | Audits your own implementation against the contract — AC coverage, severity findings, writes `pull-request.md` |
| `pr-review` prompt | Standalone | Reviews a *teammate's* PR by URL — fetches diff, produces GitHub-ready comment |
| `code-review` skill | Pocock layer (`/implement` calls it) | Two-axis quality check (Standards + Spec) against a commit/branch fixed point |

The confusion compounds because:
- `workflow-review` and `pr-review` both produce "a review of code" — the distinction (own vs. teammate's) is real but not obvious from the name
- `code-review` skill is invoked *inside* `/implement` automatically in the Pocock flow, so a user on the Pocock path gets a code review after every implement cycle — but a user on the ticket workflow path gets it only at Gate D via `workflow-review`
- If a user is mid-ticket-workflow and types `use the code-review skill`, they get a Pocock-style two-axis review that bypasses Gate D entirely

**Suggested renaming:**

| Current | Rename to | Invocation |
|---|---|---|
| `workflow-review` | Keep `run review` as command; rename artifact to *Implementation Audit* | `run review` |
| `pr-review` | Keep as `pr-review` (already clear); surface it as `run peer-review pr_url=<URL>` | `run peer-review` |
| `code-review` skill | Keep in Pocock layer; add a note that it's *not* Gate D | `use the code-review skill` or `/code-review` |

The real fix isn't just renaming — it's disambiguation in AGENTS.md. Add a "Which review to use" section:

```
Gate D (your own ticket): run review
Teammate's PR: run peer-review pr_url=<URL>
Branch quality check outside a ticket: use the code-review skill
```

---

## The Two Parallel Workflows Problem

The kit has two complete workflow systems sitting alongside each other:

**System A — Ticket workflow** (main kit):
```
run contract → run plan → run implement → run review → run closeout
```
Designed around Jira tickets, evidence gating, contract immutability, and audit trail.

**System B — Pocock skills flow** (ask-matt):
```
/grill-with-docs → /to-spec → /to-tickets → /implement (with /tdd + /code-review inside)
```
Designed around exploratory ideation, spec synthesis, and test-first implementation.

These two systems aren't in conflict — they cover different phases of work. System B is great for ideation and spec authoring before a ticket exists. System A is great for executing against a ticket that already has requirements. They could be sequential: System B → handoff to → System A.

But right now the kit doesn't explain how they connect. A user discovering `ask-matt` doesn't know when to switch to the ticket workflow. A user in the ticket workflow doesn't know that `/grill-with-docs` exists for exploring new feature ideas.

**Suggestion: Define the on-ramp between systems.**

Add a short section to `spec-driven-workflow.md`:

```md
## Two Entry Points

### Starting from a Jira ticket (ticket-first)
Use the ticket workflow: run contract → run plan → ...

### Starting from an idea (idea-first)
Use the exploration flow first:
/grill-with-docs → /to-spec → /to-tickets

The /to-tickets output produces agent-ready issues.
File the highest-priority one as a Jira ticket, then start the ticket workflow from there.

Or, for small work that doesn't need a ticket:
/to-tickets → /implement (Pocock flow handles the full cycle)
```

This gives users a clear decision: "do I have a ticket?" If yes, go to the ticket workflow. If no, start with the Pocock exploration flow and come back.

---

## Context Auto-Loading

Every workflow prompt currently requires the user to manually specify context files if the defaults aren't enough (`context=file.md`). There's no mechanism for a prompt to declare its own dependencies and load them automatically.

Amazon Kiro's "hooks" solve this: when a spec file changes, the hook fires automatically and updates dependent artifacts. The kit doesn't need hooks for everything, but it could borrow the concept of **declared dependencies in prompt frontmatter**:

```yaml
---
name: workflow-plan
agent: Plan-Agent
auto-read:
  - workflow/tickets/${ticket}/prompt.md
  - workflow/tickets/${ticket}/pre-context.md
  - .github/lessons-learned.md
  - .github/copilot-instructions.md
---
```

The prompt runner (whether Claude Code, Copilot, or Codex) reads `auto-read` and loads those files before the agent sees the prompt body. No user action required. The user only needs to specify `context=` for *additional* files beyond the declared defaults.

This is a CLi-implementation detail — whether `auto-read` is natively supported depends on the CLI. But declaring the dependencies in frontmatter is still useful: it documents what each stage expects, making the prompt files self-describing, and a CLI that supports the field gets the auto-load for free.

---

## Skills as First-Class Workflow Citizens

Currently skills are invoked informally: "use the X skill on Y." There's no structured way to call a skill from within a prompt or agent definition. The `code-review` skill is called from within `/implement` — but only in the Pocock layer; there's no equivalent mechanism in the ticket workflow.

**Consider making skills callable from within prompts.** The ticket workflow's `workflow-implement.prompt.md` could declare:

```yaml
---
post-task-hooks:
  - skill: tdd (if test file exists)
  - skill: sonar-check (if CI results available)
---
```

This is aspirational (requires CLI support), but the architecture should point toward it. Today, `sonar-check` is noted in AGENTS.md as running automatically inside `workflow-review` — but this is by convention in the prompt body, not a declared dependency. Making it explicit gives CLIs something to act on and makes the workflow more inspectable.

---

## The `infer: false` vs `infer: true` Distinction

Looking at the agent frontmatter: advisory agents (`Architect`, `Reviewer`) use `infer: false`, meaning they don't try to infer next steps autonomously — they follow the prompt exactly and stop at gates. Implementation agents (`Implementer`, `targeted-writer`) use `infer: true`.

This is a good pattern, but it's currently only documented in the agent files themselves. Users don't know this is the mechanism that enforces gate behavior. If `infer: false` is lost or overridden, gates stop working.

**Suggestion:** Document the `infer` flag in the authoring guide and explain that it's what makes gates real. Any agent with `infer: false` cannot proceed past a stopping point without an explicit user continuation. This is the enforcement mechanism — not just a stylistic choice.

---

## Condensed Action List

These are additions to the items in `kit-review-2026.md`:

| # | What | Why |
|---|---|---|
| A1 | Add `run contract ticket=<ID>` as the canonical first command (resolve via CLAUDE.md dispatcher) | Eliminates the verbose first invocation; consistent with `run plan`, `run implement` |
| A2 | Make `.active-workflow.md` an active state machine with next-command declarations | Enables `run next`; survives context resets; self-documenting |
| A3 | Rename/disambiguate the three review mechanisms in AGENTS.md with a "which review to use" decision table | Stops workflow-review/code-review/pr-review collisions |
| A4 | Add a "two entry points" section to `spec-driven-workflow.md` explaining when to use ticket-first vs. idea-first (Pocock) | Surfaces the Pocock layer as a deliberate on-ramp, not a mystery |
| A5 | Add `auto-read:` to prompt frontmatter to declare stage dependencies | Self-documenting prompts; auto-load for supporting CLIs |
| A6 | Remove or make conditional `target: vscode` from agent files | Agents should be CLI-neutral; VS Code specifics belong in a `.vscode/` config, not the agent definition |
| A7 | Document `infer: false` / `infer: true` in the authoring guide | Makes gate enforcement visible and intentional, not implicit |
| A8 | Add a skills callability pattern to `workflow-implement.prompt.md` | Connects the ticket workflow to skills (tdd, sonar-check) the way the Pocock layer already does |
