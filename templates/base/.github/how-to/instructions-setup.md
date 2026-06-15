# Instructions Setup — Understanding the AI Instruction Layer

> Reference doc for the project workspace. Explains what each instruction file does,
> who reads it, and what belongs where — especially when switching between Copilot CLI and Codex.

---

## Kit Installation Model

When these files live in a standalone workflow kit, the kit is the source repo.
The active project workspace must still receive installed copies or symlinks of
the discovery files:

```text
AGENTS.md
.github/
.copilot/
workflow/
```

Reason: most agent tools read instructions from the current working directory or
its parents. They do not automatically inspect sibling repositories.

Use the kit installer from the kit root:

```bash
./install/install-to-workspace.sh --target /path/to/workspace
```

Then open Codex, Copilot CLI, VS Code, or another agent from `/path/to/workspace`.

---

## The Two Types of Instructions

Every AI instruction you write falls into one of two categories:

### 1. Project Commands
*What to run.* Mechanical, deterministic facts about the project:
- How to install dependencies
- How to run tests for each app
- How to build, lint, start dev servers
- Monorepo-specific CLI patterns (Nx, yarn workspaces)

These are **the same for every agent** — a fact like "run `npx nx run next-webapp:test`" doesn't change based on which AI is reading it.

### 2. Behavioral Instructions
*How to act.* Guidelines for the agent's reasoning, judgment, and workflow:
- Code style preferences (quotes, semicolons, imports)
- When to ask vs. proceed
- Approval gates and workflow stages
- Persona definitions (which agent does what)
- Architecture patterns and naming conventions
- Domain knowledge (subscription model, qbank structure, etc.)

These can be **agent-specific** — Copilot's gate system doesn't mean anything to Codex, for example.

---

## Who Reads What

| File | Read by | Type of content it's designed for |
|---|---|---|
| `AGENTS.md` (repo root) | Copilot CLI ✅, Codex ✅, Cursor ✅, Amp ✅ | Project commands + universal rules — the "README for agents" |
| `.github/copilot-instructions.md` | GitHub Copilot (VS Code) ✅, Copilot CLI ✅ | Behavioral instructions — Copilot-specific workflow rules |
| `CLAUDE.md` | Copilot CLI ✅ (uses Claude), Claude Code ✅ | Claude-specific behavioral overrides |
| `GEMINI.md` | Gemini agents ✅ | Gemini-specific behavioral overrides |
| `.github/instructions/**/*.instructions.md` | Copilot CLI ✅, VS Code Copilot ✅ | Scoped instructions (per file type, per directory) |

**Key rule:** `AGENTS.md` is the only file in this list that is read by all major agents. Everything else is tool-specific.

---

## The Portability Question — Codex vs. Copilot CLI

If you switch between Codex and Copilot CLI, here's what each agent sees:

| Instruction | Copilot CLI | Codex (cloud) |
|---|---|---|
| `AGENTS.md` | ✅ Loaded | ✅ Loaded |
| `.github/copilot-instructions.md` | ✅ Loaded | ❌ Not read |
| Agent workflow (Gate A/B/C/D, @Architect, etc.) | ✅ Via copilot-instructions | ❌ Invisible unless in AGENTS.md |
| Project test/build commands | ✅ If in either file | ✅ Only if in AGENTS.md |

**Practical consequence:** put universal project commands and rules in
`AGENTS.md`. Keep tool-specific behavior in the tool-specific files.

---

## Installed Workspace Checklist

| File | What it currently contains | Is this correct? |
|---|---|---|
| `AGENTS.md` | Agent registry, universal commands, universal rules | Required |
| `.github/copilot-instructions.md` | Copilot-specific behavior and project guidance | Optional but useful |
| `.github/agents/*.agent.md` | Agent persona definitions | Required for named agents |
| `.github/prompts/*.prompt.md` | Workflow invocation prompts | Required for prompt workflow |
| `.github/skills/*/SKILL.md` | Optional task-specific skills | Optional |

After installing the kit, add the target project's real test, lint, build, and
dev-server commands to `AGENTS.md`.

---

## Recommended Split

```
AGENTS.md (universal — all agents read this)
├── ## Project Commands        ← build, test, lint, dev server
├── ## Agent Registry          ← names + roles (keep what's there)
└── ## Universal Code Rules    ← things every agent should follow regardless of tool

.github/copilot-instructions.md (Copilot-specific)
└── ## Copilot Workflow Rules  ← gates, approval patterns, doc references, path overrides
```

---

## Project Commands to Add to AGENTS.md

Replace these examples with the commands any agent needs for the target project:

```markdown
## Project Commands

### Testing
- **Unit tests:** `<command>`
- **Integration tests:** `<command>`
- **Update snapshots:** `<command>`
- **Affected tests:** `<command>`

### Build & Lint
- **Build:** `<command>`
- **Lint:** `<command>`
- **Typecheck:** `<command>`

### Dev Servers
- **Backend:** `<command>`
- **Frontend:** `<command>`
- **Mobile:** `<command>`
```

---

## Bottom Line

- **Use `AGENTS.md`** for project commands and universal facts — these are portable across every AI tool
- **Use `copilot-instructions.md`** for Copilot-specific behavior, workflow gates, and project domain rules
- **Don't duplicate** — if a rule is in `copilot-instructions.md`, don't also put it in `AGENTS.md` unless you want it to apply to Codex too
- **If you switch to Codex**, move any rules you want it to follow into `AGENTS.md` before doing so
