#!/usr/bin/env bash
# Syed Ishaq B. | ishaqzafar.com
# claude-ready hook tests. Pipes sample hook inputs through the hooks and checks
# the exit code (0 = allowed, 2 = blocked) and, for the reminder, the output.
# Usage: hooks.test.sh <hook directory>
#   A directory with .sh hooks (linux/project, mac/project) runs them with bash,
#   twice: with jq, and with python3 only (jq hidden from PATH).
#   A directory with .ps1 hooks (windows/project) runs them with PowerShell 7:
#   set PWSH to the pwsh binary or put pwsh on PATH.
set -u
hooks="$(cd "${1:?hook directory}" && pwd)"
ext=sh
if [ ! -f "$hooks/block-em-dash.sh" ] && [ -f "$hooks/block-em-dash.ps1" ]; then
  ext=ps1
  PWSH="${PWSH:-$(command -v pwsh || true)}"
  [ -x "$PWSH" ] || { echo "PowerShell 7 not found: set PWSH or install pwsh"; exit 1; }
fi
run_hook() { # hook-name-without-extension
  if [ "$ext" = sh ]; then bash "$hooks/$1.sh"; else "$PWSH" -NoProfile -NonInteractive -File "$hooks/$1.ps1"; fi
}
# The working directory is kept for inspection; the script never deletes anything.
work="$(mktemp -d)"
EM=$'\xe2\x80\x94'
TRAILER='Co-Authored-By: Claude <noreply@anthropic.com>'
NOREPLY='1+tester@users.noreply.github.com'

mkdir -p "$work/repo" "$work/other" "$work/with space" "$work/nojq"
printf 'Fix bug\n\n%s\n' "$TRAILER" > "$work/repo/msg.txt"
printf 'Fix bug\n\nPlain message.\n' > "$work/repo/clean.txt"
printf 'Body\n\nClaude-Session: https://claude.ai/code/session_x\n' > "$work/with space/msg.txt"
printf 'Summary\n\nGenerated with [Claude Code](https://claude.com/claude-code)\n' > "$work/repo/body.md"
for t in bash cat grep python3 head sed env printf git tr tail; do ln -s "$(command -v $t)" "$work/nojq/$t"; done
# Isolated git config: an empty global file, no system file, two test repos.
: > "$work/gitconfig"
export GIT_CONFIG_GLOBAL="$work/gitconfig" GIT_CONFIG_NOSYSTEM=1
unset GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL
git init -q "$work/repo" && git -C "$work/repo" config user.email "$NOREPLY"
git init -q "$work/other" && git -C "$work/other" config user.email "someone@example.com"

pass=0; fail=0
bash_in() { jq -nc --arg c "$1" --arg d "$work/repo" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}'; }
tool_in() { jq -nc --arg t "$1" --argjson i "$2" --arg d "$work/repo" '{tool_name:$t,tool_input:$i,cwd:$d}'; }

