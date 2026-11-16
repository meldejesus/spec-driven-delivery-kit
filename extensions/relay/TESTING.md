# Checking the local relay

Run these checks from the kit root:

```bash
python3 -B -m unittest discover -s extensions/relay/tests -v
bash -n install/install-to-workspace.sh
./install/install-to-workspace.sh --target /path/to/scratch-workspace --with-relay --dry-run
```

The automated suite checks persistence, duplicate enqueueing, occupied input,
retry after clearing, recipient receipts, restart uncertainty, one-worker
locking, replaced sessions, workspace boundaries, stale source entries, and
User gates. The fake terminal verifies that only one copy of each message is
injected and that an extra Enter is used only for the relay's own unsent draft.

For a live check, use a separate local workflow thread and two dedicated agent
panes. Keep actual session names, queue IDs, timestamps and transcript evidence
in that workspace's workflow folder; they are not reusable kit examples.

1. Configure the thread's Roles and tmux targets. Create a transport-only Writer
   entry addressed to Reviewer. Ask Reviewer to acknowledge receipt, append one
   normal entry, and enqueue its return to Writer.
2. If testing draft preservation, use an empty dedicated pane to create a known
   test-owned draft. Enqueue the Writer entry twice. Both calls must return the
   same ID, with only one database row.
3. Inspect status: the item should remain pending with the draft-preserved
   reason. Stop and restart the worker; the same item must remain pending.
4. Clear only that verified test-owned draft. The worker should submit the
   existing handoff, and Reviewer should run its receipt command.
5. Reviewer queues the return. Writer runs its receipt command. Confirm both
   IDs are acknowledged; no direct sender-side tmux delivery is needed.
6. Record commands and results in local verification evidence. End with a User
   turn so the check cannot dispatch another agent handoff.

Do not clear a real user's draft to run a check. A busy receiver with empty
input is allowed; an uncertain submission requires inspection. See the
[operator guide](templates/scripts/relay/README.md) for recovery and limitations.
