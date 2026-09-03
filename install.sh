#!/bin/sh
# Ironworks — Cross-platform skill installer
# https://github.com/RahulHulsure/-Ironworks
# License: MIT · (c) 2026 Rahul Hulsure
#
# Usage:
#   ./install.sh                        # auto-detect platforms, project install
#   ./install.sh --platform claude      # install for Claude only
#   ./install.sh --platform all         # install for all detected platforms
#   ./install.sh --global               # install to home directory
#   ./install.sh --uninstall            # remove installed files
#   ./install.sh --help                 # show help

set -e

# ---------------------------------------------------------------------------
# Resolve repo root from script location
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORMS_DIR="$SCRIPT_DIR/platforms"
SKILLS_DIR="$SCRIPT_DIR/.openclaw/skills"

# ---------------------------------------------------------------------------
# Colors (disabled when stdout is not a terminal)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' YELLOW='' RED='' CYAN='' BOLD='' RESET=''
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { printf "${CYAN}[info]${RESET}  %s\n" "$*"; }
ok()      { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
skip()    { printf "${YELLOW}[skip]${RESET}  %s\n" "$*"; }
err()     { printf "${RED}[err]${RESET}   %s\n" "$*" >&2; }
heading() { printf "\n${BOLD}%s${RESET}\n" "$*"; }

INSTALLED=0
SKIPPED=0
ERRORS=0

record_ok()   { INSTALLED=$((INSTALLED + 1)); ok "$*"; }
record_skip() { SKIPPED=$((SKIPPED + 1));     skip "$*"; }
record_err()  { ERRORS=$((ERRORS + 1));       err "$*"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<'EOF'
Ironworks Skill Installer

Usage:
  install.sh [options]

Options:
  --platform <name>   Install for a specific platform (or "all")
  --global            Install to home directory (where supported)
  --project           Install to current project directory (default)
  --uninstall         Remove previously installed files
  --list              List supported platforms and exit
  --dry-run           Show what would be done without writing files
  --help              Show this help message

Supported platforms:
  claude, cursor, copilot, windsurf, cline, gemini, codex, aider,
  amazon-q, kiro, roo, continue, junie, trae, augment, kilo, antigravity

Examples:
  ./install.sh                          # auto-detect, project install
  ./install.sh --platform cursor        # cursor only
  ./install.sh --platform all --global  # all detected, global install
  ./install.sh --uninstall              # remove installed files
EOF
    exit 0
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
TARGET_PLATFORM=""
SCOPE="project"   # project | global
UNINSTALL=0
DRY_RUN=0

while [ $# -gt 0 ]; do
    case "$1" in
        --platform)
            shift
            [ $# -eq 0 ] && { err "--platform requires a value"; exit 1; }
            TARGET_PLATFORM="$1"
            ;;
        --global)  SCOPE="global" ;;
        --project) SCOPE="project" ;;
        --uninstall) UNINSTALL=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --list)
            echo "Supported platforms:"
            echo "  claude  cursor  copilot  windsurf  cline  gemini  codex  aider"
            echo "  amazon-q  kiro  roo  continue  junie  trae  augment  kilo  antigravity"
            exit 0
            ;;
        --help|-h) usage ;;
        *)
            err "Unknown option: $1"
            echo "Run install.sh --help for usage."
            exit 1
            ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------
cmd_exists() { command -v "$1" >/dev/null 2>&1; }
dir_exists() { [ -d "$1" ]; }

detect_claude()      { cmd_exists claude; }
detect_cursor()      { dir_exists ".cursor" || dir_exists "$HOME/.cursor"; }
detect_copilot()     { dir_exists ".github"; }
detect_windsurf()    { dir_exists ".windsurf" || dir_exists "$HOME/.windsurf"; }
detect_cline()       { dir_exists ".cline" || dir_exists "$HOME/.cline" || dir_exists ".clinerules"; }
detect_gemini()      { cmd_exists gemini || dir_exists "$HOME/.gemini"; }
detect_codex()       { cmd_exists codex; }
detect_aider()       { cmd_exists aider; }
detect_amazon_q()    { dir_exists ".amazonq" || dir_exists "$HOME/.amazonq"; }
detect_kiro()        { dir_exists ".kiro" || dir_exists "$HOME/.kiro"; }
detect_roo()         { dir_exists ".roo" || dir_exists "$HOME/.roo"; }
detect_continue()    { dir_exists ".continue" || dir_exists "$HOME/.continue"; }
detect_junie()       { dir_exists ".junie"; }
detect_trae()        { dir_exists ".trae" || dir_exists "$HOME/.trae"; }
detect_augment()     { dir_exists ".augment" || dir_exists "$HOME/.augment" || [ -f ".augment-guidelines" ]; }
detect_kilo()        { dir_exists ".kilo" || dir_exists "$HOME/.kilo"; }
detect_antigravity() { dir_exists ".agent" || dir_exists "$HOME/.agent"; }

ALL_PLATFORMS="claude cursor copilot windsurf cline gemini codex aider amazon-q kiro roo continue junie trae augment kilo antigravity"

