# AGENTS.md — <PROJECT NAME>

> Minimal stub created by `bootstrap`. Ask your coding agent to fill the bracketed
> parts from this repo, then delete this note. Every command it writes here must be
> one it actually ran, with the real result. Keep the file small (<~200 lines);
> link out to deeper docs instead of inlining everything.

**This repo:** <one line: what it is and who uses it>
**Stack:** <language / framework / package manager / host>
**Owner:** <personal | team | client: name> — see "Git and push safety".

## Signal Gate (what belongs here)

Put **non-discoverable** signals only: hard constraints, commands, security gotchas,
scar-tissue rules. Do **not** dump file trees, dependency lists, or architecture
overviews the agent can read from source (that burns tokens and hurts accuracy).

## Working rules

1. **Think before coding.** State assumptions, surface tradeoffs, ask before guessing.
2. **Simplicity first.** Minimum code that solves the problem; no speculative abstractions.
3. **Surgical changes.** Touch only what the task needs. Match the existing style.
4. **Read before you write.** Read the file's exports and its caller before adding to it.
5. **Fail loud.** If you can't be sure it worked, say so. Never report skipped work as done.
6. **Check after every change.** Run the type check / lint from "Commands" after each edit.
7. **Behavior changes ship with tests**, where a test runner exists (see "What can be verified").
8. **Never ratchet a test to match current output.** Find why it changed; decide whether the code or the test is wrong.

## Commands (tested)

Runtime: <e.g. Node 22 (pinned in `.nvmrc`), Python 3.12> · Last verified: <YYYY-MM-DD>

| Task | Command (run from) | Notes |
| ---- | ------------------ | ----- |
| Install | <e.g. `yarn install --frozen-lockfile` (root)> | <flags you needed and why, e.g. `--ignore-engines`: sub-package wants a newer Node> |
| Type check | <e.g. `npx tsc --noEmit` (ui/)> | <baseline: N pre-existing errors> |
| Test | <command> | <needs emulator? runtime?> |
| Build | <command> | |
| Dev server | <command> | <port; how to tell dev from prod mode> |
| Verify gate | `bash .verify.sh` | runs the checks above that exist |

## Known baseline

Errors and failures that already exist on the default branch, so new ones stand out:
<e.g. "`ui/` type check: 10 errors in 4 files as of YYYY-MM-DD" — or "none: clean">

## What can be verified

<e.g. "functions/: unit + emulator tests. ui/: no test runner — verify UI changes in the
browser on the dev server." Say plainly what has no automated check.>

## Running locally and logging in

<How to sign in on the local app: emulator + seeded user, a staging test account (where its
credentials live — never paste them here), or why local login isn't possible. Say which
backend local runs hit, and whether that is shared data.>

## Dev vs production gotchas

<Things that silently differ, e.g. "the bundler builds in dev mode only via `npm start`;
running it directly builds production".>

## Git and push safety

- Default branch: <main>. Branch naming: <convention>. Never commit to the default branch.
- Push policy: <push freely to origin | ask first | push disabled locally — client repo>.
- Machine-only files (scratch notes, `CLAUDE.local.md`, local launch configs) are excluded in
  `.git/info/exclude`, never `.gitignore`. <List any tool that injects text into tracked files
  or commit messages, and how to keep it out of commits.>

## Retrieval order (read before acting)

Governed by `.claude/rules/pre-task-retrieval.md` (Cursor: `.cursor/rules/*.mdc`). Cheapest-first:
1. SimpleMem (if present) → 2. LanceDB (`scripts/search_project_knowledge_lancedb.py`)
→ 3. project wiki → 4. long-term memory.

## Invariants (always apply)

1. **Verify before done.** Run the gate, paste real output. See `.claude/rules/verify-before-done.md`.
2. **Secrets only in `.env`** (gitignored). Behavioral config in config files, never env vars.
3. <add project-specific hard rules here — the scar-tissue ones>

## Topic → where

| Need | Open |
| ---- | ---- |
| Task-specific docs (read the ones that apply before starting) | `.claude/docs/*.md` <list each with one line> |
| Operations / deploy / env | `AI_RUNBOOK.md` (created by bootstrap) |
| Recent decisions | `AI_SESSION_MEMORY.md` |
| Architecture | `docs/ARCHITECTURE.md` (created by bootstrap) |
| Wiki | `"<repo> wiki/"` (see `WIKI.md`) |
| Workflows (plan, tdd, gate, migrate…) | global `.loops/` (say "use the loops") |
| Health check | `bash path/to/my-robot/bootstrap.sh --doctor .` |

## Continuity

At close-out: append to `AI_SESSION_MEMORY.md`, update `MEMORY.md`, re-index changed
docs. When a command, baseline, or login step above turns out wrong, fix it here in the
same session. Optional: `bash scripts/handoff.sh "one-line note"` for a paste-ready kickoff.
The AI maintains these — not the human.
