---
title: Overview
type: overview
summary: What my-robot is (a one-script installer for Nicholas's AI-first repo setup), who it's for, where it lives.
status: active
created: 2026-10-19
updated: 2026-10-19
last_verified: 2026-10-19
sources: [README.md, AGENTS.md, docs/ARCHITECTURE.md, AI_RUNBOOK.md, docs/portfolio-blurb.md, .github/workflows/verify.yml]
tags: [overview]
---

# my-robot

`bootstrap.sh` plus a `template/` payload that installs Nicholas's "7-layer AI-first development system" into any git repo: an honest verify gate, env stub, retrieval, agent rules, loops workflows, an Obsidian wiki and memory files (`docs/ARCHITECTURE.md`). It never overwrites existing files ([[0001-create-if-absent]]).

## What and why

- **Problem it solves:** coding agents guess paths, forget between sessions and claim "done" without running tests; every AI-assisted repo ends up hand-building the same guardrails (`docs/portfolio-blurb.md`).
- **How:** detect the stack (Node, Python, Go, Cursor, Claude), then install only the layers that fit ([[bootstrap-installer]], [[seven-layer-system]], [[template-payload]]).
- **Also a portfolio piece:** public on GitHub with a README, demo GIF and blurbs written for prospects (commit `16622a2`).
- **Status:** feature-complete since 2026-08-29 (L6 harness, commit `3dd2333`); the only later change was this repo's own Claude Code setup (commit `be40cc6`).

## People and roles

| Role | Who |
|---|---|
| Owner and maintainer | Nicholas (`noidsoup`) |
| Users | Nicholas across his repos; anyone who clones the public repo |

## Where it runs

| Environment | URL / host | Deploys from |
|---|---|---|
| GitHub (public) | <https://github.com/noidsoup/my-robot> | `main` |
| Standalone installs | `curl …/main/bootstrap.sh \| bash`; templates cached in `~/.my-robot` (`MY_ROBOT_HOME`) | raw files on `main` ([[bootstrap-installer]]) |
| Loops dependency | `~/.loops` → `noidsoup/loops`, symlinked as `.loops` in each target | `bootstrap.sh` L3 |
| CI | GitHub Actions `verify.yml`: installs shellcheck, runs `bash .verify.sh` on pushes/PRs to `main` | `.github/workflows/verify.yml` |
| Working checkout | `~/projects/my-robot` | — |
| Older clone (don't edit) | `~/Repos/my-robot` at `16622a2` (2026-08-17) | — |

## Key links

- Gate: `bash .verify.sh` — smoke test (55 checks at `be40cc6`), harness lint, shellcheck if installed, wiki-lint (advisory) ([[honest-verify-gate]])
- Install how-to and standalone curl notes: `AI_RUNBOOK.md`; demo transcript: `docs/demo.md`
- Sibling: [loops](https://github.com/noidsoup/loops) — workflows that L3 links in

## Related

- [[gotchas]]
- [[0003-adopt-competitor-patterns]]
- [[0004-own-setup-vs-payload]]
