# Review Guardrails

These rules apply to every review in this workspace: stage review (`run review`),
peer review (`run peer-review`) and independent review (`run independent-review`).
They apply to any reviewer, including Codex, Claude Code, GitHub Copilot and
outside tools given a review prompt.

They prevent three common problems with agent reviews:

- **Invented work.** A reviewer asked to review tends to find something:
  nitpicks, style preferences or "consider adding X". Those findings turn into
  unnecessary changes.
- **Ping-pong.** Without a round limit, a reviewer and an implementer can keep
  undoing each other's preferences.
- **Uniform depth.** Reviewing a copy change as closely as a lock or an auth
  check wastes effort and dilutes attention on the risky parts.

## Findings

- Label every finding **BLOCKER**, **SHOULD FIX** or **NICE TO HAVE**.
- A BLOCKER must cite its evidence: an acceptance criterion or contract line it
  violates, or a concrete failing case (the inputs or event order, then the
  wrong result). Without that evidence, a finding is at most SHOULD FIX.
- Style, naming, refactoring preferences and features the contract doesn't
  require aren't findings. A team standard counts only when the finding cites it.
- There is no finding quota. Zero findings is a valid result.
- Mark anything not confirmed from the code or artifact as **unverified**.
- For each area reviewed closely, say in one line that it was checked, even when
  nothing was found.

## Depth follows risk

Review these closely:

- concurrency, locks and duplicate work
- authentication, authorization and data exposure
- data migrations, deletion and cleanup
- public interfaces and stored data formats
- resource limits: memory, CPU, connections, timeouts

Give everything else a light pass and report only clear defects: UI copy,
configuration, test style and docs.

The review prompt or request names which areas get which depth. When it doesn't,
the reviewer uses the lists above.

## Rounds

- A checkpoint gets at most **two rounds**.
- Round 1 is the review.
- Round 2 checks only the fixes for findings accepted in round 1. It is not a
  new review.
- Anything still disputed after round 2 goes to the user.

## Who decides

- Reviewers report findings. The user decides, with an advisor agent if one is
  helping. Reviewers never instruct the implementer directly.
- Before anything goes to the implementer, someone checks each finding against
  the code or artifact.
- Only accepted BLOCKER and SHOULD FIX findings go to the implementer.
  NICE TO HAVE findings go to the user as a list.

## Implementer

- Fix only the accepted findings, and keep each fix as small as possible.
- Don't undo an earlier accepted fix to satisfy a new finding. Flag the
  conflict to the user instead.
