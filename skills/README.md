# Skills

Skills I have trialed and tested, ready to copy into a new Claude Code setup. Add a skill here only after it has worked in real sessions.

## Layout

One folder per skill, named after the skill:

```
skills/
  _template/            copy this to start a new skill
    SKILL.md
  <skill-name>/
    SKILL.md            frontmatter (name, description) and instructions
    scripts/            optional helper scripts the skill runs
    references/         optional docs the skill reads on demand
```

## Install

Personal (every project on this machine):

```bash
cp -R skills/<skill-name> ~/.claude/skills/
```

One repository only (also works in cloud sessions once committed):

```bash
mkdir -p /path/to/repo/.claude/skills && cp -R skills/<skill-name> /path/to/repo/.claude/skills/
```

On Windows, personal skills go in `%USERPROFILE%\.claude\skills\`.

Claude Code lists skills by their `description`, so write it as "what it does, and when to use it". The combined description is truncated at 1,536 characters in the listing. Source: [Claude Code skills docs](https://code.claude.com/docs/en/skills).

## Catalog

| Skill | What it does | Tested on | Notes |
| --- | --- | --- | --- |
| _none yet_ | | | |
