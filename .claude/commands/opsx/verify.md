# /opsx:verify

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Verify the exact approved specification revision against task status, code
commit, contracts, tests, observability, security, deployment, and traceability
evidence. Mark only the verified task state. Revalidate dependent tasks when a
contract or requirement hash changed.
