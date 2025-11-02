#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de traduction GRATUITE des fichiers enriched avec BARRE DE PROGRESSION
Utilise deep-translator (Google Translate gratuit, pas d'API key requise)
"""

import json
import os
import time
import sys
from pathlib import Path
from datetime import datetime

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("📦 Installation de deep-translator...")
    os.system("pip3 install deep-translator")
    from deep_translator import GoogleTranslator

# Configuration
ASSETS_DIR = Path(__file__).parent.parent / "assets" / "questions"
DELAY_BETWEEN_REQUESTS = 1.0  # Secondes entre requêtes
DELAY_BETWEEN_QUESTIONS = 0.3  # Secondes entre questions

# Fichiers à traduire
FILES_TO_TRANSLATE = [
    "enriched_culture_questions.json",
    "enriched_science_questions.json", 
    "enriched_history_questions.json",
]

# Langues cibles
TARGET_LANGUAGES = {
    'en': 'english',
    'ar': 'arabic',
    'zh': 'chinese (simplified)',
    'es': 'spanish',
    'hi': 'hindi',
}

def translate_text(text, target_lang, retries=3):
    """Traduit un texte avec retry"""
    if not text or text.strip() == "":
        return text
    
    for attempt in range(retries):
        try:
            translator = GoogleTranslator(source='fr', target=target_lang)
            translated = translator.translate(text)
            time.sleep(DELAY_BETWEEN_REQUESTS)
            return translated
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2)
            else:
                return text  # Retourner original en cas d'échec

def translate_question_silent(question, target_lang):
    """Traduit une question (mode silencieux pour barre de progression)"""
    translated_q = question.copy()
    
    try:
        # Traduire la question
        if 'question' in question:
            translated_q['question'] = translate_text(question['question'], target_lang)
        
        # Traduire les réponses
        if 'answers' in question:
            if isinstance(question['answers'], list):
                translated_answers = []
                for answer in question['answers']:
                    translated_answers.append(translate_text(answer, target_lang))
                translated_q['answers'] = translated_answers
            elif isinstance(question['answers'], dict):
                translated_answers = {}
                for answer_text, is_correct in question['answers'].items():
                    translated_text = translate_text(answer_text, target_lang)
                    translated_answers[translated_text] = is_correct
                translated_q['answers'] = translated_answers
        
        # Traduire l'explication
        if 'explanation' in question and question['explanation']:
            translated_q['explanation'] = translate_text(question['explanation'], target_lang)
        
        time.sleep(DELAY_BETWEEN_QUESTIONS)
        
    except Exception as e:
        return question  # Retourner original en cas d'erreur
    
    return translated_q

def print_progress_bar(current, total, start_time, prefix='', suffix='', length=40):
    """Affiche une barre de progression"""
    percent = 100 * (current / float(total))
    filled_length = int(length * current // total)
    bar = '█' * filled_length + '░' * (length - filled_length)
    
    # Calculer ETA
    elapsed = time.time() - start_time
    if current > 0:
        eta_seconds = (elapsed / current) * (total - current)
        eta_min = int(eta_seconds // 60)
        eta_sec = int(eta_seconds % 60)
        eta_str = f"ETA: {eta_min:02d}:{eta_sec:02d}"
    else:
        eta_str = "ETA: --:--"
    
    sys.stdout.write(f'\r{prefix} [{bar}] {current}/{total} ({percent:.1f}%) {eta_str} {suffix}')
    sys.stdout.flush()

def translate_file_with_progress(filename, target_lang, lang_name, file_num, total_files):
    """Traduit un fichier avec barre de progression"""
    source_path = ASSETS_DIR / filename
    target_filename = filename.replace('.json', f'_{target_lang}.json')
    target_path = ASSETS_DIR / target_filename
    
    print(f"\n\n{'='*75}")
    print(f"📁 [{file_num}/{total_files}] {filename}")
    print(f"🌍 Langue: {lang_name} ({target_lang})")
    print(f"{'='*75}")
    
    # Vérifier si déjà traduit
    if target_path.exists():
        try:
            with open(target_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
            with open(source_path, 'r', encoding='utf-8') as f:
                french_data = json.load(f)
            
            # Vérifier si c'est un stub
            is_stub = False
            if isinstance(existing_data, dict) and isinstance(french_data, dict):
                # Format enriched
                ex_questions = list(existing_data.values())[0] if existing_data else []
                fr_questions = list(french_data.values())[0] if french_data else []
                if ex_questions and fr_questions:
                    if ex_questions[0].get('question') == fr_questions[0].get('question'):
                        is_stub = True
            
            if not is_stub:
                print(f"✅ Déjà traduit (skip)\n")
                return True
            else:
                print(f"⚠️  Stub détecté, écrasement...\n")
        except:
            pass
    
    # Charger le fichier source
    try:
        with open(source_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"❌ Erreur lecture: {e}\n")
        return False
    
    # Extraire les questions
    questions = []
    category_key = None
    
    if isinstance(data, list):
        questions = data
    elif isinstance(data, dict):
        if 'questions' in data:
            questions = data['questions']
        else:
            # Format enriched
            if len(data) > 0:
                category_key = list(data.keys())[0]
                questions = data[category_key]
                print(f"📂 Catégorie: {category_key}")
    
    if not questions:
        print(f"❌ Aucune question trouvée\n")
        return False
    
    total_questions = len(questions)
    print(f"📊 {total_questions} questions à traduire\n")
    
    # Traduire avec barre de progression
    translated_questions = []
    start_time = time.time()
    
    for i, question in enumerate(questions):
        print_progress_bar(
            i, 
            total_questions, 
            start_time,
            prefix=f'   🔄 Traduction',
            suffix=''
        )
        
        translated_q = translate_question_silent(question, target_lang)
        translated_questions.append(translated_q)
    
    # Afficher barre finale (100%)
    print_progress_bar(
        total_questions, 
        total_questions, 
        start_time,
        prefix=f'   🔄 Traduction',
        suffix='✅ Terminé!'
    )
    print()  # Nouvelle ligne
    
    # Sauvegarder
    if isinstance(data, list):
        output_data = translated_questions
    elif category_key:
        output_data = {category_key: translated_questions}
    else:
        output_data = {'questions': translated_questions}
    
    try:
        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        
        elapsed = time.time() - start_time
        print(f"\n   ✅ Sauvegardé: {target_filename}")
        print(f"   ⏱️  Durée: {int(elapsed // 60)}m {int(elapsed % 60)}s")
        return True
    except Exception as e:
        print(f"\n   ❌ Erreur sauvegarde: {e}")
        return False

def main():
    print("\n")
    print("╔═══════════════════════════════════════════════════════════════════════════╗")
    print("║     🌍 TRADUCTION GRATUITE - FICHIERS ENRICHED (avec progression)         ║")
    print("╚═══════════════════════════════════════════════════════════════════════════╝")
    print()
    print("🔧 Service: Google Translate (via deep-translator)")
    print("💰 Coût: GRATUIT")
    print("⏱️  Temps estimé: ~30-45 minutes")
    print(f"🕐 Démarrage: {datetime.now().strftime('%H:%M:%S')}")
    
    total_files = len(FILES_TO_TRANSLATE) * len(TARGET_LANGUAGES)
    completed = 0
    failed = 0
    start_time_global = time.time()
    
    file_counter = 0
    for filename in FILES_TO_TRANSLATE:
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            file_counter += 1
            try:
                success = translate_file_with_progress(
                    filename, 
                    lang_code, 
                    lang_name,
                    file_counter,
                    total_files
                )
                
                if success:
                    completed += 1
                else:
                    failed += 1
                
                # Progression globale
                global_progress = (file_counter / total_files) * 100
                print(f"\n📊 PROGRESSION GLOBALE: {file_counter}/{total_files} ({global_progress:.1f}%)")
                print(f"   ✅ Réussis: {completed}  |  ❌ Échecs: {failed}")
                
                time.sleep(1)  # Pause entre fichiers
                
            except KeyboardInterrupt:
                print("\n\n⚠️  Interruption utilisateur")
                print(f"📊 Progression: {completed}/{total_files}")
                return
            except Exception as e:
                print(f"\n❌ Erreur: {e}")
                failed += 1
    
    # Résumé final
    total_time = time.time() - start_time_global
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════════════════════╗")
    print("║                        ✅ TRADUCTION TERMINÉE                              ║")
    print("╚═══════════════════════════════════════════════════════════════════════════╝")
    print(f"\n🕐 Heure de fin: {datetime.now().strftime('%H:%M:%S')}")
    print(f"⏱️  Durée totale: {int(total_time // 60)}m {int(total_time % 60)}s")
    print(f"\n📊 RÉSUMÉ:")
    print(f"   • Fichiers sources: {len(FILES_TO_TRANSLATE)}")
    print(f"   • Langues cibles: {len(TARGET_LANGUAGES)}")
    print(f"   • Total fichiers: {total_files}")
    print(f"   • ✅ Complétés: {completed}")
    print(f"   • ❌ Échecs: {failed}")
    print(f"   • 📈 Taux de réussite: {(completed/total_files*100):.1f}%")
    
    if completed == total_files:
        print("\n🎉 TOUTES les traductions réussies !")
        print("\n📋 PROCHAINES ÉTAPES:")
        print("   1. ✅ Vérifier échantillon de qualité")
        print("   2. ✅ Tester l'app dans différentes langues")
        print("   3. ✅ Publier sur les stores 🚀")
    else:
        print(f"\n⚠️  {failed} fichiers en échec")
        print("   💡 Relancez le script, il skip les fichiers OK")

if __name__ == "__main__":
    main()


