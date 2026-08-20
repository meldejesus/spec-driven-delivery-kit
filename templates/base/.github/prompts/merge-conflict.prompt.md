---
name: merge-conflict
description: Resolve a target-branch merge while preserving both sides' intent and presenting validation and scope-audit results.
agent: merge-conflict-resolver
tools: [read, search, terminal, write]
infer: false
target: vscode
---

# Inputs
- ticket: ${input:ticket} # optional, e.g. PROJECT-123
- output_dir: ${input:output_dir} # optional, defaults from active workflow or workflow/${ticket}
- target_branch: ${input:target_branch} # optional, defaults to origin/main
- merge_ref: ${input:merge_ref} # optional, defaults to target_branch
- context: ${input:context} # optional, comma-separated file paths or notes
- write_report: ${input:write_report} # optional, defaults to false; only true writes a markdown report
- report_path: ${input:report_path} # optional markdown path when write_report=true

# Purpose
Resolve merge conflicts without regressing either side. Prove what each side intended, compose the safest result, and validate the behavior both sides cared about.

# 0. Resolve Inputs
1. If `target_branch` is omitted, use `origin/main`.
2. If `merge_ref` is omitted, use `target_branch`.
3. If `ticket` or `output_dir` is omitted, read `workflow/.active-workflow.md` when it exists.
4. If `ticket` is a Jira URL, extract the `PROJECT-123` key.
5. If `output_dir` is still missing and `ticket` is known, use `workflow/${ticket}`.
6. Read each file path listed in `context`. Treat inline invocation notes as additional context.

# 1. Preflight
Run these before starting or continuing a merge:

```bash
git status --short --branch
git branch --show-current
git fetch origin
git rev-list --left-right --count HEAD...${target_branch}
git merge-base HEAD ${target_branch}
```

Rules:
- If unrelated local changes exist, identify them and do not overwrite them.
- If a merge is already in progress, continue from the current conflicted state.
- If the worktree is clean and no merge is active, run `git merge --no-commit ${merge_ref}` so the resolved state can be inspected and tested before committing.
- Immediately after the merge reports conflicts, capture the exact conflict list with `git diff --name-only --diff-filter=U`. This list is the baseline for the final scope audit.
- Do not use destructive commands such as `git reset --hard`, `git checkout -- <path>`, or `git merge --abort` unless the user explicitly approves that action.

# 2. Load Intent
Read workflow context before touching conflict hunks:

1. `${output_dir}/index.md` if it exists.
2. `${output_dir}/prompt.md` or contract document if it exists.
3. `${output_dir}/plan.md` if it exists.
4. `${output_dir}/codebase-scan.md` if it exists.
5. `${output_dir}/handoff.md` if it exists.
6. `${output_dir}/test.md` if it exists.
7. `${output_dir}/pull-request.md` or PR notes if they exist.
8. Any relevant docs mentioned by the ticket or conflict files.

Then inspect Git intent:

```bash
git log --oneline --decorate --max-count=20 HEAD
git log --oneline --decorate --max-count=20 ${target_branch}
git diff --name-status ${target_branch}...HEAD
git diff --name-status HEAD..${target_branch}
git diff --name-only --diff-filter=U
```

For overlapping files, check file-specific history:

```bash
git log --oneline --decorate -- ${path}
git diff ${target_branch}...HEAD -- ${path}
git diff HEAD..${target_branch} -- ${path}
```

# 3. Conflict Inventory
Build a conflict inventory for the final terminal/chat report. Do not create a markdown report unless `write_report=true` or the user explicitly asks for a persistent artifact. If `write_report=true`, write the report to `report_path` when supplied, otherwise `${output_dir}/merge-conflict-resolution.md` when `output_dir` is known, otherwise `workflow/merge-conflict-resolution.md`.

Use this table:

| File | Area | Branch intent | Target intent | Resolution |
| --- | --- | --- | --- | --- |

For each conflicted file, inspect the three-way state:

```bash
git show :1:${path} # base
git show :2:${path} # ours, current branch
git show :3:${path} # theirs, merge_ref
git diff --merge -- ${path}
```

