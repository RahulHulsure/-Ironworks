---
name: iron-review
description: "Smart code review on 2 parallel axes — Standards (discipline ladder + Fowler smells + security) and Spec (requirements + test coverage). Catches over-engineering, spec drift, missing tests, and security basics. Not just style — substance."
homepage: https://github.com/RahulHulsure/-Ironworks
license: MIT
---

# /iron:review — Smart Code Review

A code review on two parallel axes: **Standards** (is the code well-built?) and
**Spec** (does it build the right thing?). The axes run independently — a change
can pass Standards but fail Spec (correct code, wrong feature) or pass Spec but
fail Standards (right feature, bad code). Reporting them separately prevents one
from masking the other.

This is not a linter. It catches the problems linters can't: wrong behavior,
unnecessary complexity, missing tests, spec drift, security holes.

## Invocation

```
/iron:review                         # Review uncommitted changes (git diff)
/iron:review --staged                # Review staged changes only
/iron:review --branch <branch>       # Review changes vs main/master
/iron:review --file <path>           # Review a specific file
/iron:review --spec <name>           # Review against a specific ironworks spec
/iron:review --fix                   # Review + auto-fix blockers
/iron:review --over-engineering      # Over-engineering scan only (see below)
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

1. **CLAUDE.md / CONTRIBUTING.md / CODING_STANDARDS.md** — repo-specific coding
   standards. These always override the Fowler smell baseline below.
2. **ironworks/specs/** — current requirements (if exists)
3. **ironworks/changes/** — any in-flight change that relates to the diff
4. **The full files being changed** — you need surrounding context

### Step 3 — Review on Two Parallel Axes

Examine both axes independently. Never merge or rerank findings across axes.

Each finding is one of:
- 🔴 **Block** — must fix before merge
- 🟡 **Concern** — should fix, judgment call
- 🟢 **Note** — optional improvement

---

#### Axis 1: Standards (discipline + code quality + security)

This axis combines the discipline ladder, Fowler smell baseline, and security
basics into one coherent quality check.

##### Fowler Smell Baseline

Apply these 12 smells from Refactoring ch. 3 to every codebase. Each is a
labeled heuristic, never a hard violation — judge by impact and context.
Repo-specific standards from CLAUDE.md, CONTRIBUTING.md, or CODING_STANDARDS.md
always override these defaults.

1. **Mysterious Name** — unclear variable, function, or class names
2. **Duplicated Code** — same structure in more than one place
3. **Feature Envy** — a method that uses another object's data more than its own
4. **Data Clumps** — groups of values that travel together but aren't an object
5. **Primitive Obsession** — using primitives instead of small domain objects
6. **Repeated Switches** — the same switch/case or if/else chain in multiple places
7. **Shotgun Surgery** — one change requires editing many unrelated classes
8. **Divergent Change** — one class is changed for many different reasons
9. **Speculative Generality** — hooks, parameters, or abstractions nobody uses yet
10. **Message Chains** — long chains of `a.b().c().d()` calls
11. **Middle Man** — a class that delegates almost everything to another class
12. **Refused Bequest** — a subclass that ignores or overrides most of its parent

##### Discipline Ladder

For each piece of new code, check in order:
1. **Does this need to exist?** — dead code, unused imports, speculative features
2. **Already in the codebase?** — reimplementing an existing util or helper
3. **Stdlib does it?** — custom code for something the standard library handles
4. **Platform feature?** — ignoring a framework feature (hand-rolling auth when middleware exists)
5. **Already-installed dep?** — adding a new dependency for what an existing one handles
6. **Over-built?** — could be simpler, fewer files, fewer abstractions

##### Security Basics

Check for these specific patterns:
- [ ] SQL injection — string concatenation in queries
- [ ] Secrets in code — hardcoded API keys, passwords, tokens
- [ ] Missing auth — new endpoints without authentication
- [ ] Unvalidated input — user input in file paths, shell commands, queries
- [ ] Overly permissive CORS — `Allow-Origin: *` in production
- [ ] Error exposure — stack traces or internal paths in responses
- [ ] Missing rate limiting — public endpoints without throttling

Only flag what you can see in the diff. Don't speculate.

##### Over-Engineering Tags

Tag each Standards finding with one of these when applicable:
- `delete:` — dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` — hand-rolled thing the standard library ships. Name the function.
- `native:` — dependency or code doing what the platform already does. Name the feature.
- `yagni:` — abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` — same logic, fewer lines. Show the shorter form.

---

#### Axis 2: Spec (requirements compliance + test coverage)

This axis checks whether the code builds the right thing and proves it with
tests.

##### Requirements Compliance

If ironworks specs exist and the change relates to a spec:
- Does the code implement what the spec requires? All scenarios covered?
- Does the code do anything explicitly out of scope (scope creep)?
- Does the code contradict any existing spec?
- Quote the spec line for each finding.

If no specs exist, skip the requirements check silently.

##### Test Coverage

- New behavior must have tests. Flag missing tests.
- Bug fixes must have regression tests.
- Tests must test at pre-agreed seams, not internals — test the contract, not the wiring.
- **Exemptions:** config changes, docs, type-only changes, trivial one-liners.

---

### Step 4 — Deliver the Verdict

Findings are grouped under their axis heading. Never merge or rerank across axes.

```
## Review: [files changed summary]

