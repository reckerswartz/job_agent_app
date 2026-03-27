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
    await expect(page.locator("h1")).toContainText("Find Your Next Role");
    await expect(page.locator(".home-page")).toBeVisible();

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

  test("shows sign in and sign up links", async ({ page }) => {
    await page.goto("/");
    await waitForPageReady(page);

    await expect(page.getByRole("link", { name: "Sign In" })).toBeVisible();
    await expect(page.getByRole("link", { name: "Sign Up" })).toBeVisible();
  });

  test("Get Started links to dashboard", async ({ page }) => {
    await page.goto("/");
    await waitForPageReady(page);

    const getStarted = page.getByRole("link", { name: "Get Started" });
    await expect(getStarted).toBeVisible();
    await expect(getStarted).toHaveAttribute("href", "/dashboard");
  });
});
