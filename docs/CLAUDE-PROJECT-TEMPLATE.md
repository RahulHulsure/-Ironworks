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
├── .do/              # Deployment specs (if applicable)
└── CLAUDE.md         # This file
```

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
- **Propose features**: `/iron:spec propose <name>`
- **Review code**: `/iron:review`
- **Pre-deploy check**: `/iron:preflight`
- **Map codebase**: `/iron:graph`

## Known Issues
- [List anything Claude should know about — workarounds, tech debt, gotchas]
- [e.g., "The PDF parser is slow on files > 10MB — needs streaming"]
- [e.g., "Auth middleware skips WebSocket routes — manual check needed"]
