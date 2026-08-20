# Workflow Index

All active and recent workflow artifacts. Updated by the `workflow-index` skill.

**In Obsidian** (with the [Dataview plugin](https://github.com/blacksmithgu/obsidian-dataview)): the queries below run live and stay current automatically. No manual updates needed.

**Without Obsidian:** run `use the workflow-index skill` to regenerate the static table below.

---

## All Tickets

```dataview
TABLE title, status, tags, created
FROM ""
WHERE ticket != null AND (type = "standard-ticket" OR type = "change-request")
SORT created DESC
```

---

## Active (in-progress)

```dataview
TABLE title, tags, created
FROM ""
WHERE ticket != null AND status != "closed"
SORT created DESC
```

---

## Spikes

```dataview
TABLE title, status, created
FROM ""
WHERE type = "spike"
SORT created DESC
```

---

## Static Index

*This table is the fallback for non-Obsidian environments. Regenerate with `use the workflow-index skill`.*

| Ticket | Title | Type | Status | Tags | Created |
|---|---|---|---|---|---|
| — | — | — | — | — | — |
