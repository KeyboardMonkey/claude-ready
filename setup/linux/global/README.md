# Global files

These files go in your home directory. Claude Code reads them in every local session (terminal, desktop app, IDE). Codex CLI reads `~/.codex/AGENTS.md`.

## Layout

`_USER_` stands for your user folder. Everything under it mirrors where the file belongs on disk.

```
global/
  install.sh
  home/_USER_/                  = ~  (/home/<you>)
    .claude/
      CLAUDE.md                 Claude Code global memory, imports AGENTS.md
      AGENTS.md                 the shared rules
      settings.json             attribution off, permissions, hooks
      hooks/
        block-em-dash.sh
        block-attribution.sh
        build-workflow-reminder.sh
    .codex/
      AGENTS.md                 Codex CLI global rules (same text)
```

## Install

```bash
git clone https://github.com/KeyboardMonkey/claude-ready.git
```

```bash
cd claude-ready/setup/linux/global
```

```bash
./install.sh --dry-run
```

```bash
./install.sh
```

The installer backs up any existing file that differs as `<file>.bak.<timestamp>` before replacing it. If you already had a `settings.json`, merge back any keys you still need from the backup.

## Verify

1. Start a new Claude Code session and run `/memory`: the user memory should show `CLAUDE.md` with `AGENTS.md` imported.
2. Run `/hooks`: two `PreToolUse` hooks and one `UserPromptSubmit` hook should be listed.
3. Ask Claude to write a file containing an em dash: the write should be blocked with the claude-ready message.

## Requirements and notes

- The hooks need `jq` or `python3` to read their input. Without either they allow every call, and the installer warns you.
- Cloud sessions on claude.ai/code do not read these files. Use the `project/` files for repositories you open there.
- The em dash hook can be bypassed for one session with `CLAUDE_ALLOW_EM_DASH=1`, for example when editing a third-party file you must not change.
- The attribution hook also blocks commits whose author or committer email is not a GitHub noreply address. For a repository that needs another address, bypass it for one session with `CLAUDE_ALLOW_ANY_EMAIL=1`.
- The build reminder hook only adds context and never blocks. Turn it off for one session with `CLAUDE_SKIP_BUILD_REMINDER=1`.
- `settings.json` denies reads of common secret files (`.env`, SSH and cloud credentials, private keys). Remove entries you need.
