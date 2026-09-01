# /iron:graph — Codebase Dependency Map

> Map a codebase into a dependency graph with modules, imports, hotspots, orphans, communities, and confidence-scored edges.

**Layer:** L2 — Understand | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Reads your project structure, traces imports and exports, clusters files into communities, and produces a queryable dependency report. Every connection is tagged with a confidence score (EXTRACTED, INFERRED, or AMBIGUOUS) so you know what's certain and what needs human review. Use it before refactors, when joining a new codebase, or to find god files and dead code.

## Quick Start

```
/iron:graph                          # Map the current project
/iron:graph query "how does X flow?" # Ask about codebase connections
/iron:graph deps <file>              # Show a file's dependency tree
/iron:graph hotspots                 # Find most-connected files
/iron:graph orphans                  # Find unused files
/iron:graph path "A" "B"             # Shortest path between two concepts
/iron:graph --update                 # Incremental rebuild (changed files only)
```

## Key Features

- Community detection groups related files into labeled subsystems
- Confidence-scored edges (never hides uncertain connections — flags them)
- Detects god nodes, circular dependencies, layer violations, and surprise cross-community edges
- Incremental rebuilds via `--update` using a saved manifest
- BFS (default, depth 3) or DFS (`--dfs`, depth 6) query traversal

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill provides the understanding layer before planning or building:

```
/iron:graph → /iron:arch → /iron:spec propose → /iron:tdd
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
