#!/usr/bin/env python3
"""Replace duplicate / near-duplicate quiz questions with fresh category-relevant ones."""

from __future__ import annotations

import json
import re
import time
import unicodedata
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
QDIR = ROOT / "assets" / "questions"
LANGS = ["en", "ar", "es", "hi", "zh"]
TRANSLATOR_TARGETS = {"en": "en", "ar": "ar", "es": "es", "hi": "hi", "zh": "zh-CN"}

# id -> replacement fields (FR). Keep existing keys not listed.
# Use answers{} OR options[] matching the original question shape.
REPLACEMENTS: dict[str, dict] = {
    # Culture: was duplicate of science (peau)
    "culture_0009": {
        "question": "Quelle civilisation a construit le Machu Picchu ?",
        "answers": {
            "Les Incas": True,
            "Les Mayas": False,
            "Les Aztèques": False,
            "Les Olmèques": False,
        },
        "explanation": "Machu Picchu, au Pérou, est un site emblématique de la civilisation inca.",
        "difficulty": "medium",
        "subcategory": "Histoire mondiale",
    },
    # Science: was duplicate H2O
    "science_0037": {
        "question": "Quel gaz les plantes absorbent-elles principalement pour la photosynthèse ?",
        "options": [
            "Le dioxyde de carbone (CO₂)",
            "L'oxygène",
            "L'azote",
            "L'hydrogène",
        ],
        "correctAnswer": "Le dioxyde de carbone (CO₂)",
        "explanation": "Lors de la photosynthèse, les plantes absorbent le CO₂ et libèrent de l'oxygène.",
        "difficulty": "easy",
    },
    # Science: was duplicate Mercure
    "science_0032": {
        "question": "Quelle planète est surnommée la planète rouge ?",
        "options": ["Mars", "Vénus", "Jupiter", "Mercure"],
        "correctAnswer": "Mars",
        "explanation": "Mars doit sa couleur rougeâtre à l'oxyde de fer présent à sa surface.",
        "difficulty": "easy",
    },
    # Science: was near-duplicate vitesse de la lumière
    "science_0039": {
        "question": "Quelle est la plus grande planète du système solaire ?",
        "options": ["Jupiter", "Saturne", "Neptune", "Uranus"],
        "correctAnswer": "Jupiter",
        "explanation": "Jupiter est une géante gazeuse, la plus massive et la plus volumineuse du système solaire.",
        "difficulty": "easy",
    },
    # Music: was duplicate jazz Nouvelle-Orléans
    "music_0033": {
        "question": "Quel style musical jamaïcain a été popularisé par Bob Marley ?",
        "options": ["Le reggae", "Le calypso", "La salsa", "Le zouk"],
        "correctAnswer": "Le reggae",
        "explanation": "Bob Marley a fait connaître le reggae jamaïcain dans le monde entier.",
        "difficulty": "easy",
    },
    # Football: was duplicate durée du match
    "football_0033": {
        "question": "Quel carton sanctionne une faute grave ou un second avertissement ?",
        "options": [
            "Le carton rouge",
            "Le carton jaune",
            "Le carton bleu",
            "Le carton vert",
        ],
        "correctAnswer": "Le carton rouge",
        "explanation": "Le carton rouge entraîne l'exclusion du joueur pour le reste du match.",
        "difficulty": "easy",
    },
    # Football: was duplicate La Pulga
    "football_0034": {
        "question": "Dans quel pays s'est déroulée la Coupe du Monde 2014 ?",
        "options": ["Le Brésil", "L'Afrique du Sud", "La Russie", "L'Allemagne"],
        "correctAnswer": "Le Brésil",
        "explanation": "La Coupe du Monde 2014 s'est tenue au Brésil ; l'Allemagne l'a remportée en finale.",
        "difficulty": "medium",
    },
    # History: was duplicate Mansa Moussa célèbre
    "history_0012": {
        "question": "Qui a fondé l'Empire du Mali au XIIIe siècle ?",
        "answers": {
            "Soundiata Keïta": True,
            "Mansa Moussa": False,
            "Sonni Ali": False,
            "Askia Mohammed": False,
        },
        "correctAnswer": "Soundiata Keïta",
        "explanation": "Soundiata Keïta a fondé l'Empire du Mali après sa victoire de Kirina vers 1235.",
    },
    # Africa: superficie Ouest = doublon de "plus grand Ouest"
    "africa_0018": {
        "question": "Quel fleuve d'Afrique de l'Ouest traverse le Mali, le Niger et le Nigeria ?",
        "answers": {
            "Le Niger": True,
            "Le Sénégal": False,
            "La Volta": False,
            "Le Congo": False,
        },
        "correctAnswer": "Le Niger",
        "explanation": "Le fleuve Niger, long d'environ 4 200 km, irrigue une grande partie de l'Afrique de l'Ouest.",
    },
    # Africa: superficie Est (évite doublon lac Victoria)
    "africa_0020": {
        "question": "Quel pays d'Afrique de l'Est a pour capitale Nairobi ?",
        "answers": {
            "Le Kenya": True,
            "La Tanzanie": False,
            "L'Ouganda": False,
            "L'Éthiopie": False,
        },
        "correctAnswer": "Le Kenya",
        "explanation": "Nairobi est la capitale du Kenya et un important centre économique d'Afrique de l'Est.",
    },
    # Africa: superficie Nord
    "africa_0022": {
        "question": "Quel détroit sépare le Maroc de l'Espagne ?",
        "answers": {
            "Le détroit de Gibraltar": True,
            "Le canal de Suez": False,
            "Le détroit de Bab-el-Mandeb": False,
            "Le canal de Mozambique": False,
        },
        "correctAnswer": "Le détroit de Gibraltar",
        "explanation": "Le détroit de Gibraltar relie la Méditerranée à l'Atlantique entre l'Afrique et l'Europe.",
    },
    # Africa: superficie centrale
    "africa_0019": {
        "question": "Quel fleuve d'Afrique centrale est le deuxième plus long d'Afrique ?",
        "answers": {
            "Le Congo": True,
            "Le Nil": False,
            "Le Niger": False,
            "Le Zambèze": False,
        },
        "correctAnswer": "Le Congo",
        "explanation": "Le Congo est le deuxième fleuve d'Afrique par la longueur et le plus puissant par le débit.",
    },
    # Africa: superficie australe
    "africa_0021": {
        "question": "Quel désert côtier s'étend le long de la Namibie et de l'Angola ?",
        "answers": {
            "Le Namib": True,
            "Le Kalahari": False,
            "Le Sahara": False,
            "Le Karoo": False,
        },
        "correctAnswer": "Le Namib",
        "explanation": "Le désert du Namib est l'un des plus anciens déserts du monde, le long de l'Atlantique sud.",
    },
    # Africa: densités (souvent incorrectes / redondantes avec population)
    "africa_0033": {
        "question": "Quel pays d'Afrique de l'Ouest a pour capitale Accra ?",
        "answers": {
            "Le Ghana": True,
            "Le Nigeria": False,
            "Le Togo": False,
            "La Côte d'Ivoire": False,
        },
        "correctAnswer": "Le Ghana",
        "explanation": "Accra est la capitale du Ghana, l'un des pays pionniers de l'indépendance en Afrique de l'Ouest.",
    },
    "africa_0035": {
        "question": "Dans quel pays d'Afrique de l'Est se trouve le parc national du Serengeti ?",
        "answers": {
            "La Tanzanie": True,
            "Le Kenya": False,
            "L'Ouganda": False,
            "L'Éthiopie": False,
        },
        "correctAnswer": "La Tanzanie",
        "explanation": "Le Serengeti, en Tanzanie, est célèbre pour la grande migration des gnous et des zèbres.",
    },
    "africa_0037": {
        "question": "Quelle mer borde l'Égypte au nord ?",
        "answers": {
            "La mer Méditerranée": True,
            "La mer Rouge": False,
            "La mer Noire": False,
            "La mer Caspienne": False,
        },
        "correctAnswer": "La mer Méditerranée",
        "explanation": "L'Égypte est bordée au nord par la Méditerranée et à l'est par la mer Rouge.",
    },
    "africa_0034": {
        "question": "Quelle est la capitale de la République démocratique du Congo ?",
        "answers": {
            "Kinshasa": True,
            "Brazzaville": False,
            "Lubumbashi": False,
            "Kisangani": False,
        },
        "correctAnswer": "Kinshasa",
        "explanation": "Kinshasa est la capitale et la plus grande ville de la RDC, sur le fleuve Congo.",
    },
    "africa_0036": {
        "question": "Quel océan borde l'Afrique du Sud à l'est ?",
        "answers": {
            "L'océan Indien": True,
            "L'océan Atlantique": False,
            "L'océan Pacifique": False,
            "L'océan Arctique": False,
        },
        "correctAnswer": "L'océan Indien",
        "explanation": "L'Afrique du Sud est bordée à l'ouest par l'Atlantique et à l'est par l'océan Indien.",
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
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def apply_fields(q: dict, fields: dict) -> None:
    for key, value in fields.items():
        q[key] = value
    # Keep schema consistent: if options present, drop stale answers map
    if "options" in fields and "answers" in q and "answers" not in fields:
        q.pop("answers", None)
    if "answers" in fields and "options" in q and "options" not in fields:
        q.pop("options", None)
    # Always sync correctAnswer with the True answer key when answers map exists
    answers = q.get("answers")
    if isinstance(answers, dict):
        true_key = next((k for k, v in answers.items() if v is True), None)
        if true_key:
            q["correctAnswer"] = true_key
    elif "options" in fields and "correctAnswer" in fields:
        q["correctAnswer"] = fields["correctAnswer"]


def collect_translatable_strings(fields: dict) -> list[tuple[str, str]]:
    """Return list of (path, text) to translate."""
    out: list[tuple[str, str]] = []
    out.append(("question", fields["question"]))
    out.append(("explanation", fields["explanation"]))
    if "correctAnswer" in fields:
        out.append(("correctAnswer", fields["correctAnswer"]))
    if "options" in fields:
        for i, opt in enumerate(fields["options"]):
            out.append((f"options.{i}", opt))
    if "answers" in fields:
        for i, key in enumerate(fields["answers"].keys()):
            out.append((f"answers.{i}", key))
    if "subcategory" in fields:
        out.append(("subcategory", fields["subcategory"]))
    return out


def rebuild_fields(fields: dict, translated: dict[str, str]) -> dict:
    new = dict(fields)
    new["question"] = translated["question"]
    new["explanation"] = translated["explanation"]
    if "correctAnswer" in fields:
        new["correctAnswer"] = translated["correctAnswer"]
    if "options" in fields:
        new["options"] = [translated[f"options.{i}"] for i in range(len(fields["options"]))]
    if "answers" in fields:
        keys = list(fields["answers"].keys())
        new_answers = {}
        for i, old_key in enumerate(keys):
            new_answers[translated[f"answers.{i}"]] = fields["answers"][old_key]
        new["answers"] = new_answers
        # sync correctAnswer if derived from answers
        if "correctAnswer" in new:
            for k, v in new_answers.items():
                if v is True:
                    new["correctAnswer"] = k
                    break
    if "subcategory" in fields:
        new["subcategory"] = translated["subcategory"]
    return new


def translate_map(texts: dict[str, str], dest: str) -> dict[str, str]:
    translator = GoogleTranslator(source="fr", target=dest)
    out: dict[str, str] = {}
    items = list(texts.items())
    for i, (key, text) in enumerate(items):
        for attempt in range(5):
            try:
                out[key] = translator.translate(text) or text
                break
            except Exception as exc:  # noqa: BLE001
                if attempt == 4:
                    print(f"  ⚠️  {dest} {key}: {exc}")
                    out[key] = text
                else:
                    time.sleep(1.2 * (attempt + 1))
        if (i + 1) % 20 == 0:
            time.sleep(0.3)
    return out


def norm(s: str) -> str:
    s = unicodedata.normalize("NFD", (s or "").lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    # Keep digits and letters; keep superscripts distinction by mapping common ones
    s = s.replace("²", "2").replace("³", "3")
    s = re.sub(r"[^a-z0-9\s]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def main() -> None:
    # 1) Apply FR
    files_touched = set()
    for path in QDIR.glob("*.json"):
        if any(path.name.endswith(f"_{lang}.json") for lang in LANGS):
            continue
        if path.name.startswith("_") or "_archive" in str(path):
            continue
        data = load_json(path)
        changed = 0
        for q in walk_questions(data):
            qid = q.get("id")
            if qid in REPLACEMENTS:
                apply_fields(q, REPLACEMENTS[qid])
                changed += 1
        if changed:
            save_json(path, data)
            files_touched.add(path.name)
            print(f"✅ FR {path.name}: {changed} remplacées")

    # 2) Translate each replacement
    cache_path = Path("/tmp/duplicate_replacements_i18n.json")
    if cache_path.exists():
        i18n = load_json(cache_path)
        print(f"♻️  cache {cache_path}")
    else:
        i18n = {"fr": REPLACEMENTS}
        # Build unique FR string bag per id
        for lang in LANGS:
            print(f"🌍 {lang}…")
            lang_map: dict[str, dict] = {}
            target = TRANSLATOR_TARGETS[lang]
            for qid, fields in REPLACEMENTS.items():
                pairs = collect_translatable_strings(fields)
                fr_map = {k: v for k, v in pairs}
                tr = translate_map(fr_map, target)
                lang_map[qid] = rebuild_fields(fields, tr)
                print(f"  ✓ {qid}")
                time.sleep(0.2)
            i18n[lang] = lang_map
            save_json(cache_path, i18n)
        print(f"💾 {cache_path}")

    # 3) Apply translations
    for lang in LANGS:
        lang_map = i18n[lang]
        for path in QDIR.glob(f"*_{lang}.json"):
            data = load_json(path)
            changed = 0
            for q in walk_questions(data):
                qid = q.get("id")
                if qid in lang_map:
                    apply_fields(q, lang_map[qid])
                    changed += 1
            if changed:
                save_json(path, data)
                print(f"✅ {lang} {path.name}: {changed}")

    # 4) Duplicate check FR
    all_q = []
    for path in QDIR.glob("*.json"):
        if any(path.name.endswith(f"_{lang}.json") for lang in LANGS):
            continue
        if path.name.startswith("_"):
            continue
        for q in walk_questions(load_json(path)):
            all_q.append((path.name, q.get("id"), norm(q.get("question", ""))))
    from collections import defaultdict

    by = defaultdict(list)
    for f, i, n in all_q:
        if n:
            by[n].append((f, i))
    dups = {k: v for k, v in by.items() if len(v) > 1}
    print(f"\n📊 Doublons exacts restants: {len(dups)}")
    for k, v in list(dups.items())[:15]:
        print(" ", v, "->", k[:70])


if __name__ == "__main__":
    main()
