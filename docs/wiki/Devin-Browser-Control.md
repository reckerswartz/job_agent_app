# Devin Browser Control via Playwright MCP

Devin can directly control a real browser through the **Playwright MCP server**.
This enables interactive recording sessions, regression testing, and behavior
capture without writing test code.

## Architecture

```
┌──────────────┐     MCP Protocol      ┌─────────────────────┐
│   Devin CLI  │ ◄──────────────────► │  Playwright MCP     │
│              │    (tool calls)       │  Server              │
│  Skills:     │                       │                      │
│  - recorder  │                       │  Controls:           │
│  - test      │                       │  - Chromium browser  │
└──────────────┘                       │  - Screenshots       │
       │                               │  - Snapshots         │
       │ saves artifacts               │  - Network capture   │
       ▼                               └─────────────────────┘
┌──────────────┐
│ test-results/│
│  screenshots/│
│  recordings/ │
│  url-log.json│
└──────────────┘
       │
       │ generate-report.js
       ▼
┌──────────────┐
│ docs/wiki/   │
│  Report.md   │ ──► GitHub Wiki
└──────────────┘
```

## Configuration

### MCP Server (`.devin/config.json`)

The Playwright MCP server is configured at the project level:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {}
    }
  },
  "permissions": {
    "allow": [
      "mcp__playwright__browser_navigate",
      "mcp__playwright__browser_snapshot",
      "mcp__playwright__browser_take_screenshot",
      "mcp__playwright__browser_network_requests",
      "mcp__playwright__browser_console_messages",
      "mcp__playwright__browser_click",
      "..."
    ]
  }
}
```

All Playwright MCP tools are pre-approved so Devin can drive the browser
without prompting for each action.

## Available Playwright MCP Tools

### Navigation
| Tool | Description |
|------|-------------|
| `browser_navigate` | Go to a URL |
| `browser_navigate_back` | Go back in history |
| `browser_tab_new` | Open a new tab |
| `browser_tab_select` | Switch to a tab |
| `browser_tab_close` | Close a tab |
| `browser_tab_list` | List open tabs |

### Capture & Inspect
| Tool | Description |
|------|-------------|
| `browser_take_screenshot` | Capture screenshot (full page, element, or viewport) |
| `browser_snapshot` | Accessibility tree snapshot (get element refs for interactions) |
| `browser_network_requests` | All HTTP requests since page load |
| `browser_console_messages` | Browser console log |

### Interaction
| Tool | Description |
|------|-------------|
| `browser_click` | Click an element (by ref from snapshot) |
| `browser_type` | Type text into an element |
| `browser_fill_form` | Fill multiple form fields at once |
| `browser_press_key` | Press a keyboard key |
| `browser_hover` | Hover over an element |
| `browser_select_option` | Select a dropdown option |
| `browser_drag` | Drag and drop |
| `browser_file_upload` | Upload a file |
| `browser_handle_dialog` | Accept/dismiss alert/confirm dialogs |

### Advanced
| Tool | Description |
|------|-------------|
| `browser_evaluate` | Run JavaScript on the page |
| `browser_run_code` | Run a Playwright code snippet |
| `browser_resize` | Change viewport size |
| `browser_wait` | Wait for a condition |

## Devin Skills

### `/browser-recorder` — Interactive Recording

Use this skill when you want to **manually direct Devin** through the app.

```
/browser-recorder http://localhost:3000
```

Then tell Devin what to do:
- "Navigate to the login page"
- "Fill in the email field with test@example.com"
- "Click the submit button"
- "Take a screenshot of the dashboard"

Devin will execute each action via the Playwright MCP and automatically capture:
- Full-page screenshots
- Accessibility snapshots
- Network request logs
- Console messages
- A session log (`test-results/recordings/session-log.json`)

### `/browser-test` — Automated Regression Walkthrough

Use this skill for a **hands-off full walkthrough** of all app pages.

```
/browser-test
```

Devin will:
1. Read `config/routes.rb` to discover all routes
2. Visit each page in both desktop and mobile viewports
3. Capture everything on each page
4. Generate the wiki report
5. Report any issues (console errors, failed requests, missing elements)

## Standalone Script

For CI or non-interactive use, the recording script can be run directly:

```bash
# Record against the local dev server
yarn record

# Record against a specific URL
node scripts/record-session.js --base-url https://staging.example.com
```

## Workflow Example

### Regression Testing Before a Deploy

```bash
# 1. Start the Rails server
bin/rails server -p 3000

# 2. Record a baseline (in another terminal, or ask Devin)
/browser-test

# 3. Make your code changes...

# 4. Record again after changes
/browser-test

# 5. Compare screenshots visually or diff the session logs
diff test-results/recordings/session-log-before.json test-results/recordings/session-log-after.json
```

### Capturing a Bug Report

```
/browser-recorder http://localhost:3000

> Navigate to /users/new
> Fill the form with name "Test User" and email "bad-email"
> Click submit
> Take a screenshot of the error state
```

Devin captures everything — screenshots, network requests, console errors —
which you can attach to a bug report.

## Output Files

| File | Content |
|------|---------|
| `test-results/screenshots/recording-*.png` | Full-page screenshots |
| `test-results/recordings/*-snapshot.md` | Accessibility tree snapshots |
| `test-results/recordings/*-network.txt` | Network request logs |
| `test-results/recordings/*-console.txt` | Console message logs |
| `test-results/recordings/session-log.json` | Cumulative session log |
| `docs/wiki/Playwright-Report.md` | Generated Markdown report |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Playwright MCP server not found" | Ensure `.devin/config.json` has the `mcpServers.playwright` entry |
| Browser doesn't launch | Run `npx playwright install chromium` |
| Permission prompts for every action | Check that `permissions.allow` includes `mcp__playwright__*` patterns |
| Screenshots are blank or wrong | Ensure the Rails server is running on the expected port |
| Devin can't find element refs | Always call `browser_snapshot` before `browser_click` or `browser_type` |
