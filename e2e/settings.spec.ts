import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Settings", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
    await page.goto("/settings/edit");
    await waitForPageReady(page);
  });

  test("shows automations and notifications sections", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Automations");
    await expect(page.locator("body")).toContainText("Email Notifications");
  });

  test("auto-apply toggle and threshold are visible", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Auto-Apply to Easy Apply Jobs");
    await expect(page.getByLabel("Minimum Match Score")).toBeVisible();
    await expect(page.getByRole("button", { name: "Save Automations" })).toBeVisible();
  });

  test("email notification toggles are present", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Scan Completed");
    await expect(page.locator("body")).toContainText("New Matches");
    await expect(page.locator("body")).toContainText("Application Status");
    await expect(page.locator("body")).toContainText("Interventions");
    await expect(page.getByRole("button", { name: "Save Notifications" })).toBeVisible();
  });

  test("match threshold accepts valid values", async ({ page }) => {
    const input = page.getByLabel("Minimum Match Score");
    await input.fill("90");
    await expect(input).toHaveValue("90");
  });
});
