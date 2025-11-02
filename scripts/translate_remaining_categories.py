#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour traduire les 7 catégories restantes en 5 langues
Génère des fichiers JSON traduits de haute qualité

Catégories à traduire:
1. enriched_history_questions.json → Histoire du Mali
2. enriched_culture_questions.json → Culture générale
3. enriched_science_questions.json → Sciences
4. math_questions.json → Mathématiques
5. africa_questions.json → Afrique
6. football_questions.json → Football
7. music_questions.json → Musique

Langues cibles: ar, en, es, hi, zh

Installation requise:
    pip install googletrans==4.0.0rc1 tqdm
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any
import sys
import time

try:
    from googletrans import Translator
    TRANSLATOR_AVAILABLE = True
except ImportError:
    TRANSLATOR_AVAILABLE = False
    print("⚠️  googletrans non installé. Utilisation du mode fallback.")
    print("   Pour des traductions complètes, installez: pip install googletrans==4.0.0rc1\n")

try:
    from tqdm import tqdm
    TQDM_AVAILABLE = True
except ImportError:
    TQDM_AVAILABLE = False
    # Fallback simple sans barre de progression
    def tqdm(iterable, **kwargs):
        return iterable

# Dictionnaire de traduction pour les termes courants
TRANSLATIONS = {
    # Catégories principales
    "Histoire du Mali": {
        "en": "History of Mali",
        "ar": "تاريخ مالي",
        "es": "Historia de Malí",
        "hi": "माली का इतिहास",
        "zh": "马里历史"
    },
    "Culture générale": {
        "en": "General Culture",
        "ar": "الثقافة العامة",
        "es": "Cultura General",
        "hi": "सामान्य संस्कृति",
        "zh": "通识文化"
    },
    "Sciences": {
        "en": "Science",
        "ar": "العلوم",
        "es": "Ciencias",
        "hi": "विज्ञान",
        "zh": "科学"
    },
    "Mathématiques": {
        "en": "Mathematics",
        "ar": "الرياضيات",
        "es": "Matemáticas",
        "hi": "गणित",
        "zh": "数学"
    },
    "Afrique": {
        "en": "Africa",
        "ar": "أفريقيا",
        "es": "África",
        "hi": "अफ्रीका",
        "zh": "非洲"
    },
    "Football": {
        "en": "Football",
        "ar": "كرة القدم",
        "es": "Fútbol",
        "hi": "फुटबॉल",
        "zh": "足球"
    },
    "Musique": {
        "en": "Music",
        "ar": "الموسيقى",
        "es": "Música",
        "hi": "संगीत",
        "zh": "音乐"
    },
    # Difficultés
    "easy": {
        "en": "easy",
        "ar": "سهل",
        "es": "fácil",
        "hi": "आसान",
        "zh": "简单"
    },
    "medium": {
        "en": "medium",
        "ar": "متوسط",
        "es": "medio",
        "hi": "मध्यम",
        "zh": "中等"
    },
    "hard": {
        "en": "hard",
        "ar": "صعب",
        "es": "difícil",
        "hi": "कठिन",
        "zh": "困难"
    },
}

# Mots-clés de base pour traduction
COMMON_WORDS = {
    "Quel": {"en": "What", "ar": "ما", "es": "¿Cuál", "hi": "क्या", "zh": "什么"},
    "Qui": {"en": "Who", "ar": "من", "es": "¿Quién", "hi": "कौन", "zh": "谁"},
    "Quand": {"en": "When", "ar": "متى", "es": "¿Cuándo", "hi": "कब", "zh": "什么时候"},
    "Où": {"en": "Where", "ar": "أين", "es": "¿Dónde", "hi": "कहाँ", "zh": "在哪里"},
    "Pourquoi": {"en": "Why", "ar": "لماذا", "es": "¿Por qué", "hi": "क्यों", "zh": "为什么"},
    "Comment": {"en": "How", "ar": "كيف", "es": "¿Cómo", "hi": "कैसे", "zh": "如何"},
    "Combien": {"en": "How many", "ar": "كم", "es": "¿Cuántos", "hi": "कितने", "zh": "多少"},
}


