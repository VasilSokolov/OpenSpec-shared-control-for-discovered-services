---
name: mob-internal-service-api-discovery
description: >-
  Discover internal mobile.de services and explore their REST APIs using the
  mde-swagger-docs MCP server. Use this skill whenever you need to find out what API
  endpoints an internal service provides, understand request/response schemas,
  look up query parameters, check HTTP methods, or figure out how to call a
  specific service. Trigger on questions like "what endpoints does X service
  have", "how do I call the Y API", "find me an API for Z", "what does this
  service do", or any task that requires understanding internal service contracts
  — even if the user doesn't explicitly mention "swagger" or "API docs".
metadata:
  author: mobile.de
  version: "1.0"
  tags: [swagger, api, api-docs, services, discovery, rest, openapi, mcp]
---

# Internal API Discovery with mde-swagger-docs MCP

This skill helps you explore mobile.de's internal service landscape. Hundreds of
microservices expose REST APIs documented via Swagger/OpenAPI specs. The
**mde-swagger-docs MCP server** gives you structured access to all of them — service
listings, endpoint overviews, detailed parameter/response specs, and data model
schemas.

## Setup — Auto-Install the MCP Server

Before using the mde-swagger-docs tools, check whether they are already available
(e.g. `mcp__mde-swagger-docs__list_services` exists). If the tools are **not**
available, install the MCP server by running this command:

```bash
claude mcp add mde-swagger-docs --transport http https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/swagger-docs/mcp
```

After running the command, let the user know the MCP server has been installed
and that they need to **restart Claude Code** (or start a new conversation) for
the tools to become available. The MCP tools are not accessible in the current
session after installation — they only load on startup.

## Tool Overview

You have six tools, designed to be used top-down from broad discovery to specific detail:

| Tool | Purpose | When to use |
|---|---|---|
| `list_services` | List all available services with their load status, API count, and schema count | **Start here.** Always call this first to discover what services exist and get `serviceName` values needed by all other tools |
| `search_apis` | Fuzzy-search endpoints by keyword across all or one service | When looking for functionality by name (e.g. "authentication", "rating", "dealer") without knowing which service owns it |
| `get_service_overview` | Get a grouped index of all endpoints for a service | After identifying a service, to understand its full API surface before drilling into specifics |
| `get_api_endpoint` | Get full endpoint details: parameters, request body, responses, resolved schemas | When you need exact call signatures — what to send and what you'll get back |
| `list_schemas` | List all data model names for a service, with optional substring filter | To discover available data models, especially before calling `get_schema` |
| `get_schema` | Get a fully resolved schema definition with all `$ref` references expanded | When you need the complete structure of a request/response type |

## Recommended Workflow

### 1. Identify the service

If the user names a specific service, go directly to step 2. Otherwise:

- **Call `list_services`** to see everything available. The response includes each
  service's `name`, `title`, `description`, `apiCount`, and `schemaCount`.
- **Call `search_apis`** with a keyword if you're looking for a capability rather
  than a known service name. This searches across path, summary, description,
  operationId, and tags. Omit `serviceName` to search all services at once.

The `name` field from `list_services` is the `serviceName` you'll pass to every
other tool.

### 2. Understand the service's API surface

**Call `get_service_overview`** with the `serviceName`. This returns all endpoints
grouped by tag, with HTTP method, path, summary, and deprecation status. Use
this to orient yourself before diving into details.

### 3. Get endpoint details

**Call `get_api_endpoint`** with `serviceName`, `path`, and `method` to get the
full specification for a specific endpoint:

- Path and query parameters (names, types, required/optional)
- Request body schema (fully resolved, no `$ref` placeholders)
- Response schemas for each status code (200, 400, 404, etc.)
- Security requirements

### 4. Explore data models

If you need to understand a complex type in more depth:

- **Call `list_schemas`** to see all model names. Use the `filter` parameter to
  narrow results (e.g. `filter: "User"` to find user-related models).
- **Call `get_schema`** with a `schemaName` to get the full resolved definition.
  Use `maxDepth` to control how deeply nested `$ref` references are expanded
  (defaults to 10).

## Tips

- **Search broadly first.** When you're not sure which service owns a feature,
  `search_apis` without a `serviceName` searches everything. The results include
  the `serviceName` so you can follow up on the right service.
- **Read overviews before details.** `get_service_overview` is cheap and gives you
  the lay of the land. Use it to pick the right endpoints before making detailed
  `get_api_endpoint` calls.
- **Use tags for grouping.** Service overviews organize endpoints by tags — these
  usually represent logical resource groups (e.g. "User", "Token", "Upload
  Settings") and help you find related endpoints quickly.
- **Check schema counts.** Services with high `schemaCount` in `list_services`
  have rich data models — use `list_schemas` + `get_schema` to understand them.
- **Some services may have `status: "error"`.** This means their Swagger spec
  couldn't be loaded. You can note this to the user but can't explore them further.
