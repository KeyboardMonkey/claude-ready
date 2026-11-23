# claude-ready global installer for Windows (PowerShell 7 or Windows PowerShell 5.1).
# Copies the files under Users\_USER_\ into your profile folder ($env:USERPROFILE).
# Existing files that differ are backed up as <file>.bak.<timestamp> first.
# Usage: .\install.ps1            install
#        .\install.ps1 -DryRun    show what would happen, change nothing
param([switch]$DryRun)
$ErrorActionPreference = 'Stop'

$src = Join-Path $PSScriptRoot 'Users\_USER_'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$script:settingsBackedUp = $false

function Copy-Item-Safe([string]$From, [string]$To) {
  if ($DryRun) { Write-Host "would install: $To"; return }
  $dir = Split-Path $To -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if ((Test-Path $To) -and ((Get-FileHash $From).Hash -ne (Get-FileHash $To).Hash)) {
    Copy-Item $To "$To.bak.$stamp"
    Write-Host "backed up:  $To -> $To.bak.$stamp"
    if ($To -like '*settings.json') { $script:settingsBackedUp = $true }
  }
  Copy-Item $From $To -Force
  Write-Host "installed:  $To"
}

$home_ = $env:USERPROFILE
Copy-Item-Safe "$src\.claude\CLAUDE.md"     "$home_\.claude\CLAUDE.md"
Copy-Item-Safe "$src\.claude\AGENTS.md"     "$home_\.claude\AGENTS.md"
Copy-Item-Safe "$src\.claude\settings.json" "$home_\.claude\settings.json"
Copy-Item-Safe "$src\.codex\AGENTS.md"      "$home_\.codex\AGENTS.md"
Get-ChildItem "$src\.claude\hooks\*.ps1" | ForEach-Object {
  Copy-Item-Safe $_.FullName "$home_\.claude\hooks\$($_.Name)"
}

if ($script:settingsBackedUp) {
  Write-Host 'note: your previous settings.json was replaced. Copy any keys you still need from the .bak file.'
}
Write-Host 'done. Start a new Claude Code session and run /hooks to confirm the three hooks are listed (two PreToolUse, one UserPromptSubmit).'
