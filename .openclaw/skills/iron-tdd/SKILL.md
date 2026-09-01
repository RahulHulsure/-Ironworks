---
name: iron-tdd
description: "Test-driven development workflow: write the test first (red), make it pass with minimum code (green), then clean up (refactor). Enforces the cycle, seam-based testing, and prevents skipping steps."
homepage: https://github.com/RahulHulsure/-Ironworks
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

## Seams

A **seam** is the public boundary you test at. The term comes from Michael
Feathers' *Working Effectively with Legacy Code*: a seam is a place where you
can alter behavior without editing in that place.

### Rules for Seams

- **Tests live at seams, never against internals.** If you are testing a private
  method or reaching past a module's public API, you are at the wrong boundary.
- **Before writing any test, identify the seam under test and confirm it with
  the user.** State it explicitly: "The seam under test is `AuthService.login()`"
  or "The seam is `POST /api/auth/login`."
- **No test at an unconfirmed seam.** If you cannot name the seam, you are not
  ready to write the test.
- **One adapter = hypothetical seam; two adapters = real seam.** A seam becomes
  real when at least two concrete adapters satisfy the interface. Until then,
  the seam is hypothetical — worth noting, not worth over-engineering.

### Examples

```
SEAM IDENTIFICATION:
  Module: PaymentService
  Public interface: processPayment(order: Order): Receipt
  Adapters: StripeAdapter, TestAdapter → real seam ✓
  Tests target: processPayment() — never the adapter internals

  Module: StringUtils.slugify
  Public interface: slugify(input: string): string
  Adapters: only one implementation → hypothetical seam
  Tests target: slugify() input/output behavior
```

## What You Must Do When Invoked

### Step 1 — Understand the Requirement

Before writing anything:

1. **Check for ironworks specs.** If `ironworks/changes/` has an active spec with
   requirements, use the scenarios from `requirements.md` as test cases.

2. **If no spec exists,** extract testable requirements from the user's description.
   State them back: "I'll test for these behaviors: [list]. Sound right?"

3. **Identify the seam under test.** Name the public boundary explicitly. Confirm
   with the user before proceeding.

4. **Identify the test file.** Follow the project's existing pattern:
   - `app/services/auth.py` → `tests/services/test_auth.py`
   - `src/lib/utils.ts` → `src/lib/__tests__/utils.test.ts`
   - If no pattern exists, ask where tests should go.

### Step 2 — RED: Write a Failing Test

Write **one** test that describes the next behavior to implement.

Work in **vertical slices**: one test, then its implementation. Never batch all
tests first and implement later (see Anti-Patterns below).

Rules for the test:
- **Test behavior at the seam, not implementation.** Assert on outputs and side
  effects at the public boundary, not internal state or method calls.
- **Name it after what it verifies:** `test_login_returns_token_for_valid_credentials`
  not `test_login` or `test_auth_1`.
- **Use the project's test framework.** Don't introduce a new one.
- **The test MUST fail.** If it passes immediately, either the behavior already
  exists (skip it) or the test doesn't assert anything meaningful (rewrite it).
- **Expected values must come from an independent source of truth.** Never
  recompute the expected value the way the code does (see Anti-Patterns).

Show the test to the user:

```
🔴 RED — Test written (should fail):
   Seam: AuthService.login()
   Test: test_login_returns_token_for_valid_credentials

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
- **Don't add behavior.** Refactoring changes structure, not behavior. If you
  are tempted to handle a new edge case during refactor, STOP — that is a new
  red-green cycle.
- **Don't skip this step.** The green phase intentionally produces rough code.
  This is where you polish it.
- **"Replace, don't layer."** When deep interface tests exist at the real seam,
  delete old shallow tests that tested the same behavior at a lower level. Do
  not accumulate redundant test layers.

```
🔧 REFACTOR — Cleaned up:
   - Extracted token generation to core/security.py (already had JWT setup)
   - Renamed `check_pw` → `verify_password` for clarity
   - Deleted test_check_pw_hash (shallow test replaced by seam-level test)
   All tests still pass: ✓
```

### Step 5 — Next Cycle (Vertical Slice)

After one full cycle (red → green → refactor), ask:

"Cycle complete. Next behavior to test:
1. [Suggested next test based on requirements]
2. [Another suggested test]
3. Or describe what to test next."

Repeat until all requirement scenarios are covered. Each cycle is one vertical
slice: one test, one implementation, one cleanup pass.

### For `/iron:tdd fix <bug>`

Bug-fix TDD follows a specific order:

1. **Reproduce first.** Write a test that demonstrates the bug:
   ```
   🔴 RED — Regression test:
      Seam: AuthService.login()
      Test: test_login_rejects_expired_token
      This test reproduces the reported bug: expired tokens are accepted.
   ```

2. **Confirm the test fails** for the right reason (the bug exists).

3. **Fix the bug** with minimum code change.

4. **Confirm the test passes** and no other tests broke.

5. **Do NOT refactor** during a bug fix unless the refactor is the fix.

### For `/iron:tdd continue`

1. Read the most recent test file touched in the project.
2. Look at what's tested and what requirement scenarios remain.
3. Identify the seam under test and confirm.
4. Start the next red-green-refactor cycle.

## Mocking Rules

Mocking is the most abused testing technique. Follow these rules strictly:

### Mock ONLY at System Boundaries

Mock these:
- **External APIs** — third-party HTTP services your code calls
- **Databases** — or use a test-specific instance/transaction rollback
- **Time and randomness** — `Date.now()`, `Math.random()`, UUIDs
- **File system I/O** — when tests need isolation from real files
- **Environment** — env vars, OS-level state

### Never Mock Your Own Code

Never mock your own classes, modules, or functions. If you need to mock an
internal collaborator to test something, that is a signal the test is at the
wrong seam.

```
# WRONG — mocking your own module
def test_login():
    with mock.patch("services.auth.hash_password"):  # ← own code
        ...

