import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, ADMIN_USER } from "./helpers/auth-helper";

test.describe("Job Sources", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
  });

  test("job sources page renders with Add Source button", async ({ page }) => {
    await page.goto("/job_sources");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Job Sources");
    await expect(page.getByRole("link", { name: "Add Source" })).toBeVisible();
  });

  test("new source form has platform dropdown", async ({ page }) => {
    await page.goto("/job_sources/new");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Add Job Source");
    await expect(page.getByLabel("Platform")).toBeVisible();
    await expect(page.getByLabel("Source Name")).toBeVisible();
  });
});
