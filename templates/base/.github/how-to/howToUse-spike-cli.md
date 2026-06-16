# Spike Workflow — CLI Quick Reference

Pipeline: **Setup → Scope → Investigate → Review → (Educate) → (File tickets)**

This is the CLI-native version of `howToUse-spike.md`. All steps run inside the GitHub Copilot CLI terminal using `Act as ...` syntax. No `@mention` or `#read` syntax required.

A spike is a time-boxed research task. The output is a document and a recommendation — not code.

Replace `PROJECT-123` with your ticket ID throughout.

---

## Steps Involved

### Session Startup

```text
/add-dir /path/to/workspace
```

### Step 1 — Create the task folder

```bash
mkdir -p workflow/spikes/PROJECT-123
```

The Scope step creates `workflow/spikes/PROJECT-123/index.md` as the first workflow-owned file.

### Step 2 — Draft Scope (Gate A)

```text
Act as Architect following .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=PROJECT-123

https://your-domain.atlassian.net/browse/PROJECT-123

if gettign text for this ticket fails after 2 attempts, let me know and i'll copy it in.
```

### Step 3 — Investigate

```text
Act as Spike-Investigator following .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md
```

### Step 4 — Review (Gate D)

```text
Act as Reviewer following .github/agents/reviewer.agent.md and .github/prompts/spike-review.prompt.md
```

### Step 5 — Educate (Optional)

```text
Act as Educator following .github/agents/educator.agent.md and .github/prompts/workflow-educate.prompt.md

ticket=PROJECT-123
output_dir=workflow/spikes/PROJECT-123
```

### Step 6 — File Follow-Up Tickets (Optional)

```text
File the follow-up tickets listed in workflow/spikes/PROJECT-123/spike-output.md using the Atlassian MCP tool.
Use the same project key as the original ticket.
```

---

## How CLI agents work

You tell the CLI which role to assume and which prompt file to follow. The CLI reads the prompt, embodies the agent's rules, and pauses at each gate for your confirmation before continuing.

**Gates are enforced via interactive prompts** — the CLI will stop and ask you before proceeding to the next stage.

---

## Providing extra context

There are three ways to give the CLI additional information at any step. They can be combined freely.

### 1 — `context=` parameter *(Scope step only)*

