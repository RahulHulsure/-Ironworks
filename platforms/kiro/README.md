# Ironworks for Kiro

> Use Ironworks skills with Kiro. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.kiro/steering
cp platforms/kiro/steering/ironworks.md your-project/.kiro/steering/
```

### Via installer

```bash
./install.sh --platform kiro
# or on Windows:
.\install.ps1 -Platform kiro
```

## What's Included

| File | Purpose |
|------|---------|
| `steering/ironworks.md` | All Ironworks skills as a single Kiro steering document |

## How It Works

Kiro reads markdown files from `.kiro/steering/` and uses them as steering documents that persistently guide the agent's planning, coding, and review behavior.

## Available Commands

After installing, use these in Kiro chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
