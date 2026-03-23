---
name: browser-test
description: Walk through all app pages, record behavior, and produce a regression baseline
argument-hint: "[base-url]"
allowed-tools:
  - read
  - edit
  - exec
  - grep
  - glob
  - mcp__playwright__browser_navigate
  - mcp__playwright__browser_snapshot
  - mcp__playwright__browser_take_screenshot
  - mcp__playwright__browser_network_requests
  - mcp__playwright__browser_console_messages
  - mcp__playwright__browser_click
  - mcp__playwright__browser_type
  - mcp__playwright__browser_fill_form
  - mcp__playwright__browser_press_key
  - mcp__playwright__browser_hover
  - mcp__playwright__browser_select_option
  - mcp__playwright__browser_navigate_back
  - mcp__playwright__browser_resize
  - mcp__playwright__browser_evaluate
  - mcp__playwright__browser_run_code
  - mcp__playwright__browser_close
  - mcp__playwright__browser_wait
  - mcp__playwright__browser_tab_list
  - mcp__playwright__browser_tab_new
  - mcp__playwright__browser_tab_select
  - mcp__playwright__browser_tab_close
  - mcp__playwright__browser_drag
  - mcp__playwright__browser_file_upload
  - mcp__playwright__browser_handle_dialog
permissions:
  allow:
    - mcp__playwright__*
    - Exec(mkdir *)
    - Exec(node *)
    - Exec(bundle exec *)
    - Exec(bin/rails *)
    - Write(test-results/**)
    - Write(e2e/**)
    - Write(docs/wiki/**)
    - Read(**)
triggers:
  - user
  - model
---

# Browser Test — Full App Walkthrough

You are a **regression testing agent**. Your job is to systematically walk
through every page of the Job Agent App, interact with key UI elements, and
record a complete baseline of behavior for change tracking.

## Setup

The base URL is `$1` or `http://localhost:3000` if not provided.

Before starting:

```bash
mkdir -p test-results/screenshots test-results/recordings
```

Clear any previous recording session:

```bash
rm -f test-results/recordings/session-log.json
```

## Test plan

Walk through the following pages in order. On **every** page:

1. `browser_navigate` to the URL
2. `browser_snapshot` → save to `test-results/recordings/<name>-snapshot.md`
3. `browser_take_screenshot` → save to `test-results/screenshots/recording-<name>.png` (fullPage: true)
4. `browser_network_requests` → save to `test-results/recordings/<name>-network.txt` (includeStatic: true)
5. `browser_console_messages` → save to `test-results/recordings/<name>-console.txt` (level: info)
6. Append to `test-results/recordings/session-log.json`

### Pages to test

| Order | Path | Name | Interactions |
|-------|------|------|-------------|
| 1 | `/` | `home` | Verify heading, check page structure |
| 2 | `/up` | `health-check` | Verify 200 response |

After the route table above, also:
- Read `config/routes.rb` to discover any additional routes
- For each additional route found, visit it and record it the same way

### Responsive testing

After completing the desktop walkthrough, resize the browser to mobile
(393x851) using `browser_resize` and revisit the home page:

| Order | Name | Width | Height |
|-------|------|-------|--------|
| 1 | `home-mobile` | 393 | 851 |

Capture screenshot + snapshot for the mobile view.

## After the walkthrough

1. Generate the wiki report:

```bash
node scripts/generate-report.js --output docs/wiki/Playwright-Report.md
```

2. Provide a summary table:

| Page | Status | Screenshot | Snapshot | Issues |
|------|--------|------------|----------|--------|
| home | ✓/✗ | path | path | any problems |
| ... | | | | |

3. Report any:
   - Console errors or warnings
   - Failed network requests (non-2xx)
   - Missing page elements
   - Visual anomalies

## Important rules

- ALWAYS get a `browser_snapshot` before trying to click or interact with
  elements — you need the element refs.
- Capture EVERYTHING on every page, even if it seems redundant.
- If a page returns a non-200 status, still record it (the error state is
  valuable for regression tracking).
- If the Rails server is not running, start it first:
  `bundle exec rails server -p 3000 -e development -d` or remind the user.
