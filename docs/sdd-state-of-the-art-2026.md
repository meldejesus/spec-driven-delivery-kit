# Spec-Driven Development: State of the Art (2025–2026)

A synthesis of the newest thinking, tools, research, and voices shaping how specs govern AI-assisted software delivery.

---

## The Insight That Changed Everything

In 2025, the industry discovered that AI coding agents do not have a capability problem — they have a **specification problem**. Raw model intelligence is not the binding constraint on output quality. The binding constraint is the precision of what you tell the model to build.

This is now backed by empirical research, formalized in commercial frameworks, encoded in open standards under the Linux Foundation, and validated across hundreds of enterprise deployments. The result is a discipline that borrows from requirements engineering, contract theory, formal methods, BDD, TDD, and platform engineering — and is being radically reshaped by the presence of AI agents as first-class development participants.

---

## The Paradox That Launched the Movement

A May 2025 arXiv paper — *"The Productivity-Reliability Paradox: Specification-Driven Governance for AI-Augmented Software Development"* — named a systematic phenomenon: AI coding assistants produce **20–56% individual productivity gains** in controlled lab settings, yet simultaneously produce **organizational delivery degradation**.

The data:
- **DORA 2024**: 25% AI adoption correlated with a 7.2% decrease in delivery stability.
- **GitClear 2025**: Projected doubling of code churn in AI-assisted teams.
- **Becker et al. (2025)**: The most rigorous randomized controlled trial found a **19% slowdown** for experienced developers on mature codebases.
- **Faros AI**: 98% more merged PRs alongside 91% longer review times — no net improvement in throughput.

The paradox resolves when you control for task abstraction level, codebase maturity, and developer experience. AI excels at well-scoped tasks in greenfield projects. It degrades on architectural coherence, long-horizon consistency, and mature systems where verification overhead exceeds generation gains.

**The paper's central thesis**: *"Specification discipline, not model capability, is the binding constraint on AI-assisted software dependability."*

---

## What Spec-Driven Development Is

Spec-driven development (SDD) is a methodology in which an **executable, version-controlled specification** — not the code — is the primary artifact. Write the spec, derive an implementation plan, break it into atomic tasks, then generate code.

The modern form coalesced in 2025 around three failure modes of LLM coding agents:

- **Intent drift** — Vague prompts give agents no basis for making correct architectural trade-offs.
- **Context decay** — As a codebase grows past an agent's effective context window, it silently contradicts prior decisions.
- **Unverifiable output** — Without explicit acceptance criteria, there is no ground truth for "correct."

Thoughtworks' Technology Radar (Vol. 32–33) positioned SDD as a key 2025 technique. The canonical three-artifact pipeline, now instantiated in both Amazon Kiro and GitHub Spec-Kit:

| Artifact | Contents |
|---|---|
| `requirements.md` | User stories + acceptance criteria in EARS notation |
| `design.md` | Component breakdown, data flow, integration points |
| `tasks.md` | Dependency-ordered, discrete, executable implementation steps |

---

## EARS Notation: The Syntax That Makes Requirements Agent-Readable

The Easy Approach to Requirements Syntax (EARS) was published at IEEE RE'09 by Alistair Mavin at Rolls-Royce. It had mainstream adoption at Airbus, Bosch, NASA, Intel, and Siemens long before AI agents arrived. In 2025 it became the **default requirement syntax for agentic development** because its structured patterns are unambiguous enough for LLMs to parse and execute reliably.

| Pattern | Template |
|---|---|
| Ubiquitous | The `<system>` shall `<action>` |
| Event-Driven | When `<trigger>`, the `<system>` shall `<action>` |
| State-Driven | While `<state>`, the `<system>` shall `<action>` |
| Unwanted Behavior | If `<condition>`, then the `<system>` shall `<action>` |
| Optional Feature | Where `<feature>`, the `<system>` shall `<action>` |

Amazon Kiro (launched July 2025) made EARS notation the default output format for its requirements generation step. EARS is becoming the universal SDD requirement language for AI systems — the spec-driven equivalent of Gherkin becoming the universal BDD language.

---

## The Major Tools and Frameworks

### Amazon Kiro (July 2025 / GA 2026)
The most prominent commercial SDD tool. Built on Code OSS (VS Code base), powered by Claude via Amazon Bedrock, with a spec-driven workflow baked into the IDE. Kiro generates three mandatory artifacts (requirements/design/tasks) before writing any code. Feature-level "hooks" run automatically when files change (on-save, on-push), enforcing spec compliance without developer intervention. It introduced "spec-driven development" as a term to mainstream developer vocabulary.

### GitHub Spec-Kit (Open-sourced September 2025)
MIT-licensed, works with 30+ AI coding agents including Claude Code, Copilot, and Gemini CLI. Adds a "constitution" layer — a project-level behavioral constraint document — on top of the three-artifact pipeline. Internal GitHub teams using Spec-Kit shipped features with roughly an order-of-magnitude fewer "regenerate from scratch" cycles than ad-hoc prompting.

### OpenSpec (Thoughtworks Radar "Assess")
Tool-agnostic SDD framework focused on **spec deltas** rather than upfront complete specifications. Its three-step flow (propose → apply → archive) lets teams adopt SDD incrementally on existing codebases without full upfront spec authorship.

