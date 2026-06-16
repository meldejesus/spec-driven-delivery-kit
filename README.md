# Spec-Driven Delivery Kit

Reusable agent workflow infrastructure for ticket-driven, evidence-gated delivery.

This repository is the source for files that get installed into a working
project. Normal ticket work should happen in the target workspace after install,
not in this repository.

## What This Is

The kit packages a Jira-to-PR style workflow:

```text
Contract -> Plan -> Implement -> Review -> Closeout -> Sonar
```

The installed workspace shape is the contract:

```text
workspace/
  AGENTS.md
  .github/
    agents/
    prompts/
    skills/
    how-to/
  .copilot/
  workflow/
    tickets/
    pointing/
    spikes/
    code-review/
    messages/
```

Agents and prompts assume those paths exist relative to the workspace root.

## Repository Layout

```text
docs/                         Kit documentation.
install/                      Installer scripts.
templates/base/               Core files installed into a target workspace.
extensions/                   Optional workflow extensions.
examples/                     Public-safe examples only.
```

Core installable files live under:

```text
templates/base/
  AGENTS.md
  .github/
  .copilot/
  workflow/
```

Optional extensions currently include:

```text
extensions/cleanup/
extensions/codex/
extensions/worklog/
```

## Install Into A Workspace

Dry run:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --dry-run
```

Install core workflow discovery files:

```bash
./install/install-to-workspace.sh --target /path/to/workspace
```

Install core files plus optional extensions:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --all
```

Use symlinks for local kit development:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode symlink --all
```

Use copy mode for a self-contained workspace:

```bash
./install/install-to-workspace.sh --target /path/to/workspace --mode copy --all
```

The installer does not overwrite existing files unless `--force` is passed.

## Why The Layout Works

Most AI tools discover instructions from the current directory or its parents.
They generally will not discover a sibling kit repository.

That means the kit source can be organized cleanly, but the installed workspace
must still expose:

```text
AGENTS.md
.github/
.copilot/
workflow/
```

As long as installation produces that shape, the workflow runs the same way.

## Private Overlays And Archives

Keep reusable workflow machinery separate from private work history.

Recommended split:

```text
spec-driven-delivery-kit/          Reusable kit source.
spec-driven-delivery-overlay/      Project/team-specific instructions.
workflow-archive-private/          Real ticket artifacts and worklog history.
```

Do not publish real Jira tickets, private worklog history, raw logs, CSV exports,
HAR files, screenshots, production payloads, credentials, or internal links in a
public kit.

## Public Readiness

This repository layout is public-friendly, but content still needs a public
readiness pass before changing visibility:

- move project-specific examples out of public history or into a private overlay
- replace real ticket IDs with neutral examples
- remove internal URLs and company-specific paths
- keep only generic workflow docs, prompts, agents, skills, and templates

See `docs/structure.md` for the source-vs-installed model.
