#!/usr/bin/env bash

# Local atomic claim fallback for development. Production must replace this
# with the shared coordination service so separate clones share one lock.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHANGE_ID=""
TASK_ID=""
OWNER=""
REPOSITORY_ID=""
WORKTREE_ID=""
SPEC_REVISION=""
LEASE_MINUTES=60

usage() {
  cat <<'EOF'
Usage:
  tools/coordination/claim-task.sh \
    --change <change-id> --task <task-id> --owner <owner> \
    --repository-id <id> --worktree-id <id> --spec-revision <revision>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change) CHANGE_ID="$2"; shift 2 ;;
    --task) TASK_ID="$2"; shift 2 ;;
    --owner) OWNER="$2"; shift 2 ;;
    --repository-id) REPOSITORY_ID="$2"; shift 2 ;;
    --worktree-id) WORKTREE_ID="$2"; shift 2 ;;
    --spec-revision) SPEC_REVISION="$2"; shift 2 ;;
    --lease-minutes) LEASE_MINUTES="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$CHANGE_ID" && -n "$TASK_ID" && -n "$OWNER" && -n "$REPOSITORY_ID" && -n "$WORKTREE_ID" && -n "$SPEC_REVISION" ]] || {
  usage >&2
  exit 2
}

claims_dir="$CONTROL_ROOT/openspec/changes/$CHANGE_ID/context/claims"
claim_file="$claims_dir/$TASK_ID.yaml"
claim_lock="$claims_dir/$TASK_ID.lock"
mkdir -p "$claims_dir"

if ! mkdir "$claim_lock" 2>/dev/null; then
  echo "Task already claimed: $TASK_ID" >&2
  [[ -f "$claim_file" ]] && sed -n '1,120p' "$claim_file"
  exit 3
fi

cleanup() { rmdir "$claim_lock" 2>/dev/null || true; }
trap cleanup EXIT

lease_expires_at="$(date -u -v+"${LEASE_MINUTES}"M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "+${LEASE_MINUTES} minutes" +%Y-%m-%dT%H:%M:%SZ)"

cat > "$claim_file" <<EOF
task_id: $TASK_ID
owner: $OWNER
repository_id: $REPOSITORY_ID
worktree_id: $WORKTREE_ID
spec_revision: $SPEC_REVISION
claimed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
lease_expires_at: $lease_expires_at
status: claimed
EOF

echo "Claimed task $TASK_ID for $OWNER"
