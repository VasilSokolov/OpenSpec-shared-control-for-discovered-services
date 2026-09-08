# mde-lokalise

Lokalise translation key lifecycle skill for mobile.de Next.js applications.

Applies whenever a UI change introduces or modifies any user-visible string.
Verified by examining `ps-contract-node`, `ps-listing-node`, `dealer-homepage-webapp`,
and the `mobile-nextjs-starter` intl package via mob-code-search on 2026-09-05.

---

## How i18n works at mobile.de (ps-family pattern)

```
Lokalise dashboard (source of truth)
        ↓  lokalise-cli pull
generated/translations/de.json   ← downloaded, gitignored or committed
generated/translations/en.json
        ↓  setupIntl() in instrumentation.ts (already wired in ps-contract-node)
globalThis.langIntls.mobilede_deIntl
globalThis.langIntls.mobilede_enIntl
        ↓  getIntl() in layout.tsx (already wired in ps-contract-node)
ServerIntlProvider messages={intl.messages} locale={intl.locale}
        ↓  per-component usage
Server: const { formatMessage } = await getIntl()  (import from '…/server')
Client: const { formatMessage } = useIntl()         (import from '…/client')
```

**Language selection order** (from `mobile-nextjs-starter`):
1. `set-cookie` header (in-flight cookie change)
2. `mobile.LOCALE` cookie
3. `getCommercialViCustomerLanguage()` from VI token header
4. Default: `de`

The language switch on the page sets the `mobile.LOCALE` cookie. If components
use hardcoded strings, the switch has no visible effect.

---

## Supported languages (ps-family)

`de`, `en` — registered in `instrumentation.ts`. Add more by:
1. Adding them to `setupIntl({ messages: { de: ..., en: ..., fr: ... } })`
2. Ensuring the `filter-langs` in `.lokalise.yml` includes them
3. Pulling the new language file

---

## Key naming convention

```
I18N.<DOMAIN>.<SECTION>.<KEY>
```

All segments after `I18N` use **SCREAMING_SNAKE_CASE**.

| Segment | Example | Rule |
|---------|---------|------|
| `I18N` | `I18N` | Always prefix — required by `localizeIfNeeded` util |
| `DOMAIN` | `DIGITAL_CONTRACT` | SCREAMING_SNAKE_CASE feature/repo area |
| `SECTION` | `SELLER_SECTION` | SCREAMING_SNAKE_CASE component or logical group |
| `KEY` | `FIRST_NAME_LABEL` | SCREAMING_SNAKE_CASE, describes the string semantically |

Examples:
```
I18N.DIGITAL_CONTRACT.SELLER_SECTION.FIRST_NAME_LABEL
I18N.DIGITAL_CONTRACT.SELLER_SECTION.PHONE_COUNTRY_CODE_LABEL
I18N.DIGITAL_CONTRACT.PARTY_SECTION.BUYER_HEADING
I18N.DIGITAL_CONTRACT.VEHICLE_SECTION.VIN_LABEL
I18N.DIGITAL_CONTRACT.CONTRACT_FORM.SAVING_LABEL
I18N.DIGITAL_CONTRACT.ERROR.ACCESS_DENIED_HEADING
I18N.DIGITAL_CONTRACT.ERROR.ACTION_HOMEPAGE
```

Never use:
- mixed case (`SellerSection`, `firstNameLabel`) — all segments must be SCREAMING_SNAKE_CASE
- UI element type in the key (`BUTTON`, `INPUT`, `PLACEHOLDER` — structural, not semantic)
- German words in the key name (keys must be language-neutral)
- Spaces in key names

---

## Mandatory steps for any change that adds user-visible text

### Step 1 — Register keys in Lokalise BEFORE writing component code

1. Go to the Lokalise project for `ps-contract-node` (project ID in `.lokalise.yml`)
2. Create each new key following the naming convention above
3. Add German (`de`) translation value
4. Add English (`en`) translation value
5. Tag keys with the feature tag (e.g. `digitalcontract`, `seller-section`)

Do not write hardcoded strings in components and plan to "add to Lokalise later".
The German translation is written once in Lokalise, not in the component.

