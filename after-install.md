# Ironworks — Installed

Restart Claude Code or start a new session to activate.

## What's Active

The following principles are **always on** (no command needed):
- Priority stack: correct → clear → performant → brief
- Discipline ladder: YAGNI → reuse → stdlib → platform → installed dep → one line → minimum code
- Security rules: validation, parameterized queries, no secrets in code, auth checks
- Spec awareness: reads `ironworks/specs/` before making changes

## Available Commands

| Command | What it does |
|---------|-------------|
| `/iron:init` | Bootstrap a project from zero |
| `/iron:graph` | Map codebase dependencies |
| `/iron:spec` | Spec-driven feature development |
| `/iron:tdd` | Test-driven development cycle |
| `/iron:debug` | Structured debugging |
| `/iron:arch` | Architecture analysis |
| `/iron:review` | Smart code review (2 parallel axes) |
| `/iron:audit` | Over-engineering audit |
| `/iron:preflight` | Pre-deploy validation |
| `/iron:deploy` | Deployment config generation |
| `/iron:handoff` | Session handoff |
| `/iron:help` | Command reference |

## Quick Start

```
/iron:help                    — see all commands
/iron:init                    — scaffold a new project
/iron:graph                   — map an existing codebase
/iron:spec propose <feature>  — plan a feature before building
```

## Security Note

Ironworks skills can read and modify files in your project. Only install
in environments where you trust the code being executed. Review AGENTS.md
and the individual SKILL.md files to understand what each command does.
