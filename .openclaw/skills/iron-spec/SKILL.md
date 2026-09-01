---
name: iron-spec
description: "Spec-driven feature development: propose a feature with requirements and design, implement against the spec, archive when done. Plain Markdown, no special syntax."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:spec — Spec-Driven Development

Every feature starts as a spec before it becomes code. This skill manages the
full lifecycle: propose → design → implement → archive. Plain Markdown, no
special syntax, no tooling dependencies.

## Why

Code without a spec is a guess. A spec forces you to answer "what exactly
should this do?" before you answer "how do I build it?" The archive creates
a searchable history of every decision and why it was made.

## Invocation

```
/iron:spec propose <name>            # Create a new feature proposal
/iron:spec show                      # View current specs and in-flight changes
/iron:spec show <name>               # View a specific change
/iron:spec apply                     # Implement the current change's tasks
/iron:spec apply <name>              # Implement a specific change
/iron:spec archive                   # Seal completed change, update living specs
/iron:spec archive <name>            # Archive a specific change
```

## What You Must Do When Invoked

### For `/iron:spec propose <name>`

1. **Check for ironworks/ directory.** If it doesn't exist, create it:
   ```
   ironworks/
   ├── specs/         # Living requirements
   └── changes/       # In-flight proposals
   ```

2. **Check for duplicate.** If `ironworks/changes/<name>/` already exists, say so and stop.

3. **Read existing specs.** Scan `ironworks/specs/` to understand what requirements
   already exist. The new feature should reference and extend them, not contradict.

4. **Read the codebase.** Before proposing, understand the current state:
   - What files/modules are relevant?
   - What patterns does the codebase already use?
   - What would need to change?

5. **Create the change directory** with four files:

```
ironworks/changes/<name>/
├── proposal.md       # Why we're doing this
├── requirements.md   # What it must do (testable scenarios)
├── design.md         # How we'll build it
└── tasks.md          # Implementation checklist
```

#### proposal.md

```markdown
# <Feature Name>

## Problem
[What's wrong or missing today. Be specific — name the user, the action, the pain.]

## Solution
[One paragraph: what we're building and why this approach.]

## Scope
- **In scope:** [Bullet list of what this change covers]
- **Out of scope:** [What we're deliberately NOT doing — and why]

## Dependencies
- [Other features, services, or changes this depends on]
- [Or "None" if standalone]
```

#### requirements.md

Requirements use plain Markdown with testable scenarios. No special syntax.
Each requirement has at least one scenario that can be verified.

```markdown
## Requirements

### [Requirement Name]
[What the system must do — one clear statement.]

**Scenario: [Happy path]**
- GIVEN [initial state]
- WHEN [action]
- THEN [expected result]

**Scenario: [Edge case or error path]**
- GIVEN [initial state]
- WHEN [action]
- THEN [expected result]
```

Write requirements from the user's perspective. Name specific inputs and
outputs. If a requirement can't be verified, it's not a requirement — it's
a wish. Rewrite it until it's testable.

#### design.md

```markdown
# Technical Design: <Feature Name>

## Approach
[How we'll build it — which files change, what patterns we'll use, why.]

## Data Model
[New or changed tables/schemas/types. Include field names, types, constraints.]

## API Changes
[New or changed endpoints. Method, path, request body, response shape.]

## Migration Plan
[If changing existing data: how to migrate safely. Reversible? Backfill needed?]

## Risks
[What could go wrong. Each risk gets a mitigation or acceptance note.]
```

#### tasks.md

An ordered checklist. Each task is small enough to implement in one pass.
Tasks must be ordered so that each one builds on the previous.

```markdown
# Tasks: <Feature Name>

## Phase 1: Foundation
- [ ] 1.1 [Specific task — names the file and what changes]
- [ ] 1.2 [Next task]

## Phase 2: Core Logic
- [ ] 2.1 [Task]
- [ ] 2.2 [Task]

## Phase 3: Integration
- [ ] 3.1 [Wire up to API / UI]
- [ ] 3.2 [Add tests for each requirement scenario]

## Phase 4: Polish
- [ ] 4.1 [Error handling and edge cases]
- [ ] 4.2 [Update CLAUDE.md if project structure changed]
```

6. **Present the proposal.** After creating the files, give a concise summary:
   - What the feature does (one sentence)
   - How many tasks, split across how many phases
   - Any risks or open questions from the design
   - Ask: "Ready to implement, or want to adjust the spec first?"

### For `/iron:spec show`

1. List all files in `ironworks/specs/` with a one-line summary of each.
2. List all directories in `ironworks/changes/` with their status:
   - Read `tasks.md` and count checked `[x]` vs unchecked `[ ]` tasks.
   - Show: `<name> — 3/8 tasks done`
3. If a specific `<name>` is given, print the full proposal, requirements summary,
   and task progress.

### For `/iron:spec apply` or `/iron:spec apply <name>`

1. If no `<name>`, find the only in-flight change. If multiple, list them and ask.

2. Read `tasks.md`. Find the first unchecked `[ ]` task.

3. Read `requirements.md` and `design.md` for context.

4. **Implement the task.** Write the code following the design. After implementing:
   - Check the task off: `[ ]` → `[x]`
   - Run tests if they exist
   - Report what was done

5. **Ask to continue.** "Task 2.1 done. Continue to 2.2, or stop here?"

6. **After each task,** validate that the implementation matches the requirement
   scenarios. If a scenario isn't covered, flag it.

### For `/iron:spec archive` or `/iron:spec archive <name>`

1. Verify all tasks in `tasks.md` are checked `[x]`. If not, list remaining
   ones and ask: "Archive with incomplete tasks, or finish them first?"

2. **Update living specs.** Merge requirements into `ironworks/specs/`:
   - If a matching spec file exists, append or update.
   - If no match, create one.

3. **Move to archive:**
   ```
   ironworks/changes/<name>/  →  ironworks/archive/YYYY-MM-DD-<name>/
   ```

4. **Report.** Print what was archived and what specs were updated.

## Rules

- **Specs are the source of truth.** If code contradicts a spec, the code is wrong
  unless the spec was updated first.
- **No implementation without a spec.** If someone asks to build a feature and no
  change proposal exists, create one first.
- **Requirements must be testable.** Every scenario must be expressible as a test.
- **Archive is permanent.** To modify a feature, create a new proposal.
- **One change at a time** is the default. Multiple in-flight changes are allowed
  but the user should be aware of each.
