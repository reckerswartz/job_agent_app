# GitHub Workflow

Standard development workflow for the Job Agent App.

## Branching Strategy

| Prefix | Use Case | Example |
|--------|----------|---------|
| `feature/` | New functionality | `feature/job-search-ui` |
| `fix/` | Bug fixes | `fix/broken-pagination` |
| `chore/` | Dependencies, CI, tooling | `chore/update-rails` |
| `docs/` | Documentation only | `docs/api-guide` |

Rules:
- **Never commit directly to `main`**
- Branches are short-lived and task-specific
- Delete branches after merge

## Development Workflow

```
1. Create branch    →  git checkout -b feature/my-change
2. Make changes     →  (code, test, verify)
3. Commit           →  git commit -m "Add job search filtering"
4. Push             →  git push -u origin feature/my-change
5. Open PR          →  gh pr create
6. CI passes        →  (automatic on push)
7. Review & merge   →  gh pr merge --squash --delete-branch
```

## Commit Messages

Format: `<type>: <description>`

| Type | When |
|------|------|
| `Add` | New feature or file |
| `Fix` | Bug fix |
| `Update` | Modification to existing code |
| `Remove` | Deleting code or files |
| `Refactor` | Code improvement, no behavior change |
| `Docs` | Documentation changes |
| `Test` | Adding or updating tests |
| `Chore` | Dependencies, CI, config |

Examples:
```
Add: job search results page with filtering
Fix: broken pagination on saved jobs list
Refactor: extract job matching into service object
Test: add specs for JobSearchService
Chore: update Rails to 8.1.3
```

## Pull Requests

Every change goes through a PR. The PR template (`.github/pull_request_template.md`) enforces:
- Purpose of the change
- Summary of changes
- Testing/validation checklist
- Linked issues
- No secrets in diff

### PR Size Guidelines

- **Small PRs** — aim for < 400 lines changed
- One concern per PR (don't mix features with refactors)
- If a feature is large, break it into stacked PRs

## Issues

Use issues for any task that can be worked on independently. Three templates:

| Template | Label | Use Case |
|----------|-------|----------|
| Bug Report | `bug` | Something broken or unexpected |
| Feature Request | `enhancement` | New functionality proposal |
| Task | `task` | Self-contained development work |

Every issue must be **self-contained** — another developer should be able to pick it up and execute without asking questions.

## CI/CD Pipeline

CI runs automatically on every push to `main` and on all pull requests.

### Jobs

| Job | What it does | Tool |
|-----|-------------|------|
| `scan_ruby` | Security scan for Rails vulnerabilities | Brakeman |
| `scan_ruby` | Audit gems for known CVEs | bundler-audit |
| `lint` | Enforce consistent code style | RuboCop |

### Pipeline Flow

```
Push / PR opened
    ├── scan_ruby
    │   ├── Brakeman (static security analysis)
    │   └── bundler-audit (dependency CVE scan)
    └── lint
        └── RuboCop (code style)
```

All jobs must pass before a PR can be merged.

### Running CI Checks Locally

```bash
# Security scan
bin/brakeman --no-pager

# Dependency audit
bin/bundler-audit

# Linter
bundle exec rubocop

# Ruby specs
bundle exec rspec

# E2E tests
npx playwright test
```

## Dependabot

Automated dependency updates are configured (`.github/dependabot.yml`):
- **Bundler** (Ruby gems) — weekly, up to 10 open PRs
- **GitHub Actions** — weekly, up to 10 open PRs

## GitHub CLI Shortcuts

Source the helper script for quick shortcuts:

```bash
source scripts/gh-helpers.sh
```

### Available Commands

| Command | Description |
|---------|-------------|
| `gh-feature <name>` | Create feature branch from latest main |
| `gh-fix <name>` | Create fix branch from latest main |
| `gh-chore <name>` | Create chore branch from latest main |
| `gh-pr [title]` | Open PR for current branch |
| `gh-pr-draft [title]` | Open draft PR |
| `gh-pr-list` | List open PRs |
| `gh-pr-view` | View current branch's PR |
| `gh-pr-status` | Check CI status on current PR |
| `gh-pr-merge` | Squash-merge and delete branch |
| `gh-issue` | Create issue (interactive) |
| `gh-bug <title>` | Create bug report |
| `gh-feat <title>` | Create feature request |
| `gh-task <title>` | Create task issue |
| `gh-issue-list [label]` | List open issues, optionally by label |
| `gh-issue-search <keyword>` | Search issues |
| `gh-status` | Repo summary (PRs, issues, CI) |
| `gh-activity` | Recent merged PRs and closed issues |
| `gh-browse` | Open repo in browser |
| `gh-ship <message>` | Commit, push, open PR in one command |
| `gh-sync` | Rebase current branch onto latest main |
