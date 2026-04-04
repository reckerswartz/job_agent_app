import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Job Listings", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
    await page.goto("/job_listings");
    await waitForPageReady(page);
  });

  test("shows listing count and table with data", async ({ page }) => {
    await expect(page.locator("body")).toContainText("listings found");
    await expect(page.locator("table")).toBeVisible();
    const rows = page.locator("table tbody tr");
    expect(await rows.count()).toBeGreaterThanOrEqual(1);
  });

  test("has status filter tabs", async ({ page }) => {
    await expect(page.getByRole("link", { name: /All \(\d+\)/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /New \(\d+\)/ })).toBeVisible();
    await expect(page.getByRole("link", { name: /Applied \(\d+\)/ })).toBeVisible();
  });

  test("status tab filters listings", async ({ page }) => {
    await page.getByRole("link", { name: /New \(\d+\)/ }).click();
    await waitForPageReady(page);
    await expect(page).toHaveURL(/status=new/);
    const badges = page.locator("table tbody .badge");
    for (const badge of await badges.all()) {
      await expect(badge).toHaveText("New");
    }
  });

  test("collapsible filter panel toggles", async ({ page }) => {
    const filterBtn = page.getByRole("button", { name: /Filters/ });
    await expect(filterBtn).toBeVisible();
    // Filters should be collapsed by default
    await expect(page.locator("#advancedFilters")).not.toBeVisible();
    // Click to expand
    await filterBtn.click();
    await expect(page.locator("#advancedFilters")).toBeVisible();
    await expect(page.getByRole("button", { name: "Filter" })).toBeVisible();
  });

  test("search filters by company name", async ({ page }) => {
    await page.getByPlaceholder("Search by title, company, or location...").fill("Shopify");
    await page.getByRole("button", { name: "Search" }).click();
    await waitForPageReady(page);
    await expect(page.locator("table")).toContainText("Shopify");
  });

  test("export CSV link is visible", async ({ page }) => {
    await expect(page.getByRole("link", { name: "Export CSV" })).toBeVisible();
  });

  test("clicking listing navigates to detail page", async ({ page }) => {
    const firstLink = page.locator("table tbody tr td a").first();
    const title = await firstLink.textContent();
    await firstLink.click();
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText(title!.trim());
  });
});
