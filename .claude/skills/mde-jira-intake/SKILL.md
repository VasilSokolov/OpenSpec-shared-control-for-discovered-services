# Jira intake

The configured Jira MCP tool for known tickets is `fetch_jira_ticket`.

## Known-ticket flow

When the user supplies a ticket key:

1. Validate the key format.
2. Call `fetch_jira_ticket` with `ticketId` set to the supplied key.
3. Pass `baseUrl` only when the configured Jira instance requires it.
4. Never place a token in a prompt, file, log, or generated specification.
5. Let the connector read `JIRA_PAT` from the runtime environment when needed.
6. Save the complete sanitized response under `context/intake/jira.json`.
7. Normalize the ticket to `context/intake/work-item.yaml`.

The normalized work item must preserve the ticket key, title, description,
issue type, status, reporter, assignee, acceptance criteria, labels,
components, links, and source timestamp when those fields exist.

## Current-user active-ticket flow

`fetch_jira_ticket` retrieves one known ticket. It cannot list the current
user's active or in-progress tickets. Automatic ticket listing requires a
separate Jira search/list MCP tool. Until that tool is configured, ask the user
for the ticket key or let them paste the Jira details.

## Fallback flow

If Jira is unavailable, accept pasted ticket text or a screenshot, record the
source as user-provided, and continue without inventing missing fields.
