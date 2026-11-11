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

- Use direct wording in all prose, whether it appears in a paragraph, bullet, table, or heading. The goal is a clear statement, not a particular format.
- Lead with the fact, action, or decision the reader needs. Cut setup that merely announces what the sentence is about to say.
- Prefer sentences with a clear actor as the subject: `I`, `you`, `we`, `Osmosis`, `Vault`, `NeoID`, `the app`, or `the team`.
- Prefer action verbs over abstract nouns.
- Replace indirect phrases with the action itself: “The team reviews model output” instead of “The team is responsible for carrying out a review of model output.”
- Use concrete statements instead of compressed labels. Replace “benchmark-path readiness” with what the team must build or test and when it must finish.
- Avoid abstract process nouns ending in `-tion` when a verb can state the work directly. Rewrite `implementation` as who implements what, and `integration` as what connects to what. Do not just swap a noun for a verb and leave the action vague.
- Name the actor, the action, and what the action affects. If no clear subject or object can be found, ask whether the phrase adds a necessary fact; cut it if it does not.
- For example, replace “The integration task validates that implementation in the real data flow” with “The team tests that uploaded files pass the required checks before the app saves the learner's chosen topics.”
- Keep exact code identifiers, ticket titles, quotations, and established technical terms such as `prompt injection` when readers need them. Apply the rule to the surrounding prose without changing the meaning or strength of a claim.
- Vary sentence length and structure so the writing sounds natural.
- Break long sentences into shorter ones when a sentence carries more than one idea.
- Avoid stacking many clauses with `which`, `that`, `because`, or `since`.

For example, replace:

> Vault provides a malware scan gate, while additional application protections are the responsibility of the consuming uploader/model integration.

With:

> Vault scans uploaded files for malware. We must check documents for semantic threats before sending them to models.

The improvement comes from stating who does what and removing abstract setup. It works as a paragraph or as separate bullets. Keep any caveat needed to preserve the meaning or strength of the original claim.

## Technical Detail

- Default to non-technical language for mixed or non-technical audiences.
- Use technical names only when the audience needs them to act or verify.
- Define technical terms before relying on them.
- Keep implementation details out of external messages unless they explain a decision, blocker, or ask.
- Do not repeat details the recipient already confirmed unless the detail prevents ambiguity.

## Message Shape

Choose paragraphs, bullets, or tables to suit the content. Formatting should support direct language, not substitute for it.

- Distinguish what we know, what we tested, and what we will do next. A proposed check must not read as a passed test.
- Keep each caveat beside the claim it qualifies. Split passages that mix unrelated facts, caveats, and next steps.
- Keep source-by-source notes, tool steps, and duplicate checks in the evidence log. Include them in the reader-facing summary only when they change how the reader should interpret a finding or act.
- Do not reopen an answered question or repeat a caveat unless it affects a decision still to be made. Keep qualifications that prevent an unsupported claim.

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
6. Can a `-tion` process noun become a verb with a clear actor and object, or can the phrase be cut?
7. Can the reader quickly tell what we confirmed, what we tested, and what happens next?
8. Does each sentence state the point directly, or does abstract setup delay it?
