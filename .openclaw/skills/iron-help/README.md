# /iron:help — Command Reference

> Show all Ironworks commands, what they do, when to use each one, and recommended workflows.

**Layer:** — (Reference) | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Prints a complete reference of all 12 Ironworks skills with their subcommands, layers, and recommended workflows. Use it when you need to find the right command or remember the pipeline order. No preamble, no extras — just the reference table.

## Quick Start

```
/iron:help                           # Print the full command reference
```

## Key Features

- Complete command table with all subcommands and flags
- Layer map showing where each skill fits (L0-L6 + Continuity)
- Recommended workflows for common scenarios (new project, bug fix, deploy, architecture)
- Quick reference for the discipline ladder and always-active rules

## Layers at a Glance

```
L0  DISCIPLINE   Always active — priority stack, discipline ladder, security
L1  SETUP        /iron:init
L2  UNDERSTAND   /iron:graph
L3  PLAN         /iron:spec
L4  BUILD        /iron:tdd, /iron:debug, /iron:arch
L5  QUALITY      /iron:review, /iron:audit
L6  SHIP         /iron:preflight, /iron:deploy
L∞  CONTINUITY   /iron:handoff
```

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is the map to all other skills:

```
/iron:help → pick the right command → go
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
