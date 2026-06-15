---
name: workflow-sonar
description: >
  Optional post-CI quality gate that queries SonarQube for a specific PR after
  CI has run. Requires project-specific SonarQube environment variables.
---

# Sonar Gate

Run this after the branch is pushed, the PR is open, and CI has completed.

## Inputs

- `ticket`: e.g. `PROJECT-123`
- `pr_number`: GitHub PR number

If `ticket` is omitted, read `workflow/tickets/.active-workflow.md`.

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
