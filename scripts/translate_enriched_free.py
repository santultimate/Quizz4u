#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de traduction GRATUITE des fichiers enriched
Utilise deep-translator (Google Translate gratuit, pas d'API key requise)
"""

import json
import os
import time
from pathlib import Path

try:
    from deep_translator import GoogleTranslator
    print("✅ deep_translator installé")
except ImportError:
    print("❌ deep_translator non installé")
    print("📦 Installation en cours...")
    os.system("pip3 install deep-translator")
    from deep_translator import GoogleTranslator
    print("✅ deep_translator installé avec succès")

# Configuration
ASSETS_DIR = Path(__file__).parent.parent / "assets" / "questions"
DELAY_BETWEEN_REQUESTS = 1.0  # Secondes entre requêtes pour éviter rate limit
DELAY_BETWEEN_QUESTIONS = 0.5  # Secondes entre questions

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
    """
    Traduit un texte avec gestion des erreurs et retry
    """
    if not text or text.strip() == "":
        return text
    
    for attempt in range(retries):
        try:
            translator = GoogleTranslator(source='fr', target=target_lang)
            translated = translator.translate(text)
            
            # Attendre un peu pour éviter rate limiting
            time.sleep(DELAY_BETWEEN_REQUESTS)
            
            return translated
        except Exception as e:
            if attempt < retries - 1:
                print(f"  ⚠️  Erreur, retry {attempt + 1}/{retries}: {e}")
                time.sleep(2)  # Attendre plus longtemps avant retry
            else:
                print(f"  ❌ Échec après {retries} tentatives: {e}")
                return text  # Retourner le texte original en cas d'échec

def translate_question(question, target_lang, lang_name):
    """
    Traduit une question complète (question + réponses + explication)
    """
    translated_q = question.copy()
    
    try:
        # Traduire la question
        if 'question' in question:
            print(f"    📝 Question: {question['question'][:50]}...")
            translated_q['question'] = translate_text(question['question'], target_lang)
        
        # Traduire les réponses
        if 'answers' in question:
            if isinstance(question['answers'], list):
                # Format liste: ["réponse1", "réponse2", ...]
                translated_answers = []
                for i, answer in enumerate(question['answers']):
                    print(f"       → Réponse {i+1}: {answer[:30]}...")
                    translated_answers.append(translate_text(answer, target_lang))
                translated_q['answers'] = translated_answers
            elif isinstance(question['answers'], dict):
                # Format dictionnaire: {"réponse1": true, "réponse2": false, ...}
                translated_answers = {}
                for i, (answer_text, is_correct) in enumerate(question['answers'].items(), 1):
                    print(f"       → Réponse {i}: {answer_text[:30]}...")
                    translated_text = translate_text(answer_text, target_lang)
                    translated_answers[translated_text] = is_correct
                translated_q['answers'] = translated_answers
        
        # Traduire l'explication si présente
        if 'explanation' in question and question['explanation']:
            print(f"       ℹ️  Explication...")
            translated_q['explanation'] = translate_text(question['explanation'], target_lang)
        
        time.sleep(DELAY_BETWEEN_QUESTIONS)
        
    except Exception as e:
        print(f"    ❌ Erreur traduction question: {e}")
        return question  # Retourner original en cas d'erreur
    
    return translated_q

def translate_file(filename, target_lang, lang_name):
    """
    Traduit un fichier complet
    """
    source_path = ASSETS_DIR / filename
    target_filename = filename.replace('.json', f'_{target_lang}.json')
    target_path = ASSETS_DIR / target_filename
    
    print(f"\n📁 {filename} → {target_filename}")
    print(f"   Langue: {lang_name}")
    
    # Vérifier si le fichier cible existe déjà et n'est pas un stub
    if target_path.exists():
        with open(target_path, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
            # Vérifier si c'est un stub (compare première question avec français)
            with open(source_path, 'r', encoding='utf-8') as f_fr:
                french_data = json.load(f_fr)
                if existing_data and french_data:
                    if isinstance(existing_data, list) and isinstance(french_data, list):
                        if len(existing_data) > 0 and len(french_data) > 0:
                            # Si la première question est identique, c'est un stub
                            if existing_data[0].get('question') == french_data[0].get('question'):
                                print(f"   ⚠️  Fichier existant est un STUB, écrasement...")
                            else:
                                print(f"   ✅ Fichier déjà traduit (skip)")
                                return True
    
    # Charger le fichier source
    try:
        with open(source_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"   ❌ Erreur lecture: {e}")
        return False
    
    # Gérer différents formats
    questions = []
    category_key = None
    
    if isinstance(data, list):
        questions = data
    elif isinstance(data, dict):
        if 'questions' in data:
            questions = data['questions']
        else:
            # Format enriched: {"Culture générale": [...]}
            # Prendre la première (et normalement unique) clé
            if len(data) > 0:
                category_key = list(data.keys())[0]
                questions = data[category_key]
                print(f"   📂 Catégorie: {category_key}")
            else:
                print(f"   ❌ Dictionnaire vide")
                return False
    else:
        print(f"   ❌ Format non reconnu")
        return False
    
    print(f"   📊 {len(questions)} questions à traduire")
    
    # Traduire chaque question
    translated_questions = []
    for i, question in enumerate(questions, 1):
        print(f"   [{i}/{len(questions)}]", end=" ")
        translated_q = translate_question(question, target_lang, lang_name)
        translated_questions.append(translated_q)
    
    # Sauvegarder avec le même format que l'original
    if isinstance(data, list):
        output_data = translated_questions
    elif category_key:
        # Format enriched: conserver la clé de catégorie
        output_data = {category_key: translated_questions}
    else:
        output_data = {'questions': translated_questions}
    
    try:
        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        print(f"   ✅ Sauvegardé: {target_path.name}")
        return True
    except Exception as e:
        print(f"   ❌ Erreur sauvegarde: {e}")
        return False

def main():
    print("╔════════════════════════════════════════════════════════════════════════╗")
    print("║     🌍 TRADUCTION GRATUITE DES FICHIERS ENRICHED                      ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print()
    print("🔧 Service: Google Translate (via deep-translator)")
    print("💰 Coût: GRATUIT")
    print("⏱️  Temps estimé: ~30-45 minutes (avec rate limiting)")
    print()
    
    total_files = len(FILES_TO_TRANSLATE) * len(TARGET_LANGUAGES)
    completed = 0
    failed = 0
    
    for filename in FILES_TO_TRANSLATE:
        print(f"\n{'='*70}")
        print(f"📄 FICHIER SOURCE: {filename}")
        print(f"{'='*70}")
        
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            try:
                success = translate_file(filename, lang_code, lang_name)
                if success:
                    completed += 1
                else:
                    failed += 1
                
                # Pause entre fichiers pour respecter rate limits
                time.sleep(2)
                
            except KeyboardInterrupt:
                print("\n\n⚠️  Interruption utilisateur")
                print(f"📊 Progression: {completed}/{total_files} complétés, {failed} échecs")
                return
            except Exception as e:
                print(f"❌ Erreur inattendue: {e}")
                failed += 1
    
    print("\n\n╔════════════════════════════════════════════════════════════════════════╗")
    print("║                   ✅ TRADUCTION TERMINÉE                               ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print(f"\n📊 RÉSUMÉ:")
    print(f"   • Fichiers sources: {len(FILES_TO_TRANSLATE)}")
    print(f"   • Langues cibles: {len(TARGET_LANGUAGES)}")
    print(f"   • Total fichiers: {total_files}")
    print(f"   • ✅ Complétés: {completed}")
    print(f"   • ❌ Échecs: {failed}")
    print(f"   • 📈 Taux de réussite: {(completed/total_files*100):.1f}%")
    
    if completed == total_files:
        print("\n🎉 TOUTES les traductions ont été effectuées avec succès !")
        print("\n📋 PROCHAINES ÉTAPES:")
        print("   1. Vérifier les fichiers traduits dans assets/questions/")
        print("   2. Tester l'app dans différentes langues")
        print("   3. Vérifier la qualité des traductions (échantillon)")
        print("   4. Publier sur les stores 🚀")
    else:
        print(f"\n⚠️  {failed} fichiers n'ont pas pu être traduits")
        print("   Vous pouvez relancer le script, il skip les fichiers déjà traduits")

if __name__ == "__main__":
    main()

