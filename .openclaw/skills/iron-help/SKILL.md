---
name: iron-help
description: "Show all Ironworks commands, what they do, and when to use each one."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:help — Ironworks Command Reference

Print this reference when invoked. No preamble, no extras.

## Commands

| Command | Layer | What it does |
|---------|-------|-------------|
| `/iron:init` | Setup | Bootstrap a project: folder structure, CLAUDE.md, git, specs, CI |
| `/iron:graph` | Understand | Map codebase dependencies, hotspots, orphans, circular deps |
| `/iron:graph query "..."` | Understand | Ask questions about the codebase structure |
| `/iron:graph deps <file>` | Understand | Show what a file depends on and what depends on it |
| `/iron:graph hotspots` | Understand | Find the most-connected files |
| `/iron:graph orphans` | Understand | Find files nothing imports |
| `/iron:spec propose <name>` | Plan | Create a feature proposal with requirements, design, tasks |
| `/iron:spec show` | Plan | View current specs and in-flight changes |
| `/iron:spec apply` | Plan | Implement tasks from the current change's checklist |
| `/iron:spec archive` | Plan | Seal completed change and update living specs |
| `/iron:tdd <feature>` | Build | Start a TDD cycle: red → green → refactor |
| `/iron:tdd fix <bug>` | Build | Bug fix via TDD (regression test first) |
| `/iron:tdd continue` | Build | Resume where the last TDD cycle left off |
| `/iron:debug <problem>` | Build | Structured debugging: reproduce → hypothesize → fix |
| `/iron:arch` | Build | Architecture scan: god files, circular deps, layer violations |
| `/iron:arch --fix` | Build | Scan + generate refactor proposals as ironworks specs |
| `/iron:review` | Quality | Code review: specs + discipline ladder + tests + security |
| `/iron:review --staged` | Quality | Review only staged changes |
| `/iron:review --fix` | Quality | Review and auto-fix blocking issues |
| `/iron:audit` | Quality | Codebase audit for over-engineering and dead code |
| `/iron:audit --fix` | Quality | Audit + delete dead code and inline simple abstractions |
| `/iron:preflight` | Ship | Pre-deploy checklist: env, health, DB, security, errors, logging |
| `/iron:preflight --fix` | Ship | Run preflight and auto-fix what's safe |
| `/iron:preflight --platform do` | Ship | Add DigitalOcean-specific checks |
| `/iron:deploy docker` | Ship | Generate Dockerfile + docker-compose.yml |
| `/iron:deploy do` | Ship | Generate DigitalOcean .do/app.yaml |
| `/iron:deploy vercel` | Ship | Generate vercel.json |
| `/iron:handoff` | Cross | Compress session into a handoff document |
| `/iron:handoff --for-agent` | Cross | Handoff optimized for another Claude session |
| `/iron:handoff --for-human` | Cross | Handoff optimized for a team member |
| `/iron:help` | — | This reference |

## Recommended Workflows

```
New project:      /iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
Existing project: /iron:graph → /iron:spec propose → /iron:tdd → /iron:review → /iron:spec archive
Bug fix:          /iron:debug → /iron:tdd fix → /iron:review
Before deploy:    /iron:preflight --platform <platform>
Architecture:     /iron:graph → /iron:arch → /iron:arch --fix
End of session:   /iron:handoff
```

## Layers

```
Layer 0  DISCIPLINE   Always active — priority stack, discipline ladder, security rules
Layer 1  SETUP        /iron:init — project bootstrap
Layer 2  UNDERSTAND   /iron:graph — dependency map and codebase queries
Layer 3  PLAN         /iron:spec — spec-driven feature proposals
Layer 4  BUILD        /iron:tdd, /iron:debug, /iron:arch — construction and quality
Layer 5  QUALITY      /iron:review, /iron:audit — review and simplification
Layer 6  SHIP         /iron:preflight, /iron:deploy — deployment validation and config
Layer ∞  CONTINUITY   /iron:handoff — session and team handoffs
```

## Always Active

The Ironworks discipline ladder and security rules are active every response,
even without invoking a specific command. See AGENTS.md for details.
