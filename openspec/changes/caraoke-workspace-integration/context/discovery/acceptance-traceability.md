# Acceptance traceability — caraoke-workspace-integration

Status: proposed / unapprovable — internal tooling change with no Jira source and
no design source. Blocked on approval and the ownership/naming decisions in
`approval.yaml` (open_questions). No visual evidence phase applies.

## Source note

There is no Jira ticket and no Figma design for this change. It is internal
tooling / architecture. The intake in `context/intake/jira.json` records
`source: none`. This file must not be marked complete until BA and engineering
approve the integration seam and the naming/ownership decisions.

## Traceability matrix

| Acceptance criterion | Design evidence | Planned task(s) | Verification | Status |
|---|---|---|---|---|
| Governed change obtains a real, buildable worktree per affected repo | design.md — "Worktree provisioning via caraoke Makefile" | 1.1–1.3 | 6.1 dry-run against a throwaway branch | Pending approval |
| Runtime bundle bootstrapped into a caraoke worktree with pointer back to control | design.md — "Bootstrap into the worktree, never the workspace root" + "MDE_CONTROL_ROOT binds worktree back to control" | 2.1–2.3 | 6.1 pointer + preflight resolution | Pending approval |
| apply/verify build and test run through caraoke `run` from inside the worktree | design.md — "Toolchain through run" | 3.1–3.3 | 6.1 captured command output | Pending approval |
| Two repositories remain separate; caraoke invoked only via public Makefile targets | design.md — "Integrate, do not merge" | 7.1–7.3 | 6.1 no caraoke modification | Pending approval |
| Both preflights remain fetch-only | design.md — "MDE_CONTROL_ROOT binds worktree back to control" | 2.2, 6.2 | 6.2 confirm no reset/rebase/overwrite | Pending approval |
| Discovery universe aligned; repository_id -> caraoke REPO mapping recorded | design.md — Risks "Discovery divergence" | 4.1–4.2 | workset.yaml + repository-catalog.yaml review | Pending approval |
| Orchestration altitude fixed (control outer, caraoke inner) | design.md — "Control is the outer loop; caraoke is the inner substrate" | 0.1 | Decision recorded in approval.yaml | Pending decision |

## Blockers

- No Jira source (internal change) — provide a tracking key or accept as an ADR.
- Approval pending (BA + engineering).
- Open decisions in `approval.yaml`: worktree-creation ownership, change_id ↔ QCT
  branch naming mapping, orchestration altitude confirmation.

## Scope guard

The following must remain untouched by this change:

- Any product-code in a governed service.
- caraoke-workspace's Makefile, skill catalog, and orchestration model.
- The separation of the two repositories (no merge, no shared git history).
