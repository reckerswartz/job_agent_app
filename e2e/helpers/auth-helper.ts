import { Page, expect } from "@playwright/test";

export async function signIn(page: Page, email: string, password: string) {
  await page.goto("/sign_in");
  await page.getByRole("textbox", { name: "Email" }).fill(email);
  await page.getByRole("textbox", { name: "Password" }).fill(password);
  await page.getByRole("button", { name: "Sign In" }).click();
  await page.waitForURL(/\/(dashboard|onboarding)/);
}

export async function signUp(page: Page, email: string, password: string) {
  await page.goto("/sign_up");
  await page.getByRole("textbox", { name: "Email" }).fill(email);
  await page.getByRole("textbox", { name: /^Password$/ }).fill(password);
  await page.getByRole("textbox", { name: "Confirm Password" }).fill(password);
  await page.getByRole("button", { name: "Create Account" }).click();
  await page.waitForURL(/\/(dashboard|onboarding)/);
}

export async function signOut(page: Page) {
  await page.goto("/");
  const signOutBtn = page.getByRole("button", { name: "Sign Out" });
  if (await signOutBtn.isVisible()) {
    await signOutBtn.click();
    await page.waitForURL("/");
  }
}

export const DEMO_USER = { email: "demo@jobagent.dev", password: "password123" };
export const ADMIN_USER = { email: "admin@jobagent.dev", password: "password123" };
