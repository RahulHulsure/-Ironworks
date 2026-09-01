---
name: iron-graph
description: "Map a codebase into a dependency graph: modules, imports, exports, cross-file connections, god files, and orphaned code. Understand before you build."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:graph — Codebase Dependency Map

Map the codebase before making changes. This skill reads the project structure,
traces imports and exports, identifies modules and their connections, and
produces a queryable dependency report.

This is not a full knowledge graph engine — it's a focused dependency mapper
that gives you the understanding you need before touching unfamiliar code.

## When to Use

- Joining an existing project — understand what connects to what
- Before a major refactor — find all callers and dependents
- Before adding a feature — understand where it fits
- Debugging — trace how data flows through the system

## Invocation

```
/iron:graph                          # Map the current project
/iron:graph <path>                   # Map a specific directory
/iron:graph query "how does X connect to Y?"   # Ask about the codebase
/iron:graph deps <file>              # Show what a file depends on and what depends on it
/iron:graph hotspots                 # Find the most-connected files (god files)
/iron:graph orphans                  # Find files nothing imports
```

## What You Must Do When Invoked

### For `/iron:graph` (full map)

1. **Scan the project structure.** Read the directory tree, ignoring:
   - `node_modules/`, `.venv/`, `venv/`, `__pycache__/`, `.git/`
   - Build outputs: `dist/`, `build/`, `.next/`, `target/`
   - Generated files: `*.lock`, `*.min.js`, `*.map`

2. **Identify the module structure.** For each source file:
   - What it exports (functions, classes, components, constants)
   - What it imports (from other project files, from dependencies)
   - Its role: model, route, service, component, utility, config, test

3. **Build the connection map.** For each connection between files:
   - Mark as **DIRECT** (explicit import/export) or **INDIRECT** (shared DB table,
     event bus, API call, env var dependency)
   - Note the direction: A depends on B, or bidirectional

4. **Identify patterns:**
   - **God files** — files with 10+ incoming connections (everything depends on them)
   - **Orphaned files** — files nothing imports (dead code candidates)
   - **Circular deps** — A → B → C → A chains
   - **Layer violations** — routes importing from other routes, models calling services

5. **Produce the report.** Output as structured text:

```
═══════════════════════════════════════
  IRONWORKS GRAPH — [Project Name]
  [N] source files · [M] connections
═══════════════════════════════════════

MODULES
  backend/app/core/       [6 files] — config, security, database setup
  backend/app/routes/     [8 files] — API endpoints
  backend/app/services/   [5 files] — business logic
  backend/app/models/     [4 files] — database models
  frontend/src/app/       [12 files] — pages and layouts
  frontend/src/components/ [15 files] — shared components
  frontend/src/lib/       [3 files] — API client, utilities

HOTSPOTS (most depended on)
  1. backend/app/core/database.py     — 14 dependents
  2. backend/app/core/config.py       — 11 dependents
  3. frontend/src/lib/api.ts          — 9 dependents

ORPHANS (nothing imports these)
  - backend/app/utils/legacy_parser.py
  - frontend/src/components/OldModal.tsx

CIRCULAR DEPENDENCIES
  ⚠️ services/auth.py ↔ services/user.py (bidirectional import)

LAYER VIOLATIONS
  ⚠️ routes/admin.py imports from routes/auth.py (route-to-route dependency)

SUGGESTED QUESTIONS
  → "How does authentication flow from login to protected routes?"
  → "What would break if I changed the User model?"
  → "What files are involved in the payment flow?"
```

6. **Save the report** to `ironworks/graph-report.md` for future reference.

### For `/iron:graph query "<question>"`

1. If `ironworks/graph-report.md` exists, read it for context.
2. Otherwise, run a targeted scan of the files relevant to the question.
3. Trace the connections related to the question:
   - Follow imports/exports
   - Check for shared database tables
   - Look for API call chains
   - Identify event-driven connections
4. Answer the question with specific file references and connection paths.

### For `/iron:graph deps <file>`

1. Read the specified file.
2. List everything it imports (with file paths).
3. Search the codebase for everything that imports from it.
4. Show the dependency tree:

```
backend/app/services/auth.py
  DEPENDS ON:
    → core/database.py (Session, get_db)
    → core/config.py (settings)
    → models/user.py (User model)
    → schemas/auth.py (LoginRequest, TokenResponse)

  DEPENDED ON BY:
    ← routes/auth.py (login, register endpoints)
    ← routes/admin.py (admin-only endpoints)
    ← services/payment.py (user verification)
```

### For `/iron:graph hotspots`

List the top 10 most-connected files with their connection counts and
a brief note on risk: "Changing this file affects N other files."

### For `/iron:graph orphans`

List files that nothing imports. For each, note:
- Is it a legitimate entry point (main.py, index.ts, test file)?
- Or is it likely dead code?
- Suggest: keep, investigate, or delete.

## Rules

- **Read, don't guess.** Every connection must come from actual imports, not inference.
- **Mark uncertainty.** If a connection is indirect (shared DB table, event bus), label it.
- **Be actionable.** "14 files depend on database.py" is useful. A raw adjacency list is not.
- **Don't read every line.** Scan imports, exports, and function signatures. Skip implementations.
- **Update on re-run.** If `ironworks/graph-report.md` exists, regenerate it — don't append.
- **Stay focused.** This is a dependency map, not a full codebase review. Don't flag bugs.
