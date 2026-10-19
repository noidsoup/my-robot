---
title: Log
type: overview
summary: Append-only history of wiki changes. Newest last.
status: active
created: 2026-07-29
updated: 2026-10-19
last_verified: 2026-10-19
sources: []
tags: [meta]
---

# Log

Format: `## [YYYY-MM-DD] ingest|session|lint|query|seed|upgrade | one line`. Keep ≤150 entries; move older ones to `log/YYYY.md`.

## [2026-07-29] create | Wiki bootstrapped

Initial vault created by my-robot bootstrap (SCHEMA, index, log, folder layout, Obsidian settings). Ready for ingest from `docs/` or new sources.

## [2026-10-19] upgrade | Wiki moved to wiki/ and seeded to the standard

Renamed `my-robot wiki/` → `wiki/` (kept `.obsidian/`). The vault held only the empty template pages; replaced SCHEMA and index with the standard and seeded [[overview]], [[gotchas]], [[bootstrap-installer]], [[template-payload]], [[seven-layer-system]], [[honest-verify-gate]] and decisions 0001–0004 from README, ARCHITECTURE, AGENTS, the runbook, session memory and commit history. `scripts/wiki-lint.py` and its template copy now also find a bare `wiki/`. Found: the payload still installs `<repo> wiki/` and would duplicate a `wiki/` folder ([[0002-named-vault-convention]]).
