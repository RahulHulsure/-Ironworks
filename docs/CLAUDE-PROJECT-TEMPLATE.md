# [Project Name]

## What This Is
[One paragraph: what the project does, who it's for, what problem it solves.]

## Stack
- **Frontend**: [framework, version]
- **Backend**: [framework, version]
- **Database**: [type, version]
- **Deployment**: [platform]

## Project Structure
```
├── frontend/         # [framework] app
├── backend/          # [framework] API
├── ironworks/        # Specs and changes (source of truth for requirements)
│   ├── specs/        # Living requirements
│   ├── changes/      # In-flight features
│   └── archive/      # Completed changes
├── docs/
│   └── adr/          # Architecture Decision Records
├── CONTEXT.md        # Domain glossary — shared vocabulary for the team
├── .do/              # Deployment specs (if applicable)
└── CLAUDE.md         # This file
```

## Domain Glossary

See `CONTEXT.md` for the project's canonical vocabulary. When writing code or
docs, use the terms defined there. If a term is missing, add it via
`/iron:spec explore`.

Format: `Term: definition. _Avoid_: synonym1, synonym2.`

## Architecture Decision Records

Architecture decisions are captured in `docs/adr/` as numbered markdown files.
Format: `NNNN-slug.md` with Title, Status, Context, Decision, Consequences.

To generate a new ADR: `/iron:arch --fix` creates them for Critical findings.

## Development Rules (Project-Specific)
- [Any rules specific to this project that override or extend globals]
- [e.g., "All API responses use the envelope defined in backend/schemas/response.py"]
- [e.g., "Frontend uses Zustand for state — no Redux, no Context for global state"]
- [e.g., "Dates are stored as UTC, displayed in user's timezone"]

## Current State
- [x] [What's built and working]
- [ ] [What's in progress — check ironworks/changes/]
- [ ] [What's not started yet]

## How to Run
```bash
# Backend
cd backend && pip install -r requirements.txt && uvicorn main:app --reload

# Frontend
cd frontend && npm install && npm run dev

# Both (if docker-compose exists)
docker compose up
```

## Environment Variables
| Variable | Description | Where |
|----------|-------------|-------|
| `DATABASE_URL` | Postgres connection | `.env` |
| `SECRET_KEY` | JWT signing key | `.env` |
| `REDIS_URL` | Cache connection | `.env` |

## Ironworks
- **Specs**: `ironworks/specs/` — read before implementing
- **Changes**: `ironworks/changes/` — check before starting new work
- **Handoffs**: `ironworks/handoffs/` — session continuity documents
- **Graph**: `ironworks/graph-report.md` — codebase dependency map
- **Domain**: `CONTEXT.md` — shared vocabulary (updated via `/iron:spec explore`)
- **ADRs**: `docs/adr/` — architecture decisions
- **Propose features**: `/iron:spec propose <name>`
- **Explore an idea**: `/iron:spec explore <topic>`
- **Review code**: `/iron:review`
- **Pre-deploy check**: `/iron:preflight`
- **Map codebase**: `/iron:graph`
- **Debt ledger**: `/iron:audit debt`

## Known Issues
- [List anything Claude should know about — workarounds, tech debt, gotchas]
- [e.g., "The PDF parser is slow on files > 10MB — needs streaming"]
- [e.g., "Auth middleware skips WebSocket routes — manual check needed"]
