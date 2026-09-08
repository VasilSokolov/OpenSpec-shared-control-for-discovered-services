#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

required_paths=(
  "$CONTROL_ROOT/AGENTS.md"
  "$CONTROL_ROOT/openspec/config.yaml"
  "$CONTROL_ROOT/openspec/project.md"
  "$CONTROL_ROOT/openspec/repository-catalog.yaml"
  "$CONTROL_ROOT/openspec/skill-bundle.yaml"
  "$CONTROL_ROOT/openspec/integrations/jira.yaml"
  "$CONTROL_ROOT/openspec/integrations/mob-code-search.yaml"
  "$CONTROL_ROOT/schemas/workset.schema.yaml"
  "$CONTROL_ROOT/schemas/task-status.schema.yaml"
  "$CONTROL_ROOT/schemas/task-claim.schema.yaml"
  "$CONTROL_ROOT/schemas/skill-manifest.schema.yaml"
  "$CONTROL_ROOT/tools/git-preflight.sh"
  "$CONTROL_ROOT/tools/bootstrap-code-repo.sh"
  "$CONTROL_ROOT/tools/router/create-worktree.sh"
  "$CONTROL_ROOT/tools/validation/validate-figma-acceptance.sh"
  "$CONTROL_ROOT/tools/integrations/jira/README.md"
  "$CONTROL_ROOT/tools/integrations/mob-code-search/README.md"
  "$CONTROL_ROOT/mde-agent-library/source-manifest.yaml"
  "$CONTROL_ROOT/mde-agent-library/LICENSE"
)

for path in "${required_paths[@]}"; do
  [[ -e "$path" ]] || { echo "Missing required path: $path" >&2; exit 1; }
done

for script in "$CONTROL_ROOT"/tools/*.sh "$CONTROL_ROOT"/tools/validation/*.sh "$CONTROL_ROOT"/mde-agent-library/install-agents.sh; do
  [[ -x "$script" ]] || { echo "Script is not executable: $script" >&2; exit 1; }
done

if command -v rg >/dev/null 2>&1; then
  search_branding() {
    rg --hidden -n -i 'github\.com/Mobile\.de|raw\.githubusercontent\.com/Mobile\.de|mobile-de\.dev' \
      "$CONTROL_ROOT/mde-agent-library" \
      --glob '!LICENSE' \
      --glob '!source-manifest.yaml'
  }

  search_identifiers() {
    rg --hidden -n 'repository_id: (ps-|frontend|backend)|module_id: (ps-)' \
      "$CONTROL_ROOT" \
      --glob '!IMPLEMENTATION-PLAN.md' \
      --glob '!openspec/changes/**'
  }
else
  echo "Warning: rg is not installed; using grep fallback" >&2

  search_branding() {
    grep -RInI --exclude='LICENSE' --exclude='source-manifest.yaml' \
      -E 'github\.com/Mobile\.de|raw\.githubusercontent\.com/Mobile\.de|mobile-de\.dev' \
      "$CONTROL_ROOT/mde-agent-library"
  }

  search_identifiers() {
    find "$CONTROL_ROOT" -type f \
      ! -name 'IMPLEMENTATION-PLAN.md' \
      ! -path "$CONTROL_ROOT/openspec/changes/*" \
      -print0 | xargs -0 grep -nHI -E 'repository_id: (ps-|frontend|backend)|module_id: (ps-)'
  }
fi

if search_branding; then
  echo "Found forbidden runtime branding or network endpoint in imported library" >&2
  exit 1
fi

if search_identifiers; then
  echo "Found hardcoded repository or module identifiers" >&2
  exit 1
fi

echo "Control repository structure is valid"