### Step 2 — Pull translations to the local repo

```bash
# Requires lokalise-cli installed (see below)
lokalise-cli pull
```

This writes/updates `generated/translations/de.json` and `generated/translations/en.json`.
These files are the only place translations live in the codebase.

After pulling, verify the file contains every key registered in Step 1.

The file structure follows a flat key-value format — keys are the Lokalise IDs,
values are the translated strings written by translators in the Lokalise dashboard.
**Do not hardcode translation values here or in the skill** — values belong in
Lokalise only.

**`generated/translations/de.json`** (German — the source language):
```json
{
  "I18N.DIGITAL_CONTRACT.SELLER_SECTION.HEADING": "<German text>",
  "I18N.DIGITAL_CONTRACT.SELLER_SECTION.FIRST_NAME_LABEL": "<German text>",
  "I18N.DIGITAL_CONTRACT.VEHICLE_SECTION.HEADING": "<German text>"
}
```

**`generated/translations/en.json`** (English):
```json
{
  "I18N.DIGITAL_CONTRACT.SELLER_SECTION.HEADING": "<English text>",
  "I18N.DIGITAL_CONTRACT.SELLER_SECTION.FIRST_NAME_LABEL": "<English text>",
  "I18N.DIGITAL_CONTRACT.VEHICLE_SECTION.HEADING": "<English text>"
}
```

The key names are identical across all language files. Only the values differ.
Pull is the only way values should enter `generated/translations/` — never edit
these files by hand.

If a key exists in Lokalise but is missing from the pulled JSON, it means it was
not translated yet — check `generated/translations/missingKeys.json` which lists
every key that fell back to the key string itself.

### Missing-key pipeline (how new keys get into Lokalise)

When code references a key not yet present in Lokalise, the runtime captures it
into `missingKeys.json`. The import pipeline is:

```
missingKeys.json
    ↓  mde-translations-generator-csv
CSV file
    ↓  Jenkins job: mobile-translations-import
Lokalise project (key created, pending translation)
    ↓  translator fills in values
    ↓  lokalise-cli pull (next run)
generated/translations/de.json + en.json updated
```

This means: if you add a `formatMessage({ id: '...' })` call with a key that is
not in Lokalise yet, the key will appear in `missingKeys.json` on first run.
The Jenkins job then creates it in Lokalise so translators can fill it in.
You **still** see the `defaultMessage` fallback locally until a translator provides
values and you run `lokalise-cli pull` again.

### appGroup option — pulling an entire namespace

If a feature owns a namespace (`I18N.DIGITAL_CONTRACT.*`), configure `appGroup`
in the translations config so **all keys under that namespace are pulled
automatically** — even ones not literally referenced in source code yet.
This prevents accidental gaps when a key is added in Lokalise but not yet
used in code.

```yaml
# .mde-translationsrc or equivalent config
appGroup: DIGITAL_CONTRACT
```

With `appGroup` set, `npm run translations` / `lokalise-cli pull` fetches every
`I18N.DIGITAL_CONTRACT.*` key from the Lokalise project, regardless of whether
the key appears in a `formatMessage()` call.

### Step 3 — Use translation keys in components

**Client component (e.g. ContractForm.tsx, SellerSection.tsx):**
```tsx
'use client';
import { useIntl } from '@mobile-de/nextjs-starter-intl/client';

export function SellerSection() {
  const { formatMessage } = useIntl();
  return (
    <label>
      {formatMessage({ id: 'I18N.DIGITAL_CONTRACT.SELLER_SECTION.FIRST_NAME_LABEL' })}
    </label>
  );
}
```

**Server component:**
```tsx
import 'server-only';
import { getIntl } from '@mobile-de/nextjs-starter-intl/server';

export async function VehicleSection() {
  // oxlint-disable-next-line react/rules-of-hooks
  const { formatMessage } = await getIntl();
  return <h2>{formatMessage({ id: 'I18N.DIGITAL_CONTRACT.VEHICLE_SECTION.HEADING' })}</h2>;
}
```

