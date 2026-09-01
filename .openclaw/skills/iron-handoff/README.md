# /iron:handoff — Session Handoff

> Compress the current session into a structured handoff document: what was done, what's in progress, what's blocked, key decisions, and exact codebase state.

**Layer:** L-infinity — Continuity | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Captures everything a new session or team member needs to continue where you left off. Scans files modified, decisions made, git state, open questions, and ironworks spec progress. Produces agent-optimized or human-readable handoffs, filters out secrets, accumulates lessons learned across sessions, and recommends the next action (continue, handoff, subagent, or compact).

## Quick Start

```
/iron:handoff                        # Generate handoff for current session
/iron:handoff --for-agent            # Optimized for another Claude session
/iron:handoff --for-human            # Optimized for a human team member
```

## Key Features

- Two output formats: machine-parseable (for agents) and narrative (for humans)
- Privacy filter redacts API keys, tokens, passwords, and connection strings
- Cross-session continuity: reads prior handoffs and carries forward lessons
- Phase boundary decision: recommends continue, handoff, subagent, or compact
- Suggests specific /iron:* commands for the next session to start with

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill bookends every session:

```
[any work] → /iron:handoff → [new session picks up]
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
