# AGENTS.md — my-robot

**This repo:** Installer that clones the 7-layer AI-first development system into any repo (`bootstrap.sh` + `template/`).
**Stack:** Bash (bootstrap + gen-verify-gate), Python templates for LanceDB retrieval, GitHub Actions CI.

## Retrieval order (read before acting)

Governed by `.cursor/rules/pre-task-retrieval.mdc`. Cheapest-first:
1. SimpleMem (if present) → 2. LanceDB (`scripts/search_project_knowledge_lancedb.py` — sidecar; this meta-repo is not Python-native)
→ 3. cross-repo vault → 4. long-term memory.

## Invariants (always apply)

1. **Verify before done.** Run the gate, paste real output. See `.cursor/rules/verify-before-done.mdc`.
2. **Secrets only in `.env`** (gitignored). Behavioral config in config files, never env vars.
3. **Never clobber.** Bootstrap is create-if-absent. Do not teach overwrite behavior without an explicit flag.
4. **Honest dry-run.** `--dry-run` must report `would-write` / `would-link` / `would-ensure`, never `installed` for writes that did not happen.
5. **Fail loud, never fake green.** Empty verify gates exit 1. Do not invent a test suite the repo does not have.
6. **Portable regenerate paths.** Generated gates point at `path/to/my-robot/template/gen-verify-gate.sh`, not private `~/.hermes/` paths.

## Definition of done (commands)

```bash
bash .verify.sh
```

## Topic → where

| Need | Open |
| ---- | ---- |
| Operations / deploy / env | `AI_RUNBOOK.md` |
| Recent decisions | `AI_SESSION_MEMORY.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Demo transcript | `docs/demo.md` |
| Workflows (plan, tdd, gate, migrate…) | global `.loops/` (say "use the loops") |

## Continuity

At close-out: append to `AI_SESSION_MEMORY.md`, update `MEMORY.md`, re-index changed
docs. The AI maintains these — not the human.
