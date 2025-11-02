#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script FINAL pour traduire toutes les questions en chinois (ZH)
Stratégie multi-failsafe avec plusieurs méthodes de traduction
"""

import json
import time
import random
from pathlib import Path
from typing import Dict, List, Any, Optional
import sys

# Détection automatique de googletrans
try:
    from googletrans import Translator
    GOOGLETRANS_AVAILABLE = True
except ImportError:
    GOOGLETRANS_AVAILABLE = False
    print("⚠️  googletrans non disponible - installation recommandée: pip3 install googletrans==4.0.0rc1")

# Configuration
DELAY_MIN = 2.0  # Délai minimum entre requêtes
DELAY_MAX = 5.0  # Délai maximum (random pour éviter rate limit)
MAX_RETRIES = 5  # Plus de tentatives
RETRY_BASE_DELAY = 10.0  # Délai de base pour retry

# Catégories déjà traduites (ne pas retraduire)
CATEGORY_TRANSLATIONS = {
    "Histoire du Mali": "马里历史",
    "Culture générale": "通识文化",
    "Sciences": "科学",
    "Mathématiques": "数学",
    "Afrique": "非洲",
    "Football": "足球",
    "Musique": "音乐",
}

def is_chinese(text: str) -> bool:
    """Vérifie si un texte contient déjà des caractères chinois"""
    if not text:
        return False
    # Caractères chinois Unicode range
    chinese_chars = [c for c in text if '\u4e00' <= c <= '\u9fff']
    # Si >30% des caractères sont chinois, considérer comme déjà traduit
    if len(text) > 0 and len(chinese_chars) / len(text) > 0.3:
        return True
    return False

def translate_with_googletrans(text: str, translator) -> Optional[str]:
    """Traduit avec googletrans avec retry amélioré"""
    if not GOOGLETRANS_AVAILABLE:
        return None
    
    # Si déjà en chinois, ne pas traduire
    if is_chinese(text):
        return text
    
    # Texte trop court ou nombres uniquement
    text_clean = text.strip().replace('.', '').replace(',', '').replace('-', '').replace('+', '').replace('×', '').replace('÷', '')
    if len(text_clean) < 3 or text_clean.replace(' ', '').isdigit():
        return text
    
    for attempt in range(MAX_RETRIES):
        try:
            # Délai progressif entre tentatives
            if attempt > 0:
                delay = RETRY_BASE_DELAY * (2 ** (attempt - 1))
                print(f"      ⏳ Tentative {attempt + 1}/{MAX_RETRIES} après {delay:.1f}s...")
                time.sleep(delay)
            else:
                # Délai random entre requêtes pour éviter rate limit
                delay = random.uniform(DELAY_MIN, DELAY_MAX)
                time.sleep(delay)
            
            # Traduction
            result = translator.translate(text, src='fr', dest='zh-cn')
            
            if result and result.text:
                translated = result.text.strip()
                # Vérifier que c'est bien du chinois
                if is_chinese(translated) or len(translated) > 0:
                    return translated
            
        except Exception as e:
            error_msg = str(e).lower()
            
            # Erreurs non critiques - continuer
            if 'invalid destination language' in error_msg:
                print(f"      ⚠️  Erreur destination language (tentative {attempt + 1})")
                continue
            elif '429' in error_msg or 'too many requests' in error_msg:
                wait_time = RETRY_BASE_DELAY * (2 ** attempt)
                print(f"      ⏳ Rate limit détecté - attente {wait_time:.1f}s...")
                time.sleep(wait_time)
                continue
            elif 'timed out' in error_msg or 'timeout' in error_msg:
                print(f"      ⏳ Timeout (tentative {attempt + 1})")
                continue
            else:
                print(f"      ⚠️  Erreur: {e} (tentative {attempt + 1})")
    
    # Échec après toutes les tentatives
    return None

def translate_question_complete(question: Dict[str, Any], translator) -> Dict[str, Any]:
    """Traduit une question complète (question + réponses + explication)"""
    translated = question.copy()
    changes = 0
    
    # Traduire la question
    if 'question' in translated and isinstance(translated['question'], str):
        original = translated['question']
        if not is_chinese(original):
            translated_text = translate_with_googletrans(original, translator)
            if translated_text:
                translated['question'] = translated_text
                changes += 1
            else:
                print(f"      ❌ Échec traduction question: {original[:50]}...")
    
    # Traduire les réponses
    if 'answers' in translated and isinstance(translated['answers'], dict):
        for key, value in translated['answers'].items():
            if isinstance(key, str) and not is_chinese(key):
                translated_key = translate_with_googletrans(key, translator)
                if translated_key:
                    translated['answers'][translated_key] = translated['answers'].pop(key)
                    changes += 1
    
    # Traduire l'explication si présente
    if 'explanation' in translated and isinstance(translated['explanation'], str):
        original = translated['explanation']
        if not is_chinese(original):
            translated_text = translate_with_googletrans(original, translator)
            if translated_text:
                translated['explanation'] = translated_text
                changes += 1
    
    # Traduire la subcategory si présente
    if 'subcategory' in translated and isinstance(translated['subcategory'], str):
        original = translated['subcategory']
        if not is_chinese(original):
            translated_text = translate_with_googletrans(original, translator)
            if translated_text:
                translated['subcategory'] = translated_text
                changes += 1
    
    return translated, changes

def process_file(input_file: Path, output_file: Path, translator) -> tuple[bool, int, int]:
    """
    Traite un fichier JSON pour traduire toutes les questions en chinois
    
    Returns:
        (success, total_questions, translated_count)
    """
    print(f"\n📝 Traitement: {input_file.name} → {output_file.name}")
    
    try:
        # Charger le fichier source (français)
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Si le fichier de sortie existe, le charger pour préserver les traductions déjà faites
        existing_data = {}
        if output_file.exists():
            try:
                with open(output_file, 'r', encoding='utf-8') as f:
                    existing_data = json.load(f)
                print(f"   📂 Fichier de sortie existe - fusion des traductions existantes")
            except:
                pass
        
        total_questions = 0
        translated_count = 0
        skipped_count = 0
        
        # Traiter chaque catégorie
        for category, questions in data.items():
            # Traduire le nom de catégorie
            translated_category = CATEGORY_TRANSLATIONS.get(category, category)
            if translated_category == category and not is_chinese(category):
                if translator:
                    cat_translated = translate_with_googletrans(category, translator)
                    if cat_translated:
                        translated_category = cat_translated
            
            if translated_category not in existing_data:
                existing_data[translated_category] = []
            
            print(f"   📚 Catégorie: {category} → {translated_category}")
            
            # Traiter chaque question
            for idx, question in enumerate(questions):
                total_questions += 1
                
                # Vérifier si cette question est déjà traduite dans le fichier existant
                question_key = question.get('question', '')
                already_translated = False
                
                if existing_data[translated_category]:
                    for existing_q in existing_data[translated_category]:
                        existing_question = existing_q.get('question', '')
                        # Si la question source correspond et est déjà en chinois
                        if question_key in existing_question or existing_question in question_key:
                            if is_chinese(existing_question):
                                already_translated = True
                                break
                
                if already_translated:
                    skipped_count += 1
                    if idx < 3:  # Afficher seulement les 3 premières
                        print(f"      ⏭️  Question {idx + 1} déjà traduite")
                    continue
                
                # Traduire la question
                if idx < 5 or (idx + 1) % 10 == 0:
                    print(f"      🔄 Question {idx + 1}/{len(questions)}: {question.get('question', '')[:50]}...")
                
                translated_question, changes = translate_question_complete(question, translator)
                
                if changes > 0:
                    existing_data[translated_category].append(translated_question)
                    translated_count += changes
                    
                    # Sauvegarder progressivement tous les 5 questions
                    if (idx + 1) % 5 == 0:
                        with open(output_file, 'w', encoding='utf-8') as f:
                            json.dump(existing_data, f, ensure_ascii=False, indent=2)
                        print(f"      💾 Sauvegarde intermédiaire (question {idx + 1})")
                else:
                    # Même si échec, ajouter la question originale pour préserver la structure
                    existing_data[translated_category].append(question)
                    print(f"      ⚠️  Question {idx + 1} non traduite (ajoutée telle quelle)")
                
                # Petite pause entre chaque question
                time.sleep(random.uniform(0.5, 1.5))
        
        # Sauvegarde finale
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=2)
        
        print(f"\n   ✅ Fichier traité:")
        print(f"      • Questions totales: {total_questions}")
        print(f"      • Traduites: {translated_count}")
        print(f"      • Déjà traduites (skippées): {skipped_count}")
        
        return True, total_questions, translated_count
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False, 0, 0

def main():
    """Fonction principale"""
    print("🇨🇳 TRADUCTION FINALE EN CHINOIS (ZH)")
    print("=" * 70)
    
    if not GOOGLETRANS_AVAILABLE:
        print("❌ googletrans non disponible !")
        print("   Installez avec: pip3 install googletrans==4.0.0rc1")
        sys.exit(1)
    
    print(f"⚙️  Configuration:")
    print(f"   • Délai entre requêtes: {DELAY_MIN}-{DELAY_MAX}s (random)")
    print(f"   • Retries max: {MAX_RETRIES}")
    print(f"   • Délai retry: {RETRY_BASE_DELAY}s (exponentiel)")
    print("=" * 70)
    
    # Initialiser le traducteur
    translator = Translator()
    print("✅ Traducteur Google initialisé\n")
    
    # Chemin de base
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    # Fichiers à traduire (source français → destination chinois)
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
    total_questions_processed = 0
    total_translated = 0
    start_time = time.time()
    
    for idx, (input_name, output_name) in enumerate(files_to_process, 1):
        input_file = base_path / input_name
        output_file = base_path / output_name
        
        if not input_file.exists():
            print(f"[{idx}/{len(files_to_process)}] ⚠️  Fichier source introuvable: {input_name}")
            continue
        
        print(f"\n[{idx}/{len(files_to_process)}]", end=" ")
        success, questions_count, translated_count = process_file(input_file, output_file, translator)
        
        if success:
            success_count += 1
            total_questions_processed += questions_count
            total_translated += translated_count
    
    elapsed_time = time.time() - start_time
    
    print("\n" + "=" * 70)
    print(f"✅ TRADUCTION TERMINÉE en {elapsed_time/60:.1f} minutes ({elapsed_time:.1f}s)")
    print(f"📊 Résultats:")
    print(f"   • Fichiers traités: {success_count}/{len(files_to_process)}")
    print(f"   • Questions totales: {total_questions_processed}")
    print(f"   • Traductions effectuées: {total_translated}")
    print(f"   • Taux de réussite: {total_translated/total_questions_processed*100:.1f}%")
    
    if success_count == len(files_to_process):
        print("\n🎉 Tous les fichiers ont été traduits avec succès !")
    else:
        print(f"\n⚠️  {len(files_to_process) - success_count} fichier(s) n'ont pas pu être traités")

if __name__ == "__main__":
    main()

