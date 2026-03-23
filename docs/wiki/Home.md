# Job Agent App Wiki

Welcome to the **Job Agent App** wiki. This is the central reference for E2E testing, regression tracking, and visual change detection.

## Pages

| Page | Description |
|------|-------------|
| [Playwright Setup](Playwright-Setup.md) | How to install, configure, and run Playwright E2E tests |
| [Playwright Report](Playwright-Report.md) | Auto-generated report with captured URLs and screenshots |
| [Devin Browser Control](Devin-Browser-Control.md) | How Devin uses Playwright MCP to control and record the browser |

## Architecture Overview

```
job_agent_app/
├── e2e/                          # Playwright E2E tests
│   ├── fixtures/
│   │   └── url-tracker.ts        # Custom fixture: captures URLs + auto-screenshots
│   ├── helpers/
│   │   └── screenshot-helper.ts  # Reusable screenshot utilities
│   ├── reports/                   # Generated reports (gitignored)
│   │   ├── html/                 # Playwright HTML report
│   │   └── results.json          # JSON results for report generation
│   ├── home.spec.ts              # Home page tests
│   ├── health-check.spec.ts      # Health endpoint tests
│   └── navigation.spec.ts        # Multi-page navigation tests
├── test-results/                  # Test artifacts (gitignored)
│   ├── screenshots/              # All captured screenshots
│   └── url-log.json              # Cumulative URL log
├── scripts/
│   ├── generate-report.js        # Builds Markdown report from test artifacts
│   ├── record-session.js         # Standalone Playwright recording script
│   └── sync-wiki.sh              # Pushes report to GitHub wiki
├── .devin/                        # Devin CLI configuration
│   ├── config.json               # MCP server config + permissions
│   └── skills/
│       ├── browser-recorder/     # Skill: interactive browser recording
│       │   └── SKILL.md
│       └── browser-test/         # Skill: full regression walkthrough
│           └── SKILL.md
├── docs/wiki/                    # Wiki source pages (checked into repo)
│   ├── Home.md
│   ├── Playwright-Setup.md
│   ├── Devin-Browser-Control.md
│   └── Playwright-Report.md      # Auto-generated after each run
└── playwright.config.ts          # Playwright configuration
```

## How It Works

### Automated E2E Tests (CI/headless)
1. **Run tests** -- `yarn e2e` executes Playwright against the Rails app.
2. **Auto-capture** -- Every test automatically records all HTTP URLs visited and takes full-page screenshots (via the `url-tracker` fixture).
3. **Generate report** -- `yarn e2e:report` reads `test-results/` and produces a Markdown report with a URL table and screenshot gallery.
4. **Sync to wiki** -- `./scripts/sync-wiki.sh` pushes the report to the GitHub wiki for team-wide access.

### Devin-Controlled Browser (interactive)
1. **Invoke a skill** -- Use `/browser-recorder` or `/browser-test` in Devin.
2. **Devin drives the browser** -- Via the Playwright MCP server, Devin navigates pages, clicks elements, fills forms, and captures everything.
3. **Artifacts saved** -- Screenshots, accessibility snapshots, network logs, and console logs are saved to `test-results/`.
4. **Report generated** -- The wiki report is updated automatically.

## Quick Start

```bash
# Run all E2E tests and generate the report
yarn e2e:full

# Record a session using the standalone script
yarn record

# View the HTML report in a browser
yarn e2e:show

# Push the report to the GitHub wiki
./scripts/sync-wiki.sh
```

### Using Devin Skills

```bash
# Interactive recording — Devin controls the browser and you tell it what to do
/browser-recorder http://localhost:3000

# Full regression walkthrough — Devin visits every page automatically
/browser-test
```
