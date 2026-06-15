# Ticket-Driven Spec-Driven Workflow

This workspace uses a form of spec-driven development, but the specs are not the files in `.github/agents/` or `.github/prompts/`.

Those folders are the workflow infrastructure:

- `.github/agents/` defines the roles that act on the work.
- `.github/prompts/` defines the repeatable stage instructions.
- `AGENTS.md` is the registry and quick reference.
- `.github/how-to/` explains how to run and maintain the workflow.
- `workflow/tickets/.active-workflow.md` stores the active ticket and output directory so later stages can run from short commands.

## Kit Source vs Installed Workspace

When this workflow is stored in a standalone kit repository, the kit is only the
source of truth. The active project workspace still needs installed copies or
symlinks for the files that agents discover automatically:

```text
AGENTS.md
.github/
.copilot/
workflow/
```

Most CLIs and editor agents read instructions from the current directory or its
parents. They generally do not discover `.github/` from a sibling repository.

Install the kit into an active workspace before running ticket work:

```bash
./install/install-to-workspace.sh --target /path/to/workspace
```

Use `--all` to also install helper folders such as `scripts/`, `standup/`, and
`messages/`.

The actual specs are the per-ticket artifacts produced during a run:

- `.active-workflow.md` - active workflow pointer under `workflow/tickets/`
- `index.md` - searchable ticket front door with metadata, summary, terms, links, paths, and artifact map
- `prompt.md` - Strategic Contract
- `reproduce.md` - reproduction and QA guide
- `plan.md` - atomic implementation plan
- `codebase-scan.md` - codebase-specific planning notes
- `handoff.md` - execution journal
- `test.md` - evidence log
- `pull-request.md` - PR synthesis
- `overview.md` - mentoring walkthrough
- `lessons-learned.md` - promotion candidates

The best short label for this system is:

> ticket-driven, evidence-gated spec-driven development

That name is more accurate than "context engineering" because the workflow is not just about supplying context. It turns a ticket into a contract, turns that contract into a plan, requires evidence for each acceptance criterion, and gates promotion of reusable lessons.

## Why It Exists

The goal is repeatable, auditable Jira-to-PR delivery.

Without this workflow, agent work tends to drift:

- Requirements get reinterpreted during implementation.
- Tests are run but not tied back to acceptance criteria.
- Review comments lack enough context to judge risk.
- Lessons from one ticket are forgotten on the next ticket.

This workflow preserves state in markdown so a human, agent, reviewer, or future session can reconstruct what happened and why.

## The Main Flow

```text
Setup
  -> Contract
  -> Plan
  -> Implement
  -> Review
  -> Closeout
  -> Push PR
  -> Sonar
```

The standard agent chain is:

```text
@Architect
  -> @Plan-Agent
  -> @Implementer
  -> @Reviewer
  -> @Architect closeout
     -> education overview
     -> promotion candidates
```

The standard prompt chain is:

```text
workflow-contract
  -> workflow-plan
  -> workflow-implement
  -> workflow-review
  -> workflow-closeout
  -> workflow-sonar
```

After `workflow-contract` creates the active workflow file, the normal commands are:

```text
run plan
run implement
run review
run closeout
```

Extra context can be added inline, for example:

```text
run review but also consider workflow/tickets/PROJECT-123/manual-test-notes.md
```

## Gates

| Gate | Stage | Human decision |
|---|---|---|
| A | Contract | Is the Strategic Contract correct enough to plan from? |
| B | Plan | Does the task plan cover the contract without changing scope? |
| C | Pivot | A task failed 3 or more times. Should the agent take a new path? |
| D | Review | Is the diff, evidence, and PR summary ready? |

The gates are the main difference between this workflow and a normal "ask the agent to fix it" session. The agent can execute, but it should not silently redefine the problem.

## Artifact Ownership

| Artifact | Owner | Purpose |
|---|---|---|
| `workflow/tickets/.active-workflow.md` | Workflow | Active ticket, output directory, and next stage pointer |
| `index.md` | Architect | Searchable ticket directory front door: ID, title, summary, keywords, paths, links, artifact map |
| `prompt.md` | Architect | Immutable contract: scope, ACs, constraints, risks, evidence strategy |
| `reproduce.md` | Architect | Reproduction and manual verification guide |
| `plan.md` | Plan-Agent | Atomic tasks mapped to ACs and evidence |
| `codebase-scan.md` | Plan-Agent | File-level implementation notes discovered during planning |
| `handoff.md` | Implementer | Progress journal after every task |
| `test.md` | Implementer | Evidence log tied to tasks and ACs |
| `pull-request.md` | Reviewer | PR description and review synthesis |
| `overview.md` | Closeout / Educator | Junior-dev explanation of the final implementation |
| `lessons-learned.md` | Closeout / Architect | Candidate project rules to promote |

