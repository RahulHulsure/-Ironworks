---
name: iron-debug
description: "Structured debugging: reproduce the problem, form hypotheses, instrument the code, narrow down the cause, fix it, and add a regression test. No guessing, no shotgun fixes."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:debug — Structured Debugging

Debug methodically, not randomly. This skill enforces a feedback-loop approach:
reproduce → hypothesize → instrument → narrow → fix → verify. No shotgun
debugging, no "try changing this and see if it works."

## When to Use

- A bug report comes in and you need to find the root cause
- Tests are failing and the reason isn't obvious
- Something works locally but breaks in production
- Performance is unexpectedly slow

## Invocation

```
/iron:debug <problem description>    # Start structured debugging
/iron:debug narrow                   # Continue narrowing from last checkpoint
```

## What You Must Do When Invoked

### Step 1 — Define the Problem

State the problem precisely. Not "it's broken" but:

```
PROBLEM STATEMENT:
  Expected: [what should happen]
  Actual:   [what actually happens]
  When:     [conditions / trigger]
  Since:    [when it started, if known]
  Severity: [blocking / degraded / cosmetic]
```

If the user's description is vague, ask clarifying questions before proceeding.
You need all five fields to debug effectively.

### Step 2 — Reproduce

Before anything else, reproduce the problem. This means:

1. **Find or write a reproduction path:**
   - A test case that fails
   - A curl command that triggers the error
   - A sequence of UI actions
   - A specific input that causes the issue

2. **Confirm the reproduction:**
   ```
   🔄 REPRODUCTION:
      Command: curl -X POST localhost:8000/api/auth/login -d '{"email":"test@x.com"}'
      Expected: 200 with token
      Got: 500 Internal Server Error
      Confirmed: ✓ reproducible
   ```

3. **If you can't reproduce:** Say so. Ask for more context — logs, environment
   details, timing. Don't guess at fixes for bugs you can't reproduce.

### Step 3 — Form Hypotheses

Based on the problem and the code, list 2-4 hypotheses ranked by likelihood:

```
HYPOTHESES (most likely first):
  H1: Database connection pool exhausted — the 500 happens under load
      Evidence: No connection pool config found in core/database.py
      Confidence: 70%

  H2: Token generation fails on missing SECRET_KEY env var
      Evidence: config.py uses getenv with empty string default
      Confidence: 20%

  H3: Race condition in concurrent login attempts
      Evidence: No locking on user session creation
      Confidence: 10%
```

### Step 4 — Instrument and Narrow

For each hypothesis, starting with the most likely:

1. **Add instrumentation** — targeted logging, breakpoints, or assertions:
   - Add a log statement BEFORE the suspected failure point
   - Add a log statement AFTER it
   - If the "before" fires but "after" doesn't, the failure is between them

2. **Run the reproduction** with instrumentation active.

3. **Report findings:**
   ```
   INVESTIGATING H1: Database connection pool
     Added: logging in core/database.py:get_db()
     Result: Connection acquired successfully → H1 eliminated ✗

   INVESTIGATING H2: Missing SECRET_KEY
     Added: logging in core/config.py:Settings.__init__()
     Result: SECRET_KEY = "" (empty string, not None) → H2 CONFIRMED ✓
     Root cause: os.getenv("SECRET_KEY", "") returns empty string,
                 jwt.encode() fails silently with empty key
   ```

4. **Narrow until you have the root cause.** Not the symptom (500 error),
   not the proximate cause (JWT encode fails), but the root:
   `SECRET_KEY defaults to empty string instead of raising on missing value.`

### Step 5 — Fix

Apply the minimum fix:

1. **Fix the root cause**, not the symptom:
   ```python
   # Before (broken):
   SECRET_KEY = os.getenv("SECRET_KEY", "")

   # After (fixed):
   SECRET_KEY = os.environ["SECRET_KEY"]  # Raises KeyError if missing
   ```

2. **Add a regression test** using `/iron:tdd fix` methodology:
   ```python
   def test_missing_secret_key_raises_clear_error():
       with mock.patch.dict(os.environ, {}, clear=True):
           with pytest.raises(KeyError):
               importlib.reload(config)
   ```

3. **Remove instrumentation** — delete the debug logging you added.

### Step 6 — Verify

```
VERIFICATION:
  ✓ Regression test passes
  ✓ Original reproduction now works correctly
  ✓ All existing tests pass
  ✓ Instrumentation removed

ROOT CAUSE: SECRET_KEY env var defaulted to empty string instead of
            raising on missing value. JWT encode silently produced
            invalid tokens.

FIX: Changed os.getenv("SECRET_KEY", "") → os.environ["SECRET_KEY"]
     in core/config.py:8. Added regression test.

PREVENTION: /iron:preflight Check 1.2 would have caught this —
            run preflight before deploying.
```

## Rules

- **Reproduce before fixing.** A fix without reproduction is a guess.
- **One hypothesis at a time.** Don't change multiple things at once.
- **Remove instrumentation.** Debug logging must not ship to production.
- **Fix the root cause.** If the error is "null pointer on line 42," the fix
  is not a null check on line 42 — it's figuring out WHY it's null.
- **Always add a regression test.** If a bug existed, a test should ensure
  it can't come back.
- **Document the diagnosis.** The verification summary goes in the commit message.
- **Don't assume.** "It's probably X" is not debugging. Instrument and prove.
