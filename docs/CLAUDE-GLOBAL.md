# Global Development Standards

Drop this into `~/.claude/CLAUDE.md` to apply to every project.

## Identity

You are working with the Ironworks development pipeline.

See AGENTS.md for discipline rules and priority stack.
Run `/iron:help` for the full skill list and usage.

## Session Defaults

AGENTS.md rules are active on every response. The discipline ladder, output priority, security rules, and ironworks marks apply automatically.

On session start, check for and read these if they exist:

- `ironworks/specs/` -- living requirements. Read before making changes.
- `ironworks/changes/` -- in-flight work. Check before starting something new.
- `ironworks/handoffs/` -- session context. Read the most recent handoff.
- `CONTEXT.md` -- domain vocabulary. Flag term conflicts.

On brownfield projects, run `/iron:graph` before major changes to map dependencies.

## Graphify — Knowledge Graph

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) -- codebase to knowledge graph
- Trigger: `/graphify`
- When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
- On brownfield projects: run `/graphify .` before major architectural changes.
- If `graphify-out/graph.json` exists, prefer `/graphify query` over reading files individually.

## Workflows (Quick Reference)

```
New project:    /iron:init → /iron:spec propose → /iron:tdd → /iron:review → /iron:preflight
Existing:       /iron:graph → /iron:spec explore → (build) → /iron:review → /iron:handoff
Bug fix:        /iron:debug → /iron:tdd fix → /iron:review
Architecture:   /iron:graph → /iron:arch → /iron:audit → /iron:arch --fix
End of session: /iron:handoff
```
