# claude-ready

Ready-to-install rule, settings and hook files for Claude Code and other AGENTS.md agents (Codex, Cursor, Copilot, Gemini CLI, Aider), for Linux, macOS and Windows.

## What you get

- **One rule set, everywhere.** `AGENTS.md` holds the rules: accuracy, tone, working style, writing style, code and artifact conventions, git and attribution, tool transparency, blockers. `CLAUDE.md` imports it, so Claude Code and other agents read the same text.
- **Enforcement where it matters.** `settings.json` switches off commit and PR attribution, denies reads of common secret files and asks before force-pushes. Two hooks block em dashes in file writes and AI attribution in git and gh commands.
- **Global and per-project copies.** Global files cover every local session on a machine. Project files cover one repository, including Claude Code cloud sessions, which only read committed files.

## Layout

```
claude-ready/
  linux/
    global/    files for ~ (home), laid out as on disk, plus install.sh
    project/   flat files to copy into a repository
  mac/
    global/    same, for /Users/<you>, plus install.sh
    project/
  windows/
    global/    same, for C:\Users\<you>, plus install.ps1
    project/   PowerShell hooks
```

## Quick start

1. Pick your OS folder: [`linux`](./linux/), [`mac`](./mac/) or [`windows`](./windows/).
2. Run the installer in `global/` once per machine. It backs up anything it replaces.
3. Copy the files in `project/` into each repository you want covered and fill in the Project section of `AGENTS.md`.

## How the files fit together

| Scope | Claude Code reads | Other agents read |
| --- | --- | --- |
| Global (local sessions) | `~/.claude/CLAUDE.md`, which imports `~/.claude/AGENTS.md`; `~/.claude/settings.json` | Codex: `~/.codex/AGENTS.md` |
| Project (local and cloud) | `<repo>/CLAUDE.md`, which imports `<repo>/AGENTS.md`; `<repo>/.claude/settings.json` | `<repo>/AGENTS.md` |

Precedence: instructions in the chat override the files. The project file wins over the global one on project matters, and the closest `AGENTS.md` to the edited file wins in a monorepo.

## Keeping copies in sync

The rule text is identical in all six `AGENTS.md` copies. When you change a rule, change it everywhere (search the repo for the old wording) or ask an agent to do it in one pass.

## Testing status

- Linux and macOS bash hooks: tested by piping sample hook inputs (Write, Edit, MultiEdit, git commit, GitHub MCP) through them.
- Windows PowerShell hooks and installer: written without a Windows machine. Run the dry run and the checks in `windows/global/README.md` before relying on them.
