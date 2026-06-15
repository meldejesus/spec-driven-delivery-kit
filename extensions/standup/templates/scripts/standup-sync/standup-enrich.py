#!/usr/bin/env python3
"""
standup-enrich.py — enriches standup dashboard and daily log:
  - Merges adjacent same-day checkout + commit pairs for the same branch into one line
  - Annotates ticket IDs with tracker summaries (if --labels provided)
  - Outputs a list of ticket IDs that need label lookup (for agent enrichment)
  - Moves [x]-checked items from active Jira dashboard sections to Done (--move-done)
  - Prunes Done items older than 30 days that carry a (done: YYYY-MM-DD) tag
  - Promotes tickets from latest daily log to In Progress if not already tracked (--promote-in-progress)

Usage:
  # Check which tickets need labels (outputs JSON list)
  python3 scripts/standup-sync/standup-enrich.py --scan

  # Apply enrichment with labels from a JSON file
  python3 scripts/standup-sync/standup-enrich.py --labels labels.json [--dry-run]

  # Move checked [x] items to Done and prune old entries
  python3 scripts/standup-sync/standup-enrich.py --move-done [--dry-run]

  # Promote untracked tickets from latest daily log to In Progress
  python3 scripts/standup-sync/standup-enrich.py --promote-in-progress [--labels labels.json] [--dry-run]
"""

import re
import sys
import json
import os
from datetime import datetime, timedelta
from typing import Optional

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
DASHBOARD_PATH = os.path.join(ROOT, "standup", "dashboard.md")
DAILY_LOG_PATH = os.path.join(ROOT, "standup", "daily-log.md")
DAILY_LOG_MARKER = "# 📋 Daily Log"
TODO_MARKER = "### To Do"
IN_PROGRESS_MARKER = "### In Progress"
CODE_REVIEW_MARKER = "### Code Review / Waiting"
TESTING_MARKER = "### Testing"
DONE_SECTION_MARKER = "### Done"
DONE_DATE_RE = re.compile(r"\(done: (\d{4}-\d{2}-\d{2})\)")
CHECKED_RE = re.compile(r"^- \[x\] (.+)$", re.IGNORECASE)
DAY_HEADER_RE = re.compile(r"^## \d{4}-\d{2}-\d{2}$")
CHECKOUT_RE = re.compile(r"^- (\d{2}:\d{2}) 🔀 checkout → `([^`]+)`(.*)?$")
COMMIT_RE = re.compile(r"^- (\d{2}:\d{2}) 💾 commit \[`([^`]+)`\] \"(.*)\"$")
TICKET_RE = re.compile(os.environ.get("STANDUP_TICKET_PATTERN", r"[A-Z][A-Z0-9]+-\d+"))
HEADING_RE = re.compile(r"^#{1,6}\s")


def is_heading(stripped: str) -> bool:
    return HEADING_RE.match(stripped) is not None


def extract_ticket(branch: str) -> Optional[str]:
    """Extract the first ticket ID from a branch name."""
    m = TICKET_RE.search(branch)
    return m.group(0) if m else None


def normalize_branch(branch: str) -> str:
    """Return canonical branch key for matching (ticket ID if present, else full name)."""
    ticket = extract_ticket(branch)
    return ticket if ticket else branch


def short_label(summary: str, ticket: str) -> str:
    """Shorten tracker summary for inline display."""
    # Remove patterns like "1.3.2 Meaningful Sequence - " from the start
    summary = re.sub(r"^\d+(\.\d+)* \w[\w\s]+ - ", "", summary).strip()
    return summary


def label_for(branch: str, labels: dict[str, str]) -> Optional[str]:
    """Return a short label for a branch if we have a summary for its ticket."""
    ticket = extract_ticket(branch)
    if ticket and ticket in labels:
        return short_label(labels[ticket], ticket)
    return None


def parse_args():
    import argparse
    parser = argparse.ArgumentParser(description="Enrich standup dashboard and daily log.")
    parser.add_argument("--scan", action="store_true",
                        help="Scan for ticket IDs needing labels and output as JSON")
    parser.add_argument("--labels", metavar="FILE",
                        help="JSON file mapping PROJECT-123 -> summary")
    parser.add_argument("--move-done", action="store_true",
                        help="Move [x]-checked items to Done section and prune items older than 30 days")
    parser.add_argument("--promote-in-progress", action="store_true",
                        help="Promote untracked tickets from latest daily log entry to In Progress")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print enriched output instead of writing to file")
    return parser.parse_args()


