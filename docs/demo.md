# Demo — what 30 seconds gets you

Scenario: a brand-new Node project, no tests wired, `.cursor/rules` exists but is empty.

```console
$ bootstrap.sh .
== my-robot bootstrap ==
target:  /tmp/myrobot-smoketest
git:0  node:1  python:0  go:0  cursor:1  claude:0

WARN: not a git repo — proceeding anyway

LAYER                STATUS         DETAIL
-----                ------         ------
L0 Ground Truth      generated      .verify.sh: npm run lint, npm run test
L0.5 Env Parity      installed      .env.example stub
L1 Retrieval         note           non-Python: docs/ai-retrieval.md explains Python-sidecar option
L2 Constraints       installed      .cursor/rules (3 new, 0 existed, 0 failed)
L3 Workflows         installed      .loops -> /Users/you/.loops (symlink, auto-updates)
L4 Knowledge Wiki    installed      myrobot-smoketest wiki/ (open in Obsidian as vault)
  WIKI.md pointer    installed      repo-root pointer to the vault
L5 Continuity        installed      memory stubs (2 new, 0 existed, 0 failed)
  AI_RUNBOOK.md      installed      ops / deploy / env stub
  ARCHITECTURE.md    installed      docs/ARCHITECTURE.md stub
gitignore            ensured        .loops ignored
AGENTS.md            installed      minimal stub — fill in stack + invariants

Done.
```

Dry-run on a fresh target reports `would-write` / `would-link` instead of `installed`:

```console
$ bootstrap.sh --dry-run .
...
L0.5 Env Parity      would-write    .env.example stub
L2 Constraints       would-write    .cursor/rules (3 new, 0 existed)
L4 Knowledge Wiki    would-write    myrobot-smoketest wiki/ (SCHEMA, index, log, .obsidian)
...
```

Re-run it and nothing clobbers:

```console
$ bootstrap.sh .
...
L0 Ground Truth      existed        .verify.sh already present
L2 Constraints       existed        .cursor/rules (0 new, 3 existed, 0 failed)
L3 Workflows         existed        .loops already present
L4 Knowledge Wiki    existed        myrobot-smoketest wiki/ left untouched
AGENTS.md            existed        left untouched
```

From here, open Cursor or Claude Code in that repo and say **"use the loops"** — the agent routes through the [loops](https://github.com/noidsoup/loops) dispatcher, searches before it acts (pre-task-retrieval rule), and runs `.verify.sh` before declaring anything done.
