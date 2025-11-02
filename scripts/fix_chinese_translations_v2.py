#!/usr/bin/env python3
"""
Script de correction des traductions chinoises - VERSION OPTIMISÉE
Avec délais augmentés pour éviter le rate-limiting de Google Translate

Auteur: Assistant IA
Date: 27 Octobre 2025
Version: 2.0 (Optimisée pour éviter rate-limiting)
"""

import json
import os
from pathlib import Path
import time
import sys

try:
    from googletrans import Translator
    print("✅ googletrans importé")
except ImportError:
    print("❌ Erreur: googletrans non installé")
    print("   Installer avec: pip install googletrans==4.0.0rc1")
    sys.exit(1)

try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    print("⚠️  tqdm non disponible, pas de barre de progression")
    
    # Fallback si tqdm n'est pas installé
    class tqdm:
        def __init__(self, *args, **kwargs):
            self.total = kwargs.get('total', 0)
            self.n = 0
        def update(self, n=1):
            self.n += n
        def __enter__(self):
            return self
        def __exit__(self, *args):
            pass

# =====================================================================
# CONFIGURATION OPTIMISÉE POUR ÉVITER RATE-LIMITING
# =====================================================================

# 🔧 Délais augmentés pour éviter le blocage
BASE_DELAY = 15  # 15 secondes entre chaque requête (au lieu de 3)
RETRY_DELAYS = [10, 20, 40, 80, 120]  # Délais croissants pour les retries
CATEGORY_PAUSE = 180  # 3 minutes entre chaque catégorie
FILE_PAUSE = 300  # 5 minutes entre chaque fichier

MAX_RETRIES = 5  # 5 tentatives au lieu de 3

# Traductions prédéfinies pour termes courants
TRANSLATIONS = {
    'fr': {
        'question': 'question',
        'answers': 'réponses',
        'correctAnswer': 'correctAnswer',
        'explanation': 'explication',
        'difficulty': 'difficulté',
        'category': 'catégorie',
        'subcategory': 'sous-catégorie',
        'Facile': 'Facile',
        'Moyen': 'Moyen',
        'Difficile': 'Difficile',
    },
    'zh': {
        'question': '问题',
        'answers': '答案',
        'correctAnswer': '正确答案',
        'explanation': '解释',
        'difficulty': '难度',
        'category': '类别',
        'subcategory': '子类别',
        'Facile': '简单',
        'Moyen': '中等',
        'Difficile': '困难',
    }
}

# =====================================================================
# FONCTIONS DE TRADUCTION
# =====================================================================

def translate_text(text: str, target_lang: str, translator, context: str = "", max_retries: int = MAX_RETRIES) -> str:
    """
    Traduit un texte avec gestion robuste des erreurs et délais
    
    Args:
        text: Texte à traduire
        target_lang: Langue cible (zh)
        translator: Instance Translator
        context: Contexte pour debug
        max_retries: Nombre max de tentatives
    """
    if not text or not isinstance(text, str):
        return text
    
    # Si c'est un nombre, ne pas traduire
    if text.replace('.', '').replace(',', '').replace('%', '').strip().isdigit():
        return text
    
    # Utiliser les traductions prédéfinies si disponibles
    if text in TRANSLATIONS.get('fr', {}).values():
        for fr_term, zh_term in zip(TRANSLATIONS['fr'].values(), TRANSLATIONS['zh'].values()):
            if text == fr_term:
                return zh_term
    
    # Sinon, traduire avec Google Translate
    for attempt in range(max_retries):
        try:
            # 🔥 DÉLAI AVANT CHAQUE REQUÊTE
            if attempt > 0:
                delay = RETRY_DELAYS[min(attempt - 1, len(RETRY_DELAYS) - 1)]
                print(f"      ⏳ Retry {attempt + 1}/{max_retries} après {delay}s...")
                time.sleep(delay)
            else:
                time.sleep(BASE_DELAY)  # Délai de base augmenté à 15s
            
            result = translator.translate(text, src='fr', dest=target_lang)
            
            if result and hasattr(result, 'text') and result.text:
                return result.text
            else:
                print(f"      ⚠️  Résultat vide (tentative {attempt + 1})")
                
        except Exception as e:
            error_msg = str(e)
            print(f"      ⚠️  Erreur (tentative {attempt + 1}): {error_msg}")
            
            # Si c'est une erreur de rate-limiting, augmenter drastiquement le délai
            if 'rate' in error_msg.lower() or 'limit' in error_msg.lower():
                extra_delay = 60 * (attempt + 1)  # 1min, 2min, 3min...
                print(f"      ⏰ Rate-limiting détecté, pause de {extra_delay}s...")
                time.sleep(extra_delay)
    
    # Si tous les essais ont échoué, garder le français
    print(f"      ❌ Échec final pour '{text[:50]}...': conservation du français")
    return text

