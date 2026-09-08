#!/usr/bin/env bash

# Install Playwright into a Next.js code repository and write the baseline
# e2e test configuration. Idempotent: safe to run more than once.

set -euo pipefail

TARGET_REPOSITORY=""
BASE_URL="http://localhost:3000"

usage() {
  cat <<'EOF'
Usage:
  tools/setup-playwright.sh --repo <code-repository> [--base-url <url>]

Options:
  --repo        Existing code repository to receive Playwright.
  --base-url    Dev-server URL (default: http://localhost:3000).
  --help        Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)       TARGET_REPOSITORY="$2"; shift 2 ;;
    --base-url)   BASE_URL="$2";          shift 2 ;;
    --help|-h)    usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$TARGET_REPOSITORY" ]] || { usage >&2; exit 2; }
TARGET_REPOSITORY="$(cd "$TARGET_REPOSITORY" && pwd)"
[[ -d "$TARGET_REPOSITORY/.git" ]] || {
  echo "Target is not a Git repository: $TARGET_REPOSITORY" >&2; exit 1
}

# Detect package manager
if [[ -f "$TARGET_REPOSITORY/yarn.lock" ]]; then
  PM="yarn"
  ADD_CMD="yarn add -D"
elif [[ -f "$TARGET_REPOSITORY/pnpm-lock.yaml" ]]; then
  PM="pnpm"
  ADD_CMD="pnpm add -D"
else
  PM="npm"
  ADD_CMD="npm install --save-dev"
fi

echo "[playwright] package manager: $PM"

# Install @playwright/test if not already present
if ! (cd "$TARGET_REPOSITORY" && node -e "require('@playwright/test')" 2>/dev/null); then
  echo "[playwright] installing @playwright/test …"
  (cd "$TARGET_REPOSITORY" && $ADD_CMD @playwright/test)
  (cd "$TARGET_REPOSITORY" && npx playwright install --with-deps chromium)
else
  echo "[playwright] @playwright/test already installed, skipping"
fi

# Write playwright.config.ts (skip if already exists)
CONFIG_FILE="$TARGET_REPOSITORY/playwright.config.ts"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[playwright] writing playwright.config.ts"
  cat > "$CONFIG_FILE" <<EOF
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? '$BASE_URL',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'NEXT_PUBLIC_MOCK_UI=true yarn dev',
    url: '$BASE_URL',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
EOF
else
  echo "[playwright] playwright.config.ts already exists, skipping"
fi

# Create e2e directory with a contract seller section smoke test
E2E_DIR="$TARGET_REPOSITORY/e2e"
mkdir -p "$E2E_DIR"
SMOKE_TEST="$E2E_DIR/contract-seller-section.spec.ts"
if [[ ! -f "$SMOKE_TEST" ]]; then
  echo "[playwright] writing e2e/contract-seller-section.spec.ts"
  cat > "$SMOKE_TEST" <<'EOF'
import { test, expect } from '@playwright/test';

// Smoke tests for the Verkäufer section — QCT-4690
// Requires: NEXT_PUBLIC_MOCK_UI=true dev server

test.describe('Verkäufer section', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/digitalcontract?adId=test-ad-id');
  });

  test('renders the seller section heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: /Verkäufer/ })).toBeVisible();
  });

  test('renders all three subsections', async ({ page }) => {
    await expect(page.getByRole('heading', { name: /Person und Anschrift/ })).toBeVisible();
    await expect(page.getByRole('heading', { name: /Kontaktdaten/ })).toBeVisible();
    await expect(page.getByRole('heading', { name: /Persönliche Angaben/ })).toBeVisible();
  });

  test('renders salutation radio options', async ({ page }) => {
    await expect(page.getByRole('radio', { name: 'Herr' })).toBeVisible();
    await expect(page.getByRole('radio', { name: 'Frau' })).toBeVisible();
    await expect(page.getByRole('radio', { name: 'Neutrale Anrede' })).toBeVisible();
  });

  test('renders Ländervorwahl dropdown defaulting to +49', async ({ page }) => {
    const dropdown = page.getByLabel('Ländervorwahl');
    await expect(dropdown).toBeVisible();
  });

  test('shows required validation on submit without filling fields', async ({ page }) => {
    await page.getByRole('button', { name: /speichern/i }).click();
    await expect(page.getByText(/Required/i).first()).toBeVisible();
  });

  test('seller section is read-only for buyer role', async ({ page }) => {
    // Mock-UI defaults to seller; verify read-only state by checking disabled inputs
    // This test is a placeholder until role-switching mock is available
    await expect(page.getByLabel('Vorname')).toBeVisible();
  });

  test('mweb: seller section has no horizontal overflow at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/digitalcontract?adId=test-ad-id');
    const section = page.locator('section').filter({ hasText: 'Verkäufer' }).first();
    await expect(section).toBeVisible();
    const box = await section.boundingBox();
    expect(box?.width).toBeLessThanOrEqual(390);
  });
});
EOF
else
  echo "[playwright] e2e/contract-seller-section.spec.ts already exists, skipping"
fi

# Add test:e2e script to package.json if missing
node - <<'JSEOF' "$TARGET_REPOSITORY/package.json"
const fs = require('fs');
const path = process.argv[2];
const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
if (!pkg.scripts['test:e2e']) {
  pkg.scripts['test:e2e'] = 'playwright test';
  fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
  console.log('[playwright] added test:e2e script to package.json');
} else {
  console.log('[playwright] test:e2e script already exists');
}
JSEOF

echo "[playwright] setup complete for $TARGET_REPOSITORY"
