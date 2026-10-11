# AGENTS.md — my-robot

**This repo:** Installer that clones the 7-layer AI-first development system into any repo (`bootstrap.sh` + `template/`).
**Stack:** Bash (bootstrap + gen-verify-gate), Python templates for LanceDB retrieval, GitHub Actions CI.

Claude Code loads this file through `.claude/CLAUDE.md`; this repo's own rules are in `.claude/rules/` (the wiki rule loads only for files in `my-robot wiki/`). Everything under `template/` is the payload `bootstrap.sh` installs into other repos (rules in Cursor format included), not this repo's own agent setup.

## Retrieval order (read before acting)

Governed by `.claude/rules/pre-task-retrieval.md`. Cheapest-first:
1. SimpleMem (if present) → 2. LanceDB sidecar, if installed (`docs/ai-retrieval.md`; this meta-repo is not Python-native)
→ 3. cross-repo vault → 4. long-term memory.

## Invariants (always apply)

1. **Verify before done.** Run the gate, paste real output. See `.claude/rules/verify-before-done.md`.
2. **Secrets only in `.env`** (gitignored). Behavioral config in config files, never env vars.
3. **Never clobber.** Bootstrap is create-if-absent. Do not teach overwrite behavior without an explicit flag.
4. **Honest dry-run.** `--dry-run` must report `would-write` / `would-link` / `would-ensure`, never `installed` for writes that did not happen.
5. **Fail loud, never fake green.** Empty verify gates exit 1. Do not invent a test suite the repo does not have.
6. **Portable regenerate paths.** Generated gates name the regenerate command as path/to/my-robot/template/gen-verify-gate.sh (a portable placeholder), never a private `~/.hermes/` path.
7. **Keep the payload list in sync.** `TEMPLATE_FILES` in `bootstrap.sh` must match the files under `template/` (a standalone install downloads exactly that list).

## Definition of done (commands)

```bash
bash .verify.sh                      # smoke test + shellcheck (skipped if not installed) + wiki-lint (advisory)
bash tests/smoke_bootstrap.sh         # bootstrap against throwaway repos
bash scripts/run-verify-phases.sh     # the same phases, read from .harness/verify.conf
./bootstrap.sh --dry-run /path/to/repo   # writes nothing; ./bootstrap.sh --doctor /path/to/repo is a read-only health check
```

CI (`.github/workflows/verify.yml`) installs shellcheck and runs `bash .verify.sh` on pushes and PRs to `main`.

## Topic → where

| Need | Open |
| ---- | ---- |
| Operations / deploy / env | `AI_RUNBOOK.md` |
| Recent decisions | `AI_SESSION_MEMORY.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Demo transcript | `docs/demo.md` |
| Install payload (rules, bridges, stubs, scripts, wiki seed) | `template/` |
| Installer and its file list | `bootstrap.sh` |
| Wiki (dogfood vault) | `my-robot wiki/SCHEMA.md` |
| Workflows (plan, tdd, gate, migrate…) | global `.loops/` (say "use the loops") |
| Self-improve (L6 harness health) | `~/.loops/loops/self-improve/loop.md` |

## Continuity

At close-out: append to `AI_SESSION_MEMORY.md`, update `MEMORY.md`, re-index changed
docs. The AI maintains these — not the human.