### Tessl (Raised $125M, Spec Registry September 2025)
The most radical approach: **spec-as-source**. Tessl's thesis is that specifications — not code — become the permanently maintained artifact. Developers write and maintain specs in Markdown under `specs/`, tagged with `@generate` and `@test` directives. Code is AI-generated output, not the thing you maintain. The **Tessl Spec Registry** (open beta September 2025) is a dependency system for versioned specification packages — 10,000+ specs describing how to use external libraries — solving the agent API-hallucination problem by giving agents formal specs for their dependencies rather than relying on training data. Guy Podjarny's timeline claim: by end of 2027, developers working with agents won't look at code most of the time.

### BMAD Method (~49K GitHub stars, MIT)
Open-source agile-simulation-first framework. BMAD orchestrates 12+ specialized AI agent personas — Mary (Business Analyst), Preston (Product Manager), Winston (Architect), Devon (Developer), Quinn (QA) — across the full SDLC. Less a specification format and more a **multi-agent orchestration framework** that produces rich documentation artifacts. Works inside Claude Code, Cursor, and Codex CLI. Its primary value is a structured handoff protocol between specialist agents.

---

## The Practitioners: Who to Follow

### Nate B. Jones — Specification Engineering Framework

Jones is an AI strategy educator who distilled four distinct skills most practitioners conflate under "prompting":

1. **Prompt Craft** — Writing well-formed individual prompts (where most devs plateau)
2. **Context Engineering** — Curating what goes into the context window
3. **Intent Engineering** — Specifying *what outcome you actually want*, not just the task
4. **Specification Engineering** — Writing formal, durable specs that govern AI behavior

His claim: 90% of "AI-native" developers are stuck at level 1, and the gap to levels 3–4 is 10x in capability.

His **Five Levels of AI Coding** framework (from his *"Dark Factory"* Substack, February 2026):

| Level | Description |
|---|---|
| L0 | AI as spicy autocomplete |
| L1 | Chat-driven code generation |
| L2 | AI in the IDE with suggestions (most "AI-native" devs plateau here) |
| L3 | Agent-driven loops with human review |
| L4 | Human specifies, AI executes and verifies |
| L5 | Dark Factory — no human writes code; teams write specs, AI builds and tests against behavioral scenarios, humans approve artifacts |

His **Precision Tax** thesis: as model capability increases, the precision required of human inputs also increases. Vague intent that worked at L1 causes catastrophic drift at L4.

**Read:** natesnewsletter.substack.com

---

### Matt Pocock — Composable Skills, TDD-First AI, TypeScript as Spec

Pocock is the TypeScript educator behind Total TypeScript. His `mattpocock/skills` repo reached 176,000 GitHub stars and 7.5M+ downloads by July 2026 — a collection of 40+ composable agent skills for Claude Code and similar tools.

**His critique of process-ownership frameworks**: *"Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control."* His alternative: small, individually deployable, modifiable skills that encode engineering fundamentals at the points where agents tend to skip them.

**His guiding principle** (citing Pragmatic Programmer): *"Always take small, deliberate steps. The rate of feedback is your speed limit."*

**The four problems his skills solve:**

| Problem | Skill |
|---|---|
| Misalignment | `/grill-me`, `/grill-with-docs` — one-question-at-a-time requirements interrogation before any code is written |
| Verbosity | `CONTEXT.md` with domain-specific terminology to reduce jargon confusion and token waste |
| Broken Code | `/tdd` — enforces red-green-refactor; prevents Claude Code from writing implementation before a failing test exists |
| Poor Architecture | `/improve-codebase-architecture`, `/codebase-design` — continuous design investment |

**TypeScript as specification**: Pocock argues that TypeScript's type system functions as a living specification for AI agents. His `.cursor/rules` guidance specifically notes: *"When declaring functions on the top-level of a module, declare their return types. This will help future AI assistants understand the function's purpose."* Types act as machine-readable intent constraints — 94% of LLM-generated code compilation errors are type-check failures, making types the most direct available spec mechanism.

**Read:** github.com/mattpocock/skills · totaltypescript.com

---

### Kent C. Dodds — MCP, Behavioral Testing, Agentic Architecture

Dodds (creator of Testing Library) has pivoted from web/React education to **EpicAI.pro**, a platform for AI-native application architecture.

His most important 2025–2026 contribution is becoming the leading educator-advocate for the **Model Context Protocol** in the web dev space. He frames MCP as the infrastructure needed for a "Jarvis" interaction model: an assistant that knows you, maintains context across your life, and can *do things* rather than just respond. His quote: *"The next era is: Add your app to the chatbot."*

**His testing philosophy carried forward**: Dodds' long-standing principle ("test what users see, not implementation details") maps directly to AI contexts. He advocates AI generating tests guided by behavioral principles. His finding: AI-generated tests improve significantly when you send specific testing principles as context, not just instructions — which is a micro version of the SDD argument applied to test generation.

**Read:** epicai.pro · kentcdodds.com/blog

---

### Kyle Cook — SDD Practitioner Dissemination

Cook (Web Dev Simplified, 4M+ YouTube subscribers) has produced several directly relevant videos in 2025–2026:

