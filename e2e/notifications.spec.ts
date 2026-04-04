import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Notifications", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
  });

  test("bell dropdown shows unread count", async ({ page }) => {
    const bell = page.getByRole("button", { name: "Notifications" });
    await expect(bell).toBeVisible();
    // Badge with unread count should be present
    await expect(page.locator(".badge.bg-danger")).toBeVisible();
  });

  test("bell dropdown opens and shows notifications", async ({ page }) => {
    await page.getByRole("button", { name: "Notifications" }).click();
    await expect(page.locator("body")).toContainText("Notifications");
    await expect(page.getByRole("link", { name: "View all notifications" })).toBeVisible();
  });

  test("notifications page shows list with timestamps", async ({ page }) => {
    await page.goto("/notifications");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Notifications");
    await expect(page.locator("body")).toContainText("total");
    // Should have actual notification rows
    await expect(page.locator("table tbody tr").first()).toBeVisible();
  });

  test("notifications include scan and application categories", async ({ page }) => {
    await page.goto("/notifications");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Scan completed");
    await expect(page.locator("body")).toContainText("Application submitted");
  });
});
