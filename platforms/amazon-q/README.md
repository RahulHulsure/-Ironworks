# Ironworks for Amazon Q Developer

> Use Ironworks skills with Amazon Q Developer. 12 skills · 7 layers · 60+ commands.

**Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)** — Industrial-grade development pipeline for AI coding agents.

## Install

### Quick (copy files)

```bash
# From the ironworks repo root:
mkdir -p your-project/.amazonq/rules
cp platforms/amazon-q/rules/ironworks.md your-project/.amazonq/rules/
```

### Via installer

```bash
./install.sh --platform amazon-q
# or on Windows:
.\install.ps1 -Platform amazon-q
```

## What's Included

| File | Purpose |
|------|---------|
| `rules/ironworks.md` | All Ironworks skills as a single Amazon Q rules file |

## How It Works

Amazon Q Developer reads markdown files from `.amazonq/rules/` and applies them as project-level rules that guide code generation, reviews, and agent behavior.

## Available Commands

After installing, use these in Amazon Q chat:

```
/iron:help                    # See all commands
/iron:init                    # Bootstrap a project
/iron:graph                   # Map codebase dependencies
/iron:spec propose <feature>  # Plan before building
/iron:review                  # Smart code review
```

→ [Full command list](https://github.com/RahulHulsure/-Ironworks#-all-12-skills) | [All platforms](https://github.com/RahulHulsure/-Ironworks#-supported-platforms)
