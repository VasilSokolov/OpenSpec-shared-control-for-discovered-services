#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: tools/validate-change-package.sh --change <path> [--structural-only]

Validates one generated OpenSpec change package. Structural validation checks
the package files, YAML/JSON syntax, declared design evidence, and translation
reference when present.
The default mode also enforces the implementation gate: approval, Jira scope
reconciliation, and visual design validation must be complete.
USAGE
}

change_dir=""
structural_only=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change)
      [[ $# -ge 2 ]] || { echo "Missing value for --change" >&2; usage >&2; exit 2; }
      change_dir="$2"
      shift 2
      ;;
    --structural-only)
      structural_only=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "$change_dir" ]] || { echo "--change is required" >&2; usage >&2; exit 2; }
[[ -d "$change_dir" ]] || { echo "Change directory not found: $change_dir" >&2; exit 2; }

required_files=(
  .openspec.yaml
  approval.yaml
  proposal.md
  design.md
  tasks.md
  workset.yaml
  context/intake/jira.json
  context/intake/work-item.yaml
  context/discovery/repositories.yaml
  context/discovery/acceptance-traceability.md
)

for relative_path in "${required_files[@]}"; do
  [[ -f "$change_dir/$relative_path" ]] || {
    echo "FAIL: missing required file: $relative_path" >&2
    exit 1
  }
done

command -v ruby >/dev/null || {
  echo "FAIL: Ruby is required for YAML/JSON validation" >&2
  exit 1
}

ruby - "$change_dir" <<'RUBY'
require "json"
require "yaml"

change_dir = ARGV.fetch(0)
yaml_files = %w[
  .openspec.yaml
  approval.yaml
  workset.yaml
  context/intake/work-item.yaml
  context/discovery/repositories.yaml
]

yaml_files.each do |relative_path|
  YAML.load_file(File.join(change_dir, relative_path))
  puts "YAML OK: #{relative_path}"
end

JSON.parse(File.read(File.join(change_dir, "context/intake/jira.json")))
puts "JSON OK: context/intake/jira.json"
RUBY

figma_declared=false
if [[ -f "$change_dir/context/intake/figma-reference.md" ]] || \
  grep -Eq '^[[:space:]]*figma_(url|file_key|node_id):' "$change_dir/context/intake/work-item.yaml"; then
  figma_declared=true
fi

if $figma_declared; then
  [[ -f "$change_dir/context/intake/figma-reference.md" ]] || {
    echo "FAIL: a declared Figma source requires context/intake/figma-reference.md" >&2
    exit 1
  }

  node_id="$(awk -F'"' '/figma_node_id:/ { print $2; exit }' "$change_dir/context/intake/work-item.yaml")"
  [[ -n "$node_id" ]] || {
    echo "FAIL: no figma_node_id found for the declared Figma source" >&2
    exit 1
  }

  for relative_path in \
    context/intake/figma-reference.md \
    design.md \
    tasks.md \
    context/discovery/repositories.yaml; do
    grep -Fq "$node_id" "$change_dir/$relative_path" || {
      echo "FAIL: Figma node $node_id is missing from $relative_path" >&2
      exit 1
    }
  done

  "$SCRIPT_DIR/validation/validate-figma-acceptance.sh" \
    --change "$change_dir" \
    --structural-only
fi

if [[ -f "$change_dir/context/intake/translation-reference.md" ]]; then
  grep -Eq '^```tsv$' "$change_dir/context/intake/translation-reference.md" || {
    echo "FAIL: translation reference must contain a fenced TSV table" >&2
    exit 1
  }
  grep -Eq '^```$' "$change_dir/context/intake/translation-reference.md" || {
    echo "FAIL: translation reference TSV fence is not closed" >&2
    exit 1
  }
fi

grep -Eq '^scope: .+$' "$change_dir/workset.yaml" || {
  echo "FAIL: workset.yaml must declare a non-empty scope" >&2
  exit 1
}

echo "STRUCTURAL VALIDATION PASSED: $change_dir"

if $structural_only; then
  exit 0
fi

blocked=false

if grep -Eq '^status: pending$' "$change_dir/approval.yaml"; then
  echo "BLOCKED: approval.yaml status is pending"
  blocked=true
fi

if grep -Eq 'requires_ba_confirmation: true' "$change_dir/context/intake/work-item.yaml"; then
  echo "BLOCKED: Jira scope reconciliation still requires BA confirmation"
  blocked=true
fi

if $figma_declared; then
  if ! "$SCRIPT_DIR/validation/validate-figma-acceptance.sh" --change "$change_dir"; then
    blocked=true
  fi
fi

if $blocked; then
  echo "IMPLEMENTATION GATE BLOCKED: resolve the evidence blockers, then rerun without --structural-only" >&2
  exit 2
fi

echo "IMPLEMENTATION GATE PASSED: $change_dir"
