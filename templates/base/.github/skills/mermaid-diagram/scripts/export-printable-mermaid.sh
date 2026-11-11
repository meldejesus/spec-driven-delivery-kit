#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_MERMAID_CLI_VERSION="11.12.0"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <diagram.mmd|document.md> [output-directory]" >&2
  exit 2
fi

input_argument="$1"
if [[ ! -f "$input_argument" ]]; then
  echo "Mermaid input does not exist: $input_argument" >&2
  exit 2
fi

input_directory="$(cd "$(dirname "$input_argument")" && pwd)"
input_file="$input_directory/$(basename "$input_argument")"
input_name="$(basename "$input_file")"
input_stem="${input_name%.*}"
skill_directory="$(cd "$(dirname "$0")/.." && pwd)"
output_directory="${2:-$input_directory/printable/$input_stem}"

case "$input_file" in
  *.md|*.markdown)
    output_mode="markdown"
    ;;
  *.mmd)
    output_mode="diagram"
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

"$skill_directory/scripts/validate-mermaid.sh" "$input_file"

mkdir -p "$output_directory"
output_directory="$(cd "$output_directory" && pwd)"
mermaid_cli_version="${MERMAID_CLI_VERSION:-$DEFAULT_MERMAID_CLI_VERSION}"

if [[ "$output_mode" == "markdown" ]]; then
  npx --yes --package="@mermaid-js/mermaid-cli@$mermaid_cli_version" \
    mmdc --input "$input_file" \
    --output "$output_directory/$input_stem-print.md"
  npx --yes --package="@mermaid-js/mermaid-cli@$mermaid_cli_version" \
    mmdc --input "$input_file" \
    --output "$output_directory/$input_stem-print.pdf" \
    --backgroundColor white \
    --pdfFit
else
  npx --yes --package="@mermaid-js/mermaid-cli@$mermaid_cli_version" \
    mmdc --input "$input_file" \
    --output "$output_directory/$input_stem-print.svg"
  npx --yes --package="@mermaid-js/mermaid-cli@$mermaid_cli_version" \
    mmdc --input "$input_file" \
    --output "$output_directory/$input_stem-print.pdf" \
    --backgroundColor white \
    --pdfFit
fi

pdf_found=0
while IFS= read -r printable_pdf; do
  if [[ ! -s "$printable_pdf" ]]; then
    echo "Printable PDF is empty: $printable_pdf" >&2
    exit 1
  fi
  pdf_found=1
  echo "Printable PDF: $printable_pdf"
done < <(find "$output_directory" -maxdepth 1 -type f -name "$input_stem-print*.pdf" -print | sort)

if [[ "$pdf_found" -ne 1 ]]; then
  echo "No printable PDF was produced in: $output_directory" >&2
  exit 1
fi

echo "Print-safe Mermaid exports created with @mermaid-js/mermaid-cli@$mermaid_cli_version"