def read_dashboard() -> list[str]:
    with open(DASHBOARD_PATH, "r") as f:
        return f.readlines()


def read_daily_log() -> list[str]:
    with open(DAILY_LOG_PATH, "r") as f:
        return f.readlines()


def find_daily_log_range(lines: list[str]) -> tuple[int, int]:
    """Return (start, end) line indices of the Daily Log section."""
    start = None
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped == DAILY_LOG_MARKER:
            start = i
        elif start is not None and stripped.startswith("# ") and stripped != DAILY_LOG_MARKER:
            return start, i
    return start, len(lines)


def scan_tickets(lines: list[str]) -> list[str]:
    """Return sorted unique OSMS ticket IDs in checkout/commit lines that lack a label (daily log only)."""
    start, end = find_daily_log_range(lines)
    if start is None:
        return []
    tickets = set()
    for line in lines[start:end]:
        stripped = line.rstrip()
        m_co = CHECKOUT_RE.match(stripped)
        m_cm = COMMIT_RE.match(stripped)
        # Only report if the line has no label yet (no " — " after the branch reference)
        if m_co:
            suffix = m_co.group(3) or ""
            if "—" not in suffix:
                ticket = extract_ticket(m_co.group(2))
                if ticket:
                    tickets.add(ticket)
        if m_cm:
            # COMMIT_RE only matches original format (no label yet), so any match needs a label
            ticket = extract_ticket(m_cm.group(2))
            if ticket:
                tickets.add(ticket)
    return sorted(tickets)


def enrich_day_section(day_lines: list[str], labels: dict[str, str]) -> list[str]:
    """
    Process a single day's lines:
      - Merge adjacent (checkout, commit) pairs for the same branch
      - Annotate bare ticket IDs with labels
    Returns updated lines (without trailing newlines).
    """
    # Strip newlines for processing
    raw = [l.rstrip("\n") for l in day_lines]
    result = []
    i = 0
    while i < len(raw):
        line = raw[i]
        m_co = CHECKOUT_RE.match(line)

        # Try to merge with next commit line if branches match
        if m_co and i + 1 < len(raw):
            next_line = raw[i + 1]
            m_cm = COMMIT_RE.match(next_line)
            if m_cm and normalize_branch(m_co.group(2)) == normalize_branch(m_cm.group(2)):
                t1 = m_co.group(1)
                t2 = m_cm.group(1)
                branch = m_cm.group(2)  # use commit branch (may have fuller name)
                message = m_cm.group(3)
                label = label_for(branch, labels)
                label_str = f" — {label}" if label else ""
                merged = f"- {t1}–{t2} 🔀💾 `{branch}`{label_str}: \"{message}\""
                result.append(merged)
                i += 2
                continue

        # Standalone checkout — add label if available
        if m_co:
            branch = m_co.group(2)
            suffix = m_co.group(3) or ""
            label = label_for(branch, labels)
            if label and f"— {label}" not in line and "—" not in suffix:
                result.append(f"- {m_co.group(1)} 🔀 checkout → `{branch}` — {label}")
            else:
                result.append(line)
            i += 1
            continue

        # Standalone commit — add label if available
        m_cm = COMMIT_RE.match(line)
        if m_cm:
            branch = m_cm.group(2)
            message = m_cm.group(3)
            label = label_for(branch, labels)
            if label and "—" not in line:
                result.append(f"- {m_cm.group(1)} 💾 commit [`{branch}`] — {label}: \"{message}\"")
            else:
                result.append(line)
            i += 1
            continue

        result.append(line)
        i += 1

    return result


def enrich(lines: list[str], labels: dict[str, str]) -> list[str]:
    """Enrich all day sections in the daily log."""
    start, end = find_daily_log_range(lines)
    if start is None:
        print("standup-enrich: could not find '# 📋 Daily Log' section.", file=sys.stderr)
        return lines

    # Collect lines before and after the daily log section
    before = lines[:start + 1]  # include the marker line
    after = lines[end:]

    # Split the daily log body into per-day chunks
    log_body = lines[start + 1:end]
    day_chunks: list[tuple[str, list[str]]] = []  # (header_line, content_lines)

    current_header = None
    current_lines: list[str] = []

    for line in log_body:
        stripped = line.rstrip()
        if DAY_HEADER_RE.match(stripped):
            if current_header is not None:
                day_chunks.append((current_header, current_lines))
            current_header = line
            current_lines = []
        else:
            current_lines.append(line)

    if current_header is not None:
        day_chunks.append((current_header, current_lines))
    else:
        # No day sections found — return unchanged
        return lines

    # Enrich each day chunk
    enriched_body: list[str] = []
    for header, content in day_chunks:
        enriched_body.append(header)
        enriched_content = enrich_day_section(content, labels)
        for l in enriched_content:
            enriched_body.append(l + "\n")

    return [l if l.endswith("\n") else l + "\n" for l in
            [l.rstrip("\n") for l in before]] + enriched_body + after


