#!/usr/bin/env python3
"""wiki-lint.py — structural health checks for my-robot Obsidian vaults.

Finds vaults named \"<something> wiki/\" at the repo root (never bare wiki/).
Checks: broken [[wikilinks]], orphan pages, thin/empty bodies, index drift,
missing SCHEMA/index/log, filename kebab-case for content pages.

Stdlib only. Exit 0 if clean, 1 if issues.

Usage:
  python3 scripts/wiki-lint.py
  python3 scripts/wiki-lint.py --json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
WIKILINK_RE = re.compile(r"\[\[([^\[\]\n|#]+?)(?:#[^\[\]\n|]+)?(?:\|[^\[\]\n]+)?\]\]")
FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
KEBAB_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*\.md$")
META_NAMES = {"SCHEMA.md", "index.md", "log.md", "overview.md", "WIKI.md"}
CONTENT_DIRS = (
    "sources",
    "entities",
    "concepts",
    "decisions",
    "guides",
    "memories",
    "synthesis",
)


@dataclass
class Issue:
    kind: str
    path: str
    message: str


@dataclass
class Report:
    issues: list[Issue] = field(default_factory=list)

    def add(self, kind: str, path: Path, message: str) -> None:
        try:
            rel = str(path.relative_to(REPO_ROOT))
        except ValueError:
            rel = str(path)
        self.issues.append(Issue(kind, rel, message))


def find_vaults(root: Path) -> list[Path]:
    vaults: list[Path] = []
    for child in sorted(root.iterdir()):
        if child.is_dir() and child.name.endswith(" wiki"):
            vaults.append(child)
    return vaults


def page_stem(path: Path) -> str:
    return path.stem


def collect_pages(vault: Path) -> list[Path]:
    pages: list[Path] = []
    for p in vault.rglob("*.md"):
        if ".obsidian" in p.parts:
            continue
        pages.append(p)
    return pages


def body_after_frontmatter(text: str) -> str:
    m = FRONTMATTER_RE.match(text)
    if m:
        return text[m.end() :].strip()
    return text.strip()


def lint_vault(vault: Path, report: Report) -> None:
    for required in ("SCHEMA.md", "index.md", "log.md"):
        p = vault / required
        if not p.is_file() or p.stat().st_size == 0:
            report.add("missing-core", p, f"required vault file missing or empty: {required}")

    pages = collect_pages(vault)
    stems = {page_stem(p): p for p in pages}
    inbound: dict[str, int] = {s: 0 for s in stems}

    index_text = ""
    index_path = vault / "index.md"
    if index_path.is_file():
        index_text = index_path.read_text(encoding="utf-8", errors="replace")

    for path in pages:
        text = path.read_text(encoding="utf-8", errors="replace")
        rel_name = path.name
        if path.parent.name in CONTENT_DIRS and rel_name not in META_NAMES:
            if not KEBAB_RE.match(rel_name):
                report.add("filename", path, "prefer kebab-case.md for content pages")

        body = body_after_frontmatter(text)
        if path.name not in ("log.md",) and len(body) < 40:
            report.add("thin", path, "page body is very thin (<40 chars after frontmatter)")

        for m in WIKILINK_RE.finditer(text):
            target = m.group(1).strip()
            # ignore absolute-ish / external
            if "/" in target or target.startswith("http"):
                continue
            # SCHEMA.md is the convention doc — example [[placeholders]] are not real links
            if path.name == "SCHEMA.md":
                continue
            # allow common meta targets
            if target in ("SCHEMA", "index", "log", "overview"):
                continue
            if target in stems:
                inbound[target] = inbound.get(target, 0) + 1
            elif any(s.lower() == target.lower() for s in stems):
                for s in stems:
                    if s.lower() == target.lower():
                        inbound[s] = inbound.get(s, 0) + 1
                        break
            else:
                report.add(
                    "dead-link",
                    path,
                    f"wikilink [[{target}]] has no matching page stem in vault",
                )

        # index drift: content pages should appear in index.md
        if (
            path.parent.name in CONTENT_DIRS
            and index_text
            and f"[[{page_stem(path)}]]" not in index_text
            and page_stem(path) not in index_text
        ):
            report.add(
                "index-drift",
                path,
                f"content page not referenced from index.md as [[{page_stem(path)}]]",
            )

    # orphans: content pages with zero inbound (index counts)
    for stem, path in stems.items():
        if path.name in META_NAMES:
            continue
        if path.parent.name not in CONTENT_DIRS:
            continue
        # count index mentions as inbound
        if index_text and f"[[{stem}]]" in index_text:
            continue
        if inbound.get(stem, 0) == 0:
            report.add("orphan", path, "no inbound [[wikilinks]] and not listed in index.md")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", action="store_true", help="emit JSON report")
    ap.add_argument(
        "--root",
        type=Path,
        default=REPO_ROOT,
        help="repo root (default: parent of scripts/)",
    )
    args = ap.parse_args()
    root = args.root.resolve()
    vaults = find_vaults(root)
    report = Report()
    if not vaults:
        report.add("no-vault", root, 'no "<name> wiki/" vault found at repo root')
    for vault in vaults:
        lint_vault(vault, report)

    if args.json:
        print(
            json.dumps(
                {
                    "ok": not report.issues,
                    "vaults": [str(v.relative_to(root)) for v in vaults],
                    "issues": [i.__dict__ for i in report.issues],
                },
                indent=2,
            )
        )
    else:
        print(f"wiki-lint: {len(vaults)} vault(s)")
        if not report.issues:
            print("wiki-lint: PASS")
        else:
            for issue in report.issues:
                print(f"  [{issue.kind}] {issue.path}: {issue.message}")
            print(f"wiki-lint: FAIL ({len(report.issues)} issue(s))")
    return 0 if not report.issues else 1


if __name__ == "__main__":
    sys.exit(main())
