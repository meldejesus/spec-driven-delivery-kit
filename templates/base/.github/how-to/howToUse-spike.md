# Spike Workflow — Quick Reference

Pipeline: **Scope → Investigate → Review → (Educate) → (File tickets)**

A spike is a time-boxed research task. The output is a document and a recommendation — not code.
Replace `PROJECT-123` with your ticket ID.

> **CLI-native workflow.** All steps run in the Copilot CLI terminal. No `@mention` or `#read` syntax required.

---

## Steps Involved

### Step 1 — Create the task folder

```bash
mkdir -p workflow/tickets/PROJECT-123
```

### Step 2 — Draft Scope (Gate A)

```text
Read .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

### Step 3 — Investigate

```text
Read .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

### Step 4 — Review (Gate D)

```text
Read .github/agents/reviewer.agent.md and .github/prompts/spike-review.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

### Step 5 — Educate (Optional)

```text
Read .github/agents/educator.agent.md and .github/prompts/workflow-educate.prompt.md

ticket=PROJECT-123
```

### Step 6 — File Follow-Up Tickets (Optional)

```text
File the follow-up tickets listed in workflow/tickets/PROJECT-123/spike-output.md using the Atlassian MCP tool.
Use the same project key as the original ticket.
```

---

## Step 1 — Create the task folder

```bash
mkdir -p workflow/tickets/PROJECT-123
```

---

## Step 2 — Draft Scope (Gate A)

**You say:**
```
Read .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=https://your-domain.atlassian.net/browse/PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

**Expect:** Architect fetches the Jira ticket, scans for prior related spikes, and writes `scope.md` with: the question, why it matters, in/out of scope, timebox, and sources to consult. Ends with `"Stage Complete: Scope (Gate A)"`.

**You do:** Read `scope.md`. If the question or boundaries are wrong, say so — Architect will redraft. Do not proceed until you're satisfied.

---

## Step 3 — Investigate

**You say:**
```
Read .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

**Expect:** Spike-Investigator works through the sources in `scope.md`, journals each finding to `findings.md`, then writes `spike-output.md` with: Executive Summary, Technical Findings, Confidence Level, Gaps & Assumptions, and optional Suggested Follow-up Tickets. It also writes `explained.md`, a shorter readable summary that starts with the basic goal and target page/route/endpoint before moving into workflow, data changes, safety, and open decisions. Ends with `"Stage Complete: Investigation"`.

**You do:** Read `explained.md` first for the practical answer, then use `spike-output.md` when you need the detailed evidence. If the question wasn't actually answered, send back with specific feedback.

---

## Step 4 — Review (Gate D)

**You say:**
```
Read .github/agents/reviewer.agent.md and .github/prompts/spike-review.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123
```

**Expect:** Reviewer reads `scope.md`, `findings.md`, `spike-output.md`, and `explained.md`. Checks that the question was answered, findings are evidence-grounded, gaps are honest, scope was respected, and the readable summary is accurate. Outputs **APPROVE** or **REQUEST CHANGES** with severity-rated findings. On approval, appends a review footer to `spike-output.md`. Ends with `"Stage Complete: Review (Gate D)"`.

**You do:** Accept or action the findings.

---

## Step 5 — Educate (optional)

**You say:**
```
Read .github/agents/educator.agent.md and .github/prompts/workflow-educate.prompt.md

ticket=PROJECT-123
```

**Expect:** Educator reads the scope, findings, and output. Produces a plain-language walkthrough of what was investigated, what was found, the key decision point, and the main takeaway. Writes to `workflow/tickets/PROJECT-123/overview.md`. Ends with `"Stage Complete: Education"`.

**Skip if:** The spike was straightforward or the audience doesn't need a walkthrough.

---

## Step 6 — File Follow-up Tickets (optional)

If `spike-output.md` contains a Suggested Follow-up Tickets section and the reviewer approved them:

**You say:**
```
File the follow-up tickets listed in workflow/tickets/PROJECT-123/spike-output.md using the Atlassian MCP tool.
Use the same project key as the original ticket.
```

**Expect:** Tickets are created in Jira. IDs are echoed back so you can add them to `standup/dashboard.md`.

---

## File reference

| File | Created by | Gate |
|---|---|---|
| `workflow/tickets/PROJECT-123/scope.md` | Architect | A |
| `workflow/tickets/PROJECT-123/findings.md` | Spike-Investigator | — |
| `workflow/tickets/PROJECT-123/spike-output.md` | Spike-Investigator | — |
| `workflow/tickets/PROJECT-123/explained.md` | Spike-Investigator | — |
| `workflow/tickets/PROJECT-123/overview.md` | Educator | — (optional) |

---

## How spikes differ from the full pipeline

| | Full pipeline | Spike |
|---|---|---|
| Output | Code + PR | Document + recommendation |
| Gate C | Pivot approval if task fails | Not applicable |
| Review lens | Code quality, AC coverage | Question answered, evidence-grounded |
| Merge | Required | Not applicable |
| Education | Optional | Optional |
| Follow-up tickets | Promotion stage | Filed directly from output |

---

## When to use this workflow

- Ticket is labelled **Spike** in Jira
- The work is answering a question before deciding whether to build something
- No code will be written during this session
- Output is a recommendation, comparison, feasibility assessment, or data summary
