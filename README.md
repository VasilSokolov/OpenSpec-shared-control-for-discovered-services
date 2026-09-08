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
