# Ironworks for Antigravity

> Use Ironworks skills with Antigravity. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.agent/skills/ironworks
cp platforms/antigravity/skills/ironworks/SKILL.md your-project/.agent/skills/ironworks/SKILL.md
```

### Via installer

```bash
./install.sh --platform antigravity
# or on Windows:
.\install.ps1 -Platform antigravity
```

## What's Included

| File | Purpose |
|------|---------|
| `skills/ironworks/SKILL.md` | All Ironworks skills as an Antigravity skill definition |

## How It Works

Antigravity reads skill definitions from `.agent/skills/` and loads them as structured capabilities. Each skill directory contains a `SKILL.md` that defines the agent's behavior.

## Available Commands

After installing, use these in Antigravity chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
