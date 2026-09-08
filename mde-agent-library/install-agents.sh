#!/usr/bin/env bash

# Install selected local Mobile.de agent definitions into a code repository.
# This installer never fetches agents from the network.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT=""
COPY_ALL=false
SELECTED_CATEGORIES=()

usage() {
  cat <<'EOF'
Usage:
  ./install-agents.sh --target <code-repository> --all
  ./install-agents.sh --target <code-repository> --category <directory>

Options:
  --target      Existing code repository receiving the runtime bundle.
  --all         Copy every local category.
  --category    Copy one category; may be supplied more than once.
  --help        Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
      TARGET_ROOT="$2"
      shift 2
      ;;
    --all)
      COPY_ALL=true
      shift
      ;;
    --category)
      [[ $# -ge 2 ]] || { echo "Missing value for --category" >&2; exit 2; }
      SELECTED_CATEGORIES+=("$2")
      shift 2
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

if [[ -z "$TARGET_ROOT" ]]; then
  echo "--target is required" >&2
  usage >&2
  exit 2
fi

TARGET_ROOT="$(cd "$TARGET_ROOT" && pwd)"
[[ -d "$TARGET_ROOT/.git" ]] || {
  echo "Target is not a Git repository: $TARGET_ROOT" >&2
  exit 1
}

if [[ "$COPY_ALL" == false && ${#SELECTED_CATEGORIES[@]} -eq 0 ]]; then
  echo "Select --all or at least one --category" >&2
  exit 2
fi

TARGET_DIR="$TARGET_ROOT/.claude/skills/mde-agent-library"
mkdir -p "$TARGET_DIR/categories"

if [[ "$COPY_ALL" == true ]]; then
  rsync -a "$SCRIPT_DIR/categories/" "$TARGET_DIR/categories/"
else
  for category in "${SELECTED_CATEGORIES[@]}"; do
    source_category="$SCRIPT_DIR/categories/$category"
    [[ -d "$source_category" ]] || {
      echo "Unknown category: $category" >&2
      exit 1
    }
    mkdir -p "$TARGET_DIR/categories/$category"
    rsync -a "$source_category/" "$TARGET_DIR/categories/$category/"
  done
fi

rsync -a "$SCRIPT_DIR/.claude-plugin/" "$TARGET_DIR/.claude-plugin/"
cp "$SCRIPT_DIR/README.md" "$TARGET_DIR/README.md"
cp "$SCRIPT_DIR/LICENSE" "$TARGET_DIR/LICENSE"
cp "$SCRIPT_DIR/source-manifest.yaml" "$TARGET_DIR/source-manifest.yaml"

manifest_commit="$(awk '/^source_commit:/{print $2; exit}' "$SCRIPT_DIR/source-manifest.yaml")"
generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat > "$TARGET_ROOT/.claude/skill-manifest.yaml" <<EOF
bundle_id: mde-skill-bundle
bundle_version: 0.1.0
source_library: mde-agent-library
source_revision: ${manifest_commit:-unknown}
generated_at: $generated_at
skills:
  - mde-openspec-core
  - mde-git-preflight
  - mde-repository-discovery
  - mde-dependency-analysis
  - mde-multi-repository-router
  - mde-task-coordination
  - mde-approval-policy
  - mde-validation
  - mde-agent-library
permissions:
  - read-source
  - write-assigned-worktree
  - run-declared-tests
EOF

echo "Installed local Mobile.de agent bundle into $TARGET_DIR"
