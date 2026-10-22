# Skill Libraries Research

Survey of prominent AI agent skill libraries and frameworks. Captured 2026-10-08.

---

## Libraries at a Glance

| Library | Author | Type | Repo |
|---|---|---|---|
| agent-skills | Addy Osmani | Skill library | https://github.com/addyosmani/agent-skills |
| skills | Matt Pocock | Skill library | https://github.com/mattpocock/skills |
| pstack | Lauren Tan (@poteto) | Framework | https://github.com/cursor/plugins/tree/main/pstack/skills |
| pstack-claude | Michael Denyer | pstack port | https://github.com/michael-denyer/pstack-claude |

Supporting reading:
- https://flaviocopes.com/pstack/
- https://www.theneuron.ai/explainer-articles/pstack-explained-lauren-tans-system-for-trustworthy-ai-agents/

---

## Addy Osmani — agent-skills

**Type:** Skill library. 25 skills organized around a linear development lifecycle.

**Pipeline:**
```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
```

**Full skill inventory:**

| Category | Skills |
|---|---|
| Meta | `using-agent-skills` |
| Define | `interview-me`, `idea-refine`, `spec-driven-development`, `constraint-driven-development` |
| Plan | `planning-and-task-breakdown` |
| Build | `incremental-implementation`, `test-driven-development`, `context-engineering`, `source-driven-development`, `doubt-driven-development`, `frontend-ui-engineering`, `api-and-interface-design` |
| Verify | `browser-testing-with-devtools`, `debugging-and-error-recovery` |
| Review | `code-review-and-quality`, `code-simplification`, `security-and-hardening`, `performance-optimization` |
| Ship | `git-workflow-and-versioning`, `ci-cd-and-automation`, `deprecation-and-migration`, `documentation-and-adrs`, `observability-and-instrumentation`, `shipping-and-launch` |

### Review stack (four layers)

This is the part most worth appropriating. Each layer is independent — invoke any combination based on risk profile.

1. **`code-review-and-quality`** — five-axis review, change sizing (~100 lines), severity labels. Primary gate before merge.
2. **`security-and-hardening`** — OWASP Top 10, auth patterns, secrets, dependency auditing, three-tier boundaries.
3. **`performance-optimization`** — Core Web Vitals targets, profiling workflows, bundle analysis.
4. **`code-simplification`** — Chesterton's Fence principle, Rule of 500, complexity reduction while preserving behavior.

**Key concept — `doubt-driven-development`:** Adversarial fresh-context review structured as CLAIM → EXTRACT → DOUBT → RECONCILE. Forces the agent to challenge its own prior reasoning from a clean slate. Pairs well with `grill-me` in our workflow.

**Key concept — `constraint-driven-development`:** Generates a `CONSTRAINTS.md` from quality bar interviews, then uses it for cost-based check placement throughout development. Similar in spirit to our `prompt.md` contract — worth comparing structures.

---

## Matt Pocock — skills

**Type:** Skill library. Smaller, more focused on developer feedback loops and alignment.

**Selected skills of note:**

| Skill | Type | What it does |
|---|---|---|
| `grill-me` | User-invoked | Intensive planning interview — challenges assumptions before committing |
| `grilling` | Model-invoked | Core interview primitive used by grill-me and others |
| `triage` | User-invoked | Move issues through state machines |
| `code-review` | Model-invoked | Two-axis review: standards + spec compliance |
| `codebase-design` | Model-invoked | Deep module design discipline |
| `domain-modeling` | Model-invoked | Sharpen project terminology |
| `prototype` | Model-invoked | Throwaway prototypes for design questions |
| `wayfinder` | User-invoked | Plan large-scale work |
| `to-spec` / `to-tickets` | User-invoked | Convert conversations to specs or tickets |
| `handoff` | User-invoked | Documentation for agent session transitions |
| `retro` | User-invoked | Post-session environment improvements |
| `writing-for-agents` | User-invoked | Write documentation optimized for AI consumption |

**Philosophy:** Small, composable, easy to adapt. Addresses four problems: misalignment between developer and agent, verbosity from lack of shared terminology, code quality from insufficient feedback loops, architectural decay from rapid unguided development.

**Note on grill-me in our workflow:** We already have the agent suggest `grill-me` at the end of contract and plan stages when it detects ambiguity or risk. The model-invoked `grilling` primitive is the underlying building block — worth understanding if we want to build our own interrogation-style gates.

---

## pstack — Lauren Tan (@poteto)

**Type:** Framework (not just a skill library). An opinionated, end-to-end engineering system.

**Repo:** https://github.com/cursor/plugins/tree/main/pstack/skills
**Claude port:** https://github.com/michael-denyer/pstack-claude

**Scale:** 24 workflow skills + 23 engineering principles + 22 task playbooks.

