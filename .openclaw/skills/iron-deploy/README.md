# /iron:deploy — Deployment Config Generator

> Generate production-ready deployment configs for Docker, DigitalOcean, Vercel, AWS, Railway, and Fly.io from your project structure.

**Layer:** L6 — Ship | **Part of [Ironworks](https://github.com/RahulHulsure/-Ironworks)**

## What This Skill Does

Detects your stack and generates platform-specific deployment files that work out of the box. Produces multi-stage Dockerfiles, docker-compose for local dev, platform config files, and CI pipelines for PR preview environments. Supports migrating configs between platforms and generates staging vs. production variants with appropriate defaults.

## Quick Start

```
/iron:deploy docker                  # Dockerfile + docker-compose.yml
/iron:deploy vercel                  # vercel.json
/iron:deploy aws                     # Dockerfile, buildspec, ECS task definition
/iron:deploy fly                     # fly.toml with health checks and scaling
/iron:deploy migrate heroku          # Migrate from another platform
/iron:deploy preview                 # CI config for PR preview environments
```

## Key Features

- Auto-detects runtime, framework, and database from project files
- Multi-stage Docker builds with non-root user and health checks
- Platform migration from Heroku, Render, Railway, Fly.io, Docker Compose, AWS ECS
- PR preview environments with auto-create/destroy and PR comments
- Environment variants: `--env staging` (relaxed) vs. `--env production` (strict)
- Cross-references all env vars against .env.example

## Use It Standalone

To use just this skill without the full Ironworks suite:

1. Copy this directory to your project's `.claude/skills/` (or equivalent)
2. The `SKILL.md` file contains the complete instructions

## Part of the Ironworks Pipeline

This skill generates configs after preflight validation:

```
/iron:preflight → /iron:deploy <platform> → deploy
```

→ [View all 12 skills](https://github.com/RahulHulsure/-Ironworks)
