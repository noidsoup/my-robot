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
L0 Ground Truth      generated      .verify.sh: npm run test
L0.5 Env Parity      installed      .env.example stub
L1 Retrieval         note           non-Python: docs/ai-retrieval.md explains Python-sidecar option
L2 Constraints       installed      .cursor/rules (2 new, 0 existed)
L3 Workflows         installed      .loops -> /Users/you/.loops (symlink, auto-updates)
L5 Continuity        installed      memory stubs (2 new, 0 existed)
gitignore            ensured        uncommitted/ + .loops ignored
AGENTS.md            installed      minimal stub — fill in stack + invariants

Done.
```

Re-run it and nothing clobbers:

```console
$ bootstrap.sh .
...
L0 Ground Truth      existed        .verify.sh already present
L2 Constraints       installed      .cursor/rules (0 new, 2 existed)
L3 Workflows         existed        .loops already present
AGENTS.md            existed        left untouched
```

From here, open Cursor or Claude Code in that repo and say **"use the loops"** — the agent routes through the [loops](https://github.com/noidsoup/loops) dispatcher, searches before it acts (pre-task-retrieval rule), and runs `.verify.sh` before declaring anything done.
