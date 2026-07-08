#!/usr/bin/env python3
"""Fusionne les traductions UI du Dart legacy vers assets/translations/*.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DART_FILE = ROOT / "lib/services/translation_service.dart"
LEGACY_DART_FILE = ROOT / "lib/services/translation_service_legacy.dart"
TRANSLATIONS_DIR = ROOT / "assets/translations"
LANGS = ("fr", "en", "ar", "zh", "hi", "es")


def extract_lang_block(text: str, lang: str) -> str | None:
    pattern = rf"'{lang}':\s*\{{"
    match = re.search(pattern, text)
    if not match:
        return None
    start = match.end()
    depth = 1
    i = start
    while i < len(text) and depth:
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        i += 1
    return text[start : i - 1]


def parse_dart_map(block: str) -> dict[str, str]:
    entries: dict[str, str] = {}
    for key, value in re.findall(r"'([^']+)':\s*'((?:\\'|[^'])*)'", block):
        entries[key] = value.replace("\\'", "'")
    return entries


def load_json(lang: str) -> dict[str, str]:
    path = TRANSLATIONS_DIR / f"{lang}.json"
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def save_json(lang: str, data: dict[str, str]) -> None:
    path = TRANSLATIONS_DIR / f"{lang}.json"
    with path.open("w", encoding="utf-8") as handle:
        json.dump(dict(sorted(data.items())), handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def main() -> None:
    source = LEGACY_DART_FILE if LEGACY_DART_FILE.exists() else DART_FILE
    text = source.read_text(encoding="utf-8")
    for lang in LANGS:
        block = extract_lang_block(text, lang)
        if not block:
            print(f"[skip] {lang}: bloc Dart introuvable")
            continue
        dart = parse_dart_map(block)
        merged = {**dart, **load_json(lang)}  # JSON prioritaire sur Dart
        save_json(lang, merged)
        print(f"[ok] {lang}: {len(merged)} clés ({len(dart)} Dart, JSON prioritaire)")


if __name__ == "__main__":
    main()
