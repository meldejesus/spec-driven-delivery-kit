# macOS Developer Cleanup Guide

**Script:** `clean.sh`

---

## Team Setup (one-time)

Install the cleanup extension into a workspace, then run commands from
`scripts/cleanup/`.

Add a `clean` alias to `~/.zshrc` by running this **from this folder**:

```bash
cd /path/to/workspace/scripts/cleanup
echo "alias clean='$(pwd)/clean.sh --yes'" >> ~/.zshrc
source ~/.zshrc
```

Then just type `clean` from anywhere.

> **Android project path** auto-detects Android project folders under the
> workspace. To override it, set `ANDROID_PROJECT_DIR` or colon-separated
> `ANDROID_PROJECT_DIRS`:
> ```bash
> ANDROID_PROJECT_DIR=~/your-project/android ./clean.sh --only android_build
> ```

---

## Run it now

Preview what would be cleaned (dry-run, no changes):
```bash
./clean.sh
```

Execute the preferred category set:
```bash
./clean.sh --yes
```

Run everything (all categories):
```bash
./clean.sh --yes --all
```

Target specific categories only:
```bash
./clean.sh --yes --only gradle_caches,user_caches,logs_old,trash_empty
```

Clean the repo-local generated artifacts that tend to grow during active dev:
```bash
./clean.sh --yes --only project_generated
```

Free the cache/build locations that most often spike on this repo:
```bash
./clean.sh --yes --only node_caches,project_generated,android_build
```

---

Always preview first by running `./clean.sh` (dry-run is the default) before running with `--yes`.

---
## What to know about the initial run

**Things that cause a slow next build (recoverable, just annoying):**
- `gradle_caches` - next Android build re-downloads all dependencies (~5-10 min)
- `xcode_derived` - next iOS build recompiles from scratch (~2-5 min)
- `cocoapods_carthage` - next `pod install` re-downloads pod sources
- `editors_cache` (VS Code) - editor may feel slightly slower on first reopen

**Things that require a decision before running:**
- `xcode_devicesupport` - keeps only the 2 newest iOS device SDKs; if you plug in an older device afterward, Xcode re-downloads its support files
- `xcode_simulators` - deletes "unavailable" simulators; safe, but worth knowing
- `project_generated` - deletes repo-local `tmp`, `coverage`, and `.nx`; active dev servers may need a restart
- `ios_simulator_runtimes` (not in default set) - each runtime is ~6-8 GB; only run if you know which iOS versions you need
- `android_sdk_images` (not in default set) - removes unused Android SDK system images

**Things that are intentionally excluded from the default run:**
- Docker (anything) - not in default `ONLY` set, must use `--only docker_dangling` or `--aggressive`
- Browser caches - not in default, use `--only browsers_cache`
- Project-generated artifacts - not in default, use `--only project_generated` or `--all`

**The one thing to hammer home:**
> Run `clean.sh` first (dry-run) and read the estimates before running `./clean.sh --yes`. The dry-run is the default - nothing is deleted until you pass `--yes`.

That's essentially the full briefing. The script itself prints warnings inline for the risky categories, so most of this is self-documenting once they run the dry-run.

---

## Categories

| Category              | What it cleans                                                    | Notes                                                                                                                               |
| --------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `node_caches`         | Yarn/npm/pnpm caches, Yarn Berry cache, `_npx`, Cypress, Puppeteer | Never touches project `node_modules`                                                                                                 |
| `pip_cache`           | `~/Library/Caches/pip`                                            | Safe                                                                                                                                |
| `brew_cleanup`        | Runs `brew cleanup -s`                                            | Safe                                                                                                                                |
| `user_caches`         | `~/Library/Caches/`, `~/.cache/`                                  | Skips iCloud, OneDrive, security tools                                                                                              |
| `gradle_caches`       | `~/.gradle/caches/` - global dep download cache only              | Safe to run anytime. Does NOT touch compiled output or project files. Next build re-downloads deps (adds ~2 min).                   |
| `xcode_derived`       | DerivedData + Archives                                            | Often frees 10-50 GB                                                                                                                |
| `xcode_simulators`    | Unavailable simulators only                                       | Active simulators untouched                                                                                                         |
| `xcode_devicesupport` | Old iOS DeviceSupport (keeps 2 newest)                            | Safe                                                                                                                                |
| `cocoapods_carthage`  | CocoaPods + Carthage caches                                       | Rebuild automatically                                                                                                               |
| `browsers_cache`      | Safari, Chrome, Edge, Brave caches                                | Excluded from preferred command (may sign you out)                                                                                  |
| `editors_cache`       | VS Code + JetBrains caches                                        | Keeps settings/extensions                                                                                                           |
| `logs_old`            | Logs older than 14 days                                           | Safe                                                                                                                                |
| `trash_empty`         | `~/.Trash`                                                        | Review contents first                                                                                                               |
| `project_generated`   | `tmp`, `coverage`, and `.nx` under configured project roots        | Recoverable. Active dev servers may need a restart. Does not touch `node_modules`.                                                  |
| `docker_dangling`     | Stopped containers, dangling images, unused networks, build cache | Safe. Volumes are never touched here.                                                                                               |
| `docker_volumes`      | Unused Docker volumes                                             | **Risky.** `docker compose down` makes DB volumes appear unused. Only run if local DBs are disposable. Use `--only docker_volumes`. |
| `docker_aggressive`   | All unused Docker (needs `--aggressive`)                          | Use with caution                                                                                                                    |
| `android_build`       | Android `app/build` + project `.gradle`                           | Auto-detects Android project folders or uses `ANDROID_PROJECT_DIR(S)`. Next build recompiles from scratch.                          |

### gradle_caches - will it undo build progress?

**No.** The script only cleans `~/.gradle/caches/` - the global Gradle dependency download cache (`.jar` files, transforms, etc.). It does **not** touch:
- `apps/mobile/android/app/build/` - compiled APK output
- `apps/mobile/android/.gradle/` - the project-local incremental state

Safe to run even mid-stuck-build. The only cost is that the next build re-downloads Gradle dependencies (~2 min extra).

---

## Never touched (by default)

- Project `node_modules`
- Repo `tmp`, `coverage`, and `.nx` - unless you explicitly use `--only project_generated` or `--all`
- Compiled build output (`android/app/build/`) - unless you explicitly use `--only android_build`
- Source code of any kind
- App settings or preferences
- iCloud / OneDrive / Dropbox
- Security/MDM tools (Defender, CrowdStrike, Cisco, Zscaler)
- System directories

---

## Flags

| Flag               | Description                               |
| ------------------ | ----------------------------------------- |
| `--dry-run`        | Preview only (default)                    |
| `--yes`            | Execute without prompting auto categories |
| `--fast`           | Skip expensive directory scans            |
| `--aggressive`     | Add Docker `-a --volumes` prune           |
| `--only cat1,cat2` | Run specific categories only              |
| `--since-days N`   | Log age threshold (default: 14)           |
| `--self-test`      | Check available tools, no changes         |
| `--timeout-secs N` | Per-command timeout (default: 25s)        |
| `--debug`          | Shell tracing (`set -x`)                  |

Logs written to `~/cleanup-logs/<timestamp>.log`. Files moved to `~/.Trash`, not hard-deleted.
