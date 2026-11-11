---
name: team-kickoff
description: Brief a new agent joining a multi-agent ticket mid-workflow. Reads team roles, current thread state, and active workflow position so the agent knows who they are, who else is working, and what to do next. Run this at the start of any new terminal session on an active ticket.
---

# When to run

At the start of a new terminal session joining an active ticket.
Invocation: `Read .github/skills/team-kickoff/SKILL.md and follow it. ticket=<ID>`

The Reviewer runs `independent-review` at the **contract, plan, and implement**
stages, and runs Gate D (`run review`).
The Writer runs contract, plan, implement, approved fixes and closeout.
Either agent may run this skill at the start of their session.

# Process

1. **Resolve the ticket.** Use `ticket=<ID>` from the invocation if given, with
   `output_dir` = `workflow/<ID>`. Otherwise read `workflow/.active-workflow.md`
   for the active ticket ID and output_dir. If neither is available, ask the user
   for the ticket ID before proceeding.

2. **Read `${output_dir}/thread.md`** — read the full file if under 60 lines;
   otherwise read the Roles section at the top plus the last 15 entries. Identify:
   - Your assigned role: find your CLI or model name in the Agent column of the
     Roles table
   - The last entry addressed to you
   - The current `Next:` instruction

3. **Read `${output_dir}/prompt.md`** — the immutable contract (ACs, constraints).
   Skim only — do not re-draft or reinterpret.

4. **Read the last 20 lines of `${output_dir}/handoff.md`** — current implementation
   state. If it does not exist, the ticket has not reached implement yet.

5. **Acknowledge in one line:**
   "I'm @[Role] ([CLI/model]). [One sentence on current state and what I'll do next]."

   Example: "I'm @Reviewer (Claude). Task 3 is complete per the last thread entry — reading the diff now."

6. **Proceed immediately** with the work indicated by the last `Next:` entry addressed to you.
   Do not wait for further instruction. "your turn" means: read the thread, do your part, append one entry, stop.
   Head your entry `## <Agent> (<Role>) — YYYY-MM-DD HH:MM`, such as `## Codex (Reviewer) — 2026-11-11 14:30`.

# Notes

- If your agent name isn't in the Roles table, or the table still shows `<agent>`, write `Question for User:` asking for your role in `thread.md`, and stop.
- If the last `Next:` entry is not addressed to you, say so and stop — do not act on another agent's turn.
- If `thread.md` does not exist, this is a solo workflow session. Proceed with the standard stage prompts.
