# /opsx:validate

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Validate the selected OpenSpec change package and its source evidence. The
agent, not the user, must run the checks and return a concise evidence report.

1. Resolve the change directory from the requested change ID; do not infer a
   repository, ticket, URL, or module from a hardcoded value.
2. Run `tools/validate-change-package.sh --change <change-directory>
   --structural-only`.
3. If a design source is declared, open the exact source through the
   configured connector or authenticated browser, capture a screenshot/export
   under `context/evidence/`, and compare it with every normalized Jira
   acceptance criterion in a separate review file.
4. Run `tools/validate-change-package.sh --change <change-directory>`.
5. Report passed checks, unresolved blockers, source versions/timestamps,
   screenshot paths, and the acceptance-criteria comparison result.

This command is optional for users because `/opsx:propose` and
`/opsx:approve` run the same gates automatically. It exists for an explicit
status check and for rerunning validation after evidence changes.
