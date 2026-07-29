#!/usr/bin/env bash
# bootstrap.sh — install the 7-layer AI-first development system into any repo.
#
# Idempotent: every write is create-if-absent-else-skip. Never clobbers existing
# verify scripts, rules, or memory files. Stack-aware: only installs what fits.
#
# Usage:
#   bootstrap.sh [TARGET_DIR]      # default: current directory
#   bootstrap.sh --dry-run [DIR]   # report what WOULD happen, write nothing
#
# Standalone (no clone):
#   curl -fsSL https://raw.githubusercontent.com/noidsoup/my-robot/main/bootstrap.sh | bash -s -- --dry-run
#
# Exit codes: 0 ok, 1 target not a directory.

set -euo pipefail

# Where templates live. If this script was downloaded standalone (not run from
# a clone of the repo), fetch the template tree once and cache it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
CACHE_DIR="${MY_ROBOT_HOME:-$HOME/.my-robot}"
REPO_RAW="https://raw.githubusercontent.com/noidsoup/my-robot/main"
LOOPS_REPO="https://github.com/noidsoup/loops"
LOOPS_ROOT="${LOOPS_ROOT:-$HOME/.loops}"

TEMPLATE_FILES="
.env.example
AGENTS.stub.md
WIKI.stub.md
docs/ai-retrieval-sidecar.md
gen-verify-gate.sh
memory/AI_SESSION_MEMORY.md
memory/MEMORY.md
requirements-lancedb.txt
rules/pre-task-retrieval.mdc
rules/verify-before-done.mdc
rules/llm-wiki.mdc
scripts/index_project_knowledge_lancedb.py
scripts/project_knowledge_lancedb_common.py
scripts/search_project_knowledge_lancedb.py
wiki/SCHEMA.md
wiki/index.md
wiki/log.md
wiki/.obsidian/app.json
"

if [[ -d "$SCRIPT_DIR/template" ]]; then
  TEMPLATES_DIR="$SCRIPT_DIR/template"
else
  TEMPLATES_DIR="$CACHE_DIR/template"
  if [[ ! -f "$TEMPLATES_DIR/AGENTS.stub.md" ]]; then
    echo "fetching my-robot templates -> $TEMPLATES_DIR"
    for f in $TEMPLATE_FILES; do
      mkdir -p "$(dirname "$TEMPLATES_DIR/$f")"
      curl -fsSL "$REPO_RAW/template/$f" -o "$TEMPLATES_DIR/$f"
    done
    chmod +x "$TEMPLATES_DIR/gen-verify-gate.sh" 2>/dev/null || true
  fi
fi

DRY_RUN=0
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

TARGET="$(cd "$TARGET" 2>/dev/null && pwd || true)"
[[ -z "$TARGET" || ! -d "$TARGET" ]] && { echo "ERROR: target is not a directory"; exit 1; }
cd "$TARGET"

# ---- report helpers ---------------------------------------------------------
declare -a REPORT
add_report() { REPORT+=("$1|$2|$3"); }  # layer|status|detail

do_write() {  # do_write <dest-rel> <src-abs>   (create if absent)
  local dest="$1" src="$2"
  if [[ -e "$dest" ]]; then
    return 1  # existed
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    return 0  # would-write
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  return 0
}

ensure_line() {  # ensure_line <file> <line>
  local file="$1" line="$2"
  [[ $DRY_RUN -eq 1 ]] && { grep -qxF "$line" "$file" 2>/dev/null || echo "would-add"; return; }
  touch "$file"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ---- 1. DETECT --------------------------------------------------------------
IS_GIT=0; git rev-parse --is-inside-work-tree >/dev/null 2>&1 && IS_GIT=1
HAS_PKG=0; [[ -f package.json ]] && HAS_PKG=1
HAS_PY=0
if [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]] || compgen -G "*.py" >/dev/null 2>&1 || compgen -G "scripts/*.py" >/dev/null 2>&1; then
  HAS_PY=1
fi
HAS_GO=0; [[ -f go.mod ]] && HAS_GO=1
HAS_CURSOR=0; [[ -d .cursor ]] && HAS_CURSOR=1
HAS_CLAUDE=0; [[ -d .claude || -f CLAUDE.md ]] && HAS_CLAUDE=1

