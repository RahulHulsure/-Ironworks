# /iron:debug — Structured Debugging

> Debug methodically with a feedback loop: define the problem, build a reproduction, form hypotheses, instrument, narrow, fix, and verify. No guessing.

**Layer:** L4 — Build | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Replaces "try changing this and see" with a structured process. You define the problem precisely, build a tight feedback loop (failing test, curl script, bisection harness, etc.), then systematically eliminate hypotheses using tagged instrumentation. Every debug log gets a unique tag for guaranteed cleanup. Ends with a root-cause fix, regression test, and prevention note.

## Quick Start

```
/iron:debug <problem description>    # Start structured debugging
/iron:debug narrow                   # Continue narrowing from last checkpoint
```

## Key Features

- 10 feedback loop methods ranked by priority (failing test is best, HITL is last resort)
- Hypothesis-driven: rank 2-4 hypotheses by likelihood, test one at a time
- Tagged instrumentation (`[DEBUG-XXXX]`) for guaranteed cleanup
- Non-deterministic bug support with failure rate tracking
- Prevention notes linking to other Ironworks skills that would have caught the bug

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill pairs with TDD for regression tests after fixing:

```
/iron:debug → /iron:tdd fix → /iron:review
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
