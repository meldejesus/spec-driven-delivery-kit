# Agentic Workflow — CLI Quick Reference

Pipeline: **Setup → Contract → Plan → Implement → Review → Closeout → Merge**

This is the CLI-native version of `howToUse.md`. All steps run inside the GitHub Copilot CLI terminal.
Agent personas (`Architect`, `Plan-Agent`, `Implementer`, `Reviewer`, `Educator`) are embodied by the CLI — no VS Code Chat required.

Replace `PROJECT-123` with your ticket ID throughout.

Canonical standard-ticket workflow decisions live in `.github/how-to/howToUse.md`; this file exists for CLI syntax, session setup, and CLI-specific examples.

For the concept behind this flow, see `.github/how-to/spec-driven-workflow.md`.
For MCP setup and fallback notes, see `.github/how-to/mcp-setup.md`.

---

## Install The Kit First

If these files live in a standalone kit repository, install them into the active
workspace before opening the CLI there:

```bash
cd /path/to/spec-driven-delivery-kit
./install/install-to-workspace.sh --target /path/to/workspace
```

For local kit development, use symlinks:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode symlink --all
```

Open the CLI from `/path/to/workspace`, not from the kit repository, when doing
normal ticket work.

## Steps Involved

### Session Startup

```text
/add-dir /path/to/workspace
```

### Step 1 — Create the task folder

```bash
mkdir -p workflow/tickets/PROJECT-123
```

The Contract step creates `workflow/tickets/PROJECT-123/index.md` as the first workflow-owned file.

### Step 2 — Draft Contract (Gate A)

```text
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
```

### Step 3 — Generate Plan (Gate B)

```text
run plan
```

### Step 4 — Implement

```text
run implement
```

### Step 5 — Review (Gate D)

```text
run review
```

### Step 6 — Closeout

```text
run closeout
```

### Step 7 — Push + Open PR

```bash
cd monorepo
git push origin <your-branch>
```

### Post-Push — Sonar Gate

```text
run sonar
pr_number=<PR_NUMBER>
```

### Change Request — Start A New Request

```bash
mkdir -p workflow/tickets/PROJECT-123/changes/cr-01
```

The Contract step creates `workflow/tickets/PROJECT-123/changes/cr-01/index.md` for the change request.

```text
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123/changes/cr-01

This is a change request on a completed ticket. Read the original contract at
workflow/tickets/PROJECT-123/prompt.md before drafting so you don't re-research
decisions already made.
```

---

## How CLI agents work

Instead of `@Architect #read prompt.md`, you tell the CLI which role to assume and which prompt file to follow. The CLI reads the prompt, embodies the agent's rules, and pauses at each gate with an explicit confirmation before continuing.

**Gates are enforced via interactive prompts** — the CLI will stop and ask you before proceeding to the next stage. You don't need to watch for magic phrases.

---

## Providing extra context

There are three ways to give the CLI additional information at any step. They can be combined freely.

### 1 — `context=` parameter

