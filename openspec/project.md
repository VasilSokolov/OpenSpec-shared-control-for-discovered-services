# MDE specification project

Use OpenSpec as the only user-facing workflow. Mobile.de-specific behavior is
implemented through the pinned `.claude` commands, skills, discovery tools,
router, coordination layer, and validation tools.

The control repository owns the shared specification. Code repositories own
product source code and receive only a generated runtime bundle plus a pointer
to the approved change.

## Change naming

Use `<page>-<feature>` or `<page>-<feature>-<action>`. Jira is optional intake
metadata inside the change folder.

## Required implementation evidence

Each affected task must identify its repository and module, claim owner,
worktree, branch, commit, tests, API/data contracts, observability checks,
security checks, deployment checks, and validation evidence.
