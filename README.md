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
# Ruby specs
bundle exec rspec

# E2E browser tests
npx playwright test
```

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
