# Durable local agent relay

This helper keeps tmux handoffs in `workflow/.relay/queue.sqlite3` at the
workspace root. It uses Python 3's standard library, SQLite and `tmux` on
macOS/Linux. No Redis, network service or Python package installation is needed.

Install the extension with the kit's `--with-relay` or `--all` flag. The thread
must already contain `Mode: tmux`, exact Writer/Reviewer targets, and a Roles
table naming `Codex` or `Claude`. These are the initial supported terminal UIs.
The queue never approves workflow stages or dispatches a User turn.

## Send a handoff

Append the normal thread entry first, ending with `Next: Writer` or
`Next: Reviewer`. Then enqueue its exact heading:

```bash
python3 scripts/relay/relay.py --workspace /path/to/workspace enqueue \
  --thread workflow/PROJECT-123/thread.md \
  --entry '## Codex (Writer) — YYYY-MM-DD HH:MM' --role Reviewer
```

The helper returns a stable ID and starts a detached worker. End the sending
agent turn promptly. Repeating the same command returns the same ID without
adding another message. Only the latest entry can be enqueued. Changing that
entry changes its identity; do not edit an already queued source entry.

The worker checks the pane's workspace and agent UI. If its input is occupied
or the pane is missing, it leaves the message pending and retries with backoff
(up to 30 seconds). It preserves detected drafts. It can submit to a busy agent
with an empty input. The target is pinned to a pane/process on first discovery;
replacement sessions require operator attention. New thread entries or routing
changes supersede an older pending handoff.

## Receive and acknowledge

The incoming message contains an exact receipt command:

```bash
python3 scripts/relay/relay.py --workspace /path/to/workspace ack --id HANDOFF_ID
```

Run that command before doing the work. Receipt does not mean completion. Check
the current thread and follow its latest instruction; ignore stale handoffs.
Record the source heading in the next normal thread entry. Do not repeat work
for a handoff ID already handled. Queue any return handoff using the same helper.

## Status and lifecycle

```bash
python3 scripts/relay/relay.py --workspace /path/to/workspace status
python3 scripts/relay/relay.py --workspace /path/to/workspace start
python3 scripts/relay/relay.py --workspace /path/to/workspace stop
```

- `pending`: waiting for a safe target/input; retries automatically.
- `delivering`: persisted before terminal input is injected.
- `submitted`: terminal accepted/queued the message; waiting for a receipt.
- `acknowledged`: recipient confirmed receipt.
- `superseded`: the thread advanced or routing changed before delivery.
- `needs_attention`: submission was uncertain, the session was replaced, or a
  receipt did not arrive within five minutes. The worker does not resend it.
- `cancelled`: an operator stopped queue management of the item.

Only one worker holds the workspace lock. Starting again is safe. The detached
worker survives terminal closure; after a machine reboot, run `start` (or enqueue
another handoff). SQLite state survives both. A restart during injection marks
that message `needs_attention` rather than sending it again. Worker diagnostics
are in `workflow/.relay/worker.log`; status never prints a user's draft.

If a pane has moved, preserve the queue and inspect the terminal and thread.
Confirm whether the recipient handled the ID. A received message can still be
acknowledged after a receipt timeout. Cancel pending or uncertain work only
after inspection:

```bash
python3 scripts/relay/relay.py --workspace /path/to/workspace cancel --id HANDOFF_ID
```

Cancellation cannot withdraw input already sent. To intentionally replace a
cancelled or uncertain handoff, resolve its state first and append a new thread
entry; do not blindly repeat work. Unresolved uncertain delivery blocks later
handoffs to that target until it is acknowledged or explicitly cancelled.

## Limits

Terminal input and human typing cannot be made atomic through tmux. The worker
checks immediately before sending, but someone starting a draft at that exact
moment can still race delivery. Use dedicated agent panes and avoid typing into
them during submission. UI changes or ambiguous input keep the handoff queued
or flag it for attention. The queue does not claim exactly-once execution:
stable IDs and recipient deduplication prevent repeated work, while uncertain
submissions require inspection rather than automatic resending.

Keep `workflow/.relay/` out of version control. Its database holds local handoff
text and delivery state. The directory is created with owner-only permissions.
No credentials or ticket payloads belong in the reusable kit templates.
