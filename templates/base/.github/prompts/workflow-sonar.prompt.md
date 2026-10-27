---
name: workflow-sonar
description: >
  Optional post-CI quality gate that queries SonarQube for a specific PR after
  CI has run. Requires project-specific SonarQube environment variables.
---

## Writing Requirements — All Agents

Before writing or updating this stage's artifacts, read
`docs/writing-style-guide.md` if the workspace provides it. Otherwise, read
`.github/skills/writing-style-guide/SKILL.md`. Apply the guide while drafting,
then check clarity and technical accuracy before saving or handing off.

Explain what changes, why, and what the reader should do in plain language.
Keep the required document structure, acceptance criteria, task IDs,
dependencies, exact identifiers, paths, commands, expected results, evidence,
and approval boundaries. Keep proposals, completed work, and unverified checks
distinct. Write only the artifacts this stage authorizes; style cleanup must
not change scope or add another approval gate.

# Sonar Gate

Run this after the branch is pushed, the PR is open, and CI has completed.

## Inputs

- `ticket`: e.g. `PROJECT-123`
- `pr_number`: GitHub PR number

If `ticket` is omitted, read `workflow/.active-workflow.md`.

## Required Environment

Set these in the local shell before running:

```bash
export SONAR_TOKEN="..."
export SONAR_HOST_URL="https://sonarqube.example.com"
export SONAR_PROJECT_KEY="your-project-key"
```

Never print `SONAR_TOKEN`.

## Fetch PR Data

Use read-only SonarQube API calls:

```bash
curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/issues/search?projectKeys=$SONAR_PROJECT_KEY&pullRequest=${pr_number}&types=CODE_SMELL,BUG,VULNERABILITY&severities=BLOCKER,CRITICAL,MAJOR&ps=50"
```

```bash
curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/measures/component?component=$SONAR_PROJECT_KEY&pullRequest=${pr_number}&metricKeys=coverage,line_coverage,branch_coverage,uncovered_lines,uncovered_conditions"
```

## Report

Report:

- blocking issues by severity
- files and line numbers when available
- coverage summary
- whether the gate is `PASSED` or `BLOCKED`

Do not fix code from this prompt. If fixes are needed, hand off to the normal
implementation workflow.
