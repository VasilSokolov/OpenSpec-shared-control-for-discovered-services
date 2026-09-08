# mobile-frontend

Standards for Next.js App Router frontend development at mobile.de.

## Stack

- Next.js App Router (app/ directory, React Server Components by default)
- TypeScript strict mode
- Zod schemas for form validation
- react-hook-form with zodResolver
- CSS Modules for component styles
- @mde-ui component library for all interactive controls

## @mde-ui rules

Always check `package.json` for installed @mde-ui packages before choosing a component.
- `@mde-ui/text-input` → wrap with a `TextField` form field component
- `@mde-ui/select` → wrap with a `DropdownField` form field component
- `@mde-ui/radio-button` → wrap if installed; otherwise custom `RadioField`
- Never import @mde-ui components that are not in `package.json`

To verify what is available: `mcp__mde-ui__list_components`.

## File placement

- Domain logic: `src/<domain>/` (e.g. `src/digitalcontract/`)
- Domain hooks: `src/<domain>/hooks/`
- Domain utils / schemas / mappings: `src/<domain>/utils/`
- Domain providers: `src/<domain>/providers/`
- Shared (2+ domains): `src/shared/`
- Route files only: `src/app/` (page.tsx, layout.tsx, error.tsx, API handlers)
- Tests: `__tests__/` subdirectory next to the source file

## Schema and mapping conventions

- Zod schema file: `<domain>/utils/<name>.schema.ts`
- Constants (dropdown options, enum values): `<domain>/utils/<name>.constants.ts`
- Data mapping (API ↔ form): `<domain>/utils/<name>Mapping.ts`
- Single source of truth: constants must not be duplicated between mapping and UI files

## Form field naming

Field names must match Zod schema property names exactly.
- `phoneCountryCode` — the country code dropdown (e.g. `+49`)
- `phoneNumber` — the local number part (no country code prefix)
- The API-layer concatenation `phoneCountryCode + phoneNumber` is done in the request body builder, not in the schema

## Accessibility

- Every input must have an associated `<label>` with `htmlFor` matching the input `id`
- Radio groups must use `role="radiogroup"` with `aria-label` or `aria-labelledby`
- `readOnly` fields must have `aria-readonly="true"`
- Color contrast: minimum 4.5:1 for body text, 3:1 for large text (WCAG AA)

## Dev-mode observability (mandatory for data-loading code)

Any `useEffect` that calls `reset()` or sets form state from an API response **must** include a `console.debug` block guarded by `process.env.NODE_ENV === 'development'`. Log:
- The source of truth used (active contract, prefill, created contract)
- Contract state and `shared` flag
- Whether each party object is present (`!!contract.buyer`)
- Key field values that are known to be tricky (phone, dateOfBirth)
- The mapped output for those same fields

This makes data-loading bugs visible in the browser console without attaching a debugger. Strip nothing — `NODE_ENV` guard keeps it out of production.

Also add a `console.warn` whenever a required party object is absent:
```ts
if (!activeContract.buyer) {
  console.warn('[ContractForm] API returned no buyer data — state:', activeContract.state);
}
```

## Code style

- KISS: prefer the simplest solution that satisfies the requirements
- DRY: extract shared constants; never duplicate option arrays
- YAGNI: do not add props or logic that has no current consumer
- No comments that describe what the code does — only the non-obvious why
