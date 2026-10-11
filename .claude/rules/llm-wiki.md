---
description: LLM Wiki — read my-robot wiki/SCHEMA.md before any wiki operation
paths:
  - "my-robot wiki/**"
---

# LLM Wiki

This project's Obsidian vault is **`my-robot wiki/`** (repository folder name + space + `wiki`).

Before creating, updating, or querying wiki pages, read `my-robot wiki/SCHEMA.md` for conventions.

The vault uses `[[wikilinks]]` for internal links. Every page has YAML frontmatter.

When the user says "ingest", "add to wiki", "lint wiki", or "query wiki", follow the workflows in SCHEMA.md.

After significant work sessions, suggest filing key decisions and learnings into the wiki (ADRs in `decisions/`, runbooks in `guides/`).
