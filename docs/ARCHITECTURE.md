# Architecture — my-robot

## What this is

A one-script bootstrap that installs a 7-layer AI-first development foundation into any git repo: verify gate, env stub, retrieval (or sidecar note), agent rules, loops workflows, Obsidian wiki, and memory stubs.

## Layout

| Path | Role |
| ---- | ---- |
| `bootstrap.sh` | Installer (idempotent, stack-aware, `--dry-run`, `--doctor`) |
| `template/` | Files copied or used to generate target-repo artifacts |
| `template/gen-verify-gate.sh` | Detects real checks; writes honest `.verify.sh` |
| `template/scripts/` | LanceDB, wiki-lint, verify-phases, doctor, handoff |
| `template/bridges/` | Thin CLAUDE.md + Cursor `agents.mdc` → AGENTS.md |
| `template/.harness/` | Declarative verify phase example |
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
8. **L6** Self-correction — `self-improve` loop in global `~/.loops` (no per-repo file)

Plus ops stubs: `AI_RUNBOOK.md`, `docs/ARCHITECTURE.md`.

## L6 — Self-improve loop

L6 is a **conductor**, not a new skill pack in every repo. It lives at `LOOPS_ROOT/loops/self-improve/loop.md` and routes to existing tools:

| Phase | Tool |
| ----- | ---- |
| Observe | `bridge-log` kinds: `verify_red`, `user_correction`, `rule_miss`, `skill_miss` |
| Inventory | `~/.hermes/scripts/workflow-audit.sh` (`report`, `failures`) |
| Propose | `weekly-retro` skill (≤3 audit-cited items) |
| Refine | Tiered apply — T1 auto, T2 skill/memory after retro yes, T3 rules always ask |
| Memorize | `AI_SESSION_MEMORY.md`, Honcho, skill `## Pitfalls`, `my-robot/template/` |
| Prove | `.verify.sh`, `scripts/harness-lint.sh`, audit delta |

**Triggers:** "self-improve", "improve the agent", "run weekly retro", "L6 loop".

**Cadence:** Sunday cron runs audit → weekly-retro; session end uses `mark-where-you-are`; on-demand `audit and refine` polishes the current diff.

**v1 regression gate:** `scripts/harness-lint.sh` (template rules present, size cap, L6 doc). Agent behavior goldens are v2.

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
