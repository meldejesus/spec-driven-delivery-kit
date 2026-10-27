# Workspace Instructions

This file is installed from the spec-driven delivery kit into a project
workspace. Treat it as a starting point and adapt project-specific paths,
commands, documentation links, and domain rules after installation.

## Tool Preferences

- Use `rg` or `rg --files` for text and file searches.
- Prefer the workspace's existing scripts, test commands, and helper APIs.
- Read nearby code before changing behavior.
- Keep edits scoped to the requested task.

## Source Of Truth

- Code is the source of truth when docs and implementation disagree.
- If docs appear stale, call out the discrepancy and offer a docs update.
- Record reusable implementation lessons in `.github/lessons-learned.md` only
  when they are broadly useful for future work.

## Context Management

- Do not load broad docs folders by default.
- Read only the specific docs, source files, or workflow artifacts needed for
  the current task.
- Use `workflow/<PROJECT-123>/` for durable task-local artifacts.
- Each ticket directory should begin with `index.md`, a searchable front door
  containing the ticket ID, title, summary, search terms, related paths, related
  links, and artifact map.

## Workflow Writing

Before creating or updating workflow prose, read the workspace writing style
guide when one is provided. Otherwise, use
`.github/skills/writing-style-guide/SKILL.md`. Apply it while drafting contracts,
plans, codebase scans, handoffs, test/evidence notes, reviews, pull requests,
spike findings, and closeout documents.

Write so the user can review the document and an agent can act on it:

- Lead with the problem, intended behavior, or current state. Explain what
  changes and why before giving implementation detail.
- Use short, concrete headings and direct sentences. Explain an unfamiliar
  technical term through its effect; keep identifiers exact.
- Preserve the required artifact structure, acceptance criteria, task IDs,
  dependencies, file paths, commands, expected results, evidence links, and
  approval boundaries. Plain language must not remove implementation detail.
- Keep facts, proposals, assumptions, completed work, and unverified checks
  distinct. A style edit must not change scope, decisions, or test results.
- Before saving or handing off, check both readability and meaning against
  the source. Clarify dense prose while preserving required detail. During
  implementation, keep journal entries brief and retain existing audit history.

This check is part of each existing writing step. It adds no approval gate,
mandatory separate agent, or extra workflow artifact. Keep each document's
required shape; a short PR description does not replace a contract's criteria
or a plan's executable checklist.

## Implementation Standards

- Follow existing project conventions before introducing new abstractions.
- Prefer clear, testable code over cleverness.
- Add comments only when they explain non-obvious intent or constraints.
- Avoid unrelated refactors while implementing a ticket.

## Verification

- Use the project's established test, lint, typecheck, and build commands.
- When commands are unknown, inspect package scripts, task runners, or existing
  CI config before guessing.
- If a verification command cannot run locally, document why and what evidence
  remains.

## Accessibility And UX

- Prefer semantic HTML and accessible primitives.
- Interactive controls need keyboard support, focus visibility, and accessible
  names.
- Do not rely on color alone to communicate state.
- Keep UI text and controls responsive across expected viewport sizes.
