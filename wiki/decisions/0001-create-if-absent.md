---
title: "0001 — Create-if-absent, honest dry-run, fail loud"
type: decision
summary: The installer never overwrites, dry-run never claims installed, and empty gates exit 1.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [bootstrap.sh, AGENTS.md, "commit 60e6b15", tests/smoke_bootstrap.sh]
tags: [adr, installer, safety]
---

# 0001 — Create-if-absent, honest dry-run, fail loud

## Status

**Active** since the first release (2026-07-29); dry-run honesty enforced by commit `60e6b15` after an audit (2026-07-29). `AGENTS.md` invariants 3–5.

## Context

The tool is run on repos that already have work in them, often by someone who has not read the script. An overwrite or a fake "installed" line destroys trust.

## Decision

- Every write is create-if-absent-else-skip. Overwrite behavior needs an explicit flag (none exists).
- Incomplete wiki vaults are repaired (missing or empty core pages only); non-empty pages are never touched.
- `--dry-run` reports `would-write` / `would-link` / `would-ensure` and writes nothing; failed writes report `failed` and exit 1.
- A target with no runnable checks gets a fail-loud `.verify.sh` ([[honest-verify-gate]]).

## Consequences

- Re-runs are safe and report `existed`.
- Upgrading an installed file means deleting it first (e.g. `.verify.sh` regeneration in `AI_RUNBOOK.md`).
- `tests/smoke_bootstrap.sh` asserts dry-run honesty and idempotency; keep it green.

## Related

- [[bootstrap-installer]]
- [[gotchas]]
