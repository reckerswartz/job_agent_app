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
gh-status                       # View open PRs, issues, CI
```

## CI/CD

CI runs automatically on pushes to `main` and on all pull requests:

| Job | Tool | Purpose |
|-----|------|---------|
| `scan_ruby` | Brakeman | Static security analysis |
| `scan_ruby` | bundler-audit | Gem CVE scanning |
| `lint` | RuboCop | Code style enforcement |

Dependabot keeps Ruby gems and GitHub Actions up to date weekly.
