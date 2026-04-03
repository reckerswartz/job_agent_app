import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";

test.describe("Error Pages", () => {
  test("404 page shows branded not found message", async ({ page }) => {
    await page.goto("/this-page-does-not-exist-at-all", { waitUntil: "domcontentloaded" });
    await expect(page.locator("body")).toContainText("Page Not Found");
    await expect(page.getByRole("link", { name: /Go Home/ })).toBeVisible();
  });

  test("404 page has Go to Dashboard link when signed in", async ({ page }) => {
    // Sign in first
    await page.goto("/sign_in");
    await page.getByRole("textbox", { name: "Email" }).fill("admin@jobagent.dev");
    await page.getByRole("textbox", { name: "Password" }).fill("password123");
    await page.getByRole("button", { name: "Sign In" }).click();
    await page.waitForURL(/\/dashboard/);

    await page.goto("/this-page-does-not-exist-at-all", { waitUntil: "domcontentloaded" });
    await expect(page.locator("body")).toContainText("Page Not Found");
    await expect(page.getByRole("link", { name: /Dashboard/ })).toBeVisible();
  });
});
