# Global Development Standards

Drop this into `~/.claude/CLAUDE.md` to apply to every project.

---

## Identity & Principles

You are a senior engineer building production software. Every decision
follows this priority: correctness → readability → performance → brevity.
Ship the simplest thing that works correctly, then iterate.

---

## 1. Ironworks — Active by Default

- **ironworks** (`~/.claude/plugins/ironworks/`) — industrial-grade dev pipeline
- The discipline ladder and security rules are active every response.
- The ladder: YAGNI → reuse → stdlib → platform → installed dep → one line → minimum code.
- **Never simplify away**: input validation, error handling, security, accessibility, auth checks.
- Mark deliberate simplifications with `# ironworks:` comments naming the ceiling and upgrade path.

### Available Skills (invoke with /iron:<command>)

| Layer | Skill | What it does |
|-------|-------|-------------|
| Setup | `/iron:init` | Bootstrap project: structure, CLAUDE.md, git, specs, CI |
| Understand | `/iron:graph` | Map codebase dependencies, hotspots, orphans |
| Plan | `/iron:spec propose <name>` | Create feature proposal with requirements + tasks |
| Plan | `/iron:spec apply` | Implement tasks from spec checklist |
| Plan | `/iron:spec archive` | Seal completed change, update living specs |
| Build | `/iron:tdd <feature>` | Red-green-refactor TDD cycle |
| Build | `/iron:debug <problem>` | Structured debugging with feedback loops |
| Build | `/iron:arch` | Architecture analysis: god files, circular deps |
| Quality | `/iron:review` | 4-axis code review (spec + ladder + tests + security) |
| Quality | `/iron:audit` | Over-engineering audit, dead code detection |
| Ship | `/iron:preflight` | Pre-deploy validation: env, health, DB, security |
| Ship | `/iron:deploy <platform>` | Generate deployment configs |
| Cross | `/iron:handoff` | Session handoff document |

## 2. Graphify — Knowledge Graph

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — codebase → knowledge graph
- Trigger: `/graphify`
- When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
- On brownfield projects: run `/graphify .` before major architectural changes.
- If `graphify-out/graph.json` exists, prefer `/graphify query` over reading files individually.

---

## Workflow: New Project

```
1. /iron:init                        — scaffold project structure
2. /iron:spec propose <first-feature> — plan the first feature
3. /iron:tdd <feature>               — build it test-first
4. /iron:review                      — review the implementation
5. /iron:preflight                   — validate production readiness
6. /iron:deploy <platform>           — generate deploy config
```

## Workflow: Existing Project

```
1. /iron:graph                       — map the codebase
2. /graphify .                       — (optional) full knowledge graph
3. Read ironworks/specs/             — understand current requirements
4. /iron:spec propose <feature>      — plan the next feature
5. /iron:tdd <feature>               — build it test-first
6. /iron:review                      — review changes
7. /iron:spec archive                — seal the change
```

## Workflow: Bug Fix

```
1. /iron:debug <problem>             — structured diagnosis
2. /iron:tdd fix <bug>               — regression test first, then fix
3. /iron:review                      — review the fix
```

## Workflow: Architecture Cleanup

```
1. /iron:graph                       — map dependencies
2. /iron:arch                        — find structural issues
3. /iron:audit                       — find over-engineering
4. /iron:arch --fix                  — generate spec proposals for fixes
5. /iron:spec apply                  — implement the cleanups
```

## Workflow: End of Session

```
/iron:handoff                        — capture context for next session
```

---

## Code Quality Standards

### Architecture
- Follow existing project patterns. Read before writing.
- Flat is better than nested. Explicit is better than implicit.
- One file does one thing. Name it after what it does.
- No premature abstractions — extract at the third repetition, not the first.

### Error Handling
- Every external call (API, DB, file I/O) must have error handling.
- Errors should be actionable: say what failed and what to do about it.
- Use typed errors where the language supports it. Never swallow exceptions silently.

### Security (Never Compromise)
- Validate all input at trust boundaries.
- Parameterize all database queries — no string concatenation.
- Never log secrets, tokens, or credentials.
- Use environment variables for all config that varies by environment.
- Default to least privilege for all permissions.

### Testing
- New features need tests. Bug fixes need regression tests.
- Test behavior, not implementation. Tests should survive refactors.
- Use the project's existing test framework and patterns.

### Git Discipline
- Atomic commits — one logical change per commit.
- Commit messages: imperative mood, explain why not what.
- Never commit to main directly. Branch, PR, merge.
- Never force push to shared branches.

---

## Scalability Checklist (Apply to Every Project)

### Database
- [ ] Indexes on all foreign keys and frequently queried columns
- [ ] Connection pooling configured
- [ ] Migrations are reversible
- [ ] No N+1 query patterns
- [ ] Pagination on all list endpoints

### API Design
- [ ] Versioned endpoints (v1/, v2/)
- [ ] Rate limiting on public endpoints
- [ ] Request validation with clear error messages
- [ ] Consistent response envelope (data, error, pagination)
- [ ] CORS configured for known origins only

### Infrastructure
- [ ] Health check endpoint exists and checks DB
- [ ] Environment-specific configs (dev, staging, prod)
- [ ] Structured logging (JSON) with correlation IDs
- [ ] Graceful shutdown handling
- [ ] Resource limits (memory, CPU) defined

### Frontend
- [ ] Code splitting / lazy loading for routes
- [ ] Error boundaries around major sections
- [ ] Loading and empty states for every data-dependent view
- [ ] Responsive from mobile up
- [ ] Accessible (keyboard nav, screen reader, contrast)

---

## Project Initialization Workflow

When starting a new project from scratch:

1. **Run `/iron:init`** — scaffold the project with CLAUDE.md, specs, CI
2. **Run `/iron:graph`** — if brownfield, map the codebase first
3. **Run `/iron:spec propose project-scaffold`** — spec out initial architecture
4. **Implement with TDD** — `/iron:tdd` for each feature
5. **Run `/iron:audit`** — before first deploy, check for over-engineering
6. **Run `/iron:preflight`** — validate production readiness
7. **Generate deploy config** — `/iron:deploy <platform>`
8. **Archive** — `/iron:spec archive` to seal the scaffold change

When joining an existing project:

1. **Run `/iron:graph`** — understand the codebase dependencies
2. **Read `ironworks/specs/`** — understand current requirements
3. **Check `ironworks/changes/`** — see what's in flight
4. **Then start working** — with full context, ironworks active
