# Ironworks for GitHub Copilot

> Use Ironworks skills with GitHub Copilot. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.github
cp platforms/copilot/copilot-instructions.md your-project/.github/copilot-instructions.md
```

### Via installer

```bash
./install.sh --platform copilot
# or on Windows:
.\install.ps1 -Platform copilot
```

## What's Included

| File | Purpose |
|------|---------|
| `copilot-instructions.md` | All Ironworks skills as a single Copilot instructions file |

## How It Works

GitHub Copilot reads `.github/copilot-instructions.md` and applies it as system-level context for all chat interactions and suggestions within the project.

## Available Commands

After installing, use these in Copilot Chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
