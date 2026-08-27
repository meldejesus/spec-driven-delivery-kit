---
name: merge-conflict-resolution
description: >
  Resolve target-branch merge conflicts while preserving both sides' intent,
  auditing whether manual changes were limited to the original conflict files,
  and presenting validation evidence without creating markdown reports unless
  requested.
---

# Merge Conflict Resolution

Use this skill when a feature branch needs to merge `origin/main` or another
target branch and conflicts are likely or already present.

## Primary workflow

Use the merge-conflict prompt as the executable checklist:

```text
@merge-conflict-resolver
#read .github/prompts/merge-conflict.prompt.md

ticket=PROJECT-123
output_dir=workflow/PROJECT-123
target_branch=origin/main
merge_ref=origin/main
```

For human-facing usage details, read:

```text
.github/how-to/howToUse-merge-conflict-resolution.md
```

## Required scope audit

Every merge-conflict resolution must report:

- original conflicted files from `git diff --name-only --diff-filter=U`
- manual resolution files from `git show --remerge-diff --name-only HEAD`
- all files in the merge commit from `git diff --name-status HEAD^1..HEAD`
- whether any files outside the original conflict list were manually changed or added
- whether extra files only came from the target branch merge

Report these results in the terminal/chat by default. Write a markdown report
only when the user explicitly requests a persistent artifact or the prompt is
invoked with `write_report=true`.

## Guardrails

- Preserve both sides' intent; do not blindly take ours or theirs.
- Keep manual edits limited to conflict files unless adjacent code must change.
- If adjacent non-conflict files are changed, explain why and validate that behavior.
- Do not use destructive Git commands unless the user explicitly approves.
