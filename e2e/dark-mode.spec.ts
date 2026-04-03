import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, ADMIN_USER } from "./helpers/auth-helper";

test.describe("Dark Mode", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await waitForPageReady(page);
  });

  test("toggle switches to dark mode and back", async ({ page }) => {
    const html = page.locator("html");

    // Start in light mode (or whatever default)
    const toggleBtn = page.locator("button", { hasText: /🌙|☀️/ });
    await expect(toggleBtn).toBeVisible();

    // Switch to dark
    await toggleBtn.click();
    await expect(html).toHaveAttribute("data-theme", "dark");

    // Switch back to light
    await toggleBtn.click();
    await expect(html).toHaveAttribute("data-theme", "light");
  });

  test("dark mode persists across navigation", async ({ page }) => {
    // Enable dark mode
    await page.locator("button", { hasText: /🌙/ }).click();
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");

    // Navigate to another page
    await page.goto("/job_listings");
    await waitForPageReady(page);

    // Dark mode should persist (via localStorage)
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
  });

  test("skip-to-content link exists", async ({ page }) => {
    const skipLink = page.locator("a.skip-link");
    await expect(skipLink).toHaveCount(1);
    await expect(skipLink).toHaveAttribute("href", "#main-content");
  });

  test("sidebar has aria-label for accessibility", async ({ page }) => {
    const sidebar = page.locator("aside.sidebar");
    await expect(sidebar).toHaveAttribute("aria-label", "Main navigation");
  });

  test("notification bell has aria-label", async ({ page }) => {
    const bell = page.locator("button[aria-label='Notifications']");
    await expect(bell).toBeVisible();
  });
});
