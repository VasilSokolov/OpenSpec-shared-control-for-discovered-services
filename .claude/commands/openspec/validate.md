---
description: Run the OpenSpec change-package + design-evidence validation gates on demand in the MDE control plane and return a concise evidence report. Alias of /opsx:validate.
argument-hint: "[change id]"
---

# /openspec:validate

Alias of `/opsx:validate` for the MDE OpenSpec SDLC control repository. The
canonical workflow — structural and full change-package validation plus the
design screenshot-to-acceptance comparison — is defined in
`.claude/commands/opsx/validate.md`, the single source of truth.

Read `.claude/commands/opsx/validate.md` now and execute it exactly, applying
any ARGUMENTS passed to this command. Do not duplicate, summarize, or diverge
from it — the two namespaces must stay identical on every governance gate.
