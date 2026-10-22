#!/usr/bin/env bash
# doctor.sh — read-only health check for a my-robot-installed (or candidate) repo.
# Inspired by agent-feed status/check + contextdocs context-verify + prove-it doctor.
#
# Usage:
#   bash path/to/my-robot/template/scripts/doctor.sh [TARGET_DIR]
#   bootstrap.sh --doctor [TARGET_DIR]
set -uo pipefail

TARGET="${1:-.}"
if ! TARGET="$(cd "$TARGET" 2>/dev/null && pwd)"; then
  echo "ERROR: target is not a directory"
  exit 1
fi
cd "$TARGET" || exit 1

PASS=0
WARN=0
FAIL=0
note() { printf '  %-7s %s\n' "$1" "$2"; }
ok() { note "ok" "$1"; PASS=$((PASS + 1)); }
warn() { note "warn" "$1"; WARN=$((WARN + 1)); }
bad() { note "FAIL" "$1"; FAIL=$((FAIL + 1)); }

check_file() {  # check_file <path> <ok-msg> <missing-msg> <missing-fn>
  local path="$1" okmsg="$2" missmsg="$3" missfn="$4"
  if [[ -f "$path" ]]; then
    ok "$okmsg"
  else
    "$missfn" "$missmsg"
  fi
}

echo "== my-robot doctor =="
echo "target: $TARGET"
echo

echo "Layers"
if [[ -f .verify.sh ]]; then
  if [[ -x .verify.sh ]] || head -1 .verify.sh | grep -q '^#!'; then
    ok ".verify.sh present"
  else
    warn ".verify.sh present but not marked executable"
  fi
else
  bad "missing .verify.sh (L0)"
fi

check_file .env.example ".env.example present" "missing .env.example (L0.5)" warn

if [[ -f scripts/search_project_knowledge_lancedb.py ]]; then
  ok "LanceDB retrieval scripts present (L1)"
elif [[ -f docs/ai-retrieval.md ]]; then
  ok "retrieval sidecar note present (L1 non-Python)"
else
  warn "no L1 retrieval scaffold (LanceDB or docs/ai-retrieval.md)"
fi

RULE_HITS=0
for d in .cursor/rules .claude/rules; do
  for ext in mdc md; do
    [[ -f "$d/verify-before-done.$ext" ]] && RULE_HITS=$((RULE_HITS + 1))
    [[ -f "$d/pre-task-retrieval.$ext" ]] && RULE_HITS=$((RULE_HITS + 1))
  done
done
if [[ "$RULE_HITS" -ge 2 ]]; then
  ok "agent rules present (L2)"
else
  warn "missing verify-before-done / pre-task-retrieval rules (L2)"
fi

if [[ -e .loops ]]; then
  ok ".loops present (L3)"
else
  warn "missing .loops symlink (L3 — install loops or re-run bootstrap)"
fi

VAULT=""
shopt -s nullglob
for d in *\ wiki wiki; do
  if [[ -d "$d" ]]; then VAULT="$d"; break; fi
done
shopt -u nullglob
if [[ -n "$VAULT" && -s "$VAULT/SCHEMA.md" && -s "$VAULT/index.md" && -s "$VAULT/log.md" ]]; then
  ok "Obsidian vault complete: $VAULT (L4)"
elif [[ -n "$VAULT" ]]; then
  warn "vault '$VAULT' incomplete (need SCHEMA.md, index.md, log.md)"
else
  bad 'missing "<repo> wiki/" vault (L4)'
fi

check_file WIKI.md "WIKI.md pointer present" "missing WIKI.md pointer" warn

if [[ -f AI_SESSION_MEMORY.md && -f MEMORY.md ]]; then
  ok "memory stubs present (L5)"
else
  warn "missing AI_SESSION_MEMORY.md / MEMORY.md (L5)"
fi

check_file AGENTS.md "AGENTS.md present" "missing AGENTS.md" bad

echo
echo "Bridges"
if grep -qs 'AGENTS\.md' CLAUDE.md .claude/CLAUDE.md; then
  ok "Claude bridge imports AGENTS.md"
elif [[ -f CLAUDE.md || -f .claude/CLAUDE.md ]]; then
  warn "CLAUDE.md exists but does not import AGENTS.md (add @AGENTS.md, or @../AGENTS.md in .claude/CLAUDE.md)"
else
  warn "no CLAUDE.md or .claude/CLAUDE.md — Claude Code will not load AGENTS.md"
fi
if [[ -f .cursor/rules/agents.mdc ]] || [[ -f .cursor/rules/cursor-agents.mdc ]]; then
  ok "Cursor AGENTS bridge rule"
else
  note "—" "no .cursor/rules/agents.mdc (optional)"
fi
if [[ -f .cursorrules && ! -d .cursor/rules ]]; then
  warn "legacy .cursorrules without .cursor/rules/ — Agent mode prefers .mdc rules"
