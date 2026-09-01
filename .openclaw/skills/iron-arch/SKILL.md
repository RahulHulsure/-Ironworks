---
name: iron-arch
description: "Architecture analysis: scan the codebase for structural problems — god files, circular dependencies, layer violations, missing boundaries — and produce an improvement plan."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:arch — Architecture Analysis

Scan the codebase for structural problems and produce an actionable improvement
plan. This catches the slow-burn issues that make codebases harder to work with
over time: god files, missing boundaries, circular dependencies, and abstraction
leaks.

## When to Use

- Codebase is getting harder to navigate
- Changes in one file unexpectedly break others
- New team members struggle to understand the structure
- Before a major feature addition (is the foundation solid?)
- Technical debt review

## Invocation

```
/iron:arch                           # Full architecture scan
/iron:arch --focus <area>            # Scan a specific module or directory
/iron:arch --quick                   # Top 5 issues only
/iron:arch --fix                     # Scan + generate refactor proposals
```

## What You Must Do When Invoked

### Step 1 — Map the Structure

Read the project tree and identify:

1. **Layers** — What layers exist? Common patterns:
   - Routes/Controllers → Services → Models → Database
   - Pages → Components → Hooks → Utils → API
   - Handlers → Use Cases → Entities → Repositories

2. **Boundaries** — Where are the module boundaries? Look for:
   - Directory structure (each dir = a module?)
   - Package/namespace organization
   - Index/barrel files that define public APIs

3. **Entry points** — How does execution flow into the system?
   - HTTP routes, CLI commands, event handlers, cron jobs

### Step 2 — Detect Issues

Scan for these specific architectural problems:

#### God Files
Files with too many responsibilities or too many dependents.

Signals:
- File is > 500 lines and not a migration or generated code
- File has > 10 incoming imports (everything depends on it)
- File mixes concerns (DB queries + business logic + HTTP handling)

#### Circular Dependencies
A depends on B, B depends on A (directly or through a chain).

Signals:
- Explicit circular imports (some languages throw errors, others don't)
- Implicit circular deps through shared mutable state
- Two modules that import each other "for just one function"

#### Layer Violations
Code that skips layers or reaches in the wrong direction.

Signals:
- Routes importing from other routes
- Models calling services
- Database queries in route handlers (bypassing services)
- Frontend components making direct API calls instead of using a client layer

#### Missing Boundaries
Modules that expose their internals instead of a clean interface.

Signals:
- No index/barrel file — everything is imported by deep path
- Internal implementation details imported by external code
- "Utility" files that are actually a dumping ground for unrelated functions

#### Abstraction Leaks
Low-level details exposed through high-level interfaces.

Signals:
- Database column names in API responses
- ORM models used as API response types
- SQL or query syntax visible in service layer
- Infrastructure concerns (caching, queuing) in business logic

#### Dead Code
Files, functions, or exports that nothing uses.

Signals:
- Exported functions with zero importers (excluding entry points)
- Feature flags that are always on or always off
- Commented-out code blocks
- Files in the tree that no other file references

### Step 3 — Produce the Report

```
═══════════════════════════════════════
  IRONWORKS ARCH — [Project Name]
  [Date] · [N] source files analyzed
═══════════════════════════════════════

ARCHITECTURE SCORE: [A-F]
  Complexity: [Low/Medium/High]
  Coupling:   [Low/Medium/High]
  Cohesion:   [Low/Medium/High]

CRITICAL (fix soon):
  🔴 GOD FILE: backend/app/core/utils.py (840 lines, 16 dependents)
     Problem: Mixes auth helpers, date parsing, string formatting, and DB utils
     Fix: Split into auth_utils.py, date_utils.py, string_utils.py. Each < 100 lines.
     Impact: 16 files need import updates.

  🔴 CIRCULAR DEP: services/auth.py ↔ services/user.py
     Problem: auth imports get_user, user imports verify_token
     Fix: Extract verify_token to core/security.py (already has JWT setup)
     Impact: 2 files change.

WARNINGS (address when convenient):
  🟡 LAYER VIOLATION: routes/admin.py imports from routes/auth.py
     Should: Import from services/auth.py instead
     Impact: 1 file change.

  🟡 MISSING BOUNDARY: frontend/src/lib/ has 12 files, no index.ts
     Should: Add index.ts exporting only the public API
     Impact: Improves discoverability, no functional change.

NOTES:
  🟢 DEAD CODE: frontend/src/components/OldModal.tsx — zero importers
     Likely leftover from a removed feature. Safe to delete.

IMPROVEMENT PLAN (ordered by impact ÷ effort):
  1. Split core/utils.py (high impact, medium effort) → /iron:spec propose split-utils
  2. Break auth↔user cycle (high impact, low effort) → direct fix
  3. Fix admin route layer violation (low impact, low effort) → direct fix
  4. Add lib/index.ts boundary (medium impact, low effort) → direct fix
  5. Remove dead components (low impact, low effort) → direct fix
```

### Step 4 — Generate Proposals (with --fix)

For each Critical issue, generate an ironworks spec proposal:

```
/iron:spec propose split-utils
```

This creates a change folder with requirements, design, and tasks for
the refactoring — so it's tracked and reviewable, not a drive-by change.

## Rules

- **Evidence over opinion.** Every finding must reference specific files and line numbers.
- **Impact over count.** One god file causes more damage than ten dead imports.
  Rank by actual impact on development velocity.
- **Don't flag style.** Architecture analysis is about structure, not formatting.
- **Propose, don't just complain.** Every finding must have a concrete fix suggestion
  with an estimate of effort and files affected.
- **Respect existing patterns.** If the codebase consistently uses a pattern you
  disagree with, flag it as a note, not a critical. Consistency beats preference.
- **Score honestly.** Most codebases score C or D. An A means few issues and
  strong boundaries. Don't grade on a curve.
