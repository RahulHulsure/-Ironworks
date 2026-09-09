---
name: iron-forge
description: "End-to-end autonomous app builder — from requirements to deploy-ready app using the full Ironworks skill chain."
---

# /iron:forge

Takes raw app requirements and autonomously drives the full Ironworks pipeline
— init → spec → build → review → ship — producing a tested, reviewed,
deploy-ready application.

## Invocation

```
/iron:forge                              # Interactive: asks for requirements
/iron:forge "<requirements>"             # Inline requirements
/iron:forge --file <path>                # Read requirements from a file
/iron:forge --resume                     # Resume from last checkpoint
/iron:forge --platform <platform>        # Target: docker|vercel|aws|fly|railway|do
/iron:forge --stack <stack>              # Force tech stack
/iron:forge --dry-run                    # Plan only, don't build
/iron:forge status                       # Show current progress
```

## Pipeline Overview

```
Phase 0   INTAKE ─────── Parse requirements, decompose features, order by dependency
Phase 1   FOUNDATION ─── /iron:init + domain context + feature exploration
Phase 2   SPECIFICATION  /iron:spec propose for each feature, cross-validate
Phase 3   BUILD ──────── /iron:tdd per feature, /iron:debug on failures, /iron:graph --update
Phase 4   INTEGRATION ── /iron:arch + /iron:review + /iron:audit (full codebase)
Phase 5   SHIP ───────── /iron:preflight + /iron:deploy + /iron:spec archive + /iron:handoff
```

Every phase ends with a quality gate. Failing a gate triggers a retry loop
with a hard cap. Exceeding the cap pauses for human input — never silently
skip a gate.

---

## Entry Modes

Forge auto-detects the project state and adapts. It works at any point in
development — empty directory, existing codebase, partially spec'd, or
mid-build.

| State detected | Entry mode | What forge does differently |
|----------------|------------|---------------------------|
| Empty directory | **GREENFIELD** | Full pipeline from scratch |
| Code exists, no `ironworks/` directory | **BROWNFIELD** | Reconnaissance first: map code, identify existing features, build only what's new |
| `ironworks/` exists, specs in progress | **MIDSTREAM** | Read existing specs/tasks, mark completed work, continue from where things are |
| `ironworks/forge/checkpoint.json` exists | **RESUME** | Redirect to `--resume` flow — pick up at exact checkpoint |
| Code exists, some features complete, user gives new requirements | **EXTEND** | Treat existing features as pre-existing, spec+build only new/changed features |

The entry mode is detected automatically in Step 0.0 and shapes every
subsequent phase. No flag needed — forge figures it out.

---

## Phase 0: INTAKE

### Step 0.0 — Reconnaissance

**Run this FIRST, before parsing requirements.** Scan the project to
determine the entry mode.

#### Check 1: Existing checkpoint

If `ironworks/forge/checkpoint.json` exists:
- Print: "Found existing forge checkpoint. Redirecting to --resume."
- Follow the `--resume` flow (see Context Management section). Stop here.

#### Check 2: Project structure

Scan for signal files (`package.json`, `go.mod`, `requirements.txt`,
`Cargo.toml`, `pom.xml`, `mix.exs`, `pubspec.yaml`, `.csproj`, `manage.py`,
`composer.json`, etc.).

- **No signal files found** → GREENFIELD mode. Proceed to Step 0.1.
- **Signal files found** → BROWNFIELD or MIDSTREAM. Continue to Check 3.

#### Check 3: Ironworks state

- If `ironworks/` directory does not exist → **BROWNFIELD** mode.
- If `ironworks/` exists:
  - Read `ironworks/specs/` for living specs.
  - Read `ironworks/changes/` for in-flight proposals.
  - Read `ironworks/handoffs/` for session history.
  - If meaningful state exists → **MIDSTREAM** mode.
  - If ironworks/ is empty scaffolding → **BROWNFIELD** mode.

#### Check 4: Codebase inventory (BROWNFIELD and MIDSTREAM only)

Run `/iron:graph` to map the existing codebase. From the graph, extract:

