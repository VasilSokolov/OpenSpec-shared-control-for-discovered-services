#!/usr/bin/env bash

# Create or reuse an isolated worktree for one discovered repository.
#
# Two backends:
#   standalone (default) — manage the worktree directly with `git worktree`.
#   caraoke              — delegate to the caraoke-workspace Makefile
#                          (`make fetch` + `make worktree`/`worktree-new`),
#                          selected by --caraoke-workspace. This reuses caraoke's
#                          bare-clone + worktree machinery instead of duplicating it.
#
# The last stdout line is always `WORKTREE_PATH=<absolute-path>` so callers
# (the bootstrap wrapper, the router) can consume the resolved worktree.

set -euo pipefail

REPOSITORY=""
WORKTREE=""
BRANCH=""
BASE_REF=""
CARAOKE_WORKSPACE=""
CARAOKE_REPO=""

usage() {
  cat <<'EOF'
Usage:
  Standalone backend:
    tools/router/create-worktree.sh \
      --repository <repository-path> \
      --worktree <generated-worktree-path> \
      --branch <implementation-branch> \
      --base <approved-base-ref>

  caraoke backend (delegates to caraoke-workspace Makefile):
    tools/router/create-worktree.sh \
      --caraoke-workspace <path-to-caraoke-workspace> \
      --caraoke-repo <caraoke-REPO-name> \
      --branch <implementation-branch>

The caraoke backend derives the base ref from origin/<default-branch> (caraoke's
own rule) and returns <workspace>/worktrees/<repo>/<branch>. --base is ignored
in caraoke mode.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repository) REPOSITORY="$2"; shift 2 ;;
    --worktree) WORKTREE="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --base) BASE_REF="$2"; shift 2 ;;
    --caraoke-workspace) CARAOKE_WORKSPACE="$2"; shift 2 ;;
    --caraoke-repo) CARAOKE_REPO="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

emit_path() {
  # Machine-readable resolved worktree path, always the final stdout line.
  echo "WORKTREE_PATH=$1"
}

# --------------------------------------------------------------------------
# caraoke backend
# --------------------------------------------------------------------------
if [[ -n "$CARAOKE_WORKSPACE" ]]; then
  [[ -n "$CARAOKE_REPO" && -n "$BRANCH" ]] || {
    echo "caraoke backend requires --caraoke-repo and --branch" >&2
    usage >&2
    exit 2
  }

  # caraoke's branch convention is QCT-XXXX-short-kebab (slash-free). A slashed
  # branch would nest under worktrees/<repo>/ and desync the reconstructed dest
  # from caraoke's actual worktree path, producing a false "not created" failure.
  case "$BRANCH" in
    */*)
      echo "caraoke backend: branch must be slash-free (QCT-XXXX-short-kebab): $BRANCH" >&2
      exit 2
      ;;
  esac

  command -v make >/dev/null || { echo "make is required for the caraoke backend" >&2; exit 1; }

  WORKSPACE="$(cd "$CARAOKE_WORKSPACE" && pwd)" || {
    echo "caraoke workspace not found: $CARAOKE_WORKSPACE" >&2
    exit 1
  }
  [[ -f "$WORKSPACE/Makefile" ]] || {
    echo "Not a caraoke workspace (no Makefile): $WORKSPACE" >&2
    exit 1
  }

  bare_repo="$WORKSPACE/repos/$CARAOKE_REPO.git"
  [[ -d "$bare_repo" ]] || {
    echo "Repository not cloned in caraoke workspace: $bare_repo" >&2
    echo "Run 'make -C $WORKSPACE clone' (or clone-contrib) first." >&2
    exit 1
  }

  dest="$WORKSPACE/worktrees/$CARAOKE_REPO/$BRANCH"

  # Reuse an existing worktree without re-fetching.
  if [[ -d "$dest" ]] && git -C "$dest" rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "Reusing existing caraoke worktree: $dest"
    emit_path "$dest"
    exit 0
  fi

  # Fetch-only: caraoke's `fetch` never resets/rebases. Skipping it would base a
  # new branch on a stale master (a documented caraoke footgun).
  echo "Fetching caraoke repositories (fetch-only)..."
  make -C "$WORKSPACE" fetch >/dev/null

  # Existing branch (local or remote) -> `worktree`; otherwise a new branch -> `worktree-new`.
  if git -C "$bare_repo" show-ref --verify --quiet "refs/heads/$BRANCH" \
    || git -C "$bare_repo" show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
    make -C "$WORKSPACE" worktree REPO="$CARAOKE_REPO" BRANCH="$BRANCH"
  else
    make -C "$WORKSPACE" worktree-new REPO="$CARAOKE_REPO" BRANCH="$BRANCH"
  fi

  git -C "$dest" rev-parse --show-toplevel >/dev/null 2>&1 || {
    echo "caraoke worktree was not created at expected path: $dest" >&2
    exit 1
  }

  echo "caraoke worktree ready: $dest"
  emit_path "$dest"
  exit 0
fi

# --------------------------------------------------------------------------
# standalone backend (default)
# --------------------------------------------------------------------------
[[ -n "$REPOSITORY" && -n "$WORKTREE" && -n "$BRANCH" && -n "$BASE_REF" ]] || {
  usage >&2
  exit 2
}

REPOSITORY="$(cd "$REPOSITORY" && pwd)"
WORKTREE_PARENT="$(dirname "$WORKTREE")"
mkdir -p "$WORKTREE_PARENT"
WORKTREE="$(cd "$WORKTREE_PARENT" && pwd)/$(basename "$WORKTREE")"

git -C "$REPOSITORY" rev-parse --show-toplevel >/dev/null 2>&1 || {
  echo "Not a Git repository: $REPOSITORY" >&2
  exit 1
}

git -C "$REPOSITORY" fetch --prune --tags origin

if [[ -d "$WORKTREE" ]]; then
  if git -C "$WORKTREE" rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "Reusing existing worktree: $WORKTREE"
    emit_path "$WORKTREE"
    exit 0
  fi
  echo "Worktree path exists but is not a Git worktree: $WORKTREE" >&2
  exit 1
fi

if git -C "$REPOSITORY" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git -C "$REPOSITORY" worktree add "$WORKTREE" "$BRANCH"
else
  git -C "$REPOSITORY" worktree add -b "$BRANCH" "$WORKTREE" "$BASE_REF"
fi

echo "Created worktree: $WORKTREE"
emit_path "$WORKTREE"