echo "== my-robot bootstrap =="
echo "target:  $TARGET"
echo "git:$IS_GIT  node:$HAS_PKG  python:$HAS_PY  go:$HAS_GO  cursor:$HAS_CURSOR  claude:$HAS_CLAUDE"
[[ $DRY_RUN -eq 1 ]] && echo "(dry-run — nothing will be written)"
echo

[[ $IS_GIT -eq 0 ]] && echo "WARN: not a git repo — proceeding anyway"

# ---- L0: Ground Truth (verify gate) ----------------------------------------
# Generate a sensible-default .verify.sh that chains ONLY checks that already
# exist. Never fabricates a suite: repos with nothing runnable get an honest
# fail-loud stub. Existing gates are left untouched.
GENVERIFY="$TEMPLATES_DIR/gen-verify-gate.sh"
VERIFY_STATUS="skipped"; VERIFY_DETAIL="gen-verify-gate.sh not found"
if [[ -f "$GENVERIFY" ]]; then
  if [[ -f .verify.sh ]]; then
    VERIFY_STATUS="existed"; VERIFY_DETAIL=".verify.sh already present"
  elif [[ $DRY_RUN -eq 1 ]]; then
    VERIFY_STATUS="would-write"; VERIFY_DETAIL="would generate .verify.sh from detected checks"
  else
    GV_OUT="$(bash "$GENVERIFY" "$TARGET" 2>&1)"
    if echo "$GV_OUT" | grep -q 'none detected'; then
      VERIFY_STATUS="stub"; VERIFY_DETAIL="no real checks found — fail-loud .verify.sh written (add tests/lint, then regenerate)"
    else
      GV_CHECKS="$(echo "$GV_OUT" | grep '^checks:' | sed 's/^checks: //')"
      VERIFY_STATUS="generated"; VERIFY_DETAIL=".verify.sh: $GV_CHECKS"
    fi
  fi
fi
add_report "L0 Ground Truth" "$VERIFY_STATUS" "$VERIFY_DETAIL"

# ---- L0.5: Environment Parity ----------------------------------------------
if do_write ".env.example" "$TEMPLATES_DIR/.env.example"; then
  add_report "L0.5 Env Parity" "installed" ".env.example stub"
else
  add_report "L0.5 Env Parity" "existed" ".env.example already present"
fi

# ---- L1: Retrieval (LanceDB scaffold) --------------------------------------
if [[ $HAS_PY -eq 1 ]]; then
  w=0; e=0
  for f in project_knowledge_lancedb_common.py index_project_knowledge_lancedb.py search_project_knowledge_lancedb.py; do
    if do_write "scripts/$f" "$TEMPLATES_DIR/scripts/$f"; then w=$((w+1)); else e=$((e+1)); fi
  done
  do_write "requirements-lancedb.txt" "$TEMPLATES_DIR/requirements-lancedb.txt" && w=$((w+1)) || e=$((e+1))
  add_report "L1 Retrieval" "installed" "LanceDB scaffold ($w new, $e existed) — run index after"
else
  # JS/other: note the Python-sidecar path instead of broken scripts
  if do_write "docs/ai-retrieval.md" "$TEMPLATES_DIR/docs/ai-retrieval-sidecar.md"; then
    add_report "L1 Retrieval" "note" "non-Python: docs/ai-retrieval.md explains Python-sidecar option"
  else
    add_report "L1 Retrieval" "existed" "docs/ai-retrieval.md present"
  fi
fi

# ---- L2: Constraints (rules) ------------------------------------------------
if [[ $HAS_CURSOR -eq 1 || $HAS_CLAUDE -eq 0 ]]; then
  RULES_DIR=".cursor/rules"
else
  RULES_DIR=".claude/rules"
fi
rw=0; re=0
for r in pre-task-retrieval.mdc verify-before-done.mdc llm-wiki.mdc; do
  if do_write "$RULES_DIR/$r" "$TEMPLATES_DIR/rules/$r"; then rw=$((rw+1)); else re=$((re+1)); fi
done
add_report "L2 Constraints" "installed" "$RULES_DIR ($rw new, $re existed)"

# ---- L3: Workflows (clone loops + symlink) ----------------------------------
if [[ -e .loops ]]; then
  add_report "L3 Workflows" "existed" ".loops already present"
elif [[ $DRY_RUN -eq 1 ]]; then
  if [[ -d "$LOOPS_ROOT" ]]; then
    add_report "L3 Workflows" "would-link" ".loops -> $LOOPS_ROOT (already cloned)"
  else
    add_report "L3 Workflows" "would-clone" "$LOOPS_REPO -> $LOOPS_ROOT, then symlink .loops"
  fi
