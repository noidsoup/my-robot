---
title: Gotchas
type: overview
summary: Known traps. Check here after a repeated failure.
status: active
created: 2026-10-19
updated: 2026-10-21
last_verified: 2026-10-21
sources: [bootstrap.sh, AGENTS.md, AI_RUNBOOK.md, "commit a8442b6", "commit 60e6b15", "commit be40cc6"]
tags: [gotchas]
---

# Gotchas

One line each: the trap, then the fix or the page with details.

- **Bootstrap creates a second wiki in repos that use `wiki/`.** L4 only checks for `<repo> wiki/`, so running it on a repo already on the 2026-10 `wiki/` standard adds `<repo> wiki/`, which the standard lint reports as an error. Delete it or skip L4 until the payload follows the standard. → [[0002-named-vault-convention]]
- **Cursor-only repos stay on `.mdc` rules.** A repo with `.cursor/` and no Claude setup, or one that already got `.mdc` rules, keeps getting them; Claude Code won't read them. Move it to Claude by hand. → [[0004-own-setup-vs-payload]]
- **The `.claude/CLAUDE.md` bridge is skipped only when root `CLAUDE.md` already mentions `AGENTS.md`.** Both files load, so a root file that imports it would load AGENTS.md twice.
- **Editing `template/` changes other repos, not this one.** This repo's own setup is `.claude/` + `AGENTS.md`. → [[0004-own-setup-vs-payload]]
- **`TEMPLATE_FILES` in `bootstrap.sh` must list every file under `template/`**, or standalone (curl) installs silently miss it (`AGENTS.md`, invariant 7). → [[bootstrap-installer]]
- **Dry-run must never say `installed`.** Use `would-write` / `would-link` / `would-ensure`; the smoke test asserts it (commit `60e6b15`). → [[0001-create-if-absent]]
- **Installer helper scripts are not "Python".** `scripts/wiki-lint.py` and the LanceDB scripts are ignored by stack detection; without that, a Node repo gained a LanceDB scaffold on re-run (commit `a8442b6`). → [[bootstrap-installer]]
- **Empty gates must exit 1.** Never let the generated `.verify.sh` pass with no checks. → [[honest-verify-gate]]
- **Generated gates must not name `~/.hermes/` paths;** use the portable `path/to/my-robot/template/gen-verify-gate.sh` (`AGENTS.md`, invariant 6).
- **Put `MY_ROBOT_HOME` on `bash`, not on `curl`,** when piping the standalone installer (`AI_RUNBOOK.md`).
- **`~/Repos/my-robot` is an older clone** (HEAD `16622a2`); edits there don't reach `main`. Use `~/projects/my-robot`.
- **The wiki-lint step in `.verify.sh` is advisory** — it can fail without failing the gate unless `MY_ROBOT_STRICT_WIKI=1`. Read its output.

## Related

- [[overview]]
- [[index]]
