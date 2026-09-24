---
name: perf-gate
description: Lightweight performance checklist for changes that touch hot paths (DB, endpoints, loops over user data, cold-start-sensitive code). Invoked at implement time when plan.md declares `Perf-Gate: Y`. Not always-on — only fires when the plan says it should.
---

# When to run

The plan.md file for the active ticket declares:

```
Perf-Gate: Y — <reason>
```

If `Perf-Gate: N`, skip this skill entirely. If missing, ask the plan-writer to fill it in before implement continues.

# What to check

For each item, note the file:line and rate PASS / FAIL / N/A. Fail loud — a single FAIL blocks implement completion until addressed or explicitly waived by the human.

## Database
- **New WHERE / ORDER BY / JOIN columns have indexes.** Any query touching a large table without a supporting index is a FAIL.
- **No N+1 patterns.** Loops that issue one query per iteration. Batch or preload instead.
- **Migrations are online-safe.** No `ALTER TABLE` that rewrites a large table under load. No adding `NOT NULL` without a default. Additive-only, then cutover.
- **Transactions are scoped tight.** No network I/O inside a DB transaction.

## Endpoints / Request Path
- **No unbounded response payloads.** Paginate, cap, or stream.
- **No synchronous work that belongs in a background job.** Email, image processing, external API calls in the request path is a FAIL unless the SLA explicitly allows it.
- **No serial awaits where parallel would work.** `await a; await b;` when `Promise.all([a, b])` is safe.
- **Cache headers set** on responses that can be cached.

## Loops / Batch
- **No O(n²) over user data.** Nested loops over the same user-sized collection is a FAIL.
- **Bounded batch sizes.** Any batch iteration over "all records of type X" must have a max batch size and a resume token.
- **No sync file I/O in a loop.** Use streaming or batched reads.

## Cold Start / Bundle
- **New heavy deps justified.** Any new dep >100KB should have a note in plan.md explaining why. Tree-shake or lazy-load if possible.
- **No top-level async work** in module init.

# Output

Append to `${output_dir}/test.md` under `### Perf-Gate`:

```md
### Perf-Gate — <task or diff summary>

- [PASS] Indexes on new WHERE columns — models/orders.py:42 adds `user_id` index
- [FAIL] N+1 in listing endpoint — api/orders.py:118 loops calling `Order.customer` per row. Fix: `.select_related('customer')`.
- [N/A] Migrations — no schema changes
- ...
```

If any FAIL, do NOT announce Stage Complete. Fix or waive (with human note in handoff.md).

# Notes

- This skill is intentionally lean — 6 categories, ~20 checks. Not a substitute for load testing or profiling. It catches the classes of change that most often cause prod incidents.
- If the ticket needs deeper analysis (load test, flame graph, query plan review), the plan-review reviewer should have caught it and added a task. This skill is the last-mile check.
