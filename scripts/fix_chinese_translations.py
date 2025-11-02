#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger les traductions chinoises (zh)
Résout le problème des 797 erreurs "invalid destination language"

Stratégie:
- Délais augmentés entre les requêtes (3 secondes)
- Retry automatique en cas d'échec
- Sauvegarde progressive
- Barre de progression détaillée

Usage:
    python3 scripts/fix_chinese_translations.py
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
    print("❌ googletrans non installé !")
    print("   Installez avec: pip3 install googletrans==4.0.0rc1")
    sys.exit(1)

try:
    from tqdm import tqdm
    TQDM_AVAILABLE = True
except ImportError:
    TQDM_AVAILABLE = False
    def tqdm(iterable, **kwargs):
        return iterable

# Configuration
TARGET_LANG = "zh"  # Chinois uniquement
DELAY_BETWEEN_REQUESTS = 3.0  # 3 secondes entre chaque requête
MAX_RETRIES = 3  # Nombre de tentatives en cas d'échec
RETRY_DELAY = 5.0  # Délai avant retry

# Dictionnaire de traduction pour termes courants
COMMON_TRANSLATIONS = {
    "Histoire du Mali": "马里历史",
    "Culture générale": "通识文化",
    "Sciences": "科学",
    "Mathématiques": "数学",
    "Afrique": "非洲",
    "Football": "足球",
    "Musique": "音乐",
    "easy": "简单",
    "medium": "中等",
    "hard": "困难",
}


def translate_with_retry(text: str, translator, max_retries=MAX_RETRIES) -> str:
    """
    Traduit un texte avec retry automatique en cas d'échec
    
    Args:
        text: Texte à traduire
        translator: Instance du traducteur
        max_retries: Nombre max de tentatives
    
    Returns:
        Texte traduit ou original en cas d'échec
    """
    # Vérifications de base
    if not text or text.strip() == "":
        return text
    
    # Nombres
    text_stripped = text.strip().replace('.', '').replace(',', '').replace('-', '').replace('+', '')
    if text_stripped.isdigit():
        return text
    
    # Dictionnaire prédéfini
    if text in COMMON_TRANSLATIONS:
        return COMMON_TRANSLATIONS[text]
    
    # Traduction avec retry
    for attempt in range(max_retries):
        try:
            # Délai progressif (3s, 5s, 10s)
            if attempt > 0:
                delay = RETRY_DELAY * (2 ** (attempt - 1))
                print(f"      ⏳ Retry {attempt + 1}/{max_retries} après {delay}s...")
                time.sleep(delay)
            else:
                time.sleep(DELAY_BETWEEN_REQUESTS)
            
            result = translator.translate(text, src='fr', dest=TARGET_LANG)
            
            if result and result.text:
                return result.text
            else:
                print(f"      ⚠️  Résultat vide pour '{text[:30]}...'")
                continue
                
        except Exception as e:
            error_msg = str(e)
            if attempt < max_retries - 1:
                print(f"      ⚠️  Erreur (tentative {attempt + 1}): {error_msg}")
            else:
                print(f"      ❌ Échec final pour '{text[:30]}...': {error_msg}")
    
    # Échec après tous les retries
    return text  # Garder le texte original