A formal named parameter accepted by `spike-contract`. Pass a single file path or a comma-separated list of **file paths** (no `@` prefix — that's VS Code Chat syntax, not CLI):

```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=PROJECT-123
context=workflow/spikes/PROJECT-123/pre-context.md,docs/prior-spike.md,docs/architecture/caching.md
```

The CLI reads each file and treats its contents as **authoritative developer context** — overriding assumptions from the ticket alone. Use it for prior related spikes, ADRs, known constraints, or research sources you want the Architect to start from.

> `context=` accepts file paths only — not directories. For whole directories, use plain text after the invocation block (see below).

> `spike-investigate` and `spike-review` do not have a formal `context=` slot — use `pre-context.md` or plain text (below) for those steps.

### 2 — `pre-context.md` *(works at every step, automatically)*

Drop a file named `pre-context.md` in the ticket folder before any step:

```bash
echo "Prior spike PROJECT-123 concluded X. The question here is narrower — only about Y." \
  > workflow/spikes/PROJECT-123/pre-context.md
```

**Every agent reads this file automatically** as its first action — no parameter needed. It is the standard way to pre-load context for steps that don't have a `context=` slot (Investigate, Review).

### 3 — Plain text appended to your message *(works at every step, always)*

Anything you write after the invocation block is visible to the CLI as conversational context. This is also the right way to point the CLI at **whole directories**:

```
Act as Spike-Investigator following .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md

Focus on the Redis caching layer specifically — the Postgres angle was covered in PROJECT-123.
Ignore any findings about the mobile app, that's out of scope for this spike.
```

```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=PROJECT-123
context=docs/architecture/caching.md

Also read everything in workflow/spikes/PROJECT-123/ and path/to/relevant/cache/.
```

The CLI will glob and read those directories as part of its research. You can mix both — `context=` for specific files you know matter, plain text for broader "look at this whole area" instructions.

---

## Session memory — ticket and output_dir defaults

The CLI remembers the last `ticket` and `output_dir` you set within a session. Once set, you can omit them from subsequent steps and the CLI will reuse the last known values, confirming them before proceeding.

**First invocation** — provide the short ticket number:
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=PROJECT-123
```
The CLI auto-derives:
- `ticket` → `https://your-domain.atlassian.net/browse/PROJECT-123`
- `output_dir` → `workflow/spikes/PROJECT-123`

**All subsequent steps** — omit ticket and output_dir entirely:
```
Act as Spike-Investigator following .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md
```
The CLI will confirm: *"Using ticket=PROJECT-123, output_dir=workflow/spikes/PROJECT-123 — proceed?"*

To **switch tickets mid-session**, just supply the new ticket number:
```
Act as Architect following ...

ticket=PROJECT-456
```

---

## Session startup (run every time you open the CLI)

```
/add-dir /path/to/workspace
```

| Operation | Behavior |
|---|---|
| File reads (view, grep, glob) | ✅ Auto-approved within workspace |
| File writes/edits within workspace | ✅ Auto-approved |
| Files outside the workspace | 🚫 Blocked |
| Shell commands (`git`, `npm`, etc.) | ⚠️ Prompted once per command type |

---

## Step 1 — Create the task folder

```bash
mkdir -p workflow/spikes/PROJECT-123
```

The Scope step creates `index.md` before `scope.md`.

> **Optional:** Drop a `pre-context.md` in this folder before Step 2. The Architect will read it automatically. Use it for known constraints, related prior spikes, or anything the ticket description omits.

---

## Step 2 — Draft Scope (Gate A)

**You type:**
```
Act as Architect following .github/agents/architect.agent.md and .github/prompts/spike-contract.prompt.md

ticket=PROJECT-123
```

**What happens:** The CLI fetches the Jira ticket (via Atlassian MCP), creates `index.md` with searchable metadata, reads `pre-context.md` if present, scans `.github/archive/` for related prior spikes, and writes `scope.md` with: the question, why it matters, in/out of scope, timebox, and sources to consult.

**Gate A — CLI pauses here.** You will be asked:
> "I've initialized the spike index and drafted the Scope. Shall I proceed to Investigation, or do you want revisions?"

**You do:** Read `workflow/spikes/PROJECT-123/scope.md`. Use `index.md` to relocate the spike later by ID, summary, terms, paths, or links. If the question or boundaries are wrong, say so — the CLI will redraft. Do not proceed until you're satisfied with the framing.

---

## Step 3 — Investigate

**You type:**
```
Act as Spike-Investigator following .github/agents/spike-investigator.agent.md and .github/prompts/spike-investigate.prompt.md
```
> `ticket` and `output_dir` are optional — the CLI defaults to the last values set in Step 2.

**What happens:** The CLI works through the sources listed in `scope.md`, journals each finding to `findings.md` as it goes, then writes `spike-output.md` containing:
- Executive Summary
- Technical Findings (with evidence citations)
- Confidence Level
- Gaps & Assumptions
- Suggested Follow-up Tickets (optional)

It also writes `explained.md`, a shorter readable summary that starts with known quantities: the basic goal, target page/route/endpoint/admin surface, expected workflow, data changes, safety behavior, and open decisions.

Ends with `"Stage Complete: Investigation"`.

**You do:** Read `workflow/spikes/PROJECT-123/explained.md` first for the practical answer, then use `spike-output.md` for evidence and deeper detail. If the question wasn't actually answered, send back with specific feedback — the CLI will re-investigate the gap.

---

## Step 4 — Review (Gate D)

**You type:**
```
Act as Reviewer following .github/agents/reviewer.agent.md and .github/prompts/spike-review.prompt.md
```
> `ticket` is optional — the CLI defaults to the last value used.

**What happens:** The CLI reads `scope.md`, `findings.md`, `spike-output.md`, and `explained.md`. Checks that:
- The question was answered
- Every finding is evidence-grounded (not speculative)
- Gaps and unknowns are stated honestly
- Scope was respected (no out-of-scope drift)
- `explained.md` is accurate, readable, and starts with the basic goal plus target page/route/endpoint/admin surface

Outputs **APPROVE** or **REQUEST CHANGES** with severity-rated findings. On approval, appends a review footer to `spike-output.md`.

**Gate D — CLI pauses here.** You'll be asked to accept or action the findings before proceeding.

**You do:** Accept, or address REQUEST CHANGES items and re-run this step.

---

## Step 5 — Educate (optional)

**You type:**
```
Act as Educator following .github/agents/educator.agent.md and .github/prompts/workflow-educate.prompt.md

ticket=PROJECT-123
output_dir=workflow/spikes/PROJECT-123
```
> `ticket` and `output_dir` are optional when session memory is correct, but passing both avoids falling back to the implementation-ticket directory.

**What happens:** The CLI reads the scope, findings, and output. Produces a plain-language walkthrough of what was investigated, what was found, the key decision point, and the main takeaway. Writes to `workflow/spikes/PROJECT-123/overview.md`.

**Skip if:** The spike was straightforward or the audience doesn't need a walkthrough.

---

## Step 6 — File Follow-up Tickets (optional)

If `spike-output.md` contains a Suggested Follow-up Tickets section and the reviewer approved them:

**You type:**
```
File the follow-up tickets listed in workflow/spikes/PROJECT-123/spike-output.md using the Atlassian MCP tool.
Use the same project key as the original ticket.
```

**What happens:** Tickets are created in Jira. IDs are echoed back so you can add them to `standup/dashboard.md`.

---

## File reference

| File | Created by | Auto-written? | Gate |
|---|---|---|---|
| `workflow/spikes/PROJECT-123/index.md` | Architect | ✅ Yes | Pre-A |
| `workflow/spikes/PROJECT-123/pre-context.md` | You | ❌ Manual (optional) | Pre-A |
| `workflow/spikes/PROJECT-123/scope.md` | Architect | ✅ Yes | A |
| `workflow/spikes/PROJECT-123/findings.md` | Spike-Investigator | ✅ Yes (running journal) | — |
| `workflow/spikes/PROJECT-123/spike-output.md` | Spike-Investigator | ✅ Yes | — |
| `workflow/spikes/PROJECT-123/explained.md` | Spike-Investigator | ✅ Yes | — |
| `workflow/spikes/PROJECT-123/overview.md` | Educator | ✅ Yes | — (optional) |

---

## How spikes differ from the full pipeline

| | Full pipeline | Spike |
|---|---|---|
| Output | Code + PR | Document + recommendation |
| Gate B | Plan approval | Not applicable |
| Gate C | Pivot approval on task failures | Not applicable |
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
