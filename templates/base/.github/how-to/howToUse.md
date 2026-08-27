# Workflow Reference

All commands in one place. For first-time setup, read `QUICKSTART.md` first.

---

## Ticket Workflow — Pipeline at a Glance

| # | Stage | Command | Gate | You approve |
|---|---|---|---|---|
| 1 | Contract | `run contract ticket=PROJECT-123` | **A** | Scope, ACs, constraints |
| 2 | Plan | `run plan` | **B** | Task order and coverage |
| 3 | Implement | `run implement` | **C** *(if task fails 3×)* | Pivot approach |
| 4 | Review | `run review` | **D** | Diff, findings, PR description |
| 5 | Closeout | `run closeout` | — | Promotion candidates |
| 6 | Push | `git push origin <branch>` | — | — |
| 7 | Sonar | `run sonar pr_number=N` | — | — |

---

## Stage-by-Stage Details

### 1. Contract (Gate A)

```
run contract ticket=PROJECT-123
```

Or with a full Jira URL:

```
run contract ticket=https://your-domain.atlassian.net/browse/PROJECT-123
```

**What happens:** Architect fetches the ticket, scans for similar past work, drafts the Strategic Contract (scope, ACs, constraints), and writes a QA reproduction guide.

**What gets written:** `index.md`, `prompt.md`, `reproduce.md`, `workflow/.active-workflow.md`

**You do:** Read `prompt.md`. If scope is wrong, say so — Architect will redraft. Do not continue until you're satisfied. The contract is immutable once approved; scope changes require a new contract.

---

### 2. Plan (Gate B)

```
run plan
```

**What happens:** Plan-Agent reads the approved contract, breaks every AC into atomic tasks (≤15 min each), and surveys affected files.

**What gets written:** `plan.md`, `codebase-scan.md`

**You do:** Read `plan.md`. Check task order, coverage, and that nothing is missing. Approve or request adjustments.

---

### 3. Implement

```
run implement
```

**What happens:** Implementer works through `plan.md` one task at a time. After each task: updates `handoff.md`, logs evidence to `test.md`, marks the task `[x]`. Before finishing, runs a final build validation and records the result.

**Gate C** fires automatically if a task fails 3 times — the agent marks it `[FAILED]`, proposes a pivot, and stops for your decision. You can also stop the agent at any time, read `handoff.md`, and edit `plan.md` directly.

**You do:** Watch for Gate C. Otherwise, let it run.

---

### 4. Review (Gate D)

```
run review
```

**What happens:** Reviewer reads the contract, plan, handoff, and test log, then runs `git diff`, affected build, lint, and affected tests. Outputs severity-rated findings. Then:

- **APPROVE** → writes `pull-request.md` and announces next command
- **REQUEST CHANGES** → lists BLOCKERs with exact fix guidance

**You do:** Approve or fix blockers, then re-run.

> **Optional:** Add context inline: `run review context=workflow/PROJECT-123/manual-test-notes.md`

---

### 5. Closeout

```
run closeout
```

**What happens:** Writes `overview.md` (plain-English walkthrough for a future teammate), then surfaces generalizable lessons and proposes any global rule promotions. Stops before touching global files.

**You do:** Approve, revise, or skip the promotion.

---

### 6. Push + Open PR

```bash
git push origin <your-branch>
```

Open a PR in GitHub using `workflow/PROJECT-123/pull-request.md` as the description.

---

### 7. Sonar Gate *(~20 min after push, once CI completes)*

```
run sonar pr_number=<PR_NUMBER>
```

Queries SonarQube for BLOCKER/CRITICAL/MAJOR issues and coverage delta. States a clear **PASSED** or **BLOCKED** verdict. If blocked, hands off fixes and re-checks after CI re-runs.

---

## Change Request on a Completed Ticket

Do not overwrite the original artifacts — they are the audit trail.

```bash
mkdir -p workflow/PROJECT-123/changes/cr-01
```

```
run contract ticket=PROJECT-123
output_dir=workflow/PROJECT-123/changes/cr-01
note=This is a CR. Read the original contract at workflow/PROJECT-123/prompt.md before drafting.
```

