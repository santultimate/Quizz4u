#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour analyser les questions restantes à traduire en chinois,
puis traduire avec suivi d'avancement en temps réel
"""

import json
import time
import random
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime
import sys

# Détection automatique de googletrans
try:
    from googletrans import Translator
    GOOGLETRANS_AVAILABLE = True
except ImportError:
    GOOGLETRANS_AVAILABLE = False
    print("❌ googletrans non disponible !")
    print("   Installez avec: pip3 install googletrans==4.0.0rc1")
    sys.exit(1)

# Configuration
DELAY_MIN = 2.5  # Délai minimum entre requêtes
DELAY_MAX = 4.5  # Délai maximum
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

def analyze_file(file_path: Path, source_file: Path = None) -> Dict[str, Any]:
    """Analyse un fichier ZH pour compter les questions à traduire"""
    stats = {
        'file': file_path.name,
        'total_questions': 0,
        'translated_questions': 0,
        'french_questions': 0,
        'translated_answers': 0,
        'french_answers': 0,
        'translated_explanations': 0,
        'french_explanations': 0,
        'categories': {},
    }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for category, questions in data.items():
            cat_stats = {
                'total': len(questions),
                'translated': 0,
                'french': 0,
            }
            
            for question in questions:
                stats['total_questions'] += 1
                
                # Analyser la question
                if 'question' in question:
                    q_text = question['question']
                    if is_chinese(q_text):
                        stats['translated_questions'] += 1
                        cat_stats['translated'] += 1
                    else:
                        stats['french_questions'] += 1
                        cat_stats['french'] += 1
                
                # Analyser les réponses
                if 'answers' in question:
                    for answer_text, is_correct in question['answers'].items():
                        if is_chinese(answer_text):
                            stats['translated_answers'] += 1
                        else:
                            stats['french_answers'] += 1
                
                # Analyser les explications
                if 'explanation' in question:
                    exp_text = question['explanation']
                    if is_chinese(exp_text):
                        stats['translated_explanations'] += 1
                    else:
                        stats['french_explanations'] += 1
            
            stats['categories'][category] = cat_stats
            
    except Exception as e:
        stats['error'] = str(e)
    
    return stats

def analyze_all_files() -> List[Dict[str, Any]]:
    """Analyse tous les fichiers ZH"""
    print("🔍 ANALYSE DES QUESTIONS RESTANTES À TRADUIRE")
    print("=" * 70)
    
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    # Fichiers à analyser
    zh_files = sorted(base_path.glob("*_zh.json"))
    
    if not zh_files:
        print("⚠️  Aucun fichier ZH trouvé !")
        return []
    
    print(f"📁 {len(zh_files)} fichiers ZH trouvés\n")
    
    all_stats = []
    total_stats = {
        'total_questions': 0,
        'translated_questions': 0,
        'french_questions': 0,
        'french_answers': 0,
        'french_explanations': 0,
    }
    
    for file_path in zh_files:
        stats = analyze_file(file_path)
        all_stats.append(stats)
        
        # Cumuler les totaux
        total_stats['total_questions'] += stats['total_questions']
        total_stats['translated_questions'] += stats['translated_questions']
        total_stats['french_questions'] += stats['french_questions']
        total_stats['french_answers'] += stats['french_answers']
        total_stats['french_explanations'] += stats['french_explanations']
        
        # Afficher le résumé du fichier
        print(f"📄 {stats['file']}")
        print(f"   Questions totales: {stats['total_questions']}")
        print(f"   ✅ Traduites: {stats['translated_questions']} ({stats['translated_questions']*100/max(stats['total_questions'],1):.1f}%)")
        print(f"   ❌ En français: {stats['french_questions']} ({stats['french_questions']*100/max(stats['total_questions'],1):.1f}%)")
        
        if stats['french_answers'] > 0:
            print(f"   ⚠️  Réponses en français: {stats['french_answers']}")
        if stats['french_explanations'] > 0:
            print(f"   ⚠️  Explications en français: {stats['french_explanations']}")
        
        # Détail par catégorie
        if stats['categories']:
            for cat, cat_stats in stats['categories'].items():
                if cat_stats['french'] > 0:
                    print(f"      • {cat}: {cat_stats['french']}/{cat_stats['total']} à traduire")
        print()
    
    # Résumé global
    print("=" * 70)
    print("📊 RÉSUMÉ GLOBAL")
    print("=" * 70)
    print(f"📝 Questions totales: {total_stats['total_questions']}")
    print(f"✅ Questions déjà traduites: {total_stats['translated_questions']} ({total_stats['translated_questions']*100/max(total_stats['total_questions'],1):.1f}%)")
    print(f"❌ Questions à traduire: {total_stats['french_questions']} ({total_stats['french_questions']*100/max(total_stats['total_questions'],1):.1f}%)")
    print(f"⚠️  Réponses à traduire: {total_stats['french_answers']}")
    print(f"⚠️  Explications à traduire: {total_stats['french_explanations']}")
    
    total_to_translate = total_stats['french_questions'] + total_stats['french_answers'] + total_stats['french_explanations']
    print(f"\n🎯 TOTAL À TRADUIRE: {total_to_translate} éléments")
    
    # Estimation du temps
    avg_time_per_item = 3.5  # secondes
    estimated_minutes = (total_to_translate * avg_time_per_item) / 60
    print(f"⏱️  Temps estimé: ~{estimated_minutes:.1f} minutes ({estimated_minutes/60:.1f} heures)")
    print()
    
    return all_stats

def translate_with_googletrans(text: str, translator, item_type: str = "question") -> Optional[str]:
    """Traduit avec googletrans avec retry amélioré"""
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
                print(f"         ⏳ Retry {attempt + 1}/{MAX_RETRIES} après {delay:.1f}s...")
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
            
            if 'invalid destination language' in error_msg:
                continue
            elif '429' in error_msg or 'too many requests' in error_msg:
                wait_time = RETRY_BASE_DELAY * (2 ** attempt)
                print(f"         ⏳ Rate limit - attente {wait_time:.1f}s...")
                time.sleep(wait_time)
                continue
            elif 'timed out' in error_msg or 'timeout' in error_msg:
                continue
    
    return None

def translate_file(file_path: Path, translator, stats: Dict[str, Any]) -> Dict[str, Any]:
    """Traduit un fichier avec suivi d'avancement"""
    print(f"\n🔄 TRADUCTION: {file_path.name}")
    print("=" * 70)
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        total_items = stats['french_questions'] + stats['french_answers'] + stats['french_explanations']
        translated_items = 0
        failed_items = 0
        
        start_time = time.time()
        
        for category, questions in data.items():
            print(f"\n📚 Catégorie: {category}")
            
            for q_idx, question in enumerate(questions):
                changed = False
                
                # Traduire la question
                if 'question' in question:
                    q_text = question['question']
                    if not is_chinese(q_text):
                        print(f"   [{q_idx+1}/{len(questions)}] 🔄 Question: {q_text[:50]}...")
                        translated_q = translate_with_googletrans(q_text, translator, "question")
                        if translated_q:
                            question['question'] = translated_q
                            translated_items += 1
                            changed = True
                            print(f"         ✅ Traduite: {translated_q[:50]}...")
                        else:
                            failed_items += 1
                            print(f"         ❌ Échec traduction")
                
                # Traduire les réponses
                if 'answers' in question:
                    new_answers = {}
                    for answer_text, is_correct in question['answers'].items():
                        if not is_chinese(answer_text):
                            translated_a = translate_with_googletrans(answer_text, translator, "answer")
                            if translated_a:
                                new_answers[translated_a] = is_correct
                                translated_items += 1
                                changed = True
                            else:
                                new_answers[answer_text] = is_correct
                                failed_items += 1
                        else:
                            new_answers[answer_text] = is_correct
                    
                    if changed:
                        question['answers'] = new_answers
                
                # Traduire l'explication
                if 'explanation' in question:
                    exp_text = question['explanation']
                    if not is_chinese(exp_text):
                        translated_exp = translate_with_googletrans(exp_text, translator, "explanation")
                        if translated_exp:
                            question['explanation'] = translated_exp
                            translated_items += 1
                            changed = True
                
                # Sauvegarder progressivement tous les 5 questions
                if changed and (q_idx + 1) % 5 == 0:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                    
                    elapsed = time.time() - start_time
                    progress = (translated_items / max(total_items, 1)) * 100
                    print(f"      💾 Sauvegarde (progression: {progress:.1f}%)")
                
                # Afficher progression globale
                if (q_idx + 1) % 10 == 0 or q_idx == len(questions) - 1:
                    elapsed = time.time() - start_time
                    progress = (translated_items / max(total_items, 1)) * 100
                    remaining = total_items - translated_items
                    if remaining > 0:
                        eta_minutes = (elapsed / max(translated_items, 1)) * remaining / 60
                        print(f"      📊 Progression: {translated_items}/{total_items} ({progress:.1f}%) - ETA: ~{eta_minutes:.1f} min")
        
        # Sauvegarde finale
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        elapsed = time.time() - start_time
        
        return {
            'success': True,
            'translated': translated_items,
            'failed': failed_items,
            'time': elapsed,
        }
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return {
            'success': False,
            'error': str(e),
        }

