---
name: message-clarity
description: Turn dense technical notes, spike findings, ticket summaries, or implementation details into clearer prose for technical, mixed, or non-technical audiences. Use when Codex should rewrite, summarize, or reshape a message in conversation without creating a separate workflow lane.
---

# Message Clarity

Use this skill for conversation-first message rewriting. Prefer chat output.
If the user asks for a durable artifact, put it with the related ticket, spike,
or refinement note instead of creating a separate message lane.

## Process

1. Identify the audience and what they need to do with the information.
2. Preserve technical truth, but choose the lowest useful level of implementation detail.
3. Replace internal implementation names with user-facing concepts unless the audience needs the implementation term.
4. Use an outline gate before drafting when the source material is long or ambiguous.
5. Keep final prose direct, skimmable, and grounded in the provided source.

## Output

- For quick rewrites, respond in chat only.
- For source material with unclear intent, first state the assumed audience and ask for correction.
- If the user asks for a durable artifact and the target path is unclear, ask whether it belongs with a ticket, spike, or refinement note.
