# Ticket Refinement — Quick Reference

Pipeline: **Fetch → Find Code → Dialogue → Write Doc**

Ticket refinement turns a Jira ticket into a concise plain-English document that
any developer can pick up and immediately understand: what the problem is, where
the relevant code lives, what the fix looks like, and what the key risk is.

The dialogue step is what makes this different from a one-shot summary. The agent
presents its understanding, you correct or confirm it, and the doc only gets
written once the mental model is right.

Replace `PROJECT-123` with your ticket ID.

---

## Steps Involved

### Step 1 — Create the output folder

```bash
mkdir -p workflow/refinement
```

### Step 2 — Run the refinement prompt

```text
Read .github/agents/pointing-analyst.agent.md and .github/prompts/pointing-plan.prompt.md

mode=tickets
tickets=PROJECT-123
output_dir=workflow/refinement
```

### Step 3 — Dialogue (your most important job)

The agent will present its understanding of the ticket and the code it found,
then ask 1-2 clarifying questions.

**You do:** Read it carefully. Answer the questions. Correct anything that is
wrong or imprecise. The doc only gets written after you confirm the understanding
is accurate.

### Step 4 — Review the output doc

The agent writes `workflow/refinement/PROJECT-123.md` (or appends to a batch file).

**You do:** Skim it. If anything is still off, push back — the agent can revise
before you close the session.

---

## The Dialogue Phase In Detail

The agent will always present three things before asking anything:

1. **What the ticket wants** — 2-3 sentences, no jargon.
2. **The code it found** — actual file names and what they do.
3. **Its understanding of the problem** — what is broken, missing, or unclear,
   and why it matters.

Then it asks at most 2 questions. Answer them directly. If the agent's
understanding is wrong, say so plainly — "no, it's not that" is a valid and
useful answer.

The dialogue is complete when you say something like "yes, that's right" or
"close enough, write it up."

---

## What "You say" looks like in practice

**Starting a single ticket:**
```
Read .github/agents/pointing-analyst.agent.md and .github/prompts/pointing-plan.prompt.md

mode=tickets
tickets=OSMS-18357
output_dir=workflow/refinement
```

**Starting a batch (multiple tickets):**
```
Read .github/agents/pointing-analyst.agent.md and .github/prompts/pointing-plan.prompt.md

mode=tickets
tickets=OSMS-18357, OSMS-18384, OSMS-18385
output_dir=workflow/refinement
```

**Continuing a sprint batch:**
```
Read .github/agents/pointing-analyst.agent.md and .github/prompts/pointing-plan.prompt.md

mode=sprint
sprint=Apollo 2.0 (2026)
output_dir=workflow/refinement
```

---

## What to expect in the output doc

Each refined ticket gets these sections:

| Section | What it answers |
|---|---|
| **TL;DR** | One-line description, why it matters, likely approach, readiness |
| **Plain-English Goal** | What does done look like? |
| **How It Currently Works** | What does the code actually do today? Includes file names. |
| **How It Will Work** | What changes, in plain terms. No code. |
| **The Key Risk or Open Question** | The one thing most likely to blow up the estimate. |
| **Estimate** | 1 / 2 / 3 with confidence and a one-line reason. |
| **Recommended Next Workflow** | Where this ticket goes after refinement. |

---

## Estimate rubric

| Points | What it means |
|---|---|
| `1` | Mostly UI or a simple targeted fix |
| `2` | Requires some logic and/or has moderate unknowns |
| `3` | Larger task with broader complexity or significant unknowns |

---

## Output files

| File | Created by |
|---|---|
| `workflow/refinement/PROJECT-123.md` | pointing-analyst (single ticket) |
| `workflow/refinement/ticket-refinement-YYYY-MM-DD.md` | pointing-analyst (batch, no sprint) |
| `workflow/refinement/<slugified-sprint>.md` | pointing-analyst (sprint mode) |

---

## Recommended next step after refinement

| Outcome | Next step |
|---|---|
| Ticket is clear and scoped | `workflow/tickets/PROJECT-123/` — standard delivery pipeline |
| Central question needs research first | `workflow/spikes/PROJECT-123/` — spike workflow |
| Acceptance criteria are missing or ownership is unclear | Backlog clarification — bring back to PM/team |
| Ticket is too large or too vague as written | Split, merge, or defer |

---

## How this differs from a spike

| | Ticket refinement | Spike |
|---|---|---|
| Starting point | Jira ticket with known work | Open question, no clear answer yet |
| Output | Plain-English doc + estimate | Research findings + recommendation |
| Code search | To understand current behavior | To answer a research question |
| Dialogue | Always — confirms understanding | Optional — surfaces unknowns |
| Next step | Implementation pipeline or spike | Follow-up tickets or defer |

---

## When to use this workflow

- A ticket is in the backlog and the team wants to understand it before sprint planning
- You are picking up a ticket and want a clear mental model before starting the contract
- A ticket description is vague and you want a structured writeup to share with the team
- You want an estimate with a documented rationale, not just a gut number
