# worklog/

Small personal status workspace for current priorities and chronological work
logs.

## Files

```text
worklog/
  dashboard.md    Current work grouped by status.
  daily-log.md    Append-only checkout/commit/manual work log.
  README.md       This guide.
```

## Daily Workflow

Use `worklog/dashboard.md` for the current picture:

- `Ticket Work` for ticket-backed work by status.
- `Workspace Work` for local repo and environment cleanup.
- `Follow-Ups` for loose ideas that may become tickets.
- `Notes` for short worklog-adjacent context.

Use `worklog/daily-log.md` for chronological activity captured by hooks or
manual log entries.

For routine cleanup, ask the agent to `update worklog`.

## Auto-Logging

The optional scripts under `scripts/worklog-sync/` can log checkout and commit
activity. Configure the hook path from the installed workspace root:

```bash
git config --global core.hooksPath "$PWD/scripts/worklog-sync/hooks"
```

If your main source repo is not the workspace root, set:

```bash
export WORKLOG_REPO_PATH="/path/to/source/repo"
```

## Manual Log Entry

```bash
python3 scripts/worklog-sync/worklog-entry.py checkout feature/example
python3 scripts/worklog-sync/worklog-entry.py commit feature/example "short note"
```
