# Agent Instructions For This Kit Repo

This repository is the source for an installable spec-driven delivery workflow.

When editing this repo:

- Keep the installed workspace contract stable:
  - `templates/base/AGENTS.md`
  - `templates/base/.github/`
  - `templates/base/.copilot/`
  - `templates/base/workflow/`
- Do not put live ticket artifacts, standup logs, credentials, raw exports, or
  internal project details into the reusable base template.
- Put optional workflow tooling under `extensions/`.
- Put non-core examples under `examples/`, and keep private examples out of any
  public release.
- After changing layout or install behavior, run:

```bash
./install/install-to-workspace.sh --target /private/tmp/spec-kit-install-check --dry-run
bash -n install/install-to-workspace.sh
```

The installed workspace should still expose:

```text
AGENTS.md
.github/
.copilot/
workflow/
```
