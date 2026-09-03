---
name: iron-arch
description: "Scan for structural problems and produce an improvement plan using deep-module vocabulary."
---

# /iron:arch

Scan the codebase for structural problems and produce an actionable improvement
plan.

## Vocabulary

Use these terms precisely throughout every analysis. They come from John
Ousterhout's *A Philosophy of Software Design* and are scale-agnostic -- they
apply to a function, a class, a package, or a service.

- **Module:** Anything with an interface and an implementation. A function, a
  class, a package, a microservice -- the scale does not matter.
- **Interface:** Everything a caller must know. Not just the type signature --
  also invariants, ordering constraints, error modes, and performance
  characteristics.
- **Depth:** The leverage at the interface. A deep module provides lots of
  behavior behind a small interface. A shallow module has a large interface
  relative to the behavior it hides.
- **Seam:** A place where you can alter behavior without editing in that place.
  Seams exist at module boundaries where adapters can be swapped.
- **Adapter:** A concrete thing that satisfies an interface at a seam (e.g.,
  `StripeGateway` and `TestGateway` for the same seam).
- **Leverage:** What callers get from depth.
- **Locality:** What maintainers get from depth.

## Invocation

```
/iron:arch                           # Full architecture scan
/iron:arch --focus <area>            # Scan a specific module or directory
/iron:arch --quick                   # Top 5 issues only
/iron:arch --fix                     # Scan + generate refactor proposals + ADRs
```

## What You Must Do When Invoked

### Step 1 — Map the Structure

Read the project tree and identify:

1. **Layers** -- what layers exist? Common patterns:
   - Routes/Controllers → Services → Models → Database
   - Pages → Components → Hooks → Utils → API
   - Handlers → Use Cases → Entities → Repositories

2. **Boundaries** -- where are the module boundaries? Look for:
   - Directory structure (each dir = a module?)
   - Package/namespace organization
   - Index/barrel files that define public APIs

3. **Entry points** -- how does execution flow into the system?
   - HTTP routes, CLI commands, event handlers, cron jobs

4. **Depth map** -- for each major module, assess its depth:
   - Interface size (how much must callers know?)
   - Implementation size (how much behavior is hidden?)
   - Ratio = depth. Flag modules where the interface is nearly as complex as the
     implementation.

### Step 2 — Detect Issues

Scan for these specific architectural problems:

#### God Files
Files with too many responsibilities or too many dependents.
- File is > 500 lines and not a migration or generated code
- File has > 10 incoming imports (everything depends on it)
- File mixes concerns (DB queries + business logic + HTTP handling)

