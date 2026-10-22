# Command Reference

All commands and flags for the spec-driven delivery workflow.
Print this file for a quick desk reference.

---

## Core Pipeline

```
CONTRACT ──► PLAN ──► IMPLEMENT ──► REVIEW ──► CLOSEOUT ──► SONAR
  Gate A       Gate B    Gate C        Gate D     Gate E
```

---

## run contract

Start a new ticket. Fetches the ticket, drafts acceptance criteria and constraints, produces `prompt.md` and `index.md`.

```
run contract ticket=PROJECT-123
run contract ticket=PROJECT-123 --review
run contract ticket=PROJECT-123 output_dir=/path/to/repo/workflow/PROJECT-123
run contract ticket=PROJECT-123 context=/path/to/extra-context.md
```

| Input | Required | Description |
|---|---|---|
| `ticket` | Yes | Ticket ID (`PROJECT-123`) or full Jira URL |
| `output_dir` | No | Where to write artifacts. Defaults to `workflow/PROJECT-123/` |
| `context` | No | Path(s) to additional context files (comma-separated) |
| `--review` | No | Immediately chains a contract review after stage completes |

**Artifacts produced:** `prompt.md`, `index.md`

---

## run plan

Break the contract into ordered, atomic tasks. Produces `plan.md`.

```
run plan
run plan ticket=PROJECT-123
run plan --review
run plan --premortem
```

| Input | Required | Description |
|---|---|---|
| `ticket` | No | Falls back to `workflow/.active-workflow.md` if omitted |
| `output_dir` | No | Defaults from active workflow |
| `context` | No | Path(s) to additional context files |
| `--review` | No | Chains a full plan review (risk, gaps, premortem) after stage completes |
| `--premortem` | No | Chains a premortem-only pass after stage completes (lighter than `--review`) |

**Artifacts produced:** `plan.md`

---

## run implement

Execute plan tasks one at a time. Journals to `handoff.md` and `test.md`. Commits after each approved task.

```
run implement
run implement --inspect
run implement ticket=PROJECT-123
run implement context=/path/to/file.md
```

| Input | Required | Description |
|---|---|---|
| `ticket` | No | Falls back to `workflow/.active-workflow.md` if omitted |
| `output_dir` | No | Defaults from active workflow |
| `context` | No | Path(s) to additional context files |
| `--inspect` | No | Enables per-task expectation gates for code-change tasks (see below) |

**`--inspect` mode:**
Before each task the agent classifies it:
- **Code-change task** (add, create, modify, wire up): agent states what it expects to produce before coding, confirms the diff matches after, waits for your approval before committing.
- **Pass-through task** (run build, run tests, validate, lint): agent executes, logs PASS/FAIL, continues automatically — no gate.

**Artifacts produced:** `handoff.md`, `test.md` (updated after each task); commits per task

---

## run review

Full diff review against the contract. Produces `pull-request.md`. Blocks closeout if critical issues remain.

```
run review
run review ticket=PROJECT-123
```

| Input | Required | Description |
|---|---|---|
| `ticket` | No | Falls back to `workflow/.active-workflow.md` if omitted |
| `output_dir` | No | Defaults from active workflow |
| `context` | No | Path(s) to additional context files |

**After stage completes**, the agent assesses the diff and reminds you of optional focused passes:

| Invocation | What it covers |
|---|---|
| `use the security-review skill` | OWASP, auth, secrets, input validation, dependency safety |
| `use the performance-review skill` | Core Web Vitals, bundle impact, hot-path analysis |
| `use the simplification-review skill` | Complexity reduction, Chesterton's Fence, Rule of 500 |

The agent will recommend which (if any) are warranted based on the diff. All are optional.

**Artifacts produced:** `pull-request.md`

---

## run closeout

Education pass on the diff. Extracts lessons learned and proposes promotions to the kit.

```
run closeout
run closeout ticket=PROJECT-123
```

| Input | Required | Description |
|---|---|---|
| `ticket` | No | Falls back to `workflow/.active-workflow.md` if omitted |
| `output_dir` | No | Defaults from active workflow |
| `context` | No | Path(s) to additional context files |

**Artifacts produced:** updates `handoff.md` with lessons; proposes additions to `lessons-learned.md`

---

## run sonar

SonarQube / code quality integration pass. Run after CI passes and the PR number is known.

```
run sonar pr_number=456
```

| Input | Required | Description |
|---|---|---|
| `pr_number` | Yes | GitHub PR number (available after pushing the branch) |

---

## Spike Pipeline

For research tasks without a defined implementation path.

```
run spike-contract ticket=PROJECT-123
run spike-investigate
run spike-review
```

| Command | Inputs | What it does |
|---|---|---|
| `run spike-contract` | `ticket`, `output_dir`, `context` | Scopes the research task, produces a spike contract |
| `run spike-investigate` | `ticket`, `output_dir` | Executes the research |
| `run spike-review` | `ticket`, `output_dir` | Finalizes and summarizes findings |

---

## Optional Mid-Stage Skills

Invoke any of these between stages. Not part of the required pipeline.

| Invocation | Best used after | What it does |
|---|---|---|
| `grill-me on the contract` | contract | Stress-tests the spec — challenges assumptions before planning |
| `grill-me on the plan` | plan | Challenges the approach before implementation starts |
| `use the branch-review skill` | implement | Pre-flight two-axis review (standards + spec) before formal review |
| `use the tdd skill on <task>` | during implement | Test-first scaffolding for a specific task |
| `use the fork-session skill` | any stage | Hands off state to a fresh session when approaching context limits |

> The agent suggests `grill-me` automatically after contract and plan if it detects ambiguity, risk, or conflicting constraints. You decide whether to run it.

---

## Common Patterns

**Standard ticket, no flags:**
```
run contract ticket=PROJECT-123
run plan
run implement
run review
run closeout
run sonar pr_number=456
```

**High-risk ticket with all review gates:**
```
run contract ticket=PROJECT-123 --review
grill-me on the contract
run plan --review
grill-me on the plan
run implement --inspect
run review
use the security-review skill
use the performance-review skill
run closeout
```

**Resume after interruption:**
Each `run X` reads `workflow/.active-workflow.md` automatically — just run the next stage and it picks up where you left off.

**Override artifact location (per-repo work):**
```
run contract ticket=PROJECT-123 output_dir=/path/to/repo/workflow/PROJECT-123
```
Subsequent stages inherit `output_dir` from `.active-workflow.md` automatically.
