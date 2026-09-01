# Ironworks

**Industrial-grade development pipeline for AI coding agents.**

12 skills across 7 layers — from project bootstrap to deploy preflight, with spec-driven features, TDD, knowledge graphs, architecture analysis, and structured debugging.

```
/iron:init        → project goes from zero to production-ready
/iron:graph       → map the codebase before you touch it
/iron:spec        → features start as specs, not guesses
/iron:tdd         → red-green-refactor, enforced
/iron:debug       → structured debugging with feedback loops
/iron:arch        → find god files, circular deps, layer violations
/iron:review      → code review that checks substance, not style
/iron:audit       → find over-engineering and dead code
/iron:preflight   → deploy only when the checklist passes
/iron:deploy      → generate platform-specific deploy configs
/iron:handoff     → compress session context for continuity
/iron:help        → command reference
```

## Install

```bash
claude plugin install ironworks
```

Or from a local clone:
```bash
claude plugin install /path/to/this/repo
```

## The Layered Architecture

Ironworks organizes skills into layers that compose naturally:

```
Layer 0  DISCIPLINE   Always active — priority stack, discipline ladder, security rules
Layer 1  SETUP        /iron:init — project bootstrap
Layer 2  UNDERSTAND   /iron:graph — dependency map and codebase queries
Layer 3  PLAN         /iron:spec — spec-driven feature proposals
Layer 4  BUILD        /iron:tdd, /iron:debug, /iron:arch — construction and quality
Layer 5  QUALITY      /iron:review, /iron:audit — review and simplification
Layer 6  SHIP         /iron:preflight, /iron:deploy — deployment validation
Layer ∞  CONTINUITY   /iron:handoff — session and team handoffs
```

Each layer builds on the ones below it. You don't need all layers for every task — use what fits.

## Skills Reference

### Layer 0: Always Active (no command needed)

The **discipline ladder** and **security rules** run every response:

- **Priority stack**: correct → clear → performant → brief
- **Discipline ladder**: YAGNI → reuse → stdlib → platform → installed dep → one line → minimum code
- **Never compromise**: input validation, error handling, parameterized queries, auth checks, accessibility
- **Spec awareness**: reads `ironworks/specs/` before making changes

### Layer 1: `/iron:init` — Project Bootstrapper

One command to scaffold a project: folder structure, CLAUDE.md, git, specs directory, CI template, env config. Detects your stack (Next.js, FastAPI, Django, Go, Rust, and more).

```
/iron:init                           # Interactive — detects your stack
/iron:init --stack nextjs-fastapi    # Skip detection
/iron:init --minimal                 # Just git + CLAUDE.md + .gitignore
```

### Layer 2: `/iron:graph` — Codebase Dependency Map

Map the codebase before making changes. Traces imports, identifies hotspots (god files), finds orphaned code, detects circular dependencies.

```
/iron:graph                          # Full dependency map
/iron:graph query "how does auth connect to payments?"
/iron:graph deps backend/services/auth.py
/iron:graph hotspots                 # Most-connected files
/iron:graph orphans                  # Files nothing imports
```

### Layer 3: `/iron:spec` — Spec-Driven Development

Every feature starts as a spec before it becomes code. Propose → design → implement → archive.

```
/iron:spec propose add-auth          # Create proposal + requirements + design + tasks
/iron:spec apply                     # Implement tasks one by one
/iron:spec archive                   # Seal it, update living specs
/iron:spec show                      # View current state
```

**What it creates:**
```
ironworks/changes/add-auth/
├── proposal.md       # Why we're doing this
├── requirements.md   # Testable scenarios
├── design.md         # Technical approach
└── tasks.md          # Ordered implementation checklist
```

### Layer 4: `/iron:tdd` — Test-Driven Development

Write the test first (red), make it pass with minimum code (green), then clean up (refactor). Enforces the cycle.

```
/iron:tdd <feature>                  # Start a TDD cycle
/iron:tdd fix <bug>                  # Bug fix: regression test first
/iron:tdd continue                   # Resume last cycle
```

