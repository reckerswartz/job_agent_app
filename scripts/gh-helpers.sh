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
  local branch
  branch=$(git branch --show-current)
  if [ "$branch" = "main" ]; then
    echo "✗ Already on main — nothing to merge"
    return 1
  fi
  echo "Merging PR for ${branch}..."
  gh pr merge --squash --delete-branch
  echo "✓ PR merged and remote branch deleted"
}

# Enable auto-merge on current PR (merges automatically once CI passes)
gh-pr-auto() {
  local branch
  branch=$(git branch --show-current)
  if [ "$branch" = "main" ]; then
    echo "✗ Already on main — no PR to auto-merge"
    return 1
  fi
  echo "Enabling auto-merge for ${branch}..."
  gh pr merge --auto --squash --delete-branch
  echo "✓ Auto-merge enabled — PR will merge when all checks pass"
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

# Full workflow: commit, push, open PR, enable auto-merge
gh-ship-auto() {
  local msg="${1:?Usage: gh-ship-auto <commit-message>}"
  git add -A
  git commit -m "$msg"
  git push -u origin "$(git branch --show-current)"
  gh pr create --fill
  gh pr merge --auto --squash --delete-branch
  echo "✓ PR created with auto-merge enabled"
}

# Sync current branch with latest main
gh-sync() {
  local branch
  branch=$(git branch --show-current)
  git fetch origin main
  git rebase origin/main
  echo "✓ Rebased ${branch} onto latest main"
}

# ─── Complete Lifecycle ───────────────────────────────────────────────────────

# Merge current PR, sync back to main, ready for next task
gh-done() {
  local branch
  branch=$(git branch --show-current)

  if [ "$branch" = "main" ]; then
    echo "✗ Already on main — nothing to merge"
    return 1
  fi

  echo "=== Completing work on ${branch} ==="
  echo ""

  # Step 1: Ensure all changes are pushed
  if [ -n "$(git status --porcelain)" ]; then
    echo "[1/4] Uncommitted changes detected — committing..."
    git add -A
    git commit -m "Update: final changes on ${branch}"
    git push origin "${branch}"
  else
    echo "[1/4] Working tree clean ✓"
  fi

  # Step 2: Merge the PR
  echo "[2/4] Merging PR..."
  if ! gh pr merge --squash --delete-branch; then
    echo ""
    echo "✗ Merge failed. Possible reasons:"
    echo "  - CI checks haven't passed yet (use gh-pr-auto to enable auto-merge)"
    echo "  - Merge conflicts need resolution"
    echo "  - No PR exists for this branch (use gh-pr to create one)"
    return 1
  fi
  echo "  ✓ PR merged and remote branch deleted"

  # Step 3: Switch to main and pull latest
  echo "[3/4] Syncing to main..."
  git checkout main
  git pull origin main
  echo "  ✓ On main with latest changes"

  # Step 4: Clean up local branch
  echo "[4/4] Cleaning up..."
  git branch -d "${branch}" 2>/dev/null && echo "  ✓ Local branch ${branch} deleted" || echo "  ✓ Local branch already cleaned up"

  echo ""
  echo "=== Done! Ready for next task ==="
  echo "  Start a new task with: gh-feature <name>"
}

# Merge current PR with auto-merge, then sync when ready
gh-done-auto() {
  local branch
  branch=$(git branch --show-current)

  if [ "$branch" = "main" ]; then
    echo "✗ Already on main — nothing to merge"
    return 1
  fi

  echo "=== Setting auto-merge for ${branch} ==="
  echo ""

  # Ensure all changes are pushed
  if [ -n "$(git status --porcelain)" ]; then
    echo "[1/3] Uncommitted changes detected — committing..."
    git add -A
    git commit -m "Update: final changes on ${branch}"
    git push origin "${branch}"
  else
    echo "[1/3] Working tree clean ✓"
  fi

  # Enable auto-merge
  echo "[2/3] Enabling auto-merge..."
  if ! gh pr merge --auto --squash --delete-branch; then
    echo "✗ Auto-merge failed. Does a PR exist? Use gh-pr to create one."
    return 1
  fi
  echo "  ✓ Auto-merge enabled — will merge when CI passes"

  # Switch to main
  echo "[3/3] Switching to main..."
  git checkout main
  git pull origin main
  echo "  ✓ On main (PR will merge automatically in background)"

  echo ""
  echo "=== Auto-merge queued! Start next task with: gh-feature <name> ==="
}

echo "GitHub CLI helpers loaded. Run any gh-* command for shortcuts."
echo ""
echo "  Branches:   gh-feature, gh-fix, gh-chore"
echo "  PRs:        gh-pr, gh-pr-draft, gh-pr-list, gh-pr-view, gh-pr-status, gh-pr-merge, gh-pr-auto"
echo "  Issues:     gh-issue, gh-bug, gh-feat, gh-task, gh-issue-list, gh-issue-search"
echo "  Info:       gh-status, gh-activity, gh-browse"
echo "  Workflow:   gh-ship, gh-ship-auto, gh-sync, gh-done, gh-done-auto"
