#!/usr/bin/env bash

# Mandatory freshness check for every /opsx command.
# This script fetches refs only. It never pulls, resets, rebases, or overwrites.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REMOTE_NAME="origin"
CHANGE_ID=""
ALLOW_UNCONFIGURED=false
REPOSITORIES=()

usage() {
  cat <<'EOF'
Usage:
  tools/git-preflight.sh [options]

Options:
  --repo <path>          Fetch another repository; repeatable.
  --remote <name>        Git remote to fetch (default: origin).
  --change <change-id>   Append fetched revisions to the change work log.
  --allow-unconfigured   Bootstrap-only exception for a repository without a remote.
  --help                 Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 2; }
      REPOSITORIES+=("$2")
      shift 2
      ;;
    --remote)
      [[ $# -ge 2 ]] || { echo "Missing value for --remote" >&2; exit 2; }
      REMOTE_NAME="$2"
      shift 2
      ;;
    --change)
      [[ $# -ge 2 ]] || { echo "Missing value for --change" >&2; exit 2; }
      CHANGE_ID="$2"
      shift 2
      ;;
    --allow-unconfigured)
      ALLOW_UNCONFIGURED=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

is_git_repository() {
  git -C "$1" rev-parse --show-toplevel >/dev/null 2>&1
}

fetch_one() {
  local repository="$1"
  local label="$2"
  local branch
  local commit
  local remote_url
  local dirty

  [[ -d "$repository" ]] || {
    echo "[$label] repository path does not exist: $repository" >&2
    return 1
  }
  is_git_repository "$repository" || {
    echo "[$label] not a Git repository: $repository" >&2
    return 1
  }

  if ! remote_url="$(git -C "$repository" remote get-url "$REMOTE_NAME" 2>/dev/null)"; then
    if [[ "$ALLOW_UNCONFIGURED" == true ]]; then
      echo "[$label] no '$REMOTE_NAME' remote; bootstrap exception accepted"
    else
      echo "[$label] no '$REMOTE_NAME' remote; configure Git before /opsx" >&2
      return 1
    fi
  else
    echo "[$label] fetching $remote_url"
    git -C "$repository" fetch --prune --tags "$REMOTE_NAME"
  fi

  branch="$(git -C "$repository" symbolic-ref --short -q HEAD || echo detached)"
  if commit="$(git -C "$repository" rev-parse HEAD 2>/dev/null)"; then
    :
  else
    commit="unborn"
  fi
  dirty="$(git -C "$repository" status --porcelain)"

  if [[ -n "$dirty" && "$label" == control ]]; then
    echo "[control] working tree is dirty; commit or isolate changes before /opsx" >&2
    return 1
  fi

  echo "[$label] branch=$branch commit=$commit"
  printf '%s\t%s\t%s\t%s\n' "$label" "$REMOTE_NAME" "$branch" "$commit"

  if [[ -n "$CHANGE_ID" ]]; then
    local log_file="$CONTROL_ROOT/openspec/changes/$CHANGE_ID/context/work-log.yaml"
    mkdir -p "$(dirname "$log_file")"
    {
      echo "- fetched_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "  repository_label: $label"
      echo "  repository_path: $repository"
      echo "  remote: $REMOTE_NAME"
      echo "  branch: $branch"
      echo "  commit: $commit"
    } >> "$log_file"
  fi
}

fetch_one "$CONTROL_ROOT" control

for repository in ${REPOSITORIES[@]+"${REPOSITORIES[@]}"}; do
  resolved_repository="$(cd "$repository" && pwd)"
  [[ "$resolved_repository" == "$CONTROL_ROOT" ]] && continue
  fetch_one "$resolved_repository" code
done
