# Kit Review & Improvement Suggestions — 2026

A review of the spec-driven-delivery-kit against current research and multi-CLI compatibility. Written to inform the next revision cycle.

---

## What the Kit Does Well

Before the gaps: the kit's architecture is sound and ahead of most publicly available alternatives.

- **Evidence-gating is real.** Gates A–D are not optional checkboxes — the workflow actually stops. This is the difference between this kit and vibe-coding with a plan.md stub.
- **Artifact ownership is clear.** Every file has an agent and a stage. No ambiguity about what belongs where.
- **The Compactor agent is ahead of the field.** Most frameworks don't address context rot at all. The Compactor pattern — summarize every 5 updates, preserve Success/Friction/State Summary — is exactly what the research (Chroma, Pocock's "dumb zone") recommends.
- **Pre-context.md fallback is excellent.** MCP unavailable? Paste context into a file. Simple, resilient, and it works across every CLI.
- **The ask-matt/skills layer** (Matt Pocock's framework integrated as `ask-matt`) is a genuine complement to the ticket workflow — it covers the exploratory phase that the formal pipeline doesn't.
- **Separation principle is right.** Kit source ≠ installed workspace ≠ private overlay. This keeps the kit publishable and the workspace clean.

---

## Priority 1 — CLI Compatibility Gap (Critical)

### The Problem

`howToUse-cli.md` is written exclusively for GitHub Copilot CLI. It uses `/add-dir` — a Copilot-specific command — as the session startup step, and all invocation patterns assume Copilot's syntax. Claude Code CLI and Codex CLI use different invocation patterns, different discovery files, and different MCP config locations.

A developer using Claude Code (`claude`) or Codex (`codex`) will hit friction immediately at step 1.

### What Each CLI Actually Reads

| File / Convention | Claude Code | Codex CLI | GitHub Copilot |
|---|---|---|---|
| `AGENTS.md` | ✅ Native (AGENTS.md standard) | ✅ Native (OpenAI standard) | ✅ Reads via GitHub integration |
| `CLAUDE.md` | ✅ Primary discovery file | ❌ Ignored | ❌ Ignored |
| `.github/copilot-instructions.md` | ❌ Ignored | ❌ Ignored | ✅ Primary discovery file |
| `.github/agents/*.agent.md` | ✅ Via AGENTS.md reference | Partial | ✅ Native agent mode |
| `.github/prompts/*.prompt.md` | ✅ Via `--prompt` or reference | Partial | ✅ Native prompt mode |
| `.copilot/mcp-config.json` | ❌ | ❌ | ✅ |
| `~/.claude/claude_mcp_config.json` | ✅ | ❌ | ❌ |
| `codex.md` / `~/.codex/instructions.md` | ❌ | ✅ | ❌ |

### What's Missing

**The kit has no `CLAUDE.md` template.** Claude Code's primary discovery file — the file it reads before anything else — is not in the kit. Developers using Claude Code are relying on AGENTS.md alone, which works but misses Claude-specific capabilities: memory instructions, tool permissions, compact behavior, and cache hints.

**Codex has no setup path at all.** There is no `codex.md` or `~/.codex/instructions.md` template, and the CLI guide doesn't mention Codex.

### Recommendations

**R1.1 — Add a `CLAUDE.md` template to `templates/base/`.**

This file should:
- Reference `AGENTS.md` for the agent registry (`@AGENTS.md`)
- Set project-wide tool permissions and standing consent in Claude Code format
- Reference the workflow via `@.github/how-to/spec-driven-workflow.md`
- Include prompt caching hints (keep stable content at the top)
- Include compact behavior guidance (when to compact vs. handoff)

Starter structure:
```md
# [Project Name] — Claude Code Instructions

@AGENTS.md
@.github/how-to/spec-driven-workflow.md

## Standing Consent
[mirror from AGENTS.md, adapted for Claude Code permission format]

## Compact Behavior
Compact between workflow stages, not mid-stage.
Before compacting, write a State Summary to handoff.md.

## Context Budget
Keep ticket context under 80K tokens per stage.
Invoke @Compactor when handoff.md exceeds 50 lines.
```

**R1.2 — Split `howToUse-cli.md` into three files or a tabbed single file:**

- `howToUse-claude-code.md` — Claude Code CLI invocation patterns
- `howToUse-codex.md` — Codex CLI setup and invocation
- `howToUse-copilot-cli.md` — existing content, renamed and scoped

Or keep one file with clearly labeled sections per CLI. Either way, the `/add-dir` step needs a sibling for Claude Code (`claude --add-dir`) and a note that Codex handles directory scoping differently.

**R1.3 — Add a `codex.md` template to `templates/base/`** (or `~/.codex/instructions.md` guidance) that mirrors the AGENTS.md content in Codex-readable format.

---

## Priority 2 — MCP Server Coverage (Critical)

### The Problem

`mcp-setup.md` covers two servers: Atlassian and GitHub. MCP has expanded significantly in 2025–2026. More importantly, each CLI has a *different config file location* for MCP, and the kit currently only covers the Copilot MCP config locations.

### Current MCP Config Coverage

The kit installs:
- `.github/copilot/mcp.json` — Copilot Chat
- `.copilot/mcp-config.json` — Copilot cloud agent
- `.vscode/mcp.json` — VS Code local

Missing:
- `~/.claude/claude_mcp_config.json` — Claude Code global MCP
- `.claude/mcp.json` — Claude Code project-level MCP (auto-loaded per workspace)
- Codex MCP config (Codex uses OpenAI's MCP client spec; config location TBD per version)

### Recommended MCP Server List

Beyond Atlassian and GitHub, the following servers are relevant to the workflow:

| Server | Use in workflow | Priority |
|---|---|---|
| **Atlassian** (Jira + Confluence) | Contract stage: fetch tickets, ACs, comments | High — already listed |
| **GitHub** (PRs, diffs, CI) | Review and Sonar stages | High — already listed |
| **Playwright / Browser** | Review stage: visual QA, E2E evidence | High |
| **Filesystem** | Any stage: read/write local files with scoped permissions | Medium |
| **Memory / Knowledge Graph** | Cross-ticket lessons, codebase vocabulary persistence | Medium |
| **Linear** | Alternative to Jira for ticket intake | Medium |
| **Slack** | Incident response, PR notifications | Low |
| **SonarQube** (API) | Sonar gate: direct API instead of manual PR query | Medium |

### Recommendations

**R2.1 — Add `.claude/mcp.json` to `templates/base/`** as the Claude Code project MCP config template. Structure:

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@atlassian/mcp-atlassian"],
      "env": {
        "JIRA_URL": "${JIRA_URL}",
        "JIRA_TOKEN": "${JIRA_TOKEN}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@github/mcp-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```

**R2.2 — Expand `mcp-setup.md` to include:**
- A config file location table per CLI (Claude Code / Copilot / Codex)
- The recommended server list above with install commands
- How to verify a server is live before starting ticket work
- Linear as an explicit Jira alternative
- Notes on which servers are relevant to which workflow stages

**R2.3 — Add MCP environment variable guidance.** The current setup notes don't mention env var management. Recommend a `.env.mcp` pattern or point to `~/.claude/.env` for Claude Code.

---

## Priority 3 — Tracker-Agnostic Path (High)

### The Problem

The entire contract stage is built around Jira. The Atlassian MCP server is the first tool listed. The `howToUse-cli.md` deriving a ticket URL as `https://your-domain.atlassian.net/browse/PROJECT-123` assumes Atlassian everywhere.

Many teams use GitHub Issues, Linear, Shortcut, or just a plain feature description. There is no first-class path for them.

### Recommendations

**R3.1 — Formalize the tracker-agnostic intake pattern.** The `pre-context.md` fallback already handles this implicitly, but it's buried as a fallback, not a first-class path. Add a `howToUse-no-tracker.md` or a section in the existing how-to that starts with:

```
workflow/tickets/FEATURE-NAME/pre-context.md
```

...containing the feature description, acceptance criteria, and any constraints — and runs the same pipeline from there.

**R3.2 — Add a GitHub Issues MCP path** to the contract stage and MCP setup notes. GitHub Issues + GitHub PRs is a common all-GitHub workflow with no Jira.

**R3.3 — Make ticket ID derivation configurable.** The `workflow-contract.prompt.md` currently derives a Jira URL from the ticket ID. Add a `tracker_url` parameter or `TRACKER_BASE_URL` env var so the same prompt works for Linear (`linear.app/team/PROJECT-123`) or GitHub Issues (`github.com/org/repo/issues/123`).

---

## Priority 4 — Token Optimization (High)

The research is clear and the kit has a Compactor agent — but there's no guidance on *when* to invoke it, *how* to budget tokens across a workflow stage, or *what* degrades when you don't.

### Recommendations

**R4.1 — Add a `context-budget.md` to `.github/how-to/`** covering:

- The 100:1 input-to-output ratio in agentic work (cost is almost entirely on the input side)
- Recommended context budget per stage:

  | Stage | Recommended context budget |
  |---|---|
  | Contract | 20K–40K tokens (ticket + codebase scan) |
  | Plan | 10K–20K tokens (contract + targeted codebase reads) |
  | Implement (per task) | 30K–60K tokens (plan + handoff + affected files) |
  | Review | 40K–80K tokens (contract + plan + diff + evidence) |
  | Closeout | 10K–20K tokens (handoff summary + lessons) |

- Accuracy drops 20–50% past 100K tokens (Chroma Context Rot, 2025) — don't fill the window because it's available
- Compact between stages, not mid-stage (compacting mid-task loses the thread)
- `handoff.md` over 50 lines → invoke Compactor before continuing

**R4.2 — Add cache-efficiency guidance for Claude Code users** in `howToUse-claude-code.md`:
- Keep `CLAUDE.md` and `AGENTS.md` content stable at the top of each session (prefix cache hits)
- Avoid per-session timestamps or dynamic content in standing instructions
- Use `budget_tokens` on the Architect and Reviewer calls if cost is a concern

**R4.3 — Add a "smart zone" note to the Compactor agent.** Matt Pocock's research puts reliable reasoning at roughly 120K tokens on current models. The Compactor should trigger not just at 50-line handoff.md but also when the session estimates it's approaching that window.

---

## Priority 5 — EARS Notation for Requirements (Medium)

### The Problem

The research shows EARS notation (Easy Approach to Requirements Syntax) is becoming the standard input format for AI agent requirements. Amazon Kiro uses it as default output for its requirements step. GitHub Spec-Kit has an open issue to formalize it. The kit's contract/prompt.md has no formal requirement syntax guidance.

### Recommendations

**R5.1 — Add EARS patterns to the contract prompt or `workflow-contract.prompt.md`.** When the Architect drafts acceptance criteria, it should use structured EARS patterns:

```
When <trigger>, the <system> shall <action>
While <state>, the <system> shall <action>
If <condition>, then the <system> shall <action>
```

This makes ACs unambiguous for the Plan-Agent and Implementer — they parse structured patterns rather than interpreting natural language intent.

**R5.2 — Add a brief EARS reference to the authoring guide** (`authoring-agents-prompts-skills.md`). One table with the five patterns is enough.

---

## Priority 6 — CONTEXT.md Pattern (Medium)

### The Problem

Matt Pocock's `CONTEXT.md` approach — a bounded-context glossary per module capturing naming decisions, invariants, and known pitfalls — is not in the kit. It directly addresses the re-derivation problem: without it, agents spend tokens re-exploring architecture they should already know.

This is distinct from `copilot-instructions.md` (global standards) and `pre-context.md` (per-ticket context). It's a per-module or per-domain vocabulary file.

### Recommendations

**R6.1 — Add a `CONTEXT.md` template and guidance** to either `.github/how-to/` or as a new skill. The file pattern:

```md
# Context: [Module / Domain Name]

## Why This Exists
[One paragraph on the module's purpose and where it fits]

## Naming Decisions
- `[term]` means [specific meaning here], not [common misreading]

## Invariants
- [Constraint that must always be true]

## Known Pitfalls
- [Thing the agent will try to do that breaks this module]

## Related Files
- [path] — [what it does]
```

**R6.2 — Reference `CONTEXT.md` in `copilot-instructions.md`** with guidance on when to create one (when a module has non-obvious naming, invariants that aren't in tests, or known failure modes that recur across tickets).

---

## Priority 7 — Terminology Formalization (Medium)

`docs/terminology.md` is a raw chat conversation. The content is excellent — it covers the full taxonomy of agent patterns (skills, workflows, autonomous loops, orchestrator-worker, evaluator-optimizer, RAG, human-in-the-loop) and correctly characterizes the skill-vs-workflow distinction. It belongs in the kit as a proper reference document.

### Recommendations

**R7.1 — Rewrite `docs/terminology.md` as a clean reference.** Suggested structure:

- **Skills** — bounded, stateless, single-invocation capability
- **Workflows** — multi-step, stateful, gate-bearing, artifact-producing process
- **Autonomous agent loops** — self-directed control flow toward a goal (no fixed steps)
- **Orchestrator-worker** — dynamic decomposition + specialist sub-agents
- **Evaluator-optimizer / reflection loops** — generate → critique → revise
- **RAG** — a grounding technique, not a control-flow pattern
- **Human-in-the-loop** — a control layer on top of any of the above
- **Rough taxonomy of SDLC use cases** — which pattern fits test generation, incident response, migrations, compliance, etc.

The current conversation's content maps directly onto this. It just needs the chat wrapper stripped.

---

## Priority 8 — Model Tier Guidance (Medium)

The kit mentions Claude but has no guidance on which model tier to use for which agent. This matters for cost and quality: using Opus on every step is expensive; using Haiku on the Architect produces shallow contracts.

### Recommendations

**R8.1 — Add model tier recommendations to `AGENTS.md` or the authoring guide:**

| Agent | Recommended tier | Reason |
|---|---|---|
| `@Architect` | Opus / Sonnet | Deep codebase reasoning, strategic decisions |
| `@Plan-Agent` | Sonnet | Tactical breakdown; less open-ended than contract |
| `@Implementer` | Sonnet | High-volume, task-by-task; cache-friendly |
| `@Reviewer` | Sonnet / Opus | Needs to catch subtle bugs; don't cut corners here |
| `@Compactor` | Haiku | Summarization; no reasoning required |
| `@Educator` | Sonnet | Writing clarity over reasoning depth |
| `@Spike-Investigator` | Opus | Open-ended research benefits from depth |

**R8.2 — Add a note on Codex-specific model tiers** (o3 for hard reasoning tasks, o4-mini for high-volume implementation) once Codex CLI guidance is added.

---

## Priority 9 — Workflow Extensions for SDLC Use Cases (Low)

The terminology.md conversation identified a dozen SDLC use cases beyond ticket implementation. Several map cleanly to new workflows or skills the kit doesn't have.

### Missing workflows (based on research + terminology analysis):

| Use case | Current kit support | Gap |
|---|---|---|
| Dependency upgrades | None | Workflow: scan → patch → test → PR → merge gate |
| Incident response / postmortem | None | Workflow: detect → triage → correlate → fix → postmortem |
| Large-scale refactor | Partial (via spike + tickets) | Workflow: plan → batch execute → validate → rollback |
| Schema migrations | None | Skill or workflow depending on scope |
| Architecture decision records (ADRs) | Via `grill-with-docs` in ask-matt | Should be explicit in main kit, not just Pocock layer |
| Changelog / release notes | None | Skill: generate from commits/PRs since last tag |

### Recommendations

**R9.1 — Prioritize the `dependency-upgrade` workflow** as the first new extension. It's common, high-risk, and follows a well-defined pattern (scan vulnerabilities → propose patch plan → run tests → create PR) that maps cleanly onto the contract/plan/implement/review pipeline.

**R9.2 — Add an ADR skill** (`/adr`) that captures architectural decisions in a standard format. The `grill-with-docs` skill in the Pocock layer does this but it's not surfaced in the main kit's agent registry.

---

## Priority 10 — Small Friction Items (Low)

These are papercuts that slow down first-time users and cross-CLI compatibility.

**R10.1 — Fix `.md.md` vestiges.** The `terminology.md` file landed in `docs/` cleanly, but any future chat exports should go through the `ORIGIN.md` pattern — consolidated into a clean doc before committing.

**R10.2 — The `spec-driven-workflow.md` "GitHub Spec Kit" comparison table** references `https://github.github.com/spec-kit/` URLs that appear to be incorrect (the actual domain is `github.github.com` for GitHub documentation but the Spec-Kit docs moved). Verify and update these links.

**R10.3 — Add `docs/` links to `AGENTS.md`.** The agent registry is the main entry point, but it doesn't link to `docs/sdd-state-of-the-art-2026.md`, `docs/ORIGIN.md`, or `docs/terminology.md`. A "Further reading" section at the bottom would surface the research to new users.

**R10.4 — The `pointing-analyst` agent** (ticket refinement) is the most Jira-specific agent in the kit. If R3.x (tracker-agnostic path) is implemented, this agent needs a non-Jira mode.

**R10.5 — Add a `QUICKSTART.md` to `templates/base/`** — a single-page "you just installed the kit" reference that answers: what's the first command, where are the gates, what are the three most common skills. The `howToUse.md` files are comprehensive but intimidating for first-time users. A shorter entry point reduces time-to-first-ticket.

---

## Priority 11 — Invocation Architecture (from `architecture-review-2026.md`)

The three-layer invocation surface (verbose first command / `run X` shortcuts / `use skill X`) is inconsistent and CLI-specific. The fixes below unify it.

**A1 — Extend `run X` to the first command.**
Add `run contract ticket=<ID>` as the canonical entry point. Define a `run` dispatcher in `CLAUDE.md` and `AGENTS.md` that maps short commands to agent + prompt file pairs. Eliminates the wall-of-text first invocation; creates one consistent verb for the entire ticket lifecycle.

**A2 — Make `.active-workflow.md` an active state machine.**
After each stage, write the exact next-command(s) and available paths into `.active-workflow.md`. Enables `run next` as a universal continuation command. Survives context resets without the user needing to remember where they were.

**A3 — Disambiguation table for the three review types.**
Add a "which review to use" decision table to `AGENTS.md`:
- Gate D (own ticket): `run review`
- Teammate's PR: `run peer-review pr_url=<URL>`
- Branch quality check outside a ticket: `use the code-review skill`

**A4 — Add "two entry points" section to `spec-driven-workflow.md`.**
Clarify when to use ticket-first (you have a Jira ticket, go straight to `run contract`) vs. idea-first (no ticket yet, use exploration skills, then file a ticket and switch to the ticket workflow). These are sequential phases, not competing systems.

**A5 — Add `auto-read:` to prompt frontmatter.**
Declare each stage's file dependencies in the prompt frontmatter so CLIs that support it auto-load them. Removes the need for `context=` on standard files; makes prompts self-describing.

**A6 — Make agent files CLI-neutral.**
Remove or conditionalize `target: vscode` from agent frontmatter. Agent identity should work across Claude Code, Codex, and Copilot. VS Code-specific config belongs in `.vscode/`, not in `.agent.md`.

**A7 — Document `infer: false` / `infer: true` in the authoring guide.**
This flag is what makes gates real — advisory agents can't proceed autonomously. It's currently implicit. Surfacing it teaches authors how gate enforcement actually works.

**A8 — Connect skills into the ticket workflow implement stage.**
`workflow-implement.prompt.md` should reference `tdd` and `sonar-check` as callable within tasks, the way the Pocock `implement` skill calls them. Makes the connection between skills and the ticket workflow explicit.

---

## Priority 12 — Pocock Skills Integration

The Matt Pocock skills layer is currently sitting alongside the ticket workflow without a clear integration strategy. The decision: **keep our ticket workflow as the primary system, extract what's valuable from Pocock's work, remove what duplicates or conflicts.**

### What to Remove (Pocock workflow-runner skills)

These skills are runners for Pocock's own workflow. Without his workflow, they have no host. Remove them:

| Skill | Reason to remove |
|---|---|
| `ask-matt` | Pocock's workflow router. Replace with a kit-native skill discovery mechanism. |
| `setup-matt-pocock-skills` | Pocock's one-time setup. Meaningless without his workflow. |
| `implement` | Pocock's implementation driver (calls `tdd` + `code-review` internally). The ticket workflow has `workflow-implement.prompt.md`. The underlying ideas (tdd inside implement, code-review at end) should be absorbed into the ticket workflow's implement prompt instead. |

### What to Keep as Standalone Skills

These have standalone value that works with or without any workflow:

| Skill | Use |
|---|---|
| `tdd` | Test-first approach. Integrate reference into `workflow-implement.prompt.md`. |
| `grill-me` | Stateless requirements interview. Use before a ticket exists or when ACs are vague. |
| `grill-with-docs` | Stateful interview that updates `CONTEXT.md`. Use during pre-contract exploration. |
| `grilling` | The primitive that `grill-me` and `grill-with-docs` call. Keep internal. |
| `to-spec` | Synthesizes a conversation into a spec. Useful as a pre-contract step when no ticket exists. |
| `to-tickets` | Breaks a spec into agent-ready tickets. Works as a pre-contract step for idea-first entry. |
| `wayfinder` | For large, foggy efforts that aren't yet ticketable. Maps decision tickets before any implementation. |
| `prototype` | Throwaway code to answer a design question. Useful standalone at any stage. |
| `research` | Delegates background reading to a sub-agent. Useful inside Contract and Spike stages. |
| `teach` | Learning framework across multiple sessions. Standalone. |
| `diagnosing-bugs` | Structured bug diagnosis. Standalone. |
| `triage` | Issue triage for incoming requests. Works as a pre-ticket funnel. |
| `domain-modeling` | Domain language clarification. Feeds `CONTEXT.md`. |
| `codebase-design` | Deep module design vocabulary. Standalone reference. |
| `improve-codebase-architecture` | Architecture improvement driver. Standalone. |
| `writing-great-skills` | Meta skill for authoring. Keep. |

### Ideas to Extract and Absorb into the Ticket Workflow

Don't carry Pocock's approach as a parallel system — bake these ideas directly into the kit:

| Pocock idea | Where to absorb it |
|---|---|
| **Thin tracer bullets** — tasks that cut across all layers from step 1, not phase-by-phase | Add to task design guidance in `authoring-agents-prompts-skills.md` and the plan prompt |
| **Two-axis review** (Standards + Spec as separate sub-agent passes) | Incorporate into `workflow-review.prompt.md` as an optional parallel sub-agent pattern |
| **Context hygiene** — don't compact mid-phase, only between phases | Add to `context-budget.md` and the Compactor agent |
| **Rate of feedback as speed limit** — task size calibrated to get a feedback loop fast | Add to plan task-sizing guidance |
| **Blocking edges** — work blockers-first, declare dependencies between tasks | Add to `workflow-plan.prompt.md` as a task ordering principle |
| **CONTEXT.md per module** — bounded-context glossary | Already captured in R6.x above |

### Rename `handoff` Skill

The `handoff` skill (Pocock's session-forking mechanism — compacts the current conversation to a file, opens a new session referencing it) conflicts directly with `handoff.md` (the kit's execution journal artifact). Anyone reading the skill list sees two things called "handoff" that mean completely different things.

Rename the skill to `fork-session` or `session-bridge`. Keep the skill itself — it's useful for context-window management between long sessions.

---

## Priority 13 — Skills Naming and Organization Overhaul

42 skills in a flat directory with no grouping, inconsistent naming conventions, and two duplicate-looking merge-conflict skills is a discovery problem. New users can't tell what exists, what it does, or which one to reach for.

### Duplicates to Resolve

| Skills | Issue |
|---|---|
| `merge-conflict-resolution` and `resolving-merge-conflicts` | Two skills for the same task. Audit, keep one, delete the other. |
| `code-review` and `workflow-review` (prompt) | Same name, different systems (see A3). Rename `code-review` skill to `branch-review` or `diff-review` to distinguish it from Gate D. |
| `handoff` and `handoff.md` | Name collision. Rename the skill (see above). |

### Proposed Skill Categories

Group all 42 skills into six categories. This can be done with subfolder organization under `.github/skills/` or simply as a categorized table in `AGENTS.md` — whichever the CLIs handle better:

**Explore** — pre-ticket, idea clarification, research
`grill-me`, `grill-with-docs`, `grilling`, `research`, `wayfinder`, `prototype`, `domain-modeling`, `to-spec`, `to-tickets`

**Build** — implementation, testing, refactoring
`tdd`, `codebase-design`, `complex-logic-refactoring`, `database-migrations`, `vulnerability-remediation`, `improve-codebase-architecture`

**Review** — quality, audits, diffing
`branch-review` (renamed from `code-review`), `sonar-check`, `tailwind-check`, `docs-audit`, `docs-refresh`, `docs-review`, `pr-diff-scope-summary`

**Fix** — debugging, conflicts
`diagnosing-bugs`, `merge-conflict-resolution`, `triage`

**Learn** — education, documentation, writing
`teach`, `writing-great-skills`, `writing-style-guide`, `concise-flow-explainer`, `process-doc-formatter`, `message-clarity`, `codebase-design`

**Ops** — kit maintenance, workspace management, session tools
`kit-sync`, `workflow-index`, `copilot-chat-cleanup`, `private-workspace-archive`, `private-workspace-restore`, `worklog`, `fork-session` (renamed from `handoff`)

### Replace `ask-matt` with a Kit-Native Router

`ask-matt` was the discovery mechanism for the Pocock layer. Without that layer, there's no router. Replace it with a `which-skill` or `skill-router` skill that covers all kit skills organized by the categories above. The new router answers "which skill fits my situation?" using the kit's own taxonomy, not Pocock's flow.

### Add All Skills to `AGENTS.md`

Currently `AGENTS.md` lists only kit-native skills (sonar-check, tailwind-check, docs-*, etc.). The Pocock skills are undiscoverable from the main registry. Once reorganized, all skills should appear in `AGENTS.md` under their category.

---

## Prioritized Action List

| Priority | Action | Effort |
|---|---|---|
| 🔴 Critical | R1.1 — Add `CLAUDE.md` template | Small |
| 🔴 Critical | R1.2 — Split or expand CLI guide for Claude Code + Codex | Medium |
| 🔴 Critical | R2.1 — Add `.claude/mcp.json` template | Small |
| 🔴 Critical | R2.2 — Expand MCP setup: config locations per CLI, server list | Medium |
| 🔴 Critical | A1 — Extend `run X` to first command; add dispatcher to `CLAUDE.md` | Small |
| 🔴 Critical | P1 — Remove `ask-matt`, `setup-matt-pocock-skills`, `implement` (Pocock) | Small |
| 🔴 Critical | P2 — Rename `handoff` skill → `fork-session` | Tiny |
| 🔴 Critical | P3 — Rename `code-review` skill → `branch-review` | Tiny |
| 🔴 Critical | P4 — Resolve `merge-conflict-resolution` / `resolving-merge-conflicts` duplicate | Small |
| 🟠 High | R3.1 — Formalize tracker-agnostic intake path | Small |
| 🟠 High | R3.3 — Make ticket URL derivation configurable | Small |
| 🟠 High | R4.1 — Add `context-budget.md` how-to | Small |
| 🟠 High | R4.3 — Smart zone note in Compactor agent | Tiny |
| 🟠 High | A2 — Make `.active-workflow.md` an active state machine | Medium |
| 🟠 High | A3 — Add "which review to use" disambiguation table to `AGENTS.md` | Tiny |
| 🟠 High | A4 — Add "two entry points" section to `spec-driven-workflow.md` | Small |
| 🟠 High | S1 — Add all skills to `AGENTS.md` registry under categories | Small |
| 🟠 High | S2 — Replace `ask-matt` with kit-native `which-skill` router | Small |
| 🟡 Medium | R5.1 — Add EARS patterns to contract prompt | Small |
| 🟡 Medium | R6.1 — Add `CONTEXT.md` template and guidance | Small |
| 🟡 Medium | R7.1 — Rewrite `docs/terminology.md` as clean reference | Small |
| 🟡 Medium | R8.1 — Add model tier recommendations to agent registry | Small |
| 🟡 Medium | A5 — Add `auto-read:` to prompt frontmatter | Small |
| 🟡 Medium | A6 — Make agent files CLI-neutral (remove `target: vscode`) | Small |
| 🟡 Medium | A7 — Document `infer:` flag in authoring guide | Tiny |
| 🟡 Medium | A8 — Connect `tdd` + `sonar-check` into `workflow-implement.prompt.md` | Small |
| 🟡 Medium | P5 — Absorb Pocock ideas into ticket workflow (thin tracer bullets, two-axis review, blocking edges) | Medium |
| 🟡 Medium | S3 — Organize skills into six categories in `AGENTS.md` (Explore / Build / Review / Fix / Learn / Ops) | Small |
| 🟢 Low | R9.1 — Dependency upgrade workflow extension | Large |
| 🟢 Low | R9.2 — ADR skill | Small |
| 🟢 Low | R10.3 — Add docs links to `AGENTS.md` further reading | Tiny |
| 🟢 Low | R10.5 — Add `QUICKSTART.md` | Small |

---

## How This Aligns With the Research

The state-of-the-art document (`docs/sdd-state-of-the-art-2026.md`) identified five layers of modern SDD architecture:

1. Constitutional layer (`AGENTS.md`, `CLAUDE.md`, Policy Cards)
2. Feature specification layer (`requirements.md` with EARS, `design.md`, `tasks.md`)
3. Contract layer (OpenAPI, AsyncAPI)
4. Executable verification layer (BDD/Gherkin, TDAD, formal specs)
5. Runtime governance layer (Policy Cards, OWASP Agentic Top 10)

The kit is strong at layers 1 and 2 within the Jira-to-PR context. The gaps cluster at layer 1 (no `CLAUDE.md`, incomplete MCP coverage) and at the cross-CLI portability of the whole stack. Layers 3–5 are outside the kit's current scope and probably belong in extensions rather than the base.
