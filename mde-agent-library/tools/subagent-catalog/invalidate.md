---
name: invalidate
description: "Invalidate the local Mobile.de agent catalog cache."
---

# Subagent Catalog - Invalidate

Refresh the catalog cache from the pinned local library. This command does not
make a network request. Git freshness is handled by the OpenSpec preflight.

## Input: $ARGUMENTS

No arguments required. Use `--fetch` to invalidate and immediately rebuild.

## Instructions

```bash
source <repository>/.claude/commands/subagent-catalog/config.sh
subagent_catalog_invalidate_cache
```

If `$ARGUMENTS` contains `--fetch`, also run:

```bash
subagent_catalog_refresh_cache
```

Report that the cache was refreshed from the pinned library.
