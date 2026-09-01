# Ironworks for Aider

> Use Ironworks skills with Aider. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
cp platforms/aider/CONVENTIONS.md your-project/CONVENTIONS.md
```

### Via installer

```bash
./install.sh --platform aider
# or on Windows:
.\install.ps1 -Platform aider
```

## What's Included

| File | Purpose |
|------|---------|
| `CONVENTIONS.md` | All Ironworks skills as a single Aider conventions file |

## How It Works

Aider reads `CONVENTIONS.md` at the project root and uses it to enforce coding conventions and workflow rules across all code generation and editing tasks.

## Available Commands

After installing, use these in Aider chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
