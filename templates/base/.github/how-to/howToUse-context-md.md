# CONTEXT.md — Project Orientation File

`CONTEXT.md` is a one-page project orientation document that agents read before starting any work session. It gives agents the stable facts about the project that aren't easily derivable from code alone: what the product does, where things live, key conventions, and non-obvious gotchas.

---

## Why it exists

Agents start every session without memory of prior conversations. Without `CONTEXT.md`, an agent has to rediscover the same orientation facts — tech stack, module structure, naming conventions — on every ticket. `CONTEXT.md` short-circuits that.

It is distinct from `CLAUDE.md`, which holds workflow commands and current work state. `CONTEXT.md` holds project-level facts that change infrequently.

---

## When to update it

Update `CONTEXT.md` when:
- The tech stack or architecture changes (new service, removed module, framework upgrade)
- A new non-obvious convention is established
- A "gotcha" gets discovered — something that would surprise a fresh agent

Do not update it for ticket-specific context. That belongs in `workflow/<ticket-id>/index.md`.

---

## What agents do with it

Agents in this kit read `CONTEXT.md` automatically via the `auto-read:` block in their frontmatter. It is read once at session start and does not need to be re-read mid-session.

If an agent asks about something that `CONTEXT.md` covers, that is a signal the file is incomplete — add it.

---

## Sections

| Section | What to put there |
|---|---|
| **What This Project Is** | Product description, users, tech stack. 2-3 sentences. |
| **Architecture** | Key layers, services, modules — not an exhaustive diagram, just the map an agent needs to navigate. |
| **Key Conventions** | Rules that apply across the codebase (test placement, flag requirements, schema annotations). |
| **Where Things Live** | File/directory map for the most commonly needed locations. |
| **Local Dev Setup** | Install + dev server + test commands — keep in sync with `CLAUDE.md`'s Commands section. |
| **Gotchas** | Non-obvious constraints. If an agent would make a wrong assumption without knowing this, put it here. |

---

## Template

A starter template is at `CONTEXT.md` in the workspace root. Fill in each section and delete the placeholder comments.
