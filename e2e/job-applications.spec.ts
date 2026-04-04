import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Job Applications", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
  });

  test("list view shows applications with count", async ({ page }) => {
    await page.goto("/job_applications");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("applications");
    await expect(page.getByRole("link", { name: /All \(\d+\)/ })).toBeVisible();
  });

  test("pipeline board shows columns with cards", async ({ page }) => {
    await page.goto("/job_applications/board");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Pipeline Board");
    // Verify key pipeline stages exist
    await expect(page.locator("body")).toContainText("Applied");
    await expect(page.locator("body")).toContainText("Screening");
    await expect(page.locator("body")).toContainText("Interviewing");
    await expect(page.locator("body")).toContainText("Offered");
    await expect(page.locator("body")).toContainText("Rejected");
  });

  test("board has draggable application cards", async ({ page }) => {
    await page.goto("/job_applications/board");
    await waitForPageReady(page);
    // At least one card should exist (we have 6 applications)
    const cards = page.locator("[draggable=true]");
    expect(await cards.count()).toBeGreaterThanOrEqual(1);
  });

  test("table view link is visible on board", async ({ page }) => {
    await page.goto("/job_applications/board");
    await waitForPageReady(page);
    await expect(page.getByRole("link", { name: "Table View" })).toBeVisible();
  });

  test("clicking application card navigates to detail", async ({ page }) => {
    await page.goto("/job_applications/board");
    await waitForPageReady(page);
    const cardLink = page.locator("[draggable=true] a").first();
    await cardLink.click();
    await waitForPageReady(page);
    await expect(page).toHaveURL(/\/job_applications\/\d+/);
  });
});
