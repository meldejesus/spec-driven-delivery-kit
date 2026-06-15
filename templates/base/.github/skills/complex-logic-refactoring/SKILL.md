
# Skill: Complex Logic Refactoring
**Goal:** Extract business logic from UI components into pure, testable TypeScript services.

## Procedure
1. **Dependency Analysis:** Identify all state hooks and external API calls in the target file.
2. **Contract First:** Create a `types.ts` for the new service before moving any code.
3. **Pure Function Extraction:** Move logic into the service; ensure no React-specific hooks exist in the service.
4. **Adapter Creation:** Use the `useService` pattern to reconnect the UI to the new logic.

## Safety Rules
- Never delete the old logic until the new service has 100% test coverage in `test.md`.
- If a refactor breaks a parent component, use the **Backtrack Protocol** immediately.

## Tooling
- Use `npm run test:unit` after every function extraction.
