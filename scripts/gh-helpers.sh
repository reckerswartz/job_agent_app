#!/usr/bin/env bash
#
# GitHub CLI helper shortcuts for job_agent_app
# Source this file: source scripts/gh-helpers.sh
# Or add to your shell profile: source /path/to/job_agent_app/scripts/gh-helpers.sh
#

set -euo pipefail

# ─── Branch Management ────────────────────────────────────────────────────────

# Create a new feature branch from latest main
gh-feature() {
  local name="${1:?Usage: gh-feature <branch-name>}"
  git checkout main && git pull origin main
  git checkout -b "feature/${name}"
  echo "✓ Created branch feature/${name}"
}

# Create a new fix branch from latest main
gh-fix() {
  local name="${1:?Usage: gh-fix <branch-name>}"
  git checkout main && git pull origin main
  git checkout -b "fix/${name}"
  echo "✓ Created branch fix/${name}"
}

# Create a new chore branch from latest main
gh-chore() {
  local name="${1:?Usage: gh-chore <branch-name>}"
  git checkout main && git pull origin main
  git checkout -b "chore/${name}"
  echo "✓ Created branch chore/${name}"
}

# ─── Pull Requests ────────────────────────────────────────────────────────────

# Open a PR for the current branch (interactive)
gh-pr() {
  local title="${1:-}"
  if [ -n "$title" ]; then
    gh pr create --title "$title" --fill
  else
    gh pr create
  fi
}

# Open a draft PR for the current branch
gh-pr-draft() {
  local title="${1:-}"
  if [ -n "$title" ]; then
    gh pr create --title "$title" --fill --draft
  else
    gh pr create --draft
  fi
}

# List open PRs
gh-pr-list() {
  gh pr list --state open
}

# View current branch's PR
gh-pr-view() {
  gh pr view
}

# Check PR status (CI checks)
gh-pr-status() {
  gh pr checks
}

# Merge current PR (squash by default)
gh-pr-merge() {
  gh pr merge --squash --delete-branch
}

# ─── Issues ───────────────────────────────────────────────────────────────────

# Create a new issue (interactive)
gh-issue() {
  gh issue create
}

# Create a bug report
gh-bug() {
  local title="${1:?Usage: gh-bug <title>}"
  gh issue create --title "[Bug] ${title}" --label bug --template bug_report.md
}

# Create a feature request
gh-feat() {
  local title="${1:?Usage: gh-feat <title>}"
  gh issue create --title "[Feature] ${title}" --label enhancement --template feature_request.md
}

# Create a task
gh-task() {
  local title="${1:?Usage: gh-task <title>}"
  gh issue create --title "[Task] ${title}" --label task --template task.md
}

# List open issues
gh-issue-list() {
  local label="${1:-}"
  if [ -n "$label" ]; then
    gh issue list --state open --label "$label"
  else
    gh issue list --state open
  fi
}

# Search issues by keyword
gh-issue-search() {
  local query="${1:?Usage: gh-issue-search <keyword>}"
  gh issue list --search "$query"
}

# ─── Repository Info ──────────────────────────────────────────────────────────

# View repo status summary (PRs, issues, CI)
gh-status() {
  echo "=== Open Pull Requests ==="
  gh pr list --state open --limit 10
  echo ""
  echo "=== Open Issues ==="
  gh issue list --state open --limit 10
  echo ""
  echo "=== Current Branch CI Status ==="
  gh pr checks 2>/dev/null || echo "(no PR for current branch)"
}

# View recent repo activity
gh-activity() {
  echo "=== Recent PRs (merged) ==="
  gh pr list --state merged --limit 5
  echo ""
  echo "=== Recent Issues (closed) ==="
  gh issue list --state closed --limit 5
}

# Open the repo in the browser
gh-browse() {
  gh repo view --web
}

# ─── Quick Workflow ───────────────────────────────────────────────────────────

# Full workflow: commit, push, open PR
gh-ship() {
  local msg="${1:?Usage: gh-ship <commit-message>}"
  git add -A
  git commit -m "$msg"
  git push -u origin "$(git branch --show-current)"
  gh pr create --fill
}

# Sync current branch with latest main
gh-sync() {
  local branch
  branch=$(git branch --show-current)
  git fetch origin main
  git rebase origin/main
  echo "✓ Rebased ${branch} onto latest main"
}

echo "GitHub CLI helpers loaded. Run any gh-* command for shortcuts."
echo "Commands: gh-feature, gh-fix, gh-chore, gh-pr, gh-pr-draft, gh-pr-list,"
echo "          gh-pr-view, gh-pr-status, gh-pr-merge, gh-issue, gh-bug, gh-feat,"
echo "          gh-task, gh-issue-list, gh-issue-search, gh-status, gh-activity,"
echo "          gh-browse, gh-ship, gh-sync"
