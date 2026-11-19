#!/usr/bin/env bash
# claude-ready hook: block-em-dash
# PreToolUse hook for Write, Edit and MultiEdit. Blocks the call when the new
# text contains an em dash (U+2014) and tells Claude why, so it rewrites the text.
# Bypass for one shell session: export CLAUDE_ALLOW_EM_DASH=1
# Needs jq or python3 to read the hook input; without either it allows the call.
set -u
[ "${CLAUDE_ALLOW_EM_DASH:-0}" = "1" ] && exit 0
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  text="$(printf '%s' "$input" | jq -r '[.tool_input.content?, .tool_input.new_string?, (.tool_input.edits[]?.new_string)] | map(select(. != null)) | join("\n")' 2>/dev/null)" || exit 0
elif command -v python3 >/dev/null 2>&1; then
  text="$(printf '%s' "$input" | python3 -c '
import json, sys
t = json.load(sys.stdin).get("tool_input", {}) or {}
parts = [t.get("content"), t.get("new_string")] + [e.get("new_string") for e in (t.get("edits") or [])]
print("\n".join(p for p in parts if isinstance(p, str)))
' 2>/dev/null)" || exit 0
else
  exit 0
fi
if printf '%s' "$text" | grep -qF $'\xe2\x80\x94'; then
  echo "Blocked by claude-ready: the new text contains an em dash (U+2014). Rewrite it with a comma, colon, parentheses or a new sentence, then retry." >&2
  exit 2
fi
exit 0
