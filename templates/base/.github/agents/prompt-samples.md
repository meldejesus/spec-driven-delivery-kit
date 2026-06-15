Here’s a polished **Markdown** document you can drop in as `prompt-samples.md`.
It’s clean, copy‑pasteable, and organized for quick scanning in your repo.

***

# Prompt Samples

Quick‑start prompts for our custom Copilot agents. Use these as starting points and tailor to the task at hand.

***

## 🧱 Architect — Sample Prompts

### High‑level design exploration

    @architect
    We are adding a new feature: <feature summary>.
    Produce an Architecture Note with:
    - Proposed design approaches
    - Tradeoffs & risks
    - Integration points with existing Nx libs/apps
    - Testing implications
    - Non-goals

### Interface & boundary planning

    @architect
    Define the boundaries and contracts between:
    - <module A>
    - <module B>

    Assume Nx monorepo conventions. Provide a diagram or structured bullets.

***

## 🧪 Tester — Sample Prompts

### Design edge‑case coverage

    @tester
    Given this change: <paste diff or file>, design test scenarios:
    - Happy path
    - Edge cases / boundary conditions
    - Error handling
    - Race conditions (if relevant)
    Classify what belongs in unit vs integration tests.

### Write tests for a component or function

    @tester
    Write Jest + React Testing Library tests for <component|function>.
    Follow Nx project layout and existing testing patterns. Do not modify production code unless necessary.

### Identify affected tests

    @tester
    Given these changes <summary or diff>, list:
    - Which tests are affected and must be updated
    - Which new tests should be added
    Explain the rationale briefly.

***

## 🛠️ Developer (Agent‑Like Implementor) — Sample Prompts

### Implement feature steps from a plan

    @developer
    Implement Step 1 and Step 2 of this plan:
    <plan text>

    Scope:
    - Only modify these files: <list>
    - Non-goals: <list>

    Plan → ask → edit → checkpoint → run yarn nx affected:test → summarize.

### Small refactor with checkpoints

    @developer
    Refactor <file or function> to improve clarity and reduce duplication.
    Scope: only that file.
    Plan first and wait for approval. Execute step-by-step with checkpoints and Nx validation.

### Address reviewer feedback (BLOCKER/SHOULD FIX only)

    @developer
    Apply only BLOCKER and SHOULD FIX items from this review:
    <review text>
    Plan the minimal edits, ask for approval, then proceed with Nx lint/format/affected tests.

### Multi‑file update with safety rails

    @developer
    Update modules to use <new util>:

    Files:
    - libs/core/src/foo.ts
    - libs/shared/src/bar.ts

    Plan → ask for confirmation → apply stepwise → yarn nx affected:test → summarize diffs & risks.

***

## ✍️ Writer‑Standards (Strict, Approval‑Gated) — Sample Prompts

### Apply approved merge or patch

    @writer-standards
    Apply only the approved hunks in:
    apps/next-webapp/src/app/.../topics-selection.tsx

    Wait for "Yes, apply now" before editing.
    After edits:
    - yarn nx lint --fix
    - yarn prettier . --write
    - yarn nx affected:test
    Provide a PR-style summary (what/why/risks/tests).

### Apply an exact plan

    @writer-standards
    Apply this plan exactly, no scope expansion:
    <plan>

    Ask for “Yes, apply now” before editing.
    Then lint/format/affected tests and summarize results.

### Surgical fix only

    @writer-standards
    Fix only the issue described below, with no other changes:
    <bug description>

    Await approval, then apply minimal diff, validate with Nx, and summarize.

***

## 🔍 Reviewer (PR‑Aware) — Sample Prompts

### Full PR review (diff vs main)

    @reviewer
    Review the entire diff vs origin/main.

    PR description:
    <text>

    Return:
    - DECISION: APPROVE or REQUEST CHANGES
    - Summary (3–6 bullets)
    - Findings with severity (BLOCKER / SHOULD FIX / NICE TO HAVE)
    - “Counts toward disapproval: Yes/No” for each finding
    - Concrete fix guidance per finding

### File‑focused PR review

    @reviewer
    Analyze only this file vs origin/main:
    <path>

    PR summary:
    <text>

    Produce Decision + Structured Findings as above.

### Review with team standards context

    @reviewer
    Using our team standards and React/Next.js conventions (see .github/copilot-instructions.md),
    evaluate the diff vs main for:
    - Correctness & Types
    - Security
    - Performance
    - Accessibility/UX
    - React/Next.js conventions
    - Project Standards (ESLint/Prettier/Nx boundaries)
    - Tests & Coverage

    Return Decision + severity-rated findings.

***

## 🔀 Merge‑Conflict Resolver — Sample Prompts

### Analyze conflicts and propose options

    @merge-conflict-resolver
    Analyze this conflicted file and propose resolution options (A/B/C) with consequences.
    Summarize OURS vs THEIRS intent per hunk.
    Ask clarifying questions if intent is unclear.
    <conflict block here>

### Produce a resolution plan only

    @merge-conflict-resolver
    For the conflict in <path>, provide:
    1) Hunk inventory
    2) Intent of OURS vs THEIRS
    3) Options A/B/C with tradeoffs
    4) Your recommended merge approach (no edits)

***

## 🔀✍️ Applying Merge‑Conflict Resolutions — Sample Prompts

### Apply a chosen resolution option

    @writer-standards
    Apply Option <A|B|C> from the merge-conflict-resolver analysis to:
    <path>

    Wait for “Yes, apply now” before editing.
    After applying:
    - yarn nx lint --fix
    - yarn prettier . --write
    - yarn nx affected:test
    Summarize the rationale and the resulting diff.

***

## 🧭 End‑to‑End Example Flow

### Plan → Implement → Review → Apply

    @feature-planner
    Plan the new feature <feature>. Provide steps, risks, and files to touch.

<!---->

    @developer
    Implement Step 1 and Step 2 from the planner output.
    Plan → ask → edit → checkpoint → yarn nx affected:test → summarize.

<!---->

    @reviewer
    Review the diff vs origin/main and return Decision + severity-rated findings.

<!---->

    @writer-standards
    Apply all BLOCKER and SHOULD FIX items from the review.
    Wait for “Yes, apply now,” then lint/format/affected tests and summarize.

***

> **Tip:** When a thread gets long, ask your current agent:
> **“Create a handoff‑ready summary (decisions, constraints, unresolved questions, next steps) so I can start a fresh thread.”**
> Copy the summary into a new chat before continuing.

---

### Advanced merge conflict resolution

    @merge-conflict-resolver
    Goal: Resolve conflicts while preserving developer intent from both sides.

    Please:
    1) Use git history to infer intent:
       - Summarize the last 10 commits unique to HEAD vs origin/main.
       - Extract any commit messages that mention the conflicted areas.
    2) Read the PR description (pasted below) for additional intent.
    3) For each conflict hunk in <path/to/file>, explain OURS vs THEIRS intent and propose options A/B/C with trade-offs.
    4) Recommend the safest resolution that preserves both intents.
    5) Draft a single, accurate merge commit message that references the key commits and rationale.

    PR description:
    < paste text >