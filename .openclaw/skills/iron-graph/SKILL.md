---
name: iron-graph
description: "Map codebase dependencies, hotspots, orphans, communities, and circular deps with confidence-scored edges."
---

# /iron:graph

Map the codebase before making changes. Traces imports/exports, detects
communities, and produces a dependency report with confidence-scored edges.

## Invocation

```
/iron:graph                          # Map the current project
/iron:graph <path>                   # Map a specific directory
/iron:graph query "how does X connect to Y?"   # Ask about the codebase (BFS, depth 3)
/iron:graph query "..." --dfs        # DFS traversal (specific paths, depth 6)
/iron:graph query "..." --budget 1500  # Cap response at N tokens
/iron:graph deps <file>              # Show what a file depends on and what depends on it
/iron:graph hotspots                 # Find the most-connected files (god files)
/iron:graph orphans                  # Find files nothing imports
/iron:graph path "A" "B"             # Shortest path between two concepts or files
/iron:graph --deep                   # Aggressive inference mode (more INFERRED edges)
/iron:graph --watch                  # Auto-rebuild on file changes
/iron:graph --update                 # Incremental rebuild (only changed files)
```

## Edge Confidence Scoring

Every connection must carry a confidence tag. Never omit an uncertain
edge -- flag it instead.

| Tag | Confidence | Meaning |
|---|---|---|
| **EXTRACTED** | 1.0 | Found directly in source: explicit import, export, or call |
| **INFERRED** | 0.4–0.9 | Derived through resolution: shared DB table, event bus, naming convention, API call chain, env var dependency |
| **AMBIGUOUS** | 0.1–0.3 | Uncertain connection, flagged for human review: possible shared state, naming similarity, indirect coupling |

## Community Detection

Group related files into communities using import clustering:

1. **Cluster by imports.** Files importing heavily from each other = same community.
2. **Label each community** with a 2–5 word purpose name.
3. **Report cohesion** -- percentage of internal vs. external imports.
4. **Flag cross-community edges** crossing boundaries unexpectedly.
5. **Identify god nodes** -- 10+ incoming connections bridging multiple communities.

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

3. **Build the connection map.** Tag each edge per the confidence table above.
   Note direction: A depends on B, or bidirectional.

4. **Detect communities** (see Community Detection above).

5. **Identify patterns:**
   - **Orphaned files** -- files nothing imports (dead code candidates)
   - **Circular deps** -- A → B → C → A chains
   - **Layer violations** -- routes importing from other routes, models calling services
   - **Surprise connections** -- edges crossing community boundaries unexpectedly

6. **Produce the report.** Output as structured text:

```
═══════════════════════════════════════
  IRONWORKS GRAPH — [Project Name]
  [N] source files · [M] connections
  [C] communities detected
═══════════════════════════════════════

COMMUNITY MAP
  [1] Auth & Session Management    [8 files, 87% internal cohesion]
      backend/app/core/security.py, backend/app/services/auth.py,
      backend/app/routes/auth.py, backend/app/models/user.py, ...
  [2] Payment Processing           [5 files, 92% internal cohesion]
      backend/app/services/payment.py, backend/app/models/invoice.py, ...
  [3] UI Layout System             [12 files, 78% internal cohesion]
      frontend/src/components/Layout.tsx, frontend/src/app/page.tsx, ...

MODULES
  backend/app/core/       [6 files] — config, security, database setup
  backend/app/routes/     [8 files] — API endpoints
  backend/app/services/   [5 files] — business logic
  backend/app/models/     [4 files] — database models
  frontend/src/app/       [12 files] — pages and layouts
  frontend/src/components/ [15 files] — shared components
  frontend/src/lib/       [3 files] — API client, utilities

HOTSPOTS (most depended on)
  1. backend/app/core/database.py     — 14 dependents [GOD NODE: bridges Auth, Payment, Data]
  2. backend/app/core/config.py       — 11 dependents [GOD NODE: bridges Auth, Payment, UI]
  3. frontend/src/lib/api.ts          — 9 dependents

ORPHANS (nothing imports these)
  - backend/app/utils/legacy_parser.py
  - frontend/src/components/OldModal.tsx

CIRCULAR DEPENDENCIES
  ⚠️ services/auth.py ↔ services/user.py (bidirectional import)

LAYER VIOLATIONS
  ⚠️ routes/admin.py imports from routes/auth.py (route-to-route dependency)

SURPRISE CONNECTIONS (cross-community edges)
  ⚠️ Payment → Auth: payment.py imports auth.py (INFERRED 0.7 — shared user lookup)
  ⚠️ UI → Data: Dashboard.tsx references analytics.py schema (AMBIGUOUS 0.3)

SUGGESTED QUESTIONS
  → "How does authentication flow from login to protected routes?"
  → "What would break if I changed the User model?"
  → "What files are involved in the payment flow?"
  → "Why does Payment depend on Auth — is this coupling necessary?"
  → "Which community has the lowest cohesion and why?"
```

