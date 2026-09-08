# MDE OpenSpec SDLC Control Repository

This repository is the shared control plane for specification-driven
development. It contains OpenSpec changes, approvals, dependency evidence,
task ownership, validation evidence, routing tools, and the pinned Claude
runtime bundle.

Product source code remains in the discovered code repositories. The full
OpenSpec change is not copied into those repositories.

## User workflow

Every command begins with the Git freshness preflight:

```text
/opsx:propose
/opsx:apply
/opsx:verify
/opsx:sync
/opsx:archive
```

The preflight fetches the control repository and all repositories in the
current workset. It never resets, overwrites, or silently rebases local work.

## Bootstrap

1. Configure the control repository remote.
2. Configure Jira, Figma, mob-code search, and repository discovery.
3. Import and adapt the complete agent library under
   `mde-agent-library/`.
4. Run `tools/validate-control-repo.sh`.
5. Commit and push the control repository on `master`.
6. Obtain BA and engineering approval for the first change.
7. Bootstrap the selected runtime bundle into each affected code repository.

The runtime integration is intentionally data-driven. Repository IDs, module
IDs, branches, paths, and dependencies are discovered and stored in each
change workset; they are not hardcoded in the router.

## Running with caraoke-workspace

This control plane answers *what and why* (spec + approval + traceability).
`caraoke-workspace` is the execution substrate that answers *where and how*
(checkout + toolchain + build/run/test). It holds no product code: it manages
bare clones under `repos/` and one worktree per branch under
`worktrees/<repo>/<branch>/`, discovering repositories by GitHub topic.

The two repositories stay independent and are connected by a single,
data-driven seam. Control is the outer governance loop; caraoke is the inner
execution substrate that `/opsx:apply` invokes. Never run both orchestrators
at the same altitude. Team paths, hosts, discovery topics, and the Jira/branch
naming rules live in [`CONFIG.md`](CONFIG.md) — nothing below is hardcoded.

### Preconditions

- `caraoke-workspace` checked out locally (default `../Mobile-de/caraoke-workspace`).
- `gh` authenticated to `github.mpi-internal.com` (caraoke targets GitHub
  Enterprise; control scripts are remote-agnostic).

### Where caraoke plugs into the `/opsx:*` lifecycle

The caraoke integration is not a separate procedure you run by hand — it is the
worktree/toolchain backend the opsx commands drive. The caraoke `REPO` name and
the `QCT-XXXX-short-kebab` branch are recorded per work item in the change's
`workset.yaml` (see `caraoke_workspace:` and per-item `branch`), never hardcoded.

| Command         | Caraoke seam                                                                                     |
| --------------- | ------------------------------------------------------------------------------------------------ |
| `/opsx:propose` | Records the `repository_id → caraoke REPO` mapping and `QCT-XXXX-short-kebab` branch per work item in `workset.yaml`. |
| `/opsx:apply`   | Provisions the worktree via the router's caraoke backend, bootstraps the runtime bundle into it, then builds/tests through `run`. |
| `/opsx:verify`  | Re-runs build/test inside the worktree through `run` and collects evidence back into the change package. |
| `/opsx:sync`    | Fetch-only refresh of both control and the worktree remote (`MDE_CONTROL_ROOT` binds them); never resets caraoke worktrees. |
| `/opsx:archive` | Worktree removal is manual and patch-first; apply/archive never script `FORCE=1` `make worktree-rm`. |

### What `/opsx:apply` runs under the hood

```bash
# 1. Provision the worktree (router caraoke backend — fetches first so the
#    branch is not based on a stale default branch, a documented caraoke footgun).
tools/router/create-worktree.sh \
  --caraoke-workspace ../Mobile-de/caraoke-workspace \
  --caraoke-repo <repo> \
  --branch QCT-XXXX-short-kebab
#    -> WORKTREE_PATH=<workspace>/worktrees/<repo>/QCT-XXXX-short-kebab

# 2. Bootstrap the pinned opsx runtime bundle INTO the worktree (never the
#    workspace root, which would clobber caraoke's own .claude config).
#    Exporting MDE_CONTROL_ROOT lets the bundled preflight resolve back here.
tools/bootstrap-code-repo.sh --repo <workspace>/worktrees/<repo>/QCT-XXXX-short-kebab

# 3. Resolve the per-worktree toolchain and run build/test through `run`
#    (mise honours each repo's .nvmrc / .java-version).
eval "$(make -C ../Mobile-de/caraoke-workspace path)"
make -C ../Mobile-de/caraoke-workspace toolchain REPO=<repo>
run ./mvnw verify                    # Java
run yarn install && run yarn test    # Node (check yarn.lock vs package-lock.json)
```

Cleanup with `make worktree-rm` is irreversible without saving a patch first;
do not script `FORCE=1` removal inside apply or archive.