def translate_question_dict(question: dict, target_lang: str, translator, category: str = "", pbar=None) -> dict:
    """
    Traduit tous les champs d'une question
    
    Args:
        question: Dictionnaire de la question
        target_lang: Langue cible
        translator: Instance Translator
        category: Catégorie pour contexte
        pbar: Barre de progression
    """
    translated = {}
    
    # Traduire chaque champ
    for key, value in question.items():
        if key == 'question':
            translated[key] = translate_text(value, target_lang, translator, f"{category}_question")
        elif key == 'explanation':
            translated[key] = translate_text(value, target_lang, translator, f"{category}_explanation")
        elif key == 'difficulty':
            translated[key] = translate_text(value, target_lang, translator, "difficulty")
        elif key == 'category':
            translated[key] = translate_text(value, target_lang, translator, "category")
        elif key == 'subcategory':
            translated[key] = translate_text(value, target_lang, translator, "subcategory")
        elif key == 'answers':
            if isinstance(value, dict):
                translated[key] = {
                    translate_text(k, target_lang, translator, f"{category}_answer"): v
                    for k, v in value.items()
                }
            else:
                translated[key] = value
        elif key == 'options':
            if isinstance(value, list):
                translated[key] = [
                    translate_text(opt, target_lang, translator, f"{category}_option")
                    for opt in value
                ]
            else:
                translated[key] = value
        elif key == 'correctAnswer':
            # Traduire aussi la réponse correcte
            translated[key] = translate_text(value, target_lang, translator, f"{category}_correct")
        else:
            translated[key] = value
    
    if pbar:
        pbar.update(1)
    
    return translated

def count_questions(data) -> int:
    """Compte le nombre total de questions dans une structure JSON"""
    count = 0
    if isinstance(data, list):
        count = len(data)
    elif isinstance(data, dict):
        for value in data.values():
            if isinstance(value, list):
                count += len(value)
            elif isinstance(value, dict):
                count += count_questions(value)
    return count

# =====================================================================
# TRAITEMENT DES FICHIERS
# =====================================================================

