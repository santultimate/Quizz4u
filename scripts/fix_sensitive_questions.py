#!/usr/bin/env python3
"""Corrige ou remplace les questions potentiellement sensibles/stigmatisantes."""

from __future__ import annotations

import copy
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"

# Remplacements par id (contenu FR de référence)
REPLACEMENTS: dict[str, dict] = {
    "culture_0010": {
        "question": "Quelle mer sépare l'Afrique de la péninsule arabique ?",
        "answers": {
            "La mer Rouge": True,
            "La mer Méditerranée": False,
            "La mer Caspienne": False,
            "La mer Baltique": False,
        },
        "correctAnswer": "La mer Rouge",
        "explanation": "La mer Rouge relie l'océan Indien au canal de Suez.",
    },
    "culture_0016": {
        "question": "Quel pays européen est célèbre pour la paella et le flamenco ?",
        "answers": {
            "L'Espagne": True,
            "Le Portugal": False,
            "L'Italie": False,
            "La France": False,
        },
        "correctAnswer": "L'Espagne",
        "explanation": "L'Espagne est reconnue pour sa riche culture, dont la paella et le flamenco.",
    },
    "arts_culture_0010": {
        "question": "Quel film de Abderrahmane Sissako a été nommé aux Oscars en 2015 ?",
        "options": ["Timbuktu", "Black Panther", "Tsotsi", "La vie est belle"],
        "correctAnswer": "Timbuktu",
        "explanation": "« Timbuktu » de Abderrahmane Sissako a été nommé à l'Oscar du meilleur film étranger.",
    },
    "politics_economy_0017": {
        "question": "Combien d'Objectifs de développement durable (ODD) l'ONU a-t-elle fixés pour 2030 ?",
        "options": ["17 objectifs", "10 objectifs", "5 objectifs", "50 objectifs"],
        "correctAnswer": "17 objectifs",
        "explanation": "Les 17 ODD couvrent l'éducation, la santé, le climat et la réduction des inégalités.",
    },
    "politics_economy_0021": {
        "question": "Combien de pays membres compte l'UEMOA (zone franc CFA ouest-africain) ?",
        "options": ["8 pays", "15 pays", "27 pays", "54 pays"],
        "correctAnswer": "8 pays",
        "explanation": "L'UEMOA regroupe 8 pays d'Afrique de l'Ouest partageant la monnaie CFA.",
    },
    "politics_economy_0022": {
        "question": "En quelle année la CEDEAO a-t-elle été fondée ?",
        "options": ["1975", "1960", "2002", "1990"],
        "correctAnswer": "1975",
        "explanation": "La CEDEAO (Communauté économique des États de l'Afrique de l'Ouest) a été créée en 1975.",
    },
}

EXPLANATION_FIXES: dict[str, str] = {
    "politics_economy_0001": (
        "Nelson Mandela est devenu le premier président démocratiquement élu "
        "d'Afrique du Sud en 1994, après 27 ans de prison."
    ),
}


def iter_question_nodes(data):
    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and item.get("id"):
                yield item
    elif isinstance(data, dict):
        for value in data.values():
            yield from iter_question_nodes(value)


def apply_patch(question: dict, patch: dict) -> None:
    q = copy.deepcopy(patch)
    for key, value in q.items():
        question[key] = value


def process_file(path: Path) -> int:
    if not path.exists():
        return 0
    data = json.loads(path.read_text(encoding="utf-8"))
    changed = 0
    for question in iter_question_nodes(data):
        qid = question.get("id")
        if qid in REPLACEMENTS:
            apply_patch(question, REPLACEMENTS[qid])
            changed += 1
        if qid in EXPLANATION_FIXES:
            question["explanation"] = EXPLANATION_FIXES[qid]
            changed += 1
    if changed:
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return changed


def main() -> None:
    total = 0
    fr_files = [
        QUESTIONS_DIR / "enriched_culture_questions.json",
        QUESTIONS_DIR / "arts_culture_questions_expansion.json",
        QUESTIONS_DIR / "politics_economy_questions_expansion.json",
    ]
    for path in fr_files:
        n = process_file(path)
        if n:
            print(f"[fix] {path.name}: {n} mise(s) à jour")
            total += n
    print(f"[done] {total} corrections FR appliquées")


if __name__ == "__main__":
    main()
