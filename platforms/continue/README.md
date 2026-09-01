# Ironworks for Continue

> Use Ironworks skills with Continue. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
cp platforms/continue/continuerules your-project/.continuerules
```

### Via installer

```bash
./install.sh --platform continue
# or on Windows:
.\install.ps1 -Platform continue
```

## What's Included

| File | Purpose |
|------|---------|
| `continuerules` | All Ironworks skills as a single Continue rules file |

## How It Works

Continue reads the `.continuerules` file at the project root and applies it as persistent context rules that guide the assistant's behavior in chat and edits.

## Available Commands

After installing, use these in Continue chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
