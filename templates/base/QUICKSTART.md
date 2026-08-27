# Quick Start — Spec-Driven Delivery Kit

You installed the kit. Here is how to run your first ticket.

---

## What This Kit Does

It turns a Jira ticket into a reviewed, merged PR through a structured sequence of AI agent stages — each one stops for your approval before continuing. No agent makes decisions alone. No implementation starts without an approved plan.

```
Your ticket
  → Contract  (what and why — you approve)
  → Plan      (how, step by step — you approve)
  → Implement (runs tasks, keeps a journal)
  → Review    (checks evidence, writes PR description — you approve)
  → Closeout  (records lessons, promotes knowledge)
  → PR merged
```

Each stage writes markdown files you can read, edit, and hand off to another session. The work is never locked inside a chat window.

---

## Before Your First Ticket

**1. Pick your CLI**

| I use | Read this guide |
|---|---|
| Claude Code (`claude`) | `.github/how-to/howToUse-claude-code.md` |
| Codex CLI (`codex`) | `.github/how-to/howToUse-codex.md` |
| GitHub Copilot CLI / Chat | `.github/how-to/howToUse-copilot-cli.md` |

**2. Confirm MCP is connected**

The Contract stage fetches your Jira ticket automatically. For that to work, the Atlassian MCP server needs to be running and authenticated. Quick check:

```bash
# Ask your AI tool to fetch one ticket — if it responds with ticket data, you're good
# If it fails, see .github/how-to/mcp-setup.md for setup steps
# If MCP isn't available yet, see the fallback note below
```

**3. Create the ticket folder**

```bash
mkdir -p workflow/PROJECT-123
```

Replace `PROJECT-123` with your actual ticket ID.

---

## Your First Ticket (5 commands)

```
run contract ticket=PROJECT-123
```
↓ Architect fetches the ticket, drafts the Strategic Contract. **Read it. Approve it.**

```
run plan
```
↓ Plan-Agent breaks the contract into tasks. **Read the plan. Approve it.**

```
run implement
```
↓ Implementer works through tasks one by one, journaling every step.

```
run review
```
↓ Reviewer checks the diff against the contract. **Approve or fix blockers.**

```
run closeout
```
↓ Records what was learned. Proposes any global rule updates. **Approve or skip.**

Then push your branch and open a PR using `workflow/PROJECT-123/pull-request.md` as the description.

---

## What Gets Created

Every stage writes files into `workflow/PROJECT-123/`:

| File | Created by | What it is |
|---|---|---|
| `index.md` | Contract | Searchable metadata — find this ticket later by keyword |
| `prompt.md` | Contract | The approved Strategic Contract — scope, ACs, constraints |
| `reproduce.md` | Contract | Step-by-step QA guide for testing the fix |
| `plan.md` | Plan | Atomic task checklist — each task ≤ 15 min |
| `codebase-scan.md` | Plan | Notes on affected files and patterns found during planning |
| `handoff.md` | Implement | Running journal — what worked, what didn't, current state |
| `test.md` | Implement | Evidence log — one entry per task, proof it passed |
| `pull-request.md` | Review | PR description, ready to paste into GitHub |
| `overview.md` | Closeout | Plain-English walkthrough for a teammate reading the code later |
| `lessons-learned.md` | Closeout | Generalizable lessons proposed for promotion |

All files are plain markdown. You can read, edit, or search them at any time.

---

## The Approval Gates

The workflow stops four times and waits for you:

| Gate | When | Your decision |
|---|---|---|
| **A** | After Contract | Is this the right scope? Does the contract match what the ticket actually needs? |
| **B** | After Plan | Does the task list cover the contract? Are the tasks in the right order? |
| **C** | If a task fails 3+ times | Should the agent try a different approach, or should you adjust the plan? |
| **D** | After Review | Is the diff clean? Are the findings acceptable? Is the PR description accurate? |

If you want to change scope after Gate A, stop — draft a new contract rather than editing `prompt.md` mid-stream. The contract is immutable once approved.

---

## No Jira Ticket? No Problem

If you're working from a feature description rather than a Jira ticket:

1. Create `workflow/FEATURE-NAME/pre-context.md`
2. Paste in: feature title, description, acceptance criteria, any constraints
3. Run: `run contract ticket=FEATURE-NAME`

The Contract stage reads `pre-context.md` automatically and uses it instead of fetching a ticket. Everything else is identical.

See `.github/how-to/howToUse-no-tracker.md` for the full guide.

---

## MCP Not Working?

If the Atlassian MCP server can't fetch your ticket, the agent will tell you and ask you to paste the ticket content. You can also pre-empt this by dropping a `pre-context.md` file before running the contract:

```bash
# Create the file with your ticket content
touch workflow/PROJECT-123/pre-context.md
# Paste in: ticket title, description, ACs, any relevant links
```

The contract stage reads `pre-context.md` first, before attempting MCP. If it's there, MCP is optional for that stage.

See `.github/how-to/mcp-setup.md` for permanent MCP setup.

---

## Other Workflows

This kit handles more than standard tickets:

| What | How to start |
|---|---|
| Research question / spike | `run spike-contract ticket=PROJECT-123` — see `.github/how-to/howToUse.md` (Spike section) |
| Review a teammate's PR | `run peer-review pr_url=<GitHub PR URL>` — see `.github/how-to/howToUse.md` (Peer Review section) |
| Backlog grooming / estimates | `run refinement tickets=PROJECT-123` — see `.github/how-to/howToUse.md` (Refinement section) |
| Merge conflict | `use the merge-conflict-resolution skill` |
| Not sure which tool to use | `use the which-skill skill` |

---

## Where Everything Lives

```
AGENTS.md                     ← Full agent and skill registry. Read this when you want
                                 to know what exists and what it does.

.github/how-to/               ← Detailed guides for every workflow
  howToUse-claude-code.md     ← Claude Code CLI guide
  howToUse-codex.md           ← Codex CLI guide
  howToUse-copilot-cli.md     ← GitHub Copilot CLI guide
  howToUse-context-md.md      ← What CONTEXT.md is and when to update it
  howToUse-no-tracker.md      ← Working without a ticket tracker
  mcp-setup.md                ← MCP server setup for all CLIs
  context-budget.md           ← Token budgeting and context management
  spec-driven-workflow.md     ← Concept doc: why the workflow is designed this way

.github/agents/               ← Agent definitions (who each agent is)
.github/prompts/              ← Stage instructions (what each agent does per stage)
.github/skills/               ← Standalone tools, invokable by name

workflow/                     ← Your ticket artifacts live here (generated, not edited)
```

---

## Getting Unstuck

**The agent seems confused or is going in circles**
→ Check `handoff.md`. If it's over 50 lines, invoke the Compactor: `use the compactor agent to summarize handoff.md`

**A task keeps failing**
→ Gate C will fire automatically after 3 failures. If it doesn't, stop the agent, read `handoff.md` to understand what failed, then edit `plan.md` to give the agent a clearer path.

**I approved the contract but now scope needs to change**
→ Do not edit `prompt.md`. Run a new contract: `run contract ticket=PROJECT-123` with a note explaining what changed. The new contract goes in `changes/cr-01/` so the original audit trail stays intact.

**I'm mid-workflow and lost context**
→ Run: `read workflow/.active-workflow.md` — it tells you the active ticket, output directory, and last completed stage. Then pick up with the next `run` command.

**I want to understand what the agents are doing**
→ Read `.github/how-to/spec-driven-workflow.md` for the philosophy, or `.github/how-to/authoring-agents-prompts-skills.md` to understand how agents, prompts, and skills are built.
