# MDE agent library

This directory contains the complete imported agent catalog adapted for the
Mobile.de specification-driven development workflow.

The library is maintained in the control repository. The bootstrap process
selects and copies only the agents required by the capabilities discovered for
an active change into each code repository.

## Contents

- `categories/` contains the complete imported agent definitions.
- `.claude-plugin/` contains local plugin metadata.
- `tools/subagent-catalog/` contains local catalog helpers.
- `install-agents.sh` installs from this local copy only.
- `source-manifest.yaml` records source revision, checksums, and adaptations.
- `LICENSE` and any required notices are preserved.

## Local installation

Do not download agents at runtime. Use the pinned files in this directory:

```bash
./install-agents.sh --target <code-repository-directory> --all
```

The Mobile.de OpenSpec bootstrap process normally performs this installation
and writes `skill-manifest.yaml` to the target repository.

## Safety

Review every imported agent before enabling write or shell permissions. The
selection must be declared in `openspec/skill-bundle.yaml` and recorded in the
target repository manifest.

This library retains the upstream license and provenance information. Local
branding and workflow adaptations are tracked in `source-manifest.yaml`.
