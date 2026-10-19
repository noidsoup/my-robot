---
description: Project wiki — read wiki/SCHEMA.md before any wiki operation
paths:
  - "wiki/**"
---

# LLM Wiki

This project's wiki (also an Obsidian vault) is **`wiki/`**. It was `my-robot wiki/` until 2026-10-19. The payload in `template/` still installs `<repo> wiki/` in other repos — that is a separate thing.

Before creating, updating, or querying wiki pages, read `wiki/SCHEMA.md` for conventions.

The vault uses `[[wikilinks]]` for internal links. Every page has YAML frontmatter.

When the user says "ingest", "add to wiki", "lint wiki", or "query wiki", follow the workflows in SCHEMA.md. Lint: `python3 scripts/wiki-lint.py` and `python3 ~/.claude/skills/closeout/wiki-template/wiki_lint.py .`

After significant work sessions, suggest filing key decisions and learnings into the wiki (ADRs in `decisions/`, runbooks in `guides/`).
