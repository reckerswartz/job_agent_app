import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Interventions", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
    await page.goto("/interventions");
    await waitForPageReady(page);
  });

  test("shows interventions heading with filter tabs", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Interventions");
    await expect(page.getByRole("link", { name: /All \(\d+\)/ })).toBeVisible();
  });

  test("sidebar badge shows pending count", async ({ page }) => {
    const sidebarLink = page.getByRole("link", { name: /Interventions/ });
    await expect(sidebarLink).toBeVisible();
    // Should have a badge with count
    await expect(sidebarLink.locator(".sidebar__badge, .badge")).toBeVisible();
  });

  test("pending intervention is displayed", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Login required");
  });

  test("intervention detail page loads", async ({ page }) => {
    const link = page.locator("table tbody tr a, .card a").first();
    if (await link.isVisible()) {
      await link.click();
      await waitForPageReady(page);
      await expect(page).toHaveURL(/\/interventions\/\d+/);
    }
  });
});
