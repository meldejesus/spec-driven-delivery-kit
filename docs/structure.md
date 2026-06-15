# Structure

The kit has two shapes:

1. Source repository shape.
2. Installed workspace shape.

The source repository is organized for maintenance and eventual public sharing:

```text
docs/
install/
templates/base/
extensions/
examples/
```

The installed workspace is organized for agent discovery:

```text
workspace/
  AGENTS.md
  .github/
  .copilot/
  workflow/
```

Agents read files relative to the active workspace. They do not automatically
look inside a sibling kit repository.

The installer bridges those two shapes by copying or symlinking files from
`templates/base/` and selected `extensions/` into the target workspace.

## Core

`templates/base/` contains the minimum workflow files:

- `AGENTS.md`
- `.github/agents/`
- `.github/prompts/`
- `.github/skills/`
- `.github/how-to/`
- `.copilot/`
- `workflow/`

## Extensions

Extensions are useful but not required for the core Contract -> Plan ->
Implement -> Review -> Closeout workflow.

Current extensions:

- `extensions/messages/`
- `extensions/standup/`

Install them with:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --all
```

## Private Material

Live ticket outputs and logs should live in private archives, not in the public
base template:

```text
workflow-archive-private/
  workflow/tickets/
  workflow/pointing/
  standup/daily-log.md
```