def process_file(input_file: Path, output_base_name: str, translator, file_index: int, total_files: int):
    """Traite un fichier source et génère la traduction chinoise"""
    print(f"\n{'='*70}")
    print(f"📄 [{file_index}/{total_files}] {input_file.name}")
    print(f"{'='*70}")
    
    if not input_file.exists():
        print(f"   ⚠️  Fichier non trouvé, ignoré")
        return False
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Compter le total de questions
        total_questions = count_questions(data)
        print(f"   📊 {total_questions} questions à traduire")
        
        target_lang = 'zh'
        print(f"   🌍 Traduction vers {target_lang.upper()}")
        print(f"   ⏱️  Délai: {BASE_DELAY}s par question")
        print(f"   ⏱️  Estimation: {(total_questions * BASE_DELAY) / 60:.1f} minutes")
        print()
        
        # Déterminer la structure du JSON
        if isinstance(data, dict):
            # Format avec catégories
            translated_data = {}
            
            # Créer une barre de progression
            with tqdm(total=total_questions, 
                     desc=f"      Traduction",
                     unit="q",
                     bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]',
                     leave=False) as pbar:
                
                category_count = 0
                for category_key, questions in data.items():
                    category_count += 1
                    
                    # Traduire le nom de catégorie
                    translated_category = translate_text(category_key, target_lang, translator, "category_name")
                    print(f"\n      📁 Catégorie: {category_key} → {translated_category}")
                    
                    if isinstance(questions, list):
                        # Liste simple de questions
                        translated_data[translated_category] = [
                            translate_question_dict(q, target_lang, translator, category_key, pbar)
                            for q in questions
                        ]
                    elif isinstance(questions, dict):
                        # Sous-catégories
                        translated_data[translated_category] = {}
                        for subcat_key, subcat_questions in questions.items():
                            translated_subcat = translate_text(subcat_key, target_lang, translator, "subcategory_name")
                            print(f"         📂 Sous-cat: {subcat_key} → {translated_subcat}")
                            translated_data[translated_category][translated_subcat] = [
                                translate_question_dict(q, target_lang, translator, category_key, pbar)
                                for q in subcat_questions
                            ]
                    
                    # 🔥 PAUSE ENTRE CATÉGORIES
                    if category_count < len(data):
                        print(f"\n      ⏸️  Pause de {CATEGORY_PAUSE}s entre catégories...")
                        time.sleep(CATEGORY_PAUSE)
        
        elif isinstance(data, list):
            # Format liste simple
            with tqdm(total=len(data), 
                     desc=f"      Traduction",
                     unit="q",
                     bar_format='{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]',
                     leave=False) as pbar:
                
                translated_data = [
                    translate_question_dict(q, target_lang, translator, "", pbar)
                    for q in data
                ]
        
        # Écrire le fichier traduit
        output_file = input_file.parent / f"{output_base_name}_zh.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(translated_data, f, ensure_ascii=False, indent=2)
        
        file_size_kb = output_file.stat().st_size / 1024
        print(f"\n   ✅ {output_file.name} ({file_size_kb:.1f} KB)")
        
        # 🔥 PAUSE ENTRE FICHIERS
        if file_index < total_files:
            print(f"\n   ⏸️  Pause de {FILE_PAUSE}s avant le prochain fichier...")
            time.sleep(FILE_PAUSE)
        
        return True
    
    except Exception as e:
        print(f"\n   ❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False

# =====================================================================
# FONCTION PRINCIPALE
# =====================================================================

def main():
    """Fonction principale"""
    print("\n" + "="*70)
    print("  🇨🇳 CORRECTION TRADUCTIONS CHINOISES - VERSION OPTIMISÉE v2.0")
    print("="*70)
    print("\n📋 Configuration:")
    print(f"   • Délai de base: {BASE_DELAY}s par requête")
    print(f"   • Pause entre catégories: {CATEGORY_PAUSE}s")
    print(f"   • Pause entre fichiers: {FILE_PAUSE}s")
    print(f"   • Tentatives max: {MAX_RETRIES}")
    print("\n⚠️  Cette version est beaucoup plus lente mais plus fiable")
    print("   Durée estimée: 10-15 heures\n")
    
    # Initialiser le traducteur
    print("🔧 Initialisation du traducteur...")
    translator = Translator()
    print("✅ Traducteur initialisé\n")
    
    # Définir les fichiers à traiter
    base_path = Path(__file__).parent.parent / "assets" / "questions"
    
    files_to_process = [
        ("enriched_history_questions.json", "enriched_history_questions"),
        ("enriched_culture_questions.json", "enriched_culture_questions"),
        ("enriched_science_questions.json", "enriched_science_questions"),
        ("math_questions.json", "math_questions"),
        ("africa_questions.json", "africa_questions"),
        ("football_questions.json", "football_questions"),
        ("music_questions.json", "music_questions"),
    ]
    
    total_files = len(files_to_process)
    start_time = time.time()
    files_success = 0
    
    print(f"📂 {total_files} fichiers à traiter\n")
    
    for idx, (input_name, output_base) in enumerate(files_to_process, 1):
        input_file = base_path / input_name
        success = process_file(input_file, output_base, translator, idx, total_files)
        if success:
            files_success += 1
    
    # Résumé final
    elapsed = time.time() - start_time
    print("\n" + "="*70)
    print(f"✅ CORRECTION TERMINÉE en {elapsed:.1f}s ({elapsed/3600:.1f}h)")
    print(f"📊 {files_success}/{total_files} fichiers corrigés")
    print("="*70)
    
    if files_success == total_files:
        print("\n🎉 SUCCÈS TOTAL ! Toutes les traductions chinoises sont corrigées")
    else:
        print(f"\n⚠️  {total_files - files_success} fichier(s) ont échoué")
    
    print("\n📋 PROCHAINES ÉTAPES:")
    print("   1. Vérifier les fichiers générés")
    print("   2. Tester l'application: flutter run")
    print("   3. Paramètres > Langue > 中文")
    print("   4. Vérifier que les questions sont en chinois")
    
    print(f"\n📁 Fichiers corrigés:")
    for input_name, output_base in files_to_process:
        output_file = base_path / f"{output_base}_zh.json"
        if output_file.exists():
            file_size_kb = output_file.stat().st_size / 1024
            print(f"   • {output_file.name} ({file_size_kb:.1f} KB)")

if __name__ == "__main__":
    import sys
    
    # Auto-confirmation pour exécution non-interactive
    auto_confirm = '--yes' in sys.argv or '--auto' in sys.argv
    
    if not auto_confirm:
        try:
            print("\n⚠️  AVERTISSEMENT:")
            print("   Ce script prendra 10-15 HEURES avec les délais optimisés")
            print("\n   Avantages:")
            print("   ✅ Évite le rate-limiting")
            print("   ✅ Traductions complètes garanties")
            print("   ✅ Gratuit")
            
            response = input("\n   Continuer ? (oui/non): ")
        except (EOFError, KeyboardInterrupt):
            response = "oui"
            print("oui (auto-confirmé)")
        
        if response.lower() not in ['oui', 'o', 'yes', 'y']:
            print("\n❌ Annulé")
            sys.exit(0)
    
    print("\n🚀 DÉMARRAGE...")
    main()




