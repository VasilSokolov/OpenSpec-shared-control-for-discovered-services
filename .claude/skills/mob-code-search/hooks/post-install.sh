#!/bin/bash
if claude mcp list | grep -q "mde-code-search"; then
  echo "MCP 'mde-code-search' is already installed."
else
  claude mcp add mde-code-search --transport http https://mcs.tool.mde-staging00.mobint.io/mcp
fi
