import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Analytics", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
    await page.goto("/analytics");
    await waitForPageReady(page);
  });

  test("shows analytics heading and chart sections", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Analytics");
    await expect(page.locator("body")).toContainText("Listings Over Time");
    await expect(page.locator("body")).toContainText("Match Score Distribution");
    await expect(page.locator("body")).toContainText("Scan Success Rate");
  });

  test("charts render with data (not empty state)", async ({ page }) => {
    // Should NOT show empty state since demo user has listings
    await expect(page.locator("body")).not.toContainText("No analytics data yet");
  });

  test("scan success rate shows percentage", async ({ page }) => {
    // The scan success rate card should show a percentage
    await expect(page.locator("body")).toContainText("%");
    await expect(page.locator("body")).toContainText("total scans");
  });

  test("salary and source charts are present", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Salary Distribution");
    await expect(page.locator("body")).toContainText("Listings by Source");
    await expect(page.locator("body")).toContainText("Top Companies");
  });
});
