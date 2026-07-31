# AGENTS.md — <PROJECT NAME>

> Minimal stub created by `bootstrap`. Ask your coding agent to fill the bracketed
> parts from this repo, then delete this note. Keep the file small (<~200 lines);
> link out to deeper docs instead of inlining everything.

**This repo:** <one line: what it is and who uses it>
**Stack:** <language / framework / package manager / host>

## Signal Gate (what belongs here)

Put **non-discoverable** signals only: hard constraints, commands, security gotchas,
scar-tissue rules. Do **not** dump file trees, dependency lists, or architecture
overviews the agent can read from source (that burns tokens and hurts accuracy).

## Evidence (what “verified” means)

Prefer proof over vibes. Good evidence kinds:

1. **Command output** — `.verify.sh` / tests / lint (paste real exit codes)
2. **Diff** — what changed and why
3. **Reproduction** — bug failed before, passes after (or still fails honestly)
4. **Cross-check** — second path (UI, API, sibling package) when the change fans out

## Retrieval order (read before acting)

Governed by `.cursor/rules/pre-task-retrieval.mdc`. Cheapest-first:
1. SimpleMem (if present) → 2. LanceDB (`scripts/search_project_knowledge_lancedb.py`)
→ 3. project wiki → 4. long-term memory.

## Invariants (always apply)

1. **Verify before done.** Run the gate, paste real output. See `.cursor/rules/verify-before-done.mdc`.
2. **Secrets only in `.env`** (gitignored). Behavioral config in config files, never env vars.
3. <add project-specific hard rules here — the scar-tissue ones>

## Definition of done (commands)

```bash
bash .verify.sh                 # L0 gate
# optional: bash scripts/run-verify-phases.sh   # after wiring .harness/verify.conf
```

## Topic → where

| Need | Open |
| ---- | ---- |
| Operations / deploy / env | `AI_RUNBOOK.md` (created by bootstrap) |
| Recent decisions | `AI_SESSION_MEMORY.md` |
| Architecture | `docs/ARCHITECTURE.md` (created by bootstrap) |
| Wiki | `"<repo> wiki/"` (see `WIKI.md`) |
| Workflows (plan, tdd, gate, migrate…) | global `.loops/` (say "use the loops") |
| Health check | `bash path/to/my-robot/bootstrap.sh --doctor .` |

## Continuity

At close-out: append to `AI_SESSION_MEMORY.md`, update `MEMORY.md`, re-index changed
docs. Optional: `bash scripts/handoff.sh "one-line note"` for a paste-ready kickoff.
The AI maintains these — not the human.
