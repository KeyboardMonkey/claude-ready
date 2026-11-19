#!/usr/bin/env bash
# claude-ready hook: block-attribution
# PreToolUse hook for Bash and GitHub/GitLab MCP tools. Blocks git and gh
# commands, and MCP calls, whose text carries AI attribution: Co-Authored-By
# trailers naming an AI, session trailers or links, "Generated with ..." footers.
# Needs jq or python3 to read the hook input; without either it scans the raw input.
set -u
input="$(cat)"
tool=""; cmd=""
if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null)"
  cmd="$(printf '%s' "$input" | python3 -c 'import json,sys; print((json.load(sys.stdin).get("tool_input") or {}).get("command",""))' 2>/dev/null)"
fi
if [ "$tool" = "Bash" ]; then
  printf '%s' "$cmd" | grep -Eq '(^|[;&|(`[:space:]])(git[[:space:]]+(commit|tag|notes|merge)|gh[[:space:]]+(pr|issue|release|api))' || exit 0
  text="$cmd"
else
  text="$input"
fi
pattern='co-authored-by:.{0,80}(claude|anthropic|copilot|codex|openai|gemini|cursor)|generated (with|by) \[?(claude|codex|copilot|cursor|gemini)|claude-session:|claude\.ai/code/session|noreply@anthropic\.com'
if printf '%s' "$text" | grep -Eiq "$pattern"; then
  echo "Blocked by claude-ready: this command or message carries AI attribution (Co-Authored-By trailer, session link or 'Generated with' footer). Remove it and retry." >&2
  exit 2
fi
exit 0
