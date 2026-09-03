---
name: iron-deploy
description: "Generate deploy configs for Docker, DigitalOcean, Vercel, AWS, Railway, Fly.io from project structure."
---

# /iron:deploy

## Invocation

```
/iron:deploy docker                  # Generate Dockerfile + docker-compose.yml
/iron:deploy do                      # Generate DigitalOcean .do/app.yaml
/iron:deploy vercel                  # Generate vercel.json
/iron:deploy railway                 # Generate railway.toml
/iron:deploy aws                     # Generate AWS deployment files
/iron:deploy fly                     # Generate fly.toml
/iron:deploy --env staging           # Generate for staging environment
/iron:deploy --env production        # Generate for production (stricter defaults)
/iron:deploy migrate <source>        # Migrate from another platform
/iron:deploy preview                 # Generate CI config for PR preview environments
```

## What You Must Do When Invoked

### Step 1 — Detect the Stack

Detect:

- **Runtime**: Node.js, Python, Go, Rust, Java, Elixir
- **Framework**: Next.js, FastAPI, Django, Express, Gin, Phoenix
- **Database**: PostgreSQL, MySQL, MongoDB, Redis, SQLite
- **Monorepo?** Multiple apps in subdirectories
- **Existing deploy config?** Dockerfile, docker-compose.yml, app.yaml, etc.

### Step 2 — Generate Config

#### Docker (`/iron:deploy docker`)

Generate `Dockerfile`:
```dockerfile
# Multi-stage build — no dev deps in production
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app
# Non-root user
RUN addgroup --system app && adduser --system --ingroup app app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

Generate `docker-compose.yml`:
```yaml
services:
  app:
    build: .
    ports: ["3000:3000"]
    env_file: .env
    depends_on:
      db: { condition: service_healthy }
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: devpassword
    volumes: ["pgdata:/var/lib/postgresql/data"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
volumes:
  pgdata:
```

Generate `.dockerignore`:
```
node_modules
.env
.git
dist
*.log
```

#### DigitalOcean (`/iron:deploy do`)

Generate `.do/app.yaml`:
- Detect services, workers, static sites, databases
- Set appropriate instance sizes
- Configure health checks
- Map environment variables
- Set `min_instance_count: 2` for production

#### Vercel (`/iron:deploy vercel`)

Generate `vercel.json`:
- Route configuration
- Serverless function settings
- Environment variable mapping
- Edge vs serverless decisions

#### Railway (`/iron:deploy railway`)

Generate `railway.toml`:
- Build and start commands
- Health check path
- Resource sizing

#### AWS Expanded (`/iron:deploy aws`)

Generate AWS deployment files:

- **Dockerfile** -- multi-stage build following the same pattern as `/iron:deploy docker`
- **buildspec.yml** -- for AWS CodeBuild, with install/pre_build/build/post_build phases
- **appspec.yml** -- for AWS CodeDeploy, with lifecycle hooks (BeforeInstall, AfterInstall, ApplicationStart, ValidateService)
- **ECS task definition** -- generate `task-definition.json` with CPU/memory limits, CloudWatch logging (`awslogs`), and Secrets Manager references
- **IAM policy template** -- minimum permissions required, output as policy JSON
- **CloudWatch logging configuration** -- log group names, retention policies, metric filters for error rates
- **Auto-scaling configuration** -- target tracking scaling policy with CPU/memory thresholds, min/max instance counts

#### Fly.io Expanded (`/iron:deploy fly`)

Generate `fly.toml`:

```toml
app = "<app-name>"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

[[http_service.checks]]
  grace_period = "10s"
  interval = "30s"
  method = "GET"
  path = "/health"
  timeout = "5s"

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
```

Additional Fly.io config:
- **Secrets management** -- generate `fly secrets set` commands from .env.example
- **Volume mounts** -- when persistent storage is detected (SQLite, file uploads, local data), generate `[mounts]` section

#### Migration (`/iron:deploy migrate <source>`)

Migrate deployment config from another platform. Supported sources:

| Source | Config file read |
|--------|-----------------|
| `heroku` | `Procfile`, `app.json`, `heroku.yml` |
| `render` | `render.yaml` |
| `railway` | `railway.toml` |
| `fly` | `fly.toml` |
| `docker-compose` | `docker-compose.yml` |
| `aws-ecs` | `task-definition.json` |

Process:
1. **Analyze** -- read the source platform's config and extract services, env vars, ports, health checks, volumes, scaling settings
2. **Map** -- translate each element to the target platform's equivalent
3. **Identify unmigrable elements** -- flag features without a direct equivalent on the target (e.g., Heroku add-ons, Render cron jobs, Fly.io Machines API specifics)
4. **Generate** -- produce the new platform's config files
5. **Migration checklist** -- output a checklist of manual steps:
   - DNS changes
   - Environment variable re-creation
   - Database migration/import
   - SSL certificate provisioning
   - CI/CD pipeline updates

#### PR Preview Environments (`/iron:deploy preview`)

Generate CI configuration for ephemeral preview environments on pull requests:

- **DigitalOcean** -- GitHub Actions workflow that creates a temporary App Platform app on PR open, comments the preview URL, and destroys it on PR merge/close using `doctl`
- **Vercel** -- vercel.json with Git integration (automatic preview on every push to PR branches)
- **Railway** -- GitHub Actions workflow that creates a preview environment via `railway up --environment pr-<number>`, tears down on PR close

Generated config includes:
- Unique URL per PR (e.g., `app-pr-42.example.com`)
- Isolated database or shared staging DB (configurable)
- Auto-destroy on PR merge or close
- Comment on PR with preview URL and deployment status

### Step 3 — Environment Handling

For `--env staging`:
- Single instance, smaller resources
- Debug logging enabled
- Relaxed timeouts
- Seed data scripts included

For `--env production`:
- Multiple instances (min 2)
- Structured logging, no debug
- Strict timeouts
- Health checks required
- Resource limits enforced
- Approval gate: CI step or GitHub Actions environment protection requiring manual approval

### Step 4 — Validate and Report

1. **Cross-reference with .env.example** -- every env var in the config must
   be documented in .env.example, and vice versa.

2. **Run `/iron:preflight --platform <platform>`** to validate the config.

3. **Report:**
   ```
   ✓ Deployment config generated: Docker
     Files created:
       - Dockerfile (multi-stage, non-root)
       - docker-compose.yml (app + postgres)
       - .dockerignore

     Next steps:
       1. docker compose up — test locally
       2. /iron:preflight --platform docker — validate
       3. Push to trigger CI/CD
   ```

## Rules

- **Multi-stage builds always.** Never ship dev dependencies to production.
- **Non-root user always.** Security baseline for containers.
- **Health checks always.** Every deployment config includes a health check path.
- **Never hardcode secrets.** All sensitive values reference environment variables.
- **Match the stack.** A Python project gets `pip install`, not `npm install`.
- **Don't over-configure.** Generate the minimum config that works.
- **Warn about missing pieces.** If the project has no health endpoint but the
  config references one, flag it.
