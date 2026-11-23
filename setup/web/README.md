# claude.ai (web, desktop and mobile apps)

The claude.ai apps cannot read files or run hooks, so the rules travel as text. [`instructions.md`](./instructions.md) is the condensed version of `AGENTS.md` for the account-wide instructions field.

## Install

1. Open claude.ai, click your initials in the lower left, then **Settings** and **Your Claude** (called **Account** in the older settings layout).
2. Paste the contents of `instructions.md` into the instructions for Claude field and save.

Source: [Understanding Claude's personalization features](https://support.claude.com/en/articles/10185728-understanding-claude-s-personalization-features). Menu labels can differ between settings layouts.

## What differs from the file-based setup

| Rule | Local and cloud Claude Code | claude.ai |
| --- | --- | --- |
| No em dashes, no AI attribution, noreply commit email | Enforced by hooks | Instruction only |
| Build workflow reminder | Hook adds it when a prompt starts a build | Instruction only |
| Spec location | `docs/spec/` in the repository | A Claude Project, Docs or artifacts |
| Project context | `AGENTS.md` Project section | Project instructions (paid plans) |

## Keeping it in sync

`instructions.md` restates `AGENTS.md` sections 1 to 10 and the hard rules in fewer words. When you change a rule in `AGENTS.md`, change it here too, then paste the new text into claude.ai.
