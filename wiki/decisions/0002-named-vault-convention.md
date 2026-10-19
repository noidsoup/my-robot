---
title: "0002 — Payload wiki lives at <repo> wiki/"
type: decision
summary: In 2026-07 the payload adopted caper-app's "<repo> wiki/" vault name; Nicholas's repos moved to wiki/ on 2026-10-19 but the payload has not.
status: superseded
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [AI_SESSION_MEMORY.md, "commit c700264", bootstrap.sh, template/wiki/SCHEMA.md, scripts/wiki-lint.py, ~/.claude/skills/closeout/wiki-template/SCHEMA.md]
tags: [adr, wiki]
---

# 0002 — Payload wiki lives at `<repo> wiki/`

> **Superseded for Nicholas's own repos (2026-10-19).** The new standard is a plain `wiki/` folder with overview, gotchas and a "Must know" index (`~/.claude/skills/closeout/wiki-template/`). This repo's own wiki moved to `wiki/` the same day. The **payload is unchanged** and still installs `<repo> wiki/` — see Consequences.

## Context

L4 was added on 2026-07-29 (commit `c700264`), generalized from caper-app's wiki. caper-app used a folder named after the repo plus " wiki", so the vault name shows in Obsidian's vault list (`AI_SESSION_MEMORY.md`, 2026-07-29).

## Decision (2026-07-29)

- Vault at `<repo-folder-name> wiki/` (with a space), plus a root `WIKI.md` explaining the name.
- `scripts/wiki-lint.py` looked only for `* wiki/` folders ("never bare wiki/"); the LanceDB indexer discovered `* wiki/` folders.

## What changed on 2026-10-19

- This repo: `my-robot wiki/` → `wiki/`. `scripts/wiki-lint.py` and `template/scripts/wiki-lint.py` now also accept a bare `wiki/` (small, backward-compatible change so the dogfood lint keeps working).

## Consequences / open follow-up

- `bootstrap.sh` L4 still creates `<repo> wiki/` and checks only for that name, so it adds a duplicate vault to any repo that already has `wiki/` ([[gotchas]]). Fixing it means changing L4, `template/wiki/*`, `WIKI.stub.md`, `AGENTS.stub.md`, README and the smoke tests — a product change not done in the wiki upgrade. *(open)*

## Related

- [[template-payload]]
- [[bootstrap-installer]]
