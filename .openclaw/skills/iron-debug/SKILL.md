---
name: iron-debug
description: "Structured debugging: build a feedback loop, form hypotheses, instrument the code, narrow down the cause, fix it, and add a regression test. No guessing, no shotgun fixes."
homepage: https://github.com/RahulHulsure/-Ironworks
license: MIT
---

# /iron:debug — Structured Debugging

Debug methodically, not randomly. This skill enforces a feedback-loop approach:
define → build feedback loop → hypothesize → instrument → narrow → fix → verify.
No shotgun debugging, no "try changing this and see if it works."

## When to Use

- A bug report comes in and you need to find the root cause
- Tests are failing and the reason isn't obvious
- Something works locally but breaks in production
- Performance is unexpectedly slow
- Non-deterministic failures that need systematic reproduction

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

### Step 2 — Build a Feedback Loop

This is THE critical step. Everything depends on getting this right.

> If you have a tight pass/fail signal for the bug, you will find the cause.
> If you don't, no amount of staring at code will save you.

**If you catch yourself reading code to build a theory before this loop exists,
STOP.** Go back and build the loop first. Theories without a feedback loop are
speculation.

Choose the best method for constructing a feedback loop, in priority order
(prefer the earliest applicable method):

#### Method 1 — Failing Test (best)
Write a test case that fails because of the bug. This is the gold standard: fast,
deterministic, and it becomes your regression test when the fix lands.

#### Method 2 — Curl/HTTP Script
For API bugs, a curl command or short HTTP script that triggers the error
response. Quick, repeatable, easy to share.

#### Method 3 — CLI Invocation with Fixture
Run the program with a fixture input and diff stdout/stderr against the expected
output. Works well for CLI tools and data pipelines.

#### Method 4 — Headless Browser Script
For UI bugs, a Playwright or Puppeteer script that navigates to the broken state
and asserts on the DOM or screenshot. Slower but necessary for frontend issues.

#### Method 5 — Replay a Captured Trace
If a production trace, HAR file, or request log exists, replay it against a local
instance. Avoids reconstructing complex request sequences by hand.

#### Method 6 — Throwaway Harness
Extract the minimal subset of the system needed to reproduce the bug into a
standalone script. Useful when the full system is too slow or complex to iterate on.

#### Method 7 — Property/Fuzz Loop
Run 1000+ random inputs through the suspect function looking for violations of a
property (e.g., "output is always valid JSON," "no exception thrown"). Effective
for edge-case and parsing bugs.

#### Method 8 — Bisection Harness
Use `git bisect run <script>` to binary-search the commit that introduced the
bug. The script must exit 0 for good and non-zero for bad. Best when you know
"it worked last week but doesn't now."

#### Method 9 — Differential Loop
Run the same input through the old version and new version, diffing the outputs.
Useful for regressions where you have a known-good reference.

#### Method 10 — HITL Bash Script (last resort)
A script that sets up the state and pauses for manual verification. Use only
when no automated check is possible (e.g., visual rendering bugs without
screenshot comparison).

#### Completion Criteria

The feedback loop is not ready until it satisfies ALL four criteria:

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

#### Non-Deterministic Bugs

If the bug is non-deterministic (flaky test, race condition, timing-dependent):

1. **Loop it:** Run the reproduction 100x in a tight loop and measure the failure
   rate. Report the rate: "fails 3/100 runs."
2. **Parallelize:** Run multiple instances concurrently to increase the chance of
   triggering the race.
3. **Control time:** Pin timestamps, add artificial delays, or inject
   controlled concurrency to force the timing window.
4. **Track the rate:** After each change, re-run the loop and report whether the
   failure rate went up, down, or stayed the same.

```
NON-DETERMINISTIC BUG:
  Baseline: fails 3/100 runs (loop of 100, 3 failures)
  After adding mutex: fails 0/100 runs
  After removing mutex: fails 3/100 runs (confirmed cause)
```

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

1. **Add tagged instrumentation** — Every debug log MUST use a unique prefix tag
   for guaranteed cleanup later:

   ```python
   # Tagged debug logs — searchable and deletable
   print("[DEBUG-a4f2] get_db() called, pool_size:", pool.size())
   print("[DEBUG-a4f2] connection acquired:", conn.id)
   ```

   The tag format is `[DEBUG-XXXX]` where XXXX is a random 4-character hex string.
   Generate one tag per debugging session and use it consistently. This makes
   cleanup trivial: grep for the tag and delete every matching line.

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

4. **Narrow until you have the root cause.** Not the symptom (500 error),
   not the proximate cause (JWT encode fails), but the root:
   `SECRET_KEY defaults to empty string instead of raising on missing value.`

### For `/iron:debug narrow`

When invoked with `narrow`, this is a continuation of an active debugging session:

1. **Read the last instrumentation results.** Check the output from the most
   recent feedback loop run — what did the tagged debug logs reveal?

2. **Eliminate hypotheses based on evidence.** Mark each hypothesis as confirmed,
   eliminated, or still open based on the instrumentation data.

3. **Add new instrumentation to narrow further.** If the root cause is not yet
   found, add more targeted logging (same debug tag) to the narrowed-down area.

4. **Re-run the feedback loop.** Execute the reproduction script/test again with
   the new instrumentation.

5. **Repeat until root cause is found.** Each `narrow` cycle should cut the
   search space in half — binary search, not linear scan.

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

2. **State the root cause in the commit message.** The commit message should
   explain what was wrong and why, not just what changed:

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

4. **Prevention note.** State which other skill would have caught this earlier:
   ```
   PREVENTION: /iron:preflight Check 1.2 (env var validation) would have
   caught this before deployment. /iron:arch would have flagged the load-order
   dependency as a layer violation.
   ```

5. **Remove ALL instrumentation** — search for the debug tag and delete every
   matching line:
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

- **Build the feedback loop before theorizing.** If you are reading code to
  build a theory and no feedback loop exists, STOP. Build the loop first.
- **One hypothesis at a time.** Don't change multiple things at once.
- **Tag all debug logs.** Every `[DEBUG-XXXX]` tag must be unique to this
  session and must be removed before the fix ships.
- **Remove instrumentation.** Grep for the debug tag and confirm zero results
  before committing the fix.
- **Fix the root cause.** If the error is "null pointer on line 42," the fix
  is not a null check on line 42 — it's figuring out WHY it's null.
- **Always add a regression test.** If a bug existed, a test should ensure
  it can't come back.
- **State prevention.** In the commit message or verification summary, name
  which skill would have caught this earlier.
- **Document the diagnosis.** The verification summary goes in the commit message.
- **Don't assume.** "It's probably X" is not debugging. Instrument and prove.
- **Non-deterministic bugs need rates.** Track failure rates (e.g., 3/100) and
  re-measure after each change to confirm improvement.
