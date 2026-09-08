## Why

QCT-4690 requests a digital-contract field-section update. This change is
intentionally limited to the first contract-fields part, interpreted as the
`Verkäufer` section. The previous generated proposal incorrectly expanded the
scope to all six sections.

The exact Figma source supplied for this change is recorded in
`context/intake/figma-reference.md`. The complete translation table is stored
in `context/intake/translation-reference.md` until Drive MCP access is enabled.

The raw Jira intake currently stored in `context/intake/jira.json` describes
sections 1 through 6, while the current clarification says only the first part
is required. BA must resolve this mismatch before approval. If Jira still
requires all six sections, create a separate change or expand this change
through a new approval; do not silently implement the other sections.

## What Changes

- **Seller section only**: Render the approved seller header, subsections, and
  fields in the order shown by the supplied Figma node.
- **Seller field behavior**: Apply only the approved seller field types,
  required markers, validation, and seller-specific show-if logic.
- **Seller translations**: Use seller rows from
  `context/intake/translation-reference.md` for labels, placeholders, helper
  text, and errors.
- **Seller state and role behavior**: Preserve the existing contract-state and
  seller/buyer role model without adding an API call.
- **Seller responsive behavior**: Verify the seller section on web and mweb.

## Capabilities

### New Capabilities
- `seller-fields-conditional-visibility`: approved seller fields are shown or
  hidden based on controlling values.
- `seller-field-state-rendering`: approved seller fields retain the existing
  draft/shared/signed behavior without an extra API call.

### Modified Capabilities
- `seller-fields-layout`: seller header, subsections, field order, types, and
  required markers updated to match the approved design.
- `seller-fields-validation`: seller Zod rules aligned with approved field
  behavior.
- `seller-fields-i18n`: seller UI strings use the supplied translation reference.

## Impact

- `src/app/digitalcontract/_components/contract/ContractForm.tsx` — only
  seller-section integration where required.
- `src/app/digitalcontract/_components/contract/contract.schema.ts` — seller
  validation only.
- `src/app/digitalcontract/_components/contract/contractMapping.ts` — seller
  defaults and mapping only.
- `src/app/digitalcontract/_components/contract/components/sections/PartySection.tsx`
  and directly related seller components.
- Seller-section CSS and tests only.
- Lokalise project `794098406582daef51f997.67431793` — new translation keys pushed via
  Lokalise CLI; translations pulled before CI build.
- No backend / API changes. No new endpoints. No deployment configuration changes.

## Out of Scope

- `Fahrzeug`, `Kaufbedingungen`, `Zahlung`, `Übergabe`, and `Unterzeichnung`.
- Sticky progress boxes, action modals, and signing logic.
- Any unrelated page section.
- Field prefilling from ad data (separate ticket).
- Admin configurability of field attributes.
