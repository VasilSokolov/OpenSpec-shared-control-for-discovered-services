## Why

This control repository (`OpenSpec-shared-control-for-discovered-services`,
duplicated from `mde-sdlc-control`) is a governance control plane for
specification-driven development: it owns OpenSpec changes, approvals,
dependency/validation evidence, and cross-repository traceability. It does not
hold product code and it does not physically check out the services it governs.

`caraoke-workspace` (local at `../Mobile-de/caraoke-workspace`, remote on
`github.mpi-internal.com/mobile-de-incubation`) is a multi-repository execution
substrate for the `mob-team-caraoke` / `mob-team-swifty` services. It has no
product code of its own — it manages bare clones under `repos/` and one worktree
per branch under `worktrees/<repo>/<branch>/`, driven by a Makefile that
discovers repositories by GitHub topic.

The two systems are complementary, not overlapping: control answers *what and
why* (spec + approval + traceability); caraoke answers *where and how* (checkout
+ toolchain + build/run/test). Today they are unaware of each other, so a
governed change has no automated path to a real, buildable worktree and back.

This change proposes wiring caraoke-workspace as the **execution / worktree
provider** underneath the control plane's OpenSpec workflow, without merging the
two repositories. The seam already exists: `tools/bootstrap-code-repo.sh`
installs the pinned runtime bundle into an arbitrary code-repository path and
writes an `.openspec-workspace.yaml` pointer with `MDE_CONTROL_ROOT` — and a
caraoke worktree directory *is* exactly such a path.

There is no Jira ticket and no design source for this change; it is internal
tooling / architecture. It is therefore recorded with `status: proposed` and
kept unapprovable (see `approval.yaml`) until the naming and ownership decisions
are confirmed.

## What Changes

- **Worktree provisioning seam**: `tools/router/create-worktree.sh` gains an
  optional delegation path that shells out to caraoke's `make worktree-new
  REPO=<repo> BRANCH=<branch>` and returns the resulting
  `worktrees/<repo>/<branch>/` path, instead of only creating a local worktree
  in isolation. Delegation is opt-in and data-driven (config, not hardcoded).
- **Bootstrap into a caraoke worktree**: document and script the invocation of
  `tools/bootstrap-code-repo.sh --repo <caraoke-worktrees-path>` per affected
  repository in a change, exporting `MDE_CONTROL_ROOT` so the bundled preflight
  resolves back to this control repo.
- **Toolchain adapter**: the apply/verify steps run build and test through
  caraoke's `run` wrapper (mise-resolved runtimes) from inside the worktree
  (`run ./mvnw verify`, `run yarn …`) rather than assuming a global toolchain.
- **Naming reconciliation**: define the `change_id` <-> QCT ticket <-> caraoke
  branch (`QCT-XXXX-short-kebab`) mapping and record it in the workset.
- **Discovery alignment**: document that control's mob-code-search discovery and
  caraoke's `gh search repos --topic` cover the same repository universe, and
  how a discovered `repository_id` maps to a caraoke `REPO` name.

## Capabilities

### New Capabilities
- `execution-workspace-provisioning`: a change can request a real, buildable
  worktree for each affected repository from caraoke-workspace and receive back
  its filesystem path.
- `worktree-runtime-bootstrap`: the pinned opsx runtime bundle is installed into
  a caraoke worktree with a pointer back to this control repo.

### Modified Capabilities
- `multi-repository-router`: gains an optional caraoke delegation backend for
  worktree creation while preserving the existing standalone path.
- `git-preflight`: bundled preflight in a bootstrapped caraoke worktree resolves
  `MDE_CONTROL_ROOT` and fetches both control and the worktree remote.

## Impact

- `tools/router/create-worktree.sh` — optional caraoke `make worktree-new`
  delegation backend.
- `tools/bootstrap-code-repo.sh` — no change required; documented usage against
  caraoke worktree paths.
- `openspec/repository-catalog.yaml` / per-change `workset.yaml` — record the
  caraoke `REPO` name and branch alongside the discovered `repository_id`.
- Documentation (`README.md` / `openspec/project.md`) — describe the control ↔
  caraoke seam and the outer/inner orchestration altitude.
- No product code in any governed service is modified by this change.
- `caraoke-workspace` itself is **not** modified: it is invoked through its
  existing public Makefile targets (`make worktree-new`, `make fetch`, `make
  path`, `run`).

## Out of Scope

- Merging `caraoke-workspace` and this control repository into one repository.
- Changing caraoke's Makefile, skill catalog (`mob-ai-skills` / `caraoke-*`), or
  its orchestration model.
- Replacing control's mob-code-search discovery with caraoke's topic discovery,
  or vice versa.
- Any product-feature change in a governed service.
- CI wiring / GitHub Actions changes (a later change once the local seam works).
