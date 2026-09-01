# Ironworks for Augment Code

> Use Ironworks skills with Augment Code. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
cp platforms/augment/augment-guidelines your-project/.augment-guidelines
```

### Via installer

```bash
./install.sh --platform augment
# or on Windows:
.\install.ps1 -Platform augment
```

## What's Included

| File | Purpose |
|------|---------|
| `augment-guidelines` | All Ironworks skills as a single Augment guidelines file |

## How It Works

Augment Code reads the `.augment-guidelines` file at the project root and uses it as persistent coding guidelines that shape all code generation and review tasks.

## Available Commands

After installing, use these in Augment chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
