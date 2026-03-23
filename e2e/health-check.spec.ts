import { test, expect } from "./fixtures/url-tracker";
import { captureScreenshot } from "./helpers/screenshot-helper";

test.describe("Health check", () => {
  test("GET /up returns 200", async ({
    page,
    urlTracker,
  }) => {
    const response = await page.goto("/up");
    await page.waitForLoadState("domcontentloaded");

    // Rails health check returns 200 when the app is healthy
    expect(response?.status()).toBe(200);
    await captureScreenshot(page, "health-check-up");

    // Confirm the health endpoint was captured in the URL tracker
    const healthEntry = urlTracker.entries.find((e) => e.url.includes("/up"));
    expect(healthEntry).toBeDefined();
    expect(healthEntry!.status).toBe(200);
  });
});