fi

echo
echo "Harness"
if [[ -f .harness/verify.conf ]]; then
  ok ".harness/verify.conf present"
elif [[ -f .harness/verify.conf.example ]]; then
  warn ".harness/verify.conf.example present but not wired to .harness/verify.conf"
else
  note "—" "no declarative verify phases yet"
fi
if [[ -f scripts/run-verify-phases.sh ]]; then
  ok "run-verify-phases.sh present"
else
  note "—" "no scripts/run-verify-phases.sh"
fi
if [[ -f scripts/wiki-lint.py ]]; then
  ok "wiki-lint.py present"
else
  note "—" "no scripts/wiki-lint.py"
fi
if [[ -f .my-robot/manifest.json ]]; then
  ok "install manifest present"
else
  note "—" "no .my-robot/manifest.json (older install)"
fi

echo
echo "AGENTS.md budget"
if [[ -f AGENTS.md ]]; then
  LINES=$(wc -l < AGENTS.md | tr -d ' ')
  if [[ "$LINES" -gt 200 ]]; then
    warn "AGENTS.md is $LINES lines (target <~200 — Signal Gate: drop discoverable trees)"
  else
    ok "AGENTS.md is $LINES lines (within ~200 budget)"
  fi
  if grep -q 'Minimal stub created by' AGENTS.md; then
    warn "AGENTS.md is still the unfilled stub — ask your agent to fill it from the repo"
  fi
  # The sections that cost the most time when missing: tested commands,
  # the pre-existing error baseline, how to log in locally, push rules.
  for h in '## Commands' '## Known baseline' '## Running locally' '## Git and push safety'; do
    if grep -q "^$h" AGENTS.md; then
      ok "AGENTS.md has '$h'"
    else
      warn "AGENTS.md has no '$h' section (see my-robot template/AGENTS.stub.md)"
    fi
  done
  if grep -q '^## Commands' AGENTS.md && ! grep -qi 'last verified: *[0-9]' AGENTS.md; then
    warn "Commands section has no 'Last verified: YYYY-MM-DD' — re-run the commands and date them"
  fi
fi

echo
echo "Runtime pin"
PIN=""
for f in .nvmrc .node-version; do
  [[ -f "$f" ]] && { PIN="$(tr -d ' v\n' < "$f")"; PIN_FILE="$f"; break; }
done
[[ -z "$PIN" && -f .tool-versions ]] && PIN="$(awk '$1=="nodejs"{print $2}' .tool-versions)" && PIN_FILE=.tool-versions
ENGINES=""
shopt -s nullglob
for pj in package.json */package.json; do
  e="$(grep -A3 '"engines"' "$pj" | grep -o '"node"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//; s/"$//')"
  [[ -n "$e" ]] && ENGINES="${ENGINES}${pj}: node ${e}; "
done
shopt -u nullglob
if [[ -n "$PIN" ]]; then
  ok "Node pinned: $PIN ($PIN_FILE)"
  if command -v node >/dev/null 2>&1; then
    HAVE="$(node --version | tr -d v)"
    if [[ "${HAVE%%.*}" != "${PIN%%.*}" ]]; then
      warn "installed Node $HAVE does not match pinned $PIN — installs and builds may fail"
    fi
  fi
  [[ -n "$ENGINES" ]] && note "—" "engines: $ENGINES"
elif [[ -n "$ENGINES" ]]; then
  warn "engines set but no .nvmrc / .node-version — agents can't tell which Node to use ($ENGINES)"
elif [[ -f package.json ]]; then
  warn "Node project with no .nvmrc / .node-version / engines"
else
  note "—" "not a Node project"
fi

echo
echo "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  note "—" "origin: $(git remote get-url origin 2>/dev/null || echo none)"
  git remote get-url upstream >/dev/null 2>&1 && note "—" "upstream: $(git remote get-url upstream)"
  PUSHURL="$(git config remote.origin.pushurl || true)"
  [[ -n "$PUSHURL" ]] && note "—" "origin push URL overridden: $PUSHURL"
  [[ -x "$(git rev-parse --git-path hooks/pre-push)" ]] && note "—" "local pre-push hook present"
fi

echo
echo "Gate dry probe"
if [[ -f .verify.sh ]]; then
  if bash .verify.sh >/tmp/my-robot-doctor-verify.out 2>&1; then
    ok ".verify.sh exits 0"
  else
    rc=$?
    warn ".verify.sh exits $rc (see output — may be intentional fail-loud stub)"
    tail -5 /tmp/my-robot-doctor-verify.out | sed 's/^/    /'
  fi
fi

echo
echo "Summary: ok=$PASS warn=$WARN fail=$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  echo "doctor: FAIL"
  exit 1
fi
echo "doctor: PASS"
exit 0
