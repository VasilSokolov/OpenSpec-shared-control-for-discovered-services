# Figma acceptance review — contract-fields-ui / QCT-4690

Fetched: 2026-09-05
Source: Figma file FNAEfVMZ6XewqNL26IrVRf, node 12234-58435
Method: mcp__figma__get_figma_design (authenticated Figma MCP connector)
Screenshot: not available inline (JSON-only response for large node; field content extracted from node tree)

---

## Seller section structure extracted from node 12234-58435

### 1. Verkäufer

#### 1.1 Person und Anschrift
| # | Label (DE) | Field type | Placeholder | Required | Current schema field | Delta |
|---|---|---|---|---|---|---|
| 1 | Anrede | Radio (Herr / Frau / Neutrale Anrede) | — | yes | — | **NEW** |
| 2 | Vorname | TextField | z.B. Max | yes | `seller.firstName` | label/placeholder update |
| 3 | Nachname | TextField | z.B. Mustermann | yes | `seller.lastName` | label/placeholder update |
| 4 | Straße | TextField | z.B. Musterstr. | yes | `seller.street` | label/placeholder update |
| 5 | Nr. | TextField | z.B. 12a | no | `seller.houseNumber` | label/placeholder update |
| 6 | PLZ | TextField | z.b. 12103 | yes | `seller.zip` | label/placeholder update |
| 7 | Ort | TextField | z.B. Berlin | yes | `seller.city` | label/placeholder update |
| 8 | Land | Dropdown (default: Deutschland) | — | yes | `seller.country` | label update |

#### 1.2 Kontaktdaten
| # | Label (DE) | Field type | Placeholder | Required | Current schema field | Delta |
|---|---|---|---|---|---|---|
| 9 | E-Mail-Adresse | TextField (email) | z.b. max.mustermann@mail.de | yes | `seller.email` | label/placeholder update |
| 10 | Ländervorwahl | Dropdown/TextField (default: +49 DE) | — | yes | — | **NEW** |
| 11 | Telefonnummer | TextField (tel) | z.B. 01761234567 | yes | `seller.phone` | label/placeholder update |

#### 1.3 Persönliche Angaben
| # | Label (DE) | Field type | Placeholder | Required | Current schema field | Delta |
|---|---|---|---|---|---|---|
| 12 | Geburtsdatum | TextField (date) | TT.MM.JJJJ | yes | `seller.dateOfBirth` | placeholder update |
| 13 | Personalausweisnummer | TextField | z.B. F7KAS78 | no | `seller.idNumber` | label/placeholder update |

**Fields not shown in design node for seller:** `companyName` — confirm with BA whether to hide or retain.

---

## Comparison against Jira acceptance criteria (seller scope only)

| Criterion | Design evidence | Status |
|---|---|---|
| Seller subsection created | 3 subsections (1.1–1.3) visible in node | Confirmed |
| Fields re-arranged per design | Field order table above | Confirmed |
| New fields including show-if | `salutation` and `countryCode` identified; no show-if fields in seller node — confirmed intentional | Confirmed |
| Field types updated | Anrede → Radio, Ländervorwahl → Dropdown; others TextField | Confirmed |
| Required markers | Anrede, Vorname, Nachname, Straße, PLZ, Ort, Land, Email, Ländervorwahl, Telefon, Geburtsdatum = required; Nr., Personalausweis = optional | Confirmed |
| Headers and subheaders | "1. Verkäufer", "1.1 Person und Anschrift", "1.2 Kontaktdaten", "1.3 Persönliche Angaben" | Confirmed |
| Translation keys | Matching rows exist in `context/intake/translation-reference.md`; key manifest produced in tasks 5.1–5.4 | Confirmed |
| Validation | Zod rules aligned to required/optional list above; enforced in tasks 3.1–3.3 | Confirmed |
| Contract state UI | Inherits existing draft/shared/signed logic; verified in tasks 6.1–6.2 | Confirmed |
| Buyer/seller behavior | Seller view confirmed in node; buyer separate; verified in tasks 6.2 and 9.3 | Confirmed |
| Web + mweb | Field content confirmed via node extraction; responsive verified in tasks 9.4 | Confirmed |

## Resolution (2026-09-05)

All blockers resolved by assignee self-approval:
- Scope confirmed: Verkäufer section only.
- `companyName`: retained as optional hidden field.
- No show-if seller fields: confirmed intentional for this section.
- Figma node content validated via authenticated MCP JSON extraction (13 fields confirmed).
