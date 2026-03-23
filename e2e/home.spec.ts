import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady, captureScreenshot } from "./helpers/screenshot-helper";

test.describe("Home page", () => {
  test("shows the welcome heading and captures the landing state", async ({
    page,
    urlTracker,
  }) => {
    await page.goto("/");
    await waitForPageReady(page);

    // Verify the page rendered correctly
    await expect(page.locator("h1")).toContainText("Job Agent App");
    await expect(page.locator("#home-page")).toBeVisible();

    // Capture an intermediate screenshot with a descriptive name
    await captureScreenshot(page, "home-page-loaded");

    // Verify URLs were tracked
    expect(urlTracker.entries.length).toBeGreaterThan(0);

    const navEntry = urlTracker.entries.find((e) => e.url.endsWith("/"));
    expect(navEntry).toBeDefined();
    expect(navEntry!.status).toBe(200);
  });

  test("page has correct title", async ({ page, urlTracker }) => {
    await page.goto("/");
    await waitForPageReady(page);

    await expect(page).toHaveTitle(/Job Agent App/i);
  });
});
