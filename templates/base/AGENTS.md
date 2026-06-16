# 🤖 Agent & Prompt Reference

> Quick reference for every agent and prompt in the system.
> For full workflow walkthroughs, see `.github/how-to/howToUse*.md` files.
> For the workflow concept, see `.github/how-to/spec-driven-workflow.md`.
> Standard ticket stages after Contract can use `run plan`, `run implement`, `run review`, and `run closeout` from `workflow/tickets/.active-workflow.md`.

When this file is maintained inside the standalone kit repository, install or
symlink the kit into the active project workspace before opening an agent there.
Agents discover `AGENTS.md`, `.github/`, and `.copilot/` from the active
workspace, not from a sibling kit repo. See `README.md` for install commands.

---

## Standing Consent

Agents have standing consent to perform in-scope, non-destructive, non-billable work inside this workspace. This includes reading/searching files, editing project files for the requested task, running local tests/lint/format/build commands, creating temporary files, and starting/stopping local dev servers.

Agents must ask before destructive actions, changes outside the workspace, credential or permission changes, deployments, force pushes, database migrations against shared/non-local environments, paid/billable external services, or unusually expensive long-running tasks.

This repo policy does not override runtime sandbox, network, or security approval prompts. If the tool layer requires explicit approval, agents must request it.

When a runtime approval is required for an in-scope, non-destructive, non-billable action that is likely to recur, agents should ask for narrowly scoped reusable pre-approval if the tool supports it. Do not request reusable pre-approval for destructive actions, credential or profile edits, deployments, force pushes, shared database migrations, paid services, broad shell/interpreter access, or commands that write files unless the user explicitly asks for that scope.

## Agents

Agents are defined in `.github/agents/`. Each has a role, tools, and rules.
Invoke by mentioning them by name with a prompt file.

| Agent                      | Role                                                                                                                                                                                | Definition                                        |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `@Architect`               | Drafts Strategic Contracts, researches tickets, extracts lessons. Stays strategic — never produces code.                                                                            | `.github/agents/architect.agent.md`               |
| `@Plan-Agent`              | Converts an approved contract into an atomic, testable `plan.md`. Tactical layer only.                                                                                              | `.github/agents/plan-agent.agent.md`              |
| `@Implementer`             | Executes `plan.md` task by task, journals every step to `handoff.md`, stops for human approval on pivots.                                                                           | `.github/agents/implementer.agent.md`             |
| `@Reviewer`                | Reviews code diffs and PRs. Produces severity-rated findings and a GitHub-ready comment. Read-only — never edits files.                                                             | `.github/agents/reviewer.agent.md`                |
| `@targeted-writer`         | Approval-gated code writer. Plans first, waits for confirmation, then applies surgical or multi-file changes.                                                                       | `.github/agents/targeted-writer.agent.md`         |
| `@Message-Writer`          | Turns dense technical source material into clearer messages for technical, mixed, or non-technical audiences. Writes only under `workflow/messages/**` when file-backed output is requested. | `.github/agents/message-writer.agent.md`          |
| `@Educator`                | Explains a completed implementation to a junior dev — code flow, trade-offs, hard decisions, plan deviations.                                                                       | `.github/agents/educator.agent.md`                |
| `@Architect` (promotion)   | After review, extracts generalizable lessons and proposes updates to global instructions.                                                                                           | `.github/agents/architect.agent.md`               |
| `@Compactor`               | Summarizes and compacts `handoff.md` when it grows too long. Preserves audit trail.                                                                                                 | `.github/agents/compactor.agent.md`               |
| `@merge-conflict-resolver` | Resolves merge conflicts, preserving intent of both branches.                                                                                                                       | `.github/agents/merge-conflict-resolver.agent.md` |
| `@Legacy-Dev`              | Starts a legacy/backend dev environment using project-discovered commands.                                                                                                          | `.github/agents/legacy-dev.agent.md`              |
| `@Mobile-Dev`              | Starts a mobile dev environment using project-discovered commands.                                                                                                                  | `.github/agents/mobile-dev.agent.md`              |
| `@pointing-analyst`        | Reviews backlog or unassigned Jira tickets against docs/codebase, then writes skim-friendly ticket assessments, readiness notes, and estimates.                                     | `.github/agents/pointing-analyst.agent.md`        |
| `@Spike-Investigator`      | Works through spike research sources, journals findings, produces a structured output document.                                                                                     | `.github/agents/spike-investigator.agent.md`      |

