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

- **A verify gate** (`.verify.sh`) that chains the checks your repo already has — tests, lint, typecheck. If your repo has nothing runnable, you get a gate that *fails loudly* instead of pretending to pass.
- **Semantic search** over your own docs and code (LanceDB, fully offline). Non-Python repos get a note explaining the sidecar option instead of broken scripts.
- **Agent rules** that fire every turn: search before acting, run the gate before saying done. Installs to `.cursor/rules/` or `.claude/rules/`.
- **The [loops](https://github.com/noidsoup/loops) workflow pack** — 9 workflows (plan-and-implement, tdd, adversarial-gate…) and 9 review personas, symlinked in as `.loops`.
- **An Obsidian wiki** at `<repo> wiki/` — a knowledge base with conventions the agent follows: decision records, runbooks, an index and log. Open it in Obsidian, and everything it writes is searchable by the semantic layer.
- **Memory files** the agent maintains — context survives sessions.
- **An `AGENTS.md` stub** and sensible `.gitignore` entries.

Nothing you already have gets touched. Every write is create-if-absent; re-running the script reports `existed` and moves on. Run `--dry-run` first if you want to see the plan.

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

Two things need a human:

1. **The verify gate** — if you got the fail-loud stub, add tests or lint so "correct" means something.
2. **The AGENTS.md stub** — fill in the `<PLACEHOLDERS>` with your stack and hard-won rules. Five minutes.

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
