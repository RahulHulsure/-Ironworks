---
name: iron-help
description: "Ironworks command reference."
---

# /iron:help

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
| `/iron:graph path <A> <B>` | Understand | Find the dependency path between two files |
| `/iron:graph --deep` | Understand | Include transitive dependencies in the graph |
| `/iron:graph --watch` | Understand | Rebuild graph on file changes |
| `/iron:graph --update` | Understand | Incrementally update an existing graph |
| `/iron:spec propose <name>` | Plan | Create a feature proposal with requirements, design, tasks |
| `/iron:spec show` | Plan | View current specs and in-flight changes |
| `/iron:spec apply` | Plan | Implement tasks from the current change's checklist |
| `/iron:spec archive` | Plan | Seal completed change and update living specs |
| `/iron:spec explore` | Plan | Interactively explore spec details and relationships |
| `/iron:spec verify` | Plan | Verify spec implementation against requirements |
| `/iron:spec update` | Plan | Update an existing spec with new requirements or changes |
| `/iron:tdd <feature>` | Build | Start a TDD cycle: red → green → refactor |
| `/iron:tdd fix <bug>` | Build | Bug fix via TDD (regression test first) |
| `/iron:tdd continue` | Build | Resume where the last TDD cycle left off |
| `/iron:debug <problem>` | Build | Structured debugging: reproduce → hypothesize → fix |
| `/iron:debug narrow` | Build | Narrow down a bug by bisecting code paths |
| `/iron:arch` | Build | Architecture scan: god files, circular deps, layer violations |
| `/iron:arch --fix` | Build | Scan + generate refactor proposals as ironworks specs |
| `/iron:review` | Quality | Code review: specs + discipline ladder + tests + security |
| `/iron:review --staged` | Quality | Review only staged changes |
| `/iron:review --fix` | Quality | Review and auto-fix blocking issues |
| `/iron:review --over-engineering` | Quality | Focus review on over-engineered patterns |
| `/iron:audit` | Quality | Codebase audit for over-engineering and dead code |
| `/iron:audit --fix` | Quality | Audit + delete dead code and inline simple abstractions |
| `/iron:audit debt` | Quality | Assess and categorize technical debt across the codebase |
| `/iron:preflight` | Ship | Pre-deploy checklist: env, health, DB, security, errors, logging |
| `/iron:preflight --fix` | Ship | Run preflight and auto-fix what's safe |
| `/iron:preflight --platform do` | Ship | Add DigitalOcean-specific checks |
| `/iron:deploy docker` | Ship | Generate Dockerfile + docker-compose.yml |
| `/iron:deploy do` | Ship | Generate DigitalOcean .do/app.yaml |
| `/iron:deploy vercel` | Ship | Generate vercel.json |
| `/iron:deploy aws` | Ship | Generate AWS deployment files (Dockerfile, buildspec, ECS) |
| `/iron:deploy railway` | Ship | Generate railway.toml |
| `/iron:deploy fly` | Ship | Generate fly.toml with health checks and scaling |
| `/iron:deploy migrate <source>` | Ship | Migrate config from heroku/render/railway/fly/docker-compose/aws-ecs |
| `/iron:deploy preview` | Ship | Generate CI config for PR preview environments |
| `/iron:handoff [--for-agent\|--for-human]` | Cross | Compress session into handoff (agent-optimized or human-readable) |
| `/iron:help` | -- | This reference |

## Recommended Workflows

```
New project:      /iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
Existing project: /iron:graph → /iron:spec propose → /iron:tdd → /iron:review → /iron:spec archive
Bug fix:          /iron:debug → /iron:tdd fix → /iron:review
Before deploy:    /iron:preflight --platform <platform>
Architecture:     /iron:graph → /iron:arch → /iron:arch --fix
End of session:   /iron:handoff
```

## Always Active

Discipline ladder and security rules apply every response. See AGENTS.md.
