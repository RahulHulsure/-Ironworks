# /iron:arch — Architecture Analysis

> Scan for structural problems — god files, circular deps, layer violations, shallow modules, missing boundaries — and produce an improvement plan.

**Layer:** L4 — Build | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Analyzes your codebase structure using deep-module vocabulary (from Ousterhout's *A Philosophy of Software Design*) and Fowler's 12 code smells. Produces a scored report with critical issues, warnings, and an improvement plan ordered by impact-to-effort ratio. With `--fix`, it generates Design-It-Twice alternatives, spec proposals, and Architecture Decision Records.

## Quick Start

```
/iron:arch                           # Full architecture scan
/iron:arch --focus <area>            # Scan a specific module or directory
/iron:arch --quick                   # Top 5 issues only
/iron:arch --fix                     # Scan + generate refactor proposals + ADRs
```

## Key Features

- Depth analysis: measures interface size vs. implementation complexity per module
- Detects god files, circular deps, layer violations, shallow modules, abstraction leaks, dead code
- Fowler smell baseline (12 named smells applied to every codebase)
- Design-It-Twice: generates 2-3 radically different designs for each critical issue
- Generates Architecture Decision Records (ADRs) documenting choices and rationale

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill connects understanding to refactoring:

```
/iron:graph → /iron:arch → /iron:arch --fix → /iron:spec propose
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
