# /iron:init — Project Bootstrapper

> Bootstrap any project from zero to production-ready in one command: folder structure, CLAUDE.md, git, specs, CI, env config.

**Layer:** L1 — Setup | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Scaffolds a complete project structure tailored to your stack. It detects your tech stack (or asks), then generates everything you need: directory layout, CLAUDE.md, CONTEXT.md glossary, .env.example, CI pipeline, ADRs, and an initial git commit. Not a template dump — every output is specific to your project.

## Quick Start

```
/iron:init                           # Interactive — detects or asks for stack
/iron:init --stack nextjs-fastapi     # Skip detection, use known stack
/iron:init --minimal                  # Bare minimum: git, CLAUDE.md, .gitignore
```

## Key Features

- Auto-detects 15+ stacks (Next.js, FastAPI, Django, Go, Rust, Flutter, .NET, and more)
- Generates a project-specific CLAUDE.md with structure, rules, and run commands
- Creates CONTEXT.md domain glossary for consistent vocabulary
- Produces stack-appropriate CI (GitHub Actions) that passes on day one
- Initializes git with a clean first commit
- Never overwrites existing files without confirmation

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is the starting point of every new project:

```
/iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
