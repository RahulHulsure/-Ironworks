# /iron:spec — Spec-Driven Development

> Manage the full feature lifecycle: explore, propose, design, implement, verify, update, and archive — all driven by plain Markdown specs.

**Layer:** L3 — Plan | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Every feature starts as a spec before it becomes code. This skill manages proposals with RFC 2119 requirements (SHALL/SHOULD/MAY), GIVEN/WHEN/THEN scenarios, technical designs, and ordered task checklists. It tracks domain vocabulary in CONTEXT.md and archives completed work with delta markers (ADDED/MODIFIED/REMOVED) into living specs.

## Quick Start

```
/iron:spec explore <topic>           # Research before committing
/iron:spec propose <name>            # Create a feature proposal
/iron:spec show                      # View specs and in-flight changes
/iron:spec apply <name>              # Implement the next task
/iron:spec verify <name>             # Validate code against the spec
/iron:spec archive <name>            # Seal completed work into living specs
```

## Key Features

- RFC 2119 requirements with GIVEN/WHEN/THEN scenarios
- Four-file proposal structure: proposal.md, requirements.md, design.md, tasks.md
- Domain glossary tracking in CONTEXT.md (rejects fuzzy synonyms)
- Delta-based archiving preserves spec history
- Verify mode audits implementation against spec for gaps and scope creep

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is the planning hub that feeds into building and review:

```
/iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:spec archive
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
