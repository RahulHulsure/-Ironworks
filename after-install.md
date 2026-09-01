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
| `ironworks:iron-init` | Bootstrap a project from zero |
| `ironworks:iron-graph` | Map codebase dependencies |
| `ironworks:iron-spec` | Spec-driven feature development |
| `ironworks:iron-tdd` | Test-driven development cycle |
| `ironworks:iron-debug` | Structured debugging |
| `ironworks:iron-arch` | Architecture analysis |
| `ironworks:iron-review` | Smart code review (4 axes) |
| `ironworks:iron-audit` | Over-engineering audit |
| `ironworks:iron-preflight` | Pre-deploy validation |
| `ironworks:iron-deploy` | Deployment config generation |
| `ironworks:iron-handoff` | Session handoff |
| `ironworks:iron-help` | Command reference |

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