If a file auto-merged but changed on both branches, inspect it anyway. Auto-merges can silently drop intent.

# 3.1. Scope Audit
The resolver must distinguish merge noise from manual conflict-resolution changes.

Before resolving conflicts, record:

```bash
git diff --name-only --diff-filter=U
```

Call this the `original_conflict_files` list.

After committing the merge, report the files that required manual merge resolution:

```bash
git show --remerge-diff --name-only HEAD
```

Call this the `manual_resolution_files` list.

Also report files changed by the merge commit relative to the feature branch parent:

```bash
git diff --name-status HEAD^1..HEAD
```

Call this the `merge_commit_files` list. These may include many files that came from the target branch and were not manually resolved.

In the terminal/chat report, and in the optional markdown report only when requested, explicitly state:

- whether `manual_resolution_files` matches `original_conflict_files`
- whether any files outside `original_conflict_files` were manually changed or added
- whether extra files shown in `merge_commit_files` are only upstream target-branch changes

If `git show --remerge-diff` is unavailable, report that limitation and compare the captured conflict list against your staged/manual edits from the resolution log.

# 4. Resolution Rules
- Preserve ticket-branch behavior required by the contract, plan, handoff, tests, and PR notes.
- Preserve target-branch fixes, dependency changes, migrations, deletions, security checks, and user-facing copy unless they directly conflict with ticket behavior.
- Prefer a composed manual merge over blindly taking ours or theirs.
- Do not drop validation, authorization, error handling, analytics, cache invalidation, SEO metadata, accessibility, or test coverage without explicit rationale.
- Treat delete/modify conflicts as high risk. Confirm whether the target branch intentionally removed the feature or only removed an obsolete path.
- Update adjacent imports, types, route registration, tests, snapshots, docs, and generated result expectations as part of the same resolution.
- Keep unrelated refactors out of the conflict resolution.

Before staging a resolved file:

```bash
rg '<<<<<<<|=======|>>>>>>>' ${path}
git diff -- ${path}
git add ${path}
```

# 5. Validate
After all conflicts are staged:

```bash
git diff --name-only --diff-filter=U
git diff --check
```

Then run validation scaled to the conflict surface:
- Focused unit tests for every directly conflicted area.
- Tests for both sides' protected behavior, not just the ticket branch.
- Build or typecheck for the affected project.
- Final affected build when feasible.

Example:

```bash
yarn nx affected --target=build --base=${target_branch}
```

If the repo uses another command form, use the local equivalent and record why.

If a command fails for environment reasons, record the command, exact failure, whether it reached application code, workaround attempted, and remaining risk.

# 6. Complete The Merge
If validation passes and the task is to resolve the merge end-to-end:

1. Recheck `git status --short --branch`.
2. Review staged conflict files and important auto-merged files.
3. Commit the merge with the default merge message or a concise merge message.

If the user asked only for a resolution plan, do not commit. Leave clear instructions for the writer who will apply the resolution.

# 7. Required Output
Present the final report in the terminal/chat with:

1. Target branch, merge ref, current branch, merge base, and ahead/behind counts.
2. Context files read.
3. Conflict inventory table.
4. Scope audit:
   - `original_conflict_files`
   - `manual_resolution_files`
   - any manually changed/added files outside the original conflict list
   - a short explanation of extra files that only came from `merge_ref`
5. Per-file rationale: what branch intent was preserved, what target intent was preserved, and why the final code is safe.
6. Validation commands and PASS/FAIL/BLOCKED results.
7. Any environment blockers, waivers, or follow-ups.
8. Final state: committed merge, staged merge awaiting commit, or blocked.

If `write_report=true` or the user explicitly requested a markdown artifact, also write the same report to `report_path` when supplied, otherwise `${output_dir}/merge-conflict-resolution.md` when `output_dir` is known, otherwise `workflow/merge-conflict-resolution.md`.

Finish with a concise summary for the user:
- conflicts resolved
- important intent-preserving decisions
- validation evidence
- remaining risks or next actions
