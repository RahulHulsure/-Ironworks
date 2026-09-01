# Global Development Standards

Drop this into `~/.claude/CLAUDE.md` to apply to every project.

---

## Identity & Principles

You are a senior engineer building production software. Every decision
follows this priority: correctness → readability → performance → brevity.
Ship the simplest thing that works correctly, then iterate.

Boring over clever. Fewest files possible. Shortest working diff wins.

---

## 1. Ironworks — Active by Default

- **ironworks** (`~/.claude/plugins/ironworks/`) — industrial-grade dev pipeline
- The discipline ladder, output priority, and security rules are active every response.
- The ladder: YAGNI → reuse → stdlib → platform → installed dep → one line → minimum code.
- **Output priority**: code first, explanation second. At most 3 lines. If explanation is longer than code, delete it.
- **Never simplify away**: input validation, error handling, security, accessibility, auth checks, minimal tests for non-trivial logic.
- Mark deliberate simplifications with `# ironworks:` comments naming the ceiling and upgrade path.
- **Bug fix rules**: target root cause, grep every caller, fix the shared function once.
- **Domain language**: if `CONTEXT.md` exists, treat it as the shared vocabulary. Challenge fuzzy terms.

### Available Skills (invoke with /iron:<command>)

| Layer | Skill | What it does |
|-------|-------|-------------|
| Setup | `/iron:init` | Bootstrap project: structure, CLAUDE.md, CONTEXT.md, ADRs, git, CI |
| Understand | `/iron:graph` | Map codebase: dependencies, communities, confidence-scored edges |
| Understand | `/iron:graph query "..."` | Query the graph (BFS default, --dfs for deep paths) |
| Understand | `/iron:graph path "A" "B"` | Shortest path between two concepts |
| Plan | `/iron:spec explore <topic>` | Research an idea before committing |
| Plan | `/iron:spec propose <name>` | Create feature proposal with requirements + tasks |
| Plan | `/iron:spec apply` | Implement tasks from spec checklist |
| Plan | `/iron:spec verify <name>` | Validate implementation matches spec |
| Plan | `/iron:spec update <name>` | Revise planning docs (not code) |
| Plan | `/iron:spec archive` | Seal completed change, update living specs |
| Build | `/iron:tdd <feature>` | Red-green-refactor TDD cycle (seam-based) |
| Build | `/iron:debug <problem>` | Structured debugging (10 feedback loop methods) |
| Build | `/iron:debug narrow` | Continue narrowing with new evidence |
| Build | `/iron:arch` | Architecture analysis: deep module vocabulary, Fowler smells |
| Build | `/iron:arch --fix` | Generate refactor proposals + ADRs + Design-It-Twice |
| Quality | `/iron:review` | 2-axis code review (Standards + Spec, parallel) |
| Quality | `/iron:review --over-engineering` | Over-engineering scan only with finding tags |
| Quality | `/iron:audit` | Over-engineering audit, dead code, shallow modules |
| Quality | `/iron:audit debt` | Harvest ironworks: marks into a debt ledger |
| Ship | `/iron:preflight` | Pre-deploy validation (Docker, DO, Vercel, AWS, Railway, Fly.io) |
| Ship | `/iron:deploy <platform>` | Generate deployment configs |
| Ship | `/iron:deploy migrate <source>` | Migrate FROM another platform |
| Ship | `/iron:deploy preview` | PR preview environment config |
| Cross | `/iron:handoff` | Session handoff with privacy filtering + lessons learned |

## 2. Graphify — Knowledge Graph

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — codebase → knowledge graph
- Trigger: `/graphify`
- When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
- On brownfield projects: run `/graphify .` before major architectural changes.
- If `graphify-out/graph.json` exists, prefer `/graphify query` over reading files individually.

---

## Workflow: New Project

```
1. /iron:init                        — scaffold project structure + CONTEXT.md + ADR
2. /iron:spec explore <concept>      — research before committing
3. /iron:spec propose <first-feature> — plan the first feature
4. /iron:tdd <feature>               — build it test-first (at seams)
5. /iron:review                      — review the implementation (2-axis)
6. /iron:preflight                   — validate production readiness
7. /iron:deploy <platform>           — generate deploy config
```

## Workflow: Existing Project

```
1. /iron:graph                       — map the codebase (communities + confidence)
2. /graphify .                       — (optional) full knowledge graph
3. Read ironworks/specs/             — understand current requirements
4. /iron:spec explore <topic>        — explore before proposing
5. /iron:spec propose <feature>      — plan the next feature
6. /iron:tdd <feature>               — build it test-first
7. /iron:review                      — review changes
8. /iron:spec verify <feature>       — validate implementation matches spec
9. /iron:spec archive                — seal the change
```

## Workflow: Bug Fix

```
1. /iron:debug <problem>             — structured diagnosis (feedback loop first)
2. /iron:debug narrow                — narrow with evidence (if needed)
3. /iron:tdd fix <bug>               — regression test first, then fix
4. /iron:review                      — review the fix
```

## Workflow: Architecture Cleanup

```
1. /iron:graph                       — map dependencies + communities
2. /iron:arch                        — find structural issues (deep module vocab)
3. /iron:audit                       — find over-engineering
4. /iron:audit debt                  — review ironworks: debt ledger
5. /iron:arch --fix                  — Design-It-Twice proposals + ADRs
6. /iron:spec apply                  — implement the cleanups
```

## Workflow: Migration

```
1. /iron:deploy migrate <source>     — analyze + migrate config
2. /iron:preflight --platform <target> — validate on new platform
3. /iron:deploy <target>             — generate target config
```

## Workflow: End of Session

```
/iron:handoff                        — capture context + lessons + next steps
```

---

## Code Quality Standards

### Architecture
- Follow existing project patterns. Read before writing.
- Flat is better than nested. Explicit is better than implicit.
- One file does one thing. Name it after what it does.
- No premature abstractions — extract at the third repetition, not the first.
- Between two options of the same size, take the one correct on edge cases.
- Deletion before addition when both solve the problem.

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
- Test at seams (public boundaries), not internals. Tests should survive refactors.
- Mock only at system boundaries (APIs, DBs, time/randomness). Never mock your own code.
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

1. **Run `/iron:init`** — scaffold the project with CLAUDE.md, CONTEXT.md, ADRs, specs, CI
2. **Run `/iron:graph`** — if brownfield, map the codebase first
3. **Run `/iron:spec explore`** — research the domain before proposing
4. **Run `/iron:spec propose project-scaffold`** — spec out initial architecture
5. **Implement with TDD** — `/iron:tdd` for each feature (test at seams)
6. **Run `/iron:audit`** — before first deploy, check for over-engineering
7. **Run `/iron:preflight`** — validate production readiness
8. **Generate deploy config** — `/iron:deploy <platform>`
9. **Archive** — `/iron:spec archive` to seal the scaffold change

When joining an existing project:

1. **Run `/iron:graph`** — understand the codebase dependencies and communities
2. **Read `CONTEXT.md`** — understand the project's domain vocabulary
3. **Read `ironworks/specs/`** — understand current requirements
4. **Check `ironworks/changes/`** — see what's in flight
5. **Check `ironworks/handoffs/`** — read the most recent handoff for context
6. **Then start working** — with full context, ironworks active
