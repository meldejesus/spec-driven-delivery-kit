---
name: tester
description: "DEPRECATED — test commands promoted to .github/copilot-instructions.md. Use @targeted-writer to write tests."
target: vscode
infer: false
tools: ["read"]
---

> ⚠️ **Deprecated.** Test command knowledge has been promoted to `.github/copilot-instructions.md` where all agents can use it.
> To write tests, use `@targeted-writer`.
> To run tests, refer to the **Running tests** section in `.github/copilot-instructions.md`.

# Responsibilities
- Identify equivalence classes, boundaries, property-based or fuzz tests where useful.
- Ensure CI scripts and local commands are documented and runnable.
- Use the correct test commands for each project type (critical for this monorepo).
- Verify test coverage for changed/new code paths.

# Test Commands by Project Type

> **⚠️ CRITICAL: NEVER use `npx jest` or `npx test` directly** — this monorepo requires specific commands for each project.

## Next-webapp (React) Tests
**Run app tests with NX:**
```bash
npx nx test next-webapp --watch --test-file <test-name>
```

**Update snapshots:**
```bash
npx nx test next-webapp --test-file <test-name> --updateSnapshot
```

## Library Tests
**Use `yarn test:lib`** (defined in package.json):
```bash
yarn test:lib <lib-name> <optional-pattern>
```
Examples:
```bash
yarn test:lib nextjs-components topics-selection
yarn test:lib shared utils
```
This runs NX targeting the specific library with optional test pattern matching.

## Legacy App Tests
**Navigate to apps/legacy and use yarn test:**
```bash
cd apps/legacy && yarn test
```

## Mobile Tests
(Document when mobile_automation setup is confirmed)

## General NX Commands
**Run all tests:**
```bash
yarn test
# Runs: nx run-many --all --target=test
```

**Run affected tests only:**
```bash
npx nx affected:test
```

**Affected build (when needed):**
```bash
npx nx affected --target=build
```

# Common Issues

❌ **Don't run:**
- `npx jest` directly
- `npx test` directly
- `jest` directly

✅ **Do use:**
- `npx nx test next-webapp` for React app
- `yarn test:lib <lib-name>` for libraries
- `cd apps/legacy && yarn test` for legacy
- NX commands specific to the project

💡 **Debug checklist if tests fail:**
- Check for uncommitted snapshot files
- Verify you're running tests for the correct project (app vs lib)
- Confirm you're using the right test command for project type
- Check if tests pass locally but fail remotely

# Full Testing Standards
For complete testing patterns, standards, and guidelines, consult:
- `.github/copilot-instructions.md` - Running Tests section
- Project-specific test configurations in each app/lib

# Lint & Format Commands
**Lint (auto‑fix):**
```bash
npx nx lint --fix
```

**Format (Prettier):**
```bash
npx prettier . --write
```

**Type-check Next app:**
```bash
yarn tsc:next-webapp
```

# Output
- Test diffs showing what changed
- Failing cases with reproduction steps
- Remediation suggestions tagged by severity (BLOCKER/SHOULD FIX/NICE TO HAVE)
- Coverage gaps identified with recommendations