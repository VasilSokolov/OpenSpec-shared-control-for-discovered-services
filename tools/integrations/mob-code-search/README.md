# Mob-code-search MCP integration

The control workflow uses the installed MCP tools directly:

```text
mcs_system_status
mcs_list_indexed_repos
mcs_search
mcs_find_symbol
mcs_read_symbol
mcs_file_outline
mcs_ask
```

`mcs_list_indexed_repos` supplies repository IDs. The router uses those IDs in
worksets; it never derives ownership from the current directory or from a
hardcoded repository name.

Before discovery, the workflow checks system health. Search results are saved
with their references and indexed revision so later verification can detect
stale or changed code.
