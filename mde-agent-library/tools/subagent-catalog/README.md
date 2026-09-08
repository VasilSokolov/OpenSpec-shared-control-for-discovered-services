# subagent-catalog

A Claude Code skill for browsing and fetching agents from the local Mobile.de
agent library.

## Installation

The OpenSpec bootstrap installs this catalog into the control or code
repository. Do not fetch agents from the network at runtime.

```bash
cp -r tools/subagent-catalog <repository>/.claude/commands/
```

## Usage

| Command | Description |
|---------|-------------|
| `/subagent-catalog:search <query>` | Find agents by name, description, or category |
| `/subagent-catalog:fetch <name>` | Get full agent definition |
| `/subagent-catalog:list` | Browse all categories |
| `/subagent-catalog:invalidate` | Clear cache (add `--fetch` to refresh immediately) |

## Examples

**Find security-related agents:**
```
/subagent-catalog:search security
```

**Get the code-reviewer definition:**
```
/subagent-catalog:fetch code-reviewer
```

**Browse all available agents:**
```
/subagent-catalog:list
```

## Features

- **Smart caching**: 12-hour TTL with graceful fallback on network failure
- **Atomic updates**: Uses tmp file + mv pattern to prevent partial writes
- **Cross-platform**: Works on macOS and Linux
- **Best practices**: Follows Anthropic skill authoring guidelines

## Cache

- **Location**: `.runtime/catalog.md` inside the pinned library
- **TTL**: 12 hours (configurable in `config.sh`)
- **Behavior**: Auto-refreshes when stale, falls back to old cache on network failure

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Stale results | `/subagent-catalog:invalidate --fetch` |
| Network error | Check connection, retry |
| Agent not found | `/subagent-catalog:search <partial-name>` first |
