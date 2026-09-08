#!/bin/bash
if claude mcp list | grep -q "mde-swagger-docs"; then
  echo "MCP 'mde-swagger-docs' is already installed."
else
  claude mcp add mde-swagger-docs --transport http https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/swagger-docs/mcp
fi
