# Task result — infra-reviewer quality gate

- change_id: caraoke-workspace-integration
- gate: /opsx:apply Step 4 (quality — infra-reviewer)
- reviewed_at: 2026-09-08
- reviewer: infra-reviewer (fresh-context subagent)
- scope reviewed:
  - `tools/router/create-worktree.sh` (caraoke delegation backend)
  - `tools/router/bootstrap-worktree.sh` (bootstrap-into-worktree wrapper)
  - `tools/git-preflight.sh` (bash-3.2 empty-array fix, line 127)
  - referenced: `tools/bootstrap-code-repo.sh`

## Verdict

**SAFE.** No destructive or hard-to-reverse operations. All git mutation is
`fetch --prune --tags` and `worktree add`; delegated worktree creation goes
through caraoke's public `make` targets; all filesystem writes are confined to
`<worktree>/.claude/`. No command-injection or word-splitting exposure inside
these scripts (the only trust boundary is caraoke's Makefile, which is external
and out of scope). No BLOCKERs.

- git-preflight.sh line 127 fix confirmed correct: `${REPOSITORIES[@]+"${REPOSITORIES[@]}"}`
  is the canonical bash-3.2 empty-array-under-`set -u` idiom; fetch-only and
  dirty-control guarantees intact.
- WORKTREE_PATH parse (`sed … | tail -n1`) robust across reuse/create branches.
- Idempotent worktree reuse validated before re-use; no re-fetch.
- MDE_CONTROL_ROOT wiring via `<worktree>/.claude/opsx.env` is correct and
  complementary to the `.openspec-workspace.yaml` remote pointer (not redundant).

## Findings and disposition

1. **[FIXED] Slashed branch names desync the reconstructed `dest`.** A branch
   containing `/` would nest under `worktrees/<repo>/` and could mismatch
   caraoke's actual worktree path, producing a false "not created" failure.
   Fix: `create-worktree.sh` caraoke backend now asserts the branch is
   slash-free (matches caraoke's `QCT-XXXX-short-kebab` convention) and exits 2
   with a clear message before any workspace mutation. Verified: rejects
   `feature/bar` with exit 2.

2. **[DEFERRED → follow-up `caraoke-ref-layout-confirmation`]** Existing-branch
   detection probes `refs/heads/$BRANCH` OR `refs/remotes/origin/$BRANCH` in the
   bare repo; whether either namespace is populated depends on caraoke's clone
   mode (`--bare` vs `--mirror`) and `make fetch` refspec. Misclassification is
   non-destructive (a failed `worktree-new` run on an existing branch), but the
   assumption should be confirmed against caraoke's actual ref layout. Cannot be
   verified from this repo. Deferred to a named follow-up work item.

3. **[OUT OF SCOPE — pre-existing]** `git-preflight.sh:128`
   `resolved_repository="$(cd "$repository" && pwd)"` under `set -e` aborts on a
   nonexistent `--repo` path before `fetch_one`'s friendlier message fires.
   Pre-existing and unrelated to the one-line array fix; flagged separately, not
   changed under this change's scope.

4. **[DEFERRED → follow-up `caraoke-ref-layout-confirmation`] (nit)** `emit_path`
   prints the reconstructed `$dest` rather than the validated
   `git rev-parse --show-toplevel` output. Cosmetic (they are equal at that
   point); folded into the same follow-up as finding 2.

## Implementation commits

- `ad3f8cc` — caraoke delegation backend + bootstrap-into-worktree wrapper + docs.
- `d245f78` — git-preflight.sh bash-3.2 empty-array fix + approval.
- this commit — review-driven slash-free branch guard (finding 1), evidence, and
  workset bookkeeping.
