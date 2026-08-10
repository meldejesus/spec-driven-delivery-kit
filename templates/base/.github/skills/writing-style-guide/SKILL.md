---
name: writing-style-guide
description: Shared writing style guide for clear internal notes, external messages, handoffs, explanations, and process docs. Use directly for writing guidance and as the base style for other writing-oriented skills.
---

# Writing Style Guide

Use this as the shared base style for internal notes, external messages,
handoffs, educational explanations, and process docs.

## Defaults

- Prefer plain language unless the audience is clearly technical.
- Match the audience's need: external partners need decisions and asks; engineers may need exact systems, paths, claims, and error codes.
- Put the main point first, then add only the context needed to act.
- Use the user's wording when it is close, but tighten it for clarity.

## Sentence Style

- Prefer sentences with a clear actor as the subject: `I`, `you`, `we`, `Osmosis`, `Vault`, `NeoID`, `the app`, or `the team`.
- Prefer action verbs over abstract nouns.
- Vary sentence length and structure so the writing sounds natural.
- Break long sentences into shorter ones when a sentence carries more than one idea.
- Avoid stacking many clauses with `which`, `that`, `because`, or `since`.

## Technical Detail

- Default to non-technical language for mixed or non-technical audiences.
- Use technical names only when the audience needs them to act or verify.
- Define technical terms before relying on them.
- Keep implementation details out of external messages unless they explain a decision, blocker, or ask.
- Do not repeat details the recipient already confirmed unless the detail prevents ambiguity.

## Message Shape

For external messages, prefer:

```text
<acknowledge or main point>

<short context, only if needed>

<clear ask or next step>
```

For ticket conversation records, timestamp composed outbound messages:

```text
Composed: YYYY-MM-DD HH:mm ET
```

## Editing Checklist

Before finalizing, check:

1. Is the actor clear?
2. Is the action clear?
3. Can any long sentence become two shorter sentences?
4. Can any technical term be removed, defined, or moved later?
5. Does the message avoid repeating what the recipient already knows?
