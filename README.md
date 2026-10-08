# Spec-Driven Delivery Kit

Evidence-gated, ticket-driven workflow infrastructure for AI coding agents.

```
CONTRACT ──► PLAN ──► IMPLEMENT ──► REVIEW ──► CLOSEOUT ──► SONAR
  Gate A       Gate B    Gate C        Gate D     Gate E
```

Each stage produces artifacts. Each gate requires human approval before the next stage begins. No stage is skipped.

---

## Workflow Commands

Run these from your workspace root after install. Each command loads the right agent and prompt automatically.

### Core pipeline

| Command | Stage | What it does |
|---|---|---|
| `run contract ticket=PROJECT-123` | Contract | Fetches the ticket, drafts acceptance criteria, constraints, and a Strategic Contract. Produces `prompt.md` and `index.md`. |
| `run plan` | Plan | Breaks the contract into atomic, ordered tasks. Produces `plan.md` with a Perf-Gate flag and story points. |
| `run implement` | Implement | Executes plan tasks one at a time, journals to `handoff.md` and `test.md`, commits after each task, waits for approval before proceeding. |
| `run review` | Review | Full diff review against the contract. Produces a structured findings report. Blocks promotion if critical issues remain. |
| `run closeout` | Closeout | Education pass on the diff, extracts lessons learned, proposes global promotions to the kit. |
| `run sonar` | Sonar | SonarQube / code quality integration pass. |

### Flags

| Flag | Applies to | Effect |
|---|---|---|
| `--review` | `contract`, `plan` | Chains a fresh-eyes review immediately after the stage completes. |
| `--premortem` | `plan` | Chains a premortem-only risk analysis after plan completes. |
| `ticket=PROJECT-123` | `contract` | Ticket ID or full Jira URL. |
| `output_dir=/path` | any | Override where artifacts are written. Defaults to `workflow/PROJECT-123/`. |
| `context=/path/to/file` | `implement` | Load additional context files before executing. |

### Spike workflow

| Command | What it does |
|---|---|
| `run spike-contract ticket=PROJECT-123` | Scopes a research task. Produces a spike contract. |
| `run spike-investigate` | Executes the spike research. |
| `run spike-review` | Finalizes and summarizes spike findings. |

### Optional mid-stage skills

These are not part of the required pipeline but can be invoked between stages.

| Invocation | When to use |
|---|---|
| `grill-me on the contract` | After contract — stress-test the spec before committing to a plan. |
| `grill-me on the plan` | After plan — challenge the approach before implementation starts. |
| `use the branch-review skill` | Before `run review` — optional pre-flight: two-axis review of the full diff. |
| `use the tdd skill on <task>` | During implement — test-first scaffolding for a specific task. |
| `use the fork-session skill` | When approaching context limits — hands off state to a fresh session. |

> The agent will suggest `grill-me` at the end of contract and plan stages if it detects ambiguity, conflicting constraints, or high delivery risk. You decide whether to run it.

---

## Quick Start

### 1. Install into a workspace

```bash
cd /path/to/spec-driven-delivery-kit
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all
```

### 2. Update an existing workspace after kit changes

```bash
# Preview what will change
./reinstall.sh /path/to/workspace --dry-run

# Apply
./reinstall.sh /path/to/workspace
```

`reinstall.sh` overwrites all kit-managed files. It never touches `workflow/` ticket data.

> **Before reinstalling:** back up any hand-edited files inside `.github/`, `.copilot/`, or workspace-root `AGENTS.md` — those will be overwritten. Per-repo overrides (files inside individual repos) are never touched.

### 3. Start a ticket

Open a session from your workspace root or any child directory:

```
run contract ticket=PROJECT-123
```

Artifacts land at `workflow/PROJECT-123/`. To place them inside a specific repo instead:

```
run contract ticket=PROJECT-123 output_dir=/path/to/repo/workflow/PROJECT-123
```

Full install and migration details — including computer migration and per-repo overrides — live in **`install/INSTALL.md`**.

---

## Workspace Shape

After install, the workspace exposes these paths. AI tools (Claude Code, Copilot, etc.) discover them by walking up the directory tree from wherever you invoke them.

