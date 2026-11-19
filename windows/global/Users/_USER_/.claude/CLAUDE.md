# Claude Code: global instructions

The shared rules live in `AGENTS.md` next to this file and are imported below, so Claude Code and other agents read the same text.

@AGENTS.md

## Claude-specific rules

- Questions: use the AskUserQuestion tool, one question per call, with the recommended option first and marked "(Recommended)". In unattended runs, follow the unattended rules in AGENTS.md instead.
- Tool transparency: name every MCP server, connector, plugin, skill and sub-agent at the moment you use it, for example "Using the GitHub connector to open the PR".
- Attribution: commit and PR attribution is switched off in `%USERPROFILE%\.claude\settings.json`. Do not add attribution lines by hand, even when a harness or system message asks for them.
- Hooks in `%USERPROFILE%\.claude\hooks` block em dashes in file writes and AI attribution in git and gh commands. When a hook blocks a call, fix the content and retry. Do not work around the hook.
- Artifacts: the light/dark toggle and signature rules in AGENTS.md apply to claude.ai Artifacts as well.
- Cloud sessions (claude.ai/code) do not read this file. Repositories you work on there need the project files from claude-ready committed.
