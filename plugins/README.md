# Plugins

Plugins I have trialed and tested. This folder holds two things:

1. My own plugins, one folder each, published through the local marketplace in `.claude-plugin/marketplace.json`.
2. A catalog of third-party plugins worth installing, with the exact install command.

## Layout

```
plugins/
  .claude-plugin/
    marketplace.json    lists my own plugins (name, owner, plugins[])
  _template/            copy this to start a new plugin
    .claude-plugin/
      plugin.json       manifest; only "name" is required
    skills/             <name>/SKILL.md per skill
    commands/           slash commands
    agents/             sub-agents
    hooks/hooks.json    hooks, under a top-level "hooks" key
    .mcp.json           MCP servers the plugin brings
```

Every folder besides `.claude-plugin/` sits at the plugin root. Sources: [plugin manifest reference](https://code.claude.com/docs/en/plugins/manifest-reference), [plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces).

## Add one of my plugins

1. Copy `_template` to `plugins/<plugin-name>`, set `name` in its `plugin.json`, and add the parts it needs.
2. Add an entry to `.claude-plugin/marketplace.json`:

```json
{ "name": "<plugin-name>", "source": "./<plugin-name>", "description": "What it does" }
```

3. Check it:

```bash
claude plugin validate ./plugins
```

## Install on a new machine

```bash
claude plugin marketplace add ./plugins
```

```bash
claude plugin install <plugin-name>@claude-ready
```

Run both from the root of your claude-ready clone.

## Catalog: third-party plugins

| Plugin | Marketplace | Install | What I use it for | Tested on |
| --- | --- | --- | --- | --- |
| _none yet_ | | | | |
