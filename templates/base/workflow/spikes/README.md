# Spike Artifacts (Deprecated Top-Level Directory)

> **This directory layout is deprecated.**
>
> Spike artifacts now live inside the ticket directory:
> `workflow/<ticket-id>/spike/`
>
> Keep implementation ticket delivery in `workflow/<ticket-id>/`.

## New convention

```text
workflow/PROJECT-123/spike/
  index.md
  pre-context.md
  scope.md
  findings.md
  spike-output.md
  explained.md
  overview.md
```

Placing spike artifacts inside the ticket directory keeps all related work
together: contract, plan, implementation, and research live in one place and
share a single ticket ID.

## Why the change

The old layout (`workflow/spikes/PROJECT-123/`) required looking in multiple
top-level directories to understand a ticket's full history. The new layout
(`workflow/PROJECT-123/spike/`) collapses everything into the ticket directory
so search, restore, and archival all target one folder.

## Legacy artifacts

Any existing artifacts under this directory are from before the convention
change. They remain valid; no migration is required unless you want to
consolidate them.
