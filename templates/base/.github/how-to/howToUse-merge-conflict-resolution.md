# Merge Conflict Resolution Workflow

Use this when a feature branch needs to merge `origin/main` or another target
branch and preserve both sides' intent.

**Agent:** `@merge-conflict-resolver`

**Prompt:** `.github/prompts/merge-conflict.prompt.md`

---

## When To Use This

Use this workflow when:

- a ticket branch is behind `origin/main`
- GitHub reports conflicts before a PR can merge
- `git merge origin/main` produced conflicts
- main changed files that overlap ticket behavior
- a stacked branch needs to preserve parent and child intent
- a conflict was resolved once already but main moved again

For routine fast-forward pulls or unrelated branch cleanup, use normal Git.

---

## Normal Invocation

```text
@merge-conflict-resolver
#read .github/prompts/merge-conflict.prompt.md

ticket=PROJECT-123
output_dir=workflow/tickets/PROJECT-123
target_branch=origin/main
merge_ref=origin/main
context=<anything important about the conflict>
```

If `workflow/tickets/.active-workflow.md` is current, `ticket` and
`output_dir` can be omitted:

```text
@merge-conflict-resolver
#read .github/prompts/merge-conflict.prompt.md

target_branch=origin/main
```

---

## Expected Process

The agent should:

1. Check branch state, ahead/behind count, merge base, and local changes.
2. Read the ticket artifacts and any supplied context.
3. Compare branch intent with target-branch intent.
4. Merge with `git merge --no-commit <merge_ref>` unless a merge is already in progress.
5. Resolve conflicted files by composing behavior, not blindly choosing ours or theirs.
6. Inspect important auto-merged files that changed on both branches.
7. Audit the scope: compare the original conflict list with the final manual-resolution file list.
8. Run focused tests for the conflict surface and a final affected build when feasible.
9. Present the resolution report in the terminal/chat.
10. Commit the merge only after validation passes, unless the user asked for a plan only.

---

## Resolution Report

By default, the agent should not create a markdown report file. It should present
the conflict inventory, scope audit, rationale, validation evidence, and final
state directly in the terminal/chat response.

Only write a markdown report when the user explicitly asks for a persistent
artifact or when invoking the prompt with `write_report=true`.

When a markdown report is requested, write it to `report_path` if supplied.
Otherwise use:

```text
workflow/tickets/PROJECT-123/merge-conflict-resolution.md
```

If there is no ticket output directory, use:

```text
workflow/merge-conflict-resolution.md
```

The report should include:

- target branch, merge ref, current branch, merge base, and ahead/behind count
- context files read
- conflict inventory
- scope audit:
  - original conflicted files
  - files manually changed to resolve the merge
  - whether anything outside the original conflict list was manually changed or added
  - which extra files only came from the target branch merge
- per-file resolution rationale
- validation commands and results
- environment blockers or follow-ups
- final state: committed, staged awaiting commit, or blocked

---

## Validation Checklist

Always run:

```bash
git diff --name-only --diff-filter=U
git diff --check
```

After the merge commit, also run:

```bash
git show --remerge-diff --name-only HEAD
git diff --name-status HEAD^1..HEAD
```

Report the distinction clearly:

- `git show --remerge-diff --name-only HEAD` is the best signal for files manually resolved.
- `git diff --name-status HEAD^1..HEAD` includes upstream target-branch files brought in by the merge.

Then run checks that match the conflict surface:

- frontend conflicts: focused component/page tests and app build
- backend conflicts: focused service/route tests
- shared type conflicts: typecheck or affected build
- broad target-branch merges: affected build against the target branch

Example:

```bash
yarn nx affected --target=build --base=origin/main
```

If the repo uses a different command form, use that local equivalent and record
why.

---

## Before Push

Confirm:

- no conflict markers remain
- unrelated local changes were not overwritten
- target-branch fixes were preserved
- any files outside the original conflict list are explained
- ticket acceptance criteria still have evidence
- environment-blocked checks are clearly documented
- the merge commit exists if the task was to complete the merge
