# Control repository instructions

This repository is the specification and coordination source of truth.

- Do not add product source code here.
- Do not hardcode individual repository names in orchestration logic.
- Every active change must have a feature-based change ID.
- Jira keys are metadata, not directory names.
- The approved specification revision is immutable during implementation.
- Every `/opsx` command must run the Git freshness preflight first.
- Never reset, force-push, overwrite, or silently rebase user changes.
- A task must be atomically claimed before an implementation agent starts.
- Record repository, module, worktree, branch, commit, tests, and evidence for
  every task.
- Preserve source licenses and provenance for imported agent definitions.
