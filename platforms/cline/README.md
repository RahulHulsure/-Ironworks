# Ironworks for Cline

> Use Ironworks skills with Cline. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** -- Development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.clinerules
cp platforms/cline/ironworks.md your-project/.clinerules/
```

### Via installer

```bash
./install.sh --platform cline
# or on Windows:
.\install.ps1 -Platform cline
```

## What's Included

| File | Purpose |
|------|---------|
| `ironworks.md` | All Ironworks skills as a single Cline rules file |

## How It Works

Cline reads files from the `.clinerules/` directory and injects them as project-level instructions that guide the agent's behavior across all tasks.

## Available Commands

After installing, use these in Cline chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
