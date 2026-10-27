#!/usr/bin/env python3
"""Search active and archived workflow notes, grouped by ticket.

Example: python3 workflow-search.py syllabus uploader
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve()
ROOT = next(
    (parent for parent in SCRIPT_PATH.parents if (parent / "workflow").is_dir()),
    SCRIPT_PATH.parents[2],
)
SEARCH_ROOTS = (ROOT / "workflow", ROOT / "workflow-archive-private" / "workflow")
TICKET_DIR = re.compile(r"^(OSMS|NOJIRA)-[A-Za-z0-9-]+$", re.IGNORECASE)


def ticket_for(path: Path) -> str | None:
    """Return the nearest ticket-like workflow folder for a markdown file."""
    for part in reversed(path.relative_to(ROOT).parts[:-1]):
        if TICKET_DIR.match(part):
            return part.upper()
    return None


def clean_line(line: str) -> str:
    line = re.sub(r"^\s{0,3}(?:[-*+]\s+|#+\s*)", "", line)
    line = re.sub(r"[`*_>#]", "", line)
    return " ".join(line.split())


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Find related workflow tickets in active and archived notes."
    )
    parser.add_argument("keywords", nargs="+", help="Words or quoted phrases to search")
    parser.add_argument(
        "--any", dest="match_any", action="store_true",
        help="match a ticket containing any keyword (default: require all keywords)",
    )
    parser.add_argument("--limit", type=int, default=2, help="angles shown per ticket (default: 2)")
    args = parser.parse_args()
    terms = [term.casefold() for term in args.keywords if term.strip()]
    if not terms:
        parser.error("provide at least one non-empty keyword")

    # A record is one ticket folder; query terms can match across its files.
    hits: dict[str, dict[str, object]] = {}
    seen_files = 0
    ticket_lines: dict[str, list[tuple[str, str]]] = defaultdict(list)
    for search_root in SEARCH_ROOTS:
        if not search_root.is_dir():
            continue
        for path in search_root.rglob("*.md"):
            try:
                relative = path.relative_to(ROOT)
                content = path.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            seen_files += 1
            ticket = ticket_for(path)
            if not ticket:
                continue
            for raw_line in content.splitlines():
                line = clean_line(raw_line)
                if line:
                    ticket_lines[ticket].append((str(relative), line))

    for ticket, entries in ticket_lines.items():
        ticket_text = "\n".join(line for _, line in entries).casefold()
        matches = (any(term in ticket_text for term in terms) if args.match_any
                   else all(term in ticket_text for term in terms))
        if not matches:
            continue

        # Show lines that contain searched terms; concise metadata lines rank first.
        matching_entries = [(path, line) for path, line in entries
                            if any(term in line.casefold() for term in terms)]
        matching_lines = [line for _, line in matching_entries]

        def score(line: str) -> tuple[int, int, int]:
            folded = line.casefold()
            matched_terms = sum(term in folded for term in terms)
            metadata = any(label in folded for label in ("summary:", "description:", "title:"))
            return (-matched_terms, 0 if metadata else 1, len(line))

        record = {"paths": {path for path, _ in matching_entries}, "angles": []}
        angles = record["angles"]
        for line in sorted(set(matching_lines), key=score):
            if line not in angles:
                angles.append(line)
        hits[ticket] = record

    if not hits:
        print("No matching tickets found.")
        return 0

    ids = sorted(hits, key=lambda value: (value.split("-")[0], value))
    print("Ticket IDs (copyable):")
    print(" ".join(ids))
    print("\nMatches:")
    for ticket in ids:
        record = hits[ticket]
        print(f"\n{ticket}")
        for angle in record["angles"][: max(1, args.limit)]:  # type: ignore[index]
            print(f"  - {angle}")
        locations = sorted(record["paths"])  # type: ignore[arg-type]
        print(f"  Files: {', '.join(locations[:3])}" + (" …" if len(locations) > 3 else ""))
    print(f"\nSearched {seen_files} Markdown files across active and archived workflow.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
