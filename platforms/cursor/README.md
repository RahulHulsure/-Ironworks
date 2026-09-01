# Ironworks for Cursor

> Use Ironworks skills with Cursor. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
cp platforms/cursor/rules/*.mdc your-project/.cursor/rules/
```

### Via installer

```bash
./install.sh --platform cursor
# or on Windows:
.\install.ps1 -Platform cursor
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks-discipline.mdc` | Core discipline and workflow enforcement |
| `rules/ironworks-setup-understand.mdc` | Setup and codebase understanding layer |
| `rules/ironworks-plan-build.mdc` | Planning and build execution layer |
| `rules/ironworks-quality.mdc` | Quality assurance and review rules |
| `rules/ironworks-ship.mdc` | Deployment and shipping layer |

## How It Works

Cursor reads `.mdc` files from `.cursor/rules/` and applies them based on the `description` field in each file's frontmatter. Rules activate automatically when context matches.

## Available Commands

After installing, use these in Cursor chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
