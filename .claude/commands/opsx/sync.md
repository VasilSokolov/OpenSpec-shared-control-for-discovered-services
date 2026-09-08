# /opsx:sync

Before doing anything else, run the repository's pinned Git preflight
(`tools/git-preflight.sh` in control, `.claude/tools/git-preflight.sh` in a
bootstrapped code repository). If it fails, stop.

Fetch the latest control and workset revisions, validate the approved revision,
refresh the repository map and selected skill bundle, and report changed
specifications, dependency states, claims, and task assignments. Do not merge
or overwrite dirty local product work.
