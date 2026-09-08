# Acceptance traceability — QCT-4690

Status: partially unblocked — Figma node content extracted; BA scope confirmation and desktop screenshot still pending.

## Source conflict

The stored raw Jira intake describes sections 1 through 6. The current user
clarification says only the first contract-fields part is required. This file
must not be marked complete until BA confirms that the first part means the
`Verkäufer` section.

## Figma evidence (node 12234-58435, fetched 2026-09-05)

Full node content extracted. See `context/evidence/figma/acceptance-review.md`
and `context/discovery/field-diff.md`. Desktop/mobile screenshot pending.

## Traceability matrix

| Jira acceptance area | Current change interpretation | Planned task(s) | Design evidence | Status |
|---|---|---|---|---|
| Contract subsection | Seller subsection only | 1.1–1.3 | 3 subsections confirmed in node (1.1 Person und Anschrift, 1.2 Kontaktdaten, 1.3 Persönliche Angaben) | Design confirmed; BA scope pending |
| Field arrangement | Seller fields only | 2.1 | 13 fields in order confirmed in `field-diff.md` | Design confirmed; BA scope pending |
| New/show-if fields | `salutation` + `countryCode` new; no show-if found | 4.1–4.3 | New fields confirmed; no show-if in node — BA to confirm | Partial |
| Field types | Anrede → Radio, Ländervorwahl → Dropdown | 2.2 | Confirmed in node | Design confirmed |
| Required markers | 11 required, 2 optional per node | 3.1–3.3 | Confirmed in `field-diff.md` | Design confirmed |
| Headers and subheaders | "1. Verkäufer", 1.1–1.3 labels | 1.1 | Confirmed in node | Design confirmed |
| Translation keys | Seller rows from `translation-reference.md` | 5.1–5.4 | Key manifest pending (`lokalise-keys.md`) | Pending implementation |
| Validation | Seller Zod rules aligned to required/optional above | 3.1–3.3 | Test output required | Pending implementation |
| Contract state UI | Seller section only | 6.1 | Not extractable from node; inherits existing logic | Pending implementation |
| Buyer/seller behavior | Seller section confirmed; buyer separate | 6.2 | Seller node confirms seller-only view | Partially confirmed |
| Web and mweb | Seller section only | 9.1–9.6 | Desktop/mobile screenshot pending | Pending |

## Scope guard

The following sections must remain unchanged by this change:

- Fahrzeug
- Kaufbedingungen
- Zahlung
- Übergabe
- Unterzeichnung
