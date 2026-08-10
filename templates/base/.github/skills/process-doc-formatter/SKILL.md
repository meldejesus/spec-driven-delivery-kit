---
name: process-doc-formatter
description: Format rough technical notes into concise Input, Process, Output sections while preserving the author's current scope, examples, and learning sequence. Use when Codex should clean up process notes, study notes, spike notes, or draft docs without adding unrelated stages or turning them into a broader explainer.
---

# Process Doc Formatter

Use this skill to reshape rough technical notes into short process-stage docs.
Preserve the author's intended scope first; clarity comes from structure, not from
adding every adjacent detail.

Follow the shared base style in `../writing-style-guide/SKILL.md`.

## Core Rules

- Keep the current stage boundary. Do not add later process steps unless the user asks.
- Preserve the user's examples, terms, and learning sequence where they are useful.
- Correct inaccurate terms or claims, but keep corrections scoped to the current section.
- When explaining a next step reveals a missing term or relationship, revise the earlier step where that term first belongs instead of adding redundant explanation later.
- Distinguish user-facing terms from code terms when they differ.
- Distinguish actual code outputs from conceptual outputs used only to explain control flow.
- When similar checks appear, name the level each check applies to, such as route-level, item-level, page-level, or aggregate-level.
- Do not imply a fixed count unless the code enforces that count. Say what the count depends on.
- Prefer short bullets, small tables, and direct labels over long prose.
- Do not invent new examples unless needed to correct a claim or the user asks for one.
- If a structural decision would change scope, ask before expanding.

## Workflow

1. Read the target doc and any referenced source artifact.
2. Identify the process stage currently being described.
3. Normalize that stage around:
   - `Input:`
   - `Process:`
   - `Output:`
4. Add a brief explanation of the process or output only where it helps.
5. Scan the immediately previous stage for terms, counts, or checks that now need to be clarified or de-duplicated.
6. Correct terminology in place.
7. Say whether the output is stored, returned, or just a conceptual subset used to explain the step.
8. Leave future stages as placeholders only when the user explicitly wants a scaffold.
9. Report the main corrections and any unresolved ambiguity.

## Output Shape

For a single process stage, prefer:

```markdown
## <Stage Name>

Input: <what enters this stage>  
Process: <what happens to it>  
Output: <what comes out>

<short explanation>
```
