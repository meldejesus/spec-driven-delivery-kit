---
name: security-review
description: Focused security pass on the current diff. Covers OWASP top 10, auth, secrets, input validation, and dependency safety. Invoked optionally after run review when the diff touches security-sensitive surfaces.
---

# When to run

After `run review` when the diff touches any of: auth, user input, external APIs,
file uploads, permissions, tokens, secrets, or new dependencies.

The reviewer agent will suggest this skill if the diff warrants it. It can also
be invoked directly: `use the security-review skill`.

# What to check

For each item, note file:line and rate PASS / FAIL / N/A.

## Input validation
- **All user input validated at the boundary.** No raw request params passed to queries, commands, or file paths.
- **No SQL/NoSQL injection surface.** Parameterized queries only. ORM raw() calls are a FAIL unless justified.
- **No XSS surface.** User content rendered to HTML is escaped. `dangerouslySetInnerHTML` without sanitization is a FAIL.
- **No path traversal.** File path construction from user input must be canonicalized and bounded.

## Authentication and authorization
- **Every new endpoint has an auth check.** Unauthenticated access is intentional and noted in prompt.md, or it is a FAIL.
- **Authorization is checked at the data layer, not just the route.** Verify the user owns the resource being accessed.
- **No insecure direct object references.** IDs in URLs must be validated against the current user's scope.

## Secrets and credentials
- **No secrets in code or committed files.** API keys, tokens, passwords, connection strings must come from env vars or a secrets manager.
- **No secrets in logs.** Logging functions must not include auth headers, tokens, or PII.
- **New env vars documented.** Any new `process.env.X` reference has a corresponding entry in `.env.example` or equivalent.

## External requests (SSRF / dependencies)
- **Outbound URLs are allowlisted or validated.** User-controlled URLs used in server-side fetch are a FAIL unless bounded.
- **New npm/pip/etc. dependencies checked.** Any new package should be actively maintained and not known-vulnerable. Flag packages with <1K weekly downloads or last published >2 years ago.
- **No new transitive dep pulling in a known-CVE package** (check with `npm audit` or equivalent if available).

## Data handling
- **PII is not stored beyond its stated purpose.** New fields storing user data should match what prompt.md scoped.
- **Sensitive response fields are not over-exposed.** API responses should not return fields the caller doesn't need (password hashes, internal IDs, etc.).

# Cross-reference prompt.md

Check the `## Constraints` section of `${output_dir}/prompt.md` for any
security requirements stated in the contract. Each one must show evidence in
`${output_dir}/test.md` or this skill produces a FAIL.

# Output

Append findings to `${output_dir}/test.md` under `### Security Review`:

```md
### Security Review

- [PASS] Input validation — all new params go through zod schema at api/users.ts:14
- [FAIL] Missing auth check — GET /api/admin/export has no session guard (api/admin.ts:88)
- [N/A] Secrets — no new env vars introduced
- ...
```

FAIL findings should also be noted to the human with file:line and a concrete fix.
This skill does not block stage completion on its own — it informs the human, who
decides whether to address before merging.
