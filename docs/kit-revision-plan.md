# Kit Revision Plan

## Session State
<!-- Update this block at the end of every session before closing. -->

```
Last updated: 2026-08-13
Current batch: Complete (Batches 1–6 done)
Last completed task: Batch 6 polish — CONTEXT.md template, howToUse-context-md.md, terminology.md rewrite, AGENTS.md six-category skills + which-review table + further reading, which-skill/SKILL.md, available_next_commands in all stage prompts, INDEX.md updated
Blocked on: —
Notes: All planned batches complete. Cross-reference check passed. No stale howToUse-spike.md or howToUse-codeReview.md references remain. target: vscode removed from all agent frontmatter.
```

---

## How To Use This Plan

Each batch is one Claude Code session. At the start of a session:

```
Read docs/kit-revision-plan.md and docs/kit-review-2026.md.
Implement all unchecked tasks in Batch N.
Check off each task as it is completed.
Update the Session State block before stopping.
```

The two contract documents are:
- `docs/kit-review-2026.md` — full todo list with rationale for every item
- `docs/architecture-review-2026.md` — deeper rationale for invocation and integration items

Do not skip ahead of the current batch. Later batches depend on earlier ones — especially Batch 3 (skills cleanup) which must be done before Batch 4 (registry rewrite).

---

## Batch 1 — Foundation
**Goal:** Make the kit work correctly with Claude Code and Codex CLI, not just Copilot. Everything else depends on this.

**Context to load:** `docs/kit-review-2026.md` sections R1, R2, A6

- [ ] **Create `templates/base/CLAUDE.md`** — Claude Code primary discovery file (R1.1)
  - Opens with `@AGENTS.md` and `@.github/how-to/spec-driven-workflow.md`
  - Standing consent block in Claude Code permission format (mirror from `AGENTS.md`)
  - `run X` dispatcher table mapping short commands to agent + prompt file (see Batch 2 — write the table here even though the prompts get updated in Batch 2)
  - Compact behavior: compact between stages, not mid-stage; write State Summary to `handoff.md` before compacting
  - Context budget note: keep ticket context under 80K tokens per stage; invoke `@Compactor` when `handoff.md` exceeds 50 lines

- [ ] **Create `templates/base/.claude/mcp.json`** — Claude Code project MCP config template (R2.1)
  - Servers: Atlassian (Jira + Confluence), GitHub, Playwright
  - Use env var placeholders: `${JIRA_URL}`, `${JIRA_TOKEN}`, `${GITHUB_TOKEN}`
  - Add a comment block listing optional servers: Linear, SonarQube API, Memory/Knowledge Graph

- [ ] **Create `.github/how-to/howToUse-claude-code.md`** — Claude Code CLI guide (R1.2)
  - Mirror the structure of `howToUse-cli.md` but with Claude Code syntax
  - Session startup: `claude --add-dir /path/to/workspace` (not `/add-dir`)
  - First command: `run contract ticket=PROJECT-123` (not the verbose "Act as Architect…" form)
  - Subsequent commands: same `run plan`, `run implement`, `run review`, `run closeout` as Copilot guide
  - Note: Claude Code reads `CLAUDE.md` first, then `AGENTS.md`
  - MCP config location: `.claude/mcp.json` (project) or `~/.claude/claude_mcp_config.json` (global)
  - Permission model differences from Copilot CLI

- [ ] **Create `.github/how-to/howToUse-codex.md`** — Codex CLI guide (R1.2)
  - Session startup and workspace scoping for Codex
  - Codex reads `AGENTS.md` natively (OpenAI standard)
  - Instruction file location: `codex.md` in workspace root or `~/.codex/instructions.md`
  - Invocation syntax differences
  - MCP: note Codex MCP config location once stable (flag as TBD if still changing)
  - Same `run X` short commands apply if dispatcher is defined in `AGENTS.md`

- [ ] **Expand `mcp-setup.md`** — full multi-CLI coverage (R2.2)
  - Add config file location table: Claude Code (`.claude/mcp.json`, `~/.claude/claude_mcp_config.json`), Copilot (`.github/copilot/mcp.json`, `.copilot/mcp-config.json`), Codex (TBD)
  - Expand server list: Atlassian, GitHub, Playwright, Linear, SonarQube API, Filesystem, Memory/Knowledge Graph
  - Add which servers are relevant to which workflow stages
  - Add env var management guidance (`.env.mcp` or `~/.claude/.env` for Claude Code)
  - Add install commands for each server

