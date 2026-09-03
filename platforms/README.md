# Platform Compatibility

Ironworks works across 17 AI coding platforms. This document covers how
each integration works, what gets installed, and how to set it up.

---

## Compatibility Matrix

| Platform | Rules (L0) | Full Skills (L1-L∞) | Project Install | Global Install | Auto-Detect |
|---|:---:|:---:|:---:|:---:|:---:|
| **Claude Code** | Yes | Yes | Yes | Yes | `claude --version` |
| **Cursor** | Yes | -- | Yes | Yes | `.cursor/` dir |
| **GitHub Copilot** | Yes | -- | Yes | -- | `.github/` dir |
| **Windsurf** | Yes | -- | Yes | -- | `.windsurf/` dir |
| **Cline** | Yes | -- | Yes | -- | cline config |
| **Gemini CLI** | Yes | -- | Yes | Yes | `gemini --version` |
| **Codex** | Yes | -- | Yes | Yes | `codex --version` |
| **Aider** | Yes | -- | Yes | -- | `aider --version` |
| **Amazon Q** | Yes | -- | Yes | -- | amazonq config |
| **Kiro** | Yes | -- | Yes | -- | `.kiro/` dir |
| **Roo** | Yes | -- | Yes | -- | roo config |
| **Continue** | Yes | -- | Yes | -- | `.continue/` dir |
| **Junie** | Yes | -- | Yes | -- | `.junie/` dir |
| **Trae** | Yes | -- | Yes | -- | `.trae/` dir |
| **Augment** | Yes | -- | Yes | -- | augment config |
| **Kilo** | Yes | -- | Yes | -- | `.kilo/` dir |
| **Antigravity** | Yes | Yes | Yes | Yes | agent config |

**Rules (L0)** = the discipline layer (priority stack, discipline ladder, security
rules) is injected as a rules file the platform reads on every response.

**Full Skills (L1-L∞)** = the complete 12-skill system with slash commands
(`/iron:init`, `/iron:tdd`, etc.) is installed as individual skill directories.
Only platforms whose rules engine supports skill invocation get this.

---

## Quick Install

### Script (recommended)

```bash
# macOS / Linux
./install.sh                          # auto-detect, project scope
./install.sh --platform cursor        # one platform
./install.sh --platform all --global  # all detected, global scope
./install.sh --uninstall              # clean up
```

```powershell
# Windows
.\install.ps1                           # auto-detect, project scope
.\install.ps1 -Platform cursor          # one platform
.\install.ps1 -Platform all -Global     # all detected, global scope
.\install.ps1 -Uninstall                # clean up
```

### Manual Install

Pick your platform below and copy the files yourself.

---

## Per-Platform Instructions

### Claude Code

Claude Code loads skills from `.openclaw/skills/` (project) or `~/.claude/skills/`
(global). Each skill is a directory containing a `SKILL.md` file.

```bash
# Project (full skills)
cp -r .openclaw/skills/ YOUR_PROJECT/.openclaw/skills/

# Global (full skills)
cp -r .openclaw/skills/ ~/.claude/skills/
```

**File format:** Markdown. Each `SKILL.md` defines a slash command the agent
can invoke. Claude Code is the only platform that gets the full 12-skill system.

### Cursor

Cursor reads `.mdc` rule files from `.cursor/rules/` (project) or
`~/.cursor/rules/` (global). The `alwaysApply: true` frontmatter makes the
rules active on every response.

```bash
cp platforms/cursor/rules/ironworks-discipline.mdc YOUR_PROJECT/.cursor/rules/
```

**File format:** Markdown with YAML frontmatter (`.mdc` extension).

### GitHub Copilot

Copilot reads `copilot-instructions.md` from the `.github/` directory.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.github/copilot-instructions.md
```

**File format:** Markdown. No global install -- Copilot instructions are always
per-repository.

### Windsurf

Windsurf reads rule files from `.windsurf/rules/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.windsurf/rules/ironworks.md
```

**File format:** Markdown.

### Cline

Cline reads rules from the `.clinerules/` directory.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.clinerules/ironworks.md
```

**File format:** Markdown.

### Gemini CLI

Gemini reads `GEMINI.md` from the project root or `~/.gemini/GEMINI.md` globally.

```bash
# Project
cp platforms/ironworks-portable.md YOUR_PROJECT/GEMINI.md

# Global
cp platforms/ironworks-portable.md ~/.gemini/GEMINI.md
```

**File format:** Markdown.

### Codex (OpenAI)

Codex reads `AGENTS.md` from the project root or `~/.codex/AGENTS.md` globally.

```bash
# Project
cp platforms/ironworks-portable.md YOUR_PROJECT/AGENTS.md

# Global
cp platforms/ironworks-portable.md ~/.codex/AGENTS.md
```

