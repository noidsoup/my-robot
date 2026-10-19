---
title: Honest verify gate
type: concept
summary: Generated .verify.sh chains only checks that exist and fails loud when there are none.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [template/gen-verify-gate.sh, bootstrap.sh, .verify.sh, "commit 60e6b15", "commit 3dd2333"]
tags: [verify, l0]
---

# Honest verify gate

`template/gen-verify-gate.sh` writes a target's `.verify.sh` from the checks it can find. It never invents a test suite: a repo with nothing runnable gets a stub that **exits 1**, so a missing gate can't look like a pass (script header; `AGENTS.md` invariant 5).

## Rules

- An existing `.verify.sh` is never overwritten; to regenerate, delete it and rerun the generator (`AI_RUNBOOK.md`).
- JS repos also get an npm `verify` script unless one exists.
- Bash 3.2 compatible (macOS default): no `mapfile`, no associative arrays.
- Dry-run previews the detected checks (commit `ef13761`).

## This repo's own gate

`.verify.sh` here runs `tests/smoke_bootstrap.sh` (bootstrap against throwaway Node/Python repos: dry-run honesty, apply, idempotency, vault repair), `scripts/harness-lint.sh`, shellcheck when installed (CI installs it), and `scripts/wiki-lint.py` as advisory. `.harness/verify.conf` lists the same phases for `scripts/run-verify-phases.sh`.

## Related

- [[seven-layer-system]]
- [[0001-create-if-absent]]
