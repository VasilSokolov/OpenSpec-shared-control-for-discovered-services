# /opsx:archive

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Archive a change only after all required tasks, verification, approvals,
deployment evidence, and traceability checks are complete. Move the completed
change under `openspec/changes/archive/` and preserve its evidence.
