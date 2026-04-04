# Job Agent App

An AI-powered job search automation platform that scans LinkedIn, Indeed, and Naukri for relevant listings, matches them against your profile, and auto-applies to high-match Easy Apply jobs.

## Features

- **Multi-Source Scanning** — LinkedIn (HTTP), Indeed (HTTP), Naukri (browser) with auto-enrichment
- **AI Match Scoring** — Keyword + LLM semantic analysis with skill gap detection
- **Auto-Apply** — Configurable threshold for Easy Apply jobs
- **Resume & Cover Letters** — AI tailoring per job, PDF export (Prawn)
- **Real-Time Notifications** — Action Cable bell + branded email + webhooks (HMAC signed)
- **REST API** — 11 endpoints with Bearer token auth
- **Admin Panel** — Users, LLM models (sync/verify), API keys, scan monitor, audit log
- **Dark Mode** — Full theme support with accessibility (WCAG focus states, skip link, ARIA)

## Quick Start

### Prerequisites

- Ruby 3.4.2, Node 24, PostgreSQL 17, Yarn

### Native Setup

```bash
bundle install && yarn install
bin/rails db:setup
bin/dev                          # Starts Rails + Webpack + CSS watcher
```

### Docker Compose

```bash
docker compose up               # Starts web + PostgreSQL + Redis
docker compose exec web bin/rails db:setup
```

### Test Users (from seeds)

| Email | Password | Role |
|-------|----------|------|
| `admin@jobagent.dev` | `password123` | Admin |
| `demo@jobagent.dev` | `password123` | User (full profile) |

## Tests

```bash
bundle exec rspec              # 319 RSpec specs
bundle exec rubocop            # Linter
bin/brakeman --no-pager        # Security scan
bin/bundler-audit              # Dependency CVE audit
npx playwright test            # 18 E2E spec files
```

## Architecture

```
Resume Upload / LinkedIn URL Import
    ↓
AI Profile Structuring (NVIDIA LLM)
    ↓
Job Sources (LinkedIn, Indeed, Naukri)
    ↓
Scan → Enrich (HTTP) → Deduplicate → LLM Match Analysis
    ↓
Job Listings (filtered, sorted, scored 0-100)
    ↓
Auto-Apply (Easy Apply) / Manual Application
    ↓
Notifications + Webhooks + Activity Log
```

### Tech Stack

| Layer | Tech |
|-------|------|
| **Framework** | Rails 8.1, Ruby 3.4.2 |
| **Auth** | Devise (trackable, recoverable) |
| **Frontend** | Webpack + Bootstrap 5 Sass + Bootstrap Icons + Stimulus (12 controllers) |
| **LLM** | NVIDIA Build API (186 models, primary/vision/verification roles) |
| **Background Jobs** | Solid Queue (async in dev) |
| **Real-Time** | Action Cable (async dev, Solid Cable prod) |
| **Browser Automation** | Playwright Ruby (headless Chromium) |
| **PDF** | Prawn + prawn-table |
| **Database** | PostgreSQL 17 + Active Storage |
| **Deployment** | Docker + Kamal (SSL, PostgreSQL, Redis accessories) |

## API

Bearer token auth. See [docs/api.md](docs/api.md) for full reference.

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/v1/job_listings
```

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/job_listings` | GET | Paginated listings (filterable) |
| `/api/v1/job_applications` | GET/POST | List or create applications |
| `/api/v1/job_sources/:id/scan` | POST | Trigger a scan |
| `/api/v1/profile` | GET | User profile |
| `/api/v1/scan_runs` | GET | Scan history |

## Deployment

### Kamal (Production)

```bash
cp .kamal/secrets.example .kamal/secrets   # Fill in secrets
bin/kamal setup                             # First deploy
bin/kamal deploy                            # Subsequent deploys
```

### Health Check

```bash
curl http://localhost:3000/health           # JSON system status
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `NVIDIA_API_KEY` | NVIDIA Build API for LLM features |
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis for Action Cable + Solid Queue |
| `RAILS_MASTER_KEY` | Decrypts credentials |
| `ACTIVE_RECORD_ENCRYPTION_*` | Encryption keys for AppSetting |

## CI/CD

CI runs on all pushes and PRs: Brakeman, bundler-audit, RuboCop, RSpec (319 specs).

## Design System

See [docs/design-system.md](docs/design-system.md) for colors, components, helpers, and SCSS architecture.

## License

Private. All rights reserved.