### Layer 4: `/iron:debug` — Structured Debugging

Reproduce → hypothesize → instrument → narrow → fix → verify. No shotgun debugging.

```
/iron:debug <problem description>    # Start structured debugging
```

### Layer 4: `/iron:arch` — Architecture Analysis

Scan for structural problems: god files, circular dependencies, layer violations, missing boundaries, abstraction leaks, dead code.

```
/iron:arch                           # Full scan
/iron:arch --fix                     # Scan + generate refactor proposals
```

### Layer 5: `/iron:review` — Smart Code Review

Reviews on four axes: spec compliance, discipline ladder, test coverage, security basics.

```
/iron:review                         # Review uncommitted changes
/iron:review --staged                # Staged changes only
/iron:review --fix                   # Review + auto-fix blockers
```

**Verdicts:** `SHIP IT ✓` · `FIX AND RESHIP` · `RETHINK`

### Layer 5: `/iron:audit` — Simplification Audit

Find unnecessary abstractions, speculative features, overbuilt patterns, and dead code.

```
/iron:audit                          # Full audit
/iron:audit --fix                    # Audit + auto-simplify low-risk items
```

### Layer 6: `/iron:preflight` — Deploy Preflight

Validates production readiness: env vars, health endpoints, DB migrations, secrets, error handling, CORS, rate limiting.

```
/iron:preflight                      # Full check
/iron:preflight --fix                # Auto-fix what's safe
/iron:preflight --platform do        # DigitalOcean-specific checks
/iron:preflight --platform docker    # Docker-specific checks
```

### Layer 6: `/iron:deploy` — Deployment Config

Generate production-ready deployment configurations.

```
/iron:deploy docker                  # Dockerfile + docker-compose.yml
/iron:deploy do                      # DigitalOcean .do/app.yaml
/iron:deploy vercel                  # vercel.json
/iron:deploy railway                 # railway.toml
```

### Layer ∞: `/iron:handoff` — Session Handoff

Compress the session into a handoff document for continuity.

```
/iron:handoff                        # General handoff
/iron:handoff --for-agent            # Optimized for another Claude session
/iron:handoff --for-human            # Optimized for a team member
```

## Recommended Workflows

```
New project:      /iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
Existing project: /iron:graph → /iron:spec propose → /iron:tdd → /iron:review → /iron:spec archive
Bug fix:          /iron:debug → /iron:tdd fix → /iron:review
Before deploy:    /iron:preflight --platform <platform>
Architecture:     /iron:graph → /iron:arch → /iron:arch --fix
End of session:   /iron:handoff
```

## Global CLAUDE.md

For a drop-in `~/.claude/CLAUDE.md` that wires Ironworks into every project, see [`docs/CLAUDE-GLOBAL.md`](docs/CLAUDE-GLOBAL.md).

For a project-level CLAUDE.md template, see [`docs/CLAUDE-PROJECT-TEMPLATE.md`](docs/CLAUDE-PROJECT-TEMPLATE.md).

## Philosophy

- **Specs before code.** A feature without a spec is a guess. Guesses cause rewrites.
- **Simplest thing that works.** Not the cleverest, not the most abstract — the simplest.
- **Never compromise safety.** Validation, error handling, auth, and accessibility survive every simplification.
- **Test behavior, not implementation.** Tests that break on refactors are worse than no tests.
- **Understand before changing.** Map the codebase, read the specs, then write code.
- **Ship, then iterate.** The minimal version that works beats the perfect version that doesn't exist.

## Works With

Ironworks complements other tools in the ecosystem:

- **Graphify** — full knowledge graphs for deep codebase understanding (Layer 2 complement)
- **Ponytail** — YAGNI-first coding discipline (Layer 0 shares the same philosophy)
- **AgentMemory** — persistent cross-session memory (Layer ∞ complement)

## License

MIT — use it, modify it, share it.
