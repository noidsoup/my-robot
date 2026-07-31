#!/usr/bin/env bash
# .verify.sh — L0 ground-truth gate for my-robot itself.
set -uo pipefail
cd "$(dirname "$0")"

FAILED=0
run_step() {
  local label="$1"; shift
  echo "── $label ──"
  if "$@"; then
    echo "   ✓ $label"
  else
    rc=$?
    echo "   ✗ $label (exit $rc)"
    FAILED=1
    return $rc
  fi
}

run_step "smoke bootstrap" bash tests/smoke_bootstrap.sh

if command -v shellcheck >/dev/null 2>&1; then
  run_step "shellcheck" shellcheck -x bootstrap.sh template/gen-verify-gate.sh tests/smoke_bootstrap.sh \
    template/scripts/run-verify-phases.sh template/scripts/doctor.sh template/scripts/handoff.sh
else
  echo "── shellcheck ──"
  echo "   (shellcheck not installed — skipped; CI installs it)"
fi

# Wiki lint is advisory for thin seed pages — warn but don't fail the gate yet
# until the dogfood vault is fleshed out. Strict mode: MY_ROBOT_STRICT_WIKI=1
echo "── wiki-lint ──"
if python3 scripts/wiki-lint.py; then
  echo "   ✓ wiki-lint"
else
  if [ "${MY_ROBOT_STRICT_WIKI:-0}" = "1" ]; then
    echo "   ✗ wiki-lint"
    FAILED=1
  else
    echo "   (wiki-lint issues — non-blocking; set MY_ROBOT_STRICT_WIKI=1 to enforce)"
  fi
fi

if [ "$FAILED" -eq 0 ]; then
  echo "verify: PASS"
  exit 0
else
  echo "verify: FAIL"
  exit 1
fi
