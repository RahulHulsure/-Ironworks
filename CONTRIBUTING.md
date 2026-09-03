# Contributing to Ironworks

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

- `.openclaw/skills/` -- all 12 SKILL.md files (one per skill)
- `AGENTS.md` -- L0 always-on discipline rules
- `docs/` -- CLAUDE-GLOBAL.md (drop-in), project template
- `.claude-plugin/` -- plugin manifest and marketplace metadata

## Writing a SKILL.md

Each skill needs frontmatter (`name`, `description`, `homepage`, `license: MIT`) and these sections:

- **Invocation** -- all command variants
- **What You Must Do When Invoked** -- step-by-step agent instructions
- **Rules** -- hard constraints that always apply

See any existing `.openclaw/skills/*/SKILL.md` for a working example.

## Style Guide

- **Be precise.** "Grep every caller of the changed function" beats "check for side effects."
- **Be actionable.** Every instruction should tell the agent what to _do_, not what to _think about_.
- **Use concrete examples.** Show the output format, the command, the file structure.
- **Keep it scannable.** Headers, bullet points, code blocks. Agents parse markdown, not essays.

## Code of Conduct

Be respectful. Be constructive. Be specific. That's it.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