Then run `plan`, `implement`, `review`, `closeout` as normal. Use `cr-02`, `cr-03` for subsequent change requests.

---

## No Jira Ticket

Create `workflow/FEATURE-NAME/pre-context.md` with: feature title, description, ACs, constraints. The contract stage reads this file automatically — MCP is not needed.

```
run contract ticket=FEATURE-NAME
```

---

## Peer Review (Reviewing a Teammate's PR)

Use this to review someone else's PR from a GitHub URL. This runs outside the ticket workflow.

```
run peer-review pr_url=https://github.com/your-org/your-repo/pull/XXXX
ticket=https://your-domain.atlassian.net/browse/PROJECT-123
context=<anything you know about the area, the author's constraints, or prior conversations>
```

`ticket` and `context` are optional but improve accuracy. Even one sentence of context reduces false alarms.

### How the review runs

The review runs in three stages, designed so your testing and the agent's review happen in parallel:

**Stage 1 — You receive:**
- What the PR does in plain language
- Files changed and why
- AC list from the ticket
- Testing guide (manual steps or backend verification, tailored to the diff)

**→ Go test while the agent reviews**

**Stage 2 — Agent produces (while you test):**
- What works well
- Concerns (non-blocking — your call)
- Blockers (must fix — only when the agent is confident)
- Questions for Author (looks off but may be intentional — phrased as questions, not blockers)
- Edge cases and breaking risks
- AC coverage table

**Stage 3 — You come back with test results:**

```
Here's what I found testing:
- [step X] worked as expected
- [step Y] the modal didn't close on Escape
- didn't check the backend path
```

Or say `skip testing` to go straight to the verdict.

**→ You receive:** Final APPROVE or REQUEST CHANGES verdict + numbered change requests + GitHub comment ready to paste.

### Handling findings

| Finding type | What to do |
|---|---|
| **Blocker** | Request change — reference the line |
| **Concern** | Your call — suggest it or leave a comment |
| **Question for Author** | Post as a genuine question, don't block |
| **Edge case** | Discuss with author — decide before merge |

### Tips

- **Triage large PRs (20+ files) first:** `run peer-review-triage pr_url=<URL>` — quick file table and risk level before committing to the full review.
- **Disagree with a finding?** Say so — the agent will reassess or drop it.
- **Author already addressed something?** Include it in `context=` so it doesn't get re-raised.
- **Want a concrete fix for a blocker?** Ask: `Give me a concrete fix for blocker #2.`

---

## Spike (Research Question)

Use when the work is answering a question before deciding whether to build — output is a document, not code.

```bash
mkdir -p workflow/PROJECT-123/spike
```

```
run spike-contract ticket=PROJECT-123
```

→ Architect drafts `scope.md` — question, why it matters, in/out of scope, timebox, sources. **Gate A.**

```
run spike-investigate
```

→ Spike-Investigator works through sources, journals findings, writes `spike-output.md` (detailed) and `explained.md` (readable summary). Read `explained.md` first.

```
run spike-review
```

→ Reviewer checks: question answered, evidence-grounded, gaps honest, scope respected. **APPROVE or REQUEST CHANGES.** Gate D.

```
run spike-educate
```

*(Optional)* — plain-language overview for a teammate.

After approval, file any follow-up tickets from `spike-output.md`:

```
File the follow-up tickets listed in workflow/PROJECT-123/spike/spike-output.md using the Atlassian MCP tool. Use the same project key.
```

### Spike artifacts

| File | Created by |
|---|---|
| `workflow/PROJECT-123/spike/index.md` | Contract |
| `workflow/PROJECT-123/spike/scope.md` | Contract (Gate A) |
| `workflow/PROJECT-123/spike/findings.md` | Investigator |
| `workflow/PROJECT-123/spike/spike-output.md` | Investigator |
| `workflow/PROJECT-123/spike/explained.md` | Investigator |
| `workflow/PROJECT-123/spike/overview.md` | Educator (optional) |

---

## Ticket Refinement (Backlog / Pointing)

Use before sprint planning to turn a vague ticket into a clear, estimated writeup.

**Single ticket:**
```
run refinement tickets=PROJECT-123
```

