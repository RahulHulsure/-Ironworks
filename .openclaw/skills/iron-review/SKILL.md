---
name: iron-review
description: "Smart code review: checks changes against specs, enforces the discipline ladder (YAGNI/stdlib-first), validates tests exist for new behavior, and catches security basics. Not just style — substance."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:review — Smart Code Review

A code review that checks what actually matters: does the code match the spec?
Is it the simplest solution? Are there tests? Are the security basics covered?

This is not a linter. It catches the problems linters can't: wrong behavior,
unnecessary complexity, missing tests, spec drift.

## Invocation

```
/iron:review                         # Review uncommitted changes (git diff)
/iron:review --staged                # Review staged changes only
/iron:review --branch <branch>       # Review changes vs main/master
/iron:review --file <path>           # Review a specific file
/iron:review --spec <name>           # Review against a specific ironworks spec
/iron:review --fix                   # Review + auto-fix blockers
```

## What You Must Do When Invoked

### Step 1 — Gather the Diff

- **No flags:** `git diff` (unstaged) + `git diff --staged` (staged)
- **`--staged`:** `git diff --staged` only
- **`--branch`:** `git diff main...<branch>` (or master)
- **`--file`:** Read the full file and review holistically

If the diff is empty, say so and stop.

### Step 2 — Load Context

Before reviewing, read:

1. **CLAUDE.md** — project conventions and rules
2. **ironworks/specs/** — current requirements (if exists)
3. **ironworks/changes/** — any in-flight change that relates to the diff
4. **The full files being changed** — you need surrounding context

### Step 3 — Review on Four Axes

Each finding is one of:
- 🔴 **Block** — must fix before merge
- 🟡 **Concern** — should fix, judgment call
- 🟢 **Note** — optional improvement

#### Axis 1: Spec Compliance

If ironworks specs exist and the change relates to a spec:
- Does the code implement what the spec requires?
- Are all requirement scenarios from `requirements.md` covered?
- Does the code do anything explicitly out of scope?
- Does the code contradict any existing spec?

If no specs exist, skip this axis silently.

#### Axis 2: Discipline Ladder

For each piece of new code, check:
1. **Does this need to exist?** — dead code, unused imports, speculative features
2. **Already in the codebase?** — reimplementing an existing util or helper
3. **Stdlib does it?** — custom code for something the standard library handles
4. **Platform feature?** — ignoring a framework feature (hand-rolling auth when middleware exists)
5. **Already-installed dep?** — adding a new dependency for what an existing one handles
6. **Over-built?** — could be simpler, fewer files, fewer abstractions

#### Axis 3: Test Coverage

- New behavior must have tests. Flag missing tests.
- Bug fixes must have regression tests.
- Tests must test behavior, not implementation.
- Don't demand tests for: config changes, docs, type-only changes, trivial one-liners.

#### Axis 4: Security Basics

Check for these specific patterns:
- [ ] SQL injection — string concatenation in queries
- [ ] Secrets in code — hardcoded API keys, passwords, tokens
- [ ] Missing auth — new endpoints without authentication
- [ ] Unvalidated input — user input in file paths, shell commands, queries
- [ ] Overly permissive CORS — `Allow-Origin: *` in production
- [ ] Error exposure — stack traces or internal paths in responses
- [ ] Missing rate limiting — public endpoints without throttling

Only flag what you can see in the diff. Don't speculate.

### Step 4 — Deliver the Verdict

```
## Review: [files changed summary]

### 🔴 Blocking (N)

**[File:Line] — [One-sentence finding]**
[Why it's wrong. What to do instead. Be specific.]

### 🟡 Concerns (N)

**[File:Line] — [One-sentence finding]**
[Why it matters. Suggested fix.]

### 🟢 Notes (N)

**[File:Line] — [One-sentence finding]**
[Optional improvement.]

---

**Verdict:** [SHIP IT ✓ | FIX AND RESHIP | RETHINK]
```

- **SHIP IT:** No blockers, concerns are minor.
- **FIX AND RESHIP:** Has blockers that need fixing. List them.
- **RETHINK:** Fundamental issue — wrong approach, spec mismatch, missing design.

### Step 5 — Offer to Fix

If there are blockers: "Want me to fix the blocking issues?"
If agreed, fix each blocker, then re-run the review on the updated diff.

## Rules

- **Be specific.** "This 40-line validator can be replaced with `pydantic.field_validator`" is useful. "This could be simpler" is not.
- **Name the line.** Every finding references file:line.
- **Don't nitpick style.** Trust the linter for formatting.
- **Praise good work.** If the code is clean and tested, say "SHIP IT" and mean it.
- **One finding per issue.** Don't repeat the same concern across files.
- **Spec is king.** If code works but doesn't match the spec, it's wrong.
