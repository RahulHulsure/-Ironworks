---
name: iron-spec
description: "Spec-driven feature development: explore, propose, design, implement, verify, update, and archive features. RFC 2119 requirements, GIVEN/WHEN/THEN scenarios, delta-based archiving, and domain context tracking."
homepage: https://github.com/RahulHulsure/-Ironworks
license: MIT
---

# /iron:spec — Spec-Driven Development

Every feature starts as a spec before it becomes code. This skill manages the
full lifecycle: explore → propose → design → implement → verify → update → archive.
Plain Markdown, no special syntax, no tooling dependencies.

## Why

Code without a spec is a guess. A spec forces you to answer "what exactly
should this do?" before you answer "how do I build it?" The archive creates
a searchable history of every decision and why it was made.

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

Domain-specific terms are tracked in `ironworks/CONTEXT.md`. This file captures
the project's vocabulary — terms that have precise meaning in this codebase and
whose synonyms should be rejected for consistency.

Format:

```markdown
# Domain Context

## <Term>
<Definition — 1-2 sentences explaining what this term means in this project.>

_Avoid:_ <comma-separated list of synonyms or near-synonyms to reject>

## <Term>
...
```

Rules for CONTEXT.md:
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

## What You Must Do When Invoked

### For `/iron:spec explore <topic>`

Explore an idea against the current codebase before committing to a proposal.
This is non-committal — it does NOT create a change folder.

1. **Read relevant code.** Identify the files, modules, and patterns related
   to the topic. Understand the current state.

2. **Compare options.** If there are multiple approaches, outline each with
   pros, cons, and rough effort estimates.

3. **Identify risks.** What could go wrong? What existing behavior might break?
   What assumptions does the codebase make that this topic would challenge?

4. **Challenge domain terms.** If the topic uses fuzzy or ambiguous language:
   - Identify terms that mean different things in different parts of the codebase.
   - Propose precise definitions.
   - Suggest which synonym to standardize on and which to reject.

5. **Update CONTEXT.md.** If new domain terms were discovered or clarified,
   add them to `ironworks/CONTEXT.md`. Create the file if it doesn't exist.

6. **Report findings.** Summarize:
   - What the codebase currently does related to this topic
   - What the options are
   - What the risks are
   - Any domain terms that were clarified
   - Whether this is ready for a proposal or needs more investigation

7. **Do NOT create a change folder.** Exploration is non-committal. If the user
   wants to proceed, they should run `/iron:spec propose <name>`.

### For `/iron:spec propose <name>`

1. **Check for ironworks/ directory.** If it doesn't exist, create it:
   ```
   ironworks/
   ├── specs/         # Living requirements (optionally organized by domain)
   ├── changes/       # In-flight proposals
   └── CONTEXT.md     # Domain terms
   ```

2. **Check for duplicate.** If `ironworks/changes/<name>/` already exists, say so and stop.

3. **Read existing specs.** Scan `ironworks/specs/` to understand what requirements
   already exist. The new feature should reference and extend them, not contradict.

4. **Read the codebase.** Before proposing, understand the current state:
   - What files/modules are relevant?
   - What patterns does the codebase already use?
   - What would need to change?

5. **Capture domain terms.** If new domain-specific terms arise during the
   proposal, add them to `ironworks/CONTEXT.md`.

6. **Suggest domain organization.** If the project is large and `ironworks/specs/`
   is flat, suggest organizing specs by domain:
   ```
   ironworks/specs/auth/
   ironworks/specs/payments/
   ironworks/specs/notifications/
   ```

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

Requirements use **RFC 2119 keywords** to indicate obligation level:
- **SHALL / MUST** — hard requirement, non-negotiable
- **SHOULD** — strong recommendation, may be omitted with justification
- **MAY** — optional, nice-to-have

Each requirement is one statement with one keyword. Each requirement must be
observable and testable without reading the implementation code.

Scenarios use explicit **GIVEN/WHEN/THEN** structure. Each scenario must
exercise the specific requirement it belongs to and cover edge cases and
failure modes.

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

#### Scenario: Session timeout does not destroy unsaved data
- GIVEN an authenticated session with unsaved form data
- WHEN the session times out
- THEN the user is prompted to re-authenticate
- AND the unsaved form data is preserved after re-authentication

### Rate Limiting

The system SHOULD limit API requests to 100 per minute per user.

#### Scenario: Rate limit exceeded
- GIVEN a user who has made 100 requests in the last 60 seconds
- WHEN the user makes another request
- THEN the system responds with HTTP 429 and a Retry-After header

### Audit Logging

The system MAY log all authentication events for security review.

#### Scenario: Successful login is logged
- GIVEN audit logging is enabled
- WHEN a user logs in successfully
- THEN an event is recorded with timestamp, user ID, and IP address
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

8. **Present the proposal.** After creating the files, give a concise summary:
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

### For `/iron:spec verify <name>`

Validate that the implementation matches the spec's requirements. This is a
read-only audit — it does not change code or specs.

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

Revise planning artifacts while maintaining coherence. This changes specs,
not code.

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
   - **ADDED** — new behavior not previously in any spec
   - **MODIFIED** — changed behavior; include the full new version of the
     requirement (not a diff)
   - **REMOVED** — discontinued behavior; include a one-line explanation of
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

## Domain Organization

For large projects, specs can be organized by domain:

```
ironworks/specs/
├── auth/
│   ├── session-management.md
│   └── oauth-providers.md
├── payments/
│   ├── billing-cycles.md
│   └── refund-policy.md
└── notifications/
    └── email-templates.md
```

During `propose`, if `ironworks/specs/` contains more than 8 flat files,
suggest domain-based organization. Let the user decide — do not reorganize
without confirmation.

## Rules

- **Specs are the source of truth.** If code contradicts a spec, the code is wrong
  unless the spec was updated first.
- **No implementation without a spec.** If someone asks to build a feature and no
  change proposal exists, create one first.
- **Requirements use RFC 2119 keywords.** Every requirement must contain exactly
  one of: SHALL, MUST, SHOULD, or MAY. No requirement without a keyword.
- **Requirements must be testable.** Every requirement must be observable and
  verifiable without reading the implementation code. Every scenario must use
  GIVEN/WHEN/THEN structure explicitly.
- **Scenarios exercise requirements.** Each scenario must test the specific
  requirement it belongs to, including edge cases and failure modes.
- **Domain terms go in CONTEXT.md.** New terms discovered during explore or
  propose are added immediately. General programming terms are excluded.
- **Archive uses delta markers.** Every requirement merged into living specs
  must be tagged ADDED, MODIFIED, or REMOVED. Existing spec content not
  covered by deltas is preserved untouched.
- **Archive is permanent.** To modify a feature, create a new proposal.
- **Update changes specs, not code.** `/iron:spec update` only touches planning
  documents. Code changes happen through `/iron:spec apply`.
- **One change at a time** is the default. Multiple in-flight changes are allowed
  but the user should be aware of each.
