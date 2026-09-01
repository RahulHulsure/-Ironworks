---
name: iron-graph
description: "Map a codebase into a dependency graph: modules, imports, exports, cross-file connections, god files, orphaned code, community detection, and confidence-scored edges. Understand before you build."
homepage: https://github.com/RahulHulsure/-Ironworks
license: MIT
---

# /iron:graph — Codebase Dependency Map

Map the codebase before making changes. This skill reads the project structure,
traces imports and exports, identifies modules and their connections, detects
communities of related files, and produces a queryable dependency report with
confidence-scored edges.

This is not a full knowledge graph engine — it's a focused dependency mapper
that gives you the understanding you need before touching unfamiliar code.

## When to Use

- Joining an existing project — understand what connects to what
- Before a major refactor — find all callers and dependents
- Before adding a feature — understand where it fits
- Debugging — trace how data flows through the system
- Finding subsystems — identify natural boundaries in the codebase

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

Every connection in the graph must carry a confidence tag. Never omit an
uncertain edge — flag it instead.

| Tag | Confidence | Meaning |
|---|---|---|
| **EXTRACTED** | 1.0 | Found directly in source: explicit import, export, or call |
| **INFERRED** | 0.4–0.9 | Derived through resolution: shared DB table, event bus, naming convention, API call chain, env var dependency |
| **AMBIGUOUS** | 0.1–0.3 | Uncertain connection, flagged for human review: possible shared state, naming similarity, indirect coupling |

- All non-EXTRACTED edges must display their confidence score.
- Never hide uncertain edges. Mark them AMBIGUOUS and include them.
- In `--deep` mode, lower the threshold for adding INFERRED edges (accept
  weaker signals: naming patterns, co-change frequency, similar parameter types).

## Community Detection

Group related files into communities (subsystems) using import clustering:

1. **Cluster by imports.** Files that import heavily from each other belong to
   the same community. Use the import graph to find tightly connected clusters.
2. **Label each community** with a 2–5 word name describing its purpose
   (e.g., "Auth & Session Management", "Payment Processing", "UI Layout System").
3. **Report cohesion** within each community: what percentage of a community's
   imports are internal vs. external.
4. **Identify cross-community connections.** Flag surprising edges — connections
   that cross community boundaries unexpectedly. These are often coupling problems
   or hidden shared dependencies.
5. **Identify god nodes.** Files with 10+ incoming connections that bridge
   multiple communities are god nodes. They are high-risk targets for refactoring.

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
   - Tag as **EXTRACTED** (confidence 1.0) if it is an explicit import/export.
   - Tag as **INFERRED** (confidence 0.4–0.9) if derived through resolution:
     shared DB table, event bus, API call chain, env var dependency.
   - Tag as **AMBIGUOUS** (confidence 0.1–0.3) if uncertain: possible coupling
     through naming, co-location, or unclear shared state. Flag for human review.
   - Note the direction: A depends on B, or bidirectional.

4. **Detect communities.** Cluster files into subsystems based on import density.
   Label each community. Compute cohesion scores.

5. **Identify patterns:**
   - **God nodes** — files with 10+ incoming connections that bridge multiple
     communities (high coupling risk)
   - **Orphaned files** — files nothing imports (dead code candidates)
   - **Circular deps** — A → B → C → A chains
   - **Layer violations** — routes importing from other routes, models calling services
   - **Surprise connections** — edges that cross community boundaries unexpectedly

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

7. **Save the report** to `ironworks/graph-report.md` for future reference.

8. **Save the manifest** to `ironworks/graph-manifest.json` — a record of every
   file scanned with its last-modified timestamp. Used by `--update` for
   incremental rebuilds.

### For `/iron:graph query "<question>"`

1. If `ironworks/graph-report.md` exists, read it for context.
2. Otherwise, run a targeted scan of the files relevant to the question.
3. Trace the connections related to the question:
   - Follow imports/exports
   - Check for shared database tables
   - Look for API call chains
   - Identify event-driven connections
