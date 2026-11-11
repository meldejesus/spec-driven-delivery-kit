---
name: mermaid-diagram
description: Create or revise Mermaid diagrams from a target source file, directory, workflow, or written description, validate them against the project's compatibility profile, and generate print-safe SVG and PDF exports. Use when the user asks for a Mermaid diagram, flowchart, sequence diagram, architecture map, Mermaid syntax repair, or a printable Mermaid artifact.
---

# Mermaid Diagram

Create diagrams that explain the source accurately and render reliably in the
project's Markdown viewers and print reliably outside the browser. Prefer a
small, conservative diagram over Mermaid syntax that depends on a newer
renderer.

## Inputs

Use the target named by the user. A target may be a source file, directory,
Markdown document, workflow description, or existing Mermaid block. If no
output location is specified, place a new diagram beside the primary target in
a clearly named Markdown file. Do not modify application code unless requested.

Before drawing, read enough surrounding code or documentation to identify:

- the diagram's audience and question;
- the important actors, states, or processing stages;
- the direction of control or data flow;
- uncertainty that must be labeled rather than invented.

## Compatibility Profile

Use the renderer-safe subset documented in
`../../../docs-in-progress/meta/mermaid-troubleshooting.md`.

- Prefer `flowchart TD`, `flowchart LR`, or `sequenceDiagram`.
- Quote descriptive labels: `A["Readable label"]`.
- Put one connection on each line.
- Use simple node IDs containing letters, digits, and underscores.
- Use plain text in labels; reword comparisons and code expressions.
- Close every nested `subgraph` with its own `end`.
- Keep styling optional and minimal; meaning must survive without color.
- Split a crowded diagram instead of relying on advanced layout features.

### Print-Safe Rendering

Mermaid's HTML labels render inside SVG `<foreignObject>` elements. Some macOS,
Preview, PDF, and printer paths drop those labels while preserving shapes,
arrows, or numeric artifacts. Do not treat an SVG as printable merely because
it looks correct in a browser.

For flowcharts, place this directive immediately before `flowchart TD` or
`flowchart LR`:

```text
%%{init: {"theme": "default", "look": "classic", "htmlLabels": false, "flowchart": {"useMaxWidth": false}}}%%
```

The root-level `htmlLabels` setting is intentional; diagram-specific
`flowchart.htmlLabels` is deprecated and may be ignored by newer Mermaid
versions. `classic` avoids the Neo flowchart renderer's HTML-label defaults,
and `useMaxWidth: false` gives standalone SVGs explicit dimensions that print
more predictably.

Sequence diagrams usually emit native SVG `<text>`, but they must still pass
the same print-safety validation. Do not add editor extensions to solve an
export defect; use the pinned CLI scripts so the renderer is deterministic.

Do not use syntax merely because the selected CLI accepts it. The diagram must
also satisfy this conservative profile for embedded GitHub, Confluence, and VS
Code renderers.

## Workflow

1. Inspect the target and state the diagram's intended question in one sentence.
2. Choose the smallest diagram type that answers that question.
3. Create or update the Mermaid block using the compatibility profile.
4. For flowcharts, add the print-safe initialization directive above.
5. Run `scripts/validate-mermaid.sh <diagram-or-markdown-file>` from this skill.
   Validation fails when an SVG contains `<foreignObject>` unless the output is
   explicitly screen-only and `MERMAID_ALLOW_FOREIGN_OBJECT=1` is set.
6. If validation fails, correct the source and rerun until it passes.
7. Run `scripts/export-printable-mermaid.sh <diagram-or-markdown-file>`. By
   default it writes generated SVG and PDF files under
   `printable/<source-name>/` beside the source.
8. Visually inspect every generated PDF. When Poppler is available, render each
   PDF with `pdftoppm -png` and inspect the PNG. Confirm that labels, arrows,
   line breaks, page dimensions, and contrast are readable.
9. Review the rendered relationships against the target; syntax validity alone
   is not evidence that the diagram is accurate.
10. Report the source path, printable PDF path or paths, diagram type,
    validation version, and any labeled uncertainty.

Validation is complete only when the script exits successfully. If the intended
viewer uses a different Mermaid version, rerun with an exact version:

```bash
MERMAID_CLI_VERSION=<version> \
  .github/skills/mermaid-diagram/scripts/validate-mermaid.sh <file>
```

If the exact viewer version is unknown, use the default pinned version and the
conservative profile, then say that viewer-specific validation remains unknown.

To write printable artifacts somewhere else, pass an output directory:

```bash
.github/skills/mermaid-diagram/scripts/export-printable-mermaid.sh \
  path/to/diagram.md path/to/output-directory
```

For Markdown containing multiple Mermaid blocks, the exporter creates one
numbered SVG and PDF per diagram. PDF is the canonical printing artifact; SVG
is retained for scalable embedding and inspection. PDFs use Mermaid CLI's
`--pdfFit` mode so the page matches the chart instead of adding blank Letter
pages. In the printer dialog, use **Fit to page** for a single-sheet copy or
the printer's poster/tile option when a tall or wide diagram needs readable
multi-page output.

## Output

Return a fenced `mermaid` block inside Markdown unless the user requests a
standalone `.mmd` file. Also create the printable exports unless the user
explicitly requests source only. Keep explanatory text outside the diagram
concise.
