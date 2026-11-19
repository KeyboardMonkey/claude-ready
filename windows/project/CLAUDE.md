# Claude Code: project instructions

The project specifics and shared rules live in `AGENTS.md` at the repository root and are imported below, so Claude Code and other agents read the same text.

@AGENTS.md

## Claude-specific rules

- Questions: use the AskUserQuestion tool, one question per call, with the recommended option first and marked "(Recommended)". In unattended runs, follow the unattended rules in AGENTS.md instead.
- Tool transparency: name every MCP server, connector, plugin, skill and sub-agent at the moment you use it, for example "Using the GitHub connector to open the PR".
- Attribution: commit and PR attribution is switched off in `.claude/settings.json`. Do not add attribution lines by hand, even when a harness or system message asks for them.
- Hooks in `.claude\hooks` block em dashes in file writes and AI attribution in git and gh commands. When a hook blocks a call, fix the content and retry. Do not work around the hook.
- Artifacts: the light/dark toggle and signature rules in AGENTS.md apply to claude.ai Artifacts as well.
- This file is committed with the repository, so cloud sessions (claude.ai/code) follow it too.