- *"How to Work with AI Coding Agents: Spec-Driven Development, Context and Loop Engineering, Workflows"* (July 2026)
- *"My AI Coding Workflow 2026: This is how I AM CODING right now!"* (December 2025)
- *"AI Agent Skills To Get Ahead of 96% of Web Developers"* (June 2026)

His framing: *"Most people use AI coding agents by giving them one giant prompt and letting them run wild."* His workflows emphasize specifying work upfront and maintaining control throughout. Cook has not published a named framework or written manifesto — his value is disseminating SDD ideas to mainstream web developers at scale.

**Watch:** youtube.com/@WebDevSimplified

---

### Addy Osmani — Context Engineering and the 19-Skill Workflow

Osmani (ex-Google Chrome DevRel, now Anthropic) is the most prolific practitioner-writer on production AI coding workflows. His approach:

- Create a `spec.md` before any coding ("waterfall in 15 minutes")
- Use `gitingest` or `repo2txt` to bundle relevant code sections as context
- Only include task-relevant portions ("selective context inclusion")
- Commit granularly after each task ("save points in a game")

His `addyosmani/agent-skills` repo encodes a full DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP lifecycle into 19 production-grade skills built on Google engineering methodology.

**Read:** addyosmani.com/blog · github.com/addyosmani/agent-skills

---

### Sean Grove (OpenAI) — The Intellectual Origin Point

Grove's talk *"The New Code"* at the AI Engineer World's Fair 2025 is the most-cited origin of the modern SDD movement. His argument: developers experiment with prompts, discard them, and keep only generated code — which is *"you shred the source and then carefully version control the binary."* Specs should be the versioned artifact. He used OpenAI's model spec (a living Markdown document with clause IDs and associated test prompts) as the exemplar.

---

## Context Engineering: Why Specs Are the Most Important Prompt

The most important conceptual shift of 2025 is distinguishing **prompt engineering** from **context engineering**:

- **Prompt engineering**: Crafting the immediate instruction to an AI agent for a specific task.
- **Context engineering**: Designing the entire knowledge infrastructure an agent draws from across all tasks — the metadata, architecture decisions, conventions, constraints, and policies available in its context window.

Andrej Karpathy gave the canonical formulation in June 2025: *"Context engineering is the delicate art and science of filling the context window with just the right information for the next step."* Gartner declared "context engineering is in, and prompt engineering is out," predicting it will appear in 80% of AI tools by 2028.

**Specs are context engineering.** A well-written `requirements.md`, `design.md`, `CLAUDE.md`, or `AGENTS.md` is a context engineering artifact — it shapes what the agent knows about the project persistently, not just for a single interaction.

The academic paper *"Mise en Place for Agentic Coding"* (arXiv 2605.05400) formalizes this as three-phase preparation:
1. **Contextual grounding** — Externalize domain expertise and tacit knowledge into structured documents.
2. **Collaborative specification** — Human-agent dialogue produces detailed design artifacts.
3. **Task decomposition** — Spec artifacts are converted into structured, dependency-aware task records.

The finding: approximately two hours of MEP preparation enabled rapid parallel implementation of a full-stack educational platform by concurrent AI agents during a competitive hackathon. Preparation time converts directly to agent effectiveness.

**Token efficiency**: The Chroma Research "Context Rot" study (July 2025) tested 18 frontier models and found every model degraded as input length grew, with accuracy cliffs well before the rated context limit. Simon Willison (creator of Django) noted that TOON-style token-compression formats cause models to spend *more* tokens figuring out the format — a counterintuitive failure mode. The practical answer: LangChain's four-pillar taxonomy — **Write, Select, Compress, Isolate** — is the most widely adopted practitioner framework for context engineering.

---

## Token Optimization: The Economics of Agentic Work

Agentic workloads consume **10–100x more tokens** than equivalent single-turn chat. A code review agent on a 2,000-line PR: ~50,000 tokens. A browser-use agent on a multi-step procurement workflow: ~200,000 tokens. Inference now represents **55% of AI cloud spending** for organizations with mature agentic deployments. Production agents operate at roughly a **100:1 input-to-output ratio** — 100 tokens consumed for every 1 generated. Cost optimization lives almost entirely on the input side.

### The Context Rot Problem

The Chroma Research "Context Rot" study (July 2025, Kelly Hong, Anton Troynikov, Jeff Huber) tested 18 frontier models and found a counterintuitive result: every model degrades as input length grows, with accuracy dropping **20–50% from 10K to 100K+ tokens** — non-uniformly, not at a predictable cliff.

Model-specific behavior:
- **Claude**: Slowest degradation rate overall. Exhibits conservative abstention behavior on very long tasks (refuses rather than hallucinating). Reliable for shorter contexts; "picky" on very long ones.
- **GPT**: Most erratic — highest hallucination rates when distractors are present; random mistakes and outright refusals.
- **Gemini**: Starts degrading earliest; most volatile accuracy swings.
- **Qwen**: Degrades steadily; larger variants (235B) hold up better than smaller ones.

Counterintuitive finding: models perform **better on shuffled haystacks than on logically structured ones** — attention mechanisms are sensitive to input organization in unexpected ways. Logical structure may create false "gravity" that draws the model toward wrong answers.

