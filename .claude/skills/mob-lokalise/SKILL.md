---
name: mob-lokalise
description: >-
  Search and browse translation keys and copy text on Lokalise using the
  mde-lokalise MCP server. Use this skill whenever you need to find a
  translation key for a piece of copy, look up what text a key resolves to,
  search translations across languages, browse keys by tag or platform, or
  check which languages a project supports. Trigger on questions like "what's
  the Lokalise key for X", "find the translation for Y", "search copies for Z",
  "what keys exist for this feature", "which translations contain this text",
  or any task that involves looking up or searching mobile.de translation
  keys and copy — even if the user doesn't explicitly mention "Lokalise" or
  "translations".
metadata:
  author: mobile.de
  version: "1.0"
  tags: [lokalise, translations, i18n, copy, keys, localization, mcp]
---

# Lokalise Translation Search with mde-lokalise MCP

This skill helps you find translation keys and copy text across mobile.de's
Lokalise projects. The **mde-lokalise MCP server** provides read-only access
to all Lokalise translation projects, their keys, and translated values.

## Setup — Auto-Install the MCP Server

Before using the mde-lokalise tools, check whether they are already available
(e.g. `mcp__mde-lokalise__list_projects` exists). If the tools are **not**
available, ask the user to install the MCP server by running this command:

```bash
claude mcp add mde-lokalise --transport http https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/lokalise/mcp --scope user
```

Let the user know that after the MCP server has been installed they need to **restart Claude Code** (or start a new conversation) for
the tools to become available.

## Tool Overview

| Tool | Purpose | When to use |
|---|---|---|
| `list_projects` | List all Lokalise projects with IDs, names, key counts, progress | To discover available projects or help user pick one |
| `get_project` | Get details for a single project (stats, base language, progress) | When you have a project ID and need more info about it |
| `list_project_languages` | List languages configured for a project (ISO codes, RTL, plural forms) | To see which languages a project supports |
| `list_keys` | Browse keys with filtering by tags and platforms, with pagination | To list keys in a project, optionally filtered |
| `search_keys` | Fulltext search across key names, descriptions, and translation values | **Primary search tool.** Find keys by searching for copy text or key names |
| `list_tags` | List all tags in a project with key counts | To understand how keys are organized or filter by feature area |

## Resolving the Project ID

Every tool except `list_projects` requires a `project_id`. Resolve it in this
order:

### 1. Check for `.lokalise.yml`

Look for a `.lokalise.yml` file in the current working directory (or repo root).
If it exists, read the `project_id` from it:

```yaml
# .lokalise.yml
project_id: "123456789abcdef.01"
```

Use this ID directly — no need to ask the user.

### 2. User provided a project name or ID

If the user mentioned a project name or ID in their request, use it. If they
gave a name, call `list_projects` to find the matching project ID.

### 3. Ask the user

If no `.lokalise.yml` exists and the user didn't specify a project, call
`list_projects` to fetch available projects and present them to the user.
Ask which project they want to search in. Format the list clearly:

```
Which Lokalise project do you want to search in?

1. consumer-webapp (12,450 keys, 95% translated)
2. dealer-area (8,200 keys, 89% translated)
3. mobile-apps (15,300 keys, 92% translated)
...
```

Cache the project ID for the rest of the conversation once resolved — don't
ask again unless the user switches projects.

## Recommended Workflow

### Finding a key for a piece of copy

This is the most common task. The user has some visible text (e.g. "Fahrzeug
speichern") and wants to find the translation key for it.

1. Resolve the project ID (see above)
2. Call `search_keys` with the text as `query`
   - If searching for German text, no `language_iso` filter needed (German is
     typically the base language)
   - If searching for English or other language text, set `language_iso`
     accordingly (e.g. `language_iso: "en"`)
3. Present the matching keys with their translations

### Finding what text a key resolves to

The user has a key name (e.g. `I18N.HOMEPAGE.Save_Vehicle`) and wants to see
its translations.

1. Resolve the project ID
2. Call `search_keys` with the key name as `query`
3. Show the key's translations across available languages

### Browsing keys by feature area

The user wants to see all keys related to a feature (e.g. "financing" or
"search filters").

1. Resolve the project ID
2. Call `list_tags` to see available tags — this helps narrow down which tag
   maps to the feature
3. Call `list_keys` with `filter_tags` to get keys for that area
4. Set `include_translations: true` if the user wants to see the actual text

### Searching by platform

If the user is working on a specific platform (iOS, Android, web):

1. Resolve the project ID
2. Call `list_keys` with `filter_platforms` set to the relevant platform
   (values: `ios`, `android`, `web`, `other`)

## Search Tips

- **`search_keys` uses FTS5 syntax** — you can use boolean operators:
  - `"save vehicle"` — exact phrase match
  - `save AND vehicle` — both terms present
  - `save OR bookmark` — either term
  - `save*` — prefix match
- **Start broad, narrow if needed.** A single keyword often returns good results.
  Only add filters if there are too many matches.
- **Use `limit` to control result size.** Default varies; set explicitly if you
  want more or fewer results (max 200 for search_keys, max 500 for list_keys).
- **Tags are your friend for scoping.** If the user is working on a specific
  feature, check `list_tags` first to find the right tag, then filter by it.
