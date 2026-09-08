---
description: Apply an approved OpenSpec change in the MDE control plane — claim a task, provision a caraoke-workspace worktree, run capability agents/skills, implement and record evidence. Alias of /opsx:apply.
argument-hint: "[change id | task id]"
---

# /openspec:apply

Alias of `/opsx:apply` for the MDE OpenSpec SDLC control repository. The
canonical workflow — Git preflight, change-package validation, atomic task
claim, caraoke-workspace worktree provisioning + runtime bootstrap, dynamic
capability detection with the required mde-skills/agents, implementation inside
the worktree, and evidence recording — is defined in
`.claude/commands/opsx/apply.md`, the single source of truth.

Read `.claude/commands/opsx/apply.md` now and execute it exactly, applying any
ARGUMENTS passed to this command. Do not duplicate, summarize, or diverge from
it — the two namespaces must stay identical on every governance gate.
