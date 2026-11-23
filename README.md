# claude-ready

Everything I need to set up Claude Code, claude.ai and other AGENTS.md agents (Codex, Cursor, Copilot, Gemini CLI, Aider) on a new machine: rules, settings and hooks for Linux, macOS and Windows, plus my trialed and tested skills, plugins and MCP servers.

## Layout

```
claude-ready/
  setup/        rules, settings and hooks
    linux/        global/ (for ~, plus install.sh) and project/ (copy into a repo)
    mac/          same, for /Users/<you>
    windows/      same, for C:\Users\<you>, PowerShell hooks and install.ps1
    web/          the instruction set to paste into claude.ai
    tests/        hook test suite
  skills/       tested skills, one folder each, copy into ~/.claude/skills
  plugins/      my plugins as a local marketplace, plus a catalog of third-party ones
  mcps/         tested MCP server configs in .mcp.json format, plus a catalog
```

## Quick start on a new machine

1. Clone the repository.
2. Pick your OS folder under [`setup/`](./setup/) and run the installer in `global/`. It backs up anything it replaces.
3. Copy the files in `project/` into each repository you want covered, including every repository you open in claude.ai/code cloud sessions. Fill in the Project section of `AGENTS.md`.
4. Paste [`setup/web/instructions.md`](./setup/web/instructions.md) into claude.ai.
5. Install the skills, plugins and MCP servers you need from [`skills/`](./skills/), [`plugins/`](./plugins/) and [`mcps/`](./mcps/).

## What the setup gives you

- **One rule set everywhere.** `AGENTS.md` holds the rules: accuracy, tone, working style, writing style, code and artifact conventions, git identity and attribution, tool transparency, blockers and the app-building workflow. `CLAUDE.md` imports it and adds Claude-specific tool rules.
- **Enforcement where it matters.** `settings.json` switches off commit and PR attribution, denies reads of common secret files and asks before force-pushes, hard resets and `rm -rf`. Three hooks back up the rules:

| Hook | Event | What it does |
| --- | --- | --- |
| `block-em-dash` | PreToolUse: Write, Edit, MultiEdit, NotebookEdit, Bash, GitHub and GitLab MCP | Blocks any em dash in written files, shell commands (heredocs, redirects, `sed -i`, commit messages) and GitHub calls |
| `block-attribution` | PreToolUse: Bash, GitHub and GitLab MCP | Blocks AI attribution in git and gh commands, including message files passed with `-F`, `--file` or `--body-file`, and blocks commits whose author or committer email is not a GitHub noreply address |
| `build-workflow-reminder` | UserPromptSubmit | When a prompt starts an app or automation, adds a reminder of the spec, diagram and wireframe workflow |

Bypass switches for one session: `CLAUDE_ALLOW_EM_DASH=1`, `CLAUDE_ALLOW_ANY_EMAIL=1` (for a repository that needs a work address), `CLAUDE_SKIP_BUILD_REMINDER=1`.

## How the files fit together

| Scope | Claude Code reads | Other agents read |
| --- | --- | --- |
| Global (local sessions) | `~/.claude/CLAUDE.md`, which imports `~/.claude/AGENTS.md`; `~/.claude/settings.json` | Codex: `~/.codex/AGENTS.md` |
| Project (local and cloud) | `<repo>/CLAUDE.md`, which imports `<repo>/AGENTS.md`; `<repo>/.claude/settings.json` | `<repo>/AGENTS.md` |
| claude.ai apps | The instructions field in Settings | |

Precedence: instructions in the chat override the files. The project file wins over the global one on project matters, and the closest `AGENTS.md` to the edited file wins in a monorepo.

## Keeping copies in sync

The rule text is identical in all six global `AGENTS.md` copies and in all three project copies. `setup/web/instructions.md` restates the same rules in fewer words. When you change a rule, change it everywhere (search the repo for the old wording) or ask an agent to do it in one pass.

## Testing

```bash
setup/tests/hooks.test.sh setup/linux/project
```

```bash
PWSH=/path/to/pwsh setup/tests/hooks.test.sh setup/windows/project
```

- Bash hooks (Linux, macOS): 50 cases, each run with jq and with python3 only. All pass.
- PowerShell hooks: the same 50 cases, run with PowerShell 7.4.6 on Linux. All pass. They have not been run on Windows itself or under Windows PowerShell 5.1, so run the checks in `setup/windows/global/README.md` before relying on them.
