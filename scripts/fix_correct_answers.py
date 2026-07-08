#!/usr/bin/env python3
"""Aligne correctAnswer sur la clé vraie dans answers/options."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"
LANG_SUFFIXES = ("_en", "_ar", "_zh", "_hi", "_es")


def fix_question(question: dict) -> bool:
    changed = False

    answers = question.get("answers")
    if isinstance(answers, dict) and answers:
        true_keys = [key for key, value in answers.items() if value is True]
        if len(true_keys) == 1 and question.get("correctAnswer") != true_keys[0]:
            question["correctAnswer"] = true_keys[0]
            changed = True

    options = question.get("options")
    correct = question.get("correctAnswer")
    if isinstance(options, list) and correct and correct not in options:
        # Si correctAnswer est encore en FR, retrouver via l'index FR impossible ici;
        # on garde la valeur si une seule option plausible.
        pass

    return changed


def walk(node) -> int:
    changed = 0
    if isinstance(node, list):
        for item in node:
            changed += walk(item)
        return changed
    if isinstance(node, dict):
        if "question" in node:
            return 1 if fix_question(node) else 0
        for value in node.values():
            changed += walk(value)
    return changed


def main() -> None:
    total = 0
    for path in sorted(QUESTIONS_DIR.glob("*.json")):
        if not any(path.name.endswith(suffix + ".json") for suffix in LANG_SUFFIXES):
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        fixed = walk(data)
        if fixed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            print(f"[fix] {path.name}: {fixed} questions")
            total += fixed

    print(f"[done] {total} correctAnswer corrigés")


if __name__ == "__main__":
    main()
