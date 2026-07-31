# my-robot 🤖

**Clone my robot.** One script gives any repo the setup I use to make AI coding agents trustworthy — in about 30 seconds.

```bash
git clone https://github.com/noidsoup/my-robot
my-robot/bootstrap.sh --dry-run /path/to/your/repo   # see what it would do
my-robot/bootstrap.sh /path/to/your/repo             # do it
```

Prefer the clone path. A one-liner fetch exists for convenience — **review the script before piping to a shell**, and start with `--dry-run`:

```bash
curl -fsSL https://raw.githubusercontent.com/noidsoup/my-robot/main/bootstrap.sh | bash -s -- --dry-run
```

Greenfield repos (no Cursor/Claude yet) get `.cursor/rules` by default; Claude-only repos (`CLAUDE.md` / `.claude/`) get `.claude/rules`.

## The problem

Left alone, an AI coding agent will invent paths it never checked, forget everything between sessions, and say "done" without running a single test. Every serious AI-assisted project ends up hand-building the same fixes: a verify script, some agent rules, a memory file, a way to search the docs.

This is that work, done once, installable anywhere.

## What you get

| | What | Why it matters |
|---|---|---|
| **Verify gate** | `.verify.sh` runs your existing tests / lint / typecheck | “Done” means something. No suite? It fails loudly instead of faking a pass. |
| **Semantic search** | LanceDB over your docs and code (offline) | Agents look things up before inventing them. Non-Python repos get a short sidecar note, not broken scripts. |
| **Agent rules** | Search-before-acting + verify-before-done | Installed to `.cursor/rules/` or `.claude/rules/`. |
| **[loops](https://github.com/noidsoup/loops)** | 9 workflows + 9 review personas | Symlinked in as `.loops` (plan-and-implement, tdd, adversarial-gate, …). |
| **Obsidian wiki** | `<repo> wiki/` | Decisions, runbooks, index, and log — agent-readable, human-browsable, searchable. |
| **Memory** | Session + long-term memory files | Context survives across chats. |
| **AGENTS.md** | Stub + `.gitignore` tweaks | A place for your stack and hard rules. |

Safe by default: nothing you already have is overwritten. Re-runs report `existed` and skip. Prefer `--dry-run` first. Health-check an install with `bootstrap.sh --doctor`.

## What it looks like

```
L0 Ground Truth      generated      .verify.sh: npm test, npm run lint
L1 Retrieval         note           non-Python: docs/ai-retrieval.md
L2 Constraints       installed      .cursor/rules (3 new)
L3 Workflows         installed      .loops -> ~/.loops (symlink)
L4 Knowledge Wiki    installed      my-app wiki/ (open in Obsidian)
L5 Continuity        installed      memory stubs (2 new)
Done.
```

Full transcript of a real run: [docs/demo.md](docs/demo.md).

## After it runs

1. **Verify gate** — if you got the fail-loud stub, add real tests or lint so “correct” means something.
2. **AGENTS.md** — ask your coding agent to fill the `<PLACEHOLDERS>` from the repo (stack, deploy host, hard rules). Spot-check; don’t invent secrets.
3. **Optional harness** — copy `.harness/verify.conf.example` → `.harness/verify.conf`, then `bash scripts/run-verify-phases.sh`. Lint the wiki with `python3 scripts/wiki-lint.py`.

Python repos, one more step to light up search:

```bash
pip install -r requirements-lancedb.txt
python3 -u scripts/index_project_knowledge_lancedb.py --apply
```

Then open your repo in Cursor or Claude Code and say **"use the loops."**

## Who made this

I'm [noidsoup](https://github.com/noidsoup). I run AI-first development across a fleet of production repos, and this is the system I install everywhere. **Want it running on yours? [Let's talk](https://github.com/noidsoup).**

## License

MIT — take it, fork it, ship it.
