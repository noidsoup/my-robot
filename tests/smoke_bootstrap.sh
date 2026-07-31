#!/usr/bin/env bash
# tests/smoke_bootstrap.sh — self-test for my-robot bootstrap.
# Pure bash (no bats). Exit 0 on pass, 1 on fail.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOT="$ROOT/bootstrap.sh"
FAILED=0
RAN=0

pass() { RAN=$((RAN + 1)); echo "  ✓ $1"; }
fail() { RAN=$((RAN + 1)); FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

assert_grep() {  # assert_grep <haystack-file-or-> <pattern> <label>
  local hay="$1" pat="$2" label="$3"
  if [[ "$hay" == "-" ]]; then
    if grep -Eq -- "$pat"; then pass "$label"; else fail "$label (pattern not found: $pat)"; fi
  else
    if grep -Eq -- "$pat" "$hay"; then pass "$label"; else fail "$label (pattern not found: $pat)"; fi
  fi
}

assert_not_grep() {
  local hay="$1" pat="$2" label="$3"
  if grep -Eq -- "$pat" "$hay"; then fail "$label (unexpected: $pat)"; else pass "$label"; fi
}

assert_file() {
  local f="$1" label="$2"
  if [[ -e "$f" ]]; then pass "$label"; else fail "$label (missing: $f)"; fi
}

echo "== smoke_bootstrap =="

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---- 1. Dry-run honesty on a fresh Node project ----------------------------
NODE="$TMP/node-app"
mkdir -p "$NODE/.cursor/rules"
printf '%s\n' '{"name":"node-app","scripts":{"test":"echo ok","lint":"echo lint"}}' > "$NODE/package.json"

DRY_OUT="$TMP/dry.out"
bash "$BOOT" --dry-run "$NODE" >"$DRY_OUT" 2>&1 || true

assert_grep "$DRY_OUT" 'L0\.5 Env Parity[[:space:]]+would-write' "dry-run L0.5 is would-write"
assert_not_grep "$DRY_OUT" 'L0\.5 Env Parity[[:space:]]+installed' "dry-run L0.5 is not installed"
assert_grep "$DRY_OUT" 'L2 Constraints[[:space:]]+would-write' "dry-run L2 is would-write"
assert_grep "$DRY_OUT" 'L4 Knowledge Wiki[[:space:]]+would-write' "dry-run L4 is would-write"
assert_grep "$DRY_OUT" 'L5 Continuity[[:space:]]+would-write' "dry-run L5 is would-write"
assert_grep "$DRY_OUT" 'AGENTS\.md[[:space:]]+would-write' "dry-run AGENTS is would-write"
assert_grep "$DRY_OUT" 'AI_RUNBOOK\.md[[:space:]]+would-write' "dry-run AI_RUNBOOK is would-write"
assert_grep "$DRY_OUT" 'ARCHITECTURE\.md[[:space:]]+would-write' "dry-run ARCHITECTURE is would-write"
# Fresh node has no .gitignore — .loops line would be added
assert_grep "$DRY_OUT" 'gitignore[[:space:]]+would-ensure[[:space:]]+\.loops ignored' "dry-run gitignore lists only .loops"

# Nothing written on dry-run
if [[ ! -e "$NODE/.env.example" && ! -e "$NODE/AGENTS.md" && ! -e "$NODE/.verify.sh" ]]; then
  pass "dry-run wrote nothing"
else
  fail "dry-run wrote files (should be empty)"
fi

# ---- 2. Apply + verify gate + portable regenerate path ---------------------
APPLY_OUT="$TMP/apply.out"
bash "$BOOT" "$NODE" >"$APPLY_OUT" 2>&1

assert_file "$NODE/.verify.sh" "apply wrote .verify.sh"
assert_file "$NODE/.env.example" "apply wrote .env.example"
assert_file "$NODE/AGENTS.md" "apply wrote AGENTS.md"
assert_file "$NODE/AI_RUNBOOK.md" "apply wrote AI_RUNBOOK.md"
assert_file "$NODE/docs/ARCHITECTURE.md" "apply wrote docs/ARCHITECTURE.md"
assert_file "$NODE/WIKI.md" "apply wrote WIKI.md"
assert_file "$NODE/.cursor/rules/llm-wiki.mdc" "apply wrote llm-wiki rule"
assert_file "$NODE/.cursor/rules/pre-task-retrieval.mdc" "apply wrote pre-task-retrieval"
assert_file "$NODE/.cursor/rules/verify-before-done.mdc" "apply wrote verify-before-done"
VAULT="$(basename "$NODE") wiki"
assert_file "$NODE/$VAULT/SCHEMA.md" "apply wrote wiki SCHEMA"
assert_file "$NODE/.loops" "apply linked .loops"

assert_not_grep "$NODE/.verify.sh" 'hermes' "generated gate has no hermes path"
assert_grep "$NODE/.verify.sh" 'my-robot/template/gen-verify-gate' "generated gate points at my-robot template"

# Gate should PASS for the stub npm scripts
if bash "$NODE/.verify.sh" >"$TMP/verify.out" 2>&1; then
  pass "generated .verify.sh exits 0"
else
  fail "generated .verify.sh failed (exit $?)"
  cat "$TMP/verify.out" || true
fi

# npm verify script wired
assert_grep "$NODE/package.json" '"verify"[[:space:]]*:[[:space:]]*"bash \.verify\.sh"' "npm verify script wired"

# gitignore only .loops for non-Python
assert_grep "$NODE/.gitignore" '^\.loops$' "gitignore has .loops"
assert_not_grep "$NODE/.gitignore" '^uncommitted/' "non-Python gitignore omits uncommitted/"

# ---- 3. Idempotent re-run --------------------------------------------------
RE_OUT="$TMP/re.out"
bash "$BOOT" "$NODE" >"$RE_OUT" 2>&1
assert_grep "$RE_OUT" 'L0 Ground Truth[[:space:]]+existed' "re-run L0 existed"
assert_grep "$RE_OUT" 'L2 Constraints[[:space:]]+existed' "re-run L2 existed"
assert_grep "$RE_OUT" 'AGENTS\.md[[:space:]]+existed' "re-run AGENTS existed"

# ---- 4. Claude-only rules dir ----------------------------------------------
CLAUDE="$TMP/claude-only"
mkdir -p "$CLAUDE"
touch "$CLAUDE/CLAUDE.md"
bash "$BOOT" --dry-run "$CLAUDE" >"$TMP/claude.out" 2>&1
assert_grep "$TMP/claude.out" '\.claude/rules' "Claude-only dry-run targets .claude/rules"

# ---- 5. gen-verify-gate portable path in empty stub ------------------------
EMPTY="$TMP/empty"
mkdir -p "$EMPTY"
# no package.json / py / go → fail-loud stub
bash "$ROOT/template/gen-verify-gate.sh" "$EMPTY" >"$TMP/gv.out" 2>&1
assert_file "$EMPTY/.verify.sh" "gen-verify wrote fail-loud stub"
assert_not_grep "$EMPTY/.verify.sh" 'hermes' "fail-loud stub has no hermes path"
assert_grep "$EMPTY/.verify.sh" 'my-robot/template/gen-verify-gate' "fail-loud stub points at my-robot"

# ---- 6. Partial cache still fetches missing stubs ---------------------------
# Simulate a stale ~/.my-robot cache that predates AI_RUNBOOK.stub.md.
CACHE="$TMP/fake-cache"
mkdir -p "$CACHE/template"
# Only the old sentinel file — missing new stubs must be fetched.
echo "# stub" > "$CACHE/template/AGENTS.stub.md"
# Point MY_ROBOT_HOME at our fake cache and run bootstrap with a copy of
# bootstrap that has no sibling template/ (standalone mode).
STANDALONE="$TMP/standalone"
mkdir -p "$STANDALONE"
cp "$BOOT" "$STANDALONE/bootstrap.sh"
# Intercept curl by putting a fake curl first on PATH that copies from real templates.
FAKEBIN="$TMP/fakebin"
mkdir -p "$FAKEBIN"
cat > "$FAKEBIN/curl" <<'CURL'
#!/usr/bin/env bash
# Minimal curl stub: -fsSL URL -o DEST  → copy from ROOT/template matching path
out=""
url=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) out="$2"; shift 2 ;;
    -fsSL|-f|-s|-S|-L) shift ;;
    *) url="$1"; shift ;;
  esac
