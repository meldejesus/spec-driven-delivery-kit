# Authoring Agents, Prompts, And Skills

This guide explains how to maintain the files that power the ticket-driven spec-driven workflow.

Use it when you are adding or revising:

- an agent in `.github/agents/`
- a prompt in `.github/prompts/`
- a skill in `.github/skills/`
- a how-to guide in `.github/how-to/`

## Source Of Truth

| Need | Edit this |
|---|---|
| Add or rename an agent | `.github/agents/*.agent.md`, then update `AGENTS.md` |
| Add or rename a workflow stage | `.github/prompts/*.prompt.md`, then update `AGENTS.md` and `.github/how-to/howToUse-prompts.md` |
| Explain how to run a workflow | `.github/how-to/` |
| Add a repeatable procedure | `.github/skills/<skill>/SKILL.md` |
| Add global Copilot behavior | `.github/copilot-instructions.md` or the monorepo-scoped instruction file |
| Add portable agent rules | `AGENTS.md` |

Avoid copying the same rule into several files. Prefer one source of truth and link to it.

## Agent Files

Agent files define who the agent is.

Use agent files for:

- role and responsibility
- allowed and forbidden behavior
- tool permissions
- response format
- re-entry behavior after a pause or resume

Keep agent files stable. They should not contain ticket-specific details.

Recommended structure:

```md
---
name: Example-Agent
description: One sentence that appears in the UI.
tools: [read, search]
infer: false
target: vscode
---

# Role
State the role in one short paragraph.

# Responsibilities
- What the agent owns.
- What the agent must produce.

# Constraints
- What the agent must not do.
- When the agent must stop.

# Output
Define the shape of the final response or written file.
```

## Prompt Files

Prompt files define a workflow stage.

Use prompt files for:

- inputs
- context loading
- exact stage steps
- output files
- gate behavior
- final handoff command

Prompt files can be more procedural than agent files because they are invoked for a specific task.

Recommended structure:

```md
---
name: workflow-example
description: What this stage does.
agent: Example-Agent
tools: [read, write, search]
---

# Inputs
- ticket: ${input:ticket}
- output_dir: ${input:output_dir}

# Context To Load
List the files the agent must read before acting.

# Instructions
Describe the stage work in order.

# Output
List every file to write or update.

# Stage Completion
State the gate and next command.
```

## Skills

A skill is a small, reusable procedure. It should encode work you would otherwise explain the same way every time.

Build a skill when:

- the task has project-specific rules the agent cannot infer
- the procedure is fixed but the input changes
- getting the procedure wrong has real cost
- the same instructions keep getting pasted into sessions

Do not build a skill when:

- the task is one command
- the work is highly interactive
- the task is a one-off
- the instructions belong in an existing agent or prompt instead

Good skill candidates in this workspace:

- `tailwind-check` because token replacement rules are project-specific
- `sonar-check` because SonarQube lookup and prioritization are repeatable
- `copilot-chat-cleanup` because deletion must be dry-run and approval gated

## How-To Guides

How-to files are for humans. They should answer:

- What workflow do I run?
- What command or prompt do I start with?
- What files will be created?
- Where does the workflow stop for approval?
- What do I do if a tool is unavailable?

Keep how-to files shorter than the prompt files they describe. The prompt is allowed to be procedural; the how-to should be readable.

## Writing Style

Use short, direct sections:

- Purpose
- When to use it
- Inputs
- Steps
- Outputs
- Failure path
- References

Prefer tables for ownership and artifact maps. Prefer code blocks for exact invocation text.

Avoid:

- pasted chat transcripts
- stale source links from local downloads
- duplicate copies of the same rule
- aspirational config that is not wired into the workflow
- long philosophy sections inside operational runbooks

## Context Checklist For A New Ticket

When giving an agent extra context, include only what helps the next stage:

- ticket ID or PR URL
- route, screen, API, job, or component affected
- current behavior
- expected behavior
- reproduction steps
- relevant files or line numbers
- known constraints
- commands already tried
- test or evidence expectations

For large or durable context, put it in `workflow/tickets/<TICKET>/pre-context.md`.

For one-stage context, use the `context=` parameter if the prompt supports it.

For quick notes, append plain text below the invocation.

## Code-Fix Guidance

Keep code-fix rules in the canonical instruction files, not in this how-to.

The short version for agent authors:

- keep changes minimal and focused
- preserve local patterns
- avoid new dependencies unless justified
- run the narrowest useful tests
- record evidence in the ticket artifacts when using the full workflow
- promote durable lessons only after review
