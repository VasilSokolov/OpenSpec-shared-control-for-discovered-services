# /opsx:approve

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Approval is an evidence gate, not a status-only edit. Resolve the change
directory from the requested change ID and run:

```bash
./tools/validate-change-package.sh --change <change-directory>
```

If the gate fails, do not mark the change approved. Report the exact source,
scope, screenshot, acceptance-comparison, dependency, security,
observability, test, and deployment blockers.

If the gate passes, verify that BA approval covers business scope and
acceptance criteria and engineering approval covers architecture,
repositories, dependencies, contracts, security, observability, tests, and
deployment. Record approver identity, timestamp, and approved revision in
`approval.yaml`, then mark the change approved. Never invent approval or
silently broaden the generated scope.
