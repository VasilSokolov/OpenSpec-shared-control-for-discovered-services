## Context

See proposal.md — Why. The existing codebase in `ps-contract-node` (Next.js 14,
TypeScript, react-hook-form + Zod, Vitest, Lokalise) contains the existing
contract sections and field primitives. This change is limited to the first
contract-fields part, interpreted as `Verkäufer`.

The supplied Figma source is:

- URL: `https://www.figma.com/design/FNAEfVMZ6XewqNL26IrVRf/QCT---Digital-Contract-Q3-2026?node-id=12234-58435&t=YohvVhThq2Snj9vx-4`
- File key: `FNAEfVMZ6XewqNL26IrVRf`
- Node: `12234-58435`
- Visual validation: pending authenticated access and screenshot evidence

The previous node `12234-74109` is superseded and must not be used.

## Target Seller Section

```
Verkäufer ← PartySection (role="seller"), with only the approved seller
subsections and fields from the supplied Figma node.
```

The exact seller field order, subsection grouping, and header text must follow
the supplied Figma node. The complete translation table is preserved in
`context/intake/translation-reference.md`; only seller rows may be used by
this change. Figma is authoritative for visual layout and the translation
reference is authoritative for text and keys until Drive MCP is enabled.

## Goals / Non-Goals

**Goals:**
- Exactly match the approved seller-section structure and field order.
- Every seller visible string uses a key from the translation reference.
- Seller show-if fields appear/disappear reactively without a form submission.
- Seller contract-state behavior remains correct.
- Seller/buyer permissions for the seller section remain correct.

**Non-Goals:**
- Changing the network/API layer or data model on the backend.
- Implementing button navigation or signing logic.
- Adding field prefilling from ad data.
- Redesigning field primitives beyond what required-state and conditional-visibility need.

## Key Decisions

### Seller section integration
**Decision**: Update `ContractForm.tsx` only where needed to render the
approved seller section. Do not reorder or modify the other five sections.
Preserve per-section test isolation and the existing buyer section behavior.

### Show-if conditional fields
**Decision**: Use `useWatch` (react-hook-form) only in the approved seller
section component to subscribe to the controlling field value. When the
condition is false, the dependent field is not rendered (unmounted, not just
hidden with CSS) so Zod validation does not fire on absent fields.
Remove conditional sub-schemas from the root schema and use `z.discriminatedUnion` or
`z.optional()` with `.superRefine` only where cross-field validation is required.
**Alternative rejected**: CSS `display:none` — keeps the field mounted and triggers validation.

### Translation keys
**Decision**: Use the exact seller keys in
`context/intake/translation-reference.md`; do not invent a second naming
convention. The complete table remains available for later changes. When Drive
MCP is enabled, compare the remote sheet and record differences before using
new rows.

### Contract state rendering
**Decision**: Derive seller-section state from the existing
`contractStatus` / `isShared` / `isSigned` flags. Do not add an API call or
change state behavior outside the seller section.
**Alternative rejected**: A separate API call for state — adds latency with no new data.

### Required field alignment
**Decision**: Keep the seller `required` props and corresponding Zod rules in
sync. No seller field may appear required in the UI without a matching
validation rule, or vice versa.

### mweb responsiveness
**Decision**: Audit only the seller-section CSS against the supplied Figma
mobile breakpoint. Use existing `@mde-ui` custom properties rather than
hardcoded values.

## Risks / Trade-offs

- [Seller field order change breaks autosave regression tests] → Update only
  affected seller fixtures.
- [New Lokalise keys not translated at launch] → Acceptable if keys exist and fall back to key
  name (or English placeholder); mark with a comment and track in Jira.
- [Show-if unmount flushes field value] → Use `shouldUnregister: false` (react-hook-form
  default) so unmounted show-if field values are preserved in form state until the user
  explicitly clears them. This means stale values may be submitted — acceptable per the
  ticket's out-of-scope decision on prefilling/cleanup.
- [Zod schema changes break contractMapping] → Any new required field added to the schema
  needs a corresponding `defaultValues` entry; enforce via TypeScript compilation.
