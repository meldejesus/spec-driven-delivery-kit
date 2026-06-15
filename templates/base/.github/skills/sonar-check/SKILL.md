---
name: sonar-check
description: >
  Query a configured SonarQube project for code quality or coverage signals.
  Requires SONAR_TOKEN, SONAR_HOST_URL, and SONAR_PROJECT_KEY.
---

# SonarQube Check

Use this skill only when the workspace has SonarQube configured.

## Required Environment

```bash
test -n "$SONAR_TOKEN"
test -n "$SONAR_HOST_URL"
test -n "$SONAR_PROJECT_KEY"
```

Do not print token values.

## Scope

Ask for scope if it is not provided:

- PR number
- specific file or component
- overall project summary

## Query

Use read-only `curl` calls against `$SONAR_HOST_URL`. Pass auth as:

```bash
-u "$SONAR_TOKEN:"
```

For PR checks, query issues and coverage for `$SONAR_PROJECT_KEY` and the PR
number. Report findings by severity and include exact file/line references when
available.

## Safety

- Do not generate or store tokens.
- Do not print secrets.
- Do not apply fixes without explicit user approval.