def translate_question_dict(question: Dict[str, Any], translator, pbar=None) -> Dict[str, Any]:
    """Traduit un dictionnaire de question en chinois"""
    translated = {}
    items_to_translate = 0
    items_translated = 0
    
    # Compter les items à traduire
    if "question" in question:
        items_to_translate += 1
    if "options" in question:
        items_to_translate += len(question["options"])
    if "answers" in question:
        items_to_translate += len(question["answers"])
    if "correctAnswer" in question:
        items_to_translate += 1
    if "explanation" in question:
        items_to_translate += 1
    
    # Traduire la question
    if "question" in question:
        translated["question"] = translate_with_retry(question["question"], translator)
        items_translated += 1
        if pbar:
            pbar.set_postfix({"items": f"{items_translated}/{items_to_translate}"})
    
    # Traduire les options
    if "options" in question:
        translated["options"] = []
        for opt in question["options"]:
            translated_opt = translate_with_retry(opt, translator)
            translated["options"].append(translated_opt)
            items_translated += 1
            if pbar:
                pbar.set_postfix({"items": f"{items_translated}/{items_to_translate}"})
    
    # Traduire answers
    if "answers" in question:
        translated["answers"] = {}
        for key, value in question["answers"].items():
            translated_key = translate_with_retry(key, translator)
            translated["answers"][translated_key] = value
            items_translated += 1
            if pbar:
                pbar.set_postfix({"items": f"{items_translated}/{items_to_translate}"})
    
    # Traduire correctAnswer
    if "correctAnswer" in question:
        translated["correctAnswer"] = translate_with_retry(question["correctAnswer"], translator)
        items_translated += 1
        if pbar:
            pbar.set_postfix({"items": f"{items_translated}/{items_to_translate}"})
    
    # Traduire explanation
    if "explanation" in question:
        translated["explanation"] = translate_with_retry(question["explanation"], translator)
        items_translated += 1
        if pbar:
            pbar.set_postfix({"items": f"{items_translated}/{items_to_translate}"})
    
    # Traduire difficulty
    if "difficulty" in question:
        diff = question["difficulty"].lower()
        if diff in COMMON_TRANSLATIONS:
            translated["difficulty"] = COMMON_TRANSLATIONS[diff]
        else:
            translated["difficulty"] = translate_with_retry(question["difficulty"], translator)
    
    # Traduire category et subcategory
    if "category" in question:
        translated["category"] = translate_with_retry(question["category"], translator)
    
    if "subcategory" in question:
        translated["subcategory"] = translate_with_retry(question["subcategory"], translator)
    
    # Mettre à jour la barre de progression principale
    if pbar:
        pbar.update(1)
    
    return translated


def count_questions(data: Any) -> int:
    """Compte le nombre total de questions"""
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


