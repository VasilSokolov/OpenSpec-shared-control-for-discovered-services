# Acceptance traceability — control-plane-desktop-console

Status: proposed / unapprovable — internal tooling change with no Jira source and
no design source. Blocked on approval and the framework/hosting decisions in
`approval.yaml` (open_questions). No visual evidence phase applies.

## Source note

There is no Jira ticket and no Figma design for this change. It is internal
tooling / architecture. The intake in `context/intake/jira.json` records
`source: none`. This file must not be marked complete until BA and engineering
approve the console and the framework/hosting decisions.

## Traceability matrix

| Acceptance criterion | Design evidence | Planned task(s) | Verification | Status |
|---|---|---|---|---|
| Console renders file-based control-plane state from openspec/changes/*/ | design.md — "Rust core stays thin" + "view/controller" | 2.1–2.3, 5.1, 5.4 | 8.1 renders existing changes with correct status/approval | Pending approval |
| Console runs pinned gate scripts via named commands, streaming output + exit | design.md — "No generic command execution — one runner per named gate" | 3.1–3.5, 5.5 | 8.2 runner result matches CLI; 8.4 no push reachable | Pending approval |
| Console streams a headless /opsx:propose and /opsx:apply run | design.md — "Agent bridge is opt-in and observable" | 4.1–4.2 | 8.x transcript streamed; opt-in per action | Pending approval |
| Console is a view/controller only; no governance logic in Rust | design.md — "The console is a view/controller, never a second source of truth" | 0.4, 9.1 | 9.1–9.2 review: scripts/schema/opsx unchanged | Pending approval |
| No generic exec / no push; fetch-only preflight; ACL grants only named commands | design.md — "Safety rails carried into the Rust boundary" + ACL | 1.2, 3.5, 8.3–8.4 | 8.3 denied API fails closed; 8.4 no destructive op reachable | Pending approval |
| Frontend framework decision (Vite+React default; Next.js only for @mde-ui) | design.md — "Frontend framework" | 0.2, 1.1 | Decision recorded in approval.yaml before scaffolding | Pending decision |
| Hosting decision (apps/console/ in control repo vs separate repo) | design.md — Context / proposal Impact | 0.3 | Decision recorded in approval.yaml | Pending decision |

## Blockers

- No Jira source (internal change) — provide a tracking key or accept as an ADR.
- Approval pending (BA + engineering).
- Open decisions in `approval.yaml`: surface choice (Tauri vs VS Code extension),
  frontend framework (Vite vs Next.js static export), and hosting (module in this
  repo vs separate repo).

## Scope guard

The following must remain untouched by this change:

- Any product-code in a governed service.
- The gate scripts, the change-package schema, and the `/opsx:*` workflow contract.
- caraoke-workspace (invoked only indirectly, through unchanged control scripts).
