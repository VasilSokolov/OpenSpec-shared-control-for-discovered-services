#!/usr/bin/env bash

# Provision a caraoke worktree for one affected repository and install the
# pinned opsx runtime bundle into it.
#
# Chains:
#   1. tools/router/create-worktree.sh  (caraoke backend) -> resolves worktree path
#   2. tools/bootstrap-code-repo.sh      -> installs .claude bundle + pointer
#   3. records MDE_CONTROL_ROOT so the bundled preflight resolves back to control
#
# Never modifies caraoke-workspace itself; it only calls its public Makefile
# targets through create-worktree.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CARAOKE_WORKSPACE=""
CARAOKE_REPO=""
BRANCH=""
CHANGE_ID=""
REPOSITORY_ID=""
APPROVED_REVISION=""
CONTROL_REFERENCE=""
SETUP_PLAYWRIGHT=false

usage() {
  cat <<'EOF'
Usage:
  tools/router/bootstrap-worktree.sh \
    --caraoke-workspace <path-to-caraoke-workspace> \
    --caraoke-repo <caraoke-REPO-name> \
    --branch <implementation-branch> \
    --change <change-id> \
    --repository-id <discovered-id> \
    [--approved-revision <commit-or-content-hash>] \
    [--control-reference <remote-url-or-repository-reference>] \
    [--playwright]

If --approved-revision is omitted it defaults to "pending-approval" (prototype
dry-runs only). If --control-reference is omitted the control repo's origin
remote is used.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --caraoke-workspace) CARAOKE_WORKSPACE="$2"; shift 2 ;;
    --caraoke-repo) CARAOKE_REPO="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --change) CHANGE_ID="$2"; shift 2 ;;
    --repository-id) REPOSITORY_ID="$2"; shift 2 ;;
    --approved-revision) APPROVED_REVISION="$2"; shift 2 ;;
    --control-reference) CONTROL_REFERENCE="$2"; shift 2 ;;
    --playwright) SETUP_PLAYWRIGHT=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$CARAOKE_WORKSPACE" && -n "$CARAOKE_REPO" && -n "$BRANCH" && -n "$CHANGE_ID" && -n "$REPOSITORY_ID" ]] || {
  usage >&2
  exit 2
}

if [[ -z "$APPROVED_REVISION" ]]; then
  APPROVED_REVISION="pending-approval"
  echo "WARNING: --approved-revision not supplied; using '$APPROVED_REVISION' (prototype dry-run only)." >&2
fi

# 1. Provision the worktree via the caraoke backend and capture its path.
create_output="$("$SCRIPT_DIR/create-worktree.sh" \
  --caraoke-workspace "$CARAOKE_WORKSPACE" \
  --caraoke-repo "$CARAOKE_REPO" \
  --branch "$BRANCH")"
echo "$create_output"

worktree_path="$(printf '%s\n' "$create_output" | sed -n 's/^WORKTREE_PATH=//p' | tail -n1)"
[[ -n "$worktree_path" && -d "$worktree_path" ]] || {
  echo "Could not resolve worktree path from create-worktree.sh output" >&2
  exit 1
}

# 2. Install the pinned runtime bundle into the worktree.
bootstrap_args=(
  --repo "$worktree_path"
  --repository-id "$REPOSITORY_ID"
  --change "$CHANGE_ID"
  --approved-revision "$APPROVED_REVISION"
)
[[ -n "$CONTROL_REFERENCE" ]] && bootstrap_args+=(--control-reference "$CONTROL_REFERENCE")
$SETUP_PLAYWRIGHT && bootstrap_args+=(--playwright)

"$CONTROL_ROOT/tools/bootstrap-code-repo.sh" "${bootstrap_args[@]}"

# 3. Record MDE_CONTROL_ROOT so the bundled preflight/opsx runtime resolves
#    back to this control repo. The bundled git-preflight.sh reads this env var.
env_file="$worktree_path/.claude/opsx.env"
mkdir -p "$(dirname "$env_file")"
cat > "$env_file" <<EOF
# Sourced before running /opsx from this bootstrapped worktree.
export MDE_CONTROL_ROOT="$CONTROL_ROOT"
EOF

echo
echo "Bootstrapped caraoke worktree for change $CHANGE_ID:"
echo "  worktree:         $worktree_path"
echo "  repository_id:    $REPOSITORY_ID"
echo "  approved_revision: $APPROVED_REVISION"
echo
echo "Before running /opsx from the worktree, load the toolchain and control root:"
echo "  eval \"\$(make -C $CARAOKE_WORKSPACE path)\"   # puts caraoke 'run' on PATH"
echo "  source \"$env_file\"                            # exports MDE_CONTROL_ROOT"
