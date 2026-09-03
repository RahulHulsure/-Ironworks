---
name: iron-audit
description: "Codebase audit for over-engineering: find and tag unnecessary abstractions, speculative features, overbuilt patterns, and dead code."
---

# /iron:audit

Audit the codebase for over-engineering. Apply the discipline ladder repo-wide.
Single question: "Can this be simpler?"

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
- `delete:` -- dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` -- hand-rolled thing the standard library ships. Name the function.
- `native:` -- dependency or code doing what the platform already does. Name the feature.
- `yagni:` -- abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` -- same logic, fewer lines. Show the shorter form.

#### Category 1: Unnecessary Abstractions

- `yagni:` Single-implementation interfaces
- `shrink:` Wrapper functions that just delegate
- `yagni:` Builder/factory for simple objects
- `yagni:` Generic base classes with one child
- `yagni:` Strategy pattern with one strategy
- `shrink:` Shallow modules -- large surface, little depth

#### Category 2: Speculative Features

- `delete:` Commented-out code
- `delete:` Feature flags never toggled
- `delete:` Unused API endpoints
- `yagni:` Config options nobody changes
- `delete:` Extensibility points with zero consumers

#### Category 3: Overbuilt Patterns

- `shrink:` Microservices for a monolith
- `shrink:` Event sourcing for CRUD
- `native:` GraphQL for internal APIs with stable schemas
- `stdlib:` Custom ORM when the standard one suffices
- `native:` Hand-rolled auth when frameworks handle it

#### Category 4: Dead Code

- `delete:` Exported functions with zero importers (excluding entry points)
- `delete:` Unreachable branches
- `delete:` Unused dependencies
- `delete:` Files nothing imports (excluding entry points)
- `stdlib:` Dependencies the stdlib already covers

### Step 2 — Measure Impact

For each finding, estimate:
- **Lines saved**
- **Files affected**
- **Risk** -- low (dead code), medium (simplify), high (pattern change)

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
     Single-implementation interface. Inline into the service.
     Lines saved: ~45 | Risk: Low | Files: 3

  shrink: backend/app/services/notification.py
     Shallow module: 12 methods forwarding to a single mailer. Inline.
     Lines saved: ~60 | Risk: Medium | Files: 4

SPECULATIVE FEATURES (N findings)
  delete: backend/app/utils/plugin_loader.py
     Plugin system with zero plugins. 120 lines loading nothing.
     Lines saved: ~120 | Risk: Low | Files: 1

OVERBUILT PATTERNS (N findings)
  shrink: backend/app/events/
     Event bus for 2 synchronous events. Use direct calls.
     Lines saved: ~200 | Risk: Medium | Files: 8

DEAD CODE (N findings)
  delete: frontend/src/utils/formatters.ts
     3 exported functions with zero importers: formatSSN, formatEIN, formatPhone
     Lines saved: ~35 | Risk: Low | Files: 1

  stdlib: backend/requirements.txt
     `python-dotenv` installed; stdlib `tomllib` covers the config-file read.
     Lines saved: ~10 | Risk: Low | Files: 2

───────────────────────────────────────
  Total: [N] findings
  Quick wins (low risk, high impact): [list]
  Needs discussion: [list]

  net: -[N] lines, -[M] deps possible.
───────────────────────────────────────
```

If nothing material is found, print `Lean already. Ship.`

### Step 4 — Generate Fixes (with --fix)

- **Low risk:** Delete dead code, inline unnecessary abstractions, run tests.
- **Medium risk:** Generate an `/iron:spec propose` for each.
- **High risk:** List as recommendations, not auto-fixes.

## `/iron:audit debt` — Debt Ledger

Harvest `# ironworks:` comments into a debt ledger.

1. Grep the repo for `(#|//) ?ironworks:` markers.
2. Parse each into: file, line, simplification, ceiling, upgrade trigger.
3. Flag any marker with no upgrade path as `no-trigger`.

### Output Format

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

If no markers exist, print `No ironworks: debt. Clean ledger.`

## Honesty Boundary

Never print "you saved X lines" -- the unbuilt version was never written. Report only lines removable now.

## Rules

- **Prove it's unused.** Search all references including dynamic imports, string lookups, reflection.
- **Check for plans.** A single-implementation interface may have a documented second -- check the specs.
- **Tag every finding.** No tag = too vague. Sharpen or drop it.
- **Measure, don't guess.** "~45 lines" not "some code."
- **Group related findings.** Same pattern? One example, list the rest.
- **Respect constraints.** Known regulatory/performance/compatibility reasons? Note, don't flag.
- **Quick wins first.** Dead code deletion is free. Pattern changes need discussion.
