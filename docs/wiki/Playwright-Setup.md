# Playwright E2E Testing Setup

## Prerequisites

- **Node.js** >= 18
- **Yarn** >= 1.22
- **Ruby** + **Rails 8** (for the test server)
- **PostgreSQL** running locally

## Installation

```bash
# Install npm dependencies (includes @playwright/test)
yarn install

# Install Playwright browsers (Chromium)
npx playwright install chromium
```

## Configuration

The Playwright config lives in `playwright.config.ts` at the project root.

### Key settings

| Setting | Value | Purpose |
|---------|-------|---------|
| `screenshot` | `"on"` | Captures a screenshot after **every** test |
| `trace` | `"on-first-retry"` | Records a trace on the first retry of a failed test |
| `video` | `"on-first-retry"` | Records video on the first retry |
| `baseURL` | `http://localhost:3000` | Default Rails server URL |
| `webServer.command` | `bundle exec rails server -p 3000 -e test` | Auto-starts the Rails server |

### Browser projects

| Project | Device |
|---------|--------|
| `chromium-desktop` | Desktop Chrome (1280x720) |
| `chromium-mobile` | Pixel 5 (393x851) |

## Running Tests

```bash
# Run all tests headless
yarn e2e

# Run tests with browser visible
yarn e2e:headed

# Open Playwright UI mode (interactive)
yarn e2e:ui

# Run tests and generate the wiki report
yarn e2e:full

# View the HTML report
yarn e2e:show
```

## Custom Fixtures

### URL Tracker (`e2e/fixtures/url-tracker.ts`)

Every test that imports from this fixture automatically:

1. **Records every HTTP response** -- method, URL, status code, and timestamp.
2. **Takes a full-page screenshot** at the end of the test.
3. **Appends to `test-results/url-log.json`** -- a cumulative JSON log of all URLs visited across all tests.

Usage in a test:

```typescript
import { test, expect } from "../fixtures/url-tracker";

test("example", async ({ page, urlTracker }) => {
  await page.goto("/");

  // urlTracker.entries contains all captured requests
  expect(urlTracker.entries.length).toBeGreaterThan(0);
});
```

### Screenshot Helper (`e2e/helpers/screenshot-helper.ts`)

Utility functions for capturing intermediate screenshots:

```typescript
import { captureScreenshot, waitForPageReady } from "../helpers/screenshot-helper";

// Take a named screenshot at any point
await captureScreenshot(page, "my-descriptive-name");

// Wait for the page to fully load
await waitForPageReady(page);
```

## Report Generation

After running tests, generate a Markdown report:

```bash
yarn e2e:report
```

This reads `test-results/url-log.json` and `test-results/screenshots/` to produce
`docs/wiki/Playwright-Report.md` containing:

- **Test summary** -- pass/fail counts and duration
- **Captured URLs table** -- deduplicated list of all endpoints hit
- **Screenshot gallery** -- every captured screenshot with labels
- **Full URL log** -- collapsible raw JSON log

## Syncing to GitHub Wiki

```bash
# Auto-detect repo from git remote
./scripts/sync-wiki.sh

# Or specify the repo explicitly
./scripts/sync-wiki.sh owner/job_agent_app
```

This clones the wiki repo, copies report files + screenshots, commits, and pushes.

## CI Integration

Add to `.github/workflows/ci.yml`:

```yaml
e2e:
  runs-on: ubuntu-latest
  services:
    postgres:
      image: postgres:16
      env:
        POSTGRES_PASSWORD: postgres
      ports:
        - 5432:5432
  steps:
    - uses: actions/checkout@v4
    - uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
    - uses: actions/setup-node@v4
      with:
        node-version: 20
        cache: yarn
    - run: yarn install
    - run: npx playwright install chromium --with-deps
    - run: bin/rails db:create db:schema:load RAILS_ENV=test
    - run: yarn e2e:full
    - uses: actions/upload-artifact@v4
      if: always()
      with:
        name: playwright-results
        path: |
          test-results/
          e2e/reports/
          docs/wiki/Playwright-Report.md
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `browserType.launch: Executable doesn't exist` | Run `npx playwright install chromium` |
| Tests fail with connection refused | Ensure Rails server starts: `bin/rails server -p 3000 -e test` |
| Screenshots are blank | Check that `webServer.url` in config matches the health endpoint |
| SSL certificate errors during install | Set `NODE_TLS_REJECT_UNAUTHORIZED=0` for the install command only |
