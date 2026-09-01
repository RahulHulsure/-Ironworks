# /iron:preflight — Deploy Preflight Check

> Pre-deployment validation: checks env vars, health endpoints, DB migrations, secrets, error handling, logging, CORS, and resource limits before you ship.

**Layer:** L6 — Ship | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Runs a structured checklist of everything that causes 3am pages when forgotten. Validates environment variables, health endpoints, database migrations, security configuration, error handling, and logging. Supports platform-specific checks for DigitalOcean, Docker, Vercel, AWS, Railway, and Fly.io. Reports pass/fail/warning per check with exact file and line references.

## Quick Start

```
/iron:preflight                      # Full preflight check
/iron:preflight --quick              # Critical checks only (env, health, secrets)
/iron:preflight --fix                # Auto-fix what's safe
/iron:preflight --platform docker    # Add Docker-specific checks
/iron:preflight --platform aws       # Add AWS-specific checks
```

## Key Features

- 7 check sections: environment, health, database, security, error handling, logging, platform
- Platform-specific checks: DigitalOcean, Docker, Vercel, AWS, Railway, Fly.io
- Auto-fix mode for safe changes (gitignore, health endpoint, env.example, default secrets)
- Clear pass/fail/warning/skip status per check
- Every failure includes the exact file, line, and fix

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill is the final gate before deployment:

```
/iron:review → /iron:preflight → /iron:deploy
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
