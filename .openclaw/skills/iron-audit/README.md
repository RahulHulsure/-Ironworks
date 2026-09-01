# /iron:audit — Codebase Simplification Audit

> Audit the entire codebase for over-engineering: unnecessary abstractions, speculative features, overbuilt patterns, and dead code. The discipline ladder applied repo-wide.

**Layer:** L5 — Quality | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Scans every source file asking one question: "Can this be simpler?" Finds single-implementation interfaces, wrapper functions that add no logic, speculative features, plugin systems with zero plugins, and dead exports. Every finding is tagged and measured (lines saved, files affected, risk level). The `debt` subcommand harvests `ironworks:` comment markers into a structured debt ledger.

## Quick Start

```
/iron:audit                          # Full audit
/iron:audit <path>                   # Audit a specific directory
/iron:audit --category abstractions  # Focus on one category
/iron:audit --fix                    # Audit + auto-remove dead code
/iron:audit debt                     # Harvest ironworks: debt markers
```

## Key Features

- Four audit categories: unnecessary abstractions, speculative features, overbuilt patterns, dead code
- Every finding tagged: `delete:`, `stdlib:`, `native:`, `yagni:`, `shrink:`
- Impact measurement: lines saved, files affected, risk level
- Debt ledger harvests `ironworks:` comment markers with ceilings and upgrade triggers
- Honesty boundary: never claims savings from code that was never written

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is for periodic maintenance and pre-release cleanup:

```
/iron:graph → /iron:arch → /iron:audit → /iron:audit --fix
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
