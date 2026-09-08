#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/validation/validate-figma-acceptance.sh \
  --change <path> [--structural-only]

Validates the evidence contract for a declared design source. The agent must
capture the selected design node, store the screenshot/export in the change,
and write a criterion-by-criterion visual comparison before approval.
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

reference="$change_dir/context/intake/figma-reference.md"
[[ -f "$reference" ]] || {
  echo "FAIL: missing design source reference: $reference" >&2
  exit 1
}

for field in URL 'File key' 'Node ID' 'validation_status' 'screenshot_path' 'acceptance_review_path'; do
  grep -Eiq "^[[:space:]]*(-[[:space:]]*)?(${field}):" "$reference" || {
    echo "FAIL: missing design evidence field '$field' in $reference" >&2
    exit 1
  }
done

status="$(sed -nE 's/^[[:space:]]*validation_status:[[:space:]]*[`\"]?([^`\"]+)[`\"]?[[:space:]]*$/\1/p' "$reference" | head -1)"
screenshot_path="$(sed -nE 's/^[[:space:]]*screenshot_path:[[:space:]]*[`\"]?([^`\"]*)[`\"]?[[:space:]]*$/\1/p' "$reference" | head -1)"
review_path="$(sed -nE 's/^[[:space:]]*acceptance_review_path:[[:space:]]*[`\"]?([^`\"]+)[`\"]?[[:space:]]*$/\1/p' "$reference" | head -1)"

if [[ "$status" == "pending_visual_validation" ]]; then
  echo "BLOCKED: design visual validation is pending"
elif [[ "$status" != "validated" ]]; then
  echo "BLOCKED: unsupported design validation status: ${status:-missing}"
fi

if $structural_only; then
  echo "DESIGN EVIDENCE STRUCTURE VALID: $reference"
  exit 0
fi

[[ "$status" == "validated" ]] || exit 2
[[ -n "$screenshot_path" ]] || {
  echo "BLOCKED: screenshot_path is empty" >&2
  exit 2
}
[[ "$screenshot_path" != /* && "$screenshot_path" != ../* && "$screenshot_path" != */../* ]] || {
  echo "FAIL: screenshot_path must stay inside the change directory" >&2
  exit 1
}
[[ -s "$change_dir/$screenshot_path" ]] || {
  echo "BLOCKED: design screenshot/export not found: $screenshot_path" >&2
  exit 2
}

[[ -n "$review_path" ]] || {
  echo "BLOCKED: acceptance_review_path is empty" >&2
  exit 2
}
[[ "$review_path" != /* && "$review_path" != ../* && "$review_path" != */../* ]] || {
  echo "FAIL: acceptance_review_path must stay inside the change directory" >&2
  exit 1
}
review="$change_dir/$review_path"
[[ -s "$review" ]] || {
  echo "BLOCKED: design-to-acceptance review not found: $review_path" >&2
  exit 2
}

grep -Eiq 'acceptance' "$review" || {
  echo "FAIL: design-to-acceptance review does not identify acceptance criteria" >&2
  exit 1
}
grep -Eiq 'result|status|comparison|observation' "$review" || {
  echo "FAIL: design-to-acceptance review has no comparison result" >&2
  exit 1
}

if grep -Eiq '\|[[:space:]]*(blocked|pending|fail|failed)[[:space:]]*\|' "$review"; then
  echo "BLOCKED: design-to-acceptance review contains unresolved criteria"
  exit 2
fi

echo "DESIGN SCREENSHOT AND ACCEPTANCE COMPARISON PASSED: $reference"
