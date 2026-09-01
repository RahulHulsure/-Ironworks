# Contributing to Ironworks

Thanks for your interest in contributing to Ironworks! This document covers how to get involved.

## How to Contribute

### Report Issues
- Open a GitHub issue with a clear title and description
- Include which skill is affected (e.g., `/iron:review`)
- Describe what you expected vs. what happened

### Suggest Enhancements
- Open an issue tagged `enhancement`
- Describe the use case, not just the solution
- Reference which layer/skill it belongs to

### Submit Changes
1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test by installing locally: `claude plugin install /path/to/your/fork`
5. Commit with a clear message
6. Open a Pull Request

## Repo Structure

```
.claude-plugin/           # Plugin manifest
  plugin.json             # Name, version, description, skill list
  marketplace.json        # Marketplace metadata
.openclaw/skills/         # All 12 skills
  iron-init/SKILL.md      # L1 — Project bootstrap
  iron-graph/SKILL.md     # L2 — Dependency mapping
  iron-spec/SKILL.md      # L3 — Spec-driven dev
  iron-tdd/SKILL.md       # L4 — TDD
  iron-debug/SKILL.md     # L4 — Structured debugging
  iron-arch/SKILL.md      # L4 — Architecture analysis
  iron-review/SKILL.md    # L5 — Code review
  iron-audit/SKILL.md     # L5 — Simplification audit
  iron-preflight/SKILL.md # L6 — Deploy preflight
  iron-deploy/SKILL.md    # L6 — Deployment config
  iron-handoff/SKILL.md   # L∞ — Session handoff
  iron-help/SKILL.md      # Command reference
AGENTS.md                 # L0 — Always-on discipline rules
docs/
  CLAUDE-GLOBAL.md        # Drop-in ~/.claude/CLAUDE.md
  CLAUDE-PROJECT-TEMPLATE.md  # Per-project CLAUDE.md template
```

## Writing a SKILL.md

Each skill file follows this structure:

```markdown
---
name: iron-skillname
description: "One-line description"
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:skillname — Human-Readable Title

[What this skill does, when to use it]

## Invocation

[All command variants with comments]

## What You Must Do When Invoked

[Step-by-step instructions the agent follows]

## Rules

[Hard constraints that always apply]
```

## Style Guide

- **Be precise.** "Grep every caller of the changed function" beats "check for side effects."
- **Be actionable.** Every instruction should tell the agent what to _do_, not what to _think about_.
- **Use concrete examples.** Show the output format. Show the command. Show the file structure.
- **Keep it scannable.** Headers, bullet points, code blocks. Agents parse markdown, not essays.

## Code of Conduct

Be respectful. Be constructive. Be specific. That's it.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
