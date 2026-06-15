---
name: docs-audit
description: >
  Run or review a project's documentation audit using its local audit command
  and report format.
---

# Docs Audit

Use this skill when the user asks to run a docs audit or triage audit findings.

## Workflow

1. Locate the project's docs audit command in package scripts, task runner config,
   or docs tooling.
2. Run the audit if it is available and safe to run locally.
3. Read the latest report.
4. Classify findings:
   - mechanically verified broken links, paths, schema names, or source refs
   - stale prose that needs source verification
   - content-fit candidates that need human judgment
5. Fix only the requested scope.
6. Re-run the audit when practical and report remaining findings.
