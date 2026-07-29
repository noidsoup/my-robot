# AI Session Memory

Dated log of what the AI did each session. **The AI writes this, not the human.**
Append a new entry at close-out. No secrets, no PII.

Format per entry:

```
## YYYY-MM-DD — <branch or topic>
- **Shipped:** what landed
- **Decisions:** what was chosen and why
- **State:** current status
- **Blocked / next:** concrete next steps
```

---

<!-- newest entries on top -->

## 2026-07-29 — L4 Knowledge Wiki layer + plain-English READMEs

- **Did:** Added L4 (Obsidian knowledge wiki) to the template: `template/wiki/` (SCHEMA.md, index.md, log.md, .obsidian/app.json), vault created at `<repo> wiki/`, `WIKI.md` repo-root pointer, `llm-wiki.mdc` agent rule, LanceDB indexer discovers `* wiki/` folders. Generalized from caper-app's wiki conventions. Rewrote my-robot README in plain English (~65 lines); light pass on loops README (QC section + cross-link to my-robot).
- **Decisions:** Vault lives at `<repo-folder> wiki/` (with a space) to match caper-app convention. Wiki layer is fully idempotent — never overwrites an existing vault. Ship reusable code in loops, template-specific in my-robot/template.
- **State:** Both repos public, pushed, presentation-ready. Template verified idempotent on Node + Python smoke repos.
- **Blocked / next:** Optional — test the curl standalone path, demo GIF, portfolio blurb.