def main():
    """Fonction principale"""
    print("🇨🇳 ANALYSE ET TRADUCTION CHINOISE (ZH)")
    print("=" * 70)
    print(f"⏰ Démarrage: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    # Étape 1: Analyse
    all_stats = analyze_all_files()
    
    if not all_stats:
        print("⚠️  Aucun fichier à traiter")
        return
    
    # Démarrer automatiquement si des traductions sont nécessaires
    total_french = sum(s['french_questions'] for s in all_stats)
    if total_french == 0:
        print("\n✅ Toutes les questions sont déjà traduites !")
        return
    
    print("\n" + "=" * 70)
    print("🚀 DÉMARRAGE AUTOMATIQUE DE LA TRADUCTION")
    print("=" * 70)
    
    # Étape 2: Traduction
    print("\n" + "=" * 70)
    print("🚀 DÉMARRAGE DE LA TRADUCTION")
    print("=" * 70)
    
    if not GOOGLETRANS_AVAILABLE:
        print("❌ googletrans non disponible !")
        print("   Installez avec: pip3 install googletrans==4.0.0rc1")
        return
    
    translator = Translator()
    print("✅ Traducteur Google initialisé\n")
    
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    results = []
    start_time = time.time()
    
    for stats in all_stats:
        if stats['french_questions'] == 0 and stats['french_answers'] == 0:
            print(f"⏭️  {stats['file']} - Déjà complètement traduit, skip")
            continue
        
        file_path = base_path / stats['file']
        result = translate_file(file_path, translator, stats)
        results.append({
            'file': stats['file'],
            **result,
        })
    
    # Résumé final
    total_elapsed = time.time() - start_time
    total_translated = sum(r.get('translated', 0) for r in results)
    total_failed = sum(r.get('failed', 0) for r in results)
    
    print("\n" + "=" * 70)
    print("✅ TRADUCTION TERMINÉE")
    print("=" * 70)
    print(f"⏰ Durée totale: {total_elapsed/60:.1f} minutes ({total_elapsed:.1f}s)")
    print(f"📊 Résultats:")
    print(f"   • Éléments traduits: {total_translated}")
    print(f"   • Éléments échoués: {total_failed}")
    
    if total_translated > 0:
        success_rate = (total_translated / (total_translated + total_failed)) * 100
        print(f"   • Taux de réussite: {success_rate:.1f}%")
    
    print(f"\n⏰ Fin: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()

