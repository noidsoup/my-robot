# my-robot 🤖

**Clone my robot.** One script turns any repo into an AI-first project — with a verification gate, persistent memory, semantic code search, enforced agent rules, and a full workflow methodology — in about 30 seconds.

```bash
git clone https://github.com/noidsoup/my-robot
my-robot/bootstrap.sh --dry-run /path/to/your/repo   # see the plan
my-robot/bootstrap.sh /path/to/your/repo             # apply it
```

Or run it standalone (it fetches what it needs):

```bash
curl -fsSL https://raw.githubusercontent.com/noidsoup/my-robot/main/bootstrap.sh | bash
```

## The problem

Point an AI coding agent at a repo and it will:

- **hallucinate** paths, APIs, and behavior it never checked,
- **forget** everything between sessions,
- **declare victory** without running a single verification command,
- **wander** with no shared rules, no memory, no methodology.

Every serious AI-assisted project ends up hand-rolling the same fixes: an AGENTS.md, some Cursor/Claude rules, a memory file, a verify script, an index for retrieval. This is that work, done once, installable anywhere.

## What it installs — the 7 layers

| Layer | What | How |
|---|---|---|
| **L0 Ground Truth** | `.verify.sh` — a gate that chains only the checks that already exist in your repo (tests, lint, typecheck). Never fabricates a suite; repos with nothing runnable get an honest fail-loud stub. | generated from your stack |
| **L0.5 Env Parity** | `.env.example` stub — secrets live in `.env` (gitignored), never in code or chat. | template |
| **L1 Retrieval** | Semantic search over your project's own docs/code: 3 LanceDB scripts (index, search, shared lib). Fully offline after install. Non-Python repos get a sidecar note instead of broken scripts. | template, stack-aware |
| **L2 Constraints** | Agent rules that fire every turn: `pre-task-retrieval` (search before acting) and `verify-before-done` (run the gate, paste real output). Installs to `.cursor/rules/` or `.claude/rules/`. | template |
| **L3 Workflows** | The [**loops**](https://github.com/noidsoup/loops) methodology — dispatcher + 9 workflows (plan-and-implement, tdd, adversarial-gate, reproduce-and-fix, migrate…) + 9 review personas. Cloned once to `~/.loops`, symlinked into your repo as `.loops`. | git clone |
| **L5 Continuity** | `AI_SESSION_MEMORY.md` + `MEMORY.md` stubs — the agent maintains these, not you. Context survives sessions. | template |
| **L6 Self-Correction** | Builder → Judge → Manager contract, via loops. No per-repo file needed. | via loops |

Plus a minimal `AGENTS.md` stub (only if absent) and `.gitignore` entries.

## Safety guarantees

1. **Idempotent** — every write is create-if-absent-else-skip. Run it 10×, same result.
2. **Never clobbers** — existing verify scripts, rules, memory files, AGENTS.md are left untouched and reported as `existed`.
3. **Stack-aware** — detects Node / Python / Go / Cursor / Claude and installs only what fits.
4. **Dry-run first** — `--dry-run` shows the full plan, writes nothing.
5. **Honest** — if your repo has no tests, it says so and writes a gate that *fails loudly* instead of pretending to pass.

## Example run

```
== my-robot bootstrap ==
target:  /Users/you/code/my-app
git:1  node:1  python:0  go:0  cursor:1  claude:0

LAYER                STATUS         DETAIL
-----                ------         ------
L0 Ground Truth      generated      .verify.sh: npm test, npm run lint
L0.5 Env Parity      installed      .env.example stub
L1 Retrieval         note           non-Python: docs/ai-retrieval.md explains Python-sidecar option
L2 Constraints       installed      .cursor/rules (2 new, 0 existed)
L3 Workflows         installed      .loops -> /Users/you/.loops (symlink, auto-updates)
L5 Continuity        installed      memory stubs (2 new, 0 existed)
gitignore            ensured        uncommitted/ + .loops ignored
AGENTS.md            installed      minimal stub — fill in stack + invariants
Done.
```

## After bootstrap

Two things the script deliberately does **not** fake:

1. **L0 verify gate** — if your repo had no runnable checks, you got a fail-loud stub. Define what "correct" means (add tests/lint), then re-run.
2. **AGENTS.md stub** — has `<PLACEHOLDERS>`. Fill in your stack and hard-won invariants. Five minutes, pays for itself on the first agent session.

For Python repos, finish the retrieval layer:

```bash
pip install -r requirements-lancedb.txt
python3 -u scripts/index_project_knowledge_lancedb.py --apply
```

## The companion: loops

Want the full transcript of a real run? See [docs/demo.md](docs/demo.md).

my-robot installs the **foundation**; [loops](https://github.com/noidsoup/loops) is the **methodology** that runs on top of it. Once bootstrapped, say *"use the loops"* to your agent and it will route through the dispatcher: plan-and-implement for features, tdd for behavior-locking, adversarial-gate before merges, reproduce-and-fix for bugs.

## Who made this

Built by [noidsoup](https://github.com/noidsoup) — I run AI-first development across a fleet of production repos and this is the system I install everywhere. **If you want this running on your projects (or your team), [let's talk](https://github.com/noidsoup).**

## License

MIT — see [LICENSE](LICENSE). Take it, fork it, ship it.
