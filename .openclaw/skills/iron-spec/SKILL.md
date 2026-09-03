---
name: iron-spec
description: "Spec-driven development lifecycle: explore, propose, design, implement, verify, update, archive."
---

# /iron:spec

## Invocation

```
/iron:spec explore <topic>           # Research an idea before committing to a proposal
/iron:spec propose <name>            # Create a new feature proposal
/iron:spec show                      # View current specs and in-flight changes
/iron:spec show <name>               # View a specific change
/iron:spec apply                     # Implement the current change's tasks
/iron:spec apply <name>              # Implement a specific change
/iron:spec verify <name>             # Validate implementation against the spec
/iron:spec update <name>             # Revise planning artifacts (not code)
/iron:spec archive                   # Seal completed change, update living specs
/iron:spec archive <name>            # Archive a specific change
```

## CONTEXT.md — Domain Terms

Track domain terms in `ironworks/CONTEXT.md`. Precise meanings only; reject synonyms.

Format:

```markdown
# Domain Context

## <Term>
<Definition -- 1-2 sentences explaining what this term means in this project.>

_Avoid:_ <comma-separated list of synonyms or near-synonyms to reject>

## <Term>
...
```

Rules:
- Only project-specific terms belong here. Do not add general programming
  concepts (e.g., "function", "class", "database").
- During `explore` and `propose`, capture any new domain terms discovered.
- Challenge fuzzy terms: if a term is used loosely in the codebase, propose a
  precise definition and list the alternatives to avoid.
- Example:
  ```
  ## Workspace
  A container for a user's projects, billing, and team members. One user can
  belong to multiple workspaces. Each workspace has exactly one owner.

  _Avoid:_ organization, account, tenant, team
  ```

## Procedures

### For `/iron:spec explore <topic>`

1. **Read relevant code.** Identify the files, modules, and patterns related
   to the topic.

2. **Compare options.** If there are multiple approaches, outline each with
   pros, cons, and rough effort estimates.

3. **Identify risks.** What could break? What assumptions does this challenge?

4. **Challenge domain terms.** If the topic uses fuzzy or ambiguous language:
   - Identify terms that mean different things in different parts of the codebase.
   - Propose precise definitions.
   - Suggest which synonym to standardize on and which to reject.

5. **Update CONTEXT.md.** If new domain terms were discovered or clarified,
   add them to `ironworks/CONTEXT.md`. Create the file if it doesn't exist.

6. **Report.** Summarize: current state, options, risks, clarified terms, readiness.

### For `/iron:spec propose <name>`

1. **Ensure ironworks/ directory exists:**
   ```
   ironworks/
   ├── specs/         # Living requirements (optionally organized by domain)
   ├── changes/       # In-flight proposals
   └── CONTEXT.md     # Domain terms
   ```

2. **Check for duplicate.** If `ironworks/changes/<name>/` already exists, say so and stop.

3. **Read existing specs** in `ironworks/specs/`. New feature must extend, not contradict.

4. **Read the codebase.** Identify relevant files, existing patterns, and what must change.

5. **Capture domain terms.** If new domain-specific terms arise during the
   proposal, add them to `ironworks/CONTEXT.md`.

6. **Suggest domain organization.** If `ironworks/specs/` has more than 8 flat files, suggest domain-based subdirectories. Do not reorganize without confirmation.

