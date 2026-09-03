<!-- Ironworks v1.0.0 — https://github.com/RahulHulsure/-Ironworks -->
<!-- Platform adapter: Kilo Code (.kilo/rules/*.md or .kilocode/rules/*.md) -->

# Ironworks — AI Development Pipeline

> Development rules for AI coding agents.
> 12 skills · 7 layers · 60+ commands

Repository: https://github.com/RahulHulsure/-Ironworks
License: MIT · © 2026 Rahul Hulsure

---

## L0 — Always Active (Discipline)

These rules are active on EVERY response. Non-negotiable.

### Priority Stack

1. **Correct** -- does what the spec says, handles edge cases, fails safely
2. **Clear** -- a new team member can read it without a walkthrough
3. **Performant** -- no unnecessary work, no N+1, no blocking calls where async fits
4. **Brief** -- shortest code that satisfies 1–3

### Output Priority

- Code first, then explanation
- Three lines max: what was skipped, when to add it
- If explanation is longer than code, delete the explanation

### Discipline Ladder

Before writing new code, stop at the first rung that holds:

1. Does this need to exist at all? → skip
2. Already in this codebase? → reuse
3. Standard library does it? → use it
4. Native platform feature? → use it
5. Already-installed dependency? → use it
6. Can it be one line? → one line
7. Only then: minimum code that works

### Ironworks Marks

Deliberate simplifications get `# ironworks:` comments naming the ceiling and upgrade path:

```
# ironworks: global lock, per-account locks if throughput matters
# ironworks: O(n^2) scan, index if table exceeds 10k rows
```

### Never Compromise

These survive every simplification -- no exceptions:

- Input validation at trust boundaries
- Error handling on every external call (API, DB, file, network)
- Parameterized queries -- never concatenated SQL
- Auth/authz on protected operations
- Secrets in env vars, never in code
- Typed errors with actionable messages -- never swallow exceptions
- A minimal test for non-trivial logic
- Understanding the problem -- trace first, shortcut the solution, never the reading

### Bug Fix Rules

- Target root cause, not symptom
- Grep every caller of the touched function
- Fix shared function once, not guards in every caller

### Code Standards

- Follow existing patterns -- read before writing
- Flat > nested. Explicit > implicit. One file, one thing
- Extract at third repetition, not first. Deletion before addition
- Atomic commits, imperative messages, never force push shared branches
- Test behavior not implementation. Tests survive refactors

### Domain Language

If `CONTEXT.md` exists, it is the shared vocabulary. Flag term conflicts. Propose canonical terms for vague or overloaded language.

### Scalability Defaults

- **DB:** Indexes on FKs, connection pooling, no N+1, pagination, reversible migrations
- **API:** Versioned endpoints, rate limiting, consistent envelope `{ data, error, meta }`, CORS locked
- **Infra:** Health check, structured logging with correlation IDs, graceful shutdown, env configs
- **Frontend:** Code splitting, error boundaries, loading/empty states, responsive, keyboard accessible

---

## L1 — `/iron:init` — Project Bootstrap

Scaffold from zero to production-ready. Detects stack (16+ supported: Next.js, React, Vue, Angular, SvelteKit, Express, FastAPI, Django, Laravel, Go, Rust, Java/Spring, Scala, Elixir/Phoenix, .NET, Flutter), creates agent rules file, CONTEXT.md, .env.example, ironworks/specs/, docs/adr/, CI config, git init.

**Variants:** `--stack <name>` (skip detection), `--minimal` (git + rules file + .gitignore)

**Rules:** Never overwrite existing files. No placeholder code. Scaffold must pass its own CI.

---

## L2 — `/iron:graph` — Codebase Dependency Map

Map the codebase before making changes. Scans imports/exports, scores edges (EXTRACTED 1.0 = explicit import, INFERRED 0.4–0.9 = shared DB/event bus/API chain, AMBIGUOUS 0.1–0.3 = uncertain). Detects communities via import clustering, finds god nodes (10+ connections), orphans, circular deps, layer violations, surprise cross-community edges.

**Subcommands:** `query "<question>"` (BFS depth 3, `--dfs` depth 6), `deps <file>`, `hotspots`, `orphans`, `path "A" "B"`, `--deep`, `--watch`, `--update`

**Output:** Saves `ironworks/graph-report.md` and `ironworks/graph-manifest.json`

---

## L3 — `/iron:spec` — Spec-Driven Development

Every feature starts as a spec before it becomes code.

**Lifecycle:** `explore <topic>` (research, update CONTEXT.md) → `propose <name>` (RFC-style spec with GIVEN/WHEN/THEN, RFC 2119 keywords, acceptance criteria) → `apply <spec>` (implement, link changes to requirements) → `verify <spec>` (check impl vs spec) → `update <name>` (revise) → `archive <spec>` (move completed to archive)

**Rules:** Every feature traces to a spec. MUST/SHOULD/MAY are precise RFC 2119. Delta markers `[+]`/`[-]`/`[~]` track changes.

---

## L4 — `/iron:tdd` — Test-Driven Development

Red → Green → Refactor. No exceptions.

**Steps:** Write failing test → Write minimum code to pass → Refactor (only when green) → Repeat. Vertical slices (one feature end-to-end, not horizontal layers).

**Seam-based testing (Feathers):** Find seams -- constructor injection, interface boundaries, config switches. Test through seams to avoid over-mocking.

**Anti-patterns to reject:** Implementation-coupled tests, tautological tests, horizontal slicing, mock internals (mock boundaries only).

**Variants:** `<feature>` (new TDD cycle), `fix <bug>` (regression test first), `continue` (resume)

---

## L4 — `/iron:debug` — Structured Debugging

Isolate → Reproduce → Narrow → Fix.

**Steps:** Reproduce (exact inputs + environment) → Narrow (binary search the codebase) → Hypothesize → Verify with tagged logs `[DEBUG-xxxx]` → Fix root cause → Regression test → Remove debug logs.

**10 feedback loops:** Print, breakpoint, assert, snapshot, diff, replay, trace, profile, reduce, isolate.

**Subcommand:** `narrow` (bisect code paths). Non-deterministic bugs: vary time, concurrency, data, environment.

---

## L4 — `/iron:arch` — Architecture Analysis

Understand and improve system structure.

**Subcommands:** `analyze` (assess), `propose <change>` (Design-It-Twice: always two approaches before choosing), `assess <design>` (evaluate), `record <decision>` (generate ADR in docs/adr/)

**Deep module vocabulary (Ousterhout):** Information hiding, deep vs shallow modules, temporal decomposition, strategic vs tactical, classitis, pass-through methods.

**12 Fowler smells:** Shotgun Surgery, Feature Envy, God Class, Long Method, Data Clump, Primitive Obsession, Message Chain, Speculative Generality, Refused Bequest, Parallel Inheritance, Comments-as-deodorant, Divergent Change.

---

## L5 — `/iron:review` — Code Review

Two parallel axes run independently:

**Standards axis:** Discipline ladder compliance, never-compromise checklist, 12 Fowler smells, ironworks mark validation.

**Spec axis:** Every changed file traced to a spec requirement. Untraceable changes flagged.

**Over-engineering tags:** `[delete]` (remove), `[stdlib]` (use standard lib), `[native]` (platform feature), `[yagni]` (not needed yet), `[shrink]` (simplify).

**Variants:** `--staged`, `--branch <b>`, `--file <f>`, `--spec <s>`, `--fix` (auto-fix blockers), `--over-engineering` (OE scan only)

---

## L5 — `/iron:audit` — Simplification Audit

Find complexity to eliminate. Scans for: ironworks marks (deliberate debts), shallow modules (small interface hiding nothing), dead code, unnecessary abstractions, over-configuration.

**Subcommand:** `debt` -- harvest all `# ironworks:` marks into a prioritized debt ledger sorted by blast radius.

**Rules:** Only flag what you can prove. If uncertain, tag "investigate" not "fix." `--fix` auto-fixes safe deletions.

---

## L6 — `/iron:preflight` — Deploy Preflight

Verify deployment readiness per platform:

- **Vercel:** Framework, build output, env vars, function sizes
- **AWS (ECS/Lambda):** Dockerfile, task def, IAM, VPC
- **Railway:** Nixpacks/Dockerfile, PORT, health checks
- **Fly.io:** fly.toml, Dockerfile, regions, volumes
- **DigitalOcean:** App spec, components, resources
- **Universal:** .env alignment, dependency audit, git clean, tests pass

**Variants:** `--platform <name>`, `--fix` (auto-fix safe issues)

---

## L6 — `/iron:deploy` — Deployment Config

Generate deploy config: DigitalOcean, Vercel, AWS (ECS/Lambda/App Runner), Fly.io, Railway, Render.

**Subcommands:** `<platform>` (generate), `migrate <from> <to>` (convert between platforms, preserves env vars and bindings), `preview` (PR preview environment CI config)

---

## L-inf — `/iron:handoff` — Session Handoff

Preserve context across sessions. Summarizes work done, lists modified files, applies privacy filter (strips API keys, tokens, passwords, connection strings, private keys, auth headers, session tokens), extracts lessons learned, suggests next skills. Saves to `ironworks/handoffs/`.

**Variants:** `--for-agent` (optimized for AI continuation), `--for-human` (optimized for teammate)

**Session recall:** Reads most recent handoff before starting work.

---

## Workflows

```
New project:      /iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
Join existing:    /iron:graph → /iron:spec explore → (build) → /iron:review → /iron:handoff
Bug fix:          /iron:debug → /iron:tdd fix → /iron:review
Ship:             /iron:review → /iron:audit → /iron:preflight → /iron:deploy → /iron:handoff
Architecture:     /iron:graph → /iron:arch → /iron:arch --fix
End of session:   /iron:handoff
```

## Layer Map

```
L0  DISCIPLINE   Always active — priority stack, discipline ladder, security rules
L1  SETUP        /iron:init — project bootstrap
L2  UNDERSTAND   /iron:graph — dependency map and codebase queries
L3  PLAN         /iron:spec — spec-driven feature proposals
L4  BUILD        /iron:tdd, /iron:debug, /iron:arch — construction and quality
L5  QUALITY      /iron:review, /iron:audit — review and simplification
L6  SHIP         /iron:preflight, /iron:deploy — deployment and config
L∞  CONTINUITY   /iron:handoff — session and team handoffs
```
