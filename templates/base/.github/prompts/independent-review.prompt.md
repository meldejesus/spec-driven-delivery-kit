---
name: independent-review
description: Second-opinion review of any workflow artifact or checkpoint (contract, plan, task-batch diff, doc). Findings only, under the review guardrails; no verdict or PR description.
agent: Reviewer
tools: [read, search]
infer: false
target: vscode
---

# Purpose

Give an independent second opinion at a checkpoint, while problems are still
cheap to fix. This is not Gate D: `run review` remains the final stage review,
and `run peer-review` covers a teammate's PR.

An independent review works best from a different model or tool than the one
that wrote the artifact. This prompt stands on its own so it can be pasted into
an outside tool. When you paste it, also paste
`.github/policies/REVIEW-GUARDRAILS.md` or keep the rules below.

# Inputs

- ticket: ${input:Ticket ID (e.g., PROJECT-123)}
- artifact: ${input:contract | plan | diff | doc}
- target: ${input:Path(s) to review, or base..head commits for a diff}
- requirements: ${input:Path to the approved contract or source requirements}
- deep: ${input:Areas to review closely (optional; defaults to the guardrails' risk list)}
- light: ${input:Areas for a light pass (optional)}
- accepted: ${input:Accepted limitations not to re-raise (optional)}
- round: ${input:1 or 2 (default 1)}
- fixes: ${input:Round 2 only: the accepted findings and the commits or edits that fix them}

# Rules

Read-only. Make no edits, commits, stashes, installs, builds or network calls.
Run tests only if the request explicitly allows it and names a time limit.

Follow `.github/policies/REVIEW-GUARDRAILS.md`. In short:

- Label every finding **BLOCKER**, **SHOULD FIX** or **NICE TO HAVE**.
- A BLOCKER must cite an acceptance criterion or requirement line it violates,
  or a concrete failing case (the inputs or event order, then the wrong result).
  Without that evidence, it is at most SHOULD FIX.
- Style, naming, refactoring preferences and features the requirements don't
  ask for aren't findings.
- There is no finding quota. Zero findings is a valid result.
- Mark anything not confirmed from the artifact as **unverified**.
- Don't re-raise accepted limitations unless the artifact makes them worse.

# What to check, by artifact

- **contract:** the scope matches the ticket; the acceptance criteria are
  testable; constraints and safeguards cover the real risks; open decisions are
  named; required outcomes are kept separate from optional implementation
  choices.
- **plan:** every acceptance criterion maps to a task and a test; task order and
  dependencies hold; test cost and runtime limits are stated; no task reaches
  outside the contract.
- **diff:** the code meets the requirements' acceptance criteria and constraints;
  failure and cleanup paths are correct; tests prove what they claim rather than
  mocking it away.
- **doc:** claims match the code; commands work as written; nothing is stale or
  misleading for a reader new to the system.

Spend most of the effort on the `deep` areas, or on the guardrails' risk list
when none are given. Give `light` areas a pass for clear defects only.

# Round 2

Check only the listed fixes. Confirm that each one resolves its finding without
breaking nearby behavior. Don't start a new review. Report anything still
disputed for the user to decide.

# Output

1. **Findings**, most severe first. For each, give:
   - the label
   - the location (`file:line`, or section and line for documents)
   - the evidence (the requirement line or the failing case)
   - the smallest fix
2. **Coverage:** one line per deep area, either "checked, no issues" or "see
   finding N".
3. **Unverified:** anything you couldn't confirm, and what would confirm it.

No verdict and no PR description. The user decides what to accept.