4. **Default traversal is BFS** (broad, nearest neighbors first, depth 3).
   This finds the most directly related files quickly.
5. If `--dfs` is specified, use **DFS traversal** (follows specific paths deeply,
   depth 6). Better for tracing a single flow end-to-end.
6. If `--budget N` is specified, cap the response at N tokens. Prioritize the
   most relevant connections and truncate the rest with a note.
7. Answer the question with specific file references and connection paths.
   Show confidence scores on all non-EXTRACTED edges.

### For `/iron:graph deps <file>`

1. Read the specified file.
2. List everything it imports (with file paths).
3. Search the codebase for everything that imports from it.
4. Show the dependency tree with confidence tags:

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

1. Find the shortest path between two concepts or files in the dependency graph.
2. If A and B are file paths, trace the import chain between them.
3. If A and B are concept names (e.g., "authentication", "payment"), resolve them
   to the most relevant files first, then find the path.
4. Show every hop with its confidence tag:

```
PATH: auth.py → user.py → payment.py
  auth.py → user.py        [EXTRACTED — imports User model]
  user.py → payment.py     [INFERRED 0.6 — shared user_id FK]
  Total hops: 2 · Lowest confidence: 0.6
```

5. If no path exists, say so. If multiple paths exist, show the shortest and
   mention alternatives.

### For `/iron:graph hotspots`

List the top 10 most-connected files with their connection counts and
a brief note on risk: "Changing this file affects N other files."
Flag god nodes: files with 10+ incoming connections that bridge multiple
communities. For each god node, list which communities it bridges.

### For `/iron:graph orphans`

List files that nothing imports. For each, note:
- Is it a legitimate entry point (main.py, index.ts, test file)?
- Or is it likely dead code?
- Suggest: keep, investigate, or delete.

### For `/iron:graph --deep`

Run the full map with aggressive inference mode:
- Lower the threshold for INFERRED edges (accept weaker signals).
- Look for: naming convention matches, co-change patterns, similar parameter
  types, shared constants, parallel directory structures.
- All additional edges are tagged INFERRED with their confidence score.
- Never tag an aggressively inferred edge as EXTRACTED.

### For `/iron:graph --watch`

Auto-rebuild the graph when files change:
- **Code-only changes** (source files): free rescan — update the graph
  automatically without user confirmation.
- **Doc changes** (markdown, config, specs): flag for full update. Notify the
  user: "Documentation changed — run `/iron:graph --update` to rebuild."
- Uses the manifest (`ironworks/graph-manifest.json`) to detect changes.

### For `/iron:graph --update`

Incremental rebuild — only re-scan files that changed since the last build:
1. Read `ironworks/graph-manifest.json` for the previous scan state.
2. Compare file timestamps. Identify added, modified, and deleted files.
3. Re-scan only the changed files and update their edges.
4. Recompute communities if the changes affect community membership.
5. Update `ironworks/graph-report.md` and `ironworks/graph-manifest.json`.
6. Report what changed: "Updated 3 files, added 2 edges, removed 1 edge."

## Rules

- **Read, don't guess.** Every EXTRACTED connection must come from actual imports, not inference.
- **Never omit uncertain edges.** If a connection is uncertain, tag it AMBIGUOUS
  with a confidence score (0.1–0.3). Hidden edges are worse than flagged ones.
- **Show confidence scores** on all non-EXTRACTED edges. EXTRACTED edges are
  confidence 1.0 by definition and don't need a score displayed.
- **Mark uncertainty.** If a connection is indirect (shared DB table, event bus),
  label it INFERRED with its confidence score.
- **Be actionable.** "14 files depend on database.py" is useful. A raw adjacency list is not.
- **Don't read every line.** Scan imports, exports, and function signatures. Skip implementations.
- **Update on re-run.** If `ironworks/graph-report.md` exists, regenerate it — don't append.
- **Stay focused.** This is a dependency map, not a full codebase review. Don't flag bugs.
- **Communities are descriptive.** Label communities with what they do, not where they are.
  "Auth & Session Management" is good. "backend/app/services/" is not a community name.