1. **Existing modules**: list every functional area the code already covers
   (e.g., "auth — JWT-based, in src/auth/", "posts — CRUD API, in
   src/posts/").
2. **Existing tests**: identify test files and what they cover.
3. **Existing infrastructure**: database setup, API framework, error
   handling, logging — anything that counts as INFRA.

Save the inventory to `ironworks/forge/inventory.md`:

```markdown
# Codebase Inventory

**Scanned**: <timestamp>
**Entry mode**: BROWNFIELD | MIDSTREAM

## Existing Modules

| Module | Location | Has Tests | Coverage Notes |
|--------|----------|-----------|----------------|
| auth | src/auth/ | Yes (8 tests) | Login, register, JWT refresh |
| posts | src/posts/ | Partial (3 tests) | CRUD only, no pagination |

## Existing Infrastructure

- Framework: Express.js (src/app.js)
- Database: PostgreSQL via Prisma (prisma/schema.prisma)
- Error handling: Global handler in src/middleware/errors.js

## Ironworks State (MIDSTREAM only)

- Living specs: auth, posts (in ironworks/specs/)
- In-flight changes: search (3/7 tasks done)
- Last handoff: 2025-01-15 (ironworks/handoffs/2025-01-15-14.md)
```

#### Check 5: Present inventory to user

For BROWNFIELD and MIDSTREAM modes, present the inventory:

```
Found existing project: <stack>
Entry mode: BROWNFIELD

Existing features detected:
  ✓ auth — JWT login/register/refresh (8 tests)
  ~ posts — CRUD API, partial tests (3 tests, missing pagination)
  ✓ database — PostgreSQL via Prisma

Tell me your requirements and I'll build what's missing.
```

Wait for the user to provide requirements (unless already provided via
arguments). Then proceed to Step 0.1.

### Step 0.1 — Parse Requirements

Read the input (interactive prompt, inline string, or file). Extract:

1. **App type**: web app, API, CLI, mobile, desktop, library, fullstack
2. **Core features**: every user-facing capability
3. **Tech preferences**: stack, database, auth method, styling
4. **Target platform**: where it will deploy
5. **Constraints**: performance targets, compliance, accessibility, integrations

If any critical item is ambiguous, ask ONE round of clarifying questions.
Decide everything else yourself — do not interview the user.

### Step 0.2 — Decompose Features

Break requirements into discrete features. Each feature must be:

- **Independently specifiable** — can write requirements without other features built
- **Independently testable** — can verify in isolation
- **One-cycle sized** — completable in one `/iron:spec` → `/iron:tdd` cycle

Classify each feature by **tag** (what it is) and **mode** (what forge
does with it):

**Tags** (what the feature is):

| Tag | Meaning | Build order |
|-----|---------|-------------|
| INFRA | Shared infrastructure: auth, DB schema, API layer, error handling | First |
| CORE | Features that define the app's value proposition | Second |
| SECONDARY | Enhances but not essential for v1 | Third |
| POLISH | UX improvements, optimizations, nice-to-haves | Last |

**Modes** (what forge does — assigned by cross-referencing requirements
against the codebase inventory from Step 0.0):

| Mode | When assigned | What forge does |
|------|---------------|-----------------|
| NEW | Feature does not exist in the codebase | Full cycle: spec → build → review |
| EXISTS | Feature already built, tests pass, meets requirements as-is | Validate only: review + include in integration |
| EXTEND | Feature partially exists or exists but requirements ask for changes | Spec the delta only, build additions, review all |
| REWORK | Feature exists but quality is poor (no tests, broken, wrong approach) | Write spec for desired state, rebuild with TDD |

**GREENFIELD projects:** All features are mode NEW. Skip the mode assignment.

**BROWNFIELD/MIDSTREAM projects:** For each required feature, compare
against the codebase inventory:

1. If a matching module exists with passing tests that cover the
   requirement → mode **EXISTS**.
2. If a matching module exists but the requirements ask for more
   (new endpoints, new behavior, new fields) → mode **EXTEND**.
3. If a matching module exists but has no tests, broken tests, or
   fundamentally wrong approach → mode **REWORK**.
4. If no matching module exists → mode **NEW**.

When uncertain between EXISTS and EXTEND, prefer EXTEND — it's safer to
validate and spec the gap than to assume existing code is complete.

### Step 0.3 — Dependency Ordering

Build a feature dependency graph:

1. INFRA features first (no feature dependencies by definition)
2. CORE features next, ordered: fewer dependencies first
3. SECONDARY features after all CORE features pass their gates
4. POLISH last

Detect circular feature dependencies. If found, merge the circling features
into one.

### Step 0.4 — Create the Forge Plan

Save to `ironworks/forge/plan.md`:

```markdown
# Forge Plan

**App**: <name>
**Stack**: <detected or chosen>
**Platform**: <target>
**Entry mode**: GREENFIELD | BROWNFIELD | MIDSTREAM
**Generated**: <timestamp>

## Features (build order)

1. [INFRA] auth — JWT authentication (EXISTS — validate only)
2. [INFRA] database — PostgreSQL schema (EXISTS — validate only)
3. [CORE] posts — Blog post CRUD (EXTEND — add pagination, search)
4. [CORE] comments — Threaded comments (NEW — full build)
5. [SECONDARY] notifications — Email alerts (NEW — full build)
6. [POLISH] dark-mode — Theme toggle (NEW — full build)

## Scope

- Total features: <N>
- NEW (full build): <N>
- EXTEND (delta build): <N>
- EXISTS (validate only): <N>
- REWORK (rebuild): <N>
- Estimated complexity: small | medium | large
```

Initialize checkpoint: save to `ironworks/forge/checkpoint.json`:

```json
{
  "forge_id": "<YYYY-MM-DD-HHMM>",
  "app_name": "<name>",
  "stack": "<stack>",
  "platform": "<platform>",
  "entry_mode": "GREENFIELD | BROWNFIELD | MIDSTREAM",
  "phase": "INTAKE",
  "features": [
    { "name": "<name>", "tag": "INFRA", "mode": "NEW", "status": "pending" },
    { "name": "<name>", "tag": "INFRA", "mode": "EXISTS", "status": "pre-existing" }
  ],
  "gates": {
    "intake": "pending",
    "foundation": "pending",
    "specification": "pending",
    "build": "pending",
    "integration": "pending",
    "ship": "pending"
  }
}
```

Present the plan to the user. If `--dry-run`, stop here.

**GATE: INTAKE** — Plan has ≥1 feature, no circular dependencies, stack
detected. Mark `gates.intake: "passed"`.

---

## Phase 1: FOUNDATION

### Step 1.1 — Project Init

**GREENFIELD:** Run `/iron:init --stack <stack>`.

**BROWNFIELD/MIDSTREAM:** The project already exists. Do not run
`/iron:init`. Instead:

1. Verify `CLAUDE.md` exists — create if missing, populated with detected
   stack, project structure, and dev commands.
2. Verify `ironworks/` directories exist (`specs/`, `changes/`, `forge/`)
   — create any that are missing.
3. If `.env.example` is missing, generate it from detected `process.env` /
   `os.environ` / `env()` patterns in the codebase.
4. Do NOT restructure existing code, rename files, or change conventions.
   Forge adapts to the project's existing patterns.

### Step 1.2 — Domain Context

**GREENFIELD:** Populate `ironworks/CONTEXT.md` with domain terms extracted
from requirements.

**BROWNFIELD/MIDSTREAM:** Read existing code for domain terms already in use.
Merge with terms from the new requirements. If `CONTEXT.md` already exists,
update it — do not overwrite. Add terms from the codebase inventory that the
requirements reference.

Every noun that isn't self-evident gets a one-line definition and an
`_Avoid:_` list of rejected synonyms.

### Step 1.3 — Feature Exploration

**For NEW and REWORK features:** Run `/iron:spec explore <feature>` for each
INFRA and CORE feature.

**For EXTEND features:** Run `/iron:spec explore <feature>` but scope the
exploration to the delta — what needs to change, not what already works.
Reference the existing implementation in the exploration.

**For EXISTS features:** Skip exploration. The codebase inventory from
Step 0.0 is sufficient.

After all explorations:
- If a shared concern surfaced (e.g., "both features need pagination"),
  extract it as a new INFRA feature and re-order the plan.
- If an EXISTS feature turns out to be incomplete during exploration of a
  dependent feature, reclassify it as EXTEND.
- Update `ironworks/forge/plan.md` if features were added or reordered.
- Update checkpoint.

**GATE: FOUNDATION** — Project runs, all explorations complete (for features
that need them), CONTEXT.md has ≥1 term, forge plan is current. Mark
`gates.foundation: "passed"`.

---

## Phase 2: SPECIFICATION

### Step 2.1 — Propose Specs

Handle each feature according to its mode:

**NEW features:** Run `/iron:spec propose <feature>` — full proposal with
all four files (proposal.md, requirements.md, design.md, tasks.md).

**EXTEND features:** Run `/iron:spec propose <feature>-extension`. The
proposal must:
- Reference the existing implementation (file paths, current behavior).
- Scope requirements to the DELTA only — what's being added or changed.
- Design.md describes how to modify existing code, not rewrite it.
- Tasks.md covers only the new/changed work.
- Include a "Current State" section in proposal.md documenting what already
  works and must not break.

**REWORK features:** Run `/iron:spec propose <feature>`. The proposal must:
- Document the current broken/inadequate state and why it needs rework.
- Requirements describe the desired end state (not the delta).
- Design.md may propose a different approach from the existing code.
- Tasks.md includes migration steps if the rework changes interfaces that
  other code depends on.

**EXISTS features:** Skip spec proposal. Instead, run `/iron:spec verify`
against the codebase — confirm the existing code meets the stated
requirements. If verification finds gaps:
- If minor (missing edge case tests): reclassify as EXTEND, propose a
  small extension spec.
- If major (missing core behavior): reclassify as REWORK.
- If clean: mark `"status": "validated"` in checkpoint.

**MIDSTREAM features with existing specs:** Read `ironworks/changes/<name>/`.
- If tasks.md has all tasks checked → mark `"status": "built"`.
- If tasks.md has some tasks checked → mark `"status": "building"`,
  record `current_task`.
- If spec exists but no tasks checked → mark `"status": "specified"`.
- Do not re-propose specs that already exist. Run cross-validation against
  them.

Requirements for every NEW and REWORK proposal:
- `requirements.md` has GIVEN/WHEN/THEN for every scenario including
  error cases
- `design.md` references shared infrastructure from INFRA features
- `tasks.md` is ordered so each task builds on the previous

### Step 2.2 — Cross-Feature Validation

After all specs are proposed or validated, validate across ALL features
(including EXISTS):

1. No contradicting requirements between features
2. Shared types and interfaces are consistent across designs
3. API contracts between features align (request/response shapes match)
4. No duplicate functionality across features
5. EXTEND specs don't break assumptions that EXISTS features depend on
6. Existing code interfaces referenced by NEW feature designs actually exist

If issues found: run `/iron:spec update <feature>` on the conflicting specs.

### Step 2.3 — Checkpoint

Update feature statuses in checkpoint:
- NEW/REWORK features → `"status": "specified"`
- EXTEND features → `"status": "specified"` (the extension spec)
- EXISTS features that passed verification → `"status": "validated"`
- MIDSTREAM features → status from their existing tasks.md progress

**GATE: SPECIFICATION** — Every NEW/REWORK/EXTEND feature has spec files.
Every EXISTS feature is validated. Cross-validation clean. CONTEXT.md up to
date. Mark `gates.specification: "passed"`.

---

## Phase 3: BUILD

Process each feature in build order. One feature completes before the next
starts. The build steps differ by mode.

### Step 3.0 — Route by Mode

For each feature, follow the path matching its mode:

| Mode | Build path |
|------|-----------|
| **NEW** | Full TDD cycle: Step 3.1 → 3.2 → 3.3 → 3.4 |
| **EXTEND** | TDD cycle for extension tasks only: Step 3.1 → 3.2 → 3.3 → 3.4 |
| **REWORK** | Full TDD cycle (rebuilds from spec): Step 3.1 → 3.2 → 3.3 → 3.4 |
| **EXISTS** | Validation only: Step 3.2 (review) → 3.3 → 3.4 |
| **MIDSTREAM (partially built)** | Resume from first unchecked task: Step 3.1 (continuing) → 3.2 → 3.3 → 3.4 |

### Step 3.1 — Implement with TDD

**NEW and REWORK features:**

1. Run `/iron:spec apply <feature>` to surface the first unchecked task.
2. For each task:
   a. Run `/iron:tdd <task description>` — strict RED → GREEN → REFACTOR.
   b. If GREEN fails after 3 attempts: run `/iron:debug` on the failure.
      - If `/iron:debug` resolves it: continue.
      - If `/iron:debug` fails after 3 narrowing cycles: **pause for human**.
   c. After GREEN: mark task complete in `tasks.md`.
   d. Run the full test suite — including tests for EXISTS and previously
      built features.
      - If regressions in previous features: fix regressions before
        continuing (max 3 regression-fix attempts, then pause for human).
   e. Proceed to next task.

**EXTEND features:**

1. Run `/iron:spec apply <feature>-extension` to surface the first
   unchecked task in the extension spec.
2. Same TDD loop as NEW, but:
   - Before writing any code, read the existing implementation to
     understand current patterns, naming, and structure.
   - New code MUST follow the existing feature's conventions — same file
     organization, naming style, error handling patterns.
   - Tests must cover both the new behavior AND verify existing behavior
     is preserved (regression guard).
   - If modifying an existing file: use the minimum diff. Do not refactor
     the existing code unless the extension requires it.

**REWORK features — special considerations:**

1. Before building: if the existing code has callers in other features,
   identify them. The rework must maintain interface compatibility unless
   the callers are also being reworked.
2. If interface changes are unavoidable: update callers as a task in the
   rework spec. Run those callers' tests after each interface change.
3. Migration tasks (data migration, API versioning) come before the
   rework tasks in the task list.

**MIDSTREAM features (partially built):**

1. Read `ironworks/changes/<feature>/tasks.md`.
2. Find the first unchecked task.
3. Read the handoff for context on what was done and any known issues.
4. Continue the TDD loop from that task — same process as NEW.
5. Run all tests first to verify existing work is still passing. If
   existing tests fail before you start: fix them first as a prerequisite
   (these are regressions from the prior session, not new work).

**EXISTS features:** Skip Step 3.1 entirely. Proceed to Step 3.2.

### Step 3.2 — Feature Review

**NEW, EXTEND, REWORK, MIDSTREAM features:**

After all tasks for a feature are complete:

1. Run `/iron:review --spec <feature>`.
2. Handle the verdict:

| Verdict | Action | Limit |
|---------|--------|-------|
| **SHIP IT** | Proceed to next feature | — |
| **FIX AND RESHIP** | Apply fixes, re-run review | Max 3 fix cycles |
| **RETHINK** | `/iron:spec update <feature>`, rebuild affected tasks | Max 1 rethink per feature |

If limits exhausted: **pause for human**.

**EXISTS features:**

1. Run `/iron:review --file <feature files>` — standards axis only (no
   spec axis, since EXISTS features weren't spec'd by forge).
2. If Block findings:
   - Reclassify feature as REWORK if issues are fundamental.
   - Reclassify as EXTEND if issues are isolated fixes.
   - Re-enter the pipeline at Step 2.1 for the new mode.
3. If only Concerns or Notes: record in handoff, proceed. Forge does not
   rewrite working code that passes tests just because it could be better.

### Step 3.3 — Update Dependency Graph

Run `/iron:graph --update` to register the feature's connections.

Check for circular dependencies introduced by this feature. If found, fix
before proceeding.

For EXTEND features: verify the graph still shows correct connections for
the existing feature — the extension should not orphan existing code paths.

### Step 3.4 — Checkpoint

Update feature status in checkpoint:
- NEW/REWORK/EXTEND features → `"status": "built"`. Record test count
  and review verdict.
- EXISTS features → `"status": "validated"`. Record review findings
  (if any).
- MIDSTREAM features that completed → `"status": "built"`.

**GATE: BUILD (per feature)** — All tasks checked off (for features with
tasks), all tests pass (zero failures), `/iron:review` verdict is SHIP IT
(or clean for EXISTS), no regressions in prior features.

After ALL features are built or validated: mark `gates.build: "passed"`.

---

## Phase 4: INTEGRATION

Run after every feature has passed its individual BUILD gate. Integration
covers the ENTIRE codebase — pre-existing code, new code, extended code,
and reworked code together. This is where forge validates that everything
composes correctly.

### Step 4.1 — Architecture Analysis

Run `/iron:arch`.

| Score | Action | Limit |
|-------|--------|-------|
| **A or B** | Proceed | — |
| **C** | Note findings in handoff, proceed | — |
| **D or F** | `/iron:arch --fix` → rebuild fixes via Phase 3 loop → re-run `/iron:arch` | Max 2 arch-fix cycles |

If score stays D/F after 2 cycles: **pause for human**.

### Step 4.2 — Full Code Review

**GREENFIELD:** Run `/iron:review` on the entire diff from initial commit.

**BROWNFIELD/MIDSTREAM:** Run `/iron:review` scoped to forge-touched code:
- For NEW features: full diff of new files
- For EXTEND features: diff of changed files
- For REWORK features: diff of reworked files
- For EXISTS features: already reviewed in Step 3.2 — skip here

Do NOT review the entire pre-existing codebase during integration. Forge
is responsible for what it built and what it changed, not for auditing
code that was working before forge started. Pre-existing code issues found
during `/iron:arch` are noted in the handoff as improvement opportunities.

- Standards axis: zero Block findings required in forge-touched code
- Spec axis: all NEW/EXTEND/REWORK features show as complete

If Block findings remain after 2 fix-and-reship cycles: list them and
**pause for human**.

### Step 4.3 — Simplification Audit

Run `/iron:audit`.

- Run `/iron:audit --fix` for low-risk items (dead code, inline trivial
  abstractions). Verify tests still pass after each fix.
- Medium/high-risk items: note in handoff, do not auto-fix.
- If over-engineering score > 6 after auto-fixes: note in handoff but
  proceed (audit score is advisory, not blocking at this stage).

### Step 4.4 — Full Dependency Graph

Run `/iron:graph` (full rebuild).

- Circular dependencies → fix immediately
- Orphaned non-entry-point files → delete, verify tests pass
- God nodes → note in handoff as future refactor targets

**GATE: INTEGRATION** — Arch score ≥ C, review verdict SHIP IT (zero
Blocks), no circular dependencies, all tests pass. Mark
`gates.integration: "passed"`.

---

## Phase 5: SHIP

### Step 5.1 — Deploy Preflight

Run `/iron:preflight --platform <platform>`.

- All critical checks must pass.
- If critical failures: run `/iron:preflight --fix`, re-check.
  Max 2 preflight-fix cycles, then **pause for human**.
- Warning items: note in handoff.

### Step 5.2 — Deploy Config

Run `/iron:deploy <platform> --env production`.

Verify:
- Generated config references all required env vars from `.env.example`
- Health check endpoint exists and is wired in the config
- No hardcoded secrets

### Step 5.3 — Archive All Specs

For each feature that has a forge-created spec (NEW, EXTEND, REWORK):
run `/iron:spec archive <feature>`.

EXISTS features have no forge spec to archive. If they had pre-existing
specs in `ironworks/specs/`, leave them untouched.

Living specs in `ironworks/specs/` should now reflect the full application.

### Step 5.4 — Final Documentation

1. **Update README.md** with:
   - What the app does
   - How to install and run locally
   - How to run tests
   - How to deploy (reference the generated config)
   - Environment variables (reference `.env.example`)
   - Architecture overview (reference the graph report)

2. **Run `/iron:handoff --for-human`** to document everything.

3. **Create `ironworks/forge/FORGE-COMPLETE.md`**:

```markdown
# Forge Complete

**App**: <name>
**Stack**: <stack>
**Platform**: <platform>
**Completed**: <timestamp>

## Features

| # | Tag | Feature | Mode | Tests | Review |
|---|-----|---------|------|-------|--------|
| 1 | INFRA | auth | EXISTS | 14 | Clean |
| 2 | INFRA | database | EXISTS | 8 | Clean |
| 3 | CORE | posts | EXTEND | 28 | SHIP IT |
| 4 | CORE | comments | NEW | 22 | SHIP IT |
| 5 | SECONDARY | notifications | NEW | 16 | SHIP IT |
| ... | ... | ... | ... | ... | ... |

## Quality Results

- Architecture Score: <grade>
- Review Verdict: SHIP IT
- Audit Score: <N>/10
- Preflight: <N>/<total> pass, <N> warnings
- Total Tests: <N> passing, 0 failing
- Circular Dependencies: 0

## Deploy

- Platform: <platform>
- Config files: <list>
- Required env vars: <count> (see .env.example)

## Known Limitations

- [Items noted during audit]
- [Warning items from preflight]
- [Future improvements from arch analysis]

## To Deploy

1. Set environment variables per `.env.example`
2. Run database migrations
3. Deploy: `<platform-specific command>`
```

**GATE: SHIP** — Preflight critical checks pass, deploy config valid, all
specs archived, README complete, handoff written. Mark
`gates.ship: "passed"`.

---

## Quality Gates Summary

| Gate | Hard Criteria | On Failure |
|------|---------------|------------|
| INTAKE | ≥1 feature, no circular deps, stack detected | Clarify with user |
| FOUNDATION | Init succeeds, explorations complete, CONTEXT.md populated | Fix init issues |
| SPECIFICATION | 4 spec files per feature, cross-validation clean | Update conflicting specs |
| BUILD (each) | All tests pass, review = SHIP IT, no regressions | TDD → debug → rethink → **human** |
| INTEGRATION | Arch ≥ C, review = SHIP IT, no circular deps | Fix cycles → **human** |
| SHIP | Preflight pass, config valid, docs complete | Preflight --fix → **human** |

---

## Error Recovery

| Situation | Recovery | Max Retries | Then |
|-----------|----------|-------------|------|
| Test won't go GREEN | `/iron:debug` | 3 narrowing cycles | Pause for human |
| `/iron:debug` can't find root cause | Report hypotheses and evidence | — | Pause for human |
| Review says FIX AND RESHIP | Apply fixes, re-review | 3 cycles | Pause for human |
| Review says RETHINK | `/iron:spec update` + rebuild tasks | 1 per feature | Pause for human |
| Arch score D/F | `/iron:arch --fix` + rebuild | 2 cycles | Pause for human |
| Preflight critical failure | `/iron:preflight --fix` | 2 cycles | Pause for human |
| Build breaks previous feature | Fix regression | 3 attempts | Pause for human |
| Feature depends on unbuilt feature | Reorder plan, build dependency first | — | — |
| EXISTS feature fails review | Reclassify as EXTEND or REWORK | — | Re-enter at Step 2.1 |
| EXTEND breaks existing behavior | Revert extension, re-spec the delta | 1 re-spec | Pause for human |
| Pre-existing tests fail before forge starts | Fix as prerequisite before building | 3 attempts | Pause for human |
| MIDSTREAM tasks stale (code moved since last session) | Re-read codebase, update tasks.md | 1 update | Pause for human |

When max retries are exceeded: **STOP. Report the blocker with full context.
Ask the human what to do.** Never silently skip a quality gate. Never
fabricate a passing result.

---

## Checkpoint System

Progress is saved to `ironworks/forge/checkpoint.json` after:
- Every phase completion
- Every feature status change (pending → specified → building → built)
- Every quality gate evaluation

`/iron:forge --resume` reads the checkpoint and the most recent handoff in
`ironworks/handoffs/`, then continues from the exact point.

`/iron:forge status` reads the checkpoint and prints:

```
Forge: <app_name>  |  Stack: <stack>  |  Platform: <platform>
Entry: BROWNFIELD  |  Features: 6 (2 exist, 1 extend, 3 new)

Phase: BUILD (3/5)

Features:
  ● [INFRA] auth — EXISTS, validated (14 tests, clean)
  ● [INFRA] database — EXISTS, validated (8 tests, clean)
  ✓ [CORE] posts — EXTEND, built (28 tests, SHIP IT)
  → [CORE] comments — NEW, building (task 3/7)
  · [SECONDARY] notifications — NEW, specified
  · [POLISH] dark-mode — NEW, pending

Gates:
  ✓ INTAKE  ✓ FOUNDATION  ✓ SPECIFICATION  → BUILD  · INTEGRATION  · SHIP
```

Legend: `●` = pre-existing (validated), `✓` = built by forge,
`→` = in progress, `·` = pending

---

## Context Management

A full forge run WILL exceed a single session for any non-trivial app.

**Proactive handoff triggers** — run `/iron:handoff --for-agent` and save
checkpoint:

- At every phase boundary (always)
- After every 3rd feature completes in BUILD phase
- Before any human pause point
- When the conversation is getting long

**On resume** (`/iron:forge --resume`):

1. Read `ironworks/forge/checkpoint.json`
2. Read the most recent file in `ironworks/handoffs/`
3. Read `ironworks/forge/plan.md`
4. Announce: "Resuming forge at Phase X, Feature Y. Last completed: Z."
5. Continue from the exact checkpoint

---

## Rules

1. **No skipping gates.** Every gate is evaluated even for trivial apps.
   Report "gate passed trivially" if appropriate, but evaluate it.

2. **No silent failures.** If something fails and retries are exhausted,
   say so. Never mark a gate as passed when it isn't.

3. **Human pause points are real.** When the skill says "pause for human,"
   stop and ask. Do not guess the answer. Do not substitute your judgment for
   the user's on blocked items.

4. **Scope discipline.** Build only what the requirements say. If you discover
   something useful during build, note it in the handoff under "future
   improvements." Do not add it to the current forge.

5. **The Discipline Ladder still applies.** Inside every phase, Layer 0
   constraints are active. Reuse > stdlib > one-liner > minimum new code.

6. **One feature at a time.** Complete a feature's full cycle (spec → build →
   review) before starting the next. No interleaving.

