import { test, expect } from "./fixtures/url-tracker";
import { waitForPageReady } from "./helpers/screenshot-helper";
import { signIn, signOut, ADMIN_USER } from "./helpers/auth-helper";

test.describe("Authentication", () => {
  test("sign up redirects new user to onboarding", async ({ page }) => {
    const uniqueEmail = `e2e_${Date.now()}@test.dev`;
    await page.goto("/sign_up");
    await waitForPageReady(page);

    await page.getByRole("textbox", { name: "Email" }).fill(uniqueEmail);
    await page.getByRole("textbox", { name: /^Password$/ }).fill("password123");
    await page.getByRole("textbox", { name: "Confirm Password" }).fill("password123");
    await page.getByRole("button", { name: "Create Account" }).click();

    await expect(page).toHaveURL(/\/onboarding/);
    await expect(page.locator("body")).toContainText("start with your resume");
  });

  test("sign in with valid credentials goes to dashboard", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator("body")).toContainText("Dashboard");
  });

  test("sign in with invalid credentials shows error", async ({ page }) => {
    await page.goto("/sign_in");
    await page.getByRole("textbox", { name: "Email" }).fill("wrong@example.com");
    await page.getByRole("textbox", { name: "Password" }).fill("wrongpassword");
    await page.getByRole("button", { name: "Sign In" }).click();

    await expect(page.locator("body")).toContainText("Invalid Email or password");
  });

  test("sign out redirects to home", async ({ page }) => {
    await signIn(page, ADMIN_USER.email, ADMIN_USER.password);
    await signOut(page);
    await expect(page.getByRole("link", { name: "Sign In" })).toBeVisible();
  });
});