#### Circular Dependencies
A depends on B, B depends on A (directly or through a chain).
- Explicit circular imports (some languages throw errors, others don't)
- Implicit circular deps through shared mutable state
- Two modules that import each other "for just one function"

#### Layer Violations
Code that skips layers or reaches in the wrong direction.
- Routes importing from other routes
- Models calling services
- Database queries in route handlers (bypassing services)
- Frontend components making direct API calls instead of using a client layer

#### Missing Boundaries
Modules that expose their internals instead of a clean interface.
- No index/barrel file -- everything is imported by deep path
- Internal implementation details imported by external code
- "Utility" files that are actually a dumping ground for unrelated functions

#### Shallow Modules
Modules with a large interface surface relative to the complexity they hide.
- Wrapper classes that add no behavior (pass-through to another module)
- Thin facades that expose every method of the underlying implementation
- Modules whose interface has more symbols than their implementation
- "Manager" or "Helper" classes that just delegate

**The deletion test:** If deleting a module makes complexity reappear across N
callers, it was deep. If deleting it just moves one line into each caller, it
was shallow -- the indirection cost more than the abstraction saved.

#### Abstraction Leaks
Low-level details exposed through high-level interfaces.
- Database column names in API responses
- ORM models used as API response types
- SQL or query syntax visible in service layer
- Infrastructure concerns (caching, queuing) in business logic

#### Dead Code
Files, functions, or exports that nothing uses.
- Exported functions with zero importers (excluding entry points)
- Feature flags that are always on or always off
- Commented-out code blocks
- Files in the tree that no other file references

#### Fowler Smell Baseline

These 12 smells from Martin Fowler's *Refactoring* (Chapter 3) apply to every
codebase regardless of language. Check for each during analysis:

1. **Mysterious Name** -- rename to reveal purpose.
2. **Duplicated Code** -- extract and share.
3. **Feature Envy** -- move to the module whose data it uses.
4. **Data Clumps** -- extract co-traveling data into a struct.
5. **Primitive Obsession** -- replace bare primitives with value objects.
6. **Repeated Switches** -- replace with polymorphism.
7. **Shotgun Surgery** -- consolidate scattered behavior.
8. **Divergent Change** -- split by responsibility.
9. **Speculative Generality** -- delete unused abstractions.
10. **Message Chains** -- hide the object graph.
11. **Middle Man** -- remove and let callers talk directly.
12. **Refused Bequest** -- replace inheritance with composition.

When reporting smells, reference the specific smell name and the module where it
occurs. Report only what is actually present.

### Step 3 — Produce the Report

```
═══════════════════════════════════════
  IRONWORKS ARCH — [Project Name]
  [Date] · [N] source files analyzed
═══════════════════════════════════════

VOCABULARY:
  Modules: [N] major modules identified
  Deepest: [module name] (small interface, large implementation)
  Shallowest: [module name] (large interface, little hidden complexity)

ARCHITECTURE SCORE: [A-F]
  Complexity: [Low/Medium/High]
  Coupling:   [Low/Medium/High]
  Cohesion:   [Low/Medium/High]
  Depth:      [Shallow/Mixed/Deep]

CRITICAL (fix soon):
  🔴 GOD FILE: backend/app/core/utils.py (840 lines, 16 dependents)
     Problem: Mixes auth helpers, date parsing, string formatting, and DB utils
     Smells: Divergent Change, Shotgun Surgery
     Fix: Split into auth_utils.py, date_utils.py, string_utils.py. Each < 100 lines.
     Impact: 16 files need import updates.

  🔴 CIRCULAR DEP: services/auth.py ↔ services/user.py
     Problem: auth imports get_user, user imports verify_token
     Smells: Feature Envy (verify_token envies core/security)
     Fix: Extract verify_token to core/security.py (already has JWT setup)
     Impact: 2 files change.

  🔴 SHALLOW MODULE: services/UserManager (12 public methods, all pass-through)
     Problem: Delegates everything to UserRepository with no added behavior
     Deletion test: Removing it moves one line into each of 5 callers — not earning its keep
     Fix: Let callers use UserRepository directly, or add real business logic
     Impact: 5 files change.

WARNINGS (address when convenient):
  🟡 LAYER VIOLATION: routes/admin.py imports from routes/auth.py
     Should: Import from services/auth.py instead
     Impact: 1 file change.

  🟡 MISSING BOUNDARY: frontend/src/lib/ has 12 files, no index.ts
     Should: Add index.ts exporting only the public API
     Impact: Improves discoverability, no functional change.

  🟡 SMELL — Primitive Obsession: email addresses passed as bare strings
     in 4 modules (auth, user, notification, admin)
     Should: Extract EmailAddress value object
     Impact: 4 files change.

NOTES:
  🟢 DEAD CODE: frontend/src/components/OldModal.tsx — zero importers
     Likely leftover from a removed feature. Safe to delete.

IMPROVEMENT PLAN (ordered by impact ÷ effort):
  1. Split core/utils.py (high impact, medium effort) → /iron:spec propose split-utils
  2. Break auth↔user cycle (high impact, low effort) → direct fix
  3. Remove UserManager middleman (medium impact, low effort) → direct fix
  4. Fix admin route layer violation (low impact, low effort) → direct fix
  5. Add lib/index.ts boundary (medium impact, low effort) → direct fix
  6. Remove dead components (low impact, low effort) → direct fix
```

### Step 4 — Generate Proposals (with --fix)

When `--fix` is specified:

#### Design-It-Twice

For each **Critical** issue, generate 2-3 radically different interface designs
from different first principles.

```
DESIGN-IT-TWICE: Splitting core/utils.py

DESIGN A — Domain-aligned modules:
  auth_utils.py, date_utils.py, string_utils.py, db_utils.py
  Interface: Each module exports 3-5 functions. Callers import by domain.
  Depth: Medium — each module hides some complexity, but interfaces are small
  Locality: High — auth changes concentrate in auth_utils.py
  Seams: Each module is a seam; test adapters not needed (pure functions)

DESIGN B — Capability-based modules:
  core/security.py (auth + crypto), core/formatting.py (dates + strings), core/data.py (DB)
  Interface: Fewer modules, slightly larger interfaces
  Depth: Deeper — more behavior behind each import
  Locality: Medium — security changes touch one file, but it mixes auth + crypto
  Seams: core/data.py is a seam for DB access (test adapter possible)

DESIGN C — Inline elimination:
  Delete utils.py entirely. Move each function to its only caller.
  Interface: Zero — no shared module at all
  Depth: N/A — functions become private to their callers
  Locality: Highest — each function lives where it is used
  Seams: None — no shared boundary
  Constraint: Only works if functions have 1-2 callers. With 16 dependents, unlikely.

RECOMMENDATION: Design A
  Rationale: 16 dependents rules out Design C. Design B groups by technical
  capability rather than domain, which makes the interface harder to predict.
  Design A aligns with the domain boundaries already visible in the codebase.
  Callers can import exactly what they need.
```

Compare each design by:
- **Depth** (leverage) -- how much behavior does the interface hide?
- **Locality** (change concentration) -- does a change stay in one place?
- **Seam placement** -- where can behavior be swapped or tested?

#### Generate Ironworks Spec Proposals

For each Critical issue, generate a spec proposal:

```
/iron:spec propose split-utils
```

This creates a change folder with requirements, design, and tasks for
the refactoring -- so it's tracked and reviewable.

#### Generate Architecture Decision Records (ADRs)

For each proposal, create an ADR in `docs/adr/`.

ADR numbering: next sequential number in `docs/adr/` (create at 0001 if absent).

ADR format:
- **Title:** `NNNN-slug.md` where NNNN is zero-padded and slug is kebab-case
- **Status:** `Proposed` (the user or team changes it to Accepted/Rejected/Superseded)
- **Context:** Why this decision is needed -- reference the /iron:arch findings
- **Decision:** What was decided, and what alternatives were considered
- **Consequences:** What changes as a result, both positive and negative

## Rules

- **Evidence over opinion.** Every finding must reference specific files and line numbers.
- **Impact over count.** Rank by actual impact on development velocity.
- **Don't flag style.** Architecture analysis is about structure, not formatting.
- **Propose, don't just complain.** Every finding must have a concrete fix with effort and files affected.
- **Respect existing patterns.** If the codebase consistently uses a pattern you disagree with, flag it as a note, not a critical.
- **Score honestly.** Most codebases score C or D. Don't grade on a curve.
