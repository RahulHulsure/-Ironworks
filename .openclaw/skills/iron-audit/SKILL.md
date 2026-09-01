---
name: iron-audit
description: "Codebase audit for over-engineering: find unnecessary abstractions, speculative features, overbuilt patterns, and dead code. The discipline ladder applied repo-wide."
homepage: https://github.com/rmyndharis/ironworks-skills
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
```

## What You Must Do When Invoked

### Step 1 — Scan Everything

Read the project tree. For each source file (not tests, not generated code),
check against these categories:

#### Category 1: Unnecessary Abstractions

- **Single-implementation interfaces** — an interface/abstract class with exactly
  one implementation and no plan for others. The interface adds indirection
  without adding flexibility.
- **Wrapper functions that just call another function** — `getUserById(id)` that
  only calls `db.users.findOne({id})`. The wrapper adds a name but no logic.
- **Builder/factory patterns for simple objects** — a factory class for something
  that could be a constructor call or object literal.
- **Generic base classes** with one child class.
- **Strategy pattern** with one strategy.

#### Category 2: Speculative Features

- **Commented-out code** — "might need this later." Delete it; git remembers.
- **Feature flags that are never toggled** — always `true` or always `false`.
- **Unused API endpoints** — routes that no frontend or client calls.
- **Configuration options nobody changes** — hardcode the value, delete the config.
- **"Extensibility points"** — hooks, plugins, or event systems with zero consumers.

#### Category 3: Overbuilt Patterns

- **Microservices for a monolith** — separate services that share a database
  and are always deployed together.
- **Event sourcing for CRUD** — full event log for simple create/update/delete.
- **GraphQL for internal APIs** — REST would be simpler for known, stable schemas.
- **Custom ORM or query builder** — when the standard one does everything needed.
- **Hand-rolled auth** — when passport/devise/nextauth handles the exact use case.

#### Category 4: Dead Code

- **Exported functions with zero importers** (excluding entry points and test helpers)
- **Unreachable branches** — conditions that can never be true given the types
- **Unused dependencies in package.json / requirements.txt**
- **Files that nothing imports** (excluding entry points)

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
  Total simplification potential: ~[N] lines removable
  Estimated effort to simplify: [hours/days]

UNNECESSARY ABSTRACTIONS (N findings)
  🟡 backend/app/interfaces/user_repo.py
     Single-implementation interface. UserRepository has one implementation
     (SQLAlchemyUserRepository). Inline the methods into the service.
     Lines saved: ~45 | Risk: Low | Files: 3

SPECULATIVE FEATURES (N findings)
  🔴 backend/app/utils/plugin_loader.py
     Plugin system with zero plugins. 120 lines of code loading nothing.
     Lines saved: ~120 | Risk: Low | Files: 1

OVERBUILT PATTERNS (N findings)
  🟡 backend/app/events/
     Event bus system used for 2 events, both called synchronously.
     Direct function calls would be clearer.
     Lines saved: ~200 | Risk: Medium | Files: 8

DEAD CODE (N findings)
  🟢 frontend/src/utils/formatters.ts
     3 exported functions with zero importers: formatSSN, formatEIN, formatPhone
     Lines saved: ~35 | Risk: Low | Files: 1

───────────────────────────────────────
  Total: [N] findings
  Quick wins (low risk, high impact): [list]
  Needs discussion: [list]
───────────────────────────────────────
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

## Rules

- **Prove it's unused before deleting.** Search for all references, including
  dynamic imports, string-based lookups, and reflection.
- **Not all abstractions are bad.** An interface with one implementation TODAY
  might have a documented plan for a second. Check the specs.
- **Measure, don't guess.** "~45 lines" not "some code."
- **Group related findings.** If the same pattern repeats, show one example
  and list the other locations.
- **Respect the team's choices.** If a pattern exists because of a known
  constraint (regulatory, performance, compatibility), note it but don't flag it.
- **Quick wins first.** Dead code deletion is free. Pattern changes need discussion.