## Standards

### 🔴 Blocking (N)

`stdlib:` **src/utils/hash.py:42** — Hand-rolled SHA-256 digest; use `hashlib.sha256()`.
Fix: Replace the function body with `return hashlib.sha256(data).hexdigest()`.

### 🟡 Concerns (N)

`yagni:` **src/services/cache.py:18** — CacheStrategy interface with one implementation.
Fix: Inline `RedisCacheStrategy` methods into the service; delete the interface.

### 🟢 Notes (N)

**src/models/user.py:7** — Mysterious Name: `d` should be `created_date`.
Fix: Rename `d` to `created_date` across this file.

## Spec

### 🔴 Blocking (N)

**src/api/orders.py:55** — Spec requires discount validation before total calculation
(requirements.md line 23: "Discounts MUST be validated before applying to subtotal").
Fix: Move `validate_discount()` call before `calculate_total()`.

### 🟡 Concerns (N)

**src/api/orders.py:80** — No test for the bulk-order discount path.
Fix: Add a test case for orders with quantity > 100.

### 🟢 Notes (N)

**src/api/orders.py:92** — Scope creep: gift-wrap option not in any spec.
Fix: Remove or open a new spec proposal for gift-wrap.

---

**Verdict:** [SHIP IT ✓ | FIX AND RESHIP | RETHINK]
```

- **SHIP IT ✓:** No blockers, concerns are minor.
- **FIX AND RESHIP:** Has blockers that need fixing. List them.
- **RETHINK:** Fundamental issue — wrong approach, spec mismatch, missing design.

### Step 5 — Offer to Fix

If there are blockers: "Want me to fix the blocking issues?"
If agreed, fix each blocker, then re-run the review on the updated diff.

---

## `/iron:review --over-engineering`

When invoked with `--over-engineering`, run an over-engineering-only scan.
Skip Spec (Axis 2) entirely. Focus only on the Standards axis, specifically
the discipline ladder and Fowler smell checks that relate to unnecessary
complexity.

### Output Format

One line per finding, tagged. No severity icons, no grouping, no elaboration.

```
delete: src/utils/plugin_loader.py:1-120 — plugin system with zero plugins
stdlib: src/utils/hash.py:42 — hand-rolled SHA-256; use hashlib.sha256()
native: src/auth/session.py:15 — hand-rolled session management; use framework middleware
yagni: src/services/cache.py:18 — CacheStrategy interface, one implementation
shrink: src/api/orders.py:30-45 — 15-line validation loop → 3-line list comprehension
```

End with one of:

```
net: -N lines possible.
```

or:

```
Lean already. Ship.
```

---

## Rules

- **Be specific.** "This 40-line validator can be replaced with `pydantic.field_validator`" is useful. "This could be simpler" is not.
- **Name the line.** Every finding references file:line.
- **Tag the finding.** Every Standards finding gets a tag when one applies.
- **Don't nitpick style.** Trust the linter for formatting.
- **Praise good work.** If the code is clean and tested, say "SHIP IT ✓" and mean it.
- **One finding per issue.** Don't repeat the same concern across files.
- **Spec is king.** If code works but doesn't match the spec, it's wrong.
- **Repo standards override smells.** If CLAUDE.md or CONTRIBUTING.md endorses a pattern that a Fowler smell would flag, the repo standard wins.
- **Axes stay separate.** Never merge Standards and Spec findings into a single ranked list. A reader must be able to see each axis independently.