done
rel="${url#*template/}"
src="${SMOKE_ROOT}/template/${rel}"
mkdir -p "$(dirname "$out")"
cp "$src" "$out"
CURL
chmod +x "$FAKEBIN/curl"
TARGET_CACHE="$TMP/cache-target"
mkdir -p "$TARGET_CACHE"
SMOKE_ROOT="$ROOT" PATH="$FAKEBIN:$PATH" MY_ROBOT_HOME="$CACHE" \
  bash "$STANDALONE/bootstrap.sh" --dry-run "$TARGET_CACHE" >"$TMP/cache.out" 2>&1 || true
assert_file "$CACHE/template/AI_RUNBOOK.stub.md" "stale cache fetched AI_RUNBOOK.stub.md"
assert_file "$CACHE/template/docs/ARCHITECTURE.stub.md" "stale cache fetched ARCHITECTURE.stub.md"
assert_file "$CACHE/template/rules/llm-wiki.mdc" "stale cache fetched llm-wiki.mdc"

# ---- 7. Missing template reports failed + exit 1 ---------------------------
BROKEN="$TMP/broken-installer"
mkdir -p "$BROKEN/template"
# Copy templates but omit AGENTS.stub.md so do_write fails for that file.
for f in .env.example WIKI.stub.md AI_RUNBOOK.stub.md docs/ARCHITECTURE.stub.md \
         docs/ai-retrieval-sidecar.md gen-verify-gate.sh \
         memory/AI_SESSION_MEMORY.md memory/MEMORY.md \
         rules/pre-task-retrieval.mdc rules/verify-before-done.mdc rules/llm-wiki.mdc \
         wiki/SCHEMA.md wiki/index.md wiki/log.md wiki/.obsidian/app.json; do
  mkdir -p "$(dirname "$BROKEN/template/$f")"
  cp "$ROOT/template/$f" "$BROKEN/template/$f"
