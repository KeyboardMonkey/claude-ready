# claude-ready hook: build-workflow-reminder (PowerShell)
# UserPromptSubmit hook. When a prompt looks like a request to build an app or
# automation, it adds a short reminder of the build workflow (AGENTS.md section 10)
# to Claude's context. It never blocks the prompt.
# If docs\spec\spec.md already exists, it adds a one-line pointer instead.
# Turn off for one session: $env:CLAUDE_SKIP_BUILD_REMINDER = '1'
if ($env:CLAUDE_SKIP_BUILD_REMINDER -eq '1') { exit 0 }
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$prompt = [string]$data.prompt
$cwd = [string]$data.cwd
$verbs = 'build|create|make|develop|scaffold|prototype|design|start|spin up|set up|automate'
$things = 'app|apps|application|automation|workflow|tool|dashboard|bot|website|site|web app|service|api|extension|plugin|agent|n8n|saas|mvp'
if ($prompt -notmatch "(^|[^a-z])($verbs)([^a-z].{0,60})?[^a-z]($things)([^a-z]|$)") { exit 0 }
if ($cwd -and (Test-Path -LiteralPath (Join-Path $cwd 'docs/spec/spec.md') -PathType Leaf)) {
  Write-Output 'claude-ready: this project has a spec in docs/spec/. Read spec.md, design.md and build-plan.md before building, and update them when scope or architecture changes.'
  exit 0
}
Write-Output @'
claude-ready build workflow (AGENTS.md section 10). If this prompt starts a new app or automation, do this before writing code:
1. Spec intake: ask at least 10 multiple-choice questions, then write docs/spec/spec.md, design.md and build-plan.md.
2. Ask: which apps feel the way this one should and why; which hooks and security guardrails to enforce; which skills and plugins to use (list the relevant available ones first, multi-select).
3. Show and wait for feedback: an end-to-end customer journey flowchart, a dataflow and architecture diagram (app, infra, networking), and a low-fidelity clickable wireframe.
If this prompt is not a new build, ignore this note.
'@
exit 0