---

## Prompts

Prompts live in `.github/prompts/`. Files are grouped by prefix.

### `workflow-*` — Main development pipeline
Used in order for a standard ticket. See `.github/how-to/howToUse.md` for the full walkthrough.

| Prompt                         | What it does                                                                                          |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `workflow-contract.prompt.md`  | Fetches Jira ticket, creates searchable `index.md`, researches codebase, drafts Strategic Contract + reproduction guide. **Gate A.** |
| `workflow-plan.prompt.md`      | Converts approved contract into atomic `plan.md` + `codebase-scan.md`. **Gate B.**                    |
| `workflow-implement.prompt.md` | Runs implementation task by task, journals handoff + evidence after each. Stops on failures.          |
| `workflow-review.prompt.md`    | Reviews diff + AC coverage + lint. Produces severity-rated findings + PR description. **Gate D.**     |
| `workflow-closeout.prompt.md`  | Runs education first, then promotion candidates. Standard post-review closeout step.                  |
| `workflow-promote.prompt.md`   | Standalone promotion step for global lesson candidates. Usually called through closeout.              |
| `workflow-educate.prompt.md`   | Standalone mentoring walkthrough of the completed implementation. Usually called through closeout.    |
| `workflow-sonar.prompt.md`     | Queries SonarQube post-CI. States PASSED or BLOCKED. Hands off fixes to `@targeted-writer`.           |

### `spike-*` — Research / spike workflow
Used for time-boxed research tickets. See `.github/how-to/howToUse-spike.md`.

| Prompt                        | What it does                                                                                    |
| ----------------------------- | ----------------------------------------------------------------------------------------------- |
| `spike-contract.prompt.md`    | Fetches spike ticket, creates searchable `index.md`, drafts scope document with question, boundaries, and sources. **Gate A.** |
| `spike-investigate.prompt.md` | Works through sources, journals findings, writes structured output document.                    |
| `spike-review.prompt.md`      | Reviews spike output — checks question was answered, findings are grounded, gaps are honest.    |

### `pr-review-*` — Reviewing someone else's PR
Used to review a teammate's PR from a GitHub URL. See `.github/how-to/howToUse-codeReview.md`.

| Prompt                       | What it does                                                                                                  |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `pr-review-triage.prompt.md` | Fetches PR file list + ticket ACs. Produces risk table and context summary. Optional gate before full review. |
| `pr-review.prompt.md`        | Full multi-stage review: context + testing guide → code review (parallel) → verdict + GitHub comment.         |

### `message-*` — Dense docs to clear communication
Used to turn one or more technical source documents into a clearer message. See `.github/how-to/howToUse-message.md`.

| Prompt                       | What it does                                                                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `message-workflow.prompt.md` | Reads source docs and a request, then runs approach → outline → draft → review → lessons. Defaults to conversation-only; can write under `workflow/messages/**`. |

### `pointing-*` — Ticket assessment / pointing prep

| Prompt                    | What it does                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------ |
| `pointing-plan.prompt.md` | Reviews backlog tickets, compares them to docs/codebase, and writes lightweight proto-contract assessment reports. |

### Dev environment starters

| Prompt                       | What it does                                                               |
| ---------------------------- | -------------------------------------------------------------------------- |
| `legacy-dev-start.prompt.md` | Starts a legacy/backend dev environment after discovering local commands. |
| `mobile-start.prompt.md`     | Starts a mobile dev environment after discovering local commands.         |

### Standalone tools

