---
name: simplification-review
description: Focused complexity pass on the current diff. Applies Chesterton's Fence and the Rule of 500 to identify code that could be removed, flattened, or clarified without changing behavior. Invoked optionally after run review.
---

# When to run

After `run review` when the diff is large, introduces new abstractions, adds
significant new code to an existing module, or when the reviewer flagged
complexity concerns.

The reviewer agent will suggest this skill if the diff warrants it. It can also
be invoked directly: `use the simplification-review skill`.

# Principles

**Chesterton's Fence** — before removing or simplifying code, understand why it
exists. If the reason is unclear, flag it rather than delete it. Simplification
that removes a constraint no one remembers is a latent bug.

**Rule of 500** — a file exceeding ~500 lines is carrying too much. Any diff that
pushes a file past that threshold should come with a note on why it wasn't split.

**Subtract before you add** — if the same outcome is achievable with less code,
the simpler path is preferred. New abstractions must earn their place.

# What to check

For each item, note file:line and rate PASS / FAIL / N/A.

## Dead code
- **No unreachable branches introduced.** Conditions that can never be true given the current type or data contract.
- **No unused variables, imports, or exports added.** Flag anything added in this diff that nothing calls.
- **No commented-out code committed.** A comment that says `// old approach` with inert code is a FAIL.

## Abstraction
- **New abstractions have more than one caller.** A helper function called exactly once is usually just inline code with extra indirection.
- **No premature generalization.** A function parameterized for cases that don't exist yet is a FAIL.
- **Wrapper functions that only delegate should be justified.** If `doX()` just calls `reallyDoX()`, what does the wrapper add?

## Duplication
- **No copy-paste from elsewhere in the codebase.** If the same logic exists in two places now, flag it. Don't fix it in this PR unless it's trivial — note it for a follow-up.
- **New constants that duplicate existing ones.** Same magic number defined in two files.

## File and function size
- **No function exceeding ~50 lines introduced** without a comment on why it can't be split.
- **No file pushed past 500 lines** without justification.
- **Deeply nested logic (4+ levels)** should be flattened or extracted.

## Naming
- **Names describe what, not how.** `processData()` is a FAIL. `normalizeUserAddresses()` is a pass.
- **No abbreviations that require domain knowledge to decode.** `usr`, `cfg`, `tmp` in non-obvious contexts.

# Cross-reference prompt.md

Check whether any complexity in the diff stems from the spec itself being
ambiguous — if so, flag it as a Contractor concern, not an Implementer one.
The simplest code for an unclear spec is still unclear.

# Output

Append findings to `${output_dir}/test.md` under `### Simplification Review`:

```md
### Simplification Review

- [PASS] No dead code — all new functions have callers
- [FAIL] Single-caller abstraction — formatUserLabel() at utils/labels.ts:34 is only called from one place; inline it
- [FAIL] File size — api/users.ts is now 620 lines; consider splitting query logic into api/users.queries.ts
- [N/A] Duplication — no copy-paste detected
- ...
```

FAIL findings should be noted to the human with file:line and a concrete fix.
This skill does not block stage completion on its own — it informs the human,
who decides whether to address before merging.
