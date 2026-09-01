---
name: iron-tdd
description: "Test-driven development workflow: write the test first (red), make it pass with minimum code (green), then clean up (refactor). Enforces the cycle and prevents skipping steps."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:tdd — Test-Driven Development

Write the test first. Make it pass. Clean up. Repeat.

This skill enforces the red-green-refactor cycle. It prevents the common failure
mode of writing tests after the code — which tests what you built, not what
you should have built.

## When to Use

- Building any new function, endpoint, or component
- Fixing a bug (write the regression test first)
- Implementing tasks from `/iron:spec apply` (pair with this for test-first)
- When `/iron:review` flags missing test coverage

## Invocation

```
/iron:tdd <what to build>            # Start a TDD cycle for a specific feature
/iron:tdd fix <bug description>      # Bug fix via TDD (regression test first)
/iron:tdd continue                   # Resume where the last cycle left off
```

## What You Must Do When Invoked

### Step 1 — Understand the Requirement

Before writing anything:

1. **Check for ironworks specs.** If `ironworks/changes/` has an active spec with
   requirements, use the scenarios from `requirements.md` as test cases.

2. **If no spec exists,** extract testable requirements from the user's description.
   State them back: "I'll test for these behaviors: [list]. Sound right?"

3. **Identify the test file.** Follow the project's existing pattern:
   - `app/services/auth.py` → `tests/services/test_auth.py`
   - `src/lib/utils.ts` → `src/lib/__tests__/utils.test.ts`
   - If no pattern exists, ask where tests should go.

### Step 2 — RED: Write a Failing Test

Write **one** test that describes the next behavior to implement.

Rules for the test:
- **Test behavior, not implementation.** Assert on outputs and side effects,
  not internal state or method calls.
- **Name it after what it verifies:** `test_login_returns_token_for_valid_credentials`
  not `test_login` or `test_auth_1`.
- **Use the project's test framework.** Don't introduce a new one.
- **The test MUST fail.** If it passes immediately, either the behavior already
  exists (skip it) or the test doesn't assert anything meaningful (rewrite it).

Show the test to the user:

```
🔴 RED — Test written (should fail):
   test_login_returns_token_for_valid_credentials

   Expected: POST /auth/login with valid credentials returns 200 + JWT token
   Currently: Function/endpoint doesn't exist yet

   Running tests to confirm failure...
```

Run the test and confirm it fails. If it passes, explain why and adjust.

### Step 3 — GREEN: Make It Pass

Write the **minimum code** to make the test pass. This means:

- No extra features beyond what the test checks
- No abstractions "for later"
- No handling of edge cases the test doesn't cover yet
- If it can be a one-liner that passes, write the one-liner

The discipline ladder from AGENTS.md applies here:
1. Can you reuse existing code? → Reuse it
2. Does stdlib handle it? → Use stdlib
3. Minimum new code that makes the test green

Run the test. Confirm it passes:

```
🟢 GREEN — Test passes:
   test_login_returns_token_for_valid_credentials ✓

   Implementation: Added login() in services/auth.py (12 lines)
   All existing tests still pass: ✓
```

**Critical:** Verify that ALL existing tests still pass, not just the new one.
If something broke, fix it before moving on.

### Step 4 — REFACTOR: Clean Up

Now — and ONLY now — improve the code without changing behavior:

- Extract duplication
- Improve names
- Simplify conditionals
- Move code to the right layer (if a route has logic, move it to a service)

Rules for refactoring:
- **Tests must stay green.** Run them after every change.
- **Don't add behavior.** Refactoring changes structure, not behavior.
- **Don't skip this step.** The green phase intentionally produces rough code.
  This is where you polish it.

```
🔧 REFACTOR — Cleaned up:
   - Extracted token generation to core/security.py (already had JWT setup)
   - Renamed `check_pw` → `verify_password` for clarity
   All tests still pass: ✓
```

### Step 5 — Next Cycle

After one full cycle (red → green → refactor), ask:

"Cycle complete. Next behavior to test:
1. [Suggested next test based on requirements]
2. [Another suggested test]
3. Or describe what to test next."

Repeat until all requirement scenarios are covered.

### For `/iron:tdd fix <bug>`

Bug-fix TDD follows a specific order:

1. **Reproduce first.** Write a test that demonstrates the bug:
   ```
   🔴 RED — Regression test:
      test_login_rejects_expired_token
      This test reproduces the reported bug: expired tokens are accepted.
   ```

2. **Confirm the test fails** for the right reason (the bug exists).

3. **Fix the bug** with minimum code change.

4. **Confirm the test passes** and no other tests broke.

5. **Do NOT refactor** during a bug fix unless the refactor is the fix.

### For `/iron:tdd continue`

1. Read the most recent test file touched in the project.
2. Look at what's tested and what requirement scenarios remain.
3. Start the next red-green-refactor cycle.

## Integration with Other Skills

- **`/iron:spec apply`** — When applying spec tasks, suggest using TDD for each task.
  The requirement scenarios in `requirements.md` become test cases.
- **`/iron:review`** — The review skill checks Axis 3 (test coverage). TDD ensures
  coverage is built in, not bolted on.

## Rules

- **Never skip red.** A test that passes on first run tests nothing useful.
- **Never skip refactor.** Green code is intentionally rough. Polish it.
- **One test per cycle.** Don't batch tests — each cycle adds one behavior.
- **Run ALL tests, not just the new one.** Regressions hide in green bars.
- **Test the contract, not the wiring.** If a function takes X and returns Y,
  test X→Y. Don't mock everything between them.
- **Name tests like sentences.** `test_<action>_<result>_<condition>` reads as
  documentation when tests fail.
