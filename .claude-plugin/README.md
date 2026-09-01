# `.claude-plugin/` — Claude Code Plugin Manifest

This directory contains the plugin manifest files that allow Ironworks to be installed as a native Claude Code plugin.

## Files

| File | Purpose |
|------|---------|
| `plugin.json` | Main plugin manifest — declares the plugin name, version, author, keywords, and UI metadata (display name, description, brand color, default prompts). Claude Code reads this to register the plugin and present it in the interface. |
| `marketplace.json` | Marketplace listing manifest — provides metadata for the Claude Code plugin marketplace, including the plugin source path and category. Used when the plugin is published or discovered via `claude plugin install`. |

## How It Works

When a user runs `claude plugin install ironworks`, Claude Code reads `plugin.json` to register the plugin and `marketplace.json` to resolve the plugin source. The skills in `.openclaw/skills/` are then loaded as slash commands (`/iron:*`).

## Reference

- [Claude Code Plugin Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Plugin JSON Schema](https://anthropic.com/claude-code/marketplace.schema.json)
