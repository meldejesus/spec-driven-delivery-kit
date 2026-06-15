#!/usr/bin/env python3
"""
standup-log.py — appends a timestamped entry to today's section in standup/daily-log.md.

Usage:
  python3 scripts/standup-sync/standup-log.py checkout <branch>
  python3 scripts/standup-sync/standup-log.py commit   <branch> <message>
"""

import sys
import os
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
DAILY_LOG_PATH = os.path.join(ROOT, "standup", "daily-log.md")
DAILY_LOG_MARKER = "# 📋 Daily Log"
COMMENT_LINE = "<!-- Auto-updated by git hooks. Newest first. -->"


def build_entry(event: str, args: list[str]) -> str:
    now = datetime.now()
    time_str = now.strftime("%H:%M")
    if event == "checkout":
        branch = args[0] if args else "unknown"
        return f"- {time_str} 🔀 checkout → `{branch}`"
    elif event == "commit":
        branch = args[0] if len(args) > 0 else "unknown"
        message = args[1] if len(args) > 1 else "(no message)"
        return f"- {time_str} 💾 commit [`{branch}`] \"{message}\""
    return f"- {time_str} ℹ️ {event} {' '.join(args)}"


def today_header() -> str:
    return datetime.now().strftime("## %Y-%m-%d")


def update_standup(entry: str) -> None:
    if not os.path.exists(DAILY_LOG_PATH):
        print(f"standup-log: file not found at {DAILY_LOG_PATH}", file=sys.stderr)
        return

    with open(DAILY_LOG_PATH, "r") as f:
        lines = f.readlines()

    header = today_header()
    daily_log_idx = None
    today_idx = None

    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if stripped == DAILY_LOG_MARKER or stripped.startswith(DAILY_LOG_MARKER[:10]):
            pass
        if stripped == DAILY_LOG_MARKER:
            daily_log_idx = i
        if stripped == header:
            today_idx = i
            break  # found today's section, no need to keep searching

    if daily_log_idx is None:
        print("standup-log: could not find '# 📋 Daily Log' section.", file=sys.stderr)
        return

    if today_idx is None:
        # Insert new today section right after the Daily Log header (and optional comment line)
        insert_at = daily_log_idx + 1
        # Skip the comment line if present
        if insert_at < len(lines) and lines[insert_at].strip().startswith("<!--"):
            insert_at += 1
        # Skip blank line if present
        if insert_at < len(lines) and lines[insert_at].strip() == "":
            insert_at += 1
        new_block = ["\n", f"{header}\n", f"{entry}\n"]
        lines = lines[:insert_at] + new_block + lines[insert_at:]
    else:
        # Append entry after today's header, before the next ## section or blank-then-##
        insert_at = today_idx + 1
        # Skip any existing entries for today
        while insert_at < len(lines):
            stripped = lines[insert_at].rstrip()
            if stripped.startswith("## ") or stripped.startswith("---"):
                break
            insert_at += 1
        lines.insert(insert_at, f"{entry}\n")

    with open(DAILY_LOG_PATH, "w") as f:
        f.writelines(lines)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: standup-log.py <checkout|commit> [args...]")
        sys.exit(1)
    event = sys.argv[1]
    args = sys.argv[2:]
    entry = build_entry(event, args)
    update_standup(entry)
