---
description: Run the BA + engineering approval evidence gate for an OpenSpec change in the MDE control plane — validate the package, then record approver, timestamp, and approved revision. Alias of /opsx:approve.
argument-hint: "[change id]"
---

# /openspec:approve

Alias of `/opsx:approve` for the MDE OpenSpec SDLC control repository. The
canonical workflow — evidence-gate validation before any status edit, and
recording BA/engineering approval in `approval.yaml` — is defined in
`.claude/commands/opsx/approve.md`, the single source of truth.

Read `.claude/commands/opsx/approve.md` now and execute it exactly, applying any
ARGUMENTS passed to this command. Do not duplicate, summarize, or diverge from
it — the two namespaces must stay identical on every governance gate.
