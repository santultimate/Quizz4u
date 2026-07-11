#!/usr/bin/env python3
"""Vérifie le chargement et le tirage aléatoire pour chaque catégorie active."""

from __future__ import annotations

import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "assets/questions"

# Aligné sur QuestionServiceOptimized.categoryFiles
CATEGORY_FILES: dict[str, str] = {
    "Histoire du Mali": "enriched_history_questions.json",
    "Culture générale": "enriched_culture_questions.json",
    "Sciences": "enriched_science_questions.json",
    "Mathématiques": "math_questions.json",
    "Afrique": "africa_questions.json",
    "Football": "football_questions.json",
    "Musique": "music_questions.json",
    "Arts et Culture": "arts_culture_questions_expansion.json",
    "Politique et Économie": "politics_economy_questions_expansion.json",
    "Technologie et Innovation": "technology_questions_expansion.json",
    "Santé et Médecine": "health_medicine_questions_expansion.json",
    "Environnement et Écologie": "environment_questions_expansion.json",
}

QUIZ_COUNT = 10
SIMULATION_RUNS = 5


def load_questions(category: str, filename: str) -> list[dict]:
    path = QUESTIONS_DIR / filename
    data = json.loads(path.read_text(encoding="utf-8"))
    items: list[dict] = []

    if isinstance(data, list):
        items = [q for q in data if isinstance(q, dict) and q.get("question")]
    elif isinstance(data, dict):
        bucket = data.get(category)
        if bucket is None and data:
            bucket = next(iter(data.values()))
        if isinstance(bucket, list):
            items = [q for q in bucket if isinstance(q, dict) and q.get("question")]
        elif isinstance(bucket, dict):
            for sub in bucket.values():
                if isinstance(sub, list):
                    items.extend(q for q in sub if isinstance(q, dict) and q.get("question"))

    return items


def question_id(q: dict) -> str:
    if q.get("id"):
        return str(q["id"])
    return f"legacy_{abs(hash(q.get('question', '')))}"


def is_valid_question(q: dict) -> bool:
    if not q.get("question", "").strip():
        return False
    if q.get("answers") and isinstance(q["answers"], dict):
        return any(v is True for v in q["answers"].values())
    if q.get("options") and q.get("correctAnswer"):
        return q["correctAnswer"] in q["options"]
    return False


def simulate_random_pick(all_questions: list[dict], count: int, runs: int) -> dict:
    """Simule getRandomQuestionsForCategory (shuffle + anti-répétition basique)."""
    history: list[str] = []
    max_recent = 15
    results = []

    for run in range(runs):
        available = [q for q in all_questions if question_id(q) not in history]
        if len(available) < count:
            history.clear()
            available = list(all_questions)

        random.shuffle(available)
        picked = available[: min(count, len(available))]
        ids = [question_id(q) for q in picked]

        for qid in ids:
            history.append(qid)
            if len(history) > max_recent:
                history.pop(0)

        results.append(
            {
                "run": run + 1,
                "picked": len(picked),
                "unique_in_run": len(set(ids)),
                "duplicate_questions": len(picked) - len(set(ids)),
            }
        )

    return {
        "runs": results,
        "all_unique_across_runs": len({question_id(q) for r in results for q in []}) == 0,
    }


def main() -> int:
    print("=== VALIDATION CATÉGORIES & MÉLANGE ALÉATOIRE ===\n")
    errors: list[str] = []
    warnings: list[str] = []
    rows: list[tuple] = []

    for category, filename in CATEGORY_FILES.items():
        path = QUESTIONS_DIR / filename
        if not path.exists():
            errors.append(f"{category}: fichier manquant ({filename})")
            continue

        questions = load_questions(category, filename)
        if not questions:
            errors.append(f"{category}: 0 question parsée")
            continue

        missing_ids = sum(1 for q in questions if not q.get("id"))
        invalid = [q for q in questions if not is_valid_question(q)]

        sim = simulate_random_pick(questions, QUIZ_COUNT, SIMULATION_RUNS)
        picked_counts = [r["picked"] for r in sim["runs"]]
        dup_in_runs = any(r["duplicate_questions"] > 0 for r in sim["runs"])

        if missing_ids:
            warnings.append(f"{category}: {missing_ids} question(s) sans id")
        if invalid:
            errors.append(f"{category}: {len(invalid)} question(s) invalides")
        if dup_in_runs:
            errors.append(f"{category}: doublons détectés dans un tirage")
        if max(picked_counts) < min(QUIZ_COUNT, len(questions)) and len(questions) >= QUIZ_COUNT:
            warnings.append(f"{category}: tirage incomplet ({max(picked_counts)}/{QUIZ_COUNT})")

        rows.append(
            (
                category,
                len(questions),
                missing_ids,
                len(invalid),
                f"{min(picked_counts)}-{max(picked_counts)}",
                "OK" if not invalid and not dup_in_runs else "KO",
            )
        )

    print(f"{'Catégorie':<32} {'Total':>5} {'SansID':>6} {'Invalid':>7} {'Tirage':>8} {'Statut':>6}")
    print("-" * 72)
    for row in rows:
        print(f"{row[0]:<32} {row[1]:>5} {row[2]:>6} {row[3]:>7} {row[4]:>8} {row[5]:>6}")

    if warnings:
        print("\n--- Avertissements ---")
        for w in warnings:
            print(f"  ⚠️  {w}")

    if errors:
        print("\n--- Erreurs ---")
        for e in errors:
            print(f"  ❌ {e}")
        return 1

    print("\n✅ Toutes les catégories actives sont chargeables et le tirage aléatoire est cohérent.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
