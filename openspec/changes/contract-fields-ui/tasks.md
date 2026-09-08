## 0. Scope and source validation

- [ ] 0.1 Re-fetch QCT-4690 and confirm whether “first part” means the
  `Verkäufer` section; stop if Jira still requires all six sections.
- [ ] 0.2 Validate the supplied Figma URL, file key `FNAEfVMZ6XewqNL26IrVRf`,
  and node `12234-58435`; record the result in
  `context/intake/figma-reference.md`.
- [ ] 0.3 Produce `context/discovery/field-diff.md` for seller fields only.
- [ ] 0.4 Create `context/discovery/acceptance-traceability.md` before approval.

## 1. Seller section structure

- [ ] 1.1 Render the approved seller header and seller subsections in the
  supplied Figma order.
- [ ] 1.2 Update `ContractForm.tsx` only where required for the seller section.
- [ ] 1.3 Confirm no other contract section is reordered or modified.

## 2. Seller field behavior

- [ ] 2.1 Reorder only seller fields according to the approved field diff.
- [ ] 2.2 Apply only the approved seller field types and seller CSS changes.
- [ ] 2.3 Use seller translation rows from
  `context/intake/translation-reference.md`.

## 3. Seller validation

- [ ] 3.1 Update seller portions of `contract.schema.ts` with only the
  approved format, length, pattern, required, and optional rules.
- [ ] 3.2 Update seller defaults and mapping in `contractMapping.ts`.
- [ ] 3.3 Keep seller `required` props and Zod rules synchronized.

## 4. Seller show-if fields

- [ ] 4.1 Identify seller conditional fields from the approved Figma and
  translation reference; list them in `context/discovery/field-diff.md`.
- [ ] 4.2 Implement seller conditional rendering with `useWatch`; unmount a
  dependent field when its condition is false.
- [ ] 4.3 Verify seller Zod validation does not fire for unmounted fields.

## 5. Seller translations

- [ ] 5.1 Select seller rows from `context/intake/translation-reference.md`
  and create `context/discovery/lokalise-keys.md`.
- [ ] 5.2 Replace seller hardcoded strings with the exact supplied keys.
- [ ] 5.3 Until Drive MCP is enabled, treat the local Markdown reference as the
  source and record any unresolved translation issue.
- [ ] 5.4 Before merging, reconcile the seller rows with the Google Sheet or
  Lokalise source and attach the comparison evidence.

## 6. Seller state and role behavior

- [ ] 6.1 Verify seller-section behavior for draft, shared, and signed states
  using existing contract flags; do not add an API call.
- [ ] 6.2 Verify seller/buyer permissions for the seller section only.

## 7. Scope guard

- [ ] 7.1 Confirm that `Fahrzeug`, `Kaufbedingungen`, `Zahlung`, `Übergabe`,
  and `Unterzeichnung` remain unchanged.
- [ ] 7.2 Confirm that no backend/API or unrelated page files are modified.

## 8. Tests

- [ ] 8.1 Update only tests affected by the seller-section change.
- [ ] 8.2 Add Vitest tests for each seller show-if field and its false path.
- [ ] 8.3 Test seller required markers, validation, role behavior, and contract states.
- [ ] 8.4 Run the repository test suite and build before opening the PR.

## 9. Manual verification (web + mweb)

- [ ] 9.1 Verify only the seller section on desktop web against Figma node `12234-58435`.
- [ ] 9.2 Trigger each approved seller show-if condition and verify both paths.
- [ ] 9.3 Verify seller state and buyer/seller permissions without changing other sections.
- [ ] 9.4 Verify the seller section at the approved mweb viewport with no horizontal overflow.
- [ ] 9.5 Confirm seller translations load for `de` with no missing-key fallbacks.
- [ ] 9.6 Record screenshots, test output, changed-file scope, and Figma comparison evidence.
