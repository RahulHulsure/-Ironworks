# Ironworks for Kilo Code

> Use Ironworks skills with Kilo Code. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.kilo/rules
cp platforms/kilo/rules/ironworks.md your-project/.kilo/rules/
```

### Via installer

```bash
./install.sh --platform kilo
# or on Windows:
.\install.ps1 -Platform kilo
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks.md` | All Ironworks skills as a single Kilo Code rules file |

## How It Works

Kilo Code reads markdown files from `.kilo/rules/` and applies them as project-level rules that guide the agent's behavior across all coding modes and tasks.

## Available Commands

After installing, use these in Kilo Code chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
