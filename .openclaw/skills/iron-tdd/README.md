# /iron:tdd — Test-Driven Development

> Enforce the red-green-refactor cycle: write the test first, make it pass with minimum code, then clean up. No skipping steps.

**Layer:** L4 — Build | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Enforces disciplined TDD by guiding you through vertical slices: one test, one implementation, one cleanup pass. It identifies the seam under test before writing anything, prevents common anti-patterns (tautological tests, horizontal slicing, implementation coupling), and enforces strict mocking rules — mock only at system boundaries, never your own code.

## Quick Start

```
/iron:tdd <what to build>            # Start a TDD cycle
/iron:tdd fix <bug description>      # Bug fix via regression test first
/iron:tdd continue                   # Resume from last cycle
```

## Key Features

- Seam-based testing: identifies the public boundary before writing tests
- Vertical slices: one test per cycle, not batched
- Strict mocking rules (only external APIs, databases, time, filesystem)
- Anti-pattern detection: tautological tests, implementation coupling, horizontal slicing
- Integrates with /iron:spec scenarios as test cases

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill pairs with spec-driven development and feeds into review:

```
/iron:spec apply → /iron:tdd → /iron:review
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
