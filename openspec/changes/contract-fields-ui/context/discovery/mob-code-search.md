# mob-code-search discovery — contract-fields-ui

Date: 2026-09-05
Branch: QCT-4690-Update-contract-field-section-with-new-UI-UX

## API contract verification

**Source:** `mobile-de-swiftcourt/micro-integrations:src/models/bidders-highway/CreateContractRequest.ts`

The Bidders Highway integration contract sends `initiator`/`responder` party objects.
The ps-contract-node internal API uses `seller`/`buyer` party objects. Both expect the
phone field as `phoneNumber` — a single concatenated string (e.g. `+49123456789`).

**Conclusion:** `contractRequestBody.ts` correctly concatenates `seller.countryCode` +
`seller.phone` into `phoneNumber` before sending to the backend. No backend schema
change required. The form-level field split (`countryCode` / `phone`) is frontend-only.

## Party model — contract-service

**Source:** `mobile-de-swiftcourt/contract-service:src/features/response-mapper/models/PartyMapping.ts`

Party response object uses `id`, `role`, `fields`, `permissions`. The `fields` sub-object
carries all personal data including the phone number as a single concatenated value.

## ps-contract-node index

Indexed at sha `de2eb04d`. Key symbols found in local workspace instead (not all symbols
are indexed due to recency of the branch).

## Lokalise integration

No ps-contract-node-specific Lokalise translation patterns found in indexed version.
Hardcoded German strings are acceptable for `seller-section-ui` task scope;
the `seller-translations` task (separate) will replace them with Lokalise keys.
