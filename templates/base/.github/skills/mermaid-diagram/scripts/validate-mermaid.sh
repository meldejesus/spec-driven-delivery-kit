#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_MERMAID_CLI_VERSION="11.12.0"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <diagram.mmd|document.md>" >&2
  exit 2
fi

input_argument="$1"
if [[ ! -f "$input_argument" ]]; then
  echo "Mermaid input does not exist: $input_argument" >&2
  exit 2
fi

input_directory="$(cd "$(dirname "$input_argument")" && pwd)"
input_file="$input_directory/$(basename "$input_argument")"

case "$input_file" in
  *.md|*.markdown)
    if ! grep -Eq '^[[:space:]]*```[[:space:]]*mermaid[[:space:]]*$' "$input_file"; then
      echo "No fenced Mermaid block found in: $input_file" >&2
      exit 2
    fi
    output_name="validated.md"
    ;;
  *.mmd)
    output_name="validated.svg"
    ;;
  *)
    echo "Expected a .mmd, .md, or .markdown file: $input_file" >&2
    exit 2
    ;;
esac

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "Node.js and npx are required; Java is not used by Mermaid CLI." >&2
  exit 2
fi

mermaid_cli_version="${MERMAID_CLI_VERSION:-$DEFAULT_MERMAID_CLI_VERSION}"
temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/mermaid-validation.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT

echo "Validating with @mermaid-js/mermaid-cli@$mermaid_cli_version"
(
  cd "$temporary_directory"
  npx --yes --package="@mermaid-js/mermaid-cli@$mermaid_cli_version" \
    mmdc --input "$input_file" --output "$output_name"
)

if [[ "${MERMAID_ALLOW_FOREIGN_OBJECT:-0}" != "1" ]]; then
  foreign_object_found=0
  while IFS= read -r rendered_svg; do
    if grep -q '<foreignObject' "$rendered_svg"; then
      echo "Print-safety validation failed: $(basename "$rendered_svg") contains HTML foreignObject labels." >&2
      foreign_object_found=1
    fi
  done < <(find "$temporary_directory" -maxdepth 1 -type f -name '*.svg' -print)

  if [[ "$foreign_object_found" -eq 1 ]]; then
    cat >&2 <<'EOF'
Use native SVG text for printable diagrams. For flowcharts, add this directive before the diagram declaration:
%%{init: {"theme": "default", "look": "classic", "htmlLabels": false, "flowchart": {"useMaxWidth": false}}}%%

Set MERMAID_ALLOW_FOREIGN_OBJECT=1 only when the requested output is explicitly screen-only.
EOF
    exit 1
  fi
fi

echo "Mermaid validation passed: $input_file"