def move_done(lines: list[str]) -> tuple[list[str], list[str], list[str]]:
    """
    Scans active Jira sections for [x]-checked items.
    Moves them to the top of the Done section with a (done: YYYY-MM-DD) tag.
    Prunes Done items older than 30 days that carry a (done: YYYY-MM-DD) tag.
    Returns (updated_lines, moved_items, pruned_items).
    """
    today = datetime.now().date()
    cutoff = today - timedelta(days=30)
    today_str = today.strftime("%Y-%m-%d")

    active_sections = {TODO_MARKER, IN_PROGRESS_MARKER, CODE_REVIEW_MARKER, TESTING_MARKER}
    in_active = False
    in_done = False
    done_insert_idx = None  # line index right after the Done header

    items_to_move: list[str] = []   # cleaned text of items being moved
    indices_to_remove: set[int] = set()
    pruned_items: list[str] = []

    # --- Pass 1: collect [x] items and find Done insert point ---
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped in active_sections:
            in_active = True
            in_done = False
            continue
        if stripped == DONE_SECTION_MARKER:
            in_active = False
            in_done = True
            done_insert_idx = i + 1
            continue
        if is_heading(stripped) and stripped not in active_sections and stripped != DONE_SECTION_MARKER:
            in_active = False
            in_done = False

        if in_active:
            m = CHECKED_RE.match(stripped)
            if m:
                items_to_move.append(m.group(1).rstrip())
                indices_to_remove.add(i)

        if in_done and done_insert_idx is not None:
            # Track for pruning: skip blank lines right after header
            pass

    # --- Pass 2: prune old Done items and find real insert point ---
    # We'll rebuild all at once below, so just collect prune indices
    prune_indices: set[int] = set()
    in_done = False
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped == DONE_SECTION_MARKER:
            in_done = True
            continue
        if in_done and is_heading(stripped) and stripped != DONE_SECTION_MARKER:
            in_done = False
        if in_done and stripped.startswith("- "):
            m = DONE_DATE_RE.search(stripped)
            if m:
                item_date = datetime.strptime(m.group(1), "%Y-%m-%d").date()
                if item_date < cutoff:
                    pruned_items.append(stripped)
                    prune_indices.add(i)

    moved_items = list(items_to_move)

    if not moved_items and not prune_indices:
        return lines, [], []

    if done_insert_idx is not None:
        while done_insert_idx < len(lines) and lines[done_insert_idx].strip() == "":
            done_insert_idx += 1

    # --- Rebuild ---
    new_lines = []
    i = 0
    while i < len(lines):
        if i == done_insert_idx and items_to_move:
            for item_text in moved_items:
                # Strip any existing ✅ suffix so we don't double it
                clean = item_text.rstrip(" ✅").rstrip()
                new_lines.append(f"- {clean} ✅ (done: {today_str})\n")
            items_to_move = []  # only insert once
        if i in indices_to_remove or i in prune_indices:
            i += 1
            continue
        new_lines.append(lines[i])
        i += 1

    if done_insert_idx == len(lines) and items_to_move:
        for item_text in moved_items:
            clean = item_text.rstrip(" ✅").rstrip()
            new_lines.append(f"- {clean} ✅ (done: {today_str})\n")

    return new_lines, moved_items, pruned_items


def find_latest_day_tickets(lines: list[str]) -> set[str]:
    """Return all OSMS ticket IDs found in the most recent daily log day section."""
    start, end = find_daily_log_range(lines)
    if start is None:
        return set()
    log_body = lines[start + 1:end]
    first_day_idx = None
    second_day_idx = len(log_body)
    for i, line in enumerate(log_body):
        if DAY_HEADER_RE.match(line.rstrip()):
            if first_day_idx is None:
                first_day_idx = i
            else:
                second_day_idx = i
                break
    if first_day_idx is None:
        return set()
    tickets = set()
    for line in log_body[first_day_idx:second_day_idx]:
        for m in TICKET_RE.finditer(line):
            tickets.add(m.group(0))
    return tickets


