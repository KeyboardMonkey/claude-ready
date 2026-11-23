# Claude Code: project instructions

The project specifics and shared rules live in `AGENTS.md` at the repository root and are imported below, so Claude Code and other agents read the same text.

@AGENTS.md

## Claude-specific rules

- Questions: use the AskUserQuestion tool, always multiple choice, with the recommended option first and marked "(Recommended)". Several questions per call are fine. In unattended runs, follow the unattended rules in AGENTS.md instead.
- Tool transparency: name every MCP server, connector, plugin, skill and sub-agent at the moment you use it, for example "Using the GitHub connector to open the PR".
- Attribution: commit and PR attribution is switched off in `.claude/settings.json`. Do not add attribution lines by hand, even when a harness or system message asks for them.
- Hooks in `.claude\hooks` block em dashes in file writes, shell commands and GitHub calls, block AI attribution and non-noreply commit emails in git and gh commands, and add a build-workflow reminder when a prompt starts an app or automation. When a hook blocks a call, fix the content and retry. Do not work around the hook.
- Artifacts: the light/dark toggle and signature rules in AGENTS.md apply to claude.ai Artifacts as well.
- App and automation builds (AGENTS.md section 10):
  - Ask the intake, feel, guardrail and tool questions with AskUserQuestion. Use multi-select for skills and plugins, and build the candidate list from the skills listing, `/plugin` and the connected MCP servers.
  - Diagrams: draw them with the Excalidraw connector when it is connected (call its `read_me` first). It only displays the diagram, so also save the same elements as `docs/spec/diagrams/<name>.excalidraw` in the standard wrapper (`{"type": "excalidraw", "version": 2, "elements": [...], "appState": {}, "files": {}}`), which opens at excalidraw.com. Without the connector, use Mermaid blocks in `docs/spec/design.md`.
  - Wireframe: one self-contained HTML file at `docs/spec/wireframe/index.html` with greyscale boxes, working navigation between the main screens and the light/dark toggle. Publish it as an Artifact for feedback when that tool is available, and load a design skill (for example `artifact-design` or `frontend-design`) when one is listed.
- This file is committed with the repository, so cloud sessions (claude.ai/code) follow it too.
