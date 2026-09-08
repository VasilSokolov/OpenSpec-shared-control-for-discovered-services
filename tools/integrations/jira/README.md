# Jira MCP integration

The known-ticket intake calls the MCP tool `fetch_jira_ticket`:

```text
fetch_jira_ticket(
  ticketId=<ticket-key>,
  token=<optional runtime value from JIRA_PAT>,
  baseUrl=<optional runtime value from JIRA_BASE_URL>
)
```

Tokens are runtime-only. They must never be written into the control
repository, OpenSpec context, task evidence, prompts, or logs.

This tool fetches one ticket. It does not provide the current user's active
ticket list. Configure a separate Jira search/list MCP tool before enabling
automatic active-ticket selection.
