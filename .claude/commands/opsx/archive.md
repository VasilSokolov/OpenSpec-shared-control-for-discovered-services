# /opsx:archive

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Archive a change only after all required tasks, verification, approvals,
deployment evidence, and traceability checks are complete. Move the completed
change under `openspec/changes/archive/` and preserve its evidence.

If the change provisioned caraoke worktrees (`caraoke_workspace:` in the
workset), archiving governs only the control-plane change package; it never
removes the caraoke worktrees for you. `make worktree-rm` is irreversible
without a saved patch, so leave worktree teardown to the operator — do not
script `FORCE=1` removal. Record the final worktree/branch names in the
archived workset so the checkout can be reconstructed later if needed.
