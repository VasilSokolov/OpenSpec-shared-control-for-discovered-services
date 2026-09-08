## Context

See proposal.md — Why. Two existing systems, kept separate:

- **Control plane** (this repo): OpenSpec governance. User surface is
  `/opsx:{propose,apply,verify,sync,archive}`, each gated by
  `tools/git-preflight.sh`. Affected repositories are discovered dynamically via
  mob-code-search MCP and recorded per-change in worksets
  (`openspec/repository-catalog.yaml` ships empty — nothing is hardcoded).
  `tools/bootstrap-code-repo.sh` installs the pinned `.claude` runtime bundle +
  agent library into a target code repository and writes
  `.openspec-workspace.yaml` (control reference, change_id, workset path,
  `MDE_CONTROL_ROOT`).
- **Execution substrate** (`caraoke-workspace`): no product code; bare clones in
  `repos/`, one worktree per branch in `worktrees/<repo>/<branch>/`. Repositories
  discovered by GitHub topic (`owned-by-mob-team-caraoke`,
  `owned-by-mob-team-swifty`). Toolchains resolved per-worktree via `run`
  (mise, honouring each repo's `.nvmrc`/`.java-version`). Branch convention
  `QCT-XXXX-short-kebab`. Orchestrator session delegates to `caraoke-*`
  subagents.

No design source (Figma) applies — this is internal tooling / architecture.

## Goals / Non-Goals

**Goals:**
- A governed change can obtain a real, buildable worktree per affected repo and
  a path back into the control change package for evidence.
- Reuse caraoke's existing worktree + toolchain machinery instead of
  reimplementing it in the control plane.
- Keep the two repositories independent, with a single, documented,
  data-driven seam.
- Preserve both preflight guarantees (fetch-only, never reset/rebase).

**Non-Goals:**
- Merging the repositories or sharing a git history.
- Owning caraoke's discovery, Makefile, or skill/agent catalog.
- CI/pipeline integration (deferred).
- Any product-code change.

## Key Decisions

### Integrate, do not merge
**Decision**: Keep control and caraoke as two repositories connected by one
adapter. Control is a long-lived, versioned governance artifact (specs,
approvals, evidence); caraoke is ephemeral, `.gitignore`d checkouts with a fast
lifecycle. Coupling them into one repo would bind a slow governance plane to a
volatile dev scratch space.
**Alternative rejected**: Vendoring caraoke into the control repo (or vice
versa) — creates lifecycle/ownership conflict and duplicate discovery.

### Control is the outer loop; caraoke is the inner substrate
**Decision**: `/opsx:*` is the outer governance driver. caraoke's orchestrator
and `caraoke-*` subagents are the inner execution substrate that opsx:apply
invokes. Never run both orchestrators at the same altitude, or their playbooks
compete.
**Alternative rejected**: caraoke as the top-level driver calling opsx — inverts
the approval/traceability gate that must wrap execution.

### Worktree provisioning via caraoke Makefile
**Decision**: `tools/router/create-worktree.sh` delegates (opt-in) to
`make worktree-new REPO=<repo> BRANCH=<branch>` in the caraoke workspace and
returns `worktrees/<repo>/<branch>/`. `make fetch` runs first so the branch is
not based on a stale `master` (a documented caraoke footgun).
**Alternative rejected**: Reimplementing bare-clone + worktree management in the
control plane — duplicates working, battle-tested caraoke logic.

### Bootstrap into the worktree, never the workspace root
**Decision**: Run `bootstrap-code-repo.sh --repo worktrees/<repo>/<branch>`. The
worktree is the actual code repository; bootstrapping there installs the opsx
bundle + pointer next to the code. Never bootstrap into the caraoke root, which
would clobber its own `.claude/settings.json` / `skillOverrides`. Skill names do
not collide (`mde-*` from the bundle vs `caraoke-*` / `mob-*`), so both coexist
in the worktree's `.claude/`.
**Alternative rejected**: Bootstrapping into the workspace root — overwrites
caraoke configuration and mixes altitudes.

### Toolchain through `run`
**Decision**: apply/verify build and test commands are prefixed with caraoke's
`run` from inside the worktree (`eval "$(make path)"` once per shell), so the
repo's pinned `.nvmrc`/`.java-version` is honoured rather than the global mise
runtime. Node repos split between `yarn.lock` and `package-lock.json`; use
`make toolchain REPO=<r>` to resolve the exact command.
**Alternative rejected**: Assuming a global `mvn`/`node` — caraoke documents that
plain `mvn` is not installed and bare `mise exec` returns the global runtime.

### `MDE_CONTROL_ROOT` binds worktree back to control
**Decision**: Export `MDE_CONTROL_ROOT` in the worktree environment so the
bundled `.claude/tools/git-preflight.sh` resolves back to this control repo and
fetches both control and the worktree remote (fetch-only).

### Naming reconciliation
**Decision**: A change keeps its `<page>-<feature>` control `change_id`, and the
workset records the caraoke `REPO` name and the `QCT-XXXX-short-kebab` branch per
work item. The mapping lives in `workset.yaml`, not in code.

## Risks / Trade-offs

- [Two orchestration/skill systems collide] → Fix altitude: control outer, caraoke
  inner; bootstrap only into worktrees so `.claude` bundles don't overwrite each
  other. Names are namespaced (`mde-*` vs `caraoke-*`/`mob-*`).
- [Stale base branch] → Router delegation must `make fetch` before
  `make worktree-new`; skipping bases the branch on stale `master`.
- [GitHub Enterprise auth] → caraoke targets `github.mpi-internal.com`; control
  scripts are remote-agnostic (`git remote get-url origin` + MCP). Requires `gh`
  authenticated to the GHE host; document as a precondition.
- [Discovery divergence] → mob-code-search index vs `gh search repos --topic` may
  briefly disagree on the repo set. Treat mob-code-search as authoritative for the
  change; caraoke topic discovery for physical clone availability. Record the
  `repository_id -> REPO` mapping explicitly.
- [`make worktree-rm` is irreversible without FORCE + patch] → Cleanup steps must
  save a patch first; do not script `FORCE=1` removal inside apply.
- [Naming drift between change_id and QCT branch] → Enforce the mapping in
  `workset.yaml`; validate presence during propose.
