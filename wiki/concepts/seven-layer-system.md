---
title: The seven layers (L0–L6)
type: concept
summary: The layer model the installer is built around, and what each layer guards against.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [docs/ARCHITECTURE.md, README.md, "commit 3dd2333"]
tags: [architecture, layers]
---

# The seven layers (L0–L6)

The installer is organized as layers, each answering one agent failure mode (`docs/ARCHITECTURE.md`).

| Layer | What | Failure it prevents |
|---|---|---|
| L0 Ground truth | `.verify.sh` | "done" without running anything |
| L0.5 Env parity | `.env.example` | secrets or config drift between machines |
| L1 Retrieval | LanceDB scripts or sidecar note | guessing instead of searching docs |
| L2 Constraints | always-on rules (retrieval, verify, wiki) | ignoring house rules |
| L3 Workflows | `.loops` → `~/.loops` | ad-hoc process for plan / tdd / review |
| L4 Knowledge wiki | Obsidian vault + `WIKI.md` | re-learning decisions every session |
| L5 Continuity | `AI_SESSION_MEMORY.md`, `MEMORY.md` | forgetting between chats |
| L6 Self-correction | `self-improve` loop in `~/.loops` | the same mistake recurring |

## L6 is a conductor, not files

L6 routes existing tools: bridge-log observations, `workflow-audit.sh`, the weekly-retro skill, tiered apply (T1 auto, T2 after a retro yes, T3 rules always ask), and `scripts/harness-lint.sh` as the v1 regression gate (commit `3dd2333`, `docs/ARCHITECTURE.md`). Agent-behavior golden tests are planned as v2.

## Related

- [[template-payload]]
- [[honest-verify-gate]]
- [[overview]]
