import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, DEMO_USER } from "./helpers/auth-helper";

test.describe("Profile", () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page, DEMO_USER.email, DEMO_USER.password);
  });

  test("show page displays name and headline", async ({ page }) => {
    await page.goto("/profile");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Pankaj Kumar");
    await expect(page.locator("body")).toContainText("Senior Ruby on Rails Developer");
  });

  test("show page has work experience and skills sections", async ({ page }) => {
    await page.goto("/profile");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Work Experience");
    await expect(page.locator("body")).toContainText("Skills");
    await expect(page.locator("body")).toContainText("Education");
  });

  test("extracted text is collapsible", async ({ page }) => {
    await page.goto("/profile");
    await waitForPageReady(page);
    await expect(page.locator("body")).toContainText("Extracted Resume Text");
    // Text should be collapsed by default
    await expect(page.locator("#extractedText")).not.toBeVisible();
    // Click Show/Hide to expand
    await page.getByRole("button", { name: "Show / Hide" }).click();
    await expect(page.locator("#extractedText")).toBeVisible();
  });

  test("edit page has tab navigation", async ({ page }) => {
    await page.goto("/profile/edit");
    await waitForPageReady(page);
    await expect(page.getByRole("tab", { name: "Resume" })).toBeVisible();
    await expect(page.getByRole("tab", { name: "Contact" })).toBeVisible();
    await expect(page.getByRole("tab", { name: "Experience" })).toBeVisible();
    await expect(page.getByRole("tab", { name: "Skills" })).toBeVisible();
  });

  test("contact tab shows pre-filled fields", async ({ page }) => {
    await page.goto("/profile/edit");
    await waitForPageReady(page);
    await page.getByRole("tab", { name: "Contact" }).click();
    await expect(page.getByRole("textbox", { name: "First Name" })).toHaveValue("Pankaj");
    await expect(page.getByRole("textbox", { name: "Last Name" })).toHaveValue("Kumar");
  });

  test("Structure with AI button is visible", async ({ page }) => {
    await page.goto("/profile");
    await waitForPageReady(page);
    await expect(page.getByRole("button", { name: "Structure with AI" })).toBeVisible();
  });
});