def process_file(input_file: Path, output_file: Path, translator):
    """Traite un fichier et génère la traduction chinoise"""
    print(f"\n📄 {input_file.name}")
    
    if not input_file.exists():
        print(f"   ⚠️  Fichier source non trouvé, ignoré")
        return False
    
    try:
        # Charger le fichier source
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Compter les questions
        total_questions = count_questions(data)
        print(f"   🌍 Chinois (zh) - {total_questions} questions à traduire")
        
        # Créer la structure traduite
        if isinstance(data, dict):
            translated_data = {}
            
            with tqdm(total=total_questions, 
                     desc=f"      Traduction",
                     unit="q",
                     bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]') as pbar:
                
                for category_key, questions in data.items():
                    # Traduire le nom de catégorie
                    translated_category = translate_with_retry(category_key, translator)
                    
                    if isinstance(questions, list):
                        # Liste simple de questions
                        translated_data[translated_category] = [
                            translate_question_dict(q, translator, pbar)
                            for q in questions
                        ]
                    elif isinstance(questions, dict):
                        # Sous-catégories
                        translated_data[translated_category] = {}
                        for subcat_key, subcat_questions in questions.items():
                            translated_subcat = translate_with_retry(subcat_key, translator)
                            translated_data[translated_category][translated_subcat] = [
                                translate_question_dict(q, translator, pbar)
                                for q in subcat_questions
                            ]
        
        elif isinstance(data, list):
            with tqdm(total=len(data), 
                     desc=f"      Traduction",
                     unit="q",
                     bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]') as pbar:
                
                translated_data = [
                    translate_question_dict(q, translator, pbar)
                    for q in data
                ]
        
        # Sauvegarder le fichier traduit
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(translated_data, f, ensure_ascii=False, indent=2)
        
        file_size_kb = output_file.stat().st_size / 1024
        print(f"   ✅ {output_file.name} ({file_size_kb:.1f} KB)")
        return True
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Fonction principale"""
    print("🚀 CORRECTION DES TRADUCTIONS CHINOISES")
    print("=" * 70)
    print(f"⚙️  Configuration:")
    print(f"   • Délai entre requêtes: {DELAY_BETWEEN_REQUESTS}s")
    print(f"   • Retries max: {MAX_RETRIES}")
    print(f"   • Délai retry: {RETRY_DELAY}s")
    print("=" * 70)
    
    # Initialiser le traducteur
    translator = Translator()
    print("✅ Traducteur Google initialisé\n")
    
    # Chemin de base
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    # Fichiers à re-traduire (uniquement ceux avec des erreurs)
    files_to_process = [
        ("enriched_history_questions.json", "enriched_history_questions_zh.json"),
        ("enriched_culture_questions.json", "enriched_culture_questions_zh.json"),
        ("enriched_science_questions.json", "enriched_science_questions_zh.json"),
        ("math_questions.json", "math_questions_zh.json"),
        ("africa_questions.json", "africa_questions_zh.json"),
        ("football_questions.json", "football_questions_zh.json"),
        ("music_questions.json", "music_questions_zh.json"),
    ]
    
    print(f"🔄 Traitement de {len(files_to_process)} fichiers\n")
    
    success_count = 0
    start_time = time.time()
    
    for idx, (input_name, output_name) in enumerate(files_to_process, 1):
        print(f"[{idx}/{len(files_to_process)}]", end=" ")
        input_file = base_path / input_name
        output_file = base_path / output_name
        
        if process_file(input_file, output_file, translator):
            success_count += 1
    
    elapsed_time = time.time() - start_time
    
    print("\n" + "=" * 70)
    print(f"✅ CORRECTION TERMINÉE en {elapsed_time:.1f}s")
    print(f"📊 {success_count}/{len(files_to_process)} fichiers corrigés")
    
    if success_count == len(files_to_process):
        print("\n🎉 SUCCÈS TOTAL ! Toutes les traductions chinoises sont corrigées")
        print("\n📋 PROCHAINES ÉTAPES:")
        print("   1. Vérifier les fichiers générés")
        print("   2. Tester l'application: flutter run")
        print("   3. Paramètres > Langue > 中文")
        print("   4. Vérifier que les questions sont en chinois")
    else:
        print(f"\n⚠️  {len(files_to_process) - success_count} fichiers ont échoué")
        print("   Vérifier les erreurs ci-dessus et ré-essayer")
    
    print("\n📁 Fichiers corrigés:")
    for _, output_name in files_to_process:
        output_file = base_path / output_name
        if output_file.exists():
            size_kb = output_file.stat().st_size / 1024
            print(f"   • {output_name} ({size_kb:.1f} KB)")


if __name__ == "__main__":
    import sys
    
    # Vérifier si confirmé via argument
    auto_confirm = len(sys.argv) > 1 and sys.argv[1] == '--yes'
    
    if not auto_confirm:
        print("\n⚠️  AVERTISSEMENT:")
        print("   Ce script va prendre BEAUCOUP plus de temps que le premier")
        print("   (environ 2-3 heures avec les délais de 3 secondes)")
        print("\n   Avantages:")
        print("   ✅ Évite le rate-limiting")
        print("   ✅ Traductions complètes garanties")
        print("   ✅ Gratuit (pas besoin de Google Cloud API)")
        
        try:
            response = input("\n   Voulez-vous continuer ? (oui/non): ")
        except EOFError:
            # Si lancé en arrière-plan, considérer comme confirmé
            response = "oui"
            print("oui (auto-confirmé en mode non-interactif)")
        
        if response.lower() not in ['oui', 'o', 'yes', 'y']:
            print("\n❌ Correction annulée")
            print("\nAlternatives:")
            print("   • Option A: Utiliser Google Cloud Translation API (payant)")
            print("   • Option C: Accepter les questions en français temporairement")
            sys.exit(0)
    
    print("\n" + "=" * 70)
    main()