**Practical implication**: Don't treat context window size as a capability ceiling you can fill freely. Strategic curation (context engineering) is more predictive of output quality than raw token count. Study is open-source at github.com/chroma-core/context-rot.

### The Five-Component Token Budget Model

From production agentic system analysis (Maxim AI, 2025), allocate your context window budget across five components:

| Component | Budget Share |
|---|---|
| System instructions | 10–15% |
| Tool schemas/descriptions | 15–20% |
| Knowledge context (retrieved docs, RAG) | 30–40% |
| Conversation history | 20–30% |
| Reserve buffer | 10–15% |

**Cache hit rate targets by component type:**
- Static (system prompt, tool definitions): target 95%+ cache hit rate
- Semi-static (user profile, preferences): 60–80%
- Dynamic (real-time data, current turn): 0–20% — don't attempt to cache these

### LangChain's Four-Pillar Taxonomy

The most widely adopted practitioner framework for context engineering, from the `langchain-ai/context_engineering` repository:

| Pillar | What It Does | How |
|---|---|---|
| **Write** | Store context externally so the model doesn't re-derive it every turn | `StateGraph` state persistence; cross-session memory with namespaces; checkpointing |
| **Select** | Retrieve only what the current step needs — timed precisely | Semantic tool discovery (Bigtool); namespace-based memory queries; RAG |
| **Compress** | Retain only essential tokens | Rolling summarization; tool output compression; conditional compression at length thresholds |
| **Isolate** | Partition context across specialized agents, each with focused windows | Supervisor + sub-agent architecture; sandboxed execution environments |

Core insight from Isolate: a single agent with a massive context is worse than multiple agents with focused contexts.

### Prompt Compression Techniques

When you must compress, the options have different tradeoffs:

| Technique | Best For | Reported Savings |
|---|---|---|
| **LLMLingua / LongLLMLingua** (Microsoft Research) | Retrieved documents in RAG pipelines | Up to 20x compression; LongLLMLingua +21.4% performance with fewer tokens |
| **Selective Context** | Generic prompt pruning | 50% context reduction; 0.023 BERTScore degradation |
| **RECOMP** | Query-specific RAG compression | Rewrites only what the question needs; abstractive variant best |
| **Rolling summarization** | Long conversation history | Model-independent; implemented in LangGraph with `summary` state fields |

**On TOON format**: Token-Oriented Object Notation claims 39.6–61% fewer tokens vs. JSON for tabular data. Simon Willison ran 9,649 experiments across 11 models and found a critical failure mode: at 500-table schemas, TOON used **138% more tokens than YAML** (~1,100 vs ~450); at 10,000 tables, **740% more tokens**. The model doesn't know TOON's syntax and burns tokens in correction loops. Frontier models handle it better than open-source models, but YAML still wins at scale. The lesson: format familiarity matters more than format compactness.

### Anthropic / Claude-Specific Optimization

**Prompt caching** is a prefix cache. Anthropic hashes your rendered prompt up to each `cache_control` breakpoint.

- **Rendering order**: Tools → System → Messages. Cache breakpoints must follow this order.
- **Cache read cost**: ~10% of regular input (90% savings). Cache write: ~25% more than regular input.
- **Minimum cacheable prefix**: ~1,000–3,000 tokens. Shorter prefixes silently skip caching.
- **Up to 4 explicit `cache_control` breakpoints** per request.
- **TTL**: 5-minute default (resets on each read) or 1-hour at additional write cost.

**Silent cache invalidators to audit:**
- `datetime.now()` or timestamps embedded in the system prompt
- Per-request UUIDs near the front of messages
- Non-deterministic JSON serialization (fix: `sort_keys=True`)
- Tool lists assembled dynamically per-user
- Conditional system sections based on runtime flags

**The 20-block lookback window**: The platform searches 20 blocks for cache hits. Long agent turns with many `tool_use`/`tool_result` pairs can exceed this. Fix: place intermediate breakpoints every ~12 blocks in lengthy turns.

**`budget_tokens` (Extended Thinking)**: Added March 2026. Caps inference-time reasoning. Starting approach: add `budget_tokens=2048` to your three highest-volume calls, bump to `4096` only if quality regresses. Reported outcome: **40–50% cost reduction in week one** for most teams. Stacking extended thinking budget + prompt caching + LiteLLM proxy reportedly drops typical agent workload costs by **~70%**.

**Tier routing**: Use Claude Opus/Sonnet for main loop reasoning, Haiku subagents for cheap sub-tasks (classification, routing, extraction). Haiku can process simple tasks at a fraction of the cost while preserving the expensive model's cache prefix.

**`count_tokens` endpoint**: Call `client.messages.count_tokens()` before sending — it's free. Never use `tiktoken` for Claude; it systematically undercounts. Only the native endpoint is accurate for budget enforcement.

### TALE: Token-Budget-Aware Reasoning

The TALE framework (arXiv 2412.18547, ACL 2025 Findings) addresses output verbosity:

