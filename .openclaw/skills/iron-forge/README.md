# /iron:forge — Autonomous App Builder

> One command: requirements in, deploy-ready app out. Chains every Ironworks skill into an autonomous pipeline.

**Layer:** ★ Orchestrator | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Takes raw app requirements and autonomously drives the full Ironworks pipeline — init → spec → build → review → ship — producing a tested, reviewed, deploy-ready application. Auto-detects project state and adapts: works on empty directories, existing codebases, partially built projects, or mid-session resumes.

## Quick Start

```
/iron:forge "A task management API with auth, teams, and real-time updates" --platform fly
/iron:forge --file requirements.md --stack fastapi --platform aws
/iron:forge --resume                 # Pick up where you left off
/iron:forge --dry-run                # Plan the build without executing
/iron:forge status                   # Check progress mid-build
```

## Key Features

- **5 entry modes**: GREENFIELD, BROWNFIELD, MIDSTREAM, RESUME, EXTEND — auto-detected
- **4 feature modes**: NEW, EXISTS, EXTEND, REWORK — per-feature based on codebase reconnaissance
- **6-phase pipeline**: Intake → Foundation → Specification → Build → Integration → Ship
- **Quality gates** at every phase boundary with retry loops and hard caps
- **Checkpoint system** for resumable builds across sessions (`ironworks/forge/checkpoint.json`)
- **Codebase reconnaissance**: maps existing code, identifies features, builds only what's new
- Chains all 12 original skills: init, graph, spec, tdd, debug, arch, review, audit, preflight, deploy, handoff

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory **and all other skill directories** to your project's `.claude/skills/` (or equivalent)
2. `/iron:forge` orchestrates the other skills — it requires them to be available

## Part of the Ironworks Pipeline

This skill sits above all layers as the orchestrator:

```
/iron:forge → init → graph → spec → tdd → debug → arch → review → audit → preflight → deploy → handoff
```

→ [View all 13 skills](https://github.com/RahulHulsure/-Ironworks)
