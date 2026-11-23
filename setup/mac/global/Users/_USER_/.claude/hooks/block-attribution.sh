#!/usr/bin/env bash
# claude-ready hook: block-attribution
# PreToolUse hook for Bash and GitHub/GitLab MCP tools. Blocks:
#   1. git and gh commands, and MCP calls, whose text carries AI attribution:
#      Co-Authored-By trailers naming an AI, session trailers or links,
#      "Generated with ..." footers. Message files passed with -F, --file or
#      --body-file are read too.
#   2. git commands that create commits (commit, merge, revert, cherry-pick)
#      when the author or committer email is not a GitHub noreply address
#      (<id>+<user>@users.noreply.github.com).
#      Bypass for one shell session: export CLAUDE_ALLOW_ANY_EMAIL=1
# Needs jq or python3 to read the hook input; without either it scans the raw input.
set -u
input="$(cat)"
tool=""; cmd=""; cwd=""
if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null)"
  cmd="$(printf '%s' "$input" | python3 -c 'import json,sys; print((json.load(sys.stdin).get("tool_input") or {}).get("command",""))' 2>/dev/null)"
  cwd="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"
fi

unquote() { local s="$1"; s="${s#\"}"; s="${s%\"}"; s="${s#\'}"; s="${s%\'}"; printf '%s' "$s"; }
resolve() { # path base
  case "$1" in "~/"*) printf '%s' "$HOME/${1#\~/}" ;; /*) printf '%s' "$1" ;; *) if [ -n "$2" ]; then printf '%s' "$2/$1"; else printf '%s' "$1"; fi ;; esac
}

if [ "$tool" = "Bash" ]; then
  # git with optional global options (-C dir, -c key=value, --no-pager ...) before the subcommand
  gitpre='(^|[;&|(`[:space:]])git([[:space:]]+(-[cC][[:space:]]+[^[:space:]]+|--?[a-zA-Z-]+(=[^[:space:]]+)?))*'
  ghcmd='(^|[;&|(`[:space:]])gh[[:space:]]+(pr|issue|release|api|gist)'
  printf '%s' "$cmd" | grep -Eq "$gitpre[[:space:]]+(commit|tag|notes|merge|revert|cherry-pick)|$ghcmd" || exit 0
  text="$cmd"

  # Working directory of the git command: a leading "cd dir &&", then "git -C dir"
  dir="$cwd"
  d="$(printf '%s' "$cmd" | grep -oE '(^|[;&|][[:space:]]*)cd[[:space:]]+("[^"]*"|[^[:space:];&|]+)' | tail -1 | sed -E 's/^.*cd[[:space:]]+//')"
  [ -n "$d" ] && dir="$(resolve "$(unquote "$d")" "$dir")"
  d="$(printf '%s' "$cmd" | grep -oE 'git([[:space:]]+-c[[:space:]]+[^[:space:]]+)*[[:space:]]+-C[[:space:]]+("[^"]*"|[^[:space:]]+)' | tail -1 | sed -E 's/.*-C[[:space:]]+//')"
  [ -n "$d" ] && dir="$(resolve "$(unquote "$d")" "$dir")"

  # 1. Append the contents of message files: -F f, -Ff, --file f, --file=f, --body-file f, --notes-file f
  while IFS= read -r f; do
    f="$(unquote "$f")"
    { [ -z "$f" ] || [ "$f" = "-" ]; } && continue
    f="$(resolve "$f" "$dir")"
    [ -f "$f" ] && text="$text
$(head -c 200000 "$f" 2>/dev/null)"
  done < <(printf '%s' "$cmd" | grep -oE '(^|[[:space:]])(-F[[:space:]]*|--(body-|notes-)?file(=|[[:space:]]+))("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:];&|)]+)' \
             | sed -E 's/^[[:space:]]*(-F[[:space:]]*|--(body-|notes-)?file(=|[[:space:]]+))//')

  # 2. Commit identity: every author and committer email must be a GitHub noreply address
  if [ "${CLAUDE_ALLOW_ANY_EMAIL:-0}" != "1" ] && command -v git >/dev/null 2>&1 \
     && printf '%s' "$cmd" | grep -Eq "$gitpre[[:space:]]+(commit|merge|revert|cherry-pick)([[:space:]]|$)"; then
    e="$(printf '%s' "$cmd" | grep -oE -- '-c[[:space:]]+user\.email=("[^"]*"|[^[:space:];&|]+)' | tail -1 | sed -E 's/.*user\.email=//')"
    if [ -n "$e" ]; then e="$(unquote "$e")"; else e="$(git -C "${dir:-.}" config user.email 2>/dev/null)"; fi
    emails="$e
$(printf '%s' "$cmd" | grep -oE -- '--author[= ]("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]+)' | grep -oE '<[^>]*>' | tr -d '<>')
$(printf '%s' "$cmd" | grep -oE 'GIT_(AUTHOR|COMMITTER)_EMAIL=("[^"]*"|[^[:space:];&|]+)' | sed -E 's/^[^=]*=//' | tr -d '"')
${GIT_AUTHOR_EMAIL:-}
${GIT_COMMITTER_EMAIL:-}"
    bad="$(printf '%s\n' "$emails" | sed '/^[[:space:]]*$/d' | grep -viE '@users\.noreply\.github\.com$' | head -1)"
    if [ -n "$bad" ]; then
      echo "Blocked by claude-ready: this commit would use the email '$bad'. Commit only with your GitHub noreply address, for example: git config user.email '<id>+<user>@users.noreply.github.com'. For a repository that needs another address, bypass for one session with CLAUDE_ALLOW_ANY_EMAIL=1." >&2
      exit 2
    fi
  fi
else
  text="$input"
fi

pattern='co-authored-by:.{0,80}(claude|anthropic|copilot|codex|openai|gemini|cursor)|generated (with|by) \[?(claude|codex|copilot|cursor|gemini)|claude-session:|claude\.ai/code/session|noreply@anthropic\.com'
if printf '%s' "$text" | grep -Eiq "$pattern"; then
  echo "Blocked by claude-ready: this command, its message file or its message carries AI attribution (Co-Authored-By trailer, session link or 'Generated with' footer). Remove it and retry." >&2
  exit 2
fi
exit 0
