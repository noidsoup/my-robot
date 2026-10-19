---
title: bootstrap.sh installer
type: entity
summary: The one-script installer: modes, stack detection, template cache, and what it reports.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [bootstrap.sh, AI_RUNBOOK.md, tests/smoke_bootstrap.sh, "commit a8442b6"]
tags: [installer, bash]
---

# bootstrap.sh installer

`bootstrap.sh [--dry-run|--doctor] [TARGET_DIR]` installs the layers into a target repo and prints a per-layer report (`bootstrap.sh` header).

## Modes

| Mode | Writes? | Notes |
|---|---|---|
| apply (default) | yes, create-if-absent | statuses `installed` / `existed` / `failed`; write failures exit 1 |
| `--dry-run` | no | statuses `would-write` / `would-link` / `would-clone` / `would-ensure` |
| `--doctor` | no | read-only health check (also installed as `scripts/doctor.sh`) |

## Template source

- Run from a clone: uses `template/` next to the script.
- Run standalone (curl): downloads each file in `TEMPLATE_FILES` from `raw.githubusercontent.com/noidsoup/my-robot/main/template/` into `~/.my-robot/template` (override `MY_ROBOT_HOME`). Missing files are fetched even when the cache exists, so new payload files reach old caches.

## Stack detection

`git`, Node (`package.json`), Python (`pyproject.toml`, `requirements.txt`, `setup.py`, `*.py` at root, or non-helper `scripts/*.py`), Go (`go.mod`), Cursor (`.cursor/`), Claude (`.claude/` or `CLAUDE.md`). Python → LanceDB scaffold; otherwise a `docs/ai-retrieval.md` sidecar note. Cursor present or no Claude → rules in `.cursor/rules`, else `.claude/rules`.

## Other writes

`.gitignore` lines it manages (e.g. `.loops`), an install manifest, `AGENTS.md` (minimal, only if absent), `WIKI.md`, ops stubs (`AI_RUNBOOK.md`, `docs/ARCHITECTURE.md`), harness helpers (`scripts/run-verify-phases.sh`, `wiki-lint.py`, `doctor.sh`, `handoff.sh`).

## Related

- [[template-payload]]
- [[seven-layer-system]]
- [[0001-create-if-absent]]
- [[gotchas]]
