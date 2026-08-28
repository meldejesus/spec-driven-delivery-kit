# Workflow Workspace

This directory stores live workflow artifacts after the kit is installed into a
workspace. Each ticket gets a single directory so all related artifacts — contract,
plan, implementation, and spike research — stay together.

Use `TAGS.md` at the workspace root to keep a stable topic-tag vocabulary for
cross-ticket and archive retrieval.

## Structure

```text
workflow/
├── OSMS-1234/           # full ticket work
├── OSMS-1234-2/         # follow-up on same ticket (index.md has related_to: OSMS-1234)
├── misc/                # ad-hoc, one-off, or non-ticket items (standalone PR reviews, batch refinement output)
├── future-tickets/      # queued/planned future work
├── .active-workflow.md
├── TAGS.md
├── README.md
└── index.md
```

## Implementation Tickets

Typical implementation ticket output:

```text
workflow/TICKET-123/
  index.md
  prompt.md
  reproduce.md
  codebase-scan.md
  plan.md
  handoff.md
  test.md
  pull-request.md
  overview.md
  lessons-learned.md
```

Each ticket directory starts with `index.md`, a searchable front door containing
ticket metadata, summary, search terms, related paths, related links, and the
artifact map.

`workflow/.active-workflow.md` is generated during a workflow run.

## Follow-up Workflows

When follow-up work is needed on the same ticket (for example, a second PR,
a post-merge fix, or a separate phase of work), create a new directory with a
numeric suffix:

```text
workflow/TICKET-123/    # original work
workflow/TICKET-123-2/  # follow-up
workflow/TICKET-123-3/  # another follow-up
```

The follow-up directory's `index.md` includes a `related_to:` field in its
frontmatter linking back to the original:

```yaml
related_to: TICKET-123
```

This preserves the story in separate, searchable directories while keeping the
lineage explicit.

## Spike (Research) Tickets

Spike artifacts live inside the ticket directory under a `spike/` subdirectory:

```text
workflow/TICKET-123/spike/
  index.md
  scope.md
  findings.md
  spike-output.md
  explained.md
  overview.md
```

Use this lane for research that answers a question before deciding whether to
build something. Keeping spikes inside the ticket directory preserves the full
story in one place.

> **Note:** A legacy `workflow/spikes/` top-level directory may exist in older
> workspaces. That layout is deprecated. New spike work goes in
> `workflow/<ticket-id>/spike/`.

## Misc (Ad-hoc and Non-ticket Work)

One-off work that is not tied to a specific ticket belongs under `workflow/misc/`:

```text
workflow/misc/
  <repo>-pr-<number>/      # standalone PR review output
    index.md
    triage.md
    review.md
    verdict.md
    testing-notes.md
  ticket-assessment-YYYY-MM-DD.md    # batch refinement output
  <sprint-slug>.md                   # sprint refinement output
  tech-debt-<workflow>-<sub-workflow>-YYYY-MM-DD.md
  tech-debt-tickets.md
  workflow-scan-registry.md
```

Use `misc/` for:
- Standalone PR reviews (not your own ticket's review — that stays in `workflow/TICKET-123/`)
- Batch or sprint refinement output that spans multiple tickets
- Tech debt scan output
- Any ad-hoc artifact that does not belong to a specific ticket

## Future Tickets

Queued or planned work that has not started yet belongs under `workflow/future-tickets/`:

```text
workflow/future-tickets/
  TICKET-456-notes.md
  backlog-candidates.md
```

Use this directory to park pre-work, scoping notes, or early research for tickets
that are not yet active. When a ticket moves into active development, start its
standard directory at `workflow/TICKET-456/`.

## Topic Tags

Use lightweight tags to group related artifacts across tickets, spikes, and
misc outputs.

- Keep canonical tag definitions in `TAGS.md`.
- Add `- tags:` metadata in ticket or spike `index.md` files.
- Optionally add inline hashtags (for example, `Tags: #topic-a #topic-b`) in
  entry-point docs.
