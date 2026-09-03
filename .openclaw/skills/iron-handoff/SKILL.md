---
name: iron-handoff
description: "Compress session context into a structured handoff for continuity or team handoffs."
---

# /iron:handoff

Compress the current session's context into a structured handoff document.
Use when ending a long session, switching to another agent, or briefing
a team member.

## Invocation

```
/iron:handoff                        # Generate handoff for current session
/iron:handoff --for-agent            # Optimized for another Claude session to pick up
/iron:handoff --for-human            # Optimized for a human team member to read
```

## What You Must Do When Invoked

### Step 0 — Session Recall

Check if `ironworks/handoffs/` contains previous handoff files. If so, read the
most recent one for cross-session continuity. Note accumulated lessons or
recurring blockers.

### Step 0.5 — Privacy Filter

Redact secrets before generating output:

- **API keys**: `sk-`, `AKIA`, `ghp_`, `xoxb-`, `npm_`, `glpat-`, `dop_v1_`
- **Tokens/JWTs**: `Bearer ey...`, `eyJ...` base64 patterns
- **Credentials in URIs**: `://user:pass@`

Replace all with `[REDACTED_SECRET]`.

### Step 1 — Scan Session State

Review the session for:

1. **Files modified** -- created, changed, deleted
2. **Decisions made** -- architectural choices, trade-offs, rejected alternatives
3. **Ironworks state** -- specs proposed, tasks completed, reviews done
4. **Git state** -- committed/uncommitted changes, current branch
5. **Open questions** -- deferred items or missing information

### Step 2 — Generate the Handoff

#### For `--for-agent` (another Claude session)

Concise, machine-parseable document:

```markdown
# Handoff — [Project Name] — [Date]

## State
- **Branch:** feature/add-auth
- **Last commit:** abc1234 "Add login endpoint and JWT generation"
- **Uncommitted:** backend/app/services/auth.py (password hashing WIP)

## What Was Done
1. Created spec: `ironworks/changes/add-auth/`, implemented tasks 1.1–2.3 (8/12)
2. Added User model, auth service, login/register endpoints, 14 tests passing

## What's In Progress
- Task 2.4: Password reset -- blocked on email sending (chose SES over SendGrid)

## Key Decisions
- JWT in httpOnly cookies (XSS prevention), bcrypt via passlib
- Refresh tokens: 7-day expiry, rotation on use

## What's Left
- [ ] 2.4 Password reset · 3.1 Auth middleware · 3.2 Rate limiting

## Watch Out For
- SECRET_KEY needed in production · Token expiry 30min (wants configurable)
- No email service configured -- blocks password reset

## To Resume
`/iron:spec show add-auth` → `/iron:spec apply add-auth` (continue from 2.4)
```

#### For `--for-human` (team member)

Readable natural-language summary:

```markdown
# Session Summary — [Project Name] — [Date]

## What I Did
Built authentication: registration, login (JWT in httpOnly cookies),
refresh token rotation (7-day expiry). 14 tests, all passing.

## What's Not Done Yet
Password reset halfway -- service exists, email sending not wired (using SES).
Then: auth middleware on protected routes, rate limiting.

## Decisions Made
- **JWT in cookies** — prevents XSS theft
- **Refresh tokens rotate on use** — limits theft window

## Watch Out For
1. SECRET_KEY must be set in production
2. Token expiry hardcoded to 30min
3. No email service -- blocks password reset

## Files Changed
New: user.py, auth.py (service/routes/schemas), security.py, test_auth.py
```

### Step 3 — Add Lessons Learned

Append a lessons section:

```markdown
### Lessons
- What worked: [e.g., "TDD caught the off-by-one before staging"]
- What didn't: [e.g., "unittest.mock too brittle, switched to fake SMTP"]
- What surprised: [e.g., "ORM generates 4 queries for one join"]
```

Carry forward relevant lessons from prior handoffs in `ironworks/handoffs/`.

### Step 4 — Suggest Next Steps

Recommend specific `/iron:*` commands for the next session:

```markdown
### Suggested Next Steps
- `/iron:spec show add-auth` to see current task state
- `/iron:review --staged` on auth changes before merging
- `/iron:preflight --platform aws` before deploying
```

Be specific -- name the spec, directory, platform.

### Step 5 — Phase Boundary Decision

Recommend: **Continue** (context fresh), **Handoff** (context long), **Subagent** (parallel side task), or **Compact** (continue after compaction). Append:

`### Session Transition — Recommended: **Handoff** — context 80%+ consumed, 4 tasks remain.`

### Step 6 — Save the Handoff

Save to `ironworks/handoffs/YYYY-MM-DD-HH.md`. Print the path and:
"Handoff saved. Resume with `/iron:spec show` or by reading [path]."

## Rules

- **Be specific.** "Implemented login endpoint, 14 tests passing" not "Worked on auth."
- **Decisions need rationale.** "JWT in cookies" is half; add "because XSS."
- **No code.** Reference files, don't paste them.
- **Git state is critical.** Branch, last commit, uncommitted changes.