- [ ] **Remove `target: vscode` from all agent files** — make agents CLI-neutral (A6)
  - Edit every `.agent.md` file in `templates/base/.github/agents/`
  - Remove the `target: vscode` frontmatter field
  - If any VS Code-specific behavior is embedded in the agent body, move it to a `.vscode/` config note instead

---

## Batch 2 — Invocation
**Goal:** Unify the three invocation surfaces into a single consistent `run X` convention from the first command.

**Context to load:** `docs/architecture-review-2026.md` sections on invocation, `templates/base/CLAUDE.md` (just created)

- [ ] **Add `run X` dispatcher to `templates/base/AGENTS.md`** (A1)
  - Add a "Workflow Commands" section near the top, below Standing Consent
  - Map each short command to its agent + prompt file:
    - `run contract ticket=<ID>` → Architect + `workflow-contract.prompt.md`
    - `run plan` → Plan-Agent + `workflow-plan.prompt.md`
    - `run implement` → Implementer + `workflow-implement.prompt.md`
    - `run review` → Reviewer + `workflow-review.prompt.md`
    - `run closeout` → Architect + `workflow-closeout.prompt.md`
    - `run sonar pr_number=<N>` → Reviewer + `workflow-sonar.prompt.md`
    - `run peer-review pr_url=<URL>` → Reviewer + `pr-review.prompt.md`
    - `run spike-contract ticket=<ID>` → Architect + `spike-contract.prompt.md`
    - `run spike-investigate` → Spike-Investigator + `spike-investigate.prompt.md`
    - `run spike-review` → Reviewer + `spike-review.prompt.md`

- [ ] **Update `.active-workflow.md` format** to include next-command declarations (A2)
  - Edit the format template in `workflow-contract.prompt.md` (section where it writes `.active-workflow.md`)
  - New format should include: `available_next_commands:` block listing the valid next steps and their exact commands
  - Update all other stage prompts that write `.active-workflow.md` to include the same block
  - Stages to update: workflow-contract, workflow-plan, workflow-implement, workflow-review, workflow-closeout

- [ ] **Add `auto-read:` frontmatter to all workflow prompt files** (A5)
  - `workflow-contract.prompt.md`: add auto-read for `pre-context.md`, `.github/lessons-learned.md`, `.github/copilot-instructions.md`
  - `workflow-plan.prompt.md`: add auto-read for `prompt.md`, `pre-context.md`, `.github/lessons-learned.md`
  - `workflow-implement.prompt.md`: add auto-read for `prompt.md`, `plan.md`, `handoff.md`
  - `workflow-review.prompt.md`: add auto-read for `prompt.md`, `plan.md`, `handoff.md`, `test.md`
  - `workflow-closeout.prompt.md`: add auto-read for `handoff.md`, `test.md`, `pull-request.md`
  - Same for spike prompts: scope to their artifact paths

- [ ] **Update `howToUse-cli.md` first-command instructions** (A1)
  - Replace the verbose "Act as Architect following…" first command with `run contract ticket=PROJECT-123`
  - Add note: if the dispatcher isn't resolving, fall back to the explicit form (keep it as a fallback, not the primary path)
  - Retitle this guide as `howToUse-copilot-cli.md` now that Claude Code and Codex have their own guides

- [ ] **Document `infer:` flag in `authoring-agents-prompts-skills.md`** (A7)
  - Add a section explaining `infer: false` vs `infer: true`
  - `infer: false` = agent follows prompt exactly and stops at gates; cannot proceed autonomously
  - `infer: true` = agent can take next steps without explicit user continuation
  - Note: losing or overriding `infer: false` on advisory agents breaks gate enforcement

---

## Batch 3 — Skills Cleanup
**Goal:** Remove Pocock workflow-runner skills, rename naming collisions, resolve duplicates. Must complete before Batch 4 rewrites the registry.

**Context to load:** `docs/kit-review-2026.md` section Priority 12 and 13

- [ ] **Audit `resolving-merge-conflicts/` vs `merge-conflict-resolution/`** (P4)
  - Read both SKILL.md files
  - Determine which is more complete and up-to-date
  - Delete the lesser one; ensure the keeper has a clear name and description

