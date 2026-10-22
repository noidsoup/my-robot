---
title: "0004 — This repo's agent setup is separate from the payload"
type: decision
summary: my-robot's own rules live in .claude/ (Claude Code); template/ keeps the Cursor-format payload untouched.
status: active
created: 2026-10-19
updated: 2026-10-21
last_verified: 2026-10-21
sources: ["commit be40cc6", AGENTS.md, .claude/CLAUDE.md]
tags: [adr, agents, claude-code]
---

# 0004 — This repo's agent setup is separate from the payload

## Status

**Active** since 2026-10-10 (commit `be40cc6`).

## Context

Cursor was retired on 2026-10-02. Claude Code never read this repo's own `.cursor/rules`, and nothing imported `AGENTS.md`.

## Decision

- `.claude/CLAUDE.md` imports `AGENTS.md`; root `CLAUDE.md` stays local to Origin.
- This repo's rules moved to `.claude/rules/`: two always-on, `llm-wiki` path-scoped to the wiki.
- `template/`, `bootstrap.sh`, README, docs and tests were deliberately left alone: they describe and test what the installer writes into **other** repos, which may still use Cursor.

## Consequences

- ~~The payload still installs Cursor-format `.mdc` rules and a root `CLAUDE.md` bridge.~~ Resolved 2026-10-21: the payload now targets Claude Code (`.claude/rules/*.md`, `.claude/CLAUDE.md`); Cursor `.mdc` only for Cursor-only repos ([[gotchas]]).
- Updating the payload for Claude Code is an open product decision. *(open)*

## Related

- [[template-payload]]
- [[0002-named-vault-convention]]
