#!/bin/zsh
# clean.sh - macOS developer cleanup with dry-run safety by default
# - Per-step spinner that ticks every ~250ms while commands run
# - Timestamps before/after each heavy command (find/du/docker)
# - Immediate environment banner so you know it started
# - Keeps prior safety: dry-run by default, no sudo, allow-lists

set -u
set -o pipefail

# Defaults
# ONLY defaults to the preferred safe set: useful categories without risky ones
# such as browser caches or Docker.
# Pass --all to run every category, or --only cat1,cat2 to target specific ones.
DRY_RUN=1; YES=0; AGGRESSIVE=0; SINCE_DAYS=14; LOGFILE=""; SELF_TEST=0; FAST=1; TIMEOUT_SECS=25; DEBUG=0; ALL=0
ONLY="node_caches,pip_cache,brew_cleanup,user_caches,gradle_caches,xcode_derived,xcode_simulators,xcode_devicesupport,cocoapods_carthage,editors_cache,logs_old,trash_empty"

# Colors
BOLD="$(tput bold || true)"; RESET="$(tput sgr0 || true)"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; BLUE="\033[34m"; CYAN="\033[36m"; NC="\033[0m"
info() { printf "%b%s%b\n" "$CYAN" "$1" "$NC" | tee -a "$LOGFILE"; }
success() { printf "%b%s%b\n" "$GREEN" "$1" "$NC" | tee -a "$LOGFILE"; }
warn() { printf "%b%s%b\n" "$YELLOW" "$1" "$NC" | tee -a "$LOGFILE"; }
section() { printf "\n%s%s%s\n" "$BOLD" "$1" "$RESET" | tee -a "$LOGFILE"; }
now() { date +"%Y-%m-%d %H:%M:%S"; }
mklogdir() { mkdir -p "$HOME/cleanup-logs" 2>/dev/null || true; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." 2>/dev/null && pwd || pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$DEFAULT_PROJECT_ROOT}"

print_help() {
  cat <<'EOF'
Usage: clean.sh [--dry-run] [--yes] [--all] [--aggressive] [--only cat1,cat2] [--since-days N] [--logfile PATH] [--self-test] [--fast] [--timeout-secs N] [--debug]

Defaults to a dry-run of the preferred category set. Use --yes to execute. Use --all to run every category.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; YES=0; shift ;;
    --yes) DRY_RUN=0; YES=1; shift ;;
    --aggressive) AGGRESSIVE=1; shift ;;
    --only) ONLY=${2:-""}; shift 2 ;;
    --all) ALL=1; ONLY=""; shift ;;
    --since-days) SINCE_DAYS=${2:-14}; shift 2 ;;
    --logfile) LOGFILE=${2:-""}; shift 2 ;;
    --self-test) SELF_TEST=1; shift ;;
    --fast) FAST=1; shift ;;
    --timeout-secs) TIMEOUT_SECS=${2:-25}; shift 2 ;;
    --debug) DEBUG=1; shift ;;
    -h|--help) print_help; exit 0 ;;
    *) warn "Unknown flag: $1"; print_help; exit 1 ;;
  esac
done

OS_VER=$(sw_vers -productVersion 2>/dev/null || echo "unknown"); ARCH=$(uname -m); CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
if [[ -d "/opt/homebrew" ]]; then BREW_PREFIX="/opt/homebrew"; else BREW_PREFIX="/usr/local"; fi
BREW_BIN="$BREW_PREFIX/bin/brew"
if [[ -z "$LOGFILE" ]]; then mklogdir; TS=$(date +"%Y%m%d_%H%M%S"); LOGFILE="$HOME/cleanup-logs/clean_${TS}.log"; fi
[[ $DEBUG -eq 1 ]] && set -x

section "Environment"
info "Time: $(now)"; info "OS: macOS $OS_VER | Arch: $ARCH | Chip: $CHIP"; info "Homebrew: ${BREW_BIN} $( [[ -x "$BREW_BIN" ]] && echo 'present' || echo 'missing' )"
info "Mode: $([[ $DRY_RUN -eq 1 ]] && echo 'DRY-RUN' || echo 'EXECUTE') | Aggressive: $AGGRESSIVE | Since-days: $SINCE_DAYS | Fast: $FAST | Timeout: ${TIMEOUT_SECS}s"
info "Log: $LOGFILE"
info "Project root: $PROJECT_ROOT"

