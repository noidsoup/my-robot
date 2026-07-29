---
title: Wiki Log
type: log
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
---

# Wiki Log

> Chronological record of wiki operations. Append-only.
>
> Format: `## [YYYY-MM-DD] verb | Subject`
>
> Verbs: `ingest`, `query`, `lint`, `update`, `create`, `migrate`, `session`
>
> Parseable: `grep "^## \[" log.md | tail -10`

## [<YYYY-MM-DD>] create | Wiki bootstrapped

Initial vault created by my-robot bootstrap (SCHEMA, index, log, folder layout, Obsidian settings). Ready for ingest from `docs/` or new sources.