TRACKED_SECTION_MARKERS = {
    TODO_MARKER,
    IN_PROGRESS_MARKER,
    CODE_REVIEW_MARKER,
    TESTING_MARKER,
    DONE_SECTION_MARKER,
}


def find_tracked_tickets(lines: list[str]) -> set[str]:
    """Return all OSMS ticket IDs already mentioned in any non-daily-log section."""
    daily_log_start, _ = find_daily_log_range(lines)
    tickets = set()
    in_tracked = False
    for i, line in enumerate(lines):
        if daily_log_start is not None and i >= daily_log_start:
            break
        stripped = line.rstrip()
        if stripped in TRACKED_SECTION_MARKERS:
            in_tracked = True
            continue
        if in_tracked and is_heading(stripped):
            in_tracked = False
        if in_tracked:
            for m in TICKET_RE.finditer(stripped):
                tickets.add(m.group(0))
    return tickets


def promote_in_progress(
    lines: list[str],
    daily_log_lines: list[str],
    labels: dict[str, str],
) -> tuple[list[str], list[str]]:
    """
    Find OSMS tickets in the most recent daily log day that aren't already tracked
    in any section. Insert them at the bottom of the In Progress section.
    Returns (updated_lines, promoted_items).
    """
    latest = find_latest_day_tickets(daily_log_lines)
    tracked = find_tracked_tickets(lines)
    to_promote = sorted(latest - tracked)
    if not to_promote:
        return lines, []

    # Find the end of the In Progress section (line index of the next heading after it)
    in_progress_end: Optional[int] = None
    in_in_progress = False
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped == IN_PROGRESS_MARKER:
            in_in_progress = True
            continue
        if in_in_progress and is_heading(stripped):
            in_progress_end = i
            break

    if in_in_progress and in_progress_end is None:
        in_progress_end = len(lines)

    if in_progress_end is None:
        print("standup-enrich: could not find In Progress section end.", file=sys.stderr)
        return lines, []

    promoted = []
    new_lines = list(lines)
    insert_at = in_progress_end
    # Skip back past blank lines so we insert before the trailing blank + next header
    while insert_at > 0 and new_lines[insert_at - 1].strip() == "":
        insert_at -= 1

    for ticket in reversed(to_promote):
        label = labels.get(ticket, "")
        title = f" {label}" if label else ""
        entry = f"- [{ticket}]{title}\n"
        new_lines.insert(insert_at, entry)
        promoted.append(f"[{ticket}]{title}")

    return new_lines, promoted


def main():
    args = parse_args()

    if args.scan:
        lines = read_daily_log()
        tickets = scan_tickets(lines)
        print(json.dumps(tickets))
        return

    if args.move_done:
        lines = read_dashboard()
        updated, moved, pruned = move_done(lines)
        if not moved and not pruned:
            print("✅ standup-enrich --move-done: nothing to move or prune.")
            return
        for item in moved:
            print(f"  ➡️  Moved to Done: {item}")
        for item in pruned:
            print(f"  🗑️  Pruned (>30 days): {item}")
        if args.dry_run:
            print("".join(updated))
        else:
            with open(DASHBOARD_PATH, "w") as f:
                f.writelines(updated)
            print(f"✅ standup-enrich: updated {DASHBOARD_PATH}")
        return

    labels: dict[str, str] = {}
    if args.labels:
        with open(args.labels, "r") as f:
            labels = json.load(f)

    if args.promote_in_progress:
        dashboard_lines = read_dashboard()
        daily_log_lines = read_daily_log()
        updated, promoted = promote_in_progress(dashboard_lines, daily_log_lines, labels)
        if not promoted:
            print("✅ standup-enrich --promote-in-progress: nothing to promote.")
            return
        for item in promoted:
            print(f"  ⬆️  Promoted to In Progress: {item}")
        if args.dry_run:
            print("".join(updated))
        else:
            with open(DASHBOARD_PATH, "w") as f:
                f.writelines(updated)
            print(f"✅ standup-enrich: updated {DASHBOARD_PATH}")
        return

    lines = read_daily_log()
    enriched = enrich(lines, labels)

    if args.dry_run:
        print("".join(enriched))
    else:
        with open(DAILY_LOG_PATH, "w") as f:
            f.writelines(enriched)
        print(f"✅ standup-enrich: updated {DAILY_LOG_PATH}")


if __name__ == "__main__":
    main()
