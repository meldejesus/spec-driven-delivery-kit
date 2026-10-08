# Spec File Style Guide

Applies to: `.prompt.md`, `.agent.md`, and `SKILL.md` files in this kit.

---

## Why these files are written the way they are

Spec files are instructions for an AI model, not documentation for a human developer. The structure — numbered steps, explicit conditionals, imperative verbs, variable interpolation — exists because models follow procedural instructions reliably. Prose paragraphs are ambiguous; numbered lists are not.

That said, a human has to read and maintain every spec file. The goal is to be clear to both audiences without inflating length.

**The language style is model-driven, but verbosity is not required.** A well-written spec file is short, precise, and scannable.

---

## Core rules

### 1. Imperative, not descriptive
Write what the agent should **do**, not what it **is**.

```
✗  The agent will read the plan file and identify the first unchecked task.
✓  Read plan.md. Find the first [ ] task and execute it.
```

### 2. One instruction per line
Each numbered step = one atomic action. If a step has two actions, split it.

```
✗  2. Read handoff.md and, if it does not exist, create it.
✓  2. If handoff.md does not exist, create it with create_file.
   3. Read the last 40 lines of handoff.md.
```

### 3. Conditions before actions
Put the `if` clause first so the reader knows whether the step applies before reading the action.

```
✗  Run the perf-gate skill if Perf-Gate: Y is set in plan.md.
✓  If plan.md has Perf-Gate: Y — load perf-gate/SKILL.md and apply it.
```

### 4. Short sentences
Aim for sentences under 20 words. Split long conditionals across lines.

### 5. No narrative filler
Cut phrases that restate what a header already says.

```
✗  ## End State
   When all tasks in plan.md are marked [x], the implementation stage is complete.
   At this point you should update .active-workflow.md as follows:
✓  ## End State
   When all tasks are [x]:
   1. Update .active-workflow.md:
```

### 6. Inline only what's used once
If a rule applies everywhere, put it in a shared reference (e.g., `how-to/`). Don't repeat it in every prompt.

### 7. Limit section depth
Two heading levels max (`##` and `###`). Deeper nesting usually means the section should be a separate file.

---

## File length targets

| File type | Target | Hard cap |
|-----------|--------|----------|
| `.prompt.md` (core workflow) | ≤ 120 lines | 200 lines |
| `.prompt.md` (utility/one-off) | ≤ 80 lines | 120 lines |
| `.agent.md` | ≤ 80 lines | 130 lines |
| `SKILL.md` | ≤ 60 lines | 100 lines |

Files that exceed the hard cap should be split or have sections extracted to a referenced file.

---

## What belongs in the file vs. a reference

**In the file:**
- Execution steps (numbered, imperative)
- Conditional gates and failure modes
- Output format specs (handoff.md structure, test.md structure)
- End-state actions (what to write, what to announce)

**In a reference file (loaded on demand):**
- Examples and sample output
- Background theory or rationale
- Notation guides (EARS, ADR format, etc.)
- Shared boilerplate used across multiple prompts

---

## Variable style

Use `${variable_name}` for interpolated values. Keep variable names lowercase with underscores.

```
✓  workflow/${ticket}/handoff.md
✓  ${output_dir}/plan.md
✗  workflow/TICKET_ID/handoff.md
```

---

## When to use a warning callout

Use `> ⚠️` sparingly — only for a rule that is commonly violated and causes hard-to-diagnose failures. If every step has a warning, none of them stand out.

---

## Audit checklist (before merging a new spec file)

- [ ] Does every section have a clear job? Remove sections that exist "just in case."
- [ ] Are there any prose paragraphs that could be a numbered list?
- [ ] Are any steps doing two things? Split them.
- [ ] Is any boilerplate duplicated from another prompt? Extract it.
- [ ] Does the file exceed its length target? Identify what to cut or extract.
- [ ] Does a human reading it cold know what the agent will do in 30 seconds?