- [ ] **Delete `ask-matt/` skill directory** (P1)
  - This is Pocock's workflow router; has no function without his workflow
  - Will be replaced by `which-skill/` in Batch 4

- [ ] **Delete `setup-matt-pocock-skills/` skill directory** (P1)
  - Pocock's one-time setup; meaningless without his workflow

- [ ] **Delete `implement/` skill directory** (P1)
  - Pocock's implementation driver (calls tdd + code-review internally)
  - The ideas are absorbed into `workflow-implement.prompt.md` in Batch 5
  - The kit's `workflow-implement.prompt.md` is the equivalent

- [ ] **Rename `handoff/` → `fork-session/`** (P2)
  - Rename the directory
  - Update `name:` and `description:` in the SKILL.md frontmatter
  - Update the skill body to remove any references to "handoff" that would confuse it with `handoff.md`
  - New description: "Compact the current conversation to a markdown file and open a fresh session referencing it. Use when crossing context windows without losing thread."

- [ ] **Rename `code-review/` → `branch-review/`** (P3)
  - Rename the directory
  - Update `name:` and `description:` in the SKILL.md frontmatter
  - New description: "Two-axis review (Standards + Spec) of a diff against a fixed point (commit, branch, or tag). Use for branch quality checks outside the ticket workflow. For Gate D review of your own ticket, use `run review` instead."
  - Search for any internal references to `code-review` in remaining skill files and update them

- [ ] **Verify no broken internal references after deletions and renames**
  - `rg "ask-matt\|setup-matt-pocock\|/implement\b\|code-review\|/handoff\b" templates/base/.github/`
  - Fix any hits that are not inside the deleted/renamed files themselves

---

## Batch 4 — Registry and Discovery
**Goal:** Every skill is discoverable from `AGENTS.md`. A kit-native router replaces `ask-matt`.

**Context to load:** `docs/kit-review-2026.md` section Priority 13, current `templates/base/AGENTS.md`

- [ ] **Add six-category skills section to `AGENTS.md`** (S1, S3)
  - Add after the existing Skills table, or replace it with the categorized version
  - Six categories with one-line description per skill:

  **Explore** — pre-ticket, idea clarification, research
  `grill-me`, `grill-with-docs`, `grilling`, `research`, `wayfinder`, `prototype`, `domain-modeling`, `to-spec`, `to-tickets`

  **Build** — implementation, testing, refactoring
  `tdd`, `codebase-design`, `complex-logic-refactoring`, `database-migrations`, `vulnerability-remediation`, `improve-codebase-architecture`

  **Review** — quality, audits, diffs
  `branch-review` (renamed), `sonar-check`, `tailwind-check`, `docs-audit`, `docs-refresh`, `docs-review`, `pr-diff-scope-summary`

  **Fix** — debugging, conflicts
  `diagnosing-bugs`, `merge-conflict-resolution`, `triage`

  **Learn** — education, writing, documentation
  `teach`, `writing-great-skills`, `writing-style-guide`, `concise-flow-explainer`, `process-doc-formatter`, `message-clarity`

  **Ops** — kit maintenance, workspace, session tools
  `kit-sync`, `workflow-index`, `copilot-chat-cleanup`, `private-workspace-archive`, `private-workspace-restore`, `worklog`, `fork-session` (renamed)

- [ ] **Add "Which review to use" disambiguation table to `AGENTS.md`** (A3)
  - Short table with three rows: Gate D / Teammate PR / Branch quality
  - Command for each: `run review` / `run peer-review pr_url=<URL>` / `use the branch-review skill`

- [ ] **Create `templates/base/.github/skills/which-skill/SKILL.md`** — kit-native router (S2)
  - Replaces `ask-matt` as the discovery entry point
  - Describes the six categories and which situations map to each
  - Lists all skills with one-line purpose summaries
  - Decision guide: "what are you trying to do right now?"
  - References the two workflow entry points (ticket-first vs. idea-first)
  - Invocation: `use the which-skill skill` or `/which-skill`

- [ ] **Add "Further reading" section to `AGENTS.md`** (R10.3)
  - Link to `docs/sdd-state-of-the-art-2026.md`
  - Link to `docs/kit-review-2026.md`
  - Link to `docs/architecture-review-2026.md`
  - Link to `docs/ORIGIN.md`
  - Link to `docs/terminology.md` (once rewritten in Batch 6)

---

