#!/usr/bin/env bash

# Install the pinned runtime bundle into one existing code repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_REPOSITORY=""
REPOSITORY_ID=""
CHANGE_ID=""
APPROVED_REVISION=""
CONTROL_REFERENCE=""
SETUP_PLAYWRIGHT=false

usage() {
  cat <<'EOF'
Usage:
  tools/bootstrap-code-repo.sh \
    --repo <code-repository> \
    --repository-id <discovered-id> \
    --change <change-id> \
    --approved-revision <commit-or-content-hash> \
    --control-reference <remote-url-or-repository-reference> \
    [--playwright]

Options:
  --playwright   Also run setup-playwright.sh for frontend repositories.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) TARGET_REPOSITORY="$2"; shift 2 ;;
    --repository-id) REPOSITORY_ID="$2"; shift 2 ;;
    --change) CHANGE_ID="$2"; shift 2 ;;
    --approved-revision) APPROVED_REVISION="$2"; shift 2 ;;
    --control-reference) CONTROL_REFERENCE="$2"; shift 2 ;;
    --playwright) SETUP_PLAYWRIGHT=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$TARGET_REPOSITORY" && -n "$REPOSITORY_ID" && -n "$CHANGE_ID" && -n "$APPROVED_REVISION" ]] || {
  usage >&2
  exit 2
}

TARGET_REPOSITORY="$(cd "$TARGET_REPOSITORY" && pwd)"
git -C "$TARGET_REPOSITORY" rev-parse --show-toplevel >/dev/null 2>&1 || {
  echo "Target is not a Git repository: $TARGET_REPOSITORY" >&2
  exit 1
}

if [[ -z "$CONTROL_REFERENCE" ]]; then
  CONTROL_REFERENCE="$(git -C "$CONTROL_ROOT" remote get-url origin 2>/dev/null || true)"
fi

[[ -n "$CONTROL_REFERENCE" ]] || {
  echo "Control repository has no remote reference; pass --control-reference or configure origin" >&2
  exit 1
}

"$SCRIPT_DIR/git-preflight.sh" --repo "$TARGET_REPOSITORY" --allow-unconfigured

LIBRARY_ROOT="$CONTROL_ROOT/mde-agent-library"
[[ -d "$LIBRARY_ROOT/categories" ]] || {
  echo "Agent library is incomplete: $LIBRARY_ROOT/categories" >&2
  exit 1
}

runtime_root="$TARGET_REPOSITORY/.claude"
mkdir -p "$runtime_root/commands/opsx" "$runtime_root/skills" "$runtime_root/tools"
rsync -a "$CONTROL_ROOT/.claude/commands/opsx/" "$runtime_root/commands/opsx/"
cat > "$runtime_root/tools/git-preflight.sh" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONTROL_ROOT="${MDE_CONTROL_ROOT:-}"

[[ -n "$CONTROL_ROOT" ]] || {
  echo "MDE_CONTROL_ROOT is required when /opsx runs from a code repository" >&2
  exit 1
}

exec "$CONTROL_ROOT/tools/git-preflight.sh" --repo "$CODE_ROOT" "$@"
EOF
chmod +x "$runtime_root/tools/git-preflight.sh"

common_skills=(
  mde-openspec-core
  mde-git-preflight
  mde-repository-discovery
  mde-dependency-analysis
  mde-multi-repository-router
  mde-task-coordination
  mde-approval-policy
  mde-validation
)
for skill in "${common_skills[@]}"; do
  rsync -a "$CONTROL_ROOT/.claude/skills/$skill/" "$runtime_root/skills/$skill/"
done

"$LIBRARY_ROOT/install-agents.sh" --target "$TARGET_REPOSITORY" --all

pointer="$TARGET_REPOSITORY/.openspec-workspace.yaml"
cat > "$pointer" <<EOF
control_repository: $CONTROL_REFERENCE
spec_root: openspec
change_id: $CHANGE_ID
approved_revision: $APPROVED_REVISION
repository_id: $REPOSITORY_ID
workset: context/worksets/$REPOSITORY_ID.yaml
EOF

if [[ "$SETUP_PLAYWRIGHT" == true ]]; then
  "$SCRIPT_DIR/setup-playwright.sh" --repo "$TARGET_REPOSITORY"
fi

echo "Bootstrapped $TARGET_REPOSITORY for change $CHANGE_ID"
