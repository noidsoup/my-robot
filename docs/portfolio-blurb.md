# Portfolio blurbs — my-robot

Copy-paste. No secrets. Pick the length that fits the slot.

## One line (GitHub profile / bio)

I ship a 30-second installer that gives any repo the guardrails I use so coding agents search first, remember between chats, and don’t say “done” without running tests.

## Project card

**my-robot** — Clone my robot. One script installs the AI-first setup I run across a fleet of production repos: an honest verify gate, offline doc search, agent rules, workflow loops, an Obsidian wiki, and memory files. Safe by default — it never overwrites what you already have. Dry-run first, then apply. [github.com/noidsoup/my-robot](https://github.com/noidsoup/my-robot)

## Short case study

Left alone, an AI coding agent invents paths it never checked, forgets everything between sessions, and calls the job done without running a test. Every serious AI-assisted project ends up hand-building the same fixes.

**my-robot** is that work, done once. `bootstrap.sh` detects the stack (Node, Python, Go, Cursor, Claude) and installs only what fits: a verify script that fails loudly if there is no suite, LanceDB search or a sidecar note, always-on agent rules, [loops](https://github.com/noidsoup/loops) workflows, an Obsidian vault at `<repo> wiki/`, and session memory. Re-runs report `existed` and skip. Prefer clone + `--dry-run`; a curl one-liner exists for convenience after you have read the script.

I install this everywhere I work. Want it on yours? [Let’s talk](https://github.com/noidsoup).
