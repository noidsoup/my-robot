---
title: "0003 — Adopt proven patterns from similar tools"
type: decision
summary: On 2026-07-31 my-robot copied doctor, declarative verify phases, wiki-lint, thin bridges and a manifest from six comparable projects.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: ["commit ef13761"]
tags: [adr, harness]
---

# 0003 — Adopt proven patterns from similar tools

## Status

**Active.** Commit `ef13761` (2026-07-31).

## Context

A deep-dive of agent-feed, prove-it, contextdocs, agentic-bootstrap, agentsmith and llm-wiki-template looked for features my-robot lacked.

## Decision

| Added | Borrowed from |
|---|---|
| `bootstrap.sh --doctor` (read-only health) | agent-feed, prove-it |
| `.harness/verify.conf` + `run-verify-phases.sh` (declarative phases) | agentsmith |
| `scripts/wiki-lint.py` for named vaults; `raw/`, `synthesis/` dirs and a contradiction protocol in the vault SCHEMA | llm-wiki-template |
| Thin `CLAUDE.md` + `agents.mdc` bridges pointing at `AGENTS.md` | contextdocs |
| Install manifest (agent-feed, per the `bootstrap.sh` comment); `handoff.sh`, Signal Gate + evidence section in the AGENTS stub | not attributed in the commit |
| L0 dry-run previews detected checks (`gen-verify --dry-run`) | — |

## Consequences

- `wiki-lint.py` is always written into `scripts/`, which later made a Node repo look like Python on re-run; fixed in `a8442b6` by ignoring installer helper scripts ([[gotchas]]).

## Related

- [[bootstrap-installer]]
- [[template-payload]]