detect_platform() {
    _p="$1"
    case "$_p" in
        claude)      detect_claude ;;
        cursor)      detect_cursor ;;
        copilot)     detect_copilot ;;
        windsurf)    detect_windsurf ;;
        cline)       detect_cline ;;
        gemini)      detect_gemini ;;
        codex)       detect_codex ;;
        aider)       detect_aider ;;
        amazon-q)    detect_amazon_q ;;
        kiro)        detect_kiro ;;
        roo)         detect_roo ;;
        continue)    detect_continue ;;
        junie)       detect_junie ;;
        trae)        detect_trae ;;
        augment)     detect_augment ;;
        kilo)        detect_kilo ;;
        antigravity) detect_antigravity ;;
        *) return 1 ;;
    esac
}

# Build list of platforms to process
TARGETS=""
if [ -n "$TARGET_PLATFORM" ]; then
    if [ "$TARGET_PLATFORM" = "all" ]; then
        for p in $ALL_PLATFORMS; do
            if detect_platform "$p"; then
                TARGETS="$TARGETS $p"
            fi
        done
        TARGETS="$(echo "$TARGETS" | sed 's/^ //')"
        if [ -z "$TARGETS" ]; then
            err "No platforms detected. Use --platform <name> to install for a specific platform."
            exit 1
        fi
    else
        # validate platform name
        _valid=0
        for p in $ALL_PLATFORMS; do
            if [ "$p" = "$TARGET_PLATFORM" ]; then _valid=1; break; fi
        done
        if [ "$_valid" -eq 0 ]; then
            err "Unknown platform: $TARGET_PLATFORM"
            echo "Run install.sh --list for supported platforms."
            exit 1
        fi
        TARGETS="$TARGET_PLATFORM"
    fi
else
    # auto-detect
    for p in $ALL_PLATFORMS; do
        if detect_platform "$p"; then
            TARGETS="$TARGETS $p"
        fi
    done
    TARGETS="$(echo "$TARGETS" | sed 's/^ //')"
    if [ -z "$TARGETS" ]; then
        err "No platforms detected. Use --platform <name> to install for a specific platform."
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# File operations
# ---------------------------------------------------------------------------
ensure_dir() {
    if [ "$DRY_RUN" -eq 1 ]; then
        return 0
    fi
    mkdir -p "$1"
}

copy_file() {
    _src="$1"
    _dst="$2"
    if [ ! -f "$_src" ]; then
        record_err "Source not found: $_src"
        return 1
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        record_ok "[dry-run] Would copy $(basename "$_src") -> $_dst"
        return 0
    fi
    ensure_dir "$(dirname "$_dst")"
    cp "$_src" "$_dst"
    record_ok "Copied $(basename "$_src") -> $_dst"
}

copy_dir() {
    _src="$1"
    _dst="$2"
    if [ ! -d "$_src" ]; then
        record_err "Source directory not found: $_src"
        return 1
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        record_ok "[dry-run] Would copy directory $(basename "$_src") -> $_dst"
        return 0
    fi
    ensure_dir "$_dst"
    cp -r "$_src"/. "$_dst"/
    record_ok "Copied directory $(basename "$_src") -> $_dst"
}

remove_file() {
    _target="$1"
    if [ ! -e "$_target" ]; then
        record_skip "Not found (already clean): $_target"
        return 0
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        record_ok "[dry-run] Would remove $_target"
        return 0
    fi
    if [ -d "$_target" ]; then
        rm -rf "$_target"
    else
        rm -f "$_target"
    fi
    record_ok "Removed $_target"
}

# ---------------------------------------------------------------------------
# Per-platform install/uninstall logic
# ---------------------------------------------------------------------------
# Each function receives no args; reads SCOPE to decide project vs global.

portable_file="$PLATFORMS_DIR/ironworks-portable.md"

install_claude() {
    if [ "$SCOPE" = "global" ]; then
        _dst="$HOME/.claude/skills"
    else
        _dst=".openclaw/skills"
    fi
    if [ -d "$SKILLS_DIR" ]; then
        for skill_dir in "$SKILLS_DIR"/*/; do
            [ -d "$skill_dir" ] || continue
            _name="$(basename "$skill_dir")"
            copy_dir "$skill_dir" "$_dst/$_name"
        done
    else
        record_err "Skills directory not found: $SKILLS_DIR"
    fi
}

uninstall_claude() {
    if [ "$SCOPE" = "global" ]; then
        _dst="$HOME/.claude/skills"
    else
        _dst=".openclaw/skills"
    fi
    for skill_dir in "$SKILLS_DIR"/*/; do
        [ -d "$skill_dir" ] || continue
        _name="$(basename "$skill_dir")"
        remove_file "$_dst/$_name"
    done
}

install_cursor() {
    _src="$PLATFORMS_DIR/cursor/rules/ironworks-discipline.mdc"
    if [ "$SCOPE" = "global" ]; then
        _dst="$HOME/.cursor/rules/ironworks-discipline.mdc"
    else
        _dst=".cursor/rules/ironworks-discipline.mdc"
    fi
    copy_file "$_src" "$_dst"
}

