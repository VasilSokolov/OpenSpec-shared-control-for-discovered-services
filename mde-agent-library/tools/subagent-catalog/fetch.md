---
name: fetch
description: "Read a full agent definition from the pinned Mobile.de catalog."
---

# Subagent Catalog - Fetch

Get the full definition of a specific agent from the local, approved library.

## Input: $ARGUMENTS

Accepts an agent name or local relative path.

## Instructions

1. Source the local catalog configuration.
2. Resolve the requested name to a file under `categories/`.
3. Display the definition and its declared permissions.
4. Copy it only to the assigned repository and record the selection in
   `skill-manifest.yaml`.

```bash
source <repository>/.claude/commands/subagent-catalog/config.sh
subagent_catalog_ensure_cache
agent_file="${CATALOG_ROOT}/categories/<category>/<agent>.md"
cat "$agent_file"
```

Never fetch agent definitions from a URL during runtime. If the library is
stale, run `/opsx:sync` and repeat the Git preflight.
