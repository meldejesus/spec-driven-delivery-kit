# Message Workflow - Dense Docs To Clear Communication

Use this workflow when you have dense technical source material and need a clearer message for a specific audience.

---

## Steps Involved

### Conversation-Only — CLI

```text
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md,docs-in-progress/app/platform/docker/docker.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on what the user experiences, where confusion can happen, and what language marketing should avoid.
```

### Conversation-Only — VS Code Chat

```text
@Message-Writer
#read .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md,docs-in-progress/app/platform/docker/docker.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on what the user experiences, where confusion can happen, and what language marketing should avoid.
```

### File-Backed — CLI

```text
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=mixed
format=FAQ
context=docs-in-progress/app/apps/study-schedule.md
request=Create an FAQ that explains study schedule behavior for Support and Product.
output_mode=full
output_dir=workflow/messages/study-schedule-support-faq
```

### File-Backed — VS Code Chat

```text
@Message-Writer
#read .github/prompts/message-workflow.prompt.md

audience=mixed
format=FAQ
context=docs-in-progress/app/apps/study-schedule.md
request=Create an FAQ that explains study schedule behavior for Support and Product.
output_mode=full
output_dir=workflow/messages/study-schedule-support-faq
```

### Revision Request

```text
Keep the same structure, but make the tone more direct and reduce the implementation detail by half.
```

---

## Audience Options

This is not just "make it non-technical." The goal is to choose the right level of detail for the reader:

- **technical** - clearer technical explanation
- **mixed** - technical enough for accuracy, plain enough for cross-functional readers
- **non-technical** - outcomes, impact, and decisions first; internals only when needed

---

## When To Use It

Use this for:

- explaining a technical system to marketing, product, support, sales, leadership, or QA
- turning dense docs into an email, Slack message, FAQ, memo, one-pager, or talking points
- rewriting internal technical notes into a clearer technical explanation
- preparing stakeholder-facing explanations from engineering docs

Do not use it for:

- code implementation
- PR review
- legal or compliance approval
- replacing source-of-truth technical docs

---

## Default Mode: Conversation-Only

For fast work, keep the whole workflow in chat. The only durable output is the final message you approve.

**CLI:**

```text
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md,docs-in-progress/app/platform/docker/docker.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on what the user experiences, where confusion can happen, and what language marketing should avoid.
```

**VS Code Chat:**

```text
@Message-Writer
#read .github/prompts/message-workflow.prompt.md

audience=non-technical
format=one-pager
context=docs-in-progress/app/apps/purchasing/purchasing.md,docs-in-progress/app/platform/docker/docker.md
request=Explain how the purchasing flow works for a non-technical marketing team. Focus on what the user experiences, where confusion can happen, and what language marketing should avoid.
```

The workflow will pause at:

1. Approach
2. Outline
3. Draft and review
4. Final message and lessons learned

---

## File-Backed Mode

Use file-backed mode when the message is important, reusable, or likely to go through multiple revisions.

**CLI:**

```text
Act as Message-Writer following .github/agents/message-writer.agent.md and .github/prompts/message-workflow.prompt.md

audience=mixed
format=FAQ
context=docs-in-progress/app/apps/study-schedule.md
request=Create an FAQ that explains study schedule behavior for Support and Product.
output_mode=full
output_dir=workflow/messages/study-schedule-support-faq
```

**VS Code Chat:**

```text
@Message-Writer
#read .github/prompts/message-workflow.prompt.md

audience=mixed
format=FAQ
context=docs-in-progress/app/apps/study-schedule.md
request=Create an FAQ that explains study schedule behavior for Support and Product.
output_mode=full
output_dir=workflow/messages/study-schedule-support-faq
```

Files written in `output_mode=full`:

```text
workflow/messages/<name>/approach.md
workflow/messages/<name>/outline.md
workflow/messages/<name>/draft.md
workflow/messages/<name>/review.md
workflow/messages/<name>/final.md
workflow/messages/<name>/lessons-learned.md
```

Use `output_mode=final` if you only want:

```text
workflow/messages/<name>/final.md
workflow/messages/<name>/lessons-learned.md
```

---

## Extra Context

You can pass context files:

```text
context=docs/a.md,docs/b.md
```

You can also add instructions naturally:

```text
Also consider the notes in workflow/messages/prior-support-feedback.md.
Keep this under 500 words and avoid mentioning implementation class names.
```

If you have source material that is not in a file, paste it below the invocation.

---

## Stages

### 1. Approach

The agent states how it intends to translate the source material:

- audience assumptions
- message goal
- detail level
- tone
- vocabulary
- source boundaries
- open questions

Approve or revise this before outlining.

### 2. Outline

The agent proposes the structure and key points. This is where you fix order, scope, and emphasis before prose gets written.

Approve or revise this before drafting.

### 3. Draft

The agent writes the message in the approved format and audience level.

### 4. Review

The agent reviews its own draft for:

- accuracy
- audience fit
- structure
- tone
- sentence variation
- cognitive load
- actionability

Then it produces a revised final message.

### 5. Lessons Learned

The agent extracts reusable style lessons:

- what structure worked
- what jargon was replaced
- what tone fit the audience
- what sentence patterns should be reused or avoided
- what should be clarified earlier next time

Local lessons go in `workflow/messages/<name>/lessons-learned.md` when file-backed mode is used.

Broad reusable lessons can be proposed for `workflow/messages/style-lessons.md`, but should not be applied without approval.

---

## Choosing Output Mode

| Situation | Recommended mode |
|---|---|
| Quick Slack/email rewrite | `conversation` |
| Important stakeholder message | `final` |
| Multi-round reusable artifact | `full` |
| Training future writing style | `full` |

The workflow is intentionally lighter than the Jira-to-PR workflow. Most messages do not need a full artifact trail. Use files when the message is important enough to preserve the thinking.

---

## Revisions

During Approach or Outline, give direct correction:

```text
Make this less product-marketing focused and more support-team focused.
```

During Draft, ask for targeted revision:

```text
Keep the same structure, but make the tone more direct and reduce the implementation detail by half.
```

After Review, ask for final polish:

```text
Keep the content, but vary the sentence openings and make the call to action clearer.
```
