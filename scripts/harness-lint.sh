#!/usr/bin/env bash
# harness-lint.sh — static checks for L6 harness health (my-robot template + repo rules).
# Exit 0 on pass, 1 on fail. Advisory warnings unless MY_ROBOT_STRICT_HARNESS=1.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

FAILED=0
WARNED=0
MAX_RULE_BYTES=8192

warn() {
  echo "   ⚠ $1"
  WARNED=$((WARNED + 1))
  if [[ "${MY_ROBOT_STRICT_HARNESS:-0}" == "1" ]]; then
    FAILED=1
  fi
}

fail() {
  echo "   ✗ $1"
  FAILED=1
}

pass() {
  echo "   ✓ $1"
}

echo "── harness-lint ──"

# Required template rules (bootstrapped into every repo)
for req in verify-before-done.mdc pre-task-retrieval.mdc; do
  if [[ -f "$ROOT/template/rules/$req" ]]; then
    pass "template/rules/$req present"
  else
    fail "missing template/rules/$req"
  fi
done

# Rule size guard (token bloat)
while IFS= read -r mdc; do
  [[ -f "$mdc" ]] || continue
  bytes="$(wc -c <"$mdc" | tr -d ' ')"
  base="$(basename "$mdc")"
  if [[ "$bytes" -gt "$MAX_RULE_BYTES" ]]; then
    warn "$base is ${bytes}B (>${MAX_RULE_BYTES}B)"
  else
    pass "$base size OK (${bytes}B)"
  fi
done < <(find "$ROOT/template/rules" "$ROOT/.cursor/rules" -type f -name '*.mdc' 2>/dev/null | sort -u)

# L6 documented in architecture
if grep -q 'self-improve' "$ROOT/docs/ARCHITECTURE.md" 2>/dev/null; then
  pass "docs/ARCHITECTURE.md documents L6 self-improve"
else
  fail "docs/ARCHITECTURE.md missing L6 self-improve reference"
fi

# Bootstrap still installs L2 constraints
if grep -q 'L2 Constraints' "$ROOT/bootstrap.sh" 2>/dev/null; then
  pass "bootstrap.sh installs L2 constraints"
else
  fail "bootstrap.sh missing L2 Constraints layer"
fi

if [[ "$FAILED" -eq 0 ]]; then
  if [[ "$WARNED" -gt 0 ]]; then
    echo "harness-lint: PASS (${WARNED} warning(s); set MY_ROBOT_STRICT_HARNESS=1 to enforce)"
  else
    echo "harness-lint: PASS"
  fi
  exit 0
fi

echo "harness-lint: FAIL"
exit 1
