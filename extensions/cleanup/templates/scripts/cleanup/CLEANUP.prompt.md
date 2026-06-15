# Script Upgrade Prompt Specification

Use this prompt in GitHub Copilot, ChatGPT, or any LLM to request improvements to the macOS cleanup script.

---

## Prompt: Improve My macOS Cleanup Script (`clean.sh`)
You are an expert macOS platform automation engineer. I will provide an existing shell cleanup script (`clean.sh`). Your job is to **improve, simplify, optimize, and extend** this script while preserving its strong safety guarantees.

---

## Safety Requirements
- Script must use **zsh**.
- Must default to **dry-run** mode.
- Must never require `sudo`.
- Must never modify or remove:
  - `/System` or any system-level directory
  - Keychains
  - iCloud, OneDrive, Dropbox directories
  - MDM or security tooling (Defender, CrowdStrike, Cisco, etc.)
- All destructive actions must:
  - Be restricted to user-space dev caches
  - Prefer moving to `~/.Trash` when possible
  - Require explicit user confirmation unless `--yes` is given

---

## Portability Requirements
- **Never hardcode local-specific paths** (no `/Users/username/...`, no machine-specific directories).
- All user-space path references must use shell variables:
  - `$HOME` for the user's home directory
  - `$(pwd)` or `$PWD` for the current working directory
  - `$(brew --prefix)` for Homebrew prefix (not `/opt/homebrew` or `/usr/local` directly)
- The script must be **cloneable and runnable from any directory** on any macOS machine without modification.
- Alias setup examples in documentation must also use `$(pwd)` so the path self-resolves at install time, not at authoring time.

---

## Functional Requirements
The improved script should:
- Add or refine progress indicators (spinners, timestamps).
- Add `--verbose` and `--debug` modes.
- Add **robust numeric parsing** to avoid integer truncation warnings.
- Add per-category timing (optional).
- Provide a more compact and visually clear summary.
- Support flags to explicitly include/exclude:
  - Browser caches
  - Docker cleanup
  - Xcode cleanup
  - Gradle cleanup
- Maintain `--only` filtering for category-level execution.
- Add improved logging structure with timestamps.
- Maintain `--fast` flag to reduce expensive directory scans.
- Prevent hangs with optional command timeouts.
- Ensure dry-run mode never deletes anything, even if `--yes` is passed.

---

## Output Requirements
- Produce a single `.sh` file containing the updated script.
- Add a header comment block describing:
  - Purpose
  - Safety model
  - Usage examples
- Code must be readable, structured, and maintainable.
- Provide a short "What's New" summary.

---

## Deliverables
- The full updated script
- Release notes summarizing improvements

---

Use the above requirements to iteratively enhance the script while maintaining safety as the highest priority.
