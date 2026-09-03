# Ironworks for Windsurf

> Use Ironworks skills with Windsurf. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** -- Development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.windsurf/rules
cp platforms/windsurf/rules/ironworks.md your-project/.windsurf/rules/
```

### Via installer

```bash
./install.sh --platform windsurf
# or on Windows:
.\install.ps1 -Platform windsurf
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks.md` | All Ironworks skills as a single Windsurf rules file |

## How It Works

Windsurf reads markdown files from `.windsurf/rules/` and applies them as persistent context for Cascade, its AI assistant, throughout the session.

## Available Commands

After installing, use these in Windsurf chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
