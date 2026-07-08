#!/usr/bin/env python3
"""Validation complète des traductions UI et questions."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRANSLATIONS_DIR = ROOT / "assets/translations"
QUESTIONS_DIR = ROOT / "assets/questions"
UI_LANGS = ("fr", "en", "ar", "zh", "hi", "es")
QUESTION_LANGS = ("en", "ar", "zh", "hi", "es")
LANG_SUFFIXES = tuple(f"_{lang}" for lang in QUESTION_LANGS)

CATEGORY_FILES = (
    "enriched_history_questions.json",
    "enriched_culture_questions.json",
    "enriched_science_questions.json",
    "math_questions.json",
    "africa_questions.json",
    "football_questions.json",
    "music_questions.json",
    "arts_culture_questions_expansion.json",
    "politics_economy_questions_expansion.json",
    "technology_questions_expansion.json",
    "health_medicine_questions_expansion.json",
    "environment_questions_expansion.json",
)


def load_json(path: Path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def iter_questions(data):
    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and "question" in item:
                yield item
        return
    if isinstance(data, dict):
        for value in data.values():
            if isinstance(value, list):
                for item in value:
                    if isinstance(item, dict) and "question" in item:
                        yield item
            elif isinstance(value, dict):
                for nested in value.values():
                    if isinstance(nested, list):
                        for item in nested:
                            if isinstance(item, dict) and "question" in item:
                                yield item


def is_valid_question(question: dict) -> bool:
    if not question.get("question", "").strip():
        return False
    if question.get("answers"):
        return question.get("correctAnswer") in question["answers"]
    if question.get("options") and question.get("correctAnswer"):
        return question["correctAnswer"] in question["options"]
    return False


def validate_ui_translations() -> list[str]:
    errors: list[str] = []
    reference = load_json(TRANSLATIONS_DIR / "fr.json")
    ref_keys = set(reference.keys())

    for lang in UI_LANGS:
        if lang == "fr":
            continue
        path = TRANSLATIONS_DIR / f"{lang}.json"
        keys = set(load_json(path).keys())
        missing = sorted(ref_keys - keys)
        if missing:
            errors.append(f"UI {lang}: {len(missing)} clés manquantes")
    return errors


def validate_questions() -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    stats = {
        "fr_questions": 0,
        "translated_pairs": 0,
        "untranslated_identical": 0,
        "invalid_questions": 0,
    }

    for fr_file in CATEGORY_FILES:
        fr_path = QUESTIONS_DIR / fr_file
        fr_data = load_json(fr_path)
        fr_questions = list(iter_questions(fr_data))
        fr_ids = [question.get("id") for question in fr_questions]
        fr_texts = [question.get("question", "") for question in fr_questions]
        stats["fr_questions"] += len(fr_questions)

        if len(fr_ids) != len(fr_questions) or None in fr_ids:
            errors.append(f"FR {fr_file}: ids manquants")
        if len(set(fr_ids)) != len(fr_ids):
            errors.append(f"FR {fr_file}: ids dupliqués")

        stem = fr_path.stem
        for lang in QUESTION_LANGS:
            translated_path = QUESTIONS_DIR / f"{stem}_{lang}.json"
            if not translated_path.exists():
                errors.append(f"MANQUANT: {translated_path.name}")
                continue

            tr_data = load_json(translated_path)
            if isinstance(tr_data, dict) and len(tr_data.keys()) > 1:
                errors.append(f"DOUBLON CLÉS: {translated_path.name}")

            tr_questions = list(iter_questions(tr_data))
            tr_ids = [question.get("id") for question in tr_questions]
            stats["translated_pairs"] += len(tr_questions)

            if len(tr_questions) != len(fr_questions):
                errors.append(
                    f"PARITÉ {translated_path.name}: {len(tr_questions)} vs FR {len(fr_questions)}"
                )
            if tr_ids != fr_ids:
                errors.append(f"IDS {translated_path.name}: différents du FR")

            for fr_text, question in zip(fr_texts, tr_questions):
                if fr_text == question.get("question", ""):
                    stats["untranslated_identical"] += 1
                    errors.append(
                        f"NON TRADUIT {translated_path.name} [{question.get('id')}]: {fr_text[:50]}"
                    )
                if not is_valid_question(question):
                    stats["invalid_questions"] += 1
                    errors.append(
                        f"INVALIDE {translated_path.name} [{question.get('id')}]"
                    )

    return errors, stats


def main() -> int:
    ui_errors = validate_ui_translations()
    question_errors, stats = validate_questions()
    errors = ui_errors + question_errors

    print("=== STATISTIQUES ===")
    for key, value in stats.items():
        print(f"  {key}: {value}")

    if errors:
        print(f"\n❌ Validation échouée ({len(errors)} problèmes):")
        for error in errors[:40]:
            print(f"  - {error}")
        if len(errors) > 40:
            print(f"  ... +{len(errors) - 40} autres")
        return 1

    print("\n✅ Toutes les traductions UI et questions sont valides")
    return 0


if __name__ == "__main__":
    sys.exit(main())
