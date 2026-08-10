---
name: pr-diff-scope-summary
description: >
  Audit a PR or branch diff to distinguish essential ticket changes from
  housekeeping or out-of-scope changes, then produce a concise grouped file
  change summary suitable for a PR description.
---

# PR Diff Scope Summary

Use this skill when the user asks what changed in a PR, which files are
essential to the ticket, which changes are housekeeping/non-essential, or asks
for a concise file-change explanation list.

## Workflow

1. Identify the diff base. Default to `main...HEAD` unless the user gives a PR,
   branch, or commit range.
2. Read the changed file list and diff stats first:
   - `git diff --name-status <base>`
   - `git diff --stat <base>`
3. Inspect representative diffs for unclear files before classifying them.
4. Do not edit files unless the user explicitly asks.
5. Classify changes into:
   - essential ticket behavior
   - supporting infrastructure required by the behavior
   - tests
   - housekeeping / not core to the ticket
   - suspicious or removable scope creep
6. Call out uncertainty plainly when intent cannot be proven from the diff.

## Output Rules

Default output should be concise and PR-description friendly.

- Use short grouped bullets, not full file paths.
- Prefer the last one or two meaningful path segments before the file name.
- If a group has only one file, use one bullet with the file name.
- If a group has multiple related files, use a parent bullet and sub-bullets.
- Do not include tests in the main essential list unless the user asks.
- Do not include snapshots unless they are essential to understand the change.
- Use hyper-concise role statements, usually 5-12 words.
- Keep housekeeping separate from essential changes.

## Essential List Format

Use this shape when the user asks for essential files changed:

```md
## Essential Files Changed

- `search/ranking`
  - `ranking.jade` - Admin UI for the workflow.
  - `ranking.js` - Client-side workflow state and actions.
  - `ranking.less` - Styling for the revised UI.

- `routes/admin/post`
  - `adminSaveThing.ts` - Saves the admin action.
  - `adminRunThing.ts` - Queues the background job.

- `domain/module.ts` - Core runtime behavior change.
```

## Housekeeping List Format

Use this shape when the user asks what is not essential:

```md
## Housekeeping / Not Core

- `core/startup` - Guard added while stabilizing local admin errors.
- `config/winston` - Generic process argv fallback and test.
- `.gitignore` - Local tooling ignore entry.
- `README.md` - Whitespace/newline cleanup only.
```

## Classification Guidance

Essential changes directly implement the ticket outcome, data model, runtime
behavior, user workflow, background job, or required cache invalidation.

Supporting changes are acceptable when they are required to test, run, or
stabilize the ticket flow.

Housekeeping is usually formatting, unrelated docs cleanup, generic hardening,
tooling ignore entries, or changes motivated by CI rather than the ticket.

Suspicious scope creep includes new behavior in unrelated routes, broad global
middleware, unrelated schema drift, unrelated dependency changes, or generic
refactors bundled with the ticket.
