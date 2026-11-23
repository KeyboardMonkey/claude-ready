# claude-ready hook: block-em-dash (PowerShell)
# PreToolUse hook. Blocks the call when the text it would write contains an em
# dash (U+2014) and tells Claude why, so it rewrites the text.
#   Write, Edit, MultiEdit, NotebookEdit: checks the new text.
#   Bash: checks the whole command (heredocs, redirects, sed -i, inline scripts,
#         commit messages). To search for an em dash, write it escaped.
#   GitHub/GitLab MCP tools: checks every string in the tool input.
# Bypass for one session: $env:CLAUDE_ALLOW_EM_DASH = '1'
if ($env:CLAUDE_ALLOW_EM_DASH -eq '1') { exit 0 }
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$tool = [string]$data.tool_name
$ti = $data.tool_input
if (-not $ti) { exit 0 }

function Get-Strings($o) {
  if ($null -eq $o) { return }
  if ($o -is [string]) { return $o }
  if ($o -is [System.Management.Automation.PSCustomObject]) {
    foreach ($p in $o.PSObject.Properties) { Get-Strings $p.Value }
    return
  }
  if ($o -is [System.Collections.IEnumerable]) { foreach ($x in $o) { Get-Strings $x } }
}

if ($tool -match '^(Write|Edit|MultiEdit|NotebookEdit)$') {
  $parts = @($ti.content, $ti.new_string, $ti.new_source)
  if ($ti.edits) { $parts += @($ti.edits | ForEach-Object { $_.new_string }) }
  $text = ($parts | Where-Object { $_ -is [string] }) -join "`n"
} elseif ($tool -eq 'Bash') {
  $text = [string]$ti.command
} else {
  $text = (@(Get-Strings $ti)) -join "`n"
}
if ($text.Contains([string][char]0x2014)) {
  [Console]::Error.WriteLine("Blocked by claude-ready: the text contains an em dash (U+2014). Rewrite it with a comma, colon, parentheses or a new sentence, then retry. In a shell search, write the character escaped, for example `$'\xe2\x80\x94'.")
  exit 2
}
exit 0
