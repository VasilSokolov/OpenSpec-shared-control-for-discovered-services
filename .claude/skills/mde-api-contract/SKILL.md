# mde-api-contract

**Mandatory gate before any change that renames, splits, merges, reformats, or removes a field that maps to a backend API request or response.**

This skill must run BEFORE implementation code is written, not after.

## When this skill is required

Trigger this skill when the change touches ANY of:
- Zod schema field names (rename, split, merge, type change)
- Form field names that map to API request body fields
- Data mapping functions (contractMapping.ts, request body builders)
- API response type definitions

## Step 1 — Fetch the API contract

Use `mcp__mde-swagger-docs__get_api_endpoint` or `mcp__mde-swagger-docs__get_schema` to load the current API schema for the affected endpoint.

Required: document the ACTUAL request and response shape, not what the TypeScript types say.

```
# Example: fetch contract service schema
mcp__mde-swagger-docs__get_service_overview service=ps-contract-service
mcp__mde-swagger-docs__get_schema schema=SellerParty
mcp__mde-swagger-docs__get_schema schema=Contract
```

Record the result in `context/discovery/api-contract-snapshot.md`.

## Step 2 — Check actual stored data format

Look at real staging data to understand what format the backend actually stores and returns. Do NOT assume — verify.

Specifically check:
- Phone numbers: E.164 (`+49170123456`), spaced (`+49 030 12345678`), bare (`030123456`)?
- Dates: ISO string, epoch, formatted?
- Enums: uppercase, lowercase, camelCase?
- Optional fields: null vs undefined vs absent key?

Document every field being changed with its OBSERVED format in `context/discovery/field-format-audit.md`.

## Step 3 — Impact matrix

For every field being changed, fill this table:

| Field | Current API name | Current format | New form name | New format sent to API | Backward compatible? |
|-------|-----------------|----------------|---------------|------------------------|----------------------|
| phone | `phoneNumber` | `+49 030 12345678` | `phoneCountryCode` + `phoneNumber` | concatenated → `+49 030 12345678` | ✓ if concat round-trips |

Record in `context/discovery/field-impact-matrix.md`.

## Step 4 — Compatibility verdict

Declare one of:
- **SAFE**: new format round-trips to identical stored value — no backend change needed
- **BREAKING**: backend validator rejects new format — backend change needed first
- **DEGRADED**: data round-trips but with unintended mutation (e.g. spaces stripped) — document and decide
- **UNKNOWN**: swagger unavailable, staging unreachable — BLOCK implementation until resolved

If verdict is BREAKING or UNKNOWN: raise a BLOCKER in `workset.yaml` and stop.

## Step 5 — Document in proposal

Add or update the `## Data Contract Impact` section in `proposal.md`:
- List every changed field
- State the verdict for each
- State whether backend changes are required before or after frontend deploy

## Step 6 — Record evidence

Write to `context/evidence/api-contract-check.md`:
- Swagger schema snapshot
- Observed staging data format
- Compatibility verdict per field
- Sign off: `api_contract_verified: true` or `api_contract_blocked: true`
