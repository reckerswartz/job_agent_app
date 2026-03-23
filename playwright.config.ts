import { defineConfig, devices } from "@playwright/test";

/**
 * Playwright configuration for Job Agent App.
 *
 * - Captures full-page screenshots on every test (pass or fail).
 * - Records all navigated URLs via the shared url-tracker fixture.
 * - Outputs HTML + JSON reports and screenshot artifacts.
 *
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: "./e2e",
  outputDir: "./test-results",

  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,

  /* Retry failed tests once on CI */
  retries: process.env.CI ? 1 : 0,

  /* Limit parallel workers on CI to avoid resource contention */
  workers: process.env.CI ? 2 : undefined,

  /* Reporters: HTML for local review, JSON for the wiki report generator */
  reporter: [
    ["html", { open: "never", outputFolder: "e2e/reports/html" }],
    ["json", { outputFile: "e2e/reports/results.json" }],
    ["list"],
  ],

  /* Shared settings for all projects */
  use: {
    baseURL: process.env.BASE_URL || "http://localhost:3000",
    /* Capture screenshot after EVERY test (pass or fail) */
    screenshot: "on",
    /* Record trace on first retry so failures are easy to debug */
    trace: "on-first-retry",
    /* Record video on first retry */
    video: "on-first-retry",
  },

  /* Browser projects ---------------------------------------------------- */
  projects: [
    {
      name: "chromium-desktop",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "chromium-mobile",
      use: { ...devices["Pixel 5"] },
    },
  ],

  /* Start the Rails dev server before tests if not already running */
  webServer: {
    command: "bundle exec rails server -p 3000 -e test",
    url: "http://localhost:3000/up",
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
    stdout: "pipe",
    stderr: "pipe",
  },
});