export -f run_hook; export hooks ext PWSH 2>/dev/null
modes() { if [ "$ext" = sh ]; then echo "jq python"; else echo "pwsh"; fi; }
invoke() { # mode hook input extra -> stdout, exit code
  local mode="$1" hook="${2%.sh}" input="$3" extra="$4"
  if [ "$mode" = python ]; then
    printf '%s' "$input" | env -i HOME="$HOME" PATH="$work/nojq" GIT_CONFIG_GLOBAL="$GIT_CONFIG_GLOBAL" GIT_CONFIG_NOSYSTEM=1 $extra bash "$hooks/$hook.sh" 2>/dev/null
  else
    printf '%s' "$input" | env $extra bash -c 'run_hook "$0"' "$hook" 2>/dev/null
  fi
}
check() { # name hook expected-exit input [envassign]
  local name="$1" hook="$2" want="$3" input="$4" extra="${5:-}" mode got
  for mode in $(modes); do
    invoke "$mode" "$hook" "$input" "$extra" >/dev/null; got=$?
    if [ "$got" = "$want" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL [$mode] $hook: $name (want $want, got $got)"; fi
  done
}
check_out() { # name hook input expected-substring ("" = no output) [envassign]
  local name="$1" hook="$2" input="$3" want="$4" extra="${5:-}" mode out code
  for mode in $(modes); do
    out="$(invoke "$mode" "$hook" "$input" "$extra")"; code=$?
    if [ "$code" = 0 ] && { { [ -z "$want" ] && [ -z "$out" ]; } || { [ -n "$want" ] && [[ "$out" == *"$want"* ]]; }; }; then
      pass=$((pass+1))
    else
      fail=$((fail+1)); echo "FAIL [$mode] $hook: $name (exit $code, output: ${out:0:80})"
    fi
  done
}
prompt_in() { jq -nc --arg p "$1" --arg d "${2:-$work/repo}" '{hook_event_name:"UserPromptSubmit",prompt:$p,cwd:$d}'; }

# block-em-dash
check "Write with em dash"        block-em-dash.sh 2 "$(tool_in Write "$(jq -nc --arg s "a ${EM} b" '{file_path:"/x",content:$s}')")"
check "Write clean"               block-em-dash.sh 0 "$(tool_in Write '{"file_path":"/x","content":"a, b"}')"
check "Edit with em dash"         block-em-dash.sh 2 "$(tool_in Edit "$(jq -nc --arg s "${EM}" '{file_path:"/x",old_string:"a",new_string:$s}')")"
check "Edit removing em dash"     block-em-dash.sh 0 "$(tool_in Edit "$(jq -nc --arg s "${EM}" '{file_path:"/x",old_string:$s,new_string:","}')")"
check "MultiEdit with em dash"    block-em-dash.sh 2 "$(tool_in MultiEdit "$(jq -nc --arg s "${EM}" '{file_path:"/x",edits:[{old_string:"a",new_string:"b"},{old_string:"c",new_string:$s}]}')")"
check "NotebookEdit with em dash" block-em-dash.sh 2 "$(tool_in NotebookEdit "$(jq -nc --arg s "x = 1 # ${EM}" '{notebook_path:"/x.ipynb",new_source:$s}')")"
check "Bash heredoc with em dash" block-em-dash.sh 2 "$(bash_in "cat > f.md <<'EOF'
Title ${EM} sub
EOF")"
check "Bash sed -i with em dash"  block-em-dash.sh 2 "$(bash_in "sed -i 's/,/ ${EM} /' f.md")"
check "Bash commit with em dash"  block-em-dash.sh 2 "$(bash_in "git commit -m 'Fix ${EM} thing'")"
check "Bash escaped search"       block-em-dash.sh 0 "$(bash_in "grep -rn \$'\\xe2\\x80\\x94' .")"
check "Bash clean"                block-em-dash.sh 0 "$(bash_in "ls -la")"
check "GitHub MCP PR body"        block-em-dash.sh 2 "$(tool_in mcp__github__create_pull_request "$(jq -nc --arg s "Adds X ${EM} and Y" '{owner:"o",repo:"r",title:"t",body:$s}')")"
check "GitHub MCP clean"          block-em-dash.sh 0 "$(tool_in mcp__github__create_pull_request '{"owner":"o","repo":"r","title":"t","body":"ok"}')"
check "Bypass variable"           block-em-dash.sh 0 "$(tool_in Write "$(jq -nc --arg s "${EM}" '{file_path:"/x",content:$s}')")" CLAUDE_ALLOW_EM_DASH=1

# block-attribution
check "commit -m trailer"               block-attribution.sh 2 "$(bash_in "git commit -m \"Fix

${TRAILER}\"")"
check "commit -F relative file"         block-attribution.sh 2 "$(bash_in "git commit -F msg.txt")"
check "commit -Ffile attached"          block-attribution.sh 2 "$(bash_in "git commit -Fmsg.txt")"
check "commit --file=relative"          block-attribution.sh 2 "$(bash_in "git commit --file=msg.txt")"
check "commit --file quoted abs+space"  block-attribution.sh 2 "$(bash_in "git commit --file \"$work/with space/msg.txt\"")"
check "commit -F clean file"            block-attribution.sh 0 "$(bash_in "git commit -F clean.txt")"
check "commit -F missing file"          block-attribution.sh 0 "$(bash_in "git commit -F nope.txt")"
check "commit -F - heredoc trailer"     block-attribution.sh 2 "$(bash_in "git commit -F - <<'EOF'
Fix
${TRAILER}
EOF")"
check "git -C dir commit trailer"       block-attribution.sh 2 "$(bash_in "git -C /repo commit -m 'x Claude-Session: y'")"
check "git -c k=v commit -F file"       block-attribution.sh 2 "$(bash_in "git -c user.name=me commit -F msg.txt")"
check "gh pr create --body-file"        block-attribution.sh 2 "$(bash_in "gh pr create --title t --body-file body.md")"
check "gh pr create -F"                 block-attribution.sh 2 "$(bash_in "gh pr create --title t -F body.md")"
check "chained cd && commit -F"         block-attribution.sh 2 "$(bash_in "cd $work/repo && git add . && git commit -F msg.txt")"
check "git status"                      block-attribution.sh 0 "$(bash_in "git status")"
check "non-git echo of trailer"         block-attribution.sh 0 "$(bash_in "echo '${TRAILER}' > notes.txt")"
check "clean commit"                    block-attribution.sh 0 "$(bash_in "git commit -m 'Fix parser'")"
check "GitHub MCP PR footer"            block-attribution.sh 2 "$(tool_in mcp__github__create_pull_request '{"owner":"o","repo":"r","title":"t","body":"Generated with [Claude Code](https://claude.com/claude-code)"}')"
check "GitHub MCP clean"                block-attribution.sh 0 "$(tool_in mcp__github__create_pull_request '{"owner":"o","repo":"r","title":"t","body":"ok"}')"

# block-attribution: commit identity
check "commit, repo email noreply"      block-attribution.sh 0 "$(bash_in "git commit -m 'Fix'")"
check "commit, repo email personal"     block-attribution.sh 2 "$(bash_in "git -C $work/other commit -m 'Fix'")"
check "cd other && commit"              block-attribution.sh 2 "$(bash_in "cd $work/other && git commit -m 'Fix'")"
check "-c user.email personal"          block-attribution.sh 2 "$(bash_in "git -c user.email=me@example.com commit -m 'Fix'")"
check "-c user.email noreply in other"  block-attribution.sh 0 "$(bash_in "git -c user.email=$NOREPLY -C $work/other commit -m 'Fix'")"
check "--author personal"               block-attribution.sh 2 "$(bash_in "git commit --author='Me <me@example.com>' -m 'Fix'")"
check "inline GIT_AUTHOR_EMAIL"         block-attribution.sh 2 "$(bash_in "GIT_AUTHOR_EMAIL=me@example.com git commit -m 'Fix'")"
check "merge in personal repo"          block-attribution.sh 2 "$(bash_in "git -C $work/other merge feature")"
check "status in personal repo"         block-attribution.sh 0 "$(bash_in "git -C $work/other status")"
check "bypass CLAUDE_ALLOW_ANY_EMAIL"   block-attribution.sh 0 "$(bash_in "git -C $work/other commit -m 'Fix'")" CLAUDE_ALLOW_ANY_EMAIL=1

# build-workflow-reminder
mkdir -p "$work/specd/docs/spec" && printf '# Spec\n' > "$work/specd/docs/spec/spec.md"
check_out "build an app"              build-workflow-reminder.sh "$(prompt_in 'Can you build an app that tracks my receipts?')" "Spec intake"
check_out "create n8n automation"     build-workflow-reminder.sh "$(prompt_in 'create an n8n automation for invoices')" "Spec intake"
check_out "make a dashboard"          build-workflow-reminder.sh "$(prompt_in 'Make me a small dashboard for my portfolio')" "Spec intake"
check_out "spec exists"               build-workflow-reminder.sh "$(prompt_in 'build an app for notes' "$work/specd")" "has a spec in docs/spec/"
check_out "unrelated question"        build-workflow-reminder.sh "$(prompt_in 'What does this regex do?')" ""
check_out "fix a bug"                 build-workflow-reminder.sh "$(prompt_in 'fix the failing test in parser.py')" ""
check_out "word inside word"          build-workflow-reminder.sh "$(prompt_in 'rebuild the cache and reapply settings')" ""
check_out "bypass"                    build-workflow-reminder.sh "$(prompt_in 'build an app')" "" CLAUDE_SKIP_BUILD_REMINDER=1

echo "passed: $pass  failed: $fail  (work dir kept: $work)"
[ "$fail" -eq 0 ]
# sig: U3llZCBJc2hhcSBCLiB8IGlzaGFxemFmYXIuY29t
