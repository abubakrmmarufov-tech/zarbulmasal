#!/usr/bin/env bash
# Runs every pre-commit check and prints PASS/FAIL per step.
#
# Usage: bash tool/check_all.sh
#
# Environment:
#   PAGES_DIR      per-page text dumps of docs/literature/pdfs/*.pdf
#                  (pages/<pdf name>/<n>.txt from `pdftotext -layout -f n -l n`).
#                  Built into a temporary directory when unset.
#   SPACING_OUT    when set, also run the spacing audit and write its
#                  screenshots there (UI tasks).
#   ONLY           comma-separated step names to run (default: all).
#
# Exits 1 when any step fails. Steps keep running after a failure so one run
# shows every problem.
set -uo pipefail

cd "$(dirname "$0")/.."

results=()
failed=0

wants() {
  [[ -z "${ONLY:-}" ]] && return 0
  [[ ",${ONLY}," == *",$1,"* ]]
}

step() {
  local name="$1"
  shift
  wants "$name" || return 0
  local log
  log="$(mktemp -t "check-${name}.XXXXXX")"
  printf '… %s\n' "$name"
  if "$@" >"$log" 2>&1; then
    results+=("PASS  $name")
  else
    results+=("FAIL  $name  (log: $log)")
    failed=1
    tail -n 30 "$log" | sed 's/^/    /'
  fi
}

build_pages_dir() {
  local dir="$1" pdf name count page
  for pdf in docs/literature/pdfs/*.pdf; do
    name="$(basename "$pdf" .pdf)"
    mkdir -p "$dir/$name"
    count="$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')"
    for ((page = 1; page <= count; page++)); do
      pdftotext -layout -f "$page" -l "$page" "$pdf" "$dir/$name/$page.txt"
    done
  done
}

format_check() {
  dart format --output=none --set-exit-if-changed \
    lib test tool/validate_literature_json.dart \
    tool/validate_literary_content.dart \
    tool/build_runtime_literature.dart \
    tool/verify_runtime_literature.dart
}

runtime_catalog_in_sync() {
  dart run tool/build_runtime_literature.dart &&
    git diff --exit-code -- assets/data/literature/runtime_works.json
}

source_inventory_in_sync() {
  python3 tool/literature_pipeline/scripts/discover_pdfs.py &&
    git diff --exit-code -- docs/literature/SOURCE_INVENTORY.md
}

duplicate_and_portrait_guards() {
  python3 tool/test_merge_duplicate_works.py &&
    python3 tool/test_extract_portraits.py
}

shell_syntax() {
  local script
  for script in tool/*.sh; do
    bash -n "$script" || return 1
  done
}

bundle_alignment_tests() {
  python3 -m unittest tool.test_android_bundle_alignment &&
    python3 tool/test_android_bundle_alignment.py -q
}

flutter_tests() {
  flutter test --coverage
}

coverage_gate() {
  python3 tool/check_coverage.py coverage/lcov.info --minimum 80
}

textbook_poem_audit() {
  local pages="${PAGES_DIR:-}"
  if [[ -z "$pages" ]]; then
    pages="$(mktemp -d -t zarbulmasal-pages.XXXXXX)"
    build_pages_dir "$pages"
  fi
  PYTHONDONTWRITEBYTECODE=1 python3 tool/literature/audit_textbook_poems.py "$pages"
}

# The onboarding tour overlays the dimmed page, which the audit cannot tell
# from a collision, so its findings are left to a visual check.
spacing_audit() {
  mkdir -p "$SPACING_OUT"
  SPACING_OUT="$SPACING_OUT" flutter test tool/design/spacing_audit_test.dart &&
    python3 - "$SPACING_OUT/findings.json" <<'PY'
import json, sys
results = json.load(open(sys.argv[1]))
bad = {k: v for k, v in results.items()
       if not k.startswith('onboarding_') and (v['errors'] or v['findings'])}
for key, value in sorted(bad.items()):
    print(key, value['errors'][:2], value['findings'][:3])
print(f'{len(results)} variants, {len(bad)} with findings or errors')
sys.exit(1 if bad else 0)
PY
}

step format format_check
step validate-json dart run tool/validate_literature_json.dart
step runtime-catalog runtime_catalog_in_sync
step verify-runtime dart run tool/verify_runtime_literature.dart
step validate-content dart run tool/validate_literary_content.dart
step provenance-linter python3 tool/provenance_linter.py
step provenance-adversarial python3 tool/provenance_repair_loop5_adversarial.py
step source-inventory source_inventory_in_sync
step duplicate-portrait-guards duplicate_and_portrait_guards
step unittest-literature python3 -m unittest discover -s tool/literature -p 'test_*.py'
step unittest-history python3 -m unittest discover -s tool/history -p 'test_*.py'
step unittest-design python3 -m unittest discover -s tool/design -p 'test_*.py'
step unittest-books python3 -m unittest discover -s tool/books -p 'test_*.py'
step provenance-guards python3 -m unittest tool.test_provenance_detector \
  tool.test_provenance_linter_sources tool.test_validate_literary_content_report
step deep-browser-audit python3 -m unittest tool.test_deep_browser_audit
step shell-syntax shell_syntax
step bundle-alignment bundle_alignment_tests
step coverage-gate-tests python3 -m unittest tool.test_check_coverage
step textbook-poem-audit textbook_poem_audit
step analyze flutter analyze
step flutter-test flutter_tests
step coverage coverage_gate
if [[ -n "${SPACING_OUT:-}" ]]; then
  step spacing-audit spacing_audit
fi

printf '\n'
printf '%s\n' "${results[@]}"
if ((failed)); then
  printf '\nSome checks FAILED.\n'
  exit 1
fi
printf '\nAll checks PASSED.\n'
