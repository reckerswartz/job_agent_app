import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, ADMIN_USER } from "./helpers/auth-helper";

test.describe("Admin Section", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
  });

  test("admin sidebar shows Configuration and Monitoring groups", async ({ page }) => {
    await expect(page.locator("body")).toContainText("Configuration");
    await expect(page.locator("body")).toContainText("Monitoring");
    await expect(page.getByRole("link", { name: /API Keys/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /LLM Models/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /LLM Logs/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Scan Monitor/ })).toBeVisible();
  });

  test("admin dashboard shows system stats", async ({ page }) => {
    await page.goto("/admin");
    await waitForPageReady(page);
    await expect(page.locator(".stat-card")).toHaveCount(6);
    await expect(page.locator("body")).toContainText("Users");
    await expect(page.locator("body")).toContainText("Listings");
    await expect(page.locator("body")).toContainText("LLM Calls");
  });

  test("admin users page has search and sortable headers", async ({ page }) => {
    await page.goto("/admin/users");
    await waitForPageReady(page);
    await expect(page.getByPlaceholder("Search by email")).toBeVisible();
    await expect(page.locator("th").filter({ hasText: "Email" })).toBeVisible();
    await expect(page.locator("th").filter({ hasText: "Role" })).toBeVisible();
  });

  test("admin API keys page shows provider status", async ({ page }) => {
    await page.goto("/admin/api_keys");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("API Keys");
    await expect(page.getByRole("button", { name: /Test Connection/ })).toBeVisible();
  });

  test("admin LLM models page has filter tabs and action buttons", async ({ page }) => {
    await page.goto("/admin/llm_models");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("LLM Model Configuration");
    await expect(page.getByRole("link", { name: /Active/ })).toBeVisible();
    await expect(page.getByRole("button", { name: /Sync Models/ })).toBeVisible();
    await expect(page.getByRole("button", { name: /Verify All/ })).toBeVisible();
  });
});
