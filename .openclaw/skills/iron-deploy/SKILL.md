---
name: iron-deploy
description: "Generate deployment configurations for any platform: DigitalOcean, Docker, Vercel, AWS, Railway. Produces ready-to-use config files from your project structure."
homepage: https://github.com/rmyndharis/ironworks-skills
license: MIT
---

# /iron:deploy — Deployment Config Generator

Generate production-ready deployment configurations from your project structure.
This reads your codebase, detects the stack, and produces platform-specific
config files that work out of the box.

## When to Use

- Setting up deployment for the first time
- Migrating to a new platform
- Adding a deployment target to an existing project
- Dockerizing a project

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

Read the project structure to determine:

- **Runtime**: Node.js, Python, Go, Rust, Java, Elixir
- **Framework**: Next.js, FastAPI, Django, Express, Gin, Phoenix
- **Database**: PostgreSQL, MySQL, MongoDB, Redis, SQLite
- **Is it a monorepo?**: Multiple apps in subdirectories
- **Existing deployment**: Check for Dockerfile, docker-compose.yml, app.yaml, etc.

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

Generate `docker-compose.yml` for local dev:
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

Generate `.do/app.yaml` following App Platform spec:
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

Generate comprehensive AWS deployment files:

- **Dockerfile** — multi-stage build following the same pattern as `/iron:deploy docker`
- **buildspec.yml** — for AWS CodeBuild, with install/pre_build/build/post_build phases
- **appspec.yml** — for AWS CodeDeploy, with lifecycle hooks (BeforeInstall, AfterInstall, ApplicationStart, ValidateService)
- **ECS task definition** — when ECS is the target, generate `task-definition.json` with:
  - Container definitions with proper CPU/memory limits
  - Log configuration pointing to CloudWatch Logs (`awslogs` driver)
  - Secrets references via AWS Secrets Manager ARNs
- **IAM least privilege recommendations** — list the minimum IAM permissions required for the generated deployment; output as a policy JSON template
- **CloudWatch logging configuration** — log group names, retention policies, metric filters for error rates
- **Auto-scaling configuration** — target tracking scaling policy with CPU/memory thresholds, min/max instance counts

#### Fly.io Expanded (`/iron:deploy fly`)

Generate `fly.toml` with full configuration:

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
- **Health checks** — HTTP checks on the health endpoint with grace period, interval, timeout
- **Auto-scaling** — `min_machines_running` and `auto_stop_machines` / `auto_start_machines`
- **Secrets management** — output a list of `fly secrets set KEY=value` commands for all env vars from .env.example
- **Volume mounts** — when persistent storage is detected (SQLite, file uploads, local data), generate `[mounts]` section

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
1. **Analyze** — read the source platform's config and extract services, env vars, ports, health checks, volumes, scaling settings
2. **Map** — translate each element to the target platform's equivalent
3. **Identify unmigrable elements** — flag features that don't have a direct equivalent on the target (e.g., Heroku add-ons, Render cron jobs, Fly.io Machines API specifics)
4. **Generate** — produce the new platform's config files
5. **Migration checklist** — output a checklist of manual steps:
   - DNS changes
   - Environment variable re-creation
   - Database migration/import
   - SSL certificate provisioning
   - CI/CD pipeline updates

#### PR Preview Environments (`/iron:deploy preview`)

Generate CI configuration for ephemeral preview environments on pull requests:

- **DigitalOcean** — GitHub Actions workflow that creates a temporary App Platform app on PR open, comments the preview URL, and destroys it on PR merge/close using `doctl`
- **Vercel** — vercel.json with Git integration (automatic preview on every push to PR branches)
- **Railway** — GitHub Actions workflow that creates a preview environment via `railway up --environment pr-<number>`, tears down on PR close

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
- Approval gates: generate a CI step or GitHub Actions environment protection rule
  that requires manual approval before production deployment proceeds

### Step 4 — Validate and Report

After generating configs:

1. **Cross-reference with .env.example** — every env var in the config must
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
  Obvious but critical when generating configs.
- **Don't over-configure.** Generate the minimum config that works. Users can
  add complexity later.
- **Warn about missing pieces.** If the project has no health endpoint but the
  config references one, flag it.
