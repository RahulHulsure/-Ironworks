# Ironworks for Roo Code

> Use Ironworks skills with Roo Code. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.roo/rules
cp platforms/roo/rules/ironworks.md your-project/.roo/rules/
```

### Via installer

```bash
./install.sh --platform roo
# or on Windows:
.\install.ps1 -Platform roo
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks.md` | All Ironworks skills as a single Roo Code rules file |

## How It Works

Roo Code reads markdown files from `.roo/rules/` and applies them as custom instructions that shape the agent's behavior across all modes and tasks.

## Available Commands

After installing, use these in Roo Code chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
