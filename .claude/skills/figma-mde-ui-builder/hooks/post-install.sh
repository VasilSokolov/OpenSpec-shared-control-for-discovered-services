#!/bin/bash

if ! declare -F mobctl_secret >/dev/null; then
  echo "Error: you are using an outdated version of mobctl. Please update mobctl and try again."
  echo "Update mobctl with: brew update && brew upgrade mobctl"
  exit 1
fi

FIGMA_MCP_URL="https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/figma/mcp"
MDE_UI_MCP_URL="https://mcp-hub.tool.mde-production.mobint.io/mcp-hub/mde-ui/mcp"

# ─── Helper: extract current Figma token from ~/.claude.json ─────────────────

get_current_figma_token() {
  if [ ! -f ~/.claude.json ]; then echo ""; return; fi
  # Extract the Bearer token from the Authorization header stored for the figma MCP
  python3 -c "
import json, sys
try:
    data = json.load(open('$HOME/.claude.json'))
    figma = data.get('mcpServers', {}).get('figma', {})
    headers = figma.get('headers', {})
    auth = headers.get('Authorization', headers.get('authorization', ''))
    if auth.startswith('Bearer '):
        print(auth[7:])
        sys.exit(0)
except: pass
print('')
" 2>/dev/null
}

# ─── Helper: install figma MCP with a given token ────────────────────────────

install_figma_mcp() {
  local token="$1"
  claude mcp add figma --scope user --transport http "$FIGMA_MCP_URL" \
    -H "Authorization: Bearer $token"
  echo "MCP 'figma' installed."
}

# ─── Mode: --update-token ─────────────────────────────────────────────────────

if [ "$1" = "--update-token" ]; then
  mobctl_secret "Enter your new Figma personal access token"
  figma_token=$REPLY

  if [ -z "$figma_token" ]; then
    echo "Warning: No token provided. Aborting."
    exit 1
  fi

  claude mcp remove figma --scope user 2>/dev/null || true
  install_figma_mcp "$figma_token"
  echo ""
  echo "Figma token updated. Restart Claude Code for the change to take effect."
  exit 0
fi

# ─── Mode: --update-figma ─────────────────────────────────────────────────────

if [ "$1" = "--update-figma" ]; then
  current_token=$(get_current_figma_token)

  if [ -z "$current_token" ]; then
    echo "Error: Could not find existing Figma token in ~/.claude.json."
    echo "Run without --update-figma to do a fresh install."
    exit 1
  fi

  claude mcp remove figma --scope user 2>/dev/null || true
  install_figma_mcp "$current_token"
  echo ""
  echo "Figma MCP updated. Restart Claude Code for the change to take effect."
  exit 0
fi

# ─── Default: fresh install ───────────────────────────────────────────────────

# figma: fetch and enrich Figma designs with mde-ui component and token mappings
if grep -Fq '/mcp-hub/figma/mcp' ~/.claude.json; then
  echo "MCP 'figma' is already installed."
else
  mobctl_secret "Enter your Figma personal access token"
  figma_token=$REPLY

  if [ -z "$figma_token" ]; then
    echo "Warning: No token provided. Skipping figma MCP installation."
    echo "Use your personal Figma token or the shared company token from Vault: https://vault-ui.staging.mobint.io/ui/vault/secrets-engines/mobile/kv/common%2Ffigma_token/details"
  else
    install_figma_mcp "$figma_token"
  fi
fi

# mde-ui: browse the mde-ui React component library
if grep -Fq 'mde-ui:' ~/.claude.json; then
  echo "MCP 'mde-ui' is already installed."
else
  claude mcp add mde-ui --scope user --transport http "$MDE_UI_MCP_URL"
  echo "MCP 'mde-ui' installed."
fi

echo ""
echo "figma-mde-ui-builder: all MCP servers registered."
echo "Restart Claude Code (or start a new conversation) for the tools to load."
