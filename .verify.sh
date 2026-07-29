#!/usr/bin/env bash
# .verify.sh — L0 ground-truth gate for my-robot itself.
# Chains real checks that exist in this repo. Exit 0 on pass, 1 on fail.
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
  run_step "shellcheck" shellcheck -x bootstrap.sh template/gen-verify-gate.sh tests/smoke_bootstrap.sh
else
  echo "── shellcheck ──"
  echo "   (shellcheck not installed — skipped; CI installs it)"
fi

if [ "$FAILED" -eq 0 ]; then
  echo "verify: PASS"
  exit 0
else
  echo "verify: FAIL"
  exit 1
fi
