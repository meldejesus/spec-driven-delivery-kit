# MCP Setup Notes

MCP lets agents fetch external context without you pasting everything into chat.

In this workflow, MCP is mainly used for:

- Jira tickets and acceptance criteria
- GitHub PRs, diffs, commits, and checks
- Confluence or other team docs when available

MCP is not the workflow itself. It is the context bridge that feeds the Contract, Plan, Review, and Sonar stages.

## Config Files

Different tools read different MCP files:

| File | Typical reader | Notes |
|---|---|---|
| `.github/copilot/mcp.json` | VS Code GitHub Copilot Chat | Commit this for shared editor MCP defaults. |
| `.copilot/mcp-config.json` | GitHub Copilot cloud/coding agent | Used for autonomous PR and issue work. |
| `.vscode/mcp.json` | Local VS Code workspace | Use for local-only overrides. Do not rely on this for teammates. |

Do not keep legacy copied MCP files in archive or scratch folders unless a
current tool reads them. To run Playwright MCP, configure it in the MCP client
you actually launch; the old `vscode-sanitized/mcp.json` copy is not required.

When this workflow comes from the standalone kit, install `.github/` and
`.copilot/` into the active workspace. A sibling kit repository is not enough for
tool discovery.

## Common Servers

| Server | Used for |
|---|---|
| Atlassian | Jira tickets, Jira comments, Confluence pages |
| GitHub | PRs, diffs, commit history, CI status |
| GitKraken or git tooling | Local branch and history inspection, when configured |

## Where It Fits

| Stage | MCP value |
|---|---|
| Contract | Fetch Jira ticket, ACs, comments, related links |
| Plan | Confirm code references, related tickets, prior work |
| Review | Fetch PR diff, status, linked ticket context |
| Sonar | Pair PR number and quality-gate data with review output |

## Minimal Setup Check

1. Open the AI tool settings for MCP or agent integrations.
2. Confirm the Atlassian and GitHub servers are registered.
3. Confirm auth is active for Jira and GitHub.
4. Run a small test request, such as fetching one Jira ticket or one PR.
5. If the request fails, use `pre-context.md` as the fallback.

## Fallback Pattern

If MCP cannot fetch a ticket, create:

```text
workflow/tickets/PROJECT-123/pre-context.md
```

Paste:

- ticket title
- description
- acceptance criteria
- relevant comments
- links to related PRs or docs
- known implementation constraints

The workflow prompts are written so agents should read `pre-context.md` before making ticket assumptions.

## Security Notes

- Do not paste secrets, tokens, cookies, or private credentials into task files.
- Prefer links or summaries over raw confidential payloads.
- Keep MCP permissions scoped to the systems needed for the workflow.
- If a server is unavailable, fall back to human-provided context rather than weakening permissions.

## Why This Is Separate From The CLI Guide

"Fold into CLI setup" means moving this content into `.github/how-to/howToUse-cli.md` if it becomes only a short setup paragraph.

It is separate for now because MCP applies to both VS Code Chat and CLI-style workflow runs, and because the setup may change independently of the ticket workflow steps.
