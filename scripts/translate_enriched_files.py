#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de traduction automatique des fichiers enriched_*.json
Traduit les 3 fichiers en 5 langues (EN, AR, ZH, ES, HI)

Usage: python3 translate_enriched_files.py
"""

import json
import os
from pathlib import Path
from googletrans import Translator
import time

# Configuration
ASSETS_DIR = Path('assets/questions')
FILES_TO_TRANSLATE = [
    'enriched_culture_questions.json',
    'enriched_science_questions.json',
    'enriched_history_questions.json'
]

TARGET_LANGUAGES = {
    'en': 'English',
    'ar': 'Arabic', 
    'zh-cn': 'Chinese',
    'es': 'Spanish',
    'hi': 'Hindi'
}

def translate_text(text, target_lang, translator, max_retries=3):
    """Traduit un texte avec gestion d'erreurs et retry"""
    if not text or not isinstance(text, str):
        return text
    
    for attempt in range(max_retries):
        try:
            # Limiter la taille du texte
            if len(text) > 500:
                # Diviser en chunks pour les textes longs
                chunks = [text[i:i+500] for i in range(0, len(text), 500)]
                translated_chunks = []
                for chunk in chunks:
                    result = translator.translate(chunk, dest=target_lang)
                    translated_chunks.append(result.text)
                    time.sleep(0.5)  # Pause entre chunks
                return ' '.join(translated_chunks)
            else:
                result = translator.translate(text, dest=target_lang)
                return result.text
        except Exception as e:
            print(f"  ⚠️  Erreur traduction (tentative {attempt+1}/{max_retries}): {str(e)[:50]}")
            time.sleep(2 ** attempt)  # Backoff exponentiel
            if attempt == max_retries - 1:
                print(f"  ❌ Échec définitif, conservation texte original")
                return text
    
    return text

def translate_question(question, target_lang, translator):
    """Traduit une question complète"""
    translated_q = question.copy()
    
    # Traduire la question
    if 'question' in question:
        translated_q['question'] = translate_text(question['question'], target_lang, translator)
    
    # Traduire les réponses
    if 'answers' in question and isinstance(question['answers'], dict):
        translated_answers = {}
        for answer, is_correct in question['answers'].items():
            translated_answer = translate_text(answer, target_lang, translator)
            translated_answers[translated_answer] = is_correct
        translated_q['answers'] = translated_answers
    
    # Traduire l'explication
    if 'explanation' in question:
        translated_q['explanation'] = translate_text(question['explanation'], target_lang, translator)
    
    # Garder les autres champs tels quels (difficulty, subcategory, etc.)
    
    return translated_q

def translate_file(source_file, target_lang, translator):
    """Traduit un fichier complet"""
    print(f"\n  📄 Traduction de {source_file.name} en {TARGET_LANGUAGES.get(target_lang, target_lang)}...")
    
    # Lire le fichier source
    with open(source_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if not isinstance(data, dict):
        print(f"  ⚠️  Structure invalide dans {source_file.name}")
        return None
    
    # Traduire chaque catégorie
    translated_data = {}
    for category_name, questions in data.items():
        if not isinstance(questions, list):
            continue
        
        print(f"    🔄 Traduction catégorie '{category_name}': {len(questions)} questions")
        
        # Traduire le nom de la catégorie
        translated_category_name = translate_text(category_name, target_lang, translator)
        
        # Traduire chaque question
        translated_questions = []
        for i, question in enumerate(questions, 1):
            if i % 10 == 0:
                print(f"      ⏳ Progression: {i}/{len(questions)} questions traduites...")
            
            translated_q = translate_question(question, target_lang, translator)
            translated_questions.append(translated_q)
            
            # Petite pause pour éviter rate limiting
            time.sleep(0.3)
        
        translated_data[translated_category_name] = translated_questions
        print(f"    ✅ {len(translated_questions)} questions traduites pour '{translated_category_name}'")
    
    return translated_data

def main():
    print("╔════════════════════════════════════════════════════════════════════════╗")
    print("║        🌍 TRADUCTION AUTOMATIQUE DES FICHIERS ENRICHED               ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print()
    
    # Initialiser le traducteur
    print("🔧 Initialisation du traducteur Google Translate...")
    translator = Translator()
    print("✅ Traducteur initialisé")
    print()
    
    # Statistiques
    total_files = len(FILES_TO_TRANSLATE) * len(TARGET_LANGUAGES)
    files_done = 0
    total_questions = 0
    
    # Pour chaque fichier
    for filename in FILES_TO_TRANSLATE:
        source_file = ASSETS_DIR / filename
        
        if not source_file.exists():
            print(f"⚠️  Fichier non trouvé: {filename}")
            continue
        
        print(f"┌{'─'*70}┐")
        print(f"│ 📁 FICHIER: {filename:<56} │")
        print(f"└{'─'*70}┘")
        
        # Lire pour compter les questions
        with open(source_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, dict):
                for questions in data.values():
                    if isinstance(questions, list):
                        total_questions += len(questions)
        
        # Pour chaque langue cible
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            # Créer le nom du fichier de sortie
            base_name = filename.replace('.json', '')
            lang_suffix = 'zh' if lang_code == 'zh-cn' else lang_code
            output_filename = f"{base_name}_{lang_suffix}.json"
            output_file = ASSETS_DIR / output_filename
            
            # Vérifier si déjà existant
            if output_file.exists():
                print(f"\n  ⏭️  {output_filename} existe déjà, passage...")
                files_done += 1
                continue
            
            # Traduire
            try:
                translated_data = translate_file(source_file, lang_code, translator)
                
                if translated_data:
                    # Sauvegarder
                    with open(output_file, 'w', encoding='utf-8') as f:
                        json.dump(translated_data, f, ensure_ascii=False, indent=2)
                    
                    print(f"  ✅ Sauvegardé: {output_filename}")
                    files_done += 1
                else:
                    print(f"  ❌ Échec traduction de {filename} en {lang_name}")
                
            except Exception as e:
                print(f"  ❌ Erreur lors de la traduction: {e}")
            
            # Pause entre fichiers
            time.sleep(2)
        
        print()
    
    # Résumé final
    print("╔════════════════════════════════════════════════════════════════════════╗")
    print("║                      ✅ TRADUCTION TERMINÉE                            ║")
    print("╚════════════════════════════════════════════════════════════════════════╝")
    print()
    print(f"📊 Fichiers traduits: {files_done}/{total_files}")
    print(f"📝 Questions sources: {total_questions}")
    print(f"🌍 Traductions totales: {total_questions * len(TARGET_LANGUAGES)}")
    print()
    print("✅ Tous les fichiers enriched ont été traduits !")

if __name__ == '__main__':
    main()



