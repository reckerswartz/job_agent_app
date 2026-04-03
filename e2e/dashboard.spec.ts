import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, ADMIN_USER } from "./helpers/auth-helper";

test.describe("User Dashboard", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
  });

  test("shows stat cards", async ({ page }) => {
    await expect(page.locator(".stat-card")).toHaveCount(4);
    await expect(page.locator("body")).toContainText("Jobs Found");
    await expect(page.locator("body")).toContainText("High Matches");
    await expect(page.locator("body")).toContainText("Applied");
    await expect(page.locator("body")).toContainText("Needs Attention");
  });

  test("shows recent job listings section", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Recent Job Listings");
  });

  test("shows recent activity section", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Recent Activity");
  });

  test("sidebar navigation links are visible", async ({ page }) => {
    await expect(page.getByRole("link", { name: /Dashboard/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Job Sources/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Job Listings/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Applications/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Analytics/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Profile/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Settings/ })).toBeVisible();
  });

  test("dark mode toggle works", async ({ page }) => {
    const toggleBtn = page.locator("button", { hasText: /🌙|☀️/ });
    await expect(toggleBtn).toBeVisible();
    await toggleBtn.click();
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
    await toggleBtn.click();
    await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
  });
});
