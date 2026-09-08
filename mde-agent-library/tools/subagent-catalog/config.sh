#!/usr/bin/env bash

# Local Mobile.de agent catalog configuration.
# Runtime discovery is intentionally offline and reads the pinned control
# repository snapshot. Repository freshness is handled by the OpenSpec Git
# preflight, not by this catalog helper.

set -euo pipefail

CATALOG_ROOT="${MDE_AGENT_LIBRARY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
readonly SUBAGENT_CATALOG_TTL_SECONDS=0
readonly SUBAGENT_CATALOG_SOURCE_FILE="$CATALOG_ROOT/README.md"
readonly SUBAGENT_CATALOG_CACHE_FILE="$CATALOG_ROOT/.runtime/catalog.md"

export CATALOG_ROOT SUBAGENT_CATALOG_TTL_SECONDS
export SUBAGENT_CATALOG_SOURCE_FILE SUBAGENT_CATALOG_CACHE_FILE

subagent_catalog_log_info() { echo "$1"; }
subagent_catalog_log_error() { echo "ERROR: $1" >&2; }

subagent_catalog_get_mtime() {
  date -r "$1" +%s
}

subagent_catalog_format_age() {
  local seconds=$1
  if [ "$seconds" -lt 60 ]; then
    echo "${seconds}s"
  elif [ "$seconds" -lt 3600 ]; then
    echo "$(( seconds / 60 ))m"
  else
    echo "$(( seconds / 3600 ))h"
  fi
}

_subagent_catalog_fetch() {
  mkdir -p "$(dirname "$SUBAGENT_CATALOG_CACHE_FILE")"
  cp "$SUBAGENT_CATALOG_SOURCE_FILE" "$SUBAGENT_CATALOG_CACHE_FILE.tmp"
  mv "$SUBAGENT_CATALOG_CACHE_FILE.tmp" "$SUBAGENT_CATALOG_CACHE_FILE"
}

subagent_catalog_ensure_cache() {
  _subagent_catalog_fetch
  subagent_catalog_log_info "local catalog refreshed"
}

subagent_catalog_refresh_cache() {
  _subagent_catalog_fetch
  subagent_catalog_log_info "local catalog refreshed"
}

subagent_catalog_invalidate_cache() {
  rm -f "$SUBAGENT_CATALOG_CACHE_FILE"
  subagent_catalog_log_info "local catalog cache invalidated"
}
