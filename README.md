# Job Agent App

A browser automation-powered application that finds relevant jobs for users by searching across multiple job boards, extracting listings, and ranking matches against user preferences.

## Getting Started

* **Ruby version:** See `.ruby-version`
* **Node version:** See `.node-version`

### Setup

```bash
bundle install
yarn install
bin/rails db:setup
```

### Development

```bash
bin/dev
```

### Tests

```bash
bundle exec rspec          # Ruby specs
bundle exec rubocop        # Linter
bin/brakeman --no-pager    # Security scan
bin/bundler-audit           # Dependency CVE audit
npx playwright test        # E2E browser tests
```

## GitHub Workflow

All development follows a branch-based workflow. See [docs/github-workflow.md](docs/github-workflow.md) for the full guide.

**Quick reference:**
- Never commit directly to `main` — always use a branch + PR
- Branch naming: `feature/x`, `fix/y`, `chore/z`
- PRs use a standardized template (`.github/pull_request_template.md`)
- Issues use templates for bugs, features, and tasks (`.github/ISSUE_TEMPLATE/`)
- CI runs Brakeman, bundler-audit, and RuboCop on every push and PR

### GitHub CLI Shortcuts

```bash
source scripts/gh-helpers.sh    # Load shortcuts
gh-feature my-feature           # Create feature branch
gh-ship "Add new feature"       # Commit + push + open PR
gh-done                         # Merge current PR + sync back to main
gh-status                       # View open PRs, issues, CI
```

## Architecture

```
User Profile (from resume PDF/text)
    ↓
Job Sources (LinkedIn, Indeed, Naukri, etc.)
    ↓
Job Scanner (Playwright browser automation)
    ↓
Job Listings (deduplicated, scored 0-100)
    ↓
Job Applications (auto-fill forms, track steps)
    ↓
Interventions (login/CAPTCHA → manual resolution → auto-retry)
    ↓
Dashboard (live stats, activity feed)
```

### Key Components

| Layer | Tech |
|-------|------|
| **Auth** | Devise (database_authenticatable, trackable, recoverable) |
| **Browser Automation** | playwright-ruby-client (headless Chromium) |
| **Background Jobs** | Solid Queue (scanning, applying, parsing queues) |
| **LLM** | NVIDIA Build API (vision + text + verification pipeline) |
| **Frontend** | Webpack + Bootstrap 5 Sass + Stimulus |
| **Database** | PostgreSQL + Active Storage |

## CI/CD

CI runs automatically on pushes to `main` and on all pull requests:

| Job | Tool | Purpose |
|-----|------|---------|
| `scan_ruby` | Brakeman | Static security analysis |
| `scan_ruby` | bundler-audit | Gem CVE scanning |
| `lint` | RuboCop | Code style enforcement |
| `test` | RSpec (222 specs) | Full test suite with PostgreSQL |

Dependabot keeps Ruby gems and GitHub Actions up to date weekly.

## Environment Variables

See `.env.example` for all required environment variables. Key ones:

| Variable | Purpose |
|----------|---------|
| `NVIDIA_API_KEY` | NVIDIA Build API for LLM features |
| `ACTIVE_RECORD_ENCRYPTION_*` | Encryption keys for AppSetting |
| `DATABASE_URL` | PostgreSQL connection (production/CI) |