else
  if [[ ! -d "$LOOPS_ROOT" ]]; then
    if git clone --quiet "$LOOPS_REPO" "$LOOPS_ROOT" 2>/dev/null; then
      add_report "L3 Workflows" "cloned" "$LOOPS_REPO -> $LOOPS_ROOT"
    else
      add_report "L3 Workflows" "skipped" "could not clone $LOOPS_REPO (offline?) — install loops manually"
    fi
  fi
  if [[ -d "$LOOPS_ROOT" && ! -e .loops ]]; then
    ln -s "$LOOPS_ROOT" .loops
    add_report "L3 Workflows" "installed" ".loops -> $LOOPS_ROOT (symlink, auto-updates)"
  fi
fi

# ---- L4: Knowledge Wiki (Obsidian vault) ------------------------------------
# Vault lives at "<repo-folder-name> wiki/" (space before wiki). Fully
# idempotent: never overwrites an existing vault or its pages.
VAULT_DIR="$(basename "$TARGET") wiki"
VAULT_TEMPLATE="$TEMPLATES_DIR/wiki"
vw=0; ve=0
if [[ ! -d "$VAULT_DIR" ]]; then
  if [[ $DRY_RUN -eq 1 ]]; then
    add_report "L4 Knowledge Wiki" "would-write" "$VAULT_DIR/ (SCHEMA, index, log, .obsidian)"
  else
    mkdir -p "$VAULT_DIR/.obsidian" "$VAULT_DIR"/{sources,entities,concepts,decisions,guides,memories,assets}
    TODAY="$(date +%F)"
    for f in SCHEMA.md index.md log.md; do
      sed -e "s|<YYYY-MM-DD>|$TODAY|g" "$VAULT_TEMPLATE/$f" > "$VAULT_DIR/$f"
    done
    cp "$VAULT_TEMPLATE/.obsidian/app.json" "$VAULT_DIR/.obsidian/app.json"
    add_report "L4 Knowledge Wiki" "installed" "$VAULT_DIR/ (open in Obsidian as vault)"
  fi
else
  add_report "L4 Knowledge Wiki" "existed" "$VAULT_DIR/ left untouched"
fi
if do_write "WIKI.md" "$TEMPLATES_DIR/WIKI.stub.md"; then vw=$((vw+1)); else ve=$((ve+1)); fi
[[ $vw -gt 0 || $ve -gt 0 ]] && add_report "  WIKI.md pointer" "$([[ $vw -gt 0 ]] && echo installed || echo existed)" "repo-root pointer to the vault"

# ---- L5: Continuity (memory stubs) -----------------------------------------
cw=0; ce=0
for m in AI_SESSION_MEMORY.md MEMORY.md; do
  if do_write "$m" "$TEMPLATES_DIR/memory/$m"; then cw=$((cw+1)); else ce=$((ce+1)); fi
done
add_report "L5 Continuity" "installed" "memory stubs ($cw new, $ce existed)"

# ---- gitignore uncommitted/ + loops symlink --------------------------------
if [[ $HAS_PY -eq 1 ]]; then
  ensure_line .gitignore "uncommitted/" >/dev/null
fi
ensure_line .gitignore ".loops" >/dev/null
add_report "gitignore" "ensured" "uncommitted/ + .loops ignored"

# ---- AGENTS.md pointer (create minimal if absent) --------------------------
if do_write "AGENTS.md" "$TEMPLATES_DIR/AGENTS.stub.md"; then
  add_report "AGENTS.md" "installed" "minimal stub — fill in stack + invariants"
else
  add_report "AGENTS.md" "existed" "left untouched"
fi

# ---- REPORT -----------------------------------------------------------------
echo
printf '%-20s %-14s %s\n' "LAYER" "STATUS" "DETAIL"
printf '%-20s %-14s %s\n' "-----" "------" "------"
for row in "${REPORT[@]}"; do
  IFS='|' read -r layer status detail <<< "$row"
  printf '%-20s %-14s %s\n' "$layer" "$status" "$detail"
done
echo
if [[ $HAS_PY -eq 1 ]]; then
  echo "Next: pip install -r requirements-lancedb.txt && python3 -u scripts/index_project_knowledge_lancedb.py --apply"
fi
[[ "$VERIFY_STATUS" == "stub" ]] && echo "Action needed (L0): $VERIFY_DETAIL"
echo "Done."
