#!/usr/bin/env node

/**
 * record-session.js
 *
 * Standalone script to record a browser session using Playwright.
 * Visits every known route, captures screenshots, snapshots, and network logs.
 *
 * Usage:
 *   node scripts/record-session.js [--base-url http://localhost:3000]
 *
 * This complements the Devin MCP-based recording by providing a scriptable
 * alternative that can run in CI or be triggered manually.
 */

const { chromium } = require("playwright");
const fs = require("fs");
const path = require("path");

/* ------------------------------------------------------------------ */
/*  Config                                                             */
/* ------------------------------------------------------------------ */

const baseUrlArg = process.argv.indexOf("--base-url");
const BASE_URL =
  baseUrlArg !== -1 && process.argv[baseUrlArg + 1]
    ? process.argv[baseUrlArg + 1]
    : "http://localhost:3000";

const RESULTS_DIR = path.resolve(__dirname, "../test-results");
const SCREENSHOTS_DIR = path.join(RESULTS_DIR, "screenshots");
const RECORDINGS_DIR = path.join(RESULTS_DIR, "recordings");
const SESSION_LOG = path.join(RECORDINGS_DIR, "session-log.json");

/* ------------------------------------------------------------------ */
/*  Routes to test                                                     */
/* ------------------------------------------------------------------ */

const ROUTES = [
  { path: "/", name: "home" },
  { path: "/up", name: "health-check" },
];

const VIEWPORTS = [
  { name: "desktop", width: 1280, height: 720 },
  { name: "mobile", width: 393, height: 851 },
];

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

function ensureDirs() {
  fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });
  fs.mkdirSync(RECORDINGS_DIR, { recursive: true });
}

function appendSessionLog(entry) {
  let existing = [];
  if (fs.existsSync(SESSION_LOG)) {
    try {
      existing = JSON.parse(fs.readFileSync(SESSION_LOG, "utf-8"));
    } catch {
      existing = [];
    }
  }
  existing.push(entry);
  fs.writeFileSync(SESSION_LOG, JSON.stringify(existing, null, 2));
}

/* ------------------------------------------------------------------ */
/*  Main                                                               */
/* ------------------------------------------------------------------ */

async function recordSession() {
  ensureDirs();

  // Clear previous session
  if (fs.existsSync(SESSION_LOG)) fs.unlinkSync(SESSION_LOG);

  console.log(`Recording session against: ${BASE_URL}`);
  console.log(`Routes: ${ROUTES.map((r) => r.path).join(", ")}`);
  console.log(`Viewports: ${VIEWPORTS.map((v) => v.name).join(", ")}`);
  console.log("");

  const browser = await chromium.launch({ headless: true });

  for (const viewport of VIEWPORTS) {
    const context = await browser.newContext({
      viewport: { width: viewport.width, height: viewport.height },
    });
    const page = await context.newPage();

    // Collect network requests
    const networkLog = [];
    page.on("response", (response) => {
      networkLog.push({
        method: response.request().method(),
        url: response.url(),
        status: response.status(),
      });
    });

    // Collect console messages
    const consoleLog = [];
    page.on("console", (msg) => {
      consoleLog.push({
        type: msg.type(),
        text: msg.text(),
      });
    });

    for (const route of ROUTES) {
      const pageName = `${route.name}-${viewport.name}`;
      console.log(`  Visiting ${route.path} (${viewport.name})...`);

      // Clear per-page logs
      networkLog.length = 0;
      consoleLog.length = 0;

      try {
        const response = await page.goto(`${BASE_URL}${route.path}`, {
          waitUntil: "networkidle",
          timeout: 15000,
        });

        const status = response ? response.status() : "unknown";

        // Screenshot
        const screenshotPath = path.join(
          SCREENSHOTS_DIR,
          `recording-${pageName}.png`
        );
        await page.screenshot({ path: screenshotPath, fullPage: true });

        // Accessibility snapshot
        const snapshot = await page.accessibility.snapshot();
        const snapshotPath = path.join(
          RECORDINGS_DIR,
          `${pageName}-snapshot.json`
        );
        fs.writeFileSync(snapshotPath, JSON.stringify(snapshot, null, 2));

        // Network log
        const networkPath = path.join(
          RECORDINGS_DIR,
          `${pageName}-network.json`
        );
        fs.writeFileSync(
          networkPath,
          JSON.stringify(networkLog.slice(), null, 2)
        );

        // Console log
        const consolePath = path.join(
          RECORDINGS_DIR,
          `${pageName}-console.json`
        );
        fs.writeFileSync(
          consolePath,
          JSON.stringify(consoleLog.slice(), null, 2)
        );

        // Session log entry
        appendSessionLog({
          timestamp: new Date().toISOString(),
          url: `${BASE_URL}${route.path}`,
          page: pageName,
          viewport: viewport.name,
          status,
          screenshot: `test-results/screenshots/recording-${pageName}.png`,
          snapshot: `test-results/recordings/${pageName}-snapshot.json`,
          networkRequests: networkLog.length,
          consoleMessages: consoleLog.length,
        });

        const statusIcon = status === 200 ? "✓" : "✗";
        console.log(
          `    ${statusIcon} ${status} — screenshot + snapshot + ${networkLog.length} requests`
        );
      } catch (err) {
        console.error(`    ✗ Error: ${err.message}`);
        appendSessionLog({
          timestamp: new Date().toISOString(),
          url: `${BASE_URL}${route.path}`,
          page: pageName,
          viewport: viewport.name,
          status: "error",
          error: err.message,
        });
      }
    }

    await context.close();
  }

  await browser.close();

  // Generate the report
  console.log("\nGenerating report...");
  require("child_process").execSync(
    "node scripts/generate-report.js --output docs/wiki/Playwright-Report.md",
    { cwd: path.resolve(__dirname, ".."), stdio: "inherit" }
  );

  console.log("\nSession recorded successfully!");
  console.log(`  Screenshots: ${SCREENSHOTS_DIR}`);
  console.log(`  Recordings:  ${RECORDINGS_DIR}`);
  console.log(`  Session log: ${SESSION_LOG}`);
  console.log(`  Wiki report: docs/wiki/Playwright-Report.md`);
}

recordSession().catch((err) => {
  console.error("Recording failed:", err);
  process.exit(1);
});