**No direct `import` of `de.json`** — always go through `formatMessage`.

### Step 4 — Verify language switch works

Test by setting `mobile.LOCALE=en` cookie and reloading. Every string that was
translated in Step 1 must render in English. If any string stays German, it's
hardcoded and must be fixed before merge.

### Step 5 — Record evidence

Create `context/evidence/lokalise-keys.md` in the change package listing:
- Lokalise project ID
- Keys registered (key name, de value, en value)
- Screenshot or copy of Lokalise key entries
- `lokalise-cli pull` output confirming the pull succeeded

---

## Installing lokalise-cli (local dev)

```bash
ssh-add
brew tap mobile-de/lokalise git@github.mpi-internal.com:mobile-de/lokalise-cli.git
brew install lokalise-cli
```

On first run: `lokalise-cli init` creates `.lokalise.yml`.

### `.lokalise.yml` format

```yaml
api-url: https://api.tool.mde-production.mobint.io/lokalise-api

project-id: <ps-contract-node-lokalise-project-id>

pull:
  format: json
  filter-langs: de,en
  dest: ./generated/translations
  bundle-structure: "%LANG_ISO%.%FORMAT%"
```

The `api-url` routes through mobile.de's `lokalise-proxy` — no personal API token needed.
The project ID is the Lokalise project for `ps-contract-node`. Get it from the
Lokalise dashboard or from the team's onboarding docs.

---

## CI/CD integration

Add the Lokalise pull step BEFORE the build step in the GitHub Actions workflow:

```yaml
- name: Install Lokalise CLI
  uses: mobile-de/lokalise-cli/.github/actions/install@main
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- name: Pull translations
  run: lokalise-cli pull

- name: Build
  run: npm run build
```

Or use the Docker-based action (no binary install):
```yaml
- name: Fetch translations
  uses: mobile-de/lokalise-cli/.github/actions/pull@main
  with:
    args: --dest generated/translations
```

A scheduled weekly workflow should also pull and commit updated translations:
```yaml
on:
  schedule:
    - cron: '0 6 * * 1'   # Monday 6 AM — picks up translator updates
```

---

## Detecting hardcoded strings (gate)

The `mde-validation` skill runs this check before any merge:

Fail if any `.tsx` file under `src/` contains a user-visible German word
(simple heuristic: any JSX text node with German characters like ü, ö, ä, ß
or known German words like `Verkäufer`, `Fahrzeug`, `Kaufvertrag`).

Exact implementation: `tools/validation/check-hardcoded-strings.sh`
(to be created as part of the Lokalise integration task).

---

## Current state in ps-contract-node (as of 2026-09-07)

| Layer | Status |
|-------|--------|
| `instrumentation.ts` → `setupIntl` | ✅ wired — loads `de.json` + `en.json` |
| `layout.tsx` → `ServerIntlProvider` | ✅ wired — correct locale from cookie |
| `.lokalise.yml` | ✅ exists — project-id `794098406582daef51f997.67431793`, proxy api-url set |
| `generated/translations/de.json` | ✅ exists — `I18N.COMMON.*` + `I18N.DIGITAL_CONTRACT.*` keys |
| `generated/translations/en.json` | ✅ exists — `I18N.COMMON.*` + `I18N.DIGITAL_CONTRACT.*` keys |
| `ContractErrorView.tsx` | ✅ uses `formatMessage` |
| `ContractForm.tsx` | ✅ uses `formatMessage` |

---

## Rules — must not be violated

1. **Never manually edit** `generated/translations/*.json` — these are generated by
   `lokalise-cli pull` and will be overwritten on the next pull.
2. **Never merge, patch, or script-generate** translation json files outside of
   `lokalise-cli pull` — always pull from Lokalise.
3. Keys must exist in **Lokalise first** before using them in code (or accept the
   missingKeys.json→Jenkins→Lokalise lag cycle).
4. The `defaultMessage` in `formatMessage({ id: '...', defaultMessage: '...' })` is
   only a safety fallback — never rely on it for the primary user-visible string.
   It should match the German value in case it shows as a fallback.
