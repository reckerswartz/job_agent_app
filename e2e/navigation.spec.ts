import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady, captureScreenshot } from "./helpers/screenshot-helper";

test.describe("Navigation & URL tracking", () => {
  test("navigating between pages records all URLs", async ({
    page,
    urlTracker,
  }) => {
    // Visit the home page
    await page.goto("/");
    await waitForPageReady(page);
    await captureScreenshot(page, "nav-step-1-home");

    // Navigate to health check
    await page.goto("/up");
    await waitForPageReady(page);
    await captureScreenshot(page, "nav-step-2-health");

    // Return to home
    await page.goto("/");
    await waitForPageReady(page);
    await captureScreenshot(page, "nav-step-3-home-return");

    // Verify all navigations were tracked
    const pageNavs = urlTracker.entries.filter(
      (e) => e.method === "GET" && (e.url.endsWith("/") || e.url.includes("/up"))
    );
    expect(pageNavs.length).toBeGreaterThanOrEqual(3);
  });
});