## How To Explain It To Someone

Use this framing:

> We use agents as role-based workflow participants, not as one giant coding assistant. A Jira ticket first becomes a Strategic Contract. The contract is approved before planning. The plan is approved before coding. Implementation updates a handoff and evidence log after every task. Review checks the contract, plan, diff, and evidence together. Only reusable lessons are promoted into global instructions.

The important distinction is:

- Agents and prompts are the operating system.
- Ticket artifacts are the specs.
- Human gates keep the specs from drifting.
- Evidence files make the work reviewable later.

## How This Differs From GitHub Spec Kit

GitHub Spec Kit is a general toolkit for Spec-Driven Development. Its recommended workflow includes commands such as `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.checklist`, `/speckit.plan`, `/speckit.tasks`, `/speckit.analyze`, and `/speckit.implement`.

Spec Kit also includes the `specify` CLI, project initialization, integrations, extensions, presets, and workflows.

References:

- https://github.github.com/spec-kit/
- https://github.github.com/spec-kit/quickstart.html
- https://github.github.com/spec-kit/reference/overview.html

| Area | This workspace | GitHub Spec Kit |
|---|---|---|
| Intake | Jira ticket first | Natural-language feature prompt first |
| Core artifact | `prompt.md` Strategic Contract | `spec.md` feature specification |
| Planning | `plan.md` plus `codebase-scan.md` | `plan.md`, then `tasks.md` |
| Execution | Implementer journals to `handoff.md` and `test.md` | Agent implements from generated tasks |
| Review | Reviewer gate, PR synthesis, Sonar gate | Analyze/checklist/extensions depending on setup |
| Governance | Promotion into `.github/copilot-instructions.md` or lessons docs | Constitution in `.specify/memory/constitution.md` |
| Style | Team-specific, Jira/PR lifecycle, brownfield codebase | Toolkit-driven, portable, template and preset based |

In short:

- Spec Kit is a productized SDD framework.
- This workspace is an internal SDD operating model for Jira-to-PR delivery.

## Relationship To Context Engineering

"Context engineering" is one ingredient, not the workflow name.

The workflow uses context engineering by:

- Keeping long-lived task state in markdown files.
- Loading only the artifact needed for the current stage.
- Separating global instructions from per-ticket state.
- Preserving handoff summaries so a later agent can resume.

But the workflow is broader than context management. It includes acceptance criteria, evidence, review, gates, and promotion.

## MCP In This Workflow

MCP is the integration layer that lets agents fetch outside context, especially Jira tickets, PRs, commits, and Confluence pages.

MCP does not define the workflow. It feeds the workflow.

When MCP is unavailable, the fallback is still simple: paste the missing ticket or PR context into `pre-context.md` or pass it through the `context=` parameter where supported.

See `.github/how-to/mcp-setup.md` for the concise setup notes.

## Future Automation Hooks

The old auto-commit hook stub was removed because it looked like active configuration but was only a prototype.

The idea is still useful as future work:

- Hook trigger: when an Implementer marks a `plan.md` task `[x]`
- Action: create a small checkpoint commit for the code and ticket artifacts changed by that task
- Scope: only the current ticket folder and allowed code paths
- Safety gate: never auto-commit secrets, global instruction changes, or unrelated diffs
- Commit message: derive from the task name, but allow human override

Do not implement this as a hidden side effect. If hooks are added later, document the trigger, write scope, rollback behavior, and opt-out mechanism in this file and in the relevant prompt.

## Canonical References

- Agent and prompt registry: `AGENTS.md`
- Full ticket workflow: `.github/how-to/howToUse.md`
- CLI workflow: `.github/how-to/howToUse-cli.md`
- Prompt inventory: `.github/how-to/howToUse-prompts.md`
- Agent definitions: `.github/agents/`
- Prompt definitions: `.github/prompts/`