**Primary entry point:** `/poteto-mode` — a router that reads engineering principles, matches the request to a playbook, calls specialist skills sequentially, and delegates by model role.

### Five design principles worth noting

1. **Verification as infrastructure** — agents must produce evidence of success, not just announce it. ("The build passed" is not verification.) Verification method must match what changed: UI changes walk workflows, performance changes compare traces.
2. **Materialized memory** — compact, machine-usable feature maps refreshed daily. Agents don't rediscover architecture each run.
3. **Context engineering is human work** — humans ensure agents understand the problem before coding begins. Skills like `/how`, `/why`, `/teach` gather historical context from git, PRs, and logs.
4. **Prototype as plan** — competing implementations tested against reality before architecture is committed.
5. **Parallelism after trust** — multi-agent scaling only after verification and context are proven reliable.

**Trade-off:** High rigor consumes significant compute. One documented case: comparable project took twice as long but caught three agent hallucinations. Philosophy: spend extra compute where being wrong is expensive.

### pstack skill inventory (selected)

| Skill | Category | What it does |
|---|---|---|
| `poteto-mode` | Router | Routes requests to playbooks |
| `architect` | Design | Starts from caller usage before sketching solutions |
| `arena` | Design | Runs competing implementations, synthesizes strongest |
| `swarm` | Execution | Multi-agent parallel work coordination |
| `interrogate` | Review | Shows dismissed findings, not filtered lists |
| `blast-radius` | Risk | Assesses change impact before committing |
| `tdd` | Build | Red-green-refactor |
| `no-comments` | Quality | Enforces self-documenting code |
| `unslop` | Quality | Removes AI-generated filler and verbosity |
| `reflect` | Meta | Post-task retrospective |
| `recall` | Context | Recovers prior session state |
| `figure-it-out` | Exploration | Open-ended investigation mode |
| `teach` | Context | Builds agent understanding from historical sources |
| `why` / `how` | Context | Gather rationale and implementation history |
| `principle-*` (23) | Principles | Encode engineering fundamentals as callable skills |

---

## Comparison

| Dimension | agent-skills (Addy) | skills (Pocock) | pstack (Lauren) |
|---|---|---|---|
| Scope | Full lifecycle, 25 skills | Focused on loops + alignment | Full framework, 70+ artifacts |
| Entry point | Per-skill invocation | `/ask-matt` router or direct | `/poteto-mode` router |
| Review depth | 4-layer stack | 2-axis (standards + spec) | `interrogate` with evidence trail |
| Verification model | Checklist-based | Feedback loop emphasis | Evidence-required (artifacts) |
| Context management | `context-engineering` skill | `domain-modeling`, `handoff` | Materialized memory + `/recall` |
| Best for | Well-rounded coverage across lifecycle | Developer alignment and quality loops | High-trust, high-rigor multi-agent work |
| Adoption friction | Low — install and use individual skills | Low — small and composable | High — full framework buy-in |

---

## Lessons for This Kit

### Worth appropriating from Addy's review stack

Our current `run review` is a single-pass review. Addy's four-layer model is better — each axis is independent and can be invoked selectively based on risk:

- **Security pass** — the kit has no dedicated security review skill. Addy's `security-and-hardening` covers OWASP, auth, secrets, and dependency auditing.
- **Performance pass** — the kit has a `perf-gate` flag in plan.md but no dedicated performance review skill for the diff.
- **Simplification pass** — Chesterton's Fence (don't remove code you don't understand) and Rule of 500 are both worth encoding as explicit review criteria.

**Proposal:** Add optional flags to `run review`:
```
run review --security
run review --perf
run review --simplify
```
Or make them standalone skills invoked between implement and review.

### Worth watching from pstack

- **`blast-radius`** — assessing change impact before committing is something our plan stage doesn't explicitly do. Could be a lightweight addition to the plan-review prompt.
- **`unslop`** — removing AI verbosity from generated artifacts. Our spec files and generated `handoff.md` entries could benefit from this.
- **`arena`** — competing implementations for design decisions. Could be a spike pattern variant.
- **Materialized memory** — the concept of a compact feature map refreshed per session is worth revisiting as the workflow scales to larger codebases.

### Worth watching from Pocock

- **`writing-for-agents`** — documentation written specifically for AI consumption. Relevant to how we write `CLAUDE.md` and `copilot-instructions.md`.
- **`domain-modeling`** — sharpening terminology before implementation. Could slot between contract and plan.
- **`retro`** — post-session environment improvements. Complements our `closeout` stage.

---

## Open Questions

- Should the kit's review stage become a multi-layer stack (security, perf, simplification) or keep it as one comprehensive pass?
- Is a dedicated security skill the right granularity, or does it belong inside the existing reviewer agent?
- How much of pstack's verification-as-evidence model is already covered by our `test.md` log, and what's missing?
