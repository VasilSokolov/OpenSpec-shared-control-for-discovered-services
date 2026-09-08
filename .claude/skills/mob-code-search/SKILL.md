---
name: mob-code-search
description: >-
  Search and explore mobile.de's microservice source code using the
  mde-code-search MCP server. Use this skill whenever you need to find where a
  symbol is defined, understand how a service is implemented, read source code
  from a specific repo, locate files matching a pattern, get a high-level
  overview of a repository's tech stack, or ask AI-powered questions about a
  codebase. Trigger on questions like "find where X is implemented", "how does
  service Y handle Z", "show me the source of this class", "which repo contains
  logic for W", "search for code that does X", or any task that requires reading
  or navigating actual source code across mobile.de's microservices — even if
  the user doesn't explicitly mention "code search" or a specific repo name.
metadata:
  author: mobile.de
  version: "1.0"
  tags: [code-search, source-code, repositories, microservices, semantic-search, symbols, mcp]
---

# Microservice Code Search with mde-code-search MCP

This skill helps you navigate and understand mobile.de's microservice source
code. The **mde-code-search MCP server** is backed by a semantic vector database
that indexes source files across all of mobile.de's GitHub repositories. You
can search by meaning (not just keywords), read raw source, navigate symbols,
explore directory structures, and ask AI agents questions about a codebase.

## Setup — Auto-Install the MCP Server

Before using the mde-code-search tools, check whether they are already available
(e.g. `mcp__mde-code-search__search` exists). If the tools are **not** available,
install the MCP server by running this command:

```bash
claude mcp add mde-code-search --transport http https://mcs.tool.mde-staging00.mobint.io/mcp
```

After running the command, let the user know the MCP server has been installed
and that they need to **restart Claude Code** (or start a new conversation) for
the tools to become available. The MCP tools are not accessible in the current
session after installation — they only load on startup.

## Tool Overview

You have fifteen tools across four groups: **Search**, **Discovery**,
**Exploration**, and **Write/LLM**. The Write/LLM tools may not be available
when the server is running in lite mode.

| Tool | Purpose | When to use |
|---|---|---|
| `search` | Semantic vector search across all indexed repos | **Primary entry point.** Find code by describing what it does in natural language |
| `find_symbol` | Find where a named symbol (class, function, interface) is defined | When you know the symbol name and want its definition location |
| `read_code` | Read raw source at a code reference (`owner/repo:path@commit`) | When you have a `ref` and need the full or partial file content |
| `read_symbol` | Read only the source of one specific symbol from a file | When `file_outline` or `find_symbol` gave you a ref and you want just that symbol |
| `file_outline` | List all symbols defined in a file | To understand a file's structure before reading specific parts |
| `list_indexed_repos` | List all repos in the vector DB with pagination | **Start here for repo discovery.** See what is indexed before searching |
| `list_orgs` | List accessible GitHub organizations | To see which GitHub orgs are available |
| `list_org_repos` | List all repos in a GitHub org (live API) | When you need the full org repo list, including non-indexed repos |
| `system_status` | Show task queue, DB health, and cache stats | To check server health or diagnose slow results |
| `repo_overview` | High-level overview of a repo: structure, tech stack, top-level dirs | When you first land in an unfamiliar repo |
| `list_directory` | List directory contents in a repo | To navigate a repo's directory tree |
| `find_files` | Find files matching a glob pattern in a repo | When you know roughly what a file is called or where it lives |
| `ensure_indexed` | Index a repo into the vector DB (or force re-index) | When `list_indexed_repos` shows a repo is missing |
| `ask_repo` | AI agent for git/GitHub questions (commits, PRs, branches, history) | For questions about repo activity, not source content |
| `ask` | AI agent for code understanding questions, optionally scoped to a repo | For open-ended "how does this work" questions when direct search isn't enough |

## Key Concepts

### Code References (`ref`)

Many tools accept or return a `ref` string in the format:

```
owner/repo:path/to/file.ts@commitsha
owner/repo:path/to/file.ts@commitsha:startLine-endLine
```

The `ref` is the primary currency of navigation: `search` and `find_symbol`
return refs in their results, and `read_code`, `read_symbol`, and `file_outline`
consume refs as input. Always use the exact `ref` from a previous result — do
not construct refs manually.

