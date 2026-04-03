import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";

test.describe("Onboarding Wizard", () => {
  test.beforeEach(async ({ page }) => {
    const uniqueEmail = `onboard_${Date.now()}@test.dev`;
    await page.goto("/sign_up");
    await page.getByRole("textbox", { name: "Email" }).fill(uniqueEmail);
    await page.getByRole("textbox", { name: /^Password$/ }).fill("password123");
    await page.getByRole("textbox", { name: "Confirm Password" }).fill("password123");
    await page.getByRole("button", { name: "Create Account" }).click();
    await page.waitForURL(/\/onboarding/);
  });

  test("step 1: resume upload page renders with progress bar", async ({ page }) => {
    await expect(page.locator("body")).toContainText("start with your resume");
    await expect(page.locator(".onboarding__step-number")).toHaveCount(4);
    await expect(page.locator(".onboarding__upload-zone")).toBeVisible();
  });

  test("skip resume goes to profile step", async ({ page }) => {
    await page.getByText("I'll do this later").click();
    await expect(page).toHaveURL(/step=profile/);
    await expect(page.locator("body")).toContainText("Review your profile");
  });

  test("skip profile goes to source step", async ({ page }) => {
    await page.getByText("I'll do this later").click();
    await page.waitForURL(/step=profile/);
    await page.getByText("Skip for now").click();
    await expect(page).toHaveURL(/step=source/);
    await expect(page.locator("body")).toContainText("Where should we look for jobs");
  });

  test("source step shows platform cards", async ({ page }) => {
    await page.goto(page.url().split("?")[0] + "?step=source");
    await waitForPageReady(page);
    await expect(page.locator(".onboarding__platform-card")).toHaveCount(3);
    await expect(page.locator("body")).toContainText("LinkedIn");
    await expect(page.locator("body")).toContainText("Indeed");
    await expect(page.locator("body")).toContainText("Naukri");
  });

  test("complete step shows Go to Dashboard button", async ({ page }) => {
    await page.goto(page.url().split("?")[0] + "?step=complete");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("all set");
    await expect(page.getByRole("button", { name: /Dashboard/ })).toBeVisible();
  });
});