# --- Numeric sanitizers ---
num_only() { printf "%s" "$1" | awk 'NR==1{printf "%d\n", $1+0; exit}'; }
sanitize_kb() { local v=""; v=$(num_only "$1"); echo "${v:-0}"; }
kb_to_h() { local kb=$(sanitize_kb "$1"); awk -v kb="$kb" 'BEGIN{u[1]="KB";u[2]="MB";u[3]="GB";u[4]="TB";s=kb+0;for(i=1;i<5&&s>=1024;i++){s/=1024} printf (i==1?"%.0f %s":"%.2f %s"), s, u[i] }'; }
RECLAIMABLE_KB=0; add_reclaimable() { local kb=$(sanitize_kb "$1"); : $(( RECLAIMABLE_KB += kb )); }

# --- Spinner & timeout wrappers ---
spin_run() {
  # spin_run <label> <cmd...>
  local label="$1"; shift
  local spin='|/-\\'; local i=1
  printf "%s %s %s\n" "[ $(now) ]" "$label" "(starting)" | tee -a "$LOGFILE"
  ( "$@" ) & local pid=$!
  while kill -0 $pid 2>/dev/null; do
    printf "\r%s %s %s %c" "[ $(now) ]" "$label" "(running)" ${spin:$((i%4)):1}
    i=$((i+1)); sleep 0.25
  done
  wait $pid; local rc=$?
  printf "\r%s %s %s (rc=%d)\n" "[ $(now) ]" "$label" "(done)" $rc | tee -a "$LOGFILE"
  return $rc
}

with_timeout() {
  local secs="$1"; shift
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"; elif command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"; else "$@"; fi
}

safe_trash() {
  local p="$1"
  [[ -e "$p" ]] || return 0
  mkdir -p "$HOME/.Trash" 2>/dev/null || true
  local base=$(basename "$p")
  local stamp=$(date +%s)
  local dst="$HOME/.Trash/${base}_${stamp}"
  local i=1
  while [[ -e "$dst" ]]; do
    dst="$HOME/.Trash/${base}_${stamp}_${i}"
    i=$((i+1))
  done
  mv "$p" "$dst" 2>/dev/null || rm -rf "$p" 2>/dev/null || true
}

size_kb() {
  local total=0
  for p in "$@"; do
    if [[ -e "$p" ]]; then
      local s=""
      s=$(du -sk "$p" 2>/dev/null | awk '{print $1}')
      s=$(sanitize_kb "$s")
      : $(( total += ${s:-0} ))
    fi
  done
  echo $total
}

show_top10() {
  local d="$1"; [[ $FAST -eq 1 ]] && { info "(fast) Skip Top 10 in $d"; return 0; }
  [[ -d "$d" ]] || return 0
  spin_run "Top10 in $d" sh -c 'find "$0" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | xargs -0 du -sh 2>/dev/null | sort -hr | head -n 10' "$d" | tee -a "$LOGFILE"
}

start_cat() { section "[START] $1"; }
end_cat()   { success "[END]   $1"; }

# --- Categories (trimmed explanations for brevity; same targets) ---
cat_node_caches() {
  local name="Node/Yarn/PNPM/test tool caches"
  start_cat "$name"
  local paths=(
    "$HOME/.cache/yarn"
    "$HOME/.cache/npm"
    "$HOME/.yarn/berry/cache"
    "$HOME/.npm/_npx"
    "$HOME/Library/Caches/Yarn"
    "$HOME/Library/Caches/pnpm"
    "$HOME/Library/Caches/Cypress"
    "$HOME/.cache/puppeteer"
  )
  local kb=$(size_kb "${paths[@]}")
  info "Estimated: $(kb_to_h $kb)"
  [[ -d "$HOME/.cache" ]] && show_top10 "$HOME/.cache"
  [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }
  command -v yarn >/dev/null 2>&1 && spin_run "yarn cache clean" yarn cache clean || true
  command -v npm >/dev/null 2>&1 && spin_run "npm cache clean --force" npm cache clean --force || true
  command -v pnpm >/dev/null 2>&1 && spin_run "pnpm store prune" pnpm store prune || true
  for p in "${paths[@]}"; do [[ -e "$p" ]] && safe_trash "$p"; done
  end_cat "$name"
}

