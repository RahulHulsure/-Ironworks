---
name: iron-handoff
description: "Compress the current session into a handoff document: what was done, what's in progress, what's blocked, key decisions made, and exact state of the codebase. For session continuity or team handoffs."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:handoff — Session Handoff

Compress the current session's context into a structured handoff document.
Use it when ending a long session, switching to another agent, or briefing
a team member on what happened.

## When to Use

- Session is getting long and you want to continue in a fresh one
- Handing off work to another developer or agent
- End of day — capture what's in progress for tomorrow
- Before a context window compaction — preserve the important bits

## Invocation

```
/iron:handoff                        # Generate handoff for current session
/iron:handoff --for-agent            # Optimized for another Claude session to pick up
/iron:handoff --for-human            # Optimized for a human team member to read
```

## What You Must Do When Invoked

### Step 1 — Scan Session State

Review everything that happened in this session:

1. **Files modified** — what changed, what was created, what was deleted
2. **Decisions made** — architectural choices, trade-offs, rejected alternatives
3. **Ironworks state** — any specs proposed, tasks completed, reviews done
4. **Git state** — committed changes, uncommitted changes, current branch
5. **Open questions** — things that were deferred or need more information

### Step 2 — Generate the Handoff

#### For `--for-agent` (another Claude session)

Produce a concise, machine-parseable document:

```markdown
# Handoff — [Project Name] — [Date]

## State
- **Branch:** feature/add-auth
- **Last commit:** abc1234 "Add login endpoint and JWT generation"
- **Uncommitted changes:** backend/app/services/auth.py (password hashing WIP)

## What Was Done
1. Created ironworks spec: `ironworks/changes/add-auth/`
2. Implemented tasks 1.1–2.3 of add-auth (8/12 done)
3. Added User model, auth service, login/register endpoints
4. All tests passing (14 tests, 0 failures)

## What's In Progress
- Task 2.4: Password reset flow
  - Started: reset_password service function
  - Blocked on: Email sending approach not decided
  - Context: User asked about SendGrid vs SES, chose SES for cost

## Key Decisions
- JWT stored in httpOnly cookies, not localStorage (security)
- Refresh tokens: yes, 7-day expiry, rotation on use
- Password hashing: bcrypt via passlib (already installed)

## What's Left
- [ ] 2.4 Password reset (email sending)
- [ ] 3.1 Wire auth middleware to protected routes
- [ ] 3.2 Add rate limiting to auth endpoints
- [ ] 4.1 Error handling cleanup
- [ ] Update CLAUDE.md with auth documentation

## Watch Out For
- `backend/app/core/config.py` needs SECRET_KEY in production
- Token expiry is 30min — user mentioned wanting configurable
- No email service configured yet — blocks password reset

## To Resume
Run `/iron:spec show add-auth` to see current task state,
then `/iron:spec apply add-auth` to continue from task 2.4.
```

#### For `--for-human` (team member)

Produce a readable summary in natural language:

```markdown
# Session Summary — [Project Name] — [Date]

## What I Did
Built the authentication system for the TAX project. We now have:
- User registration with email/password
- Login that returns JWT tokens (httpOnly cookies)
- Refresh token rotation with 7-day expiry
- All endpoints tested (14 tests, all passing)

## What's Not Done Yet
Password reset is halfway done — the service function exists but
we haven't set up email sending. Decision was made to use SES
(cheaper than SendGrid at scale), but the integration isn't wired yet.

After that, auth middleware needs to be applied to the protected
routes, and rate limiting should go on the auth endpoints.

## Decisions That Were Made
- **JWT in cookies, not localStorage** — prevents XSS theft
- **Bcrypt via passlib** — was already in requirements.txt
- **Refresh tokens rotate on use** — limits window if one is stolen

## Things to Be Careful About
1. SECRET_KEY must be set in production — it'll crash on startup
   if missing (by design, so we don't run with empty keys)
2. Token expiry is hardcoded to 30min — should be configurable
3. No email service yet — password reset is blocked on this

## Files Changed
- `backend/app/models/user.py` — new
- `backend/app/services/auth.py` — new
- `backend/app/routes/auth.py` — new
- `backend/app/schemas/auth.py` — new
- `backend/app/core/security.py` — new (JWT helpers)
- `backend/tests/services/test_auth.py` — new (14 tests)
```

### Step 3 — Save the Handoff

Save to `ironworks/handoffs/YYYY-MM-DD-HH.md` (create the directory if needed).

Print the location and a one-liner: "Handoff saved. A new session can pick up
with `/iron:spec show` or by reading the handoff at [path]."

## Rules

- **Be specific, not vague.** "Worked on auth" is useless. "Implemented login
  endpoint returning JWT in httpOnly cookie, 14 tests passing" is useful.
- **Include file paths.** The next session or person needs to know WHERE things are.
- **Capture decisions AND rationale.** "JWT in cookies" is half the story.
  "JWT in cookies because localStorage is vulnerable to XSS" is the full story.
- **Note blockers explicitly.** If something was deferred because of a dependency,
  a question, or a missing piece, say so clearly.
- **Don't include code.** The handoff is a map, not a copy. Reference files, don't paste them.
- **Git state is critical.** Branch name, last commit, uncommitted changes — without
  these, the next session starts confused.
