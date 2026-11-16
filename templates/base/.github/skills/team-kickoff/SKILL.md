---
name: team-kickoff
description: Brief a new agent joining a multi-agent ticket mid-workflow. Reads team roles, current thread state, and active workflow position so the agent knows who they are, who else is working, and what to do next. Run this at the start of any new terminal session on an active ticket.
---

# When to run

At the start of a new terminal session joining an active ticket.
Invocation: `Read .github/skills/team-kickoff/SKILL.md and follow it. ticket=<ID> [output_dir=<path>] [workspace_root=<path>]`

The Reviewer runs `independent-review` at the **contract, plan, and implement**
stages, and runs Gate D (`run review`).
The Writer runs contract, plan, implement, approved fixes and closeout.
Either agent may run this skill at the start of their session.

# Process

1. **Resolve the ticket.** Use `ticket=<ID>` and `output_dir=<path>` from the
   invocation when provided. Otherwise read `workflow/.active-workflow.md` from
   `workspace_root` (or the current directory) for the active ticket ID and
   output_dir. If neither is available, ask the user for the ticket ID before
   proceeding. When `workspace_root` is supplied, read its `AGENTS.md` and use
   absolute paths beneath it for all ticket artifacts, even if this terminal is
   open in a nested worktree.

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

7. **Relay mode:** Read `Relay configuration` in `thread.md`. When mode is
   `tmux`, use the durable local queue. The helper must be installed with the
   kit's `--with-relay` or `--all` option. Do not use direct `send-keys` as a
   fallback: report a missing helper and preserve the thread entry for setup.
   Never enqueue `Next: User` or `Question for User:`.

   After appending your entry, enqueue exactly that heading for the next agent:

   ```bash
   python3 <workspace-root>/scripts/relay/relay.py --workspace <workspace-root> enqueue \
     --thread <absolute-output-dir>/thread.md \
     --entry '## <Agent> (<Role>) — <exact timestamp>' --role <Writer|Reviewer>
   ```

   The helper derives the target from the thread's existing role configuration,
   returns a stable handoff ID, and starts the detached worker automatically.
   Repeating the same enqueue is safe: it returns the same ID. **End your turn
   promptly after enqueueing.** Do not wait for delivery or for the other agent
   to finish; the queue owns retries. Report it as queued, not received.

   The worker identifies the pane, checks that it remains inside the configured
   workspace, and preserves occupied drafts. Busy agents with empty composers
   may receive queued input. Missing panes and occupied composers are retried
   with bounded backoff. New thread entries supersede old pending handoffs.

   **On receipt:** Run the exact `ack` command in the incoming handoff before
   starting work. This records receipt, not completion. Check the source entry
   and latest `Next:` before acting; ignore stale instructions. Acknowledge the
   source heading in your next normal thread entry. Do not repeat work for an
   already handled handoff ID or send a separate acknowledgement relay.

   ```bash
   python3 <workspace-root>/scripts/relay/relay.py --workspace <workspace-root> status
   ```

   `pending` means waiting for safe delivery; `submitted` means accepted/queued
   by the app; `acknowledged` means the recipient confirmed receipt.
   `needs_attention` means submission or receipt is uncertain. Inspect it;
   never blindly resend. The worker will not duplicate submitted messages after
   a timeout or restart. It flags uncertainty instead. An explicitly cancelled
   item cannot be unsent; cancellation only stops queue management of that item.
   Only Codex and Claude composer profiles are supported initially. If the UI
   cannot be recognized, the worker retains the handoff rather than typing.
   See `scripts/relay/README.md` for lifecycle, recovery, and limitations.

# Writer: handing off to the Reviewer

When a stage sets `Next:` to the Reviewer, the Writer ends its final message
with this block in manual mode, after everything else, and doesn't ask the Gate
question. In tmux mode, append the thread entry and enqueue it using the procedure
above instead. Take the Reviewer's name from the Roles table. If the row still
shows `<agent>`, ask the user to fill it in instead.

```
Next: <Reviewer agent> (Reviewer) reviews <artifact>.
1. Open a second terminal in the workspace root and start <Reviewer agent>.
   (Skip if it's already running there; just say "your turn" to it.)
2. Paste: Read .github/skills/team-kickoff/SKILL.md and follow it. ticket=<ID>
3. Say "your turn" to <Reviewer agent>.
When it's done, say "your turn" to me. Approve Gate <X> after the review.
```

Ask the Gate question only when `Next:` is the User.

# Notes

- If your agent name isn't in the Roles table, or the table still shows `<agent>`, write `Question for User:` asking for your role in `thread.md`, and stop.
- If the last `Next:` entry is not addressed to you, say so and stop — do not act on another agent's turn.
- If `thread.md` does not exist, this is a solo workflow session. Proceed with the standard stage prompts.
