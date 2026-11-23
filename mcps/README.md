# MCP servers

MCP server configs I have trialed and tested, ready to add to a new setup. Secrets never go in these files: they reference environment variables with `${VAR}`.

## Layout

One file per server, in the `.mcp.json` format so it can be merged as is:

```
mcps/
  _template.mcp.json    one HTTP and one stdio example
  <server-name>.mcp.json
```

## Install

Option 1, with the CLI (writes to your user config, available in every project):

```bash
claude mcp add --scope user --transport http <name> <url>
```

```bash
claude mcp add --scope user <name> -- <command> [args...]
```

Option 2, for one repository: merge the server's entry into `<repo>/.mcp.json` under `mcpServers` and commit it. Claude Code asks for approval before it uses project servers.

`${VAR}` and `${VAR:-default}` expand in `command`, `args`, `env`, `url` and `headers`. Source: [Claude Code MCP docs](https://code.claude.com/docs/en/mcp).

claude.ai connectors (Settings, Connectors) are managed in the app and are separate from these files. List the ones you rely on in the catalog anyway, so a new setup can reconnect them.

## Catalog

| Server | Type | Config file or connector | What I use it for | Needs | Tested on |
| --- | --- | --- | --- | --- | --- |
| _none yet_ | | | | | |
