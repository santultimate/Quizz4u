#!/usr/bin/env python3
"""Reconstruit les traductions des catégories expansion depuis le FR source."""

from __future__ import annotations

import copy
import json
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"
LANGS = ("en", "ar", "zh", "hi", "es")
LANG_CODES = {"en": "en", "ar": "ar", "zh": "zh-CN", "hi": "hi", "es": "es"}

EXPANSION_FILES = (
    "arts_culture_questions_expansion.json",
    "politics_economy_questions_expansion.json",
    "technology_questions_expansion.json",
    "health_medicine_questions_expansion.json",
    "environment_questions_expansion.json",
)


def collect_strings(node, bucket: set[str]) -> None:
    if isinstance(node, list):
        for item in node:
            collect_strings(item, bucket)
        return
    if isinstance(node, dict):
        if "question" in node:
            bucket.add(node["question"])
            if node.get("explanation"):
                bucket.add(node["explanation"])
            for option in node.get("options", []) or []:
                bucket.add(str(option))
            if node.get("correctAnswer") and "options" not in node:
                bucket.add(str(node["correctAnswer"]))
            for answer in (node.get("answers") or {}).keys():
                bucket.add(str(answer))
        else:
            for value in node.values():
                collect_strings(value, bucket)


def build_cache(texts: set[str]) -> dict[str, dict[str, str]]:
    caches: dict[str, dict[str, str]] = {lang: {} for lang in LANGS}
    total = len(texts) * len(LANGS)
    done = 0

    for lang in LANGS:
        translator = GoogleTranslator(source="fr", target=LANG_CODES[lang])
        for text in sorted(texts, key=len):
            done += 1
            if done % 25 == 0:
                print(f"[cache] {done}/{total}")
            try:
                caches[lang][text] = translator.translate(text)
            except Exception as error:  # noqa: BLE001
                print(f"[warn] {lang}: {text[:40]!r} -> {error}")
                caches[lang][text] = text
            time.sleep(0.02)

    return caches


def apply_translations(node, lang: str, cache: dict[str, str]):
    if isinstance(node, list):
        return [apply_translations(item, lang, cache) for item in node]
    if isinstance(node, dict):
        if "question" in node:
            result = copy.deepcopy(node)
            result["question"] = cache.get(node["question"], node["question"])
            if node.get("explanation"):
                result["explanation"] = cache.get(
                    node["explanation"], node["explanation"]
                )
            if isinstance(node.get("options"), list):
                translated_options = [
                    cache.get(str(option), str(option)) for option in node["options"]
                ]
                result["options"] = translated_options
                correct = node.get("correctAnswer")
                if correct in node["options"]:
                    result["correctAnswer"] = translated_options[
                        node["options"].index(correct)
                    ]
                elif correct:
                    result["correctAnswer"] = cache.get(str(correct), str(correct))
            if isinstance(node.get("answers"), dict):
                translated_answers = {}
                new_correct = node.get("correctAnswer")
                for answer, is_correct in node["answers"].items():
                    translated_answer = cache.get(str(answer), str(answer))
                    translated_answers[translated_answer] = is_correct
                    if is_correct:
                        new_correct = translated_answer
                result["answers"] = translated_answers
                result["correctAnswer"] = new_correct
            return result
        return {key: apply_translations(value, lang, cache) for key, value in node.items()}
    return node


def main() -> None:
    texts: set[str] = set()
    fr_payloads: dict[str, dict] = {}

    for filename in EXPANSION_FILES:
        fr_data = json.loads((QUESTIONS_DIR / filename).read_text(encoding="utf-8"))
        fr_payloads[filename] = fr_data
        collect_strings(fr_data, texts)

    print(f"[info] {len(texts)} textes uniques à traduire")
    caches = build_cache(texts)

    for filename, fr_data in fr_payloads.items():
        stem = Path(filename).stem
        for lang in LANGS:
            translated = apply_translations(fr_data, lang, caches[lang])
            out_path = QUESTIONS_DIR / f"{stem}_{lang}.json"
            out_path.write_text(
                json.dumps(translated, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            print(f"[ok] {out_path.name}")

    print("[done] expansion translations rebuilt")


if __name__ == "__main__":
    main()
