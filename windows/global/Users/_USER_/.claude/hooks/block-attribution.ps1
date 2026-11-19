# claude-ready hook: block-attribution (PowerShell)
# PreToolUse hook for Bash and GitHub/GitLab MCP tools. Blocks git and gh
# commands, and MCP calls, whose text carries AI attribution: Co-Authored-By
# trailers naming an AI, session trailers or links, "Generated with ..." footers.
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
$text = $raw
try {
  $data = $raw | ConvertFrom-Json
  if ($data.tool_name -eq 'Bash') {
    $cmd = [string]$data.tool_input.command
    if ($cmd -notmatch '(^|[;&|(`\s])(git\s+(commit|tag|notes|merge)|gh\s+(pr|issue|release|api))') { exit 0 }
    $text = $cmd
  }
} catch { }
$pattern = 'co-authored-by:.{0,80}(claude|anthropic|copilot|codex|openai|gemini|cursor)|generated (with|by) \[?(claude|codex|copilot|cursor|gemini)|claude-session:|claude\.ai/code/session|noreply@anthropic\.com'
if ($text -match $pattern) {
  [Console]::Error.WriteLine("Blocked by claude-ready: this command or message carries AI attribution (Co-Authored-By trailer, session link or 'Generated with' footer). Remove it and retry.")
  exit 2
}
exit 0
