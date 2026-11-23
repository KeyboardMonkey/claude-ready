# Global files

These files go in your home directory. Claude Code reads them in every local session (terminal, desktop app, IDE). Codex CLI reads `~/.codex/AGENTS.md`.

> The PowerShell hooks pass the repository's test suite (`setup/tests/hooks.test.sh`) under PowerShell 7.4.6 on Linux. They and the installer have not been run on Windows itself, so run the dry run first, and check `/hooks` plus one test edit after installing.

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
        build-workflow-reminder.ps1
    .codex/
      AGENTS.md                 Codex CLI global rules (same text)
```

## Install

```powershell
git clone https://github.com/KeyboardMonkey/claude-ready.git
cd claude-ready\setup\windows\global
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
2. Run `/hooks`: two `PreToolUse` hooks and one `UserPromptSubmit` hook should be listed.
3. Ask Claude to write a file containing an em dash: the write should be blocked with the claude-ready message.

## Requirements and notes

- The hooks run with `"shell": "powershell"`, which Claude Code starts as PowerShell 7 (`pwsh`). Install PowerShell 7 if you only have Windows PowerShell 5.1.
- If you run Claude Code through Git Bash, the bash hooks from `setup/linux/global` also work on Windows.
- Cloud sessions on claude.ai/code do not read these files. Use the `project/` files for repositories you open there.
- The em dash hook can be bypassed for one session with `CLAUDE_ALLOW_EM_DASH=1`, for example when editing a third-party file you must not change.
- The attribution hook also blocks commits whose author or committer email is not a GitHub noreply address. For a repository that needs another address, bypass it for one session with `CLAUDE_ALLOW_ANY_EMAIL=1`.
- The build reminder hook only adds context and never blocks. Turn it off for one session with `CLAUDE_SKIP_BUILD_REMINDER=1`.
- `settings.json` denies reads of common secret files (`.env`, SSH and cloud credentials, private keys). Remove entries you need.
