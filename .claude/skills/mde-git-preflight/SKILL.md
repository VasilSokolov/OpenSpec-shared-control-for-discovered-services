# Mobile.de Git freshness preflight

This skill is mandatory before every `/opsx` command.

1. Identify the control repository and active workset.
2. Run `git fetch --prune --tags` for the control repository.
3. Fetch every repository referenced by the active workset.
4. Resolve the approved control commit or content hash from fetched refs.
5. Refuse stale, unreachable, dirty, or mismatched required checkouts.
6. Never reset, force-push, overwrite, or silently rebase user changes.
7. Record remote, branch, commit, and timestamp in the change work log.

When running inside a code repository, the workspace manager must provide the
local control checkout through `MDE_CONTROL_ROOT`. The code-repository
wrapper delegates the fetch to that control checkout and includes the current
code repository as a workset repository.
