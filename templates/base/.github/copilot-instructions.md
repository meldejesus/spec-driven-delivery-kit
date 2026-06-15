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
- Use `workflow/tickets/<PROJECT-123>/` for durable task-local artifacts.
- Each ticket directory should begin with `index.md`, a searchable front door
  containing the ticket ID, title, summary, search terms, related paths, related
  links, and artifact map.

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
