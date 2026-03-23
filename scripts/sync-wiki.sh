#!/usr/bin/env bash
#
# sync-wiki.sh
#
# Pushes the generated Playwright report and screenshots to the
# GitHub wiki repository. Requires `gh` CLI to be authenticated.
#
# Usage:
#   ./scripts/sync-wiki.sh [REPO]
#
# Arguments:
#   REPO  GitHub repo in owner/name format (auto-detected from git remote)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WIKI_DIR="$PROJECT_ROOT/tmp/wiki-checkout"

# --- Detect repo ---
if [[ -n "${1:-}" ]]; then
  REPO="$1"
else
  REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || true)
  if [[ -z "$REPO" ]]; then
    echo "ERROR: Could not detect GitHub repo. Pass it as an argument:"
    echo "  ./scripts/sync-wiki.sh owner/repo-name"
    exit 1
  fi
fi

WIKI_REMOTE="https://github.com/${REPO}.wiki.git"

echo "==> Syncing wiki for: $REPO"

# --- Clone or update the wiki repo ---
if [[ -d "$WIKI_DIR/.git" ]]; then
  echo "    Updating existing wiki checkout..."
  git -C "$WIKI_DIR" pull --rebase || true
else
  echo "    Cloning wiki repo..."
  rm -rf "$WIKI_DIR"
  git clone "$WIKI_REMOTE" "$WIKI_DIR" 2>/dev/null || {
    echo "    Wiki repo does not exist yet. Initializing..."
    mkdir -p "$WIKI_DIR"
    git -C "$WIKI_DIR" init -b main
    git -C "$WIKI_DIR" remote add origin "$WIKI_REMOTE"
  }
fi

# --- Copy report files ---
echo "    Copying report files..."
cp "$PROJECT_ROOT/docs/wiki/Home.md" "$WIKI_DIR/Home.md" 2>/dev/null || true
cp "$PROJECT_ROOT/docs/wiki/Playwright-Report.md" "$WIKI_DIR/Playwright-Report.md" 2>/dev/null || true
cp "$PROJECT_ROOT/docs/wiki/Playwright-Setup.md" "$WIKI_DIR/Playwright-Setup.md" 2>/dev/null || true

# Copy screenshots into the wiki (GitHub wikis support images in the repo)
if [[ -d "$PROJECT_ROOT/test-results/screenshots" ]]; then
  mkdir -p "$WIKI_DIR/screenshots"
  cp "$PROJECT_ROOT/test-results/screenshots/"*.png "$WIKI_DIR/screenshots/" 2>/dev/null || true
fi

# --- Commit and push ---
cd "$WIKI_DIR"
git add -A
if git diff --cached --quiet; then
  echo "    No changes to push."
else
  git commit -m "Update Playwright report — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push origin main
  echo "==> Wiki updated successfully!"
fi
