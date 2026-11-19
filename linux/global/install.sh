#!/usr/bin/env bash
# Syed Ishaq B. | ishaqzafar.com
# claude-ready global installer for Linux.
# Copies the files under home/_USER_/ into your home directory.
# Existing files that differ are backed up as <file>.bak.<timestamp> first.
# Usage: ./install.sh            install
#        ./install.sh --dry-run  show what would happen, change nothing
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
src="$here/home/_USER_"
dry=0
[ "${1:-}" = "--dry-run" ] && dry=1
stamp="$(date +%Y%m%d-%H%M%S)"
settings_backed_up=0

copy() {
  local from="$1" to="$2"
  if [ "$dry" -eq 1 ]; then
    echo "would install: $to"
    return
  fi
  mkdir -p "$(dirname "$to")"
  if [ -e "$to" ] && ! cmp -s "$from" "$to"; then
    cp "$to" "$to.bak.$stamp"
    echo "backed up:  $to -> $to.bak.$stamp"
    case "$to" in */settings.json) settings_backed_up=1 ;; esac
  fi
  cp "$from" "$to"
  echo "installed:  $to"
}

copy "$src/.claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
copy "$src/.claude/AGENTS.md"     "$HOME/.claude/AGENTS.md"
copy "$src/.claude/settings.json" "$HOME/.claude/settings.json"
copy "$src/.codex/AGENTS.md"      "$HOME/.codex/AGENTS.md"
for hook in "$src"/.claude/hooks/*.sh; do
  copy "$hook" "$HOME/.claude/hooks/$(basename "$hook")"
  [ "$dry" -eq 1 ] || chmod +x "$HOME/.claude/hooks/$(basename "$hook")"
done

if ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  echo "warning: neither jq nor python3 found. The hooks need one of them and will allow every call until you install one."
fi
if [ "$settings_backed_up" -eq 1 ]; then
  echo "note: your previous settings.json was replaced. Copy any keys you still need from the .bak file into ~/.claude/settings.json."
fi
echo "done. Start a new Claude Code session and run /hooks to confirm the two hooks are listed."

# sig: U3llZCBJc2hhcSBCLiB8IGlzaGFxemFmYXIuY29t
