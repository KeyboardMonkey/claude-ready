# Global files

These files go in your home directory. Claude Code reads them in every local session (terminal, desktop app, IDE). Codex CLI reads `~/.codex/AGENTS.md`.

> The PowerShell hooks and installer were written without a Windows machine to test on. Run the dry run first, and check `/hooks` plus one test edit after installing.

## Layout

`_USER_` stands for your user folder. Everything under it mirrors where the file belongs on disk.

```
global/
  install.ps1
  Users/_USER_/                 = %USERPROFILE%  (C:\Users\<you>)
    .claude/
      CLAUDE.md                 Claude Code global memory, imports AGENTS.md
      AGENTS.md                 the shared rules
      settings.json             attribution off, permissions, hooks
      hooks/
        block-em-dash.ps1
        block-attribution.ps1
    .codex/
      AGENTS.md                 Codex CLI global rules (same text)
```

## Install

```powershell
git clone https://github.com/KeyboardMonkey/claude-ready.git
cd claude-ready\windows\global
.\install.ps1 -DryRun   # preview
.\install.ps1           # install
```

If PowerShell refuses to run the script, allow local scripts for your user first:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

The installer backs up any existing file that differs as `<file>.bak.<timestamp>` before replacing it. If you already had a `settings.json`, merge back any keys you still need from the backup.

## Verify

1. Start a new Claude Code session and run `/memory`: the user memory should show `CLAUDE.md` with `AGENTS.md` imported.
2. Run `/hooks`: two `PreToolUse` hooks should be listed.
3. Ask Claude to write a file containing an em dash: the write should be blocked with the claude-ready message.

## Requirements and notes

- The hooks run with `"shell": "powershell"`, which Claude Code starts as PowerShell 7 (`pwsh`). Install PowerShell 7 if you only have Windows PowerShell 5.1.
- If you run Claude Code through Git Bash, the bash hooks from `linux/global` also work on Windows.
- Cloud sessions on claude.ai/code do not read these files. Use the `project/` files for repositories you open there.
- The em dash hook can be bypassed for one session with `CLAUDE_ALLOW_EM_DASH=1`, for example when editing a third-party file you must not change.
- `settings.json` denies reads of common secret files (`.env`, SSH and cloud credentials, private keys). Remove entries you need.
