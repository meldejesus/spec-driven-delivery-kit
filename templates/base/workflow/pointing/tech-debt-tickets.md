# Tech Debt Ticket Reference

This file defines the canonical ticket format used by the `tech-debt-scan`
prompt. Project workspaces can customize the workflow names, examples, and
effort rubric after installation.

Saved scan outputs are written alongside this file as:
`workflow/pointing/tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md`

## Canonical Ticket Structure

```markdown
### TICKET: [Short imperative title, <=10 words]

**Workflow:** <workflow-or-product-area>

**Problem**
One paragraph. Explain why this is a problem in terms of user impact, data
integrity, operational risk, or maintainability.

**Current Behavior**
What the code does today. Be specific: file path, function name, and the exact
problematic pattern when known.

**Proposed Fix**
Concrete implementation guidance. Describe the change direction, but do not
prescribe a full solution.

**Files Affected**
- `path/to/file.ts` - reason

**Effort:** S | M | L
- **S** = isolated change, no cross-cutting concerns (<= 2 files)
- **M** = touches 2-4 files or requires understanding a subsystem
- **L** = architectural change, cross-app impact, or high test surface
```

## Debt Categories

| Tag | Description |
|---|---|
| `missing-error-handling` | Silent failures, missing recovery paths, missing error UI |
| `performance` | Avoidable latency, duplicated calls, unbounded queries |
| `complexity` | Large functions, deeply nested flows, mixed responsibilities |
| `null-safety` | Unguarded optional data, unsafe array/object access |
| `stale-abstraction` | Duplicated logic, dead code, unreplaced legacy patterns |
| `ux-flow-gap` | Missing empty/loading/error states or unclear user feedback |

## Effort Rubric

| Size | Story Points | Typical scope |
|---|---|---|
| S | 1 | Single file, clear fix, no subsystem knowledge required |
| M | 2 | 2-4 files, moderate logic change, some test updates |
| L | 3 | Cross-app or architectural, broad test surface, design decision needed |

The `pointing-analyst` uses this rubric when converting tech-debt ticket drafts
into ticket assessment output.
