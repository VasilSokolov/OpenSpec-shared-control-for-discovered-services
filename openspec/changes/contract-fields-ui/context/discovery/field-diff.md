# Seller field diff — contract-fields-ui / QCT-4690

Source: Figma node 12234-58435 (extracted 2026-09-05)
Scope: Verkäufer section only

## New fields (not in current schema)

| Field key | Label (DE) | Type | Required | Notes |
|---|---|---|---|---|
| `seller.salutation` | Anrede | RadioField (Herr / Frau / Neutrale Anrede) | yes | Add to `partySchema` |
| `seller.countryCode` | Ländervorwahl | DropdownField (+49 DE default) | yes | Add to `partySchema`; precedes `phone` |

## Retained fields — updates only

| Current key | Old label | New label (DE) | New placeholder | Required change | Type change |
|---|---|---|---|---|---|
| `seller.firstName` | First name | Vorname | z.B. Max | none (still required) | none |
| `seller.lastName` | Last name | Nachname | z.B. Mustermann | none (still required) | none |
| `seller.street` | Street, number | Straße | z.B. Musterstr. | none (still required) | none |
| `seller.houseNumber` | House number | Nr. | z.B. 12a | none (still optional) | none |
| `seller.zip` | ZIP | PLZ | z.b. 12103 | none (still required) | none |
| `seller.city` | City | Ort | z.B. Berlin | none (still required) | none |
| `seller.country` | Country | Land | — | none (still required) | none (DropdownField, default Deutschland) |
| `seller.email` | Email | E-Mail-Adresse | z.b. max.mustermann@mail.de | none (still required for seller) | none |
| `seller.phone` | Phone number | Telefonnummer | z.B. 01761234567 | none (still required) | none (split: countryCode + phone) |
| `seller.dateOfBirth` | Date of birth | Geburtsdatum | TT.MM.JJJJ | none (still required) | none |
| `seller.idNumber` | ID / Passport number | Personalausweisnummer | z.B. F7KAS78 | none (still optional) | none |

## Fields not visible in design node — BA confirmation required

| Current key | Current label | Status |
|---|---|---|
| `seller.companyName` | Company name | Not shown in node 12234-58435; BA to confirm: hide or retain as hidden optional |

## Subsection grouping (new)

| Subsection | Fields |
|---|---|
| 1.1 Person und Anschrift | salutation, firstName, lastName, street, houseNumber, zip, city, country |
| 1.2 Kontaktdaten | email, countryCode, phone |
| 1.3 Persönliche Angaben | dateOfBirth, idNumber |

## Show-if conditional fields

No conditional fields were identified for the seller section in node 12234-58435.
Confirm with BA / design that this is intentional before closing task 4.1.
