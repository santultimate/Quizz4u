#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour compléter les dernières questions restantes en chinois
"""

import json
import time
import random
from pathlib import Path
from typing import Optional

try:
    from googletrans import Translator
    GOOGLETRANS_AVAILABLE = True
except ImportError:
    GOOGLETRANS_AVAILABLE = False
    print("❌ googletrans non disponible !")
    exit(1)

DELAY_MIN = 2.5
DELAY_MAX = 4.5
MAX_RETRIES = 5
RETRY_BASE_DELAY = 10.0

def is_chinese(text: str) -> bool:
    """Vérifie si un texte contient déjà des caractères chinois"""
    if not text or not isinstance(text, str):
        return False
    chinese_chars = [c for c in text if '\u4e00' <= c <= '\u9fff']
    if len(text) > 0 and len(chinese_chars) / len(text) > 0.3:
        return True
    return False

def translate_with_retry(text: str, translator) -> Optional[str]:
    """Traduit avec retry"""
    if not GOOGLETRANS_AVAILABLE:
        return None
    
    if is_chinese(text):
        return text
    
    text_clean = text.strip().replace('.', '').replace(',', '').replace('-', '').replace('+', '').replace('×', '').replace('÷', '')
    if len(text_clean) < 3 or text_clean.replace(' ', '').isdigit():
        return text
    
    for attempt in range(MAX_RETRIES):
        try:
            if attempt > 0:
                delay = RETRY_BASE_DELAY * (2 ** (attempt - 1))
                print(f"      ⏳ Retry {attempt + 1}/{MAX_RETRIES} après {delay:.1f}s...")
                time.sleep(delay)
            else:
                delay = random.uniform(DELAY_MIN, DELAY_MAX)
                time.sleep(delay)
            
            result = translator.translate(text, src='fr', dest='zh-cn')
            
            if result and result.text:
                translated = result.text.strip()
                if is_chinese(translated) or len(translated) > 0:
                    return translated
            
        except Exception as e:
            error_msg = str(e).lower()
            if 'invalid destination language' in error_msg or '429' in error_msg or 'too many requests' in error_msg:
                wait_time = RETRY_BASE_DELAY * (2 ** attempt)
                time.sleep(wait_time)
                continue
            elif 'timed out' in error_msg or 'timeout' in error_msg:
                continue
    
    return None

def complete_file(file_path: Path, translator):
    """Complète les questions restantes dans un fichier"""
    print(f"\n📝 Traitement: {file_path.name}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        total_updated = 0
        
        for category, questions in data.items():
            print(f"   📚 Catégorie: {category}")
            
            for q_idx, question in enumerate(questions):
                changed = False
                
                # Question
                if 'question' in question:
                    q_text = question['question']
                    if not is_chinese(q_text):
                        print(f"      [{q_idx+1}/{len(questions)}] 🔄 Question: {q_text[:50]}...")
                        translated_q = translate_with_retry(q_text, translator)
                        if translated_q:
                            question['question'] = translated_q
                            changed = True
                            total_updated += 1
                            print(f"         ✅ Traduite: {translated_q[:50]}...")
                        else:
                            print(f"         ❌ Échec")
                
                # Réponses
                if 'answers' in question:
                    new_answers = {}
                    for answer_text, is_correct in question['answers'].items():
                        if not is_chinese(answer_text):
                            translated_a = translate_with_retry(answer_text, translator)
                            if translated_a:
                                new_answers[translated_a] = is_correct
                                changed = True
                                total_updated += 1
                            else:
                                new_answers[answer_text] = is_correct
                        else:
                            new_answers[answer_text] = is_correct
                    
                    if changed:
                        question['answers'] = new_answers
                
                # Explication
                if 'explanation' in question:
                    exp_text = question['explanation']
                    if not is_chinese(exp_text):
                        translated_exp = translate_with_retry(exp_text, translator)
                        if translated_exp:
                            question['explanation'] = translated_exp
                            changed = True
                            total_updated += 1
                
                # Sauvegarder après chaque modification
                if changed:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                    print(f"         💾 Sauvegardé")
        
        print(f"   ✅ Fichier complété: {total_updated} éléments mis à jour")
        return total_updated
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return 0

def main():
    print("🇨🇳 COMPLÉTION DES DERNIÈRES QUESTIONS")
    print("=" * 70)
    
    translator = Translator()
    print("✅ Traducteur initialisé\n")
    
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    # Fichiers à compléter
    files_to_complete = [
        "football_questions_zh.json",
        "music_questions_zh.json",
        "arts_culture_questions_expansion_zh.json",
    ]
    
    total_updated = 0
    
    for filename in files_to_complete:
        file_path = base_path / filename
        if file_path.exists():
            updated = complete_file(file_path, translator)
            total_updated += updated
        else:
            print(f"⚠️  Fichier introuvable: {filename}")
    
    print("\n" + "=" * 70)
    print(f"✅ TERMINÉ ! {total_updated} éléments traduits")
    print("=" * 70)

if __name__ == "__main__":
    main()