### Indexed vs. Live Repos

`list_indexed_repos` only shows repos in the vector database (available for
semantic search). `list_org_repos` hits the live GitHub API and shows all repos
in an org, including those not yet indexed. If you need to search a repo that
is not indexed, use `ensure_indexed` first.

### Lite Mode

The `ensure_indexed`, `ask`, and `ask_repo` tools may be disabled when the
server runs in lite mode. If a tool call returns an error indicating it is
unavailable, fall back to the direct search and read tools.

## Recommended Workflow

### 1. Orient yourself in the codebase

If you are not sure which repo contains the code you need:

- **Call `list_indexed_repos`** to see what is available. Use `org` to filter
  by GitHub organization and `offset`/`limit` for pagination if there are many
  repos.
- **Call `repo_overview`** on a candidate repo to see its top-level structure
  and detected tech stack before diving in.

If a specific repo is already known, skip directly to step 2.

### 2. Search for the code

Depending on what you are looking for:

- **Searching by concept or behavior?** Call `search` with a natural-language
  description (e.g. `query: "rate limiting middleware for REST endpoints"`).
  Use the `language` filter to narrow to a specific language, or `code_snippet:
  true` to bias results toward code rather than documentation.
- **Searching for a named symbol?** Call `find_symbol` with the class, function,
  or interface name. Partial matches work — `symbol: "UserAuth"` will match
  `UserAuthService`, `UserAuthFilter`, etc. Optionally scope to a `repo` or
  `language`.
- **Searching for a file by name or path pattern?** Call `find_files` with a
  `repo` and a glob `pattern` (e.g. `pattern: "**/*Controller.java"`).

Both `search` and `find_symbol` return `ref` values in their results. Keep
these — they are the input to every subsequent navigation step.

### 3. Read the source

- **Full file or a range of lines?** Call `read_code` with the `ref`. Use
  `context_lines` to pad line ranges with surrounding context. Defaults to
  returning the full file if no line range is specified in the ref.
- **One specific symbol?** Call `read_symbol` with the file-level `ref` and
  the `symbol` name to get only that symbol's source — more efficient than
  reading the full file.
- **Not sure what is in the file?** Call `file_outline` with the `ref` first to
  get a list of all symbols with their kinds, signatures, and line numbers, then
  call `read_symbol` on the ones you need.

### 4. Navigate the directory structure

When you need to understand the layout of a repo or find files without a name
to search for:

- **Call `list_directory`** with a `repo` and optional `path` to browse
  directories. Use `include_counts` to see how many files each subdirectory
  contains.
- **Call `find_files`** with a glob pattern to locate files by name or extension
  across a repo.

### 5. Ask AI when direct search isn't enough

If the code is hard to find through search (e.g. behavior is spread across many
files, or you need to understand git history):

- **Call `ask`** with a free-form question and an optional `repo` scope. This
  invokes an AI agent that reasons over the indexed codebase.
- **Call `ask_repo`** for questions about commits, pull requests, branches, or
  release history — things that require git metadata rather than source content.

Note: these tools are slower than direct search and may not be available in
lite mode. Use them as a last resort or for synthesis tasks.

## Tips

- **Prefer `search` over `ask` for finding code.** Semantic search is fast and
  precise for locating specific logic. Reserve `ask` for questions that require
  synthesizing across multiple files or explaining a concept.
- **Use `find_symbol` for class and function lookups.** When the user names a
  specific class, function, or interface, `find_symbol` is more precise than a
  general `search` and returns directly usable refs.
- **Chain refs forward.** The output `ref` from `search`, `find_symbol`, and
  `file_outline` is the direct input to `read_code`, `read_symbol`, and
  `file_outline`. Pass refs through without modification.
- **Scope searches when possible.** If you know the repo or language, always
  pass `repo` and `language` to `search` and `find_symbol`. Scoped searches are
  faster and return less noise.
- **Check `list_indexed_repos` before reporting "not found".** If a search
  returns no results, the repo may simply not be indexed yet. Confirm with
  `list_indexed_repos` and offer to call `ensure_indexed` if it is missing.
- **`repo_overview` is free.** It is a cheap structural summary — always call it
  when the user asks about an unfamiliar service before trying to search inside
  it.