**File format:** Markdown.

### Aider

Aider reads `CONVENTIONS.md` from the project root.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/CONVENTIONS.md
```

**File format:** Markdown. No global install supported.

### Amazon Q

Amazon Q reads rules from `.amazonq/rules/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.amazonq/rules/ironworks.md
```

**File format:** Markdown.

### Kiro

Kiro reads steering files from `.kiro/steering/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.kiro/steering/ironworks.md
```

**File format:** Markdown.

### Roo

Roo reads rules from `.roo/rules/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.roo/rules/ironworks.md
```

**File format:** Markdown.

### Continue

Continue reads a `.continuerules` file from the project root.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.continuerules
```

**File format:** Markdown (no extension).

### Junie

Junie reads `guidelines.md` from the `.junie/` directory.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.junie/guidelines.md
```

**File format:** Markdown.

### Trae

Trae reads rule files from `.trae/rules/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.trae/rules/ironworks.md
```

**File format:** Markdown.

### Augment

Augment reads an `.augment-guidelines` file from the project root.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.augment-guidelines
```

**File format:** Markdown (no extension).

### Kilo

Kilo reads rule files from `.kilo/rules/`.

```bash
cp platforms/ironworks-portable.md YOUR_PROJECT/.kilo/rules/ironworks.md
```

**File format:** Markdown.

### Antigravity

Antigravity reads skills from `.agent/skills/` (project) or
`~/.gemini/antigravity/skills/` (global). Supports full skill directories.

```bash
# Project (full skills)
cp -r .openclaw/skills/ YOUR_PROJECT/.agent/skills/

# Global (full skills)
cp -r .openclaw/skills/ ~/.gemini/antigravity/skills/
```

**File format:** Markdown skill directories.

---

## How It Works

Ironworks uses a two-tier adapter approach:

### Tier 1 — Full Skills (Claude Code, Antigravity)

Platforms that support a skill/command invocation model get the complete
12-skill system. Each skill is a directory with a `SKILL.md` that defines
a slash command (e.g., `/iron:tdd`). The agent can invoke any skill by name.

```
.openclaw/skills/
  iron-init/SKILL.md      # /iron:init — project bootstrap
  iron-graph/SKILL.md     # /iron:graph — dependency map
  iron-spec/SKILL.md      # /iron:spec — spec-driven dev
  iron-tdd/SKILL.md       # /iron:tdd — test-driven dev
  iron-debug/SKILL.md     # /iron:debug — structured debugging
  iron-arch/SKILL.md      # /iron:arch — architecture analysis
  iron-review/SKILL.md    # /iron:review — code review
  iron-audit/SKILL.md     # /iron:audit — simplification audit
  iron-preflight/SKILL.md # /iron:preflight — deploy preflight
  iron-deploy/SKILL.md    # /iron:deploy — deployment config
  iron-handoff/SKILL.md   # /iron:handoff — session handoff
  iron-help/SKILL.md      # /iron:help — command reference
```

### Tier 2 — Portable Rules (all other platforms)

Platforms that support only a rules/instructions file get the **portable rules
document** (`platforms/ironworks-portable.md`). This contains the full L0
discipline layer -- the priority stack, discipline ladder, security rules, code
standards and scalability defaults -- condensed into a single file the platform
injects into every response.

Platform-specific adapters (e.g., Cursor's `.mdc` format) are stored in
`platforms/<name>/` when the platform needs a custom file format.

### Adding a New Platform

1. If the platform reads plain Markdown rules: just copy `ironworks-portable.md`
   to the location the platform expects.
2. If the platform needs a custom format: create `platforms/<name>/` with the
   adapted file and add the platform to the install scripts.

---

## File Format Reference

| Format | Extension | Platforms | Notes |
|---|---|---|---|
| Markdown | `.md` | Most platforms | Plain Markdown, no frontmatter |
| MDC | `.mdc` | Cursor | Markdown + YAML frontmatter (`alwaysApply: true`) |
| Skill dir | `SKILL.md` | Claude Code, Antigravity | Directory per skill with a `SKILL.md` inside |
| No extension | (none) | Continue, Augment | Markdown content, platform-specific filename |

---

## Troubleshooting

**Rules not loading?** Check that the file is in the exact path the platform
expects. Most platforms are case-sensitive about filenames.

**Conflicts with existing rules?** The Ironworks rules are additive. They do
not override platform defaults -- they extend them. If you have existing rules,
the Ironworks file can coexist alongside them.

**Uninstalling:** Run `./install.sh --uninstall` (or `.\install.ps1 -Uninstall`)
to remove all installed files. The scripts only remove files they created.
