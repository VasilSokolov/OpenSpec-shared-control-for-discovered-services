---
description: Fetch-only refresh of control + caraoke worktree revisions in the MDE control plane — validate approved revision, refresh repo map and skill bundle, report drift without overwriting local work. Alias of /opsx:sync.
argument-hint: "[change id]"
---

# /openspec:sync

Alias of `/opsx:sync` for the MDE OpenSpec SDLC control repository. The
canonical workflow — fetch-only refresh on both sides of the caraoke seam,
approved-revision validation, and drift reporting — is defined in
`.claude/commands/opsx/sync.md`, the single source of truth.

Read `.claude/commands/opsx/sync.md` now and execute it exactly, applying any
ARGUMENTS passed to this command. Do not duplicate, summarize, or diverge from
it — the two namespaces must stay identical on every governance gate.