```
workspace/
  AGENTS.md               Agent registry and standing consent
  TAGS.md                 Hashtag taxonomy for workflow artifacts
  CLAUDE.md               Project-specific commands (Tests, Build, Dev server)
  .github/
    agents/               Agent definitions (.agent.md)
    prompts/              Stage prompts (.prompt.md)
    skills/               Reusable skills (SKILL.md)
    how-to/               Human-readable workflow guides
    policies/             Standing consent and governance docs
    templates/            Artifact templates (index.md, PR structure)
    references/           Notation guides (EARS, ADR format)
  .copilot/
    copilot-instructions.md
  workflow/
    PROJECT-123/
      prompt.md           Immutable contract (ACs, constraints)
      plan.md             Ordered task list with Perf-Gate flag
      handoff.md          Per-task journal (success, friction, state)
      test.md             Evidence log (PASS/FAIL per task)
      index.md            Ticket summary and artifact index
    .active-workflow.md   Recovery anchor — current stage and ticket
    TAGS.md               Workflow-level tag reference
```

`workflow/` is always a real local directory, never symlinked — ticket artifacts never write back into the kit source.

---

## Kit Source Layout

```
templates/base/     Core files installed into a workspace.
extensions/         Optional extensions (worklog, cleanup, codex).
install/            Installer scripts and INSTALL.md.
docs/               Kit documentation and style guides.
examples/           Public-safe examples only.
```

Optional extensions installed with `--all`:

| Extension | Installs | Purpose |
|---|---|---|
| `worklog` | `worklog/`, `.github/skills/worklog/` | Daily log and dashboard for session notes |
| `cleanup` | `scripts/cleanup/` | Workspace cleanup scripts |
| `codex` | `scripts/codex/` | Codex MCP helper scripts |

---

## Token Efficiency

The kit is designed to minimize tokens loaded per session and per stage.

- **Stage isolation** — each `run X` is a fresh invocation. The `.active-workflow.md` anchor recovers ticket state without reloading full context.
- **Tail-only handoff** — agents read only the last 40 lines of `handoff.md`, not the full journal.
- **On-demand loading** — `lessons-learned.md`, `copilot-instructions.md`, templates, and references are loaded only when the stage that needs them runs.
- **Compaction trigger** — when `handoff.md` exceeds 50 lines, the Compactor agent condenses it. Accuracy degrades past 100K tokens; use `fork-session` before you get there.

| | This kit | GitHub Spec Kit |
|---|---|---|
| Implement prompt | ~110 lines | 222 lines |
| Plan prompt | ~159 lines | 170 lines |
| Contract prompt | ~250 lines | 345 lines |
| Token budgeting | Explicit (80K/stage) | None |
| Partial artifact loading | Yes (handoff.md tail-only) | No |
| Stage recovery | `.active-workflow.md` anchor | Reload from scratch |

---

## Per-Repo Overrides

If a specific repo under the workspace needs different instructions than the shared defaults, drop a local file inside that repo:

- `AGENTS.md` — overrides the workspace-level agent registry
- `CLAUDE.md` — project-specific build/test/dev-server commands (always per-project)

AI tools pick the closest file first. The installer never touches files inside individual repos.

---

## Private Overlays and Archives

Keep reusable workflow machinery separate from private work history.

```
spec-driven-delivery-kit/          Reusable kit source (this repo).
spec-driven-delivery-overlay/      Project/team-specific instructions.
workflow-archive-private/          Real ticket artifacts and worklog history.
```

Do not publish real Jira tickets, private worklog history, raw logs, credentials, or internal URLs in a public kit.

---

## Spec File Style

Prompts, agents, and skills are written in an imperative style optimized for model parsing — numbered steps, explicit conditionals, variable interpolation. This is intentional.

When editing or adding spec files, follow `docs/spec-file-style-guide.md`. Targets: prompts ≤ 120 lines, agents ≤ 80 lines, skills ≤ 60 lines.

---

## Further Reading

- `install/INSTALL.md` — fresh install, reinstall, computer migration
- `docs/spec-file-style-guide.md` — how to write and edit prompts, agents, and skills
- `docs/structure.md` — source-vs-installed model in depth
- `templates/base/.github/how-to/howToUse.md` — daily use reference (installed into workspace)
