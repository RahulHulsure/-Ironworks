---
name: iron-debug
description: "Feedback-loop debugging: hypothesize, instrument, narrow, fix, verify."
---

# /iron:debug

Debug methodically. Define → build feedback loop → hypothesize → instrument →
narrow → fix → verify.

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

If vague, ask clarifying questions. All five fields are required.

### Step 2 — Build a Feedback Loop

**Build the loop before reading code.** Theories without a feedback loop are
speculation.

Choose the best method, in priority order:

1. **Failing Test** (best) -- Write a test case that fails because of the bug.
2. **Curl/HTTP Script** -- For API bugs, a curl command or short HTTP script
   that triggers the error response.
3. **CLI Invocation with Fixture** -- Run the program with a fixture input and
   diff stdout/stderr against expected output.
4. **Headless Browser Script** -- For UI bugs, a Playwright or Puppeteer script
   that navigates to the broken state and asserts on the DOM or screenshot.
5. **Replay a Captured Trace** -- Replay a production trace, HAR file, or
   request log against a local instance.
6. **Throwaway Harness** -- Extract the minimal subset needed to reproduce the
   bug into a standalone script.
7. **Property/Fuzz Loop** -- Run 1000+ random inputs looking for property
   violations (e.g., "output is always valid JSON").
8. **Bisection Harness** -- `git bisect run <script>` to binary-search the
   introducing commit. Exit 0 = good, non-zero = bad.
9. **Differential Loop** -- Run the same input through old and new versions,
   diffing the outputs.
10. **HITL Bash Script** (last resort) -- Set up state and pause for manual
    verification. Use only when no automated check is possible.

**Completion criteria (all four required):**

- **Red-capable:** It currently fails / shows the bug
- **Deterministic:** Running it twice produces the same result
- **Fast:** Completes in seconds, not minutes
- **Agent-runnable:** Can be executed without human interaction

```
🔄 FEEDBACK LOOP:
   Method: Failing test (Method 1)
   Command: pytest tests/test_auth.py::test_login_rejects_expired_token -x
   Expected: PASS (token rejected)
   Got: FAIL (token accepted — the bug)
   Deterministic: ✓
   Speed: 0.3s
   Agent-runnable: ✓
```

**Non-deterministic bugs** -- if flaky, a race condition, or timing-dependent:

1. **Loop it:** Run the reproduction 100x and measure the failure rate.
2. **Parallelize:** Run multiple instances concurrently to trigger the race.
3. **Control time:** Pin timestamps or add artificial delays to force the
   timing window.
4. **Track the rate:** After each change, re-measure to confirm improvement.

```
NON-DETERMINISTIC BUG:
  Baseline: fails 3/100 runs (loop of 100, 3 failures)
  After adding mutex: fails 0/100 runs
  After removing mutex: fails 3/100 runs (confirmed cause)
```

### Step 3 — Form Hypotheses

List 2-4 hypotheses ranked by likelihood:

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

1. **Add tagged instrumentation** -- every debug log MUST use a `[DEBUG-XXXX]`
   tag (XXXX = random 4-hex string, one per session):

   ```python
   print("[DEBUG-a4f2] get_db() called, pool_size:", pool.size())
   print("[DEBUG-a4f2] connection acquired:", conn.id)
   ```

2. **Run the feedback loop** with instrumentation active.

3. **Report findings:**
   ```
   INVESTIGATING H1: Database connection pool
     Added: [DEBUG-a4f2] logging in core/database.py:get_db()
     Result: Connection acquired successfully → H1 eliminated ✗

   INVESTIGATING H2: Missing SECRET_KEY
     Added: [DEBUG-a4f2] logging in core/config.py:Settings.__init__()
     Result: SECRET_KEY = "" (empty string, not None) → H2 CONFIRMED ✓
     Root cause: os.getenv("SECRET_KEY", "") returns empty string,
                 jwt.encode() fails silently with empty key
   ```

4. **Narrow to the root cause** -- not the symptom, not the proximate cause,
   but why: `SECRET_KEY defaults to empty string instead of raising.`

### For `/iron:debug narrow`

1. **Read the last instrumentation results** from the most recent feedback loop
   run.
2. **Eliminate hypotheses based on evidence.** Mark each as confirmed,
   eliminated, or still open.
3. **Add new instrumentation** (same debug tag) and **re-run the feedback loop.**
4. **Repeat until root cause is found.** Each cycle should cut the search space
   in half -- binary search, not linear scan.

```
/iron:debug narrow

NARROWING (cycle 2):
  Previous: H2 confirmed — SECRET_KEY is empty string
  New question: Where is SECRET_KEY loaded? Is it the .env file or the deploy config?
  Added: [DEBUG-a4f2] logging in config loader, .env parser
  Result: .env has SECRET_KEY=abc123, but dotenv.load() is called AFTER Settings.__init__()
  Root cause refined: Load order bug — Settings reads env before dotenv populates it
```

### Step 5 — Fix

Apply the minimum fix:

1. **Fix the root cause**, not the symptom:
   ```python
   # Before (broken):
   SECRET_KEY = os.getenv("SECRET_KEY", "")

   # After (fixed):
   SECRET_KEY = os.environ["SECRET_KEY"]  # Raises KeyError if missing
   ```

2. **State the root cause in the commit message:**

   ```
   fix: raise on missing SECRET_KEY instead of defaulting to empty string

   Root cause: Settings.__init__() read SECRET_KEY before dotenv.load()
   populated the environment. The empty-string default caused jwt.encode()
   to silently produce invalid tokens.

   The load order is now: dotenv.load() → Settings.__init__().
   ```

3. **Add a regression test** using `/iron:tdd fix` methodology:
   ```python
   def test_missing_secret_key_raises_clear_error():
       with mock.patch.dict(os.environ, {}, clear=True):
           with pytest.raises(KeyError):
               importlib.reload(config)
   ```

4. **Prevention note** -- which skill would have caught this earlier:
   ```
   PREVENTION: /iron:preflight Check 1.2 (env var validation) would have
   caught this before deployment. /iron:arch would have flagged the load-order
   dependency as a layer violation.
   ```

5. **Remove ALL instrumentation** -- grep for the debug tag, delete all:
   ```
   grep -rn "[DEBUG-a4f2]" . → 4 files, 7 lines → all deleted ✓
   ```

### Step 6 — Verify

```
VERIFICATION:
  ✓ Regression test passes
  ✓ Original feedback loop now passes (bug is fixed)
  ✓ All existing tests pass
  ✓ Instrumentation removed (grep for [DEBUG-a4f2] returns 0 results)

ROOT CAUSE: Settings.__init__() read SECRET_KEY before dotenv.load()
            populated the environment. The empty-string default caused
            jwt.encode() to silently produce invalid tokens.

FIX: Changed os.getenv("SECRET_KEY", "") → os.environ["SECRET_KEY"]
     in core/config.py:8. Moved dotenv.load() before Settings init.
     Added regression test.

PREVENTION: /iron:preflight Check 1.2 would have caught this —
            run preflight before deploying. /iron:arch would have
            flagged the load-order dependency.
```

## Rules

- **One hypothesis at a time.** Don't change multiple things at once.
- **Fix the root cause.** If the error is "null pointer on line 42," the fix
  is not a null check on line 42 -- it's figuring out WHY it's null.
- **Don't assume.** "It's probably X" is not debugging. Instrument and prove.
