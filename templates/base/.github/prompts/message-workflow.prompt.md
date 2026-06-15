---
name: message-workflow
description: Turn dense technical source material into a clearer message for a technical, mixed, or non-technical audience. Runs approach, outline, draft, review, and lessons.
agent: Message-Writer
tools: [read, write, edit, search]
---

# Message Workflow Invocation

## Inputs
- audience: ${input:audience}       # required: technical, mixed, or non-technical
- request: ${input:request}         # required: what the message must explain or accomplish
- context: ${input:context}         # required unless source material is pasted inline; file path(s), comma-separated
- format: ${input:format}           # optional: email, Slack, one-pager, FAQ, talking points, memo, release note, etc.
- output_mode: ${input:output_mode} # optional: conversation (default), final, or full
- output_dir: ${input:output_dir}   # optional: messages/<name>; required for output_mode=final/full
- constraints: ${input:constraints} # optional: length, tone, must-include, must-avoid, deadline, approval context

## Output Modes

| Mode | Behavior |
|---|---|
| `conversation` | Default. Keep the workflow in chat. No files are required. |
| `final` | Write only `final.md` and `lessons-learned.md` under `output_dir`. |
| `full` | Write `approach.md`, `outline.md`, `draft.md`, `review.md`, `final.md`, and `lessons-learned.md` under `output_dir`. |

If `output_mode` is omitted, use `conversation`.

If `output_mode` is `final` or `full` and `output_dir` is omitted, ask for `output_dir` before writing files. Do not invent a directory silently.

## 0. Resolve Inputs

Before starting:

1. Confirm `audience` is one of `technical`, `mixed`, or `non-technical`. If not, ask the user to choose.
2. Confirm `request` is clear enough to define the message goal. If not, ask one concise clarifying question.
3. Read every file listed in `context`.
4. Treat pasted source material or extra inline instructions as context too.
5. If a referenced file cannot be read, tell the user and continue only if enough source material remains.
6. If `output_dir` was provided, confirm it starts with `messages/`. If it does not, ask for a `messages/<name>` directory before writing files.
7. If `output_dir` was provided, write only under `messages/**`.

If `output_dir` is provided, create or update:

```text
messages/.active-message.md
```

Use this format:

```md
# Active Message
audience: <technical|mixed|non-technical>
request: <short request summary>
format: <format or unspecified>
output_dir: <output_dir>
last_completed_stage: none
next_stage: approach
updated_by: message-workflow
```

## Stage 1 - Approach

Produce a concise **Communication Approach** with:

1. **Audience read:** what this audience likely knows, does not know, and cares about.
2. **Message goal:** what the reader should understand, decide, or do after reading.
3. **Abstraction level:** what technical detail to keep, compress, or cut.
4. **Tone:** how the message should sound.
5. **Vocabulary plan:** terms to use, define, avoid, or replace.
6. **Source boundaries:** what source claims are safe, uncertain, or out of scope.
7. **Assumptions / questions:** anything that could change the direction.

If `output_mode=full`, write this to:

```text
${output_dir}/approach.md
```

Stop and ask:

```text
Approve this approach, or tell me what to change before I outline.
```

Do not outline until the user approves the approach.

If the user revises the approach, update the Communication Approach and ask for approval again. Continue this loop until the user approves.

## Stage 2 - Outline

After approach approval, produce an **Outline** with:

1. Working title or message subject
2. Section order
3. Key point for each section
4. Source notes for each section
5. Details intentionally excluded
6. Reader takeaway or call to action

For each section, mark whether it is:

- **Must-have**
- **Optional**
- **Cut if too long**

If `output_mode=full`, write this to:

```text
${output_dir}/outline.md
```

Stop and ask:

```text
Approve this outline, or tell me what to change before I draft.
```

Do not draft until the user approves the outline.

If the user revises the outline, update the Outline and ask for approval again. Continue this loop until the user approves.

## Stage 3 - Draft

After outline approval, write the message.

Draft rules:

- Preserve source accuracy.
- Use the approved audience level and tone.
- Keep the message easy to scan.
- Prefer concrete examples over abstract explanation.
- Keep caveats visible but not distracting.
- Do not mention internal source documents unless the user asked for citations or references.
- If a fact is uncertain, label it as an assumption or open question.

If `output_mode=full`, write the first draft to:

```text
${output_dir}/draft.md
```

## Stage 4 - Review And Revision

Review the draft before finalizing. Produce a short review with:

1. **Accuracy risks**
2. **Audience-fit issues**
3. **Structure improvements**
4. **Tone and sentence variation improvements**
5. **Recommended revision summary**

Then produce a revised final message.

If `output_mode=full`, write the review to:

```text
${output_dir}/review.md
```

If `output_mode=final` or `output_mode=full`, write the revised final message to:

```text
${output_dir}/final.md
```

## Stage 5 - Lessons Learned

After the final message, produce local lessons learned.

Focus on reusable writing and communication lessons:

- Organization patterns that worked
- Tone choices that fit the audience
- Sentence patterns to reuse or avoid
- Jargon replacements
- Ways to explain dense concepts faster
- Useful outline patterns
- Things that should be asked earlier next time

If `output_mode=final` or `output_mode=full`, write these to:

```text
${output_dir}/lessons-learned.md
```

If a lesson is broadly reusable across many messages, propose it as a candidate for:

```text
messages/style-lessons.md
```

Do not edit `messages/style-lessons.md` unless the user explicitly approves.

If `output_dir` was provided, update `messages/.active-message.md`:

```md
# Active Message
audience: <technical|mixed|non-technical>
request: <short request summary>
format: <format or unspecified>
output_dir: <output_dir>
last_completed_stage: lessons
next_stage: done
updated_by: message-workflow
```

## Final Response

Return:

1. The final message
2. A short "Review notes" section with any remaining assumptions or risks
3. A short "Lessons learned" section
4. File paths written, if any

Then STOP.
