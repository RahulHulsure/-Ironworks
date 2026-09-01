# Ironworks for Gemini CLI

> Use Ironworks skills with Gemini CLI. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
cp platforms/gemini/GEMINI.md your-project/GEMINI.md
```

### Via installer

```bash
./install.sh --platform gemini
# or on Windows:
.\install.ps1 -Platform gemini
```

## What's Included

| File | Purpose |
|------|---------|
| `GEMINI.md` | All Ironworks skills as a single Gemini context file |

## How It Works

Gemini CLI reads `GEMINI.md` at the project root and applies it as persistent coding context that guides the agent's behavior throughout the session.

## Available Commands

After installing, use these in Gemini CLI:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
