# Ironworks Roadmap

> Where we're going and what's next.

## v1.0.0 — Released ✅

The foundation. 12 skills across 7 layers, 16+ platform adapters.

- [x] 12 core skills (L0–L∞)
- [x] Claude Code plugin (`.openclaw/skills/`)
- [x] 16 platform adapters (Cursor, Copilot, Windsurf, Cline, Codex, Gemini, Aider, Amazon Q, Kiro, Roo, Continue, Junie, Trae, Augment, Kilo, Antigravity)
- [x] Universal install scripts (`install.sh`, `install.ps1`)
- [x] SEO-optimized repo with per-folder READMEs

## v1.1.0 — Planned

Refinements based on community feedback.

- [ ] **MCP server integration** — expose skills as MCP tools for cross-platform interop
- [ ] **`/iron:test`** — dedicated test runner skill with coverage tracking
- [ ] **`/iron:migrate`** — database migration management skill
- [ ] **Interactive mode** — step-by-step guided workflows for beginners
- [ ] **Skill composition** — chain skills in `.ironworks/workflows.yml`

## v1.2.0 — Exploring

Ideas under consideration.

- [ ] **`/iron:perf`** — performance profiling and optimization skill
- [ ] **`/iron:docs`** — auto-generate API docs from code + specs
- [ ] **`/iron:monitor`** — production monitoring setup skill
- [ ] **Plugin marketplace submission** — publish to Claude Code marketplace
- [ ] **VS Code extension** — sidebar UI for skill invocation
- [ ] **Telemetry dashboard** — track which skills teams use most

## Contributing

Have an idea? [Open an issue](https://github.com/RahulHulsure/-Ironworks/issues/new?template=feature_request.md) tagged `enhancement`. The best features come from real workflows — tell us your use case.

## Philosophy

We add skills only when they earn their place. Each skill must:

1. **Solve a real workflow gap** — not duplicate what exists
2. **Compose with existing layers** — fit the L0–L∞ architecture
3. **Work across platforms** — not lock into one AI tool
4. **Be opinionated** — provide a clear method, not options
