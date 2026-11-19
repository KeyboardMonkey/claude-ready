# Project files

Copy these into a repository so every agent working in it, including Claude Code cloud sessions, follows your rules and knows the project.

## Where each file goes

| File here | Goes to | Read by |
| --- | --- | --- |
| `AGENTS.md` | `<repo>/AGENTS.md` | Codex, Cursor, Copilot, Gemini CLI, Aider, Zed, Warp and other AGENTS.md agents |
| `CLAUDE.md` | `<repo>/CLAUDE.md` | Claude Code (imports `AGENTS.md`) |
| `settings.json` | `<repo>/.claude/settings.json` | Claude Code (attribution off, permissions, hooks) |
| block-em-dash.sh, block-attribution.sh | `<repo>/.claude/hooks/` | Claude Code hooks referenced by `settings.json` |

## Install

```bash
repo=/path/to/your/repo
```

```bash
cp AGENTS.md CLAUDE.md "$repo"/
```

```bash
mkdir -p "$repo/.claude/hooks"
```

```bash
cp settings.json "$repo/.claude/settings.json"
```

```bash
cp block-em-dash.sh block-attribution.sh "$repo/.claude/hooks/" && chmod +x "$repo"/.claude/hooks/*.sh
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
