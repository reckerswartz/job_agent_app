import { Page } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

const SCREENSHOTS_DIR = path.resolve(__dirname, "../../test-results/screenshots");

/**
 * Take a named screenshot and save it to the central screenshots directory.
 * Useful for capturing intermediate states during a test.
 */
export async function captureScreenshot(
  page: Page,
  name: string,
  fullPage = true
): Promise<string> {
  fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });
  const safeName = name.replace(/[^a-zA-Z0-9]+/g, "-");
  const filePath = path.join(SCREENSHOTS_DIR, `${safeName}.png`);
  await page.screenshot({ path: filePath, fullPage });
  return filePath;
}

/**
 * Wait for the Rails page to fully load (network idle + DOM content loaded).
 */
export async function waitForPageReady(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForLoadState("domcontentloaded");
}