7. **Tests are non-negotiable.** Every feature ships with tests for every
   GIVEN/WHEN/THEN scenario in its requirements. Zero test failures at every
   gate.

8. **Checkpoint often.** Losing progress to a session timeout is a failure
   mode. Save checkpoint after every meaningful state change.

9. **Respect existing code.** In BROWNFIELD and MIDSTREAM modes:
   - Follow the project's existing conventions (naming, file structure,
     error handling, test patterns). Do not impose new conventions.
   - Do not refactor pre-existing code unless the forge plan explicitly
     includes it as a REWORK feature.
   - Do not move, rename, or restructure existing files.
   - Match the existing code's comment density, indentation, and style.
   - If existing code uses a pattern you disagree with, follow it anyway.
     Note the disagreement in the handoff, not in the code.

10. **Reconnaissance before assumptions.** Never assume an empty ironworks/
    directory means a greenfield project. Always run the full reconnaissance
    (Step 0.0) before deciding the entry mode.

11. **Pre-existing tests are sacred.** If the project has existing tests
    that pass before forge starts, they must still pass after every single
    forge action. A forge-introduced regression in pre-existing code is a
    build-blocking failure, even if forge's own new tests pass.

12. **Mode reclassification is one-way toward more work.** A feature can
    be reclassified from EXISTS → EXTEND → REWORK (more work) but never
    the reverse. If you classified something as NEW and discover it
    partially exists, reclassify as EXTEND — do not delete and rebuild
    what already works.
