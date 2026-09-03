---
name: iron-tdd
description: "Red-green-refactor TDD cycle with seam-based testing."
---

# /iron:tdd

## Invocation

```
/iron:tdd <what to build>            # Start a TDD cycle for a specific feature
/iron:tdd fix <bug description>      # Bug fix via TDD (regression test first)
/iron:tdd continue                   # Resume where the last cycle left off
```

## Seams

A **seam** is the public boundary you test at -- where behavior changes without editing that place.

### Seam Rules

- **Identify and confirm the seam before writing any test.** Example: "Seam under test: `AuthService.login()`"
- **No test at an unconfirmed seam.** If you cannot name the seam, you are not
  ready to write the test.
- **One adapter = hypothetical seam; two+ adapters = real seam.** Do not over-engineer hypothetical seams.

### Examples

```
SEAM IDENTIFICATION:
  Module: PaymentService
  Public interface: processPayment(order: Order): Receipt
  Adapters: StripeAdapter, TestAdapter → real seam ✓
  Tests target: processPayment() -- never the adapter internals

  Module: StringUtils.slugify
  Public interface: slugify(input: string): string
  Adapters: only one implementation → hypothetical seam
  Tests target: slugify() input/output behavior
```

## What You Must Do When Invoked

### Step 1 — Understand the Requirement

1. **Check for ironworks specs.** If `ironworks/changes/` has an active spec with
   requirements, use the scenarios from `requirements.md` as test cases.

2. **No spec?** Extract testable requirements. Confirm with user: "Testing these behaviors: [list]. Correct?"

3. **Identify the seam under test.** Name the public boundary explicitly. Confirm
   with the user before proceeding.

4. **Identify the test file.** Follow the project's existing pattern:
   - `app/services/auth.py` → `tests/services/test_auth.py`
   - `src/lib/utils.ts` → `src/lib/__tests__/utils.test.ts`
   - If no pattern exists, ask where tests should go.

### Step 2 — RED: Write a Failing Test

Test rules:
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

Minimum code: no extra features, no premature abstractions, no unexercised edge-case handling.

Prefer reuse > stdlib > minimum new code.

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

Improve structure without changing behavior:

- Extract duplication
- Improve names
- Simplify conditionals
- Move code to the right layer (if a route has logic, move it to a service)

Refactoring rules:
- **Tests must stay green.** Run them after every change.
- **Don't add behavior.** Refactoring changes structure, not behavior. If you
  are tempted to handle a new edge case during refactor, STOP -- that is a new
  red-green cycle.
- **Don't skip this step.** The green phase intentionally produces rough code.
  This is where you polish it.
- **"Replace, don't layer."** Delete shallow tests once seam-level tests cover the same behavior.

```
🔧 REFACTOR — Cleaned up:
   - Extracted token generation to core/security.py (already had JWT setup)
   - Renamed `check_pw` → `verify_password` for clarity
   - Deleted test_check_pw_hash (shallow test replaced by seam-level test)
   All tests still pass: ✓
```

### Step 5 — Next Cycle (Vertical Slice)

After each cycle, ask:

"Cycle complete. Next behavior to test:
1. [Suggested next test based on requirements]
2. [Another suggested test]
3. Or describe what to test next."

Repeat until all requirement scenarios are covered. Each cycle is one vertical
slice: one test, one implementation, one cleanup pass.

### For `/iron:tdd fix <bug>`

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

### Mock ONLY at System Boundaries

Mock these:
- **External APIs** -- third-party HTTP services your code calls
- **Databases** -- or use a test-specific instance/transaction rollback
- **Time and randomness** -- `Date.now()`, `Math.random()`, UUIDs
- **File system I/O** -- when tests need isolation from real files
- **Environment** -- env vars, OS-level state

### Never Mock Your Own Code

Never mock your own classes, modules, or functions. If you need to mock an
internal collaborator to test something, that is a signal the test is at the
wrong seam.

```
# WRONG -- mocking your own module
def test_login():
    with mock.patch("services.auth.hash_password"):  # ← own code
        ...

# RIGHT -- testing at the seam, mocking the boundary
def test_login():
    with mock.patch("services.auth.db.get_user"):    # ← database boundary
        ...
```

### Dependency Injection for Testable Seams

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

### SDK-Style Clients over Generic Fetchers

Wrap external APIs as typed clients with domain methods. The client is the seam.

```typescript
// WRONG -- generic fetcher (leaks HTTP details into tests)
const result = await fetch("/api/payments", { method: "POST", body: ... });

// RIGHT -- SDK-style client (clean seam)
const result = await paymentClient.charge(order);
```

## Anti-Patterns

### Implementation-Coupled Tests

**Pattern:** Tests mock internal collaborators or assert on private method calls.

**Signal:** Tests break on refactor despite unchanged behavior.

**Fix:** Test at the seam (inputs -> outputs + side effects). If you must reach into internals, the seam is wrong.

### Tautological Tests

**Pattern:** Assertion recomputes expected value the same way the code does.

```javascript
// TAUTOLOGICAL -- expected value recomputes what the code does
test("adds correctly", () => {
  const a = 3, b = 4;
  expect(add(a, b)).toBe(a + b);   // ← expected value is a + b, same as implementation
});

// CORRECT -- expected value is an independent literal
test("adds correctly", () => {
  expect(add(3, 4)).toBe(7);        // ← 7 is the independent source of truth
});
```

**Signal:** Expected value uses same formula as code. Shared bug = invisible bug.

**Fix:** Expected values from independent source: literal, fixture, reference implementation, or domain expert.

## Rules
- Never skip red. Never skip refactor.
- One test per cycle. Vertical slices only.
- Run ALL tests after every change.
- Test at the seam, not internals. Confirm seam before writing.
- Name tests: `test_<action>_<result>_<condition>`.
- Mock only system boundaries. Never mock own code.
- Expected values from independent source (literal, fixture, domain expert).
- Replace shallow tests when seam-level tests cover same behavior.
- Refactoring adds zero behavior. New case = new red-green cycle.
