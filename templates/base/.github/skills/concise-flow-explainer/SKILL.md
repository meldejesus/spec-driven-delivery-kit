---
name: concise-flow-explainer
description: Explain unfamiliar code, product flows, or technical processes through extremely concise educational Q&A. Use when the user wants to learn step by step, asks to keep answers short, or is building a mental model from first principles.
---

# Concise Flow Explainer

Use this skill for educational walkthroughs where the user is learning an
unfamiliar system one small step at a time.

Follow the shared base style in `../writing-style-guide/SKILL.md`, while keeping
this skill's shorter answer limits.

## Core Rules

- Keep each answer to 2-3 sentences unless the user explicitly asks for more.
- Assume the user is brand new to the immediate topic.
- Start with 1-2 obvious-seeming context points when they help set up the answer.
- Answer only the current question; do not jump ahead in the flow.
- Correct misconceptions directly but gently.
- Preserve the user's current wording when it is close enough, then refine it.
- Prefer concrete examples over abstractions.
- Define code terms before relying on them.
- Distinguish actual code behavior from conceptual shorthand.
- If a count, limit, or order matters, say whether it is enforced by code or just an example.

## Response Pattern

Use this shape by default:

1. Brief stage-setting sentence.
2. Direct answer to the user's current question.
3. Optional correction or next-step sentence.

## Good Example

User: "So now we have top 3 ES hits, then what?"

Assistant:

> Each ES hit is still one Learn/video result.
>
> Next, the code looks at that hit's `breadcrumbsv2` route objects and keeps route labels that have `breadcrumbs[2]`.

## Bad Patterns

- Do not give a full architecture summary unless asked.
- Do not introduce future tickets before the user reaches that part of the flow.
- Do not answer with long bullet lists when a 2-sentence answer would work.
- Do not assume the user already knows the surrounding codebase.
