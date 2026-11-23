# claude-ready hook: block-attribution (PowerShell)
# PreToolUse hook for Bash and GitHub/GitLab MCP tools. Blocks:
#   1. git and gh commands, and MCP calls, whose text carries AI attribution:
#      Co-Authored-By trailers naming an AI, session trailers or links,
#      "Generated with ..." footers. Message files passed with -F, --file or
#      --body-file are read too.
#   2. git commands that create commits (commit, merge, revert, cherry-pick)
#      when the author or committer email is not a GitHub noreply address
#      (<id>+<user>@users.noreply.github.com).
#      Bypass for one session: $env:CLAUDE_ALLOW_ANY_EMAIL = '1'
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
$text = $raw

function Resolve-HookPath([string]$p, [string]$base) {
  if ($p.StartsWith('~/') -or $p.StartsWith('~\')) { return (Join-Path $HOME $p.Substring(2)) }
  if ([System.IO.Path]::IsPathRooted($p) -or -not $base) { return $p }
  return (Join-Path $base $p)
}

try {
  $data = $raw | ConvertFrom-Json
  if ($data.tool_name -eq 'Bash') {
    $cmd = [string]$data.tool_input.command
    # git with optional global options (-C dir, -c key=value, --no-pager ...) before the subcommand
    $gitpre = '(^|[;&|(`\s])git(\s+(-[cC]\s+\S+|--?[a-zA-Z-]+(=\S+)?))*'
    $ghcmd = '(^|[;&|(`\s])gh\s+(pr|issue|release|api|gist)'
    if ($cmd -notmatch "$gitpre\s+(commit|tag|notes|merge|revert|cherry-pick)|$ghcmd") { exit 0 }
    $text = $cmd

    # Working directory of the git command: a leading "cd dir &&", then "git -C dir"
    $dir = [string]$data.cwd
    $m = [regex]::Matches($cmd, '(?:^|[;&|]\s*)cd\s+("[^"]*"|[^\s;&|]+)')
    if ($m.Count) { $dir = Resolve-HookPath $m[$m.Count - 1].Groups[1].Value.Trim('"', "'") $dir }
    $m = [regex]::Matches($cmd, 'git(?:\s+-c\s+\S+)*\s+-C\s+("[^"]*"|\S+)')
    if ($m.Count) { $dir = Resolve-HookPath $m[$m.Count - 1].Groups[1].Value.Trim('"', "'") $dir }

    # 1. Message files: -F f, -Ff, --file f, --file=f, --body-file f, --notes-file f
    $fileFlag = '(?:^|\s)(?:-F\s*|--(?:body-|notes-)?file(?:=|\s+))("[^"]*"|''[^'']*''|[^\s;&|)]+)'
    foreach ($fm in [regex]::Matches($cmd, $fileFlag)) {
      $f = $fm.Groups[1].Value.Trim('"', "'")
      if (-not $f -or $f -eq '-') { continue }
      $f = Resolve-HookPath $f $dir
      if (Test-Path -LiteralPath $f -PathType Leaf) {
        try { $text += "`n" + [System.IO.File]::ReadAllText($f) } catch { }
      }
    }

    # 2. Commit identity: every author and committer email must be a GitHub noreply address
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($env:CLAUDE_ALLOW_ANY_EMAIL -ne '1' -and $git -and $cmd -match "$gitpre\s+(commit|merge|revert|cherry-pick)(\s|$)") {
      $emails = @()
      $m = [regex]::Matches($cmd, '-c\s+user\.email=("[^"]*"|[^\s;&|]+)')
      if ($m.Count) {
        $emails += $m[$m.Count - 1].Groups[1].Value.Trim('"', "'")
      } else {
        $gitArgs = @()
        if ($dir) { $gitArgs += @('-C', $dir) }
        try { $e = & git @gitArgs config user.email 2>$null; if ($e) { $emails += [string]$e } } catch { }
      }
      foreach ($am in [regex]::Matches($cmd, '--author[= ]("[^"]*"|''[^'']*''|\S+)')) {
        $a = [regex]::Match($am.Value, '<([^>]*)>')
        if ($a.Success) { $emails += $a.Groups[1].Value }
      }
      foreach ($em in [regex]::Matches($cmd, 'GIT_(?:AUTHOR|COMMITTER)_EMAIL=("[^"]*"|[^\s;&|]+)')) { $emails += $em.Groups[1].Value.Trim('"') }
      if ($env:GIT_AUTHOR_EMAIL) { $emails += $env:GIT_AUTHOR_EMAIL }
      if ($env:GIT_COMMITTER_EMAIL) { $emails += $env:GIT_COMMITTER_EMAIL }
      $bad = $emails | Where-Object { $_ -and $_.Trim() -and $_.Trim() -notmatch '@users\.noreply\.github\.com$' } | Select-Object -First 1
      if ($bad) {
        [Console]::Error.WriteLine("Blocked by claude-ready: this commit would use the email '$bad'. Commit only with your GitHub noreply address, for example: git config user.email '<id>+<user>@users.noreply.github.com'. For a repository that needs another address, bypass for one session with `$env:CLAUDE_ALLOW_ANY_EMAIL = '1'.")
        exit 2
      }
    }
  }
} catch { }

$pattern = 'co-authored-by:.{0,80}(claude|anthropic|copilot|codex|openai|gemini|cursor)|generated (with|by) \[?(claude|codex|copilot|cursor|gemini)|claude-session:|claude\.ai/code/session|noreply@anthropic\.com'
if ($text -match $pattern) {
  [Console]::Error.WriteLine("Blocked by claude-ready: this command, its message file or its message carries AI attribution (Co-Authored-By trailer, session link or 'Generated with' footer). Remove it and retry.")
  exit 2
}
exit 0
