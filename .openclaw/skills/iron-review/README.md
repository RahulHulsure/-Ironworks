# /iron:review — Smart Code Review

> Two-axis code review: Standards (discipline ladder + Fowler smells + security) and Spec (requirements compliance + test coverage). Not just style — substance.

**Layer:** L5 — Quality | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Reviews code on two independent axes. The Standards axis checks code quality using a discipline ladder, 12 Fowler smells, and security basics. The Spec axis checks whether the code builds the right thing and has tests proving it. The axes never merge — a change can pass one and fail the other. Delivers a verdict: SHIP IT, FIX AND RESHIP, or RETHINK.

## Quick Start

```
/iron:review                         # Review uncommitted changes
/iron:review --staged                # Review staged changes only
/iron:review --branch <branch>       # Review changes vs main/master
/iron:review --spec <name>           # Review against a specific spec
/iron:review --fix                   # Review + auto-fix blockers
/iron:review --over-engineering      # Over-engineering scan only
```

## Key Features

- Two parallel axes: Standards and Spec (never merged or reranked)
- Over-engineering tags: `delete:`, `stdlib:`, `native:`, `yagni:`, `shrink:`
- Security basics checklist (SQL injection, secrets, CORS, auth, input validation)
- Findings rated as Block, Concern, or Note
- Respects repo-specific standards from CLAUDE.md / CONTRIBUTING.md

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is the quality gate before shipping:

```
/iron:tdd → /iron:review → /iron:preflight → /iron:deploy
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
