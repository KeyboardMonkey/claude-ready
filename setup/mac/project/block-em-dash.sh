#!/usr/bin/env bash
# claude-ready hook: block-em-dash
# PreToolUse hook. Blocks the call when the text it would write contains an em
# dash (U+2014) and tells Claude why, so it rewrites the text.
#   Write, Edit, MultiEdit, NotebookEdit: checks the new text.
#   Bash: checks the whole command, which covers heredocs, redirects, sed -i,
#         inline scripts and commit messages. To search for an em dash, write
#         it escaped, for example grep -rn $'\xe2\x80\x94' .
#   GitHub/GitLab MCP tools: checks every input field (file content, PR and
#         issue bodies, comments).
# Bypass for one shell session: export CLAUDE_ALLOW_EM_DASH=1
# Needs jq or python3 to read the hook input; without either it allows the call.
set -u
[ "${CLAUDE_ALLOW_EM_DASH:-0}" = "1" ] && exit 0
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  text="$(printf '%s' "$input" | jq -r '
    (.tool_name // "") as $t | (.tool_input // {}) as $i |
    if ($t | test("^(Write|Edit|MultiEdit|NotebookEdit)$")) then
      [$i.content?, $i.new_string?, $i.new_source?, ($i.edits[]?.new_string)]
      | map(select(type == "string")) | join("\n")
    elif $t == "Bash" then ($i.command // "")
    else ($i | tostring) end' 2>/dev/null)" || exit 0
elif command -v python3 >/dev/null 2>&1; then
  text="$(printf '%s' "$input" | python3 -c '
import json, sys
d = json.load(sys.stdin)
t, i = d.get("tool_name", ""), d.get("tool_input") or {}
if t in ("Write", "Edit", "MultiEdit", "NotebookEdit"):
    parts = [i.get("content"), i.get("new_string"), i.get("new_source")]
    parts += [e.get("new_string") for e in (i.get("edits") or [])]
    print("\n".join(p for p in parts if isinstance(p, str)))
elif t == "Bash":
    print(i.get("command", ""))
else:
    print(json.dumps(i, ensure_ascii=False))
' 2>/dev/null)" || exit 0
else
  exit 0
fi
if printf '%s' "$text" | grep -qF $'\xe2\x80\x94'; then
  echo "Blocked by claude-ready: the text contains an em dash (U+2014). Rewrite it with a comma, colon, parentheses or a new sentence, then retry. In a shell search, write the character escaped, for example \$'\\xe2\\x80\\x94'." >&2
  exit 2
fi
exit 0
