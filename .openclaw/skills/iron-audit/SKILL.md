---
name: iron-audit
description: "Codebase audit for over-engineering: find unnecessary abstractions, speculative features, overbuilt patterns, and dead code. Tag every finding. Harvest ironworks: debt markers. The discipline ladder applied repo-wide."
homepage: https://github.com/RahulHulsure/-Ironworks
license: MIT
---

# /iron:audit — Codebase Simplification Audit

Audit the codebase for over-engineering. Find unnecessary abstractions,
speculative features, overbuilt patterns, and dead code. Apply the discipline
ladder from AGENTS.md to every file in the project.

This is `/iron:review` applied repo-wide, but focused on a single question:
"Can this be simpler?"

## When to Use

- Before a major release — trim the fat
- When the codebase feels harder to work with than it should
- After inheriting a project — understand what's essential vs. cruft
- Periodic maintenance (quarterly recommended)

## Invocation

```
/iron:audit                          # Full audit
/iron:audit <path>                   # Audit a specific directory
/iron:audit --category abstractions  # Focus on one category
/iron:audit --fix                    # Audit + generate removal/simplification PRs
/iron:audit debt                     # Harvest ironworks: debt markers (see below)
```

## What You Must Do When Invoked

### Step 1 — Scan Everything

Read the project tree. For each source file (not tests, not generated code),
check against these categories.

**Tag every finding** with one of:
- `delete:` — dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` — hand-rolled thing the standard library ships. Name the function.
- `native:` — dependency or code doing what the platform already does. Name the feature.
- `yagni:` — abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` — same logic, fewer lines. Show the shorter form.

---

#### Category 1: Unnecessary Abstractions

- **Single-implementation interfaces** — an interface/abstract class with exactly
  one implementation and no plan for others. The interface adds indirection
  without adding flexibility. Tag: `yagni:`
- **Wrapper functions that just call another function** — `getUserById(id)` that
  only calls `db.users.findOne({id})`. The wrapper adds a name but no logic. Tag: `shrink:`
- **Builder/factory patterns for simple objects** — a factory class for something
  that could be a constructor call or object literal. Tag: `yagni:`
- **Generic base classes** with one child class. Tag: `yagni:`
- **Strategy pattern** with one strategy. Tag: `yagni:`
- **Shallow modules** — large interface surface area (many methods, many
  parameters) that hides little complexity. The abstraction costs more to learn
  than it saves. Tag: `shrink:`

#### Category 2: Speculative Features

- **Commented-out code** — "might need this later." Delete it; git remembers. Tag: `delete:`
- **Feature flags that are never toggled** — always `true` or always `false`. Tag: `delete:`
- **Unused API endpoints** — routes that no frontend or client calls. Tag: `delete:`
- **Configuration options nobody changes** — hardcode the value, delete the config. Tag: `yagni:`
- **"Extensibility points"** — hooks, plugins, or event systems with zero consumers. Tag: `delete:`

#### Category 3: Overbuilt Patterns

- **Microservices for a monolith** — separate services that share a database
  and are always deployed together. Tag: `shrink:`
- **Event sourcing for CRUD** — full event log for simple create/update/delete. Tag: `shrink:`
- **GraphQL for internal APIs** — REST would be simpler for known, stable schemas. Tag: `native:`
- **Custom ORM or query builder** — when the standard one does everything needed. Tag: `stdlib:`
- **Hand-rolled auth** — when passport/devise/nextauth handles the exact use case. Tag: `native:`

#### Category 4: Dead Code

- **Exported functions with zero importers** (excluding entry points and test helpers). Tag: `delete:`
- **Unreachable branches** — conditions that can never be true given the types. Tag: `delete:`
- **Unused dependencies in package.json / requirements.txt**. Tag: `delete:`
- **Files that nothing imports** (excluding entry points). Tag: `delete:`
- **Dependencies the stdlib already covers** — a package installed for functionality
  the standard library ships natively. Tag: `stdlib:`

### Step 2 — Measure Impact

For each finding, estimate:
- **Lines saved** — how much code disappears
- **Files affected** — how many files change
- **Risk** — low (delete dead code), medium (simplify abstraction), high (change pattern)

### Step 3 — Produce the Report

