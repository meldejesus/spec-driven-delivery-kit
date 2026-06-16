# Workflow Scan Registry

Tracks which product or codebase workflows have been scanned for tech debt,
their priority, and sub-workflow completion status. Customize this file for the
installed workspace.

## Priority Order

| # | Workflow | Priority Rationale | Scan Status | Ticket File |
|---|---|---|---|---|
| 1 | `<workflow-name>` | Why this area matters | Pending | - |

## Sub-Workflow Scan Status

### <workflow-name>

| Sub-workflow | Key Files | Scan Status | Notes |
|---|---|---|---|
| `<sub-workflow>` | `path/to/file.ts` | Pending | - |

## How to Run a Scan

```text
Use .github/prompts/tech-debt-scan.prompt.md
Set workflow = <workflow name from table above>
Set sub_workflow = <optional sub-workflow to target>
```

Saved output path:
`workflow/pointing/tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md`

To convert ticket drafts into assessment-ready pointing output:

```text
Use .github/prompts/pointing-plan.prompt.md
Set mode = tech-debt
Set source_file = workflow/pointing/tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
```

## Notes

- "Done" means ticket drafts exist; it does not mean work is shipped.
- "Partial" means some sub-workflows have been scanned and others are pending.
- Scan order can change. Edit the priority column and re-sort when needed.
