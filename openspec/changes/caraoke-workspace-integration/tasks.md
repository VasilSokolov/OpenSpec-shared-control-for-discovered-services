## 0. Decisions and preconditions

- [ ] 0.1 Confirm the integration seam: control is the outer opsx loop, caraoke
  is the inner execution substrate (no competing orchestrators).
- [ ] 0.2 Confirm worktree-creation ownership (control delegates to
  `make worktree-new`, or control only bootstraps into an existing worktree).
- [ ] 0.3 Define and record the `change_id` <-> QCT ticket <-> caraoke branch
  (`QCT-XXXX-short-kebab`) mapping.
- [ ] 0.4 Record the precondition that `gh` is authenticated to
  `github.mpi-internal.com` and caraoke `make check` passes.

## 1. Worktree provisioning seam

- [ ] 1.1 Add an opt-in caraoke delegation backend to
  `tools/router/create-worktree.sh` that runs `make fetch` then
  `make worktree-new REPO=<repo> BRANCH=<branch>` in the configured caraoke
  workspace and returns `worktrees/<repo>/<branch>/`.
- [ ] 1.2 Keep the existing standalone worktree path as the default; delegation
  is selected by config, never hardcoded.
- [ ] 1.3 Surface the resolved worktree path into the change workset.

## 2. Runtime bootstrap into a caraoke worktree

- [ ] 2.1 Document and script `tools/bootstrap-code-repo.sh --repo
  worktrees/<repo>/<branch>` per affected repository.
- [ ] 2.2 Export `MDE_CONTROL_ROOT` in the worktree environment and verify the
  bundled `.claude/tools/git-preflight.sh` resolves back to this control repo.
- [ ] 2.3 Verify `.claude` bundle coexistence: `mde-*` bundle skills do not
  overwrite caraoke's `.claude/settings.json` / `caraoke-*` / `mob-*` skills.

## 3. Toolchain adapter

- [ ] 3.1 Document `eval "$(make path)"` + `run <cmd>` usage for apply/verify.
- [ ] 3.2 Resolve per-repo build/test via `make toolchain REPO=<r>` and record
  it in the workset (yarn vs npm, Java version).
- [ ] 3.3 Confirm build/test run inside the worktree, not from a global runtime.

## 4. Discovery alignment

- [ ] 4.1 Document that mob-code-search (control) and `gh search repos --topic`
  (caraoke) cover the same repository universe.
- [ ] 4.2 Record the `repository_id -> caraoke REPO` mapping in the workset /
  `repository-catalog.yaml`.

## 5. Documentation

- [ ] 5.1 Update `README.md` / `openspec/project.md` with the control ↔ caraoke
  seam and the outer/inner orchestration altitude.
- [ ] 5.2 Add a runbook: propose → provision worktree → bootstrap → apply via
  `run` → verify → evidence back to the change package.

## 6. Verification

- [ ] 6.1 Dry-run the seam end to end against one caraoke repo worktree with a
  throwaway branch (no product-code change), capturing command output.
- [ ] 6.2 Confirm both preflights remain fetch-only (no reset/rebase/overwrite).
- [ ] 6.3 Confirm `make worktree-rm` cleanup saves a patch first and never uses
  `FORCE=1` from within apply.
- [ ] 6.4 Run `tools/validate-control-repo.sh` and this change's
  `tools/validate-change-package.sh` gate; record results.

## 7. Scope guard

- [ ] 7.1 Confirm no product-code change in any governed service.
- [ ] 7.2 Confirm `caraoke-workspace` is invoked only through existing public
  Makefile targets and is not modified.
- [ ] 7.3 Confirm the two repositories remain separate (no merge, no shared git
  history).
