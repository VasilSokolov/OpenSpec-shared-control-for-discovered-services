# Repository router tool boundary

Resolve workset repository and module IDs, fetch the target repository, create
an isolated worktree, and start the implementation agent with that worktree as
its current directory.

## Backends

`create-worktree.sh` has two backends. Both print `WORKTREE_PATH=<abs>` as their
final stdout line so callers can consume the resolved worktree.

- **standalone** (default) — manage the worktree directly with `git worktree`
  against a local repository path (`--repository`, `--worktree`, `--branch`,
  `--base`).
- **caraoke** — delegate to the caraoke-workspace Makefile, reusing its
  bare-clone + worktree machinery instead of duplicating it. Selected by
  `--caraoke-workspace <path> --caraoke-repo <REPO> --branch <branch>`. It runs
  `make fetch` (fetch-only) then `make worktree` (existing branch) or
  `make worktree-new` (new branch), and returns
  `<workspace>/worktrees/<repo>/<branch>`. `--base` is ignored; caraoke derives
  the base from `origin/<default-branch>`.

caraoke-workspace is never modified — only its public Makefile targets are
called.

## Bootstrap into a caraoke worktree

`bootstrap-worktree.sh` chains provisioning and runtime bootstrap for one
affected repository:

1. `create-worktree.sh` (caraoke backend) → resolves the worktree path.
2. `../bootstrap-code-repo.sh` → installs the pinned `.claude` runtime bundle
   and writes `.openspec-workspace.yaml`.
3. writes `<worktree>/.claude/opsx.env` exporting `MDE_CONTROL_ROOT`, so the
   bundled `git-preflight.sh` resolves back to this control repo.

```sh
tools/router/bootstrap-worktree.sh \
  --caraoke-workspace ../Mobile-de/caraoke-workspace \
  --caraoke-repo ps-listing-node \
  --branch QCT-1234-example \
  --change some-page-feature \
  --repository-id ps-listing-node \
  --approved-revision <commit-or-content-hash>
```

## Runbook (control ↔ caraoke seam)

1. `/opsx:propose` — record affected repos + the `repository_id -> caraoke REPO`
   mapping in the change workset.
2. `bootstrap-worktree.sh …` per affected repo — provision the worktree and
   install the bundle.
3. In the worktree: `eval "$(make -C <caraoke-workspace> path)"` (puts caraoke
   `run` on PATH) and `source .claude/opsx.env` (exports `MDE_CONTROL_ROOT`).
4. `/opsx:apply` — build/test via `run ./mvnw verify` / `run yarn …`.
5. `/opsx:verify` — record evidence back into the change package; approvals gate.

Precondition: `gh` authenticated to `github.mpi-internal.com` and caraoke
`make check` green.
