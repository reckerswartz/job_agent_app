import { test as base, Page } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

/* ------------------------------------------------------------------ */
/*  Types                                                              */
/* ------------------------------------------------------------------ */

export interface UrlEntry {
  /** ISO-8601 timestamp */
  timestamp: string;
  /** The test title chain (e.g. "Home page > shows welcome heading") */
  test: string;
  /** HTTP method inferred from the navigation (always GET for page navs) */
  method: string;
  /** Full URL visited */
  url: string;
  /** HTTP status code returned */
  status: number;
}

export interface UrlTracker {
  /** All URL entries captured in the current test */
  entries: UrlEntry[];
}

/* ------------------------------------------------------------------ */
/*  Constants                                                          */
/* ------------------------------------------------------------------ */

const RESULTS_DIR = path.resolve(__dirname, "../../test-results");
const SCREENSHOTS_DIR = path.join(RESULTS_DIR, "screenshots");
const URL_LOG_PATH = path.join(RESULTS_DIR, "url-log.json");

/* ------------------------------------------------------------------ */
/*  Extended test fixture                                              */
/* ------------------------------------------------------------------ */

/**
 * Custom Playwright `test` that:
 *  1. Intercepts every response to record the URL + status.
 *  2. Takes a full-page screenshot after every test step.
 *  3. Persists the aggregated URL log as JSON for reporting.
 */
export const test = base.extend<{ urlTracker: UrlTracker }>({
  urlTracker: async ({ page }, use, testInfo) => {
    const entries: UrlEntry[] = [];
    const testTitle = testInfo.titlePath.join(" > ");

    /* --- Listen to every server response --- */
    page.on("response", (response) => {
      entries.push({
        timestamp: new Date().toISOString(),
        test: testTitle,
        method: response.request().method(),
        url: response.url(),
        status: response.status(),
      });
    });

    /* --- Provide the tracker to the test --- */
    await use({ entries });

    /* --- After the test: persist screenshot + URL log --- */
    fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });

    // Screenshot naming: <project>--<test-file>--<test-title>.png
    const safeName = testTitle.replace(/[^a-zA-Z0-9]+/g, "-").replace(/-+$/, "");
    const project = testInfo.project.name;
    const screenshotFile = `${project}--${safeName}.png`;
    const screenshotPath = path.join(SCREENSHOTS_DIR, screenshotFile);

    await page.screenshot({ path: screenshotPath, fullPage: true });
    testInfo.attachments.push({
      name: "full-page-screenshot",
      contentType: "image/png",
      path: screenshotPath,
    });

    /* --- Append to the cumulative URL log --- */
    let existing: UrlEntry[] = [];
    if (fs.existsSync(URL_LOG_PATH)) {
      try {
        existing = JSON.parse(fs.readFileSync(URL_LOG_PATH, "utf-8"));
      } catch {
        existing = [];
      }
    }
    fs.writeFileSync(URL_LOG_PATH, JSON.stringify([...existing, ...entries], null, 2));
  },
});

export { expect } from "@playwright/test";
