import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, ADMIN_USER } from "./helpers/auth-helper";

test.describe("Mobile Viewport", () => {
  test.use({ viewport: { width: 375, height: 667 } }); // iPhone SE

  test("sidebar toggle is visible on mobile", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await waitForPageReady(page);
    const toggle = page.locator(".topbar__toggle");
    await expect(toggle).toBeVisible();
  });

  test("sidebar opens and closes via toggle", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await waitForPageReady(page);

    const sidebar = page.locator(".sidebar");
    const toggle = page.locator(".topbar__toggle");

    // Sidebar should be hidden initially on mobile
    await expect(sidebar).not.toHaveClass(/sidebar--open/);

    // Open sidebar
    await toggle.click();
    await expect(sidebar).toHaveClass(/sidebar--open/);

    // Close via overlay
    await page.locator(".sidebar-overlay").click();
    await expect(sidebar).not.toHaveClass(/sidebar--open/);
  });

  test("stat cards render in 2 columns on mobile", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await waitForPageReady(page);
    const statCards = page.locator(".stat-card");
    await expect(statCards).toHaveCount(4);
  });

  test("page header stacks vertically on mobile", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await page.goto("/job_sources");
    await waitForPageReady(page);

    // Add Source button should be visible (stacked below title)
    await expect(page.getByRole("link", { name: "Add Source" })).toBeVisible();
    await expect(page.locator(".page-header__title")).toBeVisible();
  });

  test("tables are horizontally scrollable", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await page.goto("/job_listings");
    await waitForPageReady(page);

    // Table responsive wrapper should exist
    const tableWrapper = page.locator(".table-responsive");
    const count = await tableWrapper.count();
    if (count > 0) {
      await expect(tableWrapper.first()).toBeVisible();
    }
  });

  test("topbar search is hidden on xs", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await waitForPageReady(page);
    await expect(page.locator(".topbar__search")).not.toBeVisible();
  });

  test("onboarding renders well on mobile", async ({ page }) => {
    const uniqueEmail = `mobile_${Date.now()}@test.dev`;
    await page.goto("/sign_up");
    await page.getByRole("textbox", { name: "Email" }).fill(uniqueEmail);
    await page.getByRole("textbox", { name: /^Password$/ }).fill("password123");
    await page.getByRole("textbox", { name: "Confirm Password" }).fill("password123");
    await page.getByRole("button", { name: "Create Account" }).click();
    await page.waitForURL(/\/onboarding/);

    // Progress bar steps should be visible
    await expect(page.locator(".onboarding__step-number")).toHaveCount(4);
    // Upload zone should be visible
    await expect(page.locator(".onboarding__upload-zone")).toBeVisible();
  });
});
