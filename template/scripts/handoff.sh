#!/usr/bin/env bash
# handoff.sh — paste-ready session kickoff (AgentSmith-inspired).
# Appends a dated block to AI_SESSION_MEMORY.md and prints a kickoff fence.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

STAMP="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo n/a)"
HEAD="$(git rev-parse --short HEAD 2>/dev/null || echo n/a)"
DIRTY="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
MEM="$ROOT/AI_SESSION_MEMORY.md"

NOTE="${1:-Session handoff}"

{
  echo ""
  echo "## [$STAMP $TIME] handoff | $NOTE"
  echo ""
  echo "- Branch: \`$BRANCH\` @ \`$HEAD\`"
  echo "- Dirty paths: $DIRTY"
  echo "- Verify: run \`bash .verify.sh\` before claiming done"
  echo "- Next: <fill in>"
} >> "$MEM"

cat <<EOF
\`\`\`kickoff
Repo: $(basename "$ROOT")
Branch: $BRANCH ($HEAD)
Dirty: $DIRTY path(s)
Memory: AI_SESSION_MEMORY.md (handoff $STAMP $TIME)
Task: $NOTE

Before coding: read AGENTS.md + latest AI_SESSION_MEMORY.md.
Before done: bash .verify.sh (paste real output).
\`\`\`
EOF

echo "Appended handoff to AI_SESSION_MEMORY.md"
