# Ironworks for Trae

> Use Ironworks skills with Trae. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** -- Development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.trae/rules
cp platforms/trae/rules/ironworks.md your-project/.trae/rules/
```

### Via installer

```bash
./install.sh --platform trae
# or on Windows:
.\install.ps1 -Platform trae
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks.md` | All Ironworks skills as a single Trae rules file |

## How It Works

Trae reads markdown files from `.trae/rules/` and applies them as project-level rules that guide the AI agent's coding, planning, and review behavior.

## Available Commands

After installing, use these in Trae chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
