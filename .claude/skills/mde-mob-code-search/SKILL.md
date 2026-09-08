# Mob-code search

Use the installed mob-code-search MCP tools for repository and dependency
discovery. Never infer a target from the current shell directory or hardcode
repository names. Save all results under the active change's
`context/discovery/` directory.

## Tool mapping

| MCP tool | Use |
|---|---|
| `mcs_system_status` | Verify the search service is healthy before discovery |
| `mcs_list_indexed_repos` | Discover indexed repository IDs and metadata |
| `mcs_search` | Search code, references, imports, APIs, and configuration |
| `mcs_find_symbol` | Locate definitions and usages of a symbol |
| `mcs_read_symbol` | Read the implementation behind a search result |
| `mcs_file_outline` | Understand file/module structure before assigning a task |
| `mcs_ask` | Ask repository-specific questions when direct search is insufficient |

## Required discovery sequence

1. Call `mcs_system_status` and stop if the service is unhealthy.
2. Call `mcs_list_indexed_repos` and record the returned repository IDs.
3. Search the requested feature, API, domain terms, and Jira acceptance terms
   with `mcs_search`.
4. Use `mcs_find_symbol`, `mcs_read_symbol`, and `mcs_file_outline` to verify
   ownership and implementation boundaries.
5. Use `mcs_ask` only for questions that cannot be answered from direct code
   evidence, and mark those results as inferred.
6. Record query parameters, result references, indexed revision, and timestamp
   in `repository-map.json` and `dependency-report.md`.

Search results are evidence, not approval. A newly discovered repository or
dependency must be added to the workset and reviewed by engineering before
implementation.
