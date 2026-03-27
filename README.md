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

## CI/CD

CI runs automatically on pushes to `main` and on all pull requests:

| Job | Tool | Purpose |
|-----|------|---------|
| `scan_ruby` | Brakeman | Static security analysis |
| `scan_ruby` | bundler-audit | Gem CVE scanning |
| `lint` | RuboCop | Code style enforcement |

Dependabot keeps Ruby gems and GitHub Actions up to date weekly.

## Agent Skills

This project includes agent skills (`.devin/skills/`) that extend AI coding assistant capabilities for development workflows. Skills follow the universal `SKILL.md` format and work across Claude Code, Cursor, Windsurf, and other AI coding tools.

### Installed Skills

| Skill | Description | Invoke With |
|-------|-------------|-------------|
| **browser-use** | Control a live browser to navigate, interact, and extract data from web pages | `/browser-use [url]` |
| **browser-recorder** | Record browser sessions — screenshots, snapshots, network activity | `/browser-recorder [url]` |
| **browser-test** | Full app walkthrough with regression baseline recording | `/browser-test [base-url]` |
| **job-search-automation** | Search job boards, extract listings, score and rank matches | `/job-search-automation [criteria]` |
| **frontend-design** | Generate production-grade UI with distinctive design system | `/frontend-design [component]` |
| **code-reviewer** | Automated code review — simplify, deduplicate, fix quality issues | `/code-reviewer [file-or-dir]` |
| **security-auditor** | Audit code for OWASP vulnerabilities using Brakeman and manual review | `/security-auditor [file-or-dir]` |
| **excalidraw-diagram** | Generate architecture diagrams as Excalidraw JSON | `/excalidraw-diagram [description]` |

### Skills Reference

Based on [10 Must-Have Skills for Claude (and Any Coding Agent) in 2026](https://medium.com/@unicodeveloper/10-must-have-skills-for-claude-and-any-coding-agent-in-2026-b5451b013051):

- **Browser Use** — Core to the app's job search automation workflow
- **Frontend Design** — Escape generic AI-generated UI; use a purposeful design system
- **Code Reviewer** — Every code change gets a second-draft review before presentation
- **Security Auditor** — Inspired by Shannon autonomous pentester; audit for OWASP vulnerabilities
- **Excalidraw Diagram** — Generate visual architecture documentation as part of development
- **Job Search Automation** — Custom domain skill for multi-board job discovery and ranking