A formal named parameter accepted by the standard workflow prompts. Pass a single file path or a comma-separated list of **file paths** (no `@` prefix — that's VS Code Chat syntax, not CLI):

```
This work will occur in the monorepo folder.

Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
context=workflow/tickets/PROJECT-123/pre-context.md
```

The CLI reads each file and treats its contents as **authoritative developer context** — it overrides assumptions made from the ticket alone. Use it for design docs, ADRs, related tickets, API schemas, or any file the ticket description omits.

> `context=` accepts file paths only — not directories. For whole directories, use plain text after the invocation block (see below).

> `context=` is for files. For broader instructions or whole directories, use plain text after the invocation block.

### 2 — `pre-context.md` *(works at every step, automatically)*

Drop a file named `pre-context.md` in the ticket folder before any step:

```bash
# create and populate it however you like
echo "The affected route is /api/study-schedule. The DB column is hours_per_week." \
  > workflow/tickets/PROJECT-123/pre-context.md
```

Standard workflow prompts read this file automatically when it exists. Use it for durable per-ticket context that should survive every stage.

### 3 — Plain text appended to your message *(works at every step, always)*

Anything you write after the invocation block is visible to the CLI as conversational context. No special syntax required. This is also the right way to point the CLI at **whole directories**:

```
Act as Implementer following .github/agents/implementer.agent.md and .github/prompts/workflow-implement.prompt.md

The bug only reproduces when the user has 0 hours_per_week. The failing test is in
apps/legacy/tests/studySchedule.test.ts. Skip the migration step — the column already exists in staging.
```

```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
context=docs/architecture/auth.md

Also read everything in workflow/tickets/PROJECT-123/ and path/to/relevant/cache/.
```

The CLI will glob and read those directories as part of its research. You can mix both — `context=` for specific files you know matter, plain text for broader "look at this whole area" instructions.

---

## Active workflow state

The Contract step writes:

```text
workflow/tickets/.active-workflow.md
```

Later stages read that file when `ticket` or `output_dir` is omitted. This works across context resets better than chat memory alone.

**First invocation** — provide just the ticket number (short form):
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
```
The CLI auto-derives:
- `ticket` → `https://your-domain.atlassian.net/browse/PROJECT-123`
- `output_dir` → `workflow/tickets/PROJECT-123`

**With additional context file(s):**
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
context=workflow/tickets/PROJECT-123/pre-context.md
```
> `context` accepts a single file path or a comma-separated list of paths. All files are read and treated as authoritative developer context that overrides ticket-level assumptions. Useful for passing design docs, ADRs, related tickets, or any file not in the standard `pre-context.md` location.

**All subsequent steps** — use the short command:
```
run plan
```

Then continue with:

```text
run implement
run review
run closeout
```

If the CLI cannot infer the stage prompt, include the prompt once and keep the short command:

```text
Act as Plan-Agent following .github/agents/plan-agent.agent.md and .github/prompts/workflow-plan.prompt.md

run plan
```

To pass extra context:

```text
run review but also consider workflow/tickets/PROJECT-123/manual-test-notes.md
```

or:

```text
run closeout
context=workflow/tickets/PROJECT-123/qa-notes.md
```

To **switch tickets or output directories**, run Contract again with the new ticket and/or `output_dir`. That updates `workflow/tickets/.active-workflow.md`:
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-456
```

---

## Session startup (run every time you open the CLI)

Before starting any work, run this command to scope the session safely:

```
/add-dir /path/to/workspace
```

**What this does and doesn't do:**

| Operation                                       | Behavior                                                              |
| ----------------------------------------------- | --------------------------------------------------------------------- |
| File reads (view, grep, glob)                   | ✅ Auto-approved — no prompts within the workspace                     |
| File writes/edits within workspace              | ✅ Auto-approved                                                       |
| Files outside the workspace                     | 🚫 Blocked entirely                                                    |
| Shell commands (`git`, `npm`, `rm`, etc.)       | ⚠️ Still prompted — the CLI asks once per new command type per session |
| Destructive commands (`rm`, `git reset --hard`) | ⚠️ Always prompted individually                                        |

> This means read-heavy work (searching, exploring, reviewing) flows without interruption, while anything that runs a process or could modify the system still requires your approval.

> **Do not use `/allow-all`** — that also disables prompts for external network calls, which is broader than needed.

---

## Initial Setup (one-time)

No template files need to be copied per ticket. All task files, starting with `index.md`, are auto-generated by the CLI agents.

If your ticket needs task-local agent skills, manually create `workflow/tickets/PROJECT-123/skills.md`.
Use `.github/skills/complex-logic-refactoring/SKILL.md` as a format reference. This is optional.

---

## Step 1 — Create the task folder

```bash
mkdir -p workflow/tickets/PROJECT-123
```

---

## Step 2 — Draft Contract (Gate A)

**You type:**
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
```
> The CLI auto-derives `ticket=https://your-domain.atlassian.net/browse/PROJECT-123` and `output_dir=workflow/tickets/PROJECT-123` from the short ticket number.

Consider including additional context:
- Route or URL the feature lives on
- Components affected
- Known issues or edge cases
- Image of feature in staging or prod (if applicable)
- Links to related tickets or PRs
- If ticket/API loading times out, ask the agent to split long responses into smaller parts and stop after 1-2 retries so you can paste the ticket description or ACs into `pre-context.md`.

> **Pre-context shortcut:** Drop a `pre-context.md` file in `workflow/tickets/PROJECT-123/` before running this step. The Architect will read it automatically as the first research action. Use it for file paths, API routes, third-party integrations, or any constraints the ticket description omits.

**What happens:** The CLI fetches the Jira ticket (via Atlassian MCP), creates `workflow/tickets/PROJECT-123/index.md` with searchable metadata, reads `pre-context.md` from the ticket folder if present, scans `.github/archive/` for similar issues, drafts the Strategic Contract and Reproduction Guide, and writes them to `workflow/tickets/PROJECT-123/prompt.md` and `workflow/tickets/PROJECT-123/reproduce.md`.

**Gate A — CLI pauses here.** You will be asked:
> "I've initialized the ticket index and drafted the Strategic Contract and Reproduction Guide. Shall I proceed to Gate B (Plan-Agent), or do you want revisions?"

**You do:** Read `prompt.md` and `reproduce.md`. Use `index.md` to relocate the ticket later by ID, summary, terms, paths, or links. If scope looks right, confirm. If not, say what's wrong — the CLI will redraft.

---

## Step 3 — Generate Plan (Gate B)

**You type:**
```
run plan
```
> If prompt inference fails, use: `Act as Plan-Agent following .github/agents/plan-agent.agent.md and .github/prompts/workflow-plan.prompt.md`, then `run plan`.

**What happens:** The CLI reads the approved contract, breaks every AC into atomic tasks (≤15 min each), tags each task (`@local`/`@subagent`/`@background`), and writes `plan.md` and `codebase-scan.md`.

**Gate B — CLI pauses here.** You will be asked:
> "Plan is ready. Shall I proceed to implementation, or do you want to adjust the plan first?"

**You do:** Read `plan.md`. Check task order and coverage. Confirm or request adjustments.

> **Optional:** Review `workflow/tickets/PROJECT-123/codebase-scan.md` for per-file before/after context and pre-flight checklists.

---

## Step 4 — Implement

**You type:**
```
run implement
```
> The prompt reads `workflow/tickets/.active-workflow.md` for `ticket` and `output_dir`.

**What happens:** The CLI works through `plan.md` task by task. After each task it updates `handoff.md` (Success/Friction), writes evidence to `test.md`, and marks the task `[x]`. Before implementation can complete, it runs `yarn nx affected --target=build` or the narrower build command named in the plan, then records the result in `test.md`. If a task or build fails 3+ times it marks it `[FAILED]`, proposes a pivot, and pauses for your approval (Gate C).

**Gate C — CLI pauses on failures.** If a task fails 3+ times, you'll be asked to approve the pivot path before work continues.

**You do:** Watch for Gate C pivots — those need your decision. Otherwise the CLI runs to completion.

## Step 5 — Review (Gate D)

**You type:**
```
run review
```
> To add context: `run review but also consider workflow/tickets/PROJECT-123/manual-test-notes.md`.

**What happens:** The CLI reads contract + plan + handoff + test.md, verifies final build evidence from implementation, then runs `git diff`, affected build, lint, and affected tests. Outputs severity-rated findings grouped by category, then writes `pull-request.md`. Then:

- **APPROVE** — announces "Stage Complete: Review (Gate D)"
- **REQUEST CHANGES** — lists BLOCKER items with exact fix guidance

**Gate D — CLI pauses here.** You'll be asked to approve or action the findings before proceeding.

**You do:** Approve or address the findings.

---

## Step 6 — Closeout

**You type:**
```
run closeout
```
> To add context: `run closeout context=workflow/tickets/PROJECT-123/qa-notes.md`.

**What happens:** The CLI writes the education walkthrough to `overview.md`, then extracts generalizable lessons, writes task-local `lessons-learned.md`, and proposes any global instruction updates.

**Gate — CLI pauses here.** You'll be asked to approve, revise, or skip the proposed promotion diff before any global files are touched.

**You do:** Review the proposed promotion diff. Education is already captured in `overview.md`; global instruction edits remain approval-gated.

---

## Step 7 — Push + Open PR

Push your branch and open a PR in GitHub using the content from `workflow/tickets/PROJECT-123/pull-request.md` as the PR description.

```bash
cd monorepo
git push origin <your-branch>
```

> **SSH passphrase note:** If you are prompted for an SSH passphrase, enter it manually. See [SSH Keychain setup](#ssh-keychain-caching-macos) below to avoid typing it on every push.

Wait for CI to complete before proceeding.

---

## Post-Push: Sonar Gate *(~20 min after push, once CI completes)*

Once the Sonar check turns green on the PR:

**You type:**
```
run sonar
pr_number=<PR_NUMBER>
```
> `ticket` is read from active state. `pr_number` must always be provided explicitly.

**What happens:** The CLI queries SonarQube for BLOCKER/CRITICAL/MAJOR issues and coverage. States a clear **PASSED** or **BLOCKED** decision. If blocked, hands off to the `targeted-writer` agent for fixes, then re-checks after CI re-runs.

**Then:** Merge the PR once the Sonar Gate passes.

---

## File reference

| File                                            | Created by  | Auto-written?            | Gate     |
| ----------------------------------------------- | ----------- | ------------------------ | -------- |
| `workflow/tickets/.active-workflow.md`           | Workflow    | ✅ Yes                    | All      |
| `workflow/tickets/PROJECT-123/index.md`           | Architect   | ✅ Yes                    | Pre-A    |
| `workflow/tickets/PROJECT-123/pre-context.md`     | You         | ❌ Manual (optional)      | Pre-A    |
| `workflow/tickets/PROJECT-123/prompt.md`          | Architect   | ✅ Yes                    | A        |
| `workflow/tickets/PROJECT-123/reproduce.md`       | Architect   | ✅ Yes                    | A        |
| `workflow/tickets/PROJECT-123/plan.md`            | Plan-Agent  | ✅ Yes                    | B        |
| `workflow/tickets/PROJECT-123/codebase-scan.md`   | Plan-Agent  | ✅ Yes                    | B        |
| `workflow/tickets/PROJECT-123/handoff.md`         | Implementer | ✅ Yes (after every task) | —        |
| `workflow/tickets/PROJECT-123/test.md`            | Implementer | ✅ Yes                    | —        |
| `workflow/tickets/PROJECT-123/pull-request.md`    | Reviewer    | ✅ Yes                    | D        |
| `workflow/tickets/PROJECT-123/overview.md`        | Closeout    | ✅ Yes                    | Closeout |
| `workflow/tickets/PROJECT-123/lessons-learned.md` | Closeout    | ✅ Yes                    | Closeout |
| `workflow/tickets/PROJECT-123/skills.md`          | You         | ❌ Manual (optional)      | —        |

---

## Change Requests on Completed Tickets

When a ticket has been through the full pipeline and a new change request comes in — **do not overwrite the original ticket artifacts**.

### Folder convention

```
workflow/tickets/PROJECT-123/
├── index.md            ← searchable front door and artifact map
├── prompt.md           ← original contract
├── plan.md
├── handoff.md
├── pull-request.md
└── changes/
    └── cr-01/          ← new change request (cr-02, cr-03, etc.)
        ├── index.md
        ├── prompt.md
        ├── plan.md
        ├── handoff.md
        └── pull-request.md
```

### How to start a change request

From the workspace root:

```bash
mkdir -p workflow/tickets/PROJECT-123/changes/cr-01
```

Then run the Architect with `output_dir` pointed at the new subfolder:

```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/workflow-contract.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123/changes/cr-01

This is a change request on a completed ticket. Read the original contract at
workflow/tickets/PROJECT-123/prompt.md before drafting so you don't re-research
decisions already made.
```
> The CLI auto-derives the full ticket URL from the short ticket number. `output_dir` must be set explicitly here since it differs from the default.

After Contract writes active state for the change-request folder, run the rest of the pipeline with `run plan`, `run implement`, `run review`, and `run closeout`.

---

## Spike workflow

For research/spike tickets, see the dedicated CLI guide:

📄 **[`.github/how-to/howToUse-spike-cli.md`](howToUse-spike-cli.md)**

It covers the full pipeline (Scope → Investigate → Review → Educate → File tickets) with gates, session memory, and file reference — matching the depth of this guide.

---

## PR review (teammate's PR)

To review a teammate's open PR:

```
Act as Reviewer following .github/prompts/pr-review.prompt.md

pr_url=https://github.com/your-org/your-repo/pull/<PR_NUMBER>
```

For large PRs, run triage first:
```
Act as Reviewer following .github/prompts/pr-review-triage.prompt.md

pr_url=https://github.com/your-org/your-repo/pull/<PR_NUMBER>
```

---

## Dev environment starters

```
Follow .github/prompts/legacy-dev-start.prompt.md
```

```
Follow .github/prompts/mobile-start.prompt.md
```

---

## SSH Keychain caching (macOS)

Rather than typing your SSH passphrase on every push, you can store it in the macOS Keychain so it persists across reboots:

**One-time setup:**
```bash
# Add your key to the agent AND store the passphrase in Keychain
ssh-add --apple-use-keychain ~/.ssh/your_key
```

**Make it permanent** — add these lines to `~/.ssh/config`:
```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/your_key
```

After this, macOS unlocks the key at login via Keychain and `ssh-agent` holds it for the session. You will only be prompted once after a reboot (or never, if your login keychain is already unlocked).

> **Security note:** The passphrase is stored in the macOS Keychain (encrypted, protected by your Mac login). It is **not** stored in plaintext anywhere. This is the Apple-recommended approach and is safe for a personal development machine.

> If you prefer not to cache it, typing the passphrase on each push is also fine — it is never stored by the CLI or visible in logs.
