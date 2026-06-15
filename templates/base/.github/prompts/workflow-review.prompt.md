---
name: workflow-review
description: Run a full PR review for a ticket using contract, plan, handoff, evidence, and the current diff.
tools: [read, agent, write, terminal, search]
agent: Reviewer
---

# Review Invocation (Reusable)

# Inputs
- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- output_dir: ${input:output_dir} # optional - defaults from active workflow or workflow/tickets/${ticket}
- context: ${input:context}       # optional - file path(s) to additional context (comma-separated or single path)

# 0. Resolve Inputs
Before loading context, resolve `ticket` and `output_dir`:

1. If either value was omitted, read `workflow/tickets/.active-workflow.md` and use its `ticket`, `ticket_url`, and `output_dir` values.
2. If `ticket` is a full Jira URL, extract the `PROJECT-123` ID.
3. If `output_dir` is still missing, use `workflow/tickets/${ticket}`.
4. If `context` was provided, read each listed file before reviewing.
5. Treat any additional inline instructions in the invocation, such as "run review but also consider x.md", as developer-provided context. If a file path is mentioned, read it before reviewing.
6. If `ticket` is still missing after active-state lookup, ask the user for it before proceeding.

# Context to Load
1) #read ${output_dir}/prompt.md
2) #read ${output_dir}/plan.md
3) #read ${output_dir}/handoff.md
4) #read ${output_dir}/test.md

If `${output_dir}/pre-context.md` exists, read it too.

# Diff, Build, Lint/Test, and Quality Gates (report-only)
- Run the following if terminal tools are available:
  - git fetch origin
  - git log --oneline -15          # inspect recent commits to inform the commit message
  - git diff --name-status origin/main...HEAD
  - git diff origin/main...HEAD
  - yarn nx affected --target=build # final build check for the diff
  - yarn nx lint            # or your repo lint command
  - yarn nx affected:test   # or your repo test command

- **Final build gate (blocking):**
  - First, inspect `${output_dir}/test.md` for a passing `### Final build validation` entry from implementation.
  - If the implementation build evidence is missing, stale, failed, or waived without a human note in `${output_dir}/handoff.md`, Decision = REQUEST CHANGES with an Evidence Required finding.
  - If terminal tools are available, rerun `yarn nx affected --target=build` during review. If it fails, Decision = REQUEST CHANGES.
  - If terminal tools are unavailable but implementation has passing final build evidence, note that the reviewer did not rerun the build.
  - If terminal tools are unavailable and implementation does not have passing final build evidence, Decision = REQUEST CHANGES.

- **Quality Audit (changed UI files — automatic):**
  - From the diff, identify all changed `.tsx` / `.jsx` files
  - For each, read and apply the checklist in `.github/prompts/quality-audit.prompt.md` (perf, a11y, SEO) against the **full file** — not just the diff lines
  - Flag only real issues; skip the section if no UI files changed
  - Include findings in the **Quality Audit** section of the review output (severity-rated: BLOCKER / SHOULD FIX / NICE TO HAVE)

- **Tailwind check (changed UI files only):**
  - From the diff, identify changed `.tsx` / `.jsx` files that contain `className`
  - Run `npx eslint <file>` on each — flag only violations **introduced by the diff** (cross-reference with `git diff` line numbers), not pre-existing ones
  - Include findings in the **Tailwind Violations** section; skip section if no changed UI files

- **If terminal tools are unavailable:** skip all execution steps. Note in review output: `⚠️ Terminal unavailable — diff, build, lint, and Tailwind checks could not be verified. Proceeding with static review of context files only.`

# Review Rules
- Validate AC coverage end-to-end (Contract → Plan → Evidence).
- Findings MUST reference file:path:line (or symbol) and tag AC or NFR.
- If any AC lacks evidence in test.md → Decision = REQUEST CHANGES with “Evidence Required” findings.
- If final build validation lacks passing evidence or fails in review → Decision = REQUEST CHANGES with an “Evidence Required” or “Build Failure” finding.
- Security/Perf/Observability regressions → SHOULD FIX findings.
- Keep scope tight to the diff; no broad refactors unless correctness/security requires it.

# Deliverables
1) Decision (APPROVE or REQUEST CHANGES; one sentence why)
2) Summary (3–6 bullets)
3) Findings (severity-rated, grouped by taxonomy; each with fix guidance)
   - Includes: Correctness & Types, Build Validation, Security, Performance, Accessibility/UX, React/Next.js conventions, Project Standards, Tests & Coverage, Tailwind Violations, Quality Audit
4) Suggested Follow-ups (optional)
5) Review Metadata (changed files count, affected tests, rollback)
6) Pull Request Synthesis (write to `${output_dir}/pull-request.md`) — clear, accessible format (see structure below)
7) Promotions (candidates for `.github/lessons-learned.md` or `.github/copilot-instructions.md`)

