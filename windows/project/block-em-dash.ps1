# claude-ready hook: block-em-dash (PowerShell)
# PreToolUse hook for Write, Edit and MultiEdit. Blocks the call when the new
# text contains an em dash (U+2014) and tells Claude why, so it rewrites the text.
# Bypass for one session: $env:CLAUDE_ALLOW_EM_DASH = '1'
if ($env:CLAUDE_ALLOW_EM_DASH -eq '1') { exit 0 }
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$ti = $data.tool_input
if (-not $ti) { exit 0 }
$parts = @($ti.content, $ti.new_string)
if ($ti.edits) { $parts += @($ti.edits | ForEach-Object { $_.new_string }) }
$text = ($parts | Where-Object { $_ -is [string] }) -join "`n"
if ($text.Contains([string][char]0x2014)) {
  [Console]::Error.WriteLine('Blocked by claude-ready: the new text contains an em dash (U+2014). Rewrite it with a comma, colon, parentheses or a new sentence, then retry.')
  exit 2
}
exit 0
