---
name: iron-preflight
description: "Pre-deploy validation: env vars, health, DB migrations, secrets, errors, logging, CORS, resource limits."
---

# /iron:preflight

## Invocation

```
/iron:preflight                      # Full preflight check
/iron:preflight --quick              # Critical checks only (env, health, secrets)
/iron:preflight --fix                # Fix what can be auto-fixed
/iron:preflight --platform do        # DigitalOcean-specific checks
/iron:preflight --platform docker    # Docker/docker-compose checks
/iron:preflight --platform vercel    # Vercel-specific checks
/iron:preflight --platform aws       # AWS-specific checks
```

## Procedure

Run checks in order. Report each as:

- ✅ **Pass** -- requirement met
- ❌ **Fail** -- must fix before deploying
- ⚠️ **Warning** -- not blocking, but should address soon
- ⏭️ **Skip** -- not applicable to this project

### Section 1: Environment Variables

**1.1 — .env.example exists and is complete**
- Read `.env.example` (or `.env.template`, `.env.sample`).
- If missing: ❌ FAIL
- If exists: scan codebase for `os.environ`, `os.getenv`, `process.env`, `env(`, `config(` patterns. Compare against .env.example.
- Any env var used in code but missing from .env.example: ❌ FAIL -- list them.

**1.2 — No default secrets**
- Scan for `SECRET_KEY = "change-me"`, `password = "admin"`, hardcoded credentials.
- If found: ❌ FAIL -- "Use `os.environ['KEY']` without a default for secrets."

**1.3 — Sensitive vars are not logged**
- Search logging statements for vars containing SECRET, KEY, TOKEN, PASSWORD.
- If found: ❌ FAIL

### Section 2: Health & Readiness

**2.1 — Health endpoint exists**
- Search for `/health`, `/healthz`, `/api/health`, `/_health` route.
- If found: ✅ -- verify it checks DB connectivity.
- If not: ❌ FAIL

**2.2 — Graceful shutdown**
- Look for SIGTERM/SIGINT handlers or framework shutdown hooks.
- If not found: ⚠️ WARNING

### Section 3: Database

**3.1 — Migrations up to date** -- migration directory exists with no unapplied changes
**3.2 — Migrations reversible** -- up/down pairs for destructive operations
**3.3 — No N+1 patterns** -- queries inside loops → suggest eager loading
**3.4 — Connection pooling** -- pool settings configured

### Section 4: Security

**4.1 — No secrets in code** -- `sk-`, `AKIA`, hardcoded tokens
**4.2 — .gitignore covers sensitive files** -- `.env`, `*.pem`, `*.key`, credentials
**4.3 — CORS locked down** -- no `Allow-Origin: *` in production
**4.4 — Rate limiting** -- public endpoints have throttling

### Section 5: Error Handling

**5.1 — Global error handler** -- catches unhandled exceptions, no stack traces exposed
**5.2 — External calls have error handling** -- try/catch on HTTP, DB, file operations
**5.3 — Error responses are safe** -- no internal paths, SQL, or service names leaked

### Section 6: Logging & Observability

**6.1 — Structured logging** -- JSON format, not raw `print()`/`console.log()`
**6.2 — Request logging** -- middleware logging method, path, status, duration

### Section 7: Platform-Specific

**DigitalOcean (`--platform do`):**
- `.do/app.yaml` exists and validates
- `instance_count >= 2` for production
- Health check route configured
- Env vars match .env.example

**Docker (`--platform docker`):**
- Multi-stage build (no dev deps in production)
- Non-root user in Dockerfile
- `.dockerignore` covers node_modules, .env, .git
- Health check and resource limits defined

**Vercel (`--platform vercel`):**
- `vercel.json` exists with valid config
- Edge vs serverless assignment correct for each route
- Env vars from .env.example configured in Vercel project settings
- Build output directory matches framework convention
- Function bundle sizes within Vercel limits (50 MB serverless, 4 MB edge)
- API routes reachable (no conflicting rewrites or redirects)

**AWS (`--platform aws`):**
- IAM least privilege -- no `*` actions or `*` resources unless justified
- Security groups scoped -- no `0.0.0.0/0` on non-HTTP/HTTPS ports
- CloudWatch logging enabled with retention policy set
- Auto-scaling min/max configured (min >= 1)
- RDS instances in private subnet, not publicly accessible
- Secrets in Secrets Manager or Parameter Store, not in env vars or code

**Railway (`--platform railway`):**
- `railway.toml` exists with valid config
- Health check path configured (`[deploy.healthcheckPath]`)
- Build command specified (`[build.buildCommand]`)
- Start command specified (`[deploy.startCommand]`)
- Environment variables match .env.example

**Fly.io (`--platform fly`):**
- `fly.toml` exists with valid config
- Health check configured under `[[http_service.checks]]` or `[[services.tcp_checks]]`
- `auto_stop_machines` configured (prevents idle cost)
- `min_machines_running` set appropriately (>= 1 for production)
- Volumes configured via `[mounts]` for any persistent data (SQLite, uploads, local state)
- Secrets set via `fly secrets` -- no secrets in fly.toml

## Output Format

```
═══════════════════════════════════════════════
  IRONWORKS PREFLIGHT — [Project Name]
  [Date] · [Platform if specified]
═══════════════════════════════════════════════

  ENVIRONMENT              ✅ ✅ ❌
  HEALTH & READINESS       ✅ ⚠️
  DATABASE                 ✅ ✅ ⚠️ ✅
  SECURITY                 ✅ ✅ ❌ ⚠️
  ERROR HANDLING           ✅ ⚠️ ✅
  LOGGING                  ⚠️ ⚠️

───────────────────────────────────────────────
  Result: 2 FAILURES · 5 WARNINGS · 9 PASSES
───────────────────────────────────────────────

  ❌ MUST FIX:
  1. [env:1.2] Default SECRET_KEY in backend/core/config.py:14
  2. [security:4.3] CORS allows all origins in backend/core/config.py:28

  ⚠️ SHOULD FIX:
  1. [health:2.2] No graceful shutdown handler
  2. [db:3.3] N+1 query in backend/routes/clients.py:45

  ✅ Ready to deploy: NO — fix 2 failures first.
```

## With `--fix`

Auto-fix what's safe:
- Add missing entries to `.gitignore` ✅
- Create a basic health endpoint ✅
- Add missing env vars to `.env.example` ✅
- Replace default secrets with `os.environ['KEY']` ✅
- Add global error handler that strips stack traces ✅

Cannot auto-fix (needs human judgment):
- CORS origins, rate limit values, N+1 fixes, migration issues

After fixing, re-run preflight to confirm.

## Rules

- **Don't block on warnings.** Only failures prevent deployment.
- **No false positives.** Only flag what you can see in the code.
- **Be specific about fixes.** Name the file, line, and exact change.
- **Platform checks are additive.**
- **Must be fast.** Target config, routes, middleware, models -- not every file.