## Batch 5 — Workflow Improvements
**Goal:** Make the ticket workflow smarter: EARS requirements, context budgeting, tracker-agnostic path, clearer review flow, and absorbed Pocock ideas.

**Context to load:** `docs/kit-review-2026.md` sections R3–R5, R8, A3–A4, A8, P5; `docs/architecture-review-2026.md`

- [ ] **Add EARS patterns to `workflow-contract.prompt.md`** AC section (R5.1)
  - In section 3.2 (Acceptance Criteria), add an EARS notation block after the existing guidance
  - Include all five patterns with examples:
    - Ubiquitous: `The <system> shall <action>`
    - Event-driven: `When <trigger>, the <system> shall <action>`
    - State-driven: `While <state>, the <system> shall <action>`
    - Unwanted behavior: `If <condition>, then the <system> shall <action>`
    - Optional feature: `Where <feature>, the <system> shall <action>`
  - Note: use EARS for each AC; each AC must also map to evidence in `test.md`

- [ ] **Create `.github/how-to/context-budget.md`** (R4.1)
  - Recommended token budget per stage (Contract 20–40K, Plan 10–20K, Implement 30–60K, Review 40–80K, Closeout 10–20K)
  - Accuracy drops 20–50% past 100K tokens — don't fill the window because it's available
  - Compact between stages, not mid-stage (compacting mid-task loses the thread)
  - `handoff.md` over 50 lines → invoke Compactor before continuing
  - Smart zone: reliable reasoning degrades around 120K tokens on current models
  - Claude-specific: prompt caching, `budget_tokens`, tier routing (Opus/Sonnet for strategic agents, Haiku for Compactor)

- [ ] **Add smart zone note to `compactor.agent.md`** (R4.3)
  - Add a "When to invoke" trigger: also invoke when the session is approaching 100K tokens, not only when `handoff.md` exceeds 50 lines
  - Add note: do not compact mid-task; finish the current task first

- [ ] **Create `.github/how-to/howToUse-no-tracker.md`** — tracker-agnostic intake path (R3.1)
  - First-class guide for teams without Jira
  - Entry point: create `workflow/tickets/FEATURE-NAME/pre-context.md` with feature title, description, ACs, constraints
  - Then: `run contract ticket=FEATURE-NAME` — the contract prompt reads `pre-context.md` as the ticket source
  - Everything else is identical to the standard ticket workflow
  - Note which MCP servers are skipped (Atlassian) and what the fallback is

- [ ] **Add `tracker_url` parameter to `workflow-contract.prompt.md`** (R3.3)
  - Add optional `tracker_url` input alongside `ticket` and `output_dir`
  - If provided, use it directly as the ticket URL (overrides Jira derivation)
  - If not provided, fall back to current Jira URL derivation
  - Supports Linear (`linear.app/team/<ID>`), GitHub Issues (`github.com/org/repo/issues/<N>`), or any URL
  - Update `.active-workflow.md` to store `tracker_url` when set

- [ ] **Add "two entry points" section to `spec-driven-workflow.md`** (A4)
  - Ticket-first: you have a Jira/Linear/GitHub ticket → `run contract ticket=<ID>`
  - Idea-first: no ticket yet → use Explore skills (`grill-with-docs` → `to-spec` → `to-tickets`) → file the top ticket → `run contract ticket=<ID>`
  - Note: do not skip the ticket-filing step for idea-first work; the ticket is the gate that ensures human intent is recorded before the workflow runs

- [ ] **Absorb Pocock ideas into the ticket workflow** (P5)
  - `workflow-plan.prompt.md` — add task design principles:
    - **Thin tracer bullets**: each task should cut through all layers (UI → logic → data) rather than doing all UI tasks then all logic tasks. Gets a feedback loop after every task, not after phase three.
    - **Blocking edges**: identify dependencies between tasks explicitly; sequence blockers first
    - **Rate of feedback as speed limit**: if a task takes more than 15 minutes to verify, split it
  - `workflow-review.prompt.md` — add optional two-axis parallel sub-agent pattern:
    - Standards axis: does the code follow documented conventions and smell baseline?
    - Spec axis: does the code implement what the contract asked for?
    - Note: this is optional; the existing severity-rated finding format remains the default
  - `authoring-agents-prompts-skills.md` — add thin tracer bullet and blocking edge guidance to the "Context Checklist For A New Ticket" section

