# Working Without a Ticket Tracker

Use this guide when you have feature work or bug reports but no Jira, Linear, or GitHub Issues to fetch from.

---

## Setup

Create a `pre-context.md` file in the ticket directory before running the contract:

```bash
mkdir -p workflow/FEATURE-NAME
```

Create `workflow/FEATURE-NAME/pre-context.md`:

```markdown
# <Feature or bug title>

## Description
<What is this? What problem does it solve?>

## Acceptance Criteria
- <AC 1>
- <AC 2>
- <AC 3>

## Constraints
<Technical constraints, performance requirements, things to avoid>

## Related Links
<Design files, Slack threads, prior PRs, docs>
```

Then run:

```
run contract ticket=FEATURE-NAME
```

The contract stage reads `pre-context.md` automatically and uses it as the ticket source. MCP is not needed. Everything else in the workflow is identical to the standard path.

---

## What the contract stage does with pre-context.md

- Reads the file before attempting any MCP calls
- Uses the title, description, ACs, and constraints as the ticket source
- Sets `source: pre-context` in `index.md` frontmatter
- Writes `prompt.md` and `reproduce.md` as normal

---

## Naming convention

Use a descriptive slug:

```
workflow/fix-login-modal-close/
workflow/add-csv-export/
workflow/upgrade-react-19/
```

---

## Switching to a tracker later

If a real ticket is filed later, update `index.md` frontmatter:
- Set `ticket:` to the real ticket ID
- Set `jira_url:` or `tracker_url:` to the real URL
- Set `source: Jira` (or Linear, GitHub)

The workflow artifacts stay intact.
