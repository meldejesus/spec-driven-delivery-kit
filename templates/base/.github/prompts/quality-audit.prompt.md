---
name: quality-audit
description: On-demand audit of a file, route, or component for performance, accessibility, and SEO issues. Not tied to a diff — use at any time.
tools: [read, search, terminal]
---

> **⚠️ TODO:** This prompt needs a significant expansion pass. Current checks are too basic and would rarely fire in a real review. Needs: richer SEO (structured data, canonical, OG tags), deeper perf patterns (bundle size, lazy loading, image optimization, memoization), more nuanced a11y (live regions, focus management, skip links, color contrast), and Next.js-specific checks (hydration, server vs. client components, Suspense). See standup todos.

# Quality Audit

## Inputs
- target: ${input:File, folder, or route to audit (e.g., apps/next-webapp/src/pages/learn/[id].tsx)}

## What to Audit

Read the target file(s), then check each category below. For every issue found, provide:
- **Severity:** `BLOCKER` | `SHOULD FIX` | `NICE TO HAVE`
- **What & Where:** description + file:line
- **Why it matters**
- **Fix Guidance:** minimal concrete change

---

### ⚡ Performance
**Never do (flag if present):**
- Sequential `await` calls that could be `Promise.all`
- Unbounded DB/API queries (no `LIMIT`) on a read path
- Large blob columns fetched when only a scalar field is needed
- Same DB/API query called more than once in the same request
- Full library imports when only one function is used
- `useEffect` data fetching that could be server-side in Next.js
- `console.log` on production code paths
- Synchronous heavy computation on the main thread

**Opportunities (flag if applicable):**
- Could sequential awaits be parallelized?
- Could a `LIMIT 1` query replace a full fetch + JS reduce?
- Could a server component replace a client component?
- Is cacheable data actually being cached?

---

### ♿ Accessibility
**Never do (flag if present):**
- `<div onClick>` instead of `<button>` or `<a>`
- `<img>` missing `alt` attribute
- `outline: none` without a visible focus replacement
- Color as the only means of conveying meaning
- `tabIndex > 0`
- Placeholder text used as a label substitute
- Modal or dialog opened without focus trapping

**Opportunities (flag if applicable):**
- Does new interactive UI support full keyboard navigation?
- Do icon-only buttons have `aria-label`?
- Are error messages linked to inputs via `aria-describedby`?
- Does dynamically updated content use `aria-live`?

---

### 🔍 SEO (public-facing pages only)
**Never do (flag if present):**
- Empty or missing `<title>` or `<meta name="description">`
- More than one `<h1>` per page
- Skipped heading levels (h1 → h3 with no h2)
- Accidental `noindex` on public content
- Meaningful content only in client-rendered markup

**Opportunities (flag if applicable):**
- Is the page title unique and descriptive?
- Are headings in logical order?
- Do links have descriptive text?

---

## Output Format

### Summary
1–3 sentences on overall quality signal.

### Findings
Grouped by: Performance | Accessibility | SEO
Each finding: severity, location, why it matters, fix guidance.

### Quick Wins
List of NICE TO HAVE improvements that are low-effort and high-value.
