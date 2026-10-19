---
title: Index
type: overview
summary: Start here. Must-know facts, then one line per page.
status: active
created: 2026-07-29
updated: 2026-10-19
last_verified: 2026-10-19
sources: []
tags: [meta]
---

# my-robot wiki

## Must know

- `template/` is the payload for other repos; this repo's own setup is `.claude/` + `AGENTS.md` ([[0004-own-setup-vs-payload]]).
- Never clobber; dry-run never says `installed`; empty gates exit 1 ([[0001-create-if-absent]]).
- Keep `TEMPLATE_FILES` in `bootstrap.sh` in sync with `template/` ([[bootstrap-installer]]).
- The payload still installs `<repo> wiki/` and duplicates a `wiki/` folder ([[0002-named-vault-convention]]).
- Work in `~/projects/my-robot`; `~/Repos/my-robot` is an older clone ([[overview]]).

## Overview

- [[overview]] — what this is, who it's for, where it lives
- [[gotchas]] — known traps; check after a repeated failure

## Entities

- [[bootstrap-installer]] — `bootstrap.sh`: modes, template cache, stack detection
- [[template-payload]] — what `template/` installs and where

## Concepts

- [[seven-layer-system]] — L0–L6 and the failure each prevents
- [[honest-verify-gate]] — generated `.verify.sh` that fails loud; this repo's gate

## Decisions

- [[0001-create-if-absent]] — never overwrite, honest dry-run, fail loud
- [[0002-named-vault-convention]] — `<repo> wiki/` payload vault (superseded for Nicholas's repos)
- [[0003-adopt-competitor-patterns]] — doctor, harness, wiki-lint, bridges, manifest
- [[0004-own-setup-vs-payload]] — Claude Code setup here; payload untouched

## Meta

- [[SCHEMA]] — how to write here · [[log]] — change history