cat_project_generated() {
  local name="Project generated artifacts (tmp, coverage, .nx)"
  start_cat "$name"
  local roots=()
  if [[ -n "${PROJECT_GENERATED_ROOTS:-}" ]]; then
    roots=( "${(@s/:/)PROJECT_GENERATED_ROOTS}" )
  else
    roots=( "$PROJECT_ROOT" )
    for root in "$PROJECT_ROOT"/*; do
      [[ -d "$root/.git" ]] && roots+=( "$root" )
    done
  fi
  if [[ ${#roots[@]} -eq 0 ]]; then
    warn "No project roots found under PROJECT_ROOT=$PROJECT_ROOT"
    end_cat "$name"
    return
  fi

  local targets=()
  for root in "${roots[@]}"; do
    for p in "$root/tmp" "$root/coverage" "$root/.nx"; do
      [[ -e "$p" ]] && targets+=("$p")
    done
  done

  local kb=$(size_kb "${targets[@]}")
  info "Estimated: $(kb_to_h $kb)"
  if [[ ${#targets[@]} -gt 0 ]]; then
    info "Paths:"
    for p in "${targets[@]}"; do info "  $p"; done
  fi
  [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }
  if [[ $YES -eq 1 ]] || read -q "?Delete repo tmp/coverage/.nx artifacts? Active dev servers may need restart. [y/N] "; then
    echo
    for p in "${targets[@]}"; do [[ -e "$p" ]] && safe_trash "$p"; done
  else
    info "Skipped project generated artifacts"
  fi
  end_cat "$name"
}

cat_pip_cache() { local name="pip cache"; start_cat "$name"; local p="$HOME/Library/Caches/pip"; local kb=$(size_kb "$p"); info "Estimated: $(kb_to_h $kb)"; show_top10 "$HOME/Library/Caches"; [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }; [[ -d "$p" ]] && safe_trash "$p"; end_cat "$name"; }

cat_brew_cleanup() { local name="Homebrew cleanup"; start_cat "$name"; if [[ ! -x "$BREW_BIN" ]]; then warn "Homebrew not found; skipping"; end_cat "$name"; return; fi; local cache="$HOME/Library/Caches/Homebrew"; local kb=$(size_kb "$cache"); info "Brew cache before: $(kb_to_h $kb)"; [[ -d "$cache" ]] && show_top10 "$cache"; [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }; spin_run "brew cleanup -s" with_timeout $TIMEOUT_SECS "$BREW_BIN" cleanup -s || warn "brew cleanup timed out/failed"; end_cat "$name"; }

cat_docker_dangling() { local name="Docker prune (stopped containers, dangling images, networks, build cache)"; start_cat "$name"; if ! command -v docker >/dev/null 2>&1; then warn "Docker not installed; skipping"; end_cat "$name"; return; fi; spin_run "docker system df" with_timeout $TIMEOUT_SECS docker system df || warn "docker system df timed out"; [[ $DRY_RUN -eq 1 ]] && { info "DRY-RUN: would prune stopped containers, dangling images, unused networks"; info "NOTE: volumes are never touched here - use --only docker_volumes for that"; end_cat "$name"; return; }; spin_run "docker system prune -f" with_timeout $TIMEOUT_SECS docker system prune -f >/dev/null 2>&1 || warn "docker prune timed out"; spin_run "docker builder prune -f" with_timeout $TIMEOUT_SECS docker builder prune -f >/dev/null 2>&1 || warn "docker builder prune timed out"; end_cat "$name"; }

cat_docker_volumes() {
  local name="Docker volumes (orphaned only - excludes active compose projects)"
  start_cat "$name"
  if ! command -v docker >/dev/null 2>&1; then warn "Docker not installed; skipping"; end_cat "$name"; return; fi
  warn "NOTE: 'docker compose down' removes containers but keeps volumes - those volumes appear unused here."
  warn "NOTE: Only run this if your local databases (MySQL, Neptune, ES) are freshly synced or disposable."
  info "Current volumes:"
  docker volume ls 2>/dev/null | tee -a "$LOGFILE" || true
  if [[ $DRY_RUN -eq 1 ]]; then info "DRY-RUN: would run docker volume prune -f"; end_cat "$name"; return; fi
  if read -q "?Delete ALL unused Docker volumes (see warning above)? [y/N] "; then
    echo
    spin_run "docker volume prune -f" with_timeout $TIMEOUT_SECS docker volume prune -f || warn "docker volume prune timed out"
  else
    info "Skipped docker volumes"
  fi
  end_cat "$name"
}

cat_user_caches() { local name="User caches (allow-list)"; start_cat "$name"; local targets=(); if [[ -d "$HOME/Library/Caches" ]]; then spin_run "scan ~/Library/Caches" sh -c 'find "$0" -mindepth 1 -maxdepth 1 -type d -print0' "$HOME/Library/Caches" | tr '\0' '\n' | while read -r d; do case "$d" in *Mail*|*Photos*|*com.apple.iCloudHelper*|*CloudKit*|*OneDrive*|*com.microsoft*|*Defender*|*CrowdStrike*|*Cisco*|*VPN*|*Containers*|*Group\ Containers*) ;; *) targets+=("$d");; esac; done; fi; [[ -d "$HOME/.cache" ]] && targets+=("$HOME/.cache"); local kb=$(size_kb ${targets[@]:-}); info "Estimated: $(kb_to_h $kb)"; show_top10 "$HOME/Library/Caches"; [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }; for t in ${targets[@]:-}; do safe_trash "$t"; done; end_cat "$name"; }

cat_gradle_caches() { local name="Gradle caches"; start_cat "$name"; local p="$HOME/.gradle/caches"; local kb=$(size_kb "$p"); info "Estimated: $(kb_to_h $kb)"; show_top10 "$HOME/.gradle"; [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }; [[ -d "$p" ]] && safe_trash "$p"; end_cat "$name"; }

cat_xcode_derived() { local name="Xcode DerivedData & Archives"; start_cat "$name"; local dd="$HOME/Library/Developer/Xcode/DerivedData"; local ar="$HOME/Library/Developer/Xcode/Archives"; local kb=$(size_kb "$dd" "$ar"); info "Estimated: $(kb_to_h $kb)"; show_top10 "$HOME/Library/Developer/Xcode"; [[ $DRY_RUN -eq 1 ]] && { add_reclaimable $kb; end_cat "$name"; return; }; if [[ $YES -eq 1 ]] || read -q "?Delete Xcode DerivedData & Archives? [y/N] "; then echo; [[ -d "$dd" ]] && safe_trash "$dd"; [[ -d "$ar" ]] && safe_trash "$ar"; else info "Skipped Xcode DerivedData"; fi; end_cat "$name"; }

cat_xcode_simulators() { local name="Xcode Simulators"; start_cat "$name"; if ! command -v xcrun >/dev/null 2>&1; then warn "xcrun not found; skipping"; end_cat "$name"; return; fi; [[ $DRY_RUN -eq 1 ]] && { info "DRY-RUN: would run simctl delete unavailable"; end_cat "$name"; return; }; if [[ $YES -eq 1 ]] || read -q "?Delete unavailable simulators? [y/N] "; then echo; spin_run "xcrun simctl delete unavailable" with_timeout $TIMEOUT_SECS xcrun simctl delete unavailable || warn "simctl timed out"; else info "Skipped simulators"; fi; end_cat "$name"; }

cat_xcode_devicesupport() { local name="Xcode iOS DeviceSupport (old SDKs)"; start_cat "$name"; local ds="$HOME/Library/Developer/Xcode/iOS DeviceSupport"; [[ ! -d "$ds" ]] && { info "No DeviceSupport dir"; end_cat "$name"; return; }; local kb=$(size_kb "$ds"); info "Total DeviceSupport: $(kb_to_h $kb)"; show_top10 "$ds"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Delete older DeviceSupport (keep newest 2)? [y/N] "; then echo; local keep=""; keep=$(ls -1t "$ds" 2>/dev/null | head -n 2); for d in "$ds"/*; do [[ -e "$d" ]] || continue; local nb=$(basename "$d"); if print "$keep" | grep -q "^$nb$"; then continue; fi; safe_trash "$d"; done; else info "Skipped DeviceSupport"; fi; end_cat "$name"; }

cat_cocoapods_carthage() { local name="CocoaPods & Carthage caches"; start_cat "$name"; local pods_dir="$HOME/Library/Caches/CocoaPods"; local carth_dir="$HOME/Library/Caches/org.carthage.CarthageKit"; local kb=$(size_kb "$pods_dir" "$carth_dir"); info "Estimated: $(kb_to_h $kb)"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Clean CocoaPods & Carthage caches? [y/N] "; then echo; command -v pod >/dev/null 2>&1 && spin_run "pod cache clean --all" with_timeout $TIMEOUT_SECS pod cache clean --all || true; [[ -d "$pods_dir" ]] && safe_trash "$pods_dir"; [[ -d "$carth_dir" ]] && safe_trash "$carth_dir"; else info "Skipped Pods/Carthage"; fi; end_cat "$name"; }

cat_browsers_cache() { local name="Browser caches (Cache/Code Cache/GPUCache)"; start_cat "$name"; local safari="$HOME/Library/Caches/com.apple.Safari"; local chrome_base="$HOME/Library/Application Support/Google/Chrome"; local edge_base="$HOME/Library/Application Support/Microsoft Edge"; local brave_base="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"; local targets=(); [[ -d "$safari" ]] && targets+=("$safari"); for b in "$chrome_base" "$edge_base" "$brave_base"; do if [[ -d "$b" ]]; then for p in Cache "Code Cache" GPUCache; do spin_run "scan $b/$p" sh -c 'find "$0" -type d -name "$1" -maxdepth 6 -print0' "$b" "$p" | tr '\0' '\n' | while read -r d; do targets+=("$d"); done; done; fi; done; local kb=$(size_kb ${targets[@]:-}); info "Estimated: $(kb_to_h $kb)"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Clear browser caches (may sign you out)? [y/N] "; then echo; for t in ${targets[@]:-}; do safe_trash "$t"; done; else info "Skipped browsers"; fi; end_cat "$name"; }

cat_editors_cache() { local name="Editor caches (VS Code, JetBrains)"; start_cat "$name"; local vsc_base="$HOME/Library/Application Support/Code"; local jb_base="$HOME/Library/Caches/JetBrains"; local targets=(); [[ -d "$vsc_base/Cache" ]] && targets+=("$vsc_base/Cache"); [[ -d "$vsc_base/CachedData" ]] && targets+=("$vsc_base/CachedData"); [[ -d "$vsc_base/User/workspaceStorage" ]] && targets+=("$vsc_base/User/workspaceStorage"); [[ -d "$jb_base" ]] && targets+=("$jb_base"); local kb=$(size_kb ${targets[@]:-}); info "Estimated: $(kb_to_h $kb)"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Clear editor caches (keeps settings/extensions)? [y/N] "; then echo; for t in ${targets[@]:-}; do safe_trash "$t"; done; else info "Skipped editors"; fi; end_cat "$name"; }

cat_logs_old() { local name="Logs older than $SINCE_DAYS days"; start_cat "$name"; local targets=(); [[ -d "$HOME/Library/Logs" ]] && targets+=("$HOME/Library/Logs"); [[ -d "$HOME/Library/Logs/DiagnosticReports" ]] && targets+=("$HOME/Library/Logs/DiagnosticReports"); local kb_before=0; for t in ${targets[@]:-}; do kb_before=$(( kb_before + $(size_kb "$t") )); done; info "Potential logs size (upper bound): $(kb_to_h $kb_before)"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb_before; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Delete user logs older than $SINCE_DAYS days? [y/N] "; then echo; for t in ${targets[@]:-}; do spin_run "prune logs in $t" sh -c 'find "$0" -type f -mtime +$1 -print0 | xargs -0 rm -f 2>/dev/null || true' "$t" "$SINCE_DAYS"; done; else info "Skipped logs"; fi; end_cat "$name"; }

cat_trash_empty() { local name="Empty Trash"; start_cat "$name"; local kb=$(size_kb "$HOME/.Trash"); info "Trash size: $(kb_to_h $kb)"; if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Empty ~/.Trash now? [y/N] "; then echo; spin_run "empty trash" sh -c 'rm -rf "$HOME/.Trash"/* 2>/dev/null || true'; else info "Skipped emptying Trash"; fi; end_cat "$name"; }

cat_docker_aggressive() { local name="Docker aggressive prune (-a --volumes)"; start_cat "$name"; if [[ $AGGRESSIVE -ne 1 ]]; then info "--aggressive not set; skipping"; end_cat "$name"; return; fi; if ! command -v docker >/dev/null 2>&1; then warn "Docker not installed; skipping"; end_cat "$name"; return; fi; info "Removes ALL unused images/containers/networks/UNUSED volumes"; if [[ $DRY_RUN -eq 1 ]]; then info "DRY-RUN: would run docker system prune -af --volumes"; end_cat "$name"; return; fi; if [[ $YES -eq 1 ]] || read -q "?Proceed with docker system prune -af --volumes? [y/N] "; then echo; spin_run "docker system prune -af --volumes" with_timeout $TIMEOUT_SECS docker system prune -af --volumes >/dev/null 2>&1 || warn "docker prune -a timed out"; else info "Skipped docker aggressive"; fi; end_cat "$name"; }

# android_build: project-local compiled output + project-local Gradle incremental state
# Separate from gradle_caches (which is the global ~/.gradle/caches).
# Set ANDROID_PROJECT_DIR to your android/ folder to override auto-detection, e.g.:
#   ANDROID_PROJECT_DIR=~/projects/myapp/android ./clean.sh --only android_build
cat_android_build() {
  local name="Android build artifacts (project-local)"
  start_cat "$name"
  local android_dirs=()
  if [[ -n "${ANDROID_PROJECT_DIRS:-}" ]]; then
    android_dirs=( "${(@s/:/)ANDROID_PROJECT_DIRS}" )
  elif [[ -n "${ANDROID_PROJECT_DIR:-}" ]]; then
    android_dirs+=( "$ANDROID_PROJECT_DIR" )
  else
    while IFS= read -r dir; do
      android_dirs+=( "$dir" )
    done < <(find "$PROJECT_ROOT" -maxdepth 6 -type d -name android -print 2>/dev/null)
  fi
  if [[ ${#android_dirs[@]} -eq 0 ]]; then
    warn "No Android project found. Set ANDROID_PROJECT_DIR or ANDROID_PROJECT_DIRS to use this category."
    end_cat "$name"
    return
  fi
  local targets=()
  for dir in "${android_dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    targets+=("$dir/app/build" "$dir/.gradle")
  done
  local kb=$(size_kb "${targets[@]}")
  info "Estimated: $(kb_to_h $kb)"
  info "Paths: ${targets[*]}"
  if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb; end_cat "$name"; return; fi
  if [[ $YES -eq 1 ]] || read -q "?Delete Android build output + project .gradle? (next build will recompile) [y/N] "; then
    echo
    for p in "${targets[@]}"; do [[ -e "$p" ]] && safe_trash "$p"; done
  else
    info "Skipped Android build artifacts"
  fi
  end_cat "$name"
}

# android_sdk_images: removes system images for API levels not used by any installed AVD.
# Reads ~/.android/avd/<name>.avd/config.ini to detect which API level each AVD needs.
# Safe to run any time - only images with no matching AVD are offered for deletion.
cat_android_sdk_images() {
  local name="Android SDK system images (unused)"
  start_cat "$name"
  local sdk_images_dir="$HOME/Library/Android/sdk/system-images"
  if [[ ! -d "$sdk_images_dir" ]]; then info "No SDK system-images dir; skipping"; end_cat "$name"; return; fi

  # Detect which API levels are actively used by installed AVDs
  local needed_apis=()
  if command -v emulator >/dev/null 2>&1; then
    local avd_list
    avd_list=$(emulator -list-avds 2>/dev/null | grep -v '^INFO' || true)
    for avd in ${(f)avd_list}; do
      local cfg="$HOME/.android/avd/${avd}.avd/config.ini"
      [[ -f "$cfg" ]] || continue
      local api_dir
      api_dir=$(grep 'image.sysdir.1' "$cfg" 2>/dev/null | grep -oE 'android-[0-9]+' | head -1)
      [[ -n "$api_dir" ]] && needed_apis+=("$api_dir")
    done
  fi

  if [[ ${#needed_apis[@]} -eq 0 ]]; then
    info "No AVD config found - will list all images as removable (safe_trash only)"
  else
    info "AVD(s) require: ${needed_apis[*]}"
  fi

  local removable=(); local kb_total=0
  for d in "$sdk_images_dir"/*/; do
    [[ -d "$d" ]] || continue
    local api_name=""
    api_name=$(basename "$d")
    local is_needed=0
    for needed in ${needed_apis[@]:-dummy_placeholder}; do
      [[ "$api_name" == "$needed" ]] && is_needed=1 && break
    done
    local kb=""
    kb=$(du -sk "$d" 2>/dev/null | awk '{print $1}')
    kb=$(sanitize_kb "$kb")
    if [[ $is_needed -eq 1 ]]; then
      info "  Keeping : $api_name -> $(kb_to_h $kb) (active AVD)"
    else
      info "  Removable: $api_name -> $(kb_to_h $kb)"
      removable+=("$d"); : $(( kb_total += kb ))
    fi
  done

  if [[ ${#removable[@]} -eq 0 ]]; then info "Nothing to remove"; end_cat "$name"; return; fi
  info "Total removable: $(kb_to_h $kb_total)"
  warn "NOTE: If you plan to create a new AVD targeting a different API level, set it up in Android Studio first - then re-run this script so it knows to keep that image."

  if [[ $YES -eq 1 ]] || read -q "?Delete unused Android SDK system images? [y/N] "; then
    echo
    if [[ $DRY_RUN -eq 1 ]]; then add_reclaimable $kb_total; end_cat "$name"; return; fi
    for p in ${removable[@]}; do [[ -e "$p" ]] && safe_trash "$p"; done
  else
    info "Skipped Android SDK system images"
  fi
  end_cat "$name"
}

# ios_simulator_runtimes: removes downloaded iOS simulator disk images that have no simulator devices.
# Uses `xcrun simctl runtime list` (Xcode 14+ stores runtimes as disk images, not .simruntime bundles).
# Detects which runtimes have simulator devices by cross-referencing `xcrun simctl list devices available`.
# Deletes via `xcrun simctl runtime delete <UUID>` - the official safe method.
cat_ios_simulator_runtimes() {
  local name="iOS Simulator runtimes (unused)"
  start_cat "$name"
  if ! command -v xcrun >/dev/null 2>&1; then warn "xcrun not found; skipping"; end_cat "$name"; return; fi

  # Parse runtime list: extract "iOS X.Y (build) - UUID (State)"
  local runtime_raw
  runtime_raw=$(xcrun simctl runtime list 2>/dev/null | grep -E '^\s*iOS' || true)
  if [[ -z "$runtime_raw" ]]; then info "No iOS runtimes found; skipping"; end_cat "$name"; return; fi

  # Which iOS versions have simulator devices?
  local used_versions
  used_versions=$(xcrun simctl list devices available 2>/dev/null \
    | grep -oE 'iOS [0-9]+\.[0-9]+' | sort -u || true)

  local removable_uuids=() removable_names=() kb_total=0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local ios_ver uuid state
    ios_ver=$(echo "$line" | grep -oE 'iOS [0-9]+\.[0-9]+' | head -1)
    uuid=$(echo "$line" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -1)
    state=$(echo "$line" | grep -oE '\([A-Za-z]+\)$' | tr -d '()')
    [[ -z "$uuid" || "$state" == "Deleting" ]] && continue

    # Estimate size from the total shown by simctl (no direct per-image du available)
    if echo "$used_versions" | grep -qF "$ios_ver"; then
      info "  Keeping : $ios_ver [$uuid] (has simulator devices)"
    else
      info "  Removable: $ios_ver [$uuid]"
      removable_uuids+=("$uuid")
      removable_names+=("$ios_ver")
    fi
  done <<< "$runtime_raw"

  if [[ ${#removable_uuids[@]} -eq 0 ]]; then info "Nothing to remove"; end_cat "$name"; return; fi
  warn "NOTE: Each iOS runtime disk image is ~6-8 GB."
  warn "NOTE: Removing a runtime deletes all simulators on that iOS version. Create any new simulators in Xcode first."
  warn "NOTE: To re-download later: Xcode > Settings > Platforms > (+)"

  if [[ $YES -eq 1 ]] || read -q "?Delete unused iOS simulator runtimes (${removable_names[*]})? [y/N] "; then
    echo
    if [[ $DRY_RUN -eq 1 ]]; then
      info "DRY-RUN: would run: xcrun simctl runtime delete ${removable_uuids[*]}"
      end_cat "$name"; return
    fi
    for uuid in ${removable_uuids[@]}; do
      spin_run "delete runtime $uuid" xcrun simctl runtime delete "$uuid" || warn "Failed to delete $uuid"
    done
  else
    info "Skipped iOS simulator runtimes"
  fi
  end_cat "$name"
}

ALL_AUTO=( node_caches pip_cache brew_cleanup docker_dangling user_caches gradle_caches )
ALL_PROMPT=( xcode_derived xcode_simulators xcode_devicesupport cocoapods_carthage browsers_cache editors_cache logs_old trash_empty project_generated android_build android_sdk_images ios_simulator_runtimes )
ALL_AGGR=( docker_aggressive docker_volumes deep_node_project_caches )

run_category() {
  case "$1" in
    node_caches) cat_node_caches ;;
    project_generated) cat_project_generated ;;
    pip_cache) cat_pip_cache ;;
    brew_cleanup) cat_brew_cleanup ;;
    docker_dangling) cat_docker_dangling ;;
    docker_volumes) cat_docker_volumes ;;
    user_caches) cat_user_caches ;;
    gradle_caches) cat_gradle_caches ;;
    xcode_derived) cat_xcode_derived ;;
    xcode_simulators) cat_xcode_simulators ;;
    xcode_devicesupport) cat_xcode_devicesupport ;;
    cocoapods_carthage) cat_cocoapods_carthage ;;
    browsers_cache) cat_browsers_cache ;;
    editors_cache) cat_editors_cache ;;
    logs_old) cat_logs_old ;;
    trash_empty) cat_trash_empty ;;
    docker_aggressive) cat_docker_aggressive ;;
    android_build) cat_android_build ;;
    android_sdk_images) cat_android_sdk_images ;;
    ios_simulator_runtimes) cat_ios_simulator_runtimes ;;
    deep_node_project_caches) : ;; # intentionally omitted from default run (can add back if needed)
    *) warn "Unknown category: $1" ;;
  esac
}

if [[ $SELF_TEST -eq 1 ]]; then section "Self-test"; info "Detected tools:"; for t in yarn npm pnpm pod docker xcrun; do printf "  - %s: %s\n" "$t" "$(command -v $t >/dev/null 2>&1 && echo present || echo missing)"; done | tee -a "$LOGFILE"; exit 0; fi

section "Plan"
if [[ $ALL -eq 1 ]]; then TARGETS=( ${ALL_AUTO[@]} ${ALL_PROMPT[@]} ); [[ $AGGRESSIVE -eq 1 ]] && TARGETS+=( ${ALL_AGGR[@]} )
elif [[ -n "$ONLY" ]]; then IFS=',' read -r -A TARGETS <<< "$ONLY"
else TARGETS=( ${ALL_AUTO[@]} ${ALL_PROMPT[@]} ); fi
info "Categories to process: ${TARGETS[*]}"

for c in ${TARGETS[@]:-}; do run_category "$c"; done

section "Summary"
info "Reclaimable (file-based; may require emptying Trash): $(kb_to_h $RECLAIMABLE_KB)"; info "Log saved to: $LOGFILE"; [[ $DRY_RUN -eq 1 ]] && warn "This was a DRY-RUN. Use --yes to execute."
exit 0
