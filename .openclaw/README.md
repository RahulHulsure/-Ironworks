# `.openclaw/` — Skills Directory

This is the skills directory for Claude Code and OpenClaw-compatible AI coding tools.

## Structure

```
.openclaw/
└── skills/
    ├── iron-init/SKILL.md
    ├── iron-graph/SKILL.md
    ├── iron-spec/SKILL.md
    ├── iron-tdd/SKILL.md
    ├── iron-debug/SKILL.md
    ├── iron-arch/SKILL.md
    ├── iron-review/SKILL.md
    ├── iron-audit/SKILL.md
    ├── iron-preflight/SKILL.md
    ├── iron-deploy/SKILL.md
    ├── iron-handoff/SKILL.md
    └── iron-help/SKILL.md
```

Each subdirectory contains one skill defined by a `SKILL.md` file. The `SKILL.md` file is the skill's complete instruction set — Claude Code reads it when the corresponding `/iron:*` slash command is invoked.

## How Skills Are Loaded

Claude Code scans `.openclaw/skills/*/SKILL.md` at plugin load time. Each skill directory name maps to a slash command:

- `iron-init/` maps to `/iron:init`
- `iron-graph/` maps to `/iron:graph`
- etc.

See [`skills/README.md`](skills/README.md) for a full listing of all 12 skills.
