# Project files

Copy these into a repository so every agent working in it, including Claude Code cloud sessions, follows your rules and knows the project.

> Cloud sessions on claude.ai/code run on Linux and cannot run these PowerShell hooks. For any repository you also open in the cloud, use the files from `linux/project` instead; they work on Windows too when Claude Code runs hooks through Git Bash.

## Where each file goes

| File here | Goes to | Read by |
| --- | --- | --- |
| `AGENTS.md` | `<repo>/AGENTS.md` | Codex, Cursor, Copilot, Gemini CLI, Aider, Zed, Warp and other AGENTS.md agents |
| `CLAUDE.md` | `<repo>/CLAUDE.md` | Claude Code (imports `AGENTS.md`) |
| `settings.json` | `<repo>/.claude/settings.json` | Claude Code (attribution off, permissions, hooks) |
| block-em-dash.ps1, block-attribution.ps1 | `<repo>/.claude/hooks/` | Claude Code hooks referenced by `settings.json` |

## Install

```powershell
$repo = 'C:\path\to\your\repo'
Copy-Item AGENTS.md, CLAUDE.md $repo
New-Item -ItemType Directory -Force "$repo\.claude\hooks" | Out-Null
Copy-Item settings.json "$repo\.claude\settings.json"
Copy-Item block-em-dash.ps1, block-attribution.ps1 "$repo\.claude\hooks"
```

Then:

1. Open `AGENTS.md` and fill in the **Project** section: overview, setup, build and test commands, code style, security, PR rules, do-not-touch list. Delete subsections that do not apply.
2. Commit all four files.

## Other agents

- Gemini CLI reads `GEMINI.md` by default. Point it at `AGENTS.md` with `{"contextFileName": "AGENTS.md"}` in `.gemini/settings.json`.
- Aider: add `read: AGENTS.md` to `.aider.conf.yml`.

## Notes

- With the global files installed too, Claude Code loads the personal rules twice (global and project). That only costs a little context; the text is identical.
- In a monorepo, add a smaller `AGENTS.md` in each package. The file closest to the edited code wins.
- Project `settings.json` applies to everyone who clones the repo. Keep personal-only preferences in the global files.