- **TALE-EP**: Estimates a reasonable token budget using zero-shot prompting, then injects that estimate into the reasoning prompt as an explicit constraint. Result: **67% average reduction in output tokens with less than 3% accuracy drop** across 7 datasets on GPT-4o-mini.
- **TALE-PT**: Post-training variant that internalizes budget awareness without needing explicit budget prompts — better for production where you control fine-tuning.

Implementation: classify problem complexity, estimate budget, inject "Solve this in approximately N tokens" into the reasoning prompt. Available at github.com/GeniusHTX/TALE.

### MCP Code Mode Pattern

Instead of exposing 150 tool schemas directly to the LLM (massive token overhead), expose only four meta-tools: `list_tools`, `get_tool_docs`, `call_tool`, `call_tools_sequential`. The model writes code to orchestrate tools without seeing full definitions upfront. Bifrost benchmarks: **50%+ token reduction for multi-server MCP deployments**.

### CONTEXT.md: Matt Pocock's Token Waste Reduction

Pocock argues that beyond approximately 100,000 tokens of context, reasoning quality degrades sharply — he calls this the "dumb zone." Vendors advertising million-token windows are "shipping more dumb zone."

His `CONTEXT.md` file is a **bounded-context glossary** — a per-module terminology file that answers:
- Why certain naming conventions were chosen
- What architectural decisions were made and why
- Invariants and constraints that apply to this area of the codebase
- Known pitfalls and approaches to avoid

When starting a session on a module, the agent reads the relevant `CONTEXT.md` first. A `CONTEXT-MAP.md` serves as an index for multi-context repositories. This eliminates re-derivation: without it, the model spends tokens re-exploring architecture it should already know.

### Selective Context Inclusion: Addy Osmani's Approach

From his December 2025 piece "My LLM coding workflow going into 2026":

