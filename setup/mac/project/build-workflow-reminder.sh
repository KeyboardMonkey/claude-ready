#!/usr/bin/env bash
# claude-ready hook: build-workflow-reminder
# UserPromptSubmit hook. When a prompt looks like a request to build an app or
# automation, it adds a short reminder of the build workflow (AGENTS.md section 10)
# to Claude's context. It never blocks the prompt.
# If docs/spec/spec.md already exists, it adds a one-line pointer instead.
# Turn off for one shell session: export CLAUDE_SKIP_BUILD_REMINDER=1
set -u
[ "${CLAUDE_SKIP_BUILD_REMINDER:-0}" = "1" ] && exit 0
input="$(cat)"
prompt=""; cwd=""
if command -v jq >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)"
  cwd="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"
else
  exit 0
fi
verbs='build|create|make|develop|scaffold|prototype|design|start|spin up|set up|automate'
things='app|apps|application|automation|workflow|tool|dashboard|bot|website|site|web app|service|api|extension|plugin|agent|n8n|saas|mvp'
printf '%s' "$prompt" | grep -Eiq "(^|[^a-z])($verbs)([^a-z].{0,60})?[^a-z]($things)([^a-z]|$)" || exit 0
if [ -n "$cwd" ] && [ -f "$cwd/docs/spec/spec.md" ]; then
  echo "claude-ready: this project has a spec in docs/spec/. Read spec.md, design.md and build-plan.md before building, and update them when scope or architecture changes."
  exit 0
fi
cat <<'EOF'
claude-ready build workflow (AGENTS.md section 10). If this prompt starts a new app or automation, do this before writing code:
1. Spec intake: ask at least 10 multiple-choice questions, then write docs/spec/spec.md, design.md and build-plan.md.
2. Ask: which apps feel the way this one should and why; which hooks and security guardrails to enforce; which skills and plugins to use (list the relevant available ones first, multi-select).
3. Show and wait for feedback: an end-to-end customer journey flowchart, a dataflow and architecture diagram (app, infra, networking), and a low-fidelity clickable wireframe.
If this prompt is not a new build, ignore this note.
EOF
exit 0
