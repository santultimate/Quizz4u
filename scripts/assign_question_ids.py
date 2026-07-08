#!/usr/bin/env python3
"""Assigne un id stable à chaque question (FR source → langues traduites par index)."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"

LANG_SUFFIXES = ("_en", "_ar", "_zh", "_hi", "_es")


def slug_from_filename(name: str) -> str:
    base = name.replace(".json", "")
    for suffix in LANG_SUFFIXES:
        if base.endswith(suffix):
            base = base[: -len(suffix)]
    base = base.replace("_questions_expansion", "")
    base = base.replace("_questions", "")
    base = base.replace("enriched_", "")
    return re.sub(r"[^a-z0-9]+", "_", base.lower()).strip("_")


def iter_question_lists(data):
    if isinstance(data, list):
        yield data
        return
    if isinstance(data, dict):
        for value in data.values():
            if isinstance(value, list):
                yield value
            elif isinstance(value, dict):
                for nested in value.values():
                    if isinstance(nested, list):
                        yield nested


def assign_ids_to_file(path: Path, ids: list[str] | None = None) -> list[str]:
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)

    lists = list(iter_question_lists(data))
    if not lists:
        return []

    flat_count = sum(len(items) for items in lists)

    if ids is None:
        slug = slug_from_filename(path.name)
        ids = [f"{slug}_{index:04d}" for index in range(flat_count)]
    elif len(ids) != flat_count:
        print(
            f"[warn] {path.name}: {flat_count} questions vs {len(ids)} ids FR — ids auto-générés"
        )
        slug = slug_from_filename(path.name)
        ids = [f"{slug}_{index:04d}" for index in range(flat_count)]

    cursor = 0
    for items in lists:
        for item in items:
            if isinstance(item, dict):
                item["id"] = ids[cursor]
            cursor += 1

    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
        handle.write("\n")

    return ids


def main() -> None:
    french_files = sorted(
        p
        for p in QUESTIONS_DIR.glob("*.json")
        if not any(p.name.endswith(f"{suffix}.json") for suffix in LANG_SUFFIXES)
    )

    for fr_path in french_files:
        ids = assign_ids_to_file(fr_path)
        print(f"[fr] {fr_path.name}: {len(ids)} ids")

        stem = fr_path.stem
        for suffix in LANG_SUFFIXES:
            translated = QUESTIONS_DIR / f"{stem}{suffix}.json"
            if translated.exists():
                assign_ids_to_file(translated, ids)
                print(f"  └─ {translated.name}")


if __name__ == "__main__":
    main()