7. **Save the report** to `ironworks/graph-report.md`.

8. **Save the manifest** to `ironworks/graph-manifest.json` -- file timestamps
   for `--update` incremental rebuilds.

### For `/iron:graph query "<question>"`

1. Read `ironworks/graph-report.md` if it exists; otherwise targeted scan.
2. Trace connections: imports, shared DB tables, API chains, events.
3. **Default: BFS** (broad, depth 3). With `--dfs`: DFS (deep, depth 6).
4. With `--budget N`, cap at N tokens and truncate with a note.
5. Answer with file references and confidence scores on non-EXTRACTED edges.

### For `/iron:graph deps <file>`

1. Read the file. List what it imports (with file paths).
2. Search the codebase for everything that imports from it.
3. Show the dependency tree with confidence tags:

```
backend/app/services/auth.py
  DEPENDS ON:
    → core/database.py (Session, get_db)              [EXTRACTED]
    → core/config.py (settings)                       [EXTRACTED]
    → models/user.py (User model)                     [EXTRACTED]
    → schemas/auth.py (LoginRequest, TokenResponse)   [EXTRACTED]

  DEPENDED ON BY:
    ← routes/auth.py (login, register endpoints)      [EXTRACTED]
    ← routes/admin.py (admin-only endpoints)           [EXTRACTED]
    ← services/payment.py (user verification)          [INFERRED 0.7 — shared user lookup]
```

### For `/iron:graph path "A" "B"`

1. Find the shortest path between two concepts or files.
2. If file paths, trace the import chain. If concept names, resolve to files first.
3. Show every hop with its confidence tag:

```
PATH: auth.py → user.py → payment.py
  auth.py → user.py        [EXTRACTED — imports User model]
  user.py → payment.py     [INFERRED 0.6 — shared user_id FK]
  Total hops: 2 · Lowest confidence: 0.6
```

4. If no path exists, say so. If multiple, show shortest and note alternatives.

### For `/iron:graph hotspots`

List the top 10 most-connected files with connection counts and
risk note: "Changing this file affects N other files."

### For `/iron:graph orphans`

List unimported files. Note if each is a legitimate entry point or dead code.
Suggest: keep, investigate, or delete.

### For `/iron:graph --deep`

Full map with aggressive inference. Lower INFERRED threshold, look for naming
matches, co-change patterns, similar types, shared constants. Tag all as
INFERRED (never EXTRACTED).

### For `/iron:graph --watch`

Auto-rebuild on file changes. Code changes rescan automatically; doc changes
prompt user to run `--update`. Uses `ironworks/graph-manifest.json`.

### For `/iron:graph --update`

Incremental rebuild -- only re-scan changed files:
1. Read `ironworks/graph-manifest.json` for previous scan state.
2. Compare timestamps. Identify added, modified, deleted files.
3. Re-scan changed files and update edges.
4. Recompute communities if changes affect membership.
5. Update `ironworks/graph-report.md` and `ironworks/graph-manifest.json`.
6. Report: "Updated 3 files, added 2 edges, removed 1 edge."

## Rules

- **Read, don't guess.** Every EXTRACTED connection must come from actual imports.
- **Be actionable.** "14 files depend on database.py" is useful. A raw adjacency list is not.
- **Don't read every line.** Scan imports, exports, signatures. Skip implementations.
- **Update on re-run.** If `ironworks/graph-report.md` exists, regenerate -- don't append.
- **Stay focused.** Dependency map, not codebase review. Don't flag bugs.
- **Communities are descriptive.** Label by purpose, not path.
