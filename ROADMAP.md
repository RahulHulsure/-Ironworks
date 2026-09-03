# Ironworks Roadmap

## v1.0.0 — Released

12 skills across 7 layers, 16+ platform adapters.

- [x] 12 core skills (L0-L∞)
- [x] Claude Code plugin (`.openclaw/skills/`)
- [x] 16 platform adapters (Cursor, Copilot, Windsurf, Cline, Codex, Gemini, Aider, Amazon Q, Kiro, Roo, Continue, Junie, Trae, Augment, Kilo, Antigravity)
- [x] Universal install scripts (`install.sh`, `install.ps1`)
- [x] Per-folder READMEs

## v1.1.0 — Planned

- [ ] **MCP server integration** -- expose skills as MCP tools for cross-platform interop
- [ ] **`/iron:test`** -- test runner skill with coverage tracking
- [ ] **`/iron:migrate`** -- database migration management
- [ ] **Interactive mode** -- step-by-step guided workflows
- [ ] **Skill composition** -- chain skills in `.ironworks/workflows.yml`

## v1.2.0 — Exploring

- [ ] **`/iron:perf`** -- performance profiling and optimization
- [ ] **`/iron:docs`** -- generate API docs from code + specs
- [ ] **`/iron:monitor`** -- production monitoring setup
- [ ] **Plugin marketplace submission** -- publish to Claude Code marketplace
- [ ] **VS Code extension** -- sidebar UI for skill invocation
- [ ] **Telemetry dashboard** -- track which skills teams use most

## Contributing

Have an idea? [Open an issue](https://github.com/RahulHulsure/-Ironworks/issues/new?template=feature_request.md) tagged `enhancement` and describe your use case.

## Philosophy

Each skill must:

1. **Solve a real workflow gap** -- not duplicate what exists
2. **Compose with existing layers** -- fit the L0-L∞ architecture
3. **Work across platforms** -- not lock into one AI tool
4. **Be opinionated** -- provide a clear method, not options
