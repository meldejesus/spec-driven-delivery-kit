---
name: performance-review
description: Focused performance pass on the current diff. Covers Core Web Vitals impact, bundle size, hot-path analysis, and query efficiency. Invoked optionally after run review when the diff touches rendering, data fetching, or high-traffic paths.
---

# When to run

After `run review` when the diff touches any of: data fetching, rendering,
bundle composition, database queries, loops over collections, or endpoints
on high-traffic paths.

The reviewer agent will suggest this skill if the diff warrants it. It can also
be invoked directly: `use the performance-review skill`.

Distinct from the `perf-gate` skill — perf-gate runs during implement to catch
regressions task-by-task. This skill is a post-implement diff-level review,
looking at the full change holistically.

# What to check

For each item, note file:line and rate PASS / FAIL / N/A.

## Rendering and Core Web Vitals
- **No new layout shifts introduced.** Images and embeds have explicit dimensions. Dynamic content has reserved space.
- **No render-blocking additions.** New scripts or styles loaded synchronously in `<head>` without `async`/`defer` are a FAIL.
- **Large components are lazy-loaded** if not needed on first paint.
- **No unnecessary re-renders.** New state or prop changes that trigger wide re-renders without memoization on hot components.

## Bundle size
- **New dependencies are justified by size.** Any new dep >50KB (minified+gzip) should have a note. Check with `npm run analyze` or equivalent if available.
- **No full library imported when a subset suffices.** `import _ from 'lodash'` instead of `import debounce from 'lodash/debounce'` is a FAIL.
- **Dynamic imports used for routes and heavy features** that are not on the critical path.

## Data fetching
- **No waterfall fetches where parallel would work.** Sequential awaits for independent data sources is a FAIL.
- **No over-fetching.** Queries or API calls should request only the fields the component uses.
- **Pagination or limits on list queries.** Unbounded `SELECT *` or `findAll()` on user-sized collections is a FAIL.
- **No N+1 patterns.** Loops that issue one query per iteration. Batch or preload.

## Caching
- **Static or rarely-changing responses have cache headers.** No `Cache-Control` on a response that could be cached is worth flagging.
- **New expensive computations are memoized** if called repeatedly in the same request or render cycle.

# Cross-reference test.md

Check `${output_dir}/test.md` for any perf-gate entries logged during implement.
This skill should build on those findings, not duplicate them. Note where the
full-diff view reveals patterns that individual task checks missed.

# Output

Append findings to `${output_dir}/test.md` under `### Performance Review`:

```md
### Performance Review

- [PASS] Bundle — no new deps above 50KB threshold
- [FAIL] Waterfall fetch — dashboard.tsx:42 awaits userProfile then awaits permissions sequentially; can be parallelized
- [N/A] Core Web Vitals — no rendering changes in this diff
- ...
```

FAIL findings should be noted to the human with file:line and a concrete fix.
This skill does not block stage completion on its own — it informs the human,
who decides whether to address before merging.