## Pull Request Synthesis Structure
Write for engineers who skim. The primary goal is a PR description someone can understand in 60-90 seconds: what changed, what behavior is protected, what is intentionally not solved, and how to verify it.

`pull-request.md` is a human-facing PR artifact. This scan-friendly style applies here, not to contract-oriented workflow files.

Tone and shape:
- Use plain headings: `The problem`, `The update`, and `How to test`.
- Keep sentences short and concrete. Prefer "This PR reduces duplicate mitigation events caused by rapid clicks" over workflow/audit phrasing.
- Keep the problem section short: what was inconsistent, broken, risky, or confusing before this change.
- Keep the update section as concise bullets ordered broad-to-specific. Start with the source-of-truth or broadest behavior change, then move toward dependent consumers.
- Avoid AC-matrix language in `pull-request.md`. Keep detailed AC traceability in the review output and `test.md`; summarize only the gaps a reviewer needs to know.
- Avoid repeating information that is obvious from the diff or GitHub Actions.
- Avoid jargon, or explain it the first time it appears.
- Keep manual testing manageable. Prefer 3-4 strong flows with expected results over exhaustive field dumps.
- Use optional short sections only when needed: `Boundaries`, `Automated checks`, or `Commit message`.

Style boundary:
- Apply this style only to `pull-request.md`.
- Keep `prompt.md`, `plan.md`, `test.md`, `handoff.md`, and `codebase-scan.md` in their existing formal, specific, traceable workflow styles.

Required structure:

### 1. Title
`# <ticket> Pull Request`

### 2. Route
`**Route:** <url> - <step in the flow>`

### 3. The problem
One short paragraph or 3-5 bullets. Explain the basic problem being fixed in human terms:
- What behavior or data was split, inconsistent, missing, duplicated, or risky?
- Which surfaces or users could observe the issue?
- Why did this matter?

### 4. The update
Five to eight concise bullets ordered from broadest/source-level change to dependent/minor changes.

Each bullet should answer:
- What changed?
- Where is the important code path?
- What remains intentionally compatible or unchanged?

For analytics, events, APIs, jobs, emails, notifications, or integrations, include the behavior in this section instead of creating a large separate block unless the PR truly needs one.

### 5. How to test
Three or four reviewer-friendly flows with steps and expected results.

Rules:
- Use imperative verbs: Sign in, Click, Visit, Submit, Verify.
- Include console/API checks only when they are the clearest verification path.
- Avoid testing every implementation detail. Choose flows that cover the changed surfaces and highest-risk states.
- Put automated test evidence in a short `Automated checks` subsection if useful.
- Put environment-blocked or intentionally skipped checks in one sentence, not a long list.

### 6. Boundaries
Optional. Include only meaningful non-goals, known baseline behavior, or follow-up tradeoffs.

### 7. Commit Message
One conventional-commit line plus a short body if useful.

## Commit Message Format
Generate a single conventional-commit message that describes what this PR does relative to the previous commits seen in `git log`.
- Format: `<type>(<scope>): <what changed>` on line 1, blank line, then 1–2 sentences of “why” if useful
- Types: `fix`, `feat`, `refactor`, `test`, `chore`, `docs`
- Scope: the affected module/component/domain (e.g. `qbank`, `nav`, `auth`)
- Subject line: max 72 chars, imperative mood, no trailing period
- Contrast with recent commits — do not repeat what was already described in the log
- Example: `fix(daily-practice): restore empty-state check on session load`

# End State
1. Write the Pull Request Synthesis section to `${output_dir}/pull-request.md`.
   - If this file does not yet exist, use `create_file` to create it.
2. Update `workflow/tickets/.active-workflow.md`:
   ```md
   # Active Workflow
   ticket: ${ticket}
   ticket_url: https://your-domain.atlassian.net/browse/${ticket}
   output_dir: ${output_dir}
   last_completed_stage: review
   next_stage: closeout
   updated_by: workflow-review
   ```
3. Announce **"Stage Complete: Review (Gate D)"**
4. Produce the exact next steps in order:

**Step A — Closeout (before pushing)**
Write the education overview and extract lessons before the branch leaves local:
```
@Architect
#read .github/prompts/workflow-closeout.prompt.md
run closeout
```

**Step B — Push branch and open PR (human action, after Closeout)**
Push the branch, open a PR in GitHub, and wait for CI to complete.

**Step C — Run Sonar Gate (after CI passes)**
Once CI has run and the PR number is known:
```
#read .github/prompts/workflow-sonar.prompt.md
run sonar
pr_number=<PR_NUMBER>
```

5. STOP and wait for human approval to proceed.