def translate_text(text: str, target_lang: str, translator=None, context: str = "") -> str:
    """
    Traduit un texte en utilisant Google Translate
    
    Args:
        text: Texte à traduire
        target_lang: Code langue cible (ar, en, es, hi, zh)
        translator: Instance du traducteur Google
        context: Contexte pour aide (non utilisé pour l'instant)
    
    Returns:
        Texte traduit
    """
    # Si c'est vide ou None
    if not text or text.strip() == "":
        return text
    
    # Si c'est un nombre ou une valeur numérique simple, on le garde tel quel
    text_stripped = text.strip().replace('.', '').replace(',', '').replace('-', '').replace('+', '')
    if text_stripped.isdigit():
        return text
    
    # Chercher dans le dictionnaire de traductions prédéfinies
    if text in TRANSLATIONS and target_lang in TRANSLATIONS[text]:
        return TRANSLATIONS[text][target_lang]
    
    # Pour les difficultés
    text_lower = text.lower()
    if text_lower in TRANSLATIONS and target_lang in TRANSLATIONS[text_lower]:
        return TRANSLATIONS[text_lower][target_lang]
    
    # Utiliser Google Translate si disponible
    if TRANSLATOR_AVAILABLE and translator:
        try:
            # Délai pour éviter rate limiting
            time.sleep(0.1)
            
            result = translator.translate(text, src='fr', dest=target_lang)
            return result.text
        except Exception as e:
            print(f"      ⚠️  Erreur traduction '{text[:30]}...': {e}")
            return text
    
    # Fallback: garder le texte original
    return text


def translate_question_dict(question: Dict[str, Any], target_lang: str, translator, category: str, pbar=None) -> Dict[str, Any]:
    """Traduit un dictionnaire de question dans la langue cible"""
    translated = {}
    
    # Traduire la question
    if "question" in question:
        translated["question"] = translate_text(question["question"], target_lang, translator, "question")
    
    # Traduire les options ou answers
    if "options" in question:
        translated["options"] = [
            translate_text(opt, target_lang, translator, "option") 
            for opt in question["options"]
        ]
    
    if "answers" in question:
        translated["answers"] = {
            translate_text(key, target_lang, translator, "answer"): value
            for key, value in question["answers"].items()
        }
    
    # Traduire correctAnswer
    if "correctAnswer" in question:
        translated["correctAnswer"] = translate_text(
            question["correctAnswer"], target_lang, translator, "correctAnswer"
        )
    
    # Traduire explanation
    if "explanation" in question:
        translated["explanation"] = translate_text(
            question["explanation"], target_lang, translator, "explanation"
        )
    
    # Traduire difficulty
    if "difficulty" in question:
        diff = question["difficulty"].lower()
        if diff in TRANSLATIONS:
            translated["difficulty"] = TRANSLATIONS[diff].get(target_lang, question["difficulty"])
        else:
            translated["difficulty"] = question["difficulty"]
    
    # Traduire category et subcategory
    if "category" in question:
        translated["category"] = translate_text(question["category"], target_lang, translator, "category")
    
    if "subcategory" in question:
        translated["subcategory"] = translate_text(
            question["subcategory"], target_lang, translator, "subcategory"
        )
    
    # Mettre à jour la barre de progression
    if pbar:
        pbar.update(1)
    
    return translated


def count_questions(data: Any) -> int:
    """Compte le nombre total de questions dans une structure de données"""
    count = 0
    if isinstance(data, dict):
        for value in data.values():
            if isinstance(value, list):
                count += len(value)
            elif isinstance(value, dict):
                count += count_questions(value)
    elif isinstance(data, list):
        count += len(data)
    return count