**Include only:**
- Specific modules directly related to the task (not the whole repo)
- Known constraints, edge cases, and technical invariants
- Official API documentation for niche/new libraries (paste directly; don't assume the model has them)
- Git diffs and commit logs for historical context
- Linter output and test failures to guide corrections

**Explicitly exclude:**
- Files that are out of scope: state "Do not touch the auth module"
- For large codebases: use `gitingest` or `repo2txt` to bundle only key source files into a text dump rather than entire repositories

**Brain dump pattern**: Before coding, front-load a focused context containing: high-level goal and invariants, examples of good solutions, and explicit warnings about approaches to avoid. This prevents expensive model-driven discovery.

### Token Optimization Quick Reference

| Technique | Reported Savings |
|---|---|
| Prompt caching (Anthropic `cache_control`) | 90% on cached tokens |
| TALE framework (budget prompt injection) | 67% output token reduction, <3% accuracy loss |
| LLMLingua (token-level perplexity pruning) | Up to 20x compression |
| MCP Code Mode (4 meta-tools vs. 150 schemas) | 50%+ token reduction |
| TOON at scale — avoid it | Uses 138–740% more tokens than YAML |
| Extended thinking budget (`budget_tokens`) | 40–50% cost reduction |
| Stacked optimizations (caching + budget + routing) | Up to 70–80% cost reduction |
| Context rot threshold — keep context focused | Accuracy drops 20–50% past 10K–100K tokens |

---

## TDD + SDD: The Combination That Produces Shippable Code

TDD and SDD are complementary:

- **TDD's primary artifact**: A failing test. Write test → write code to pass → refactor.
- **SDD's primary artifact**: A specification. Write spec → derive tests and code → validate.
- **The combination**: Write spec → generate tests from spec (executable contracts) → generate code that passes tests.

The academic instantiation is **TDAD (Test-Driven AI Agent Definition)**, introduced in the Productivity-Reliability Paradox paper. The four-stage TDAD process uses test cases as executable specifications and achieves 86–100% mutation scores — far higher than ad-hoc AI code generation.

Key insight: **tests are executable fragments of the specification**. When you write tests before code in an AI workflow, you are operationalizing your spec's acceptance criteria. The spec becomes the grammar; tests are sentences in that grammar; code is the runtime that makes the sentences true.

---

## BDD Evolution: Gherkin Meets AI

BDD is being **transformed from a collaboration technique into a specification substrate**.

The traditional BDD value proposition (cross-functional Given/When/Then workshops) is weakened by AI's presence, since AI can generate Gherkin from natural language descriptions. The new BDD value proposition is that **Gherkin is an ideal input format for AI agents** — it is structured, human-readable, unambiguous, and maps cleanly onto test assertions.

2025 evolution paths:

| Path | Description |
|---|---|
| AI as BDD writer | Tools generate Gherkin scenarios from user story descriptions |
| AI as BDD debugger | AI analyzes failing scenarios and suggests implementation corrections |
| BDD → SDD convergence | Given/When/Then becomes the acceptance criteria format inside `requirements.md` |

Cucumber crossed 40 million downloads with users doubling every 18 months. The format is growing; its original collaborative workshop purpose is giving way to its value as machine-readable acceptance criteria.

---

## OpenAPI/AsyncAPI: Spec-First in API Design

Postman's State of the API Report 2025: 82% of organizations have adopted API-first, with 25% fully API-first (up 12% from 2024).

Key 2025–2026 technical advances:

- **OpenAPI 3.1.1**: Full JSON Schema alignment — schemas shareable across validation, documentation, and code generation without compatibility shims.
- **OpenAPI 3.2 (September 2025)**: First-class streaming support (SSE and JSON Lines); structured tag navigation for large API catalogs.
- **OpenAPI Overlays 1.0**: Apply spec transformations without modifying base specs — critical for multi-team environments.
- **Arazzo 1.0.x**: A new standard for multi-step API workflow orchestration, describing sequences of API interactions as first-class specifications.

**The contract testing divide:**

| Approach | Tool | Philosophy |
|---|---|---|
| Spec-from-behavior | Pact | Write consumer tests → derive contract |
| Spec-then-behavior | Specmatic | Write the spec → derive tests and stubs |

In 2025–2026, the Specmatic model is gaining ground precisely because it aligns with the broader SDD shift toward spec-first. Specmatic's critique of Pact: consumer-driven contracts create coordination bottlenecks that undermine parallel development.

The key new pressure: **89% of developers use AI tools, but only 24% design APIs specifically for AI agents** (Postman 2025). Making OpenAPI specs agent-readable — not just developer-readable — is the next frontier.

---

## Governing AI Agents with Specs: AGENTS.md and Policy-as-Code

### The File-Based Convention Layer

**AGENTS.md** is an open standard published in August 2025 by OpenAI, Google, Cursor, Factory, and Sourcegraph, now stewarded by the **Agentic AI Foundation under the Linux Foundation** (platinum members: Anthropic, Google, Microsoft, OpenAI). Adopted in 60,000+ repositories as of mid-2026.

The conceptual distinction:
- `README.md` answers **"what"** — a marketing page for humans.
- `CLAUDE.md` / `AGENTS.md` answers **"how"** — an operations manual for machines.

Recommended AGENTS.md sections:

```
- Project overview and architecture
- Build/test/lint commands
- Code style conventions
- Testing requirements
- Security constraints
- Commit/PR rules
```

**Practical upper limit**: ~150–200 standing instructions before reliability degrades. "Comprehensiveness is a failure mode." Structure as WHAT/WHY/HOW with progressive disclosure.

### Beyond Conventions: Policy-as-Code for Agents

The file-based convention layer is only the beginning. As agents become more autonomous:

**Policy Cards** (arXiv 2510.24383): Machine-readable, deployment-layer standards for expressing operational, regulatory, and ethical constraints. Runtime-enforceable, with crosswalk mappings to NIST AI RMF, ISO/IEC 42001, and the EU AI Act.

**Microsoft Agent Governance Toolkit** (open-sourced April 2026): Addresses all 10 OWASP Agentic Top 10 risks with deterministic, sub-millisecond policy enforcement. Covers runtime security, zero-trust identity, and execution sandboxing.

**EU AI Act**: Now law, with penalties up to €35M or 7% of global turnover. Singapore's IMDA Model AI Governance Framework (January 2026) requires verifiable digital identity and audit trails for autonomous agents. NIST's AI Agent Standards Initiative (February 2026) addresses agent identity and authorization.

**The governance gap**: KPMG 2026 survey found 75% of enterprise leaders cite security, compliance, and auditability as critical for agent deployment — but only one in five companies has a mature governance model.

---

## Formal Specifications: The State of TLA+, Alloy, and Lean

The formal verification community is engaging with AI on two fronts — AI generating formal specs, and AI verifying formal specs. The empirical picture from 2025 benchmarks:

- **TLAiBench**: Models can handle logic puzzles but struggle with real-world system modeling — they pass the model checker without correctly describing the system's actual semantics.
- **Lean 4 / FVAPPS** (4,715 problems): Claude Sonnet solves ~30%, Gemini 1.5 Pro ~18.5%.
- **CLEVER** (161 Lean problems): Top models fully solve 1 of 161 tasks.

**The key insight**: successfully running a model checker is not an indicator of semantic correctness. AI-generated formal specs tend to be syntactically valid but semantically wrong. The gap between "compiles" and "correctly specifies behavior" remains large.

**Practical implication**: TLA+ and Alloy are increasingly valuable as a *check* on AI-generated designs for distributed and concurrent systems, but the AI-native workflow for generating them is not yet reliable enough to run unattended.

---

## The Emerging Architecture of Spec-Driven Development

The field is converging on a layered architecture for spec-governed AI development:

```
┌─────────────────────────────────────────────────────┐
│  CONSTITUTIONAL LAYER                                │
│  AGENTS.md / CLAUDE.md / Policy Cards               │
│  (Project-wide rules: style, security, commit       │
│   conventions, agent permissions)                   │
├─────────────────────────────────────────────────────┤
│  FEATURE SPECIFICATION LAYER                        │
│  requirements.md (EARS notation + Given/When/Then)  │
│  design.md (components, data flow, integrations)    │
│  tasks.md (ordered, executable steps)               │
├─────────────────────────────────────────────────────┤
│  CONTRACT LAYER                                     │
│  OpenAPI / AsyncAPI / Protobuf specs                │
│  Consumer-driven contracts (Pact / Specmatic)       │
├─────────────────────────────────────────────────────┤
│  EXECUTABLE VERIFICATION LAYER                      │
│  BDD scenarios (Gherkin / Cucumber)                 │
│  Test-driven contracts (TDAD)                       │
│  Formal specs (TLA+, Alloy) for critical systems    │
├─────────────────────────────────────────────────────┤
│  RUNTIME GOVERNANCE LAYER                           │
│  Policy Cards / Policy-as-Code                      │
│  Agent Governance Toolkit (OWASP Agentic Top 10)   │
│  EU AI Act compliance logging                       │
└─────────────────────────────────────────────────────┘
                          ↑
                    AI AGENTS
              (generate, verify, govern)
```

Each layer constrains the layer below it. The constitutional layer sets project-wide invariants. The feature spec layer directs task execution. The contract layer enforces interface compatibility. The executable layer makes acceptance criteria machine-checkable. The runtime governance layer enforces constraints at execution time.

What is new about this architecture: **humans primarily work at the top two layers**, writing and maintaining specs, while AI agents operate in the bottom three layers, generating implementations, running verifications, and self-policing against policy constraints.

---

## Critical Tensions and Open Questions

**Is SDD just waterfall with better marketing?**
Scott Logic's 2025 review of Spec-Kit asks exactly this. The SDD community's answer: shorter feedback cycles, agent-executed rather than human-approval-gated, and specs that evolve continuously rather than freezing at project start. Waterfall front-loads analysis to prevent change. SDD front-loads specification to enable safe change by agents.

**Who writes and maintains the specs?**
If code is no longer the primary maintained artifact (the Tessl thesis), developers must become expert spec writers. Junior developer employment has dropped nearly 20% since 2022. Spec-writing requires deep domain and architectural knowledge. The paradox: the shift to spec-driven development requires *more* sophisticated human judgment, not less.

**Spec drift**
Specs and code diverge over time. In a world where AI agents both write code from specs and generate code the spec hasn't caught up with, maintaining spec-code coherence is a first-class engineering problem. Amazon Kiro's "hooks" (on-save, on-push triggers) are an early attempt to automate this. The Tessl Spec Registry is another.

**Formal methods remain hard even with AI**
AI-generated TLA+ and Lean proofs are syntactically valid but semantically unreliable. Formal methods are valuable as a check on AI-generated system designs for distributed and concurrent systems, but the promise of AI making formal methods accessible to non-specialists has not yet materialized.

---

## Key Research Papers

| Paper | Key Contribution |
|---|---|
| [The Productivity-Reliability Paradox](https://arxiv.org/abs/2605.01160) (arXiv 2605.01160) | Formal theory of SDD governance; Specification Governance Model; TDAD framework |
| [Specification-Driven Development as the Foundation of AI-Native Enterprise SE](https://arxiv.org/html/2607.16680) (arXiv 2607.16680) | SDD as enterprise architecture foundation |
| [Mise en Place for Agentic Coding](https://arxiv.org/abs/2605.05400) (arXiv 2605.05400) | Context engineering methodology for agentic systems; three-phase MEP preparation |
| [Self-Spec](https://openreview.net/forum?id=6pr7BUGkLp) (OpenReview 2025) | LLMs improve code reliability by first authoring their own spec language |
| [ReqBrain](https://arxiv.org/abs/2505.17632) (arXiv 2505.17632) | Fine-tuned 7B LLM achieving 89.3% F1 on ISO 29148-compliant requirements generation |
| [KBSpec](https://arxiv.org/pdf/2606.21339) (arXiv 2606.21339) | LLM formal spec generation with self-evolving domain knowledge base |
| [Policy Cards](https://arxiv.org/pdf/2510.24383) (arXiv 2510.24383) | Machine-readable runtime governance for autonomous agents |
| [LLM-Assisted Repo-Level Generation with Structured SDD](https://arxiv.org/html/2605.02455v1) | Repo-level SDD application |

---

## Summary Map of the Field

| Domain | Key Figure / Tool | Core Artifact or Idea |
|---|---|---|
| Specification Engineering framework | Nate B. Jones | Four Disciplines + Five Levels; Specification Engineering as distinct skill |
| Composable skills / TDD-first AI | Matt Pocock | mattpocock/skills (176k stars); small deliberate steps; TypeScript as spec |
| MCP / agentic architecture education | Kent C. Dodds | EpicAI.pro; MCP as the infrastructure for persistent agent context |
| Practitioner SDD dissemination | Kyle Cook | YouTube video series; workflow emphasis over framework |
| Context engineering and production workflow | Addy Osmani | addyosmani/agent-skills; DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP |
| SDD origin / specs as source of truth | Sean Grove (OpenAI) | "The New Code" talk; specs are the source, code is the binary |
| Context engineering definition | Andrej Karpathy / Tobi Lütke | "Filling the context window with just the right information" |
| EARS notation for AI requirements | Alistair Mavin | EARS structured natural language; now the standard for agentic specs |
| SDD in IDE tooling | Amazon Kiro | spec → design → tasks; EARS notation; on-save/on-push hooks |
| Spec as permanently maintained artifact | Guy Podjarny / Tessl | Tessl Framework + Spec Registry; developers maintain specs, not code |
| Multi-agent SDLC orchestration | BMAD-Method | Named AI personas across full SDLC; file-based context passing |
| Types as machine-readable specifications | TypeScript community | Type definitions as living spec for AI agents |
| Runtime agent governance | Microsoft / OWASP Agentic Top 10 | Agent Governance Toolkit; Policy Cards; EU AI Act compliance |
| Contract testing: spec-then-behavior | Specmatic | OpenAPI spec is the contract; stubs generated from spec |

---

## Session Continuity and Worklog Patterns

As agentic workflows mature, a new problem has emerged: **agents are stateless by default, but delivery work is stateful.** The gap between sessions — where context is lost — is now recognized as one of the primary failure modes in multi-session agent work. The field has converged on a layered memory architecture to solve it.

### The Three-Layer Model (2025–2026 Consensus)

Leading practitioners (Pocock, Anthropic, GitHub Engineering, Ian Paterson) have independently arrived at the same three-layer architecture:

| Layer | File | Answers | Who writes it |
|---|---|---|---|
| **Project state** | `CLAUDE.md` state block | "Where was I?" — recovery in < 10 lines | Agent at session close |
| **Session log** | `worklog/daily-log.md` | "What happened?" — outcomes and decisions | Agent at session close |
| **Ticket** | `workflow/<id>/index.md` | "What am I building?" — authoritative intent | Agent (contract stage) |

The anti-pattern — a date-keyed daily log as the *primary* state — fails because it becomes a log of logs with no machine-queryable structure and no recovery path after context reset.

### Pocock's Handoff Pattern

Matt Pocock's `/handoff` skill (from `mattpocock/skills`) is the clearest statement of the session boundary problem. Key design decisions:

- **User-invoked only** (`disable-model-invocation: true`) — the handoff is an intentional act, not an audit trail
- **Written to the OS temp directory** — not the workspace, so it doesn't pollute the repo
- **References, not duplication** — uses file paths, commit hashes, and issue links instead of re-embedding content
- **Next-session focus** — the document is tailored to what the *incoming* session will do, not a general recap
- **Suggested skills section** — explicitly lists which skills the next agent should invoke first

The handoff document answers four questions: what are we building (ticket ref), where did we get to (state ref), what must the next session do first (one sentence), what decisions are already locked (avoid relitigating).

### The CLAUDE.md State Block

The most effective recovery mechanism identified across practitioners is a small `<!-- BEGIN STATE --> ... <!-- END STATE -->` block embedded in `CLAUDE.md`. It is always loaded (CLAUDE.md is read on every session start), costs almost no context window, and answers the "where was I?" question in under 10 lines:

```
<!-- BEGIN STATE -->
last_session: 2026-08-16 09:14
working: OSMS-123 — implement, task 4/7 done
blocked: nothing
next: finish task 5 (token revocation), then run review
recent:
  - 2026-08-16: OSMS-123 implement started, tasks 1-4 done, build passing
  - 2026-08-15: OSMS-123 plan approved, 7 tasks
  - 2026-08-14: OSMS-123 contract drafted and approved (Gate A)
<!-- END STATE -->
```

This block is agent-maintained, never human-edited. The agent updates it at session close via the worklog skill.

### Session Log Design Principles

The research consensus on `daily-log.md`:

- **Session-keyed, not date-keyed** — multiple sessions per day are distinct entries
- **Outcome-focused, not activity-focused** — "tests passing (3/3)" not "worked on tests"
- **Decisions logged twice** — once in the session log, once as a note on the ticket's `index.md` or `handoff.md`
- **Git carries the file record** — never copy commit hashes or changed file lists into the log; that's what `git log` is for
- **Rolling window** — last 20–30 sessions; prune older entries to the archive

### Dashboard as Generated View

The `dashboard.md` anti-pattern is treating it as a document that someone maintains. The correct pattern (confirmed across Pocock, GitHub Engineering, and Obsidian community) is:

> The dashboard is a **generated view** of ticket frontmatter state. It is never edited directly. The ticket files are authoritative; the dashboard is output.

When a ticket's `status:` field in `index.md` changes (from `in-progress` to `blocked`, for example), regenerating the dashboard reflects that automatically. The worklog skill handles regeneration at session close.

### Key Sources
- Matt Pocock, `mattpocock/skills` — `/handoff` and `/wayfinder` skill patterns
- Ian Paterson, "Claude Code Memory Architecture" (2026) — `/project` command recovery stack
- Anthropic Managed Agents Memory (April 2026 public beta) — file-based memory with audit logs
- GitHub Engineering Blog, "Reliable AI Workflows with Agentic Primitives" (October 2025)
- DEV Community, "Self-Managing Memory System for Claude Code" (2026)

---

## The One-Sentence Synthesis

The field has crossed a threshold: **in 2025–2026, the spec is not documentation of what the code does — the spec is the primary control artifact that governs what the AI does**, and every major tool, framework, standard, and research paper in the space is working out what that means architecturally, epistemically, legally, and culturally.

---

*Last updated: August 2026. Sources include arXiv research papers, Thoughtworks Technology Radar Vol. 32–33, Postman State of the API Report 2025, GitHub Blog, the Tessl, Kiro, BMAD, and Spec-Kit documentation, and practitioner writing from Nate B. Jones, Matt Pocock, Kent C. Dodds, Kyle Cook, Addy Osmani, Sean Grove, Andrej Karpathy, and Simon Willison.*
