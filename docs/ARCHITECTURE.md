# Architecture — my-robot

## What this is

A one-script bootstrap that installs a 7-layer AI-first development foundation into any git repo: verify gate, env stub, retrieval (or sidecar note), agent rules, loops workflows, Obsidian wiki, and memory stubs.

## Layout

| Path | Role |
| ---- | ---- |
| `bootstrap.sh` | Installer (idempotent, stack-aware, `--dry-run`) |
| `template/` | Files copied or used to generate target-repo artifacts |
| `template/gen-verify-gate.sh` | Detects real checks; writes honest `.verify.sh` |
| `template/scripts/` | LanceDB index/search (Python targets only) |
| `template/rules/` | Cursor/Claude always-on rules |
| `template/wiki/` | Obsidian vault seed (`<repo> wiki/`) |
| `tests/smoke_bootstrap.sh` | Self-tests for dry-run honesty + apply + idempotency |
| `.verify.sh` | This repo's L0 gate |
| `.github/workflows/verify.yml` | CI |
| `docs/` | Demo transcript + architecture |

## Layers (L0–L6)

1. **L0** Ground truth — `.verify.sh`
2. **L0.5** Env parity — `.env.example`
3. **L1** Retrieval — LanceDB scripts or `docs/ai-retrieval.md` note
4. **L2** Constraints — agent rules (incl. `llm-wiki`)
5. **L3** Workflows — `.loops` → `~/.loops`
6. **L4** Knowledge wiki — `<repo> wiki/` + `WIKI.md`
7. **L5** Continuity — `AI_SESSION_MEMORY.md`, `MEMORY.md`
8. **L6** Self-correction — via loops (no per-repo file)

Plus ops stubs: `AI_RUNBOOK.md`, `docs/ARCHITECTURE.md`.

## Key invariants

1. Create-if-absent; never clobber.
2. Dry-run statuses must not claim `installed`.
3. Empty gates fail loud (exit 1).
4. Greenfield / Cursor → `.cursor/rules`; Claude-only → `.claude/rules`.

## Related

- Agent instructions: `AGENTS.md`
- Ops: `AI_RUNBOOK.md`
- Demo: `docs/demo.md`
- Workflows: `.loops/`