done
chmod +x "$BROKEN/template/gen-verify-gate.sh"
cp "$BOOT" "$BROKEN/bootstrap.sh"
TARGET_B="$TMP/broken-target"
mkdir -p "$TARGET_B"
set +e
bash "$BROKEN/bootstrap.sh" --dry-run "$TARGET_B" >"$TMP/broken-dry.out" 2>&1
BDRC=$?
bash "$BROKEN/bootstrap.sh" "$TARGET_B" >"$TMP/broken.out" 2>&1
BRC=$?
set -e
if [[ "$BDRC" -eq 1 ]]; then pass "dry-run missing template exits 1"; else fail "dry-run missing template exit=$BDRC (want 1)"; fi
assert_grep "$TMP/broken-dry.out" 'AGENTS\.md[[:space:]]+failed' "dry-run missing AGENTS reports failed"
if [[ "$BRC" -eq 1 ]]; then pass "apply missing template exits 1"; else fail "apply missing template exit=$BRC (want 1)"; fi
assert_grep "$TMP/broken.out" 'AGENTS\.md[[:space:]]+failed' "apply missing AGENTS stub reports failed"

# ---- 8. Incomplete vault is repaired, not stuck as existed -----------------
PARTIAL="$TMP/partial-vault"
mkdir -p "$PARTIAL/.cursor"
# Pretend a crashed prior run left an empty vault dir
mkdir -p "$PARTIAL/$(basename "$PARTIAL") wiki"
bash "$BOOT" "$PARTIAL" >"$TMP/partial.out" 2>&1
assert_grep "$TMP/partial.out" 'L4 Knowledge Wiki[[:space:]]+installed' "incomplete vault repaired"
assert_file "$PARTIAL/$(basename "$PARTIAL") wiki/SCHEMA.md" "repaired vault has SCHEMA.md"

# ---- 9. Doctor + bridges + harness helpers ---------------------------------
assert_file "$NODE/CLAUDE.md" "apply wrote CLAUDE.md bridge"
assert_file "$NODE/.cursor/rules/agents.mdc" "apply wrote agents.mdc bridge"
assert_file "$NODE/scripts/wiki-lint.py" "apply wrote wiki-lint.py"
assert_file "$NODE/scripts/run-verify-phases.sh" "apply wrote run-verify-phases.sh"
assert_file "$NODE/.harness/verify.conf.example" "apply wrote verify.conf.example"
assert_file "$NODE/.my-robot/manifest.json" "apply wrote install manifest"
set +e
bash "$BOOT" --doctor "$NODE" >"$TMP/doctor.out" 2>&1
DRC=$?
set -e
if [[ "$DRC" -eq 0 ]]; then pass "doctor exits 0 on bootstrapped node app"; else fail "doctor exit=$DRC"; fi
assert_grep "$TMP/doctor.out" 'doctor: PASS' "doctor reports PASS"

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "smoke_bootstrap: PASS ($RAN checks)"
  exit 0
else
  echo "smoke_bootstrap: FAIL ($FAILED/$RAN checks)"
  exit 1
fi