| Prompt                     | What it does                                                  |
| -------------------------- | ------------------------------------------------------------- |
| `quality-audit.prompt.md`  | Audits code quality across a file or component.               |
| `tech-debt-scan.prompt.md` | Scans for tech debt patterns and produces a prioritized list. |
| `fix-docs-index.prompt.md` | Repairs and updates the docs index file.                      |

---

## Workflow Chains

Workflow artifacts should use the directory that matches the work:

| Workflow type | Output directory |
| ------------- | ---------------- |
| Implementation ticket | `workflow/tickets/<ticket-id>/` |
| Ticket assessment / pointing prep | `workflow/pointing/<ticket-or-batch>.md` |
| Spike / research ticket | `workflow/spikes/<ticket-id>/` |
| Review of someone else's PR | `workflow/code-review/<repo>-pr-<number>/` |
| Durable message draft | `workflow/messages/<message-name>/` |

### Ticket assessment / pointing prep
```
@pointing-analyst → pointing-plan
    ↓
skim issue summary, docs/codebase signals, estimate, readiness, next workflow
    ↓
standard ticket workflow, spike workflow, backlog clarification, split/merge, or defer
```

### Standard ticket
```
@Architect → workflow-contract
    ↓ (Gate A: you approve contract)
@Plan-Agent → workflow-plan
    ↓ (Gate B: you approve plan)
@Implementer → workflow-implement
    ↓ (Gate C: pivot approval if task fails 3×)
@Reviewer → workflow-review
    ↓ (Gate D: approve or request changes)
@Architect → workflow-closeout
→ Push PR → workflow-sonar (after CI)
```

### Spike
```
@Architect → spike-contract
    ↓ (Gate A: you approve scope)
@Spike-Investigator → spike-investigate
@Reviewer → spike-review
    ↓ (Gate D: approve or request changes)
@Educator → workflow-educate   (optional)
→ File follow-up tickets (optional)
```

### PR review (teammate's PR)
```
@Reviewer → pr-review-triage   (optional, for large PRs)
    ↓ confirm scope
@Reviewer → pr-review
    ↓ (you go test while code review runs)
→ report results → verdict + GitHub comment
```

### Message workflow
```
@Message-Writer → message-workflow
    ↓ (approve/revise approach)
outline
    ↓ (approve/revise outline)
draft → review → final message → lessons learned
```

---

## Skills

Skills are self-contained tools invoked by name — no prompt file or agent prefix needed.

| Skill                  | When to use                                                                                    | Invocation                                                   |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `sonar-check`          | SonarQube code quality + coverage check on a file, component, or PR                            | `use the sonar-check skill on <file or PR>`                  |
| `tailwind-check`       | Tailwind CSS audit — arbitrary values, unapproved colors, token fixes                          | `use the tailwind-check skill on <file>`                     |
| `docs-audit`           | Run the docs health audit and fix audit-config/source-map findings                             | `use the docs-audit skill to run the audit`                  |
| `docs-refresh`         | Refresh existing docs from stale-doc requests or doc-specific audit findings                   | `use the docs-refresh skill on docs/<doc-name>.md`           |
| `docs-review`          | Review docs audit findings or content-fit candidates without editing files                     | `use the docs-review skill to review content-fit candidates` |
| `copilot-chat-cleanup` | Remove old VS Code Copilot chat threads (dry-run first, confirm before delete)                 | `use the copilot-chat-cleanup skill`                         |
| `private-workspace-archive` | Archive private workspace state into `workflow-archive-private` before cleanup or reinstall | `use the private-workspace-archive skill`                    |
| `private-workspace-restore` | Restore private workspace state from `workflow-archive-private` after reinstalling the kit | `use the private-workspace-restore skill`                    |

> `tailwind-check`, `docs-audit`, `docs-refresh`, `docs-review`, `private-workspace-archive`, and `private-workspace-restore` are defined in `.github/skills/`. `sonar-check` and `copilot-chat-cleanup` are built-in project skills.
> Both `sonar-check` and `tailwind-check` run automatically inside `workflow-review` and `pr-review` — you only need to invoke them standalone for one-off audits.