```
═══════════════════════════════════════
  IRONWORKS AUDIT — [Project Name]
  [Date] · [N] files scanned
═══════════════════════════════════════

SUMMARY
  Over-engineering score: [1-10] (10 = severely over-engineered)
  Estimated effort to simplify: [hours/days]

UNNECESSARY ABSTRACTIONS (N findings)
  yagni: backend/app/interfaces/user_repo.py
     Single-implementation interface. UserRepository has one implementation
     (SQLAlchemyUserRepository). Inline the methods into the service.
     Lines saved: ~45 | Risk: Low | Files: 3

  shrink: backend/app/services/notification.py
     Shallow module: NotificationService exposes 12 methods that each
     forward to a single mailer call. Inline or reduce the surface.
     Lines saved: ~60 | Risk: Medium | Files: 4

SPECULATIVE FEATURES (N findings)
  delete: backend/app/utils/plugin_loader.py
     Plugin system with zero plugins. 120 lines of code loading nothing.
     Lines saved: ~120 | Risk: Low | Files: 1

OVERBUILT PATTERNS (N findings)
  shrink: backend/app/events/
     Event bus system used for 2 events, both called synchronously.
     Direct function calls would be clearer.
     Lines saved: ~200 | Risk: Medium | Files: 8

DEAD CODE (N findings)
  delete: frontend/src/utils/formatters.ts
     3 exported functions with zero importers: formatSSN, formatEIN, formatPhone
     Lines saved: ~35 | Risk: Low | Files: 1

  stdlib: backend/requirements.txt
     `python-dotenv` installed but `os.environ` used everywhere;
     stdlib `tomllib` covers the one config-file read.
     Lines saved: ~10 | Risk: Low | Files: 2

───────────────────────────────────────
  Total: [N] findings
  Quick wins (low risk, high impact): [list]
  Needs discussion: [list]

  net: -[N] lines, -[M] deps possible.
───────────────────────────────────────
```

If nothing material is found:

```
Lean already. Ship.
```

### Step 4 — Generate Fixes (with --fix)

For low-risk findings (dead code, single-implementation interfaces):
- Delete the dead code directly
- Inline the unnecessary abstractions
- Run tests to confirm nothing breaks

For medium-risk findings:
- Generate an `/iron:spec propose` for each — proper proposal with tasks

For high-risk findings:
- List them as recommendations, not auto-fixes

---

## `/iron:audit debt` — Debt Ledger

Harvest every `# ironworks:` comment in the repo into a structured debt ledger.
These markers are left behind when a developer intentionally simplifies something
and records the ceiling, the upgrade trigger, or the tradeoff.

### How It Works

1. Grep the entire repo for markers matching `(#|//) ?ironworks:` (hash or
   double-slash comment prefixes, with an optional space before `ironworks:`).
2. Parse each marker into: file, line number, what was simplified, the ceiling
   named, and the upgrade trigger (if any).
3. Flag rot risk: any `ironworks:` comment that names no upgrade path gets a
   `no-trigger` tag.

### Output Format

One row per marker, grouped by file:

```
═══════════════════════════════════════
  IRONWORKS DEBT LEDGER — [Project Name]
  [Date]
═══════════════════════════════════════

backend/app/cache.py:12, simplified to in-memory dict. ceiling: 10k entries. upgrade: when p95 latency > 200ms.
backend/app/cache.py:45, hardcoded TTL. ceiling: single tenant. upgrade: when multi-tenant ships.
backend/app/search.py:8, linear scan. ceiling: 1k records. upgrade: when dataset > 5k rows. [no-trigger: no metric wired]
frontend/src/state.ts:22, prop drilling. ceiling: 3 levels. upgrade: when 4th consumer added.

───────────────────────────────────────
  4 markers, 1 with no trigger.
───────────────────────────────────────
```

If no markers exist:

```
No ironworks: debt. Clean ledger.
```

---

## Honesty Boundary

- **Never print a per-repo savings number** like "you saved X lines here." The
  unbuilt version was never written, so there is no real baseline to compare
  against. Claiming savings from code that was never created is misleading.
- The only real per-repo data comes from:
  - `/iron:audit debt` — what was intentionally deferred (the markers exist)
  - The main audit — what is still cuttable today (the findings are concrete)
- Stick to what you can measure: lines removable now, dependencies droppable
  now. Never extrapolate what would have existed without the discipline ladder.

## Rules

- **Prove it's unused before deleting.** Search for all references, including
  dynamic imports, string-based lookups, and reflection.
- **Not all abstractions are bad.** An interface with one implementation TODAY
  might have a documented plan for a second. Check the specs.
- **Tag every finding.** Every finding gets a `delete:`, `stdlib:`, `native:`,
  `yagni:`, or `shrink:` tag. If none fits, the finding is probably too vague
  to be actionable — sharpen it or drop it.
- **Measure, don't guess.** "~45 lines" not "some code."
- **Group related findings.** If the same pattern repeats, show one example
  and list the other locations.
- **Respect the team's choices.** If a pattern exists because of a known
  constraint (regulatory, performance, compatibility), note it but don't flag it.
- **Quick wins first.** Dead code deletion is free. Pattern changes need discussion.