# RIGHT — testing at the seam, mocking the boundary
def test_login():
    with mock.patch("services.auth.db.get_user"):    # ← database boundary
        ...
```

### Use Dependency Injection to Make Seams Testable

If a module is hard to test without mocking internals, inject the dependency:

```python
# Hard to test (hidden dependency)
class PaymentService:
    def charge(self, order):
        stripe.Charge.create(...)   # Can't swap this out

# Easy to test (injected dependency = seam)
class PaymentService:
    def __init__(self, payment_gateway):
        self.gateway = payment_gateway

    def charge(self, order):
        self.gateway.charge(...)    # Test adapter or real adapter
```

### Prefer SDK-Style Interfaces over Generic Fetchers

When wrapping an external API, create a typed client with domain methods, not a
generic HTTP wrapper. The typed client is the seam.

```typescript
// WRONG — generic fetcher (leaks HTTP details into tests)
const result = await fetch("/api/payments", { method: "POST", body: ... });

// RIGHT — SDK-style client (clean seam)
const result = await paymentClient.charge(order);
```

## Anti-Patterns

These patterns look like TDD but undermine its value. Watch for them.

### Implementation-Coupled Tests

**What it looks like:** Tests mock internal collaborators, assert on private
method calls, or verify the order of internal operations.

**The tell:** Test breaks on refactor when behavior hasn't changed. You renamed
a private helper, or changed the internal call order, and tests fail even though
the public output is identical.

**Fix:** Test at the seam. Assert on the public contract (inputs → outputs +
side effects). If you cannot test a behavior without reaching into internals,
the seam is wrong — push the test boundary outward.

### Tautological Tests

**What it looks like:** The assertion recomputes the expected value the same way
the code does.

```javascript
// TAUTOLOGICAL — expected value recomputes what the code does
test("adds correctly", () => {
  const a = 3, b = 4;
  expect(add(a, b)).toBe(a + b);   // ← expected value is a + b, same as implementation
});

// CORRECT — expected value is an independent literal
test("adds correctly", () => {
  expect(add(3, 4)).toBe(7);        // ← 7 is the independent source of truth
});
```

**The tell:** The expected value uses the same formula, variables, or helper
functions as the code under test. If the code has a bug, the test has the same
bug.

**Fix:** Expected values must come from an independent source of truth: a
literal, a fixture, a reference implementation, or a domain expert's answer.

### Horizontal Slicing

**What it looks like:** Writing all tests first (the entire test suite), then
implementing all the code to make them pass.

**The tell:** You have 8 failing tests and you are trying to make them all pass
at once. You lose the tight feedback loop that makes TDD work.

**Fix:** Work in vertical slices. One test → one implementation → one refactor.
Then the next test. Each slice confirms you are still on track before adding
the next behavior.

## Integration with Other Skills

- **`/iron:spec apply`** — When applying spec tasks, suggest using TDD for each task.
  The requirement scenarios in `requirements.md` become test cases.
- **`/iron:review`** — The review skill checks Axis 3 (test coverage). TDD ensures
  coverage is built in, not bolted on.
- **`/iron:debug`** — When debugging, the regression test from `/iron:tdd fix`
  closes the loop by ensuring the bug cannot recur.

## Rules

- **Never skip red.** A test that passes on first run tests nothing useful.
- **Never skip refactor.** Green code is intentionally rough. Polish it.
- **One test per cycle.** Don't batch tests — each cycle adds one behavior.
  Work in vertical slices.
- **Run ALL tests, not just the new one.** Regressions hide in green bars.
- **Test at the seam, not the wiring.** If a function takes X and returns Y,
  test X→Y at the public boundary. Don't mock everything between them.
- **Name tests like sentences.** `test_<action>_<result>_<condition>` reads as
  documentation when tests fail.
- **Identify the seam before writing the test.** No test at an unconfirmed seam.
- **Mock only at system boundaries.** Never mock your own code.
- **Expected values are independent.** Never recompute the expected value using
  the same logic as the code under test.
- **Replace, don't layer.** When seam-level tests cover a behavior, delete the
  redundant shallow tests.
- **Refactoring adds zero behavior.** If you want to handle a new case during
  refactor, start a new red-green cycle instead.
