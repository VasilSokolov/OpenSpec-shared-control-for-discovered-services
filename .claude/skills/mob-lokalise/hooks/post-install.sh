#!/bin/bash
if claude mcp list | grep -q "mde-lokalise"; then
  echo "MCP 'mde-lokalise' is already installed."
else
  claude mcp add mde-lokalise --transport http https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/lokalise/mcp --scope user
fi
