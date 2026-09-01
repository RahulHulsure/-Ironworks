# Ironworks for Junie

> Use Ironworks skills with Junie. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.junie
cp platforms/junie/guidelines.md your-project/.junie/guidelines.md
```

### Via installer

```bash
./install.sh --platform junie
# or on Windows:
.\install.ps1 -Platform junie
```

## What's Included

| File | Purpose |
|------|---------|
| `guidelines.md` | All Ironworks skills as a single Junie guidelines file |

## How It Works

Junie reads `.junie/guidelines.md` and applies it as project guidelines that shape how the agent plans, generates, and reviews code throughout the session.

## Available Commands

After installing, use these in Junie chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
