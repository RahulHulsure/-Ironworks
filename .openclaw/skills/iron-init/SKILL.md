---
name: iron-init
description: "Bootstrap any project from zero to production-ready: folder structure, CLAUDE.md, git, specs directory, CI template, env config. One command, fully scaffolded."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:init — Project Bootstrapper

Bootstrap a project from zero to production-ready in one pass. This is not a
template dump — it reads your intent, asks the minimum questions, and generates
a structure tailored to your stack.

## When to Use

- Starting a new project from scratch
- Joining a project that has no structure (no CLAUDE.md, no specs, no CI)
- Converting a prototype into a production project

## Invocation

```
/iron:init                           # Interactive — detects or asks for stack
/iron:init --stack nextjs-fastapi    # Skip detection, use known stack
/iron:init --minimal                 # Bare minimum: git, CLAUDE.md, .gitignore
```

## What You Must Do When Invoked

### Step 1 — Detect or Ask

Check the current directory for existing files. Detect the stack:

| Signal | Stack |
|--------|-------|
| `package.json` with `next` | Next.js frontend |
| `package.json` with `react` (no next) | React SPA |
| `package.json` with `vue` | Vue.js frontend |
| `package.json` with `svelte` or `svelte.config.js` | SvelteKit |
| `package.json` with `express` | Express.js backend |
| `angular.json` | Angular frontend |
| `requirements.txt` or `pyproject.toml` with `fastapi` | FastAPI backend |
| `requirements.txt` with `django` | Django backend |
| `composer.json` with `laravel` | Laravel/PHP |
| `go.mod` | Go backend |
| `Cargo.toml` | Rust project |
| `pom.xml` or `build.gradle` | Java/Spring project |
| `build.sbt` | Scala project |
| `mix.exs` | Elixir/Phoenix project |
| `*.csproj` or `*.sln` | .NET/C# project |
| `pubspec.yaml` | Flutter/Dart project |
| None of the above | Ask the user |

If the project already has files, say what you detected and confirm before
proceeding. Never overwrite existing files without explicit confirmation.

If the directory is empty or `--stack` was passed, proceed directly.

### Step 2 — Create the Structure

Generate the project skeleton. The exact structure depends on the detected
stack, but every project gets these:

```
project-root/
├── CLAUDE.md                # Project instructions (generated, specific to this project)
├── CONTEXT.md               # Shared vocabulary / glossary (generated)
├── .gitignore               # Stack-appropriate ignores
├── .env.example             # All env vars the project needs, with descriptions
├── ironworks/               # Spec-driven development directory
│   ├── specs/               # Living requirements (empty to start)
│   └── changes/             # In-flight feature proposals
├── docs/
│   └── adr/                 # Architecture Decision Records
│       └── 0001-initial-stack-choice.md
├── .github/
│   └── workflows/
│       └── ci.yml           # Basic CI: lint, test, type-check
└── README.md                # Project readme with setup instructions
```

**Architecture Decision Records (ADR) format:**

Every ADR follows the file naming convention `NNNN-slug.md` (e.g., `0001-initial-stack-choice.md`) and uses this structure:

```markdown
# NNNN. Title

**Status:** Accepted | Proposed | Deprecated | Superseded by NNNN

## Context
What is the issue that we're seeing that is motivating this decision or change?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or harder to do because of this change?
```

The initial ADR (`0001-initial-stack-choice.md`) documents the detected or chosen stack and why.

**Stack-specific additions:**

For **Next.js + FastAPI** (or any frontend + backend combo):
```
├── frontend/                # Next.js / React app
│   ├── src/
│   │   ├── app/             # App router pages
│   │   ├── components/      # Shared components
│   │   ├── lib/             # API client, utilities
│   │   └── hooks/           # Custom hooks
│   └── package.json
├── backend/
│   ├── app/
│   │   ├── models/          # Database models
│   │   ├── routes/          # API routes
│   │   ├── services/        # Business logic
│   │   ├── schemas/         # Request/response schemas
│   │   └── core/            # Config, security, database setup
│   ├── migrations/          # Database migrations
│   ├── tests/               # Test directory mirroring app/
│   └── requirements.txt
└── docker-compose.yml       # Local dev: DB + cache + backend
```

