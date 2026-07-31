#!/usr/bin/env bash
# run-verify-phases.sh — declarative verify runner (AgentSmith-inspired).
# Reads .harness/verify.conf lines: "Label :: shell command"
# Exit 0 if all phases pass; 1 on first failure; 2 if config missing.
#
# Usage:
#   bash scripts/run-verify-phases.sh
#   bash scripts/run-verify-phases.sh --list
#   bash scripts/run-verify-phases.sh --only wiki
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/.harness/verify.conf"
ONLY=""
LIST_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only) shift; ONLY="${1:-}"; [[ -z "$ONLY" ]] && { echo "ERROR: --only needs a tag"; exit 2; } ;;
    --list) LIST_ONLY=1 ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
  shift
done

if [[ ! -f "$CONF" ]]; then
  echo "No .harness/verify.conf — copy from .harness/verify.conf.example and wire real phases."
  exit 2
fi

LABELS=()
CMDS=()
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "${line//[[:space:]]/}" ]] && continue
  case "$line" in \#*) continue ;; esac
  [[ "$line" != *"::"* ]] && continue
  label="${line%%::*}"
  cmd="${line#*::}"
  # trim
  label="$(printf '%s' "$label" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  cmd="$(printf '%s' "$cmd" | sed 's/^[[:space:]]*//')"
  [[ -z "$cmd" ]] && continue
  if [[ -n "$ONLY" && "$label" != *"$ONLY"* ]]; then
    continue
  fi
  LABELS+=("$label")
  CMDS+=("$cmd")
done < "$CONF"

TOTAL=${#LABELS[@]}
if [[ "$TOTAL" -eq 0 ]]; then
  echo "No matching phases in .harness/verify.conf"
  exit 0
fi

if [[ "$LIST_ONLY" -eq 1 ]]; then
  echo "Configured phases:"
  i=0
  while [[ $i -lt $TOTAL ]]; do
    printf '  %d. %s :: %s\n' "$((i + 1))" "${LABELS[$i]}" "${CMDS[$i]}"
    i=$((i + 1))
  done
  exit 0
fi

FAILED=0
i=0
while [[ $i -lt $TOTAL ]]; do
  label="${LABELS[$i]}"
  cmd="${CMDS[$i]}"
  echo "── $label ──"
  if (cd "$ROOT" && bash -c "$cmd"); then
    echo "   ✓ $label"
  else
    rc=$?
    echo "   ✗ $label (exit $rc)"
    FAILED=1
    break
  fi
  i=$((i + 1))
done

if [[ "$FAILED" -eq 0 ]]; then
  echo "verify-phases: PASS ($TOTAL)"
  exit 0
fi
echo "verify-phases: FAIL"
exit 1