- [ ] **Connect `tdd` and `branch-review` skills into `workflow-implement.prompt.md`** (A8)
  - Add a reference after each task's verify step: "use the `tdd` skill for test-first task implementation"
  - Add a reference at the end of implementation: "optionally run `branch-review` for a quality check before Gate D"
  - Keep these as optional references, not required steps — Gate D (`run review`) remains the required review

- [ ] **Add model tier recommendations to `AGENTS.md`** (R8.1)
  - Add a "Recommended Model Tiers" table under the agents section
  - Architect / Spike-Investigator → Opus (deep reasoning, strategic decisions)
  - Plan-Agent / Implementer / Reviewer → Sonnet (workhorse; high-volume, cache-friendly)
  - Compactor / Educator → Haiku (summarization and writing; no deep reasoning needed)
  - Note: these are recommendations, not hard requirements; override in agent frontmatter if needed

---

## Batch 6 — Polish
**Goal:** Round out the kit with CONTEXT.md guidance, clean terminology reference, quickstart, and terminology doc.

**Context to load:** `docs/kit-review-2026.md` sections R6, R7, R10

- [ ] **Create `CONTEXT.md` template and guidance** (R6.1)
  - Create `templates/base/.github/how-to/howToUse-context-md.md` explaining the pattern
  - Create `templates/base/CONTEXT.md` as an installable template with placeholder sections:
    - Why This Exists
    - Naming Decisions (term → specific meaning, not common misreading)
    - Invariants (constraints that must always be true)
    - Known Pitfalls (things agents will try that break this codebase)
    - Related Files
  - Add a reference to `CONTEXT.md` in `copilot-instructions.md`: when to create one (non-obvious naming, invariants not in tests, recurring failure modes)
  - Add `CONTEXT-MAP.md` template for multi-module repos pointing to per-module CONTEXT files

- [ ] **Rewrite `docs/terminology.md`** as a clean taxonomy reference (R7.1)
  - Strip all chat wrapper content
  - Structure as: Skill → Workflow → Autonomous Agent Loop → Orchestrator-Worker → Evaluator-Optimizer → RAG → Human-in-the-Loop
  - Add SDLC use case table: which pattern fits test generation, incident response, migrations, compliance, etc.
  - Add kit-specific terminology: Contract, Blueprint, Handoff, Gate, Promotion, Altitude Control, Context Budget, Smart Zone

- [ ] **Create `templates/base/QUICKSTART.md`** (R10.5)
  - Single-page "you just installed the kit" reference
  - Three sections: First ticket (5 steps), Common skills (3–4 most-used), Where to go deeper (links)
  - Answers: what's the first command, where are the gates, what do I do if MCP is unavailable

- [ ] **Final cross-reference check**
  - Verify all skill names in `AGENTS.md` match actual directory names after renames
  - Verify `howToUse-cli.md` has been renamed to `howToUse-copilot-cli.md` (started in Batch 2) and all references updated
  - Verify `run contract` works as first command in all three CLI guides
  - Run: `rg "ask-matt\|setup-matt-pocock\|/implement\b" templates/` — should return zero results
  - Run: `rg "code-review" templates/` — verify only `branch-review` references remain (except inside the `branch-review` skill itself)
  - Run: `rg "target: vscode" templates/` — should return zero results

---

## Reference

**Contract documents:**
- `docs/kit-review-2026.md` — full rationale and todo list (R_, A_, P_, S_ item IDs)
- `docs/architecture-review-2026.md` — invocation and integration deep-dive

**Key files being changed:**
- `templates/base/AGENTS.md` — touched in Batches 1, 2, 4, 5
- `templates/base/.github/prompts/workflow-contract.prompt.md` — touched in Batches 2, 5
- `templates/base/.github/prompts/workflow-plan.prompt.md` — touched in Batches 2, 5
- `templates/base/.github/prompts/workflow-implement.prompt.md` — touched in Batches 2, 5
- `templates/base/.github/prompts/workflow-review.prompt.md` — touched in Batches 2, 5
- `templates/base/.github/agents/*.agent.md` — touched in Batch 1 (target removal)
- `templates/base/.github/skills/` — touched in Batches 3, 4

**Do not touch during this revision:**
- `workflow/` directories (live workspace artifacts, not kit source)
- `examples/` (separate public-readiness pass needed)
- `extensions/` (out of scope for this revision)