**Batch:**
```
run refinement tickets=PROJECT-123, PROJECT-456, PROJECT-789
```

**Sprint:**
```
run refinement mode=sprint sprint="Apollo 2.0 (2026)"
```

The agent presents its understanding and asks 1–2 clarifying questions. Answer them — the doc only gets written once you confirm the model is accurate. Say `yes, that's right` or `close enough, write it up` to proceed.

**Output doc sections:** TL;DR · Plain-English Goal · How It Currently Works · How It Will Work · Key Risk or Open Question · Estimate (1/2/3) · Recommended Next Workflow

**Estimate rubric:**

| Points | What it means |
|---|---|
| `1` | Mostly UI or a simple targeted fix |
| `2` | Requires some logic or has moderate unknowns |
| `3` | Larger task or significant unknowns |

**Output file:** `workflow/PROJECT-123/refinement/PROJECT-123.md` (single) · `workflow/refinement/ticket-refinement-YYYY-MM-DD.md` (batch) · `workflow/refinement/<sprint-slug>.md` (sprint)

---

## Merge Conflict

```
run merge-conflict target_branch=origin/main
```

If `.active-workflow.md` is current, `ticket` and `output_dir` are inferred. Add `context=` for anything important about the conflict.

The agent: checks branch state, reads ticket artifacts, merges with `--no-commit`, resolves conflicted files by composing intent (not blindly choosing one side), audits scope, runs focused tests, then presents a resolution report before committing.

---

## Ticket Artifacts

| File | Created by | What it is |
|---|---|---|
| `workflow/.active-workflow.md` | Contract | State file — inferred by later stages |
| `index.md` | Contract | Searchable metadata |
| `prompt.md` | Contract | Approved scope, ACs, constraints |
| `reproduce.md` | Contract | QA repro guide |
| `plan.md` | Plan | Atomic task checklist |
| `codebase-scan.md` | Plan | Pre-implementation file survey |
| `handoff.md` | Implement | Running journal — decisions, friction, pivots |
| `test.md` | Implement | Evidence log — one entry per task |
| `pull-request.md` | Review | PR description, ready to paste |
| `overview.md` | Closeout | Plain-English walkthrough for future teammates |
| `lessons-learned.md` | Closeout | Generalizable lessons |

---

## After Merge (Archival)

Move the ticket directory to `workflow-archive/workflow/<ticket-id>/`.

**Option A — Clean ticket** (thorough PR description, no major pivots): keep `prompt.md`, `pull-request.md`, `lessons-learned.md`. Delete the rest.

**Option B — Complex/bug ticket** (pivots, deliberate tradeoffs, edge-case bugs): keep `index.md`, `prompt.md`, `plan.md`, `handoff.md`, `reproduce.md`, `pull-request.md`, `lessons-learned.md`. Delete `codebase-scan.md`, `test.md`, `overview.md`.

Decision rule: if the PR description alone would explain a future bug in this area → Option A. If pivots or deliberate tradeoffs matter → Option B.

See `.github/how-to/howToUse-ticket-archival.md` for full rationale.

---

## Getting Unstuck

| Problem | Fix |
|---|---|
| Agent confused or going in circles | Check `handoff.md`. If > 50 lines: `use the compactor agent to summarize handoff.md` |
| Task failing repeatedly | Gate C fires after 3 failures. If it doesn't, stop the agent, read `handoff.md`, edit `plan.md` |
| Lost context mid-workflow | `read workflow/.active-workflow.md` — shows active ticket, output dir, last stage |
| Scope needs to change after Gate A | Run a new contract with a note — do NOT edit `prompt.md` |

---

## Further Reading

| Topic | File |
|---|---|
| Why the workflow is designed this way | `.github/how-to/spec-driven-workflow.md` |
| MCP server setup and authentication | `.github/how-to/mcp-setup.md` |
| Instruction files explained (AGENTS.md, CLAUDE.md, etc.) | `.github/how-to/instructions-setup.md` |
| Authoring agents, prompts, and skills | `.github/how-to/authoring-agents-prompts-skills.md` |
| Archival options in detail | `.github/how-to/howToUse-ticket-archival.md` |
