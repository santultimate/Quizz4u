#!/usr/bin/env python3
"""Fill missing quiz explanations (FR) and translate to en/ar/es/hi/zh."""

from __future__ import annotations

import json
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
QDIR = ROOT / "assets" / "questions"
FR_SRC = Path("/tmp/fr_explanations.json")
OUT_TRANSLATIONS = Path("/tmp/explanations_all_langs.json")

BASES = [
    "enriched_history_questions",
    "enriched_culture_questions",
    "enriched_science_questions",
    "math_questions",
    "africa_questions",
    "football_questions",
    "music_questions",
]
LANGS = ["en", "ar", "es", "hi", "zh"]
# deep_translator uses zh-CN (not "zh")
TRANSLATOR_TARGETS = {"en": "en", "ar": "ar", "es": "es", "hi": "hi", "zh": "zh-CN"}

# Correct math results that were wrong in the dataset
MATH_FIXES = {
    "math_0036": {
        "correct": "4941",
        "answers": {"4800": False, "4900": False, "4941": True, "5000": False},
        "fr": "13³ + 14³ = 2197 + 2744 = 4941, en additionnant les cubes de 13 et 14.",
    },
    "math_0037": {
        "correct": "7471",
        "answers": {"7400": False, "7471": True, "7500": False, "7600": False},
        "fr": "15³ + 16³ = 3375 + 4096 = 7471, en additionnant les cubes de 15 et 16.",
    },
    "math_0038": {
        "correct": "10745",
        "answers": {"10500": False, "10700": False, "10745": True, "11000": False},
        "fr": "17³ + 18³ = 4913 + 5832 = 10745, en additionnant les cubes de 17 et 18.",
    },
    "math_0039": {
        "correct": "14859",
        "answers": {"14500": False, "14800": False, "14859": True, "15000": False},
        "fr": "19³ + 20³ = 6859 + 8000 = 14859, en additionnant les cubes de 19 et 20.",
    },
}


def walk_questions(data):
    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and "question" in item:
                yield item
            elif isinstance(item, dict):
                yield from walk_questions(item)
    elif isinstance(data, dict):
        for value in data.values():
            yield from walk_questions(value)


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def translate_batch(texts: list[str], dest: str) -> list[str]:
    """Translate texts one-by-one with retries (stable for accents / quotes)."""
    translator = GoogleTranslator(source="fr", target=dest)
    out: list[str] = []
    for i, text in enumerate(texts):
        for attempt in range(4):
            try:
                translated = translator.translate(text)
                out.append(translated if translated else text)
                break
            except Exception as exc:  # noqa: BLE001
                if attempt == 3:
                    print(f"  ⚠️  translate fail [{dest}] #{i}: {exc}")
                    out.append(text)
                else:
                    time.sleep(1.2 * (attempt + 1))
        if (i + 1) % 40 == 0:
            print(f"  … {dest}: {i + 1}/{len(texts)}")
            time.sleep(0.4)
    return out


def apply_math_fix(q: dict, lang: str) -> None:
    qid = q.get("id")
    if qid not in MATH_FIXES:
        return
    fix = MATH_FIXES[qid]
    q["answers"] = dict(fix["answers"])
    if "correctAnswer" in q or lang != "fr":
        # keep field if already present or always set for consistency in localized files
        q["correctAnswer"] = fix["correct"]
    # explanation set by caller


def main() -> None:
    fr_map: dict[str, str] = load_json(FR_SRC)
    for qid, fix in MATH_FIXES.items():
        fr_map[qid] = fix["fr"]

    print(f"📚 FR explanations: {len(fr_map)}")

    # 1) Apply FR + math fixes
    for base in BASES:
        path = QDIR / f"{base}.json"
        data = load_json(path)
        updated = 0
        for q in walk_questions(data):
            qid = q.get("id")
            if qid in MATH_FIXES:
                apply_math_fix(q, "fr")
            if qid in fr_map and not str(q.get("explanation") or "").strip():
                q["explanation"] = fr_map[qid]
                updated += 1
            elif qid in MATH_FIXES:
                q["explanation"] = fr_map[qid]
        save_json(path, data)
        print(f"  ✅ FR {base}: +{updated} explanations")

    # 2) Translate (or reuse cache)
    if OUT_TRANSLATIONS.exists():
        all_langs = load_json(OUT_TRANSLATIONS)
        print(f"♻️  Reusing cached translations: {OUT_TRANSLATIONS}")
    else:
        ids = sorted(fr_map.keys())
        fr_texts = [fr_map[i] for i in ids]
        all_langs = {"fr": fr_map}
        for lang in LANGS:
            target = TRANSLATOR_TARGETS[lang]
            print(f"🌍 Translating → {lang} ({target}, {len(fr_texts)} texts)…")
            translated = translate_batch(fr_texts, target)
            all_langs[lang] = {qid: translated[i] for i, qid in enumerate(ids)}
            # persist progress after each language
            save_json(OUT_TRANSLATIONS, all_langs)
            print(f"  ✅ {lang} done")
            time.sleep(0.8)

    # 3) Apply to localized files
    for base in BASES:
        for lang in LANGS:
            path = QDIR / f"{base}_{lang}.json"
            if not path.exists():
                print(f"  ⚠️  missing {path.name}")
                continue
            data = load_json(path)
            updated = 0
            lang_map = all_langs.get(lang, {})
            for q in walk_questions(data):
                qid = q.get("id")
                if qid in MATH_FIXES:
                    apply_math_fix(q, lang)
                if qid in lang_map and not str(q.get("explanation") or "").strip():
                    q["explanation"] = lang_map[qid]
                    updated += 1
                elif qid in MATH_FIXES and qid in lang_map:
                    q["explanation"] = lang_map[qid]
            save_json(path, data)
            print(f"  ✅ {lang} {base}: +{updated}")

    # 4) Verify
    print("\n📊 Verification:")
    for lang in ["fr", *LANGS]:
        miss = total = 0
        for base in BASES + [
            "arts_culture_questions_expansion",
            "politics_economy_questions_expansion",
            "technology_questions_expansion",
            "health_medicine_questions_expansion",
            "environment_questions_expansion",
        ]:
            name = f"{base}.json" if lang == "fr" else f"{base}_{lang}.json"
            p = QDIR / name
            if not p.exists():
                continue
            for q in walk_questions(load_json(p)):
                total += 1
                if not str(q.get("explanation") or "").strip():
                    miss += 1
        print(f"  {lang}: {miss}/{total} sans explication")


if __name__ == "__main__":
    main()