def process_file(input_file: Path, output_base_name: str, languages: List[str], translator):
    """Traite un fichier source et génère les traductions"""
    print(f"\n📄 {input_file.name}")
    
    if not input_file.exists():
        print(f"   ⚠️  Fichier non trouvé, ignoré")
        return 0
    
    files_generated = 0
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Compter le total de questions
        total_questions = count_questions(data)
        
        # Déterminer la structure du JSON
        if isinstance(data, dict):
            # Format avec catégories
            for lang in languages:
                print(f"   🌍 {lang.upper()} - {total_questions} questions")
                translated_data = {}
                
                # Créer une barre de progression pour cette langue
                with tqdm(total=total_questions, 
                         desc=f"      Traduction",
                         unit="q",
                         bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]',
                         leave=False) as pbar:
                    
                    for category_key, questions in data.items():
                        # Traduire le nom de catégorie
                        translated_category = translate_text(category_key, lang, translator, "category_name")
                        
                        if isinstance(questions, list):
                            # Liste simple de questions
                            translated_data[translated_category] = [
                                translate_question_dict(q, lang, translator, category_key, pbar)
                                for q in questions
                            ]
                        elif isinstance(questions, dict):
                            # Sous-catégories
                            translated_data[translated_category] = {}
                            for subcat_key, subcat_questions in questions.items():
                                translated_subcat = translate_text(subcat_key, lang, translator, "subcategory_name")
                                translated_data[translated_category][translated_subcat] = [
                                    translate_question_dict(q, lang, translator, category_key, pbar)
                                    for q in subcat_questions
                                ]
                
                # Écrire le fichier traduit
                output_file = input_file.parent / f"{output_base_name}_{lang}.json"
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(translated_data, f, ensure_ascii=False, indent=2)
                
                files_generated += 1
                file_size_kb = output_file.stat().st_size / 1024
                print(f"   ✅ {output_file.name} ({file_size_kb:.1f} KB)")
        
        elif isinstance(data, list):
            # Format liste simple
            for lang in languages:
                print(f"   🌍 {lang.upper()} - {len(data)} questions")
                
                # Créer une barre de progression
                with tqdm(total=len(data), 
                         desc=f"      Traduction",
                         unit="q",
                         bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]',
                         leave=False) as pbar:
                    
                    translated_data = [
                        translate_question_dict(q, lang, translator, "", pbar)
                        for q in data
                    ]
                
                output_file = input_file.parent / f"{output_base_name}_{lang}.json"
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(translated_data, f, ensure_ascii=False, indent=2)
                
                files_generated += 1
                file_size_kb = output_file.stat().st_size / 1024
                print(f"   ✅ {output_file.name} ({file_size_kb:.1f} KB)")
    
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
    
    return files_generated


def main():
    """Fonction principale"""
    print("🚀 GÉNÉRATION DES TRADUCTIONS")
    print("=" * 70)
    
    # Initialiser le traducteur
    translator = None
    if TRANSLATOR_AVAILABLE:
        translator = Translator()
        print("✅ Traducteur Google initialisé")
    else:
        print("⚠️  Mode fallback: traductions limitées")
    
    if not TQDM_AVAILABLE:
        print("⚠️  tqdm non installé - pas de barre de progression")
        print("   Installez avec: pip install tqdm")
    
    print("=" * 70)
    
    # Chemin de base
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    # Langues cibles
    languages = ["ar", "en", "es", "hi", "zh"]
    
    # Fichiers à traiter
    files_to_process = [
        ("enriched_history_questions.json", "enriched_history_questions"),
        ("enriched_culture_questions.json", "enriched_culture_questions"),
        ("enriched_science_questions.json", "enriched_science_questions"),
        ("math_questions.json", "math_questions"),
        ("africa_questions.json", "africa_questions"),
        ("football_questions.json", "football_questions"),
        ("music_questions.json", "music_questions"),
    ]
    
    total_files_generated = 0
    start_time = time.time()
    
    # Barre de progression globale pour les fichiers
    print(f"\n🔄 Traitement de {len(files_to_process)} catégories en {len(languages)} langues")
    print()
    
    for idx, (input_name, output_base) in enumerate(files_to_process, 1):
        print(f"[{idx}/{len(files_to_process)}]", end=" ")
        input_file = base_path / input_name
        files_count = process_file(input_file, output_base, languages, translator)
        total_files_generated += files_count
    
    elapsed_time = time.time() - start_time
    
    print("\n" + "=" * 70)
    print(f"✅ TRADUCTION TERMINÉE en {elapsed_time:.1f}s")
    print(f"📊 {total_files_generated} fichiers générés")
    print(f"   • {len(files_to_process)} catégories")
    print(f"   • {len(languages)} langues (ar, en, es, hi, zh)")
    
    if TRANSLATOR_AVAILABLE:
        print("\n✨ Traductions générées via Google Translate")
    
    print("\n📁 Emplacement: assets/questions/")
    print("\n📋 PROCHAINES ÉTAPES:")
    print("   1. Vérifier les fichiers générés")
    print("   2. Mettre à jour pubspec.yaml")
    print("   3. Mettre à jour QuestionServiceOptimized")
    print("   4. Tester avec flutter run")


if __name__ == "__main__":
    main()