7. **Create the change directory** with four files:

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
[What's wrong or missing today. Be specific -- name the user, the action, the pain.]

## Solution
[One paragraph: what we're building and why this approach.]

## Scope
- **In scope:** [Bullet list of what this change covers]
- **Out of scope:** [What we're deliberately NOT doing -- and why]

## Dependencies
- [Other features, services, or changes this depends on]
- [Or "None" if standalone]
```

#### requirements.md

**RFC 2119 keywords:**
- **SHALL / MUST** -- hard requirement, non-negotiable
- **SHOULD** -- strong recommendation, may be omitted with justification
- **MAY** -- optional, nice-to-have

One requirement = one statement + one keyword. Must be testable without reading code.
Scenarios: GIVEN/WHEN/THEN. Cover edge cases and failure modes.

```markdown
## Requirements

### Session Timeout

The system SHALL invalidate user sessions after a period of inactivity.

#### Scenario: Session timeout after inactivity
- GIVEN an authenticated session
- WHEN 30 minutes pass with no activity
- THEN the session is invalidated and the user must re-authenticate

#### Scenario: Activity resets the timeout
- GIVEN an authenticated session with 25 minutes of inactivity
- WHEN the user makes an API request
- THEN the inactivity timer resets to zero
```

#### design.md

```markdown
# Technical Design: <Feature Name>

## Approach
[How we'll build it -- which files change, what patterns we'll use, why.]

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
- [ ] 1.1 [Specific task -- names the file and what changes]
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

8. **Present the proposal:**
   - What the feature does (one sentence)
   - How many tasks, split across how many phases
   - Any risks or open questions from the design
   - Ask: "Ready to implement, or want to adjust the spec first?"

### For `/iron:spec show`

1. List all files in `ironworks/specs/` with a one-line summary of each.
2. List all directories in `ironworks/changes/` with their status:
   - Read `tasks.md` and count checked `[x]` vs unchecked `[ ]` tasks.
   - Show: `<name> -- 3/8 tasks done`
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

### For `/iron:spec verify <name>`

Read-only audit. Does not change code or specs.

1. **Read the spec.** Load `requirements.md`, `design.md`, and `tasks.md` from
   `ironworks/changes/<name>/`.

2. **Read the implementation.** Identify every file that was created or modified
   as part of this change.

3. **Check completeness.** For each requirement and scenario in `requirements.md`:
   - Is there code that implements this requirement?
   - Is there a test that covers each scenario?
   - Quote the spec line for each finding.

4. **Check correctness.** For each implemented behavior:
   - Does the behavior match what the scenario describes?
   - Are the GIVEN/WHEN/THEN conditions handled correctly?
   - Quote the spec line for each finding.

5. **Check coherence.** Does the implementation follow `design.md`?
   - Are the right patterns used?
   - Does the data model match?
   - Are the API shapes correct?

6. **Check for scope creep.** Is there code that does things not described in
   any requirement? Flag it.

7. **Report findings.** For each finding, include:
   - Category: MISSING (requirement not implemented), WRONG (behavior differs
     from spec), EXTRA (code not in any requirement), INCOMPLETE (partially
     implemented)
   - The spec line being referenced (quoted)
   - What was found (or not found) in the code
   - Severity: MUST-FIX (blocks completion) or SHOULD-FIX (quality issue)

### For `/iron:spec update <name>`

Revise planning artifacts (specs only, not code).

1. **Read all planning artifacts.** Load `proposal.md`, `requirements.md`,
   `design.md`, and `tasks.md` from `ironworks/changes/<name>/`.

2. **Understand the change.** Ask the user what needs to change, or accept
   their description of the shift.

3. **Update the affected documents:**
   - If requirements changed: update `requirements.md` with new/modified/removed
     requirements. Update scenarios to match.
   - If design changed: update `design.md` to reflect new approach.
   - If scope changed: update `proposal.md` scope section.
   - Always regenerate `tasks.md` to reflect the current state of requirements
     and design. Preserve the checked status of tasks that are still valid.

4. **Maintain coherence.** After updating:
   - Every requirement must still have at least one scenario.
   - Every scenario must still be testable.
   - Tasks must cover all requirements.
   - Design must support all requirements.

5. **Report what changed.** Summarize what was added, modified, or removed
   across the planning artifacts.

6. **Do NOT change code.** If code needs to change, that happens via `/iron:spec apply`.

### For `/iron:spec archive` or `/iron:spec archive <name>`

1. Verify all tasks in `tasks.md` are checked `[x]`. If not, list remaining
   ones and ask: "Archive with incomplete tasks, or finish them first?"

2. **Prepare delta markers.** When merging into living specs, mark each
   requirement with a delta marker:
   - **ADDED** -- new behavior not previously in any spec
   - **MODIFIED** -- changed behavior; include the full new version of the
     requirement (not a diff)
   - **REMOVED** -- discontinued behavior; include a one-line explanation of
     why it was removed

3. **Update living specs.** Merge requirements into `ironworks/specs/`:
   - If a matching spec file exists, apply the deltas:
     - ADDED requirements are appended.
     - MODIFIED requirements replace the old version in full.
     - REMOVED requirements are deleted, with the removal reason noted in a
       comment or changelog section.
     - Preserve existing content not covered by deltas.
   - If no match, create a new spec file.
   - If using domain-based organization, place the spec in the appropriate
     domain directory (e.g., `ironworks/specs/auth/session-management.md`).

4. **Move to archive:**
   ```
   ironworks/changes/<name>/  →  ironworks/archive/YYYY-MM-DD-<name>/
   ```

5. **Report.** Print what was archived, what specs were updated, and what
   delta markers were applied.

## Rules
- Specs are source of truth. Code contradicting a spec is wrong unless spec updated first.
- No implementation without a spec.
- Requirements: one RFC 2119 keyword, testable, GIVEN/WHEN/THEN scenarios.
- Domain terms in CONTEXT.md. General programming terms excluded.
- Archive: delta markers (ADDED/MODIFIED/REMOVED). Existing content preserved. Permanent.
- Update changes specs only. Code changes via `/iron:spec apply`.
- One change at a time by default. Multiple allowed with user awareness.
