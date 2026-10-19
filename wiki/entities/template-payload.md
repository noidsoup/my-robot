---
title: template/ payload
type: entity
summary: What template/ contains and where each file lands in a target repo.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [bootstrap.sh, docs/ARCHITECTURE.md, template/]
tags: [template, payload]
---

# template/ payload

Everything under `template/` is copied or used to generate files in **other** repos. It is not this repo's own agent setup ([[0004-own-setup-vs-payload]]).

| Payload | Lands as | Layer |
|---|---|---|
| `gen-verify-gate.sh` | generates `.verify.sh` (+ npm `verify` script for JS) | L0 ([[honest-verify-gate]]) |
| `.env.example` | `.env.example` | L0.5 |
| `scripts/*lancedb*.py`, `requirements-lancedb.txt` / `docs/ai-retrieval-sidecar.md` | LanceDB scaffold (Python) or `docs/ai-retrieval.md` (others) | L1 |
| `rules/pre-task-retrieval.mdc`, `verify-before-done.mdc`, `llm-wiki.mdc` | `.cursor/rules/` or `.claude/rules/` | L2 |
| `bridges/CLAUDE.stub.md`, `bridges/cursor-agents.mdc` | root `CLAUDE.md`, `<rules>/agents.mdc` | L2.5 |
| — | `.loops` symlink → `~/.loops` (clones `noidsoup/loops` if missing) | L3 |
| `wiki/SCHEMA.md`, `index.md`, `log.md`, `.obsidian/app.json`, `WIKI.stub.md` | `<repo> wiki/` + `WIKI.md` | L4 ([[0002-named-vault-convention]]) |
| `memory/AI_SESSION_MEMORY.md`, `memory/MEMORY.md` | same names at root | L5 |
| `AGENTS.stub.md`, `AI_RUNBOOK.stub.md`, `docs/ARCHITECTURE.stub.md` | ops stubs | — |
| `scripts/run-verify-phases.sh`, `doctor.sh`, `handoff.sh`, `wiki-lint.py`, `.harness/verify.conf.example` | harness helpers | — |

L6 (self-improve) is a loop in `~/.loops`, not a per-repo file ([[seven-layer-system]]).

This repo dogfoods payload scripts in its own `scripts/`. As of 2026-10-19, `doctor.sh`, `handoff.sh`, `run-verify-phases.sh`, `search_…lancedb.py` and `wiki-lint.py` are identical to `template/scripts/`, but the two LanceDB files differ: the repo copies have the partial re-index fixes from commit `3dd2333` (no delete on read error, partial update needs an existing index), while the template copies still lack them and alone discover `* wiki/` vaults. `harness-lint.sh` exists only here.

## Related

- [[bootstrap-installer]]
- [[seven-layer-system]]