For **single backend** (FastAPI, Django, Go, etc.):
```
├── app/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── schemas/
│   └── core/
├── migrations/
├── tests/
└── requirements.txt / go.mod / Cargo.toml
```

For **minimal** (`--minimal`):
```
├── CLAUDE.md
├── CONTEXT.md
├── .gitignore
└── README.md
```

### Step 3 — Generate CLAUDE.md and CONTEXT.md

The CLAUDE.md is the most important output. It must be specific to THIS project,
not a generic template. Include:

```markdown
# [Project Name]

## What This Is
[One paragraph: what the project does, who it's for]

## Stack
- **Frontend**: [detected or specified]
- **Backend**: [detected or specified]
- **Database**: [detected or specified]
- **Deployment**: [if known]

## Project Structure
[Actual tree of what was generated]

## Development Rules
- All API responses use the envelope: `{ data, error, meta }`
- Business logic lives in services/, never in routes/
- Every route has input validation via schemas/
- Tests mirror the app/ structure — `app/services/auth.py` → `tests/services/test_auth.py`

## How to Run
[Stack-specific commands]

## Environment Variables
[Table from .env.example]

## Ironworks
- Specs: `ironworks/specs/` — read before implementing
- Changes: `ironworks/changes/` — check before starting new work
- Propose features: `/iron:spec propose <name>`
- Review code: `/iron:review`
- Pre-deploy check: `/iron:preflight`
```

**Also generate a starter `CONTEXT.md`** with the project name and a placeholder glossary:

```markdown
# [Project Name] — Domain Glossary

Shared vocabulary for this project. Every contributor and AI agent should use
these terms consistently.

## Format

Each entry follows this pattern:

```
Term: definition. _Avoid_: synonym1, synonym2.
```

The _Avoid_ list names words that mean the same thing but should not be used in
code, specs, or conversation — pick one word and stick with it.

## Glossary

User: A person with an account in the system. _Avoid_: customer, client, member (unless specifically distinct).

[Add terms as the project evolves. Run `/iron:spec explore` to update.]
```

### Step 4 — Generate .env.example

List every environment variable the project will need. Include descriptions
and example values (never real secrets):

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname  # Postgres connection string

# Auth
SECRET_KEY=change-me-to-a-random-64-char-string               # JWT signing key
ACCESS_TOKEN_EXPIRE_MINUTES=30                                  # Token TTL

# Redis (if applicable)
REDIS_URL=redis://localhost:6379/0                              # Cache and queue broker
```

### Step 5 — Generate CI

Create `.github/workflows/ci.yml` appropriate to the stack:

- **Python**: Install deps, run `ruff check`, run `pytest`, type-check with `mypy` if configured
- **Node**: Install deps, run `eslint`, run `vitest` or `jest`, type-check with `tsc --noEmit`
- **Both**: Matrix job running each independently

The CI should be minimal but real — it must actually pass on the generated code.

### Step 6 — Initialize Git

```bash
git init
git add -A
git commit -m "Initial project scaffold via ironworks

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 7 — Report

Print a concise summary:

```
✓ Project scaffolded: [name]
  Stack: Next.js 14 + FastAPI + PostgreSQL
  Files: 23 created, 0 modified

  Next steps:
  1. cp .env.example .env — fill in your values
  2. /iron:spec propose <first-feature> — plan your first feature
  3. /iron:graph — map the codebase (if existing code)
  4. Start building — ironworks active
```

## Rules

- **Never overwrite existing files** without asking. If CLAUDE.md exists, offer to merge.
- **No placeholder code.** Every generated file must be valid and runnable.
- **No unnecessary dependencies.** The scaffold uses only what the stack provides.
- **The scaffold must pass its own CI.** Lint, test, type-check all pass on day one.
- **Ask before generating** if auto-detection is ambiguous. Asking is cheaper than re-scaffolding.