uninstall_cursor() {
    if [ "$SCOPE" = "global" ]; then
        remove_file "$HOME/.cursor/rules/ironworks-discipline.mdc"
    else
        remove_file ".cursor/rules/ironworks-discipline.mdc"
    fi
}

install_copilot() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Copilot: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".github/copilot-instructions.md"
}

uninstall_copilot() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".github/copilot-instructions.md"
}

install_windsurf() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Windsurf: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".windsurf/rules/ironworks.md"
}

uninstall_windsurf() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".windsurf/rules/ironworks.md"
}

install_cline() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Cline: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".clinerules/ironworks.md"
}

uninstall_cline() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".clinerules/ironworks.md"
}

install_gemini() {
    if [ "$SCOPE" = "global" ]; then
        copy_file "$portable_file" "$HOME/.gemini/GEMINI.md"
    else
        copy_file "$portable_file" "GEMINI.md"
    fi
}

uninstall_gemini() {
    if [ "$SCOPE" = "global" ]; then
        remove_file "$HOME/.gemini/GEMINI.md"
    else
        remove_file "GEMINI.md"
    fi
}

install_codex() {
    if [ "$SCOPE" = "global" ]; then
        copy_file "$portable_file" "$HOME/.codex/AGENTS.md"
    else
        copy_file "$portable_file" "AGENTS.md"
    fi
}

uninstall_codex() {
    if [ "$SCOPE" = "global" ]; then
        remove_file "$HOME/.codex/AGENTS.md"
    else
        remove_file "AGENTS.md"
    fi
}

install_aider() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Aider: global install not supported"
        return 0
    fi
    copy_file "$portable_file" "CONVENTIONS.md"
}

uninstall_aider() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file "CONVENTIONS.md"
}

install_amazon_q() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Amazon Q: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".amazonq/rules/ironworks.md"
}

uninstall_amazon_q() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".amazonq/rules/ironworks.md"
}

install_kiro() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Kiro: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".kiro/steering/ironworks.md"
}

uninstall_kiro() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".kiro/steering/ironworks.md"
}

install_roo() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Roo: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".roo/rules/ironworks.md"
}

uninstall_roo() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".roo/rules/ironworks.md"
}

install_continue() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Continue: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".continuerules"
}

uninstall_continue() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".continuerules"
}

install_junie() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Junie: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".junie/guidelines.md"
}

uninstall_junie() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".junie/guidelines.md"
}

install_trae() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Trae: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".trae/rules/ironworks.md"
}

uninstall_trae() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".trae/rules/ironworks.md"
}

install_augment() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Augment: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".augment-guidelines"
}

uninstall_augment() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".augment-guidelines"
}

install_kilo() {
    if [ "$SCOPE" = "global" ]; then
        record_skip "Kilo: global install not supported"
        return 0
    fi
    copy_file "$portable_file" ".kilo/rules/ironworks.md"
}

uninstall_kilo() {
    if [ "$SCOPE" = "global" ]; then return 0; fi
    remove_file ".kilo/rules/ironworks.md"
}

install_antigravity() {
    if [ "$SCOPE" = "global" ]; then
        _dst="$HOME/.gemini/antigravity/skills"
    else
        _dst=".agent/skills"
    fi
    if [ -d "$SKILLS_DIR" ]; then
        for skill_dir in "$SKILLS_DIR"/*/; do
            [ -d "$skill_dir" ] || continue
            _name="$(basename "$skill_dir")"
            copy_dir "$skill_dir" "$_dst/$_name"
        done
    else
        copy_file "$portable_file" "$_dst/ironworks.md"
    fi
}

uninstall_antigravity() {
    if [ "$SCOPE" = "global" ]; then
        remove_file "$HOME/.gemini/antigravity/skills"
    else
        remove_file ".agent/skills"
    fi
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
dispatch() {
    _platform="$1"
    _action="$2"   # install | uninstall
    # normalize name for function lookup (amazon-q -> amazon_q)
    _func_name="$(echo "$_platform" | tr '-' '_')"
    eval "${_action}_${_func_name}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
heading "Ironworks Skill Installer"
if [ "$DRY_RUN" -eq 1 ]; then
    info "Dry-run mode — no files will be written"
fi
info "Scope: $SCOPE"
info "Platforms: $TARGETS"

if [ "$UNINSTALL" -eq 1 ]; then
    _action="uninstall"
    heading "Uninstalling..."
else
    _action="install"
    heading "Installing..."
fi

for platform in $TARGETS; do
    info "--- $platform ---"
    dispatch "$platform" "$_action"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
heading "Summary"
printf "  ${GREEN}Installed/Removed: %d${RESET}\n" "$INSTALLED"
printf "  ${YELLOW}Skipped:           %d${RESET}\n" "$SKIPPED"
printf "  ${RED}Errors:            %d${RESET}\n" "$ERRORS"

if [ "$ERRORS" -gt 0 ]; then
    exit 1
fi
exit 0
