#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de fusion des questions uniques dans les catégories traduites
Fusionne les questions des catégories non traduites dans les catégories principales
"""

import json
import os
from pathlib import Path

# Mappings de fusion : source → destination
MERGE_MAPPINGS = {
    'mali_history_questions.json': 'enriched_history_questions.json',
    'general_culture_questions.json': 'enriched_culture_questions.json',
    'science_questions.json': 'enriched_science_questions.json',
}

def load_json(file_path):
    """Charge un fichier JSON"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Erreur lecture {file_path}: {e}")
        return None

def save_json(file_path, data, backup=True):
    """Sauvegarde un fichier JSON"""
    try:
        # Backup
        if backup and os.path.exists(file_path):
            backup_path = str(file_path) + '.pre-merge-backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(load_json(file_path), f, ensure_ascii=False, indent=2)
        
        # Sauvegarder
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"❌ Erreur sauvegarde {file_path}: {e}")
        return False

def extract_questions_list(data):
    """Extrait la liste des questions d'un fichier JSON (format flexible)"""
    questions = []
    
    def extract_recursive(obj):
        if isinstance(obj, dict):
            if 'question' in obj and 'options' in obj:
                # C'est un objet question
                questions.append(obj)
            else:
                for value in obj.values():
                    extract_recursive(value)
        elif isinstance(obj, list):
            for item in obj:
                extract_recursive(item)
    
    extract_recursive(data)
    return questions

def merge_questions(source_file, dest_file, questions_dir):
    """Fusionne les questions de source dans dest"""
    source_path = questions_dir / source_file
    dest_path = questions_dir / dest_file
    
    print(f"\n📝 Fusion: {source_file} → {dest_file}")
    
    # Charger les fichiers
    source_data = load_json(source_path)
    dest_data = load_json(dest_path)
    
    if not source_data or not dest_data:
        return False
    
    # Extraire les questions
    source_questions = extract_questions_list(source_data)
    dest_questions = extract_questions_list(dest_data)
    
    print(f"   📊 Source: {len(source_questions)} questions")
    print(f"   📊 Destination: {len(dest_questions)} questions")
    
    # Ajouter les questions source à destination
    dest_questions.extend(source_questions)
    
    print(f"   ✅ Total après fusion: {len(dest_questions)} questions")
    
    # Reconstruire la structure du fichier destination
    # On garde la structure originale et on met à jour les questions
    def update_questions_recursive(obj, new_questions):
        if isinstance(obj, dict):
            for key, value in obj.items():
                if isinstance(value, list) and value and isinstance(value[0], dict) and 'question' in value[0]:
                    # C'est une liste de questions, on la remplace
                    obj[key] = new_questions
                    return True
                elif isinstance(value, (dict, list)):
                    if update_questions_recursive(value, new_questions):
                        return True
        elif isinstance(obj, list):
            for item in obj:
                if isinstance(item, dict):
                    if update_questions_recursive(item, new_questions):
                        return True
        return False
    
    # Mise à jour
    if not update_questions_recursive(dest_data, dest_questions):
        # Si la structure est complexe, on crée une structure simple
        category_name = dest_file.replace('_questions.json', '').replace('enriched_', '').replace('_', ' ').title()
        dest_data = {
            category_name: {
                "questions": dest_questions
            }
        }
    
    # Sauvegarder
    if save_json(dest_path, dest_data):
        print(f"   💾 Sauvegarde: {dest_file}")
        
        # Mettre à jour aussi les fichiers traduits
        update_translated_files(dest_file, dest_questions, questions_dir)
        
        return True
    
    return False

def update_translated_files(base_file, questions, questions_dir):
    """Met à jour les fichiers traduits avec les nouvelles questions"""
    base_name = base_file.replace('.json', '')
    languages = ['ar', 'en', 'es', 'hi', 'zh']
    
    print(f"   🌍 Mise à jour des traductions...")
    
    for lang in languages:
        translated_file = f"{base_name}_{lang}.json"
        translated_path = questions_dir / translated_file
        
        if translated_path.exists():
            try:
                # Charger le fichier traduit
                translated_data = load_json(translated_path)
                if translated_data:
                    # Mettre à jour avec les nouvelles questions (en FR pour l'instant)
                    # Les vraies traductions seront faites plus tard
                    def update_questions_recursive(obj, new_questions):
                        if isinstance(obj, dict):
                            for key, value in obj.items():
                                if isinstance(value, list) and value and isinstance(value[0], dict):
                                    if 'question' in value[0]:
                                        obj[key] = new_questions
                                        return True
                                elif isinstance(value, (dict, list)):
                                    if update_questions_recursive(value, new_questions):
                                        return True
                        elif isinstance(obj, list):
                            for item in obj:
                                if isinstance(item, dict):
                                    if update_questions_recursive(item, new_questions):
                                        return True
                        return False
                    
                    update_questions_recursive(translated_data, questions)
                    save_json(translated_path, translated_data, backup=False)
                    print(f"      ✅ {lang.upper()}")
            except Exception as e:
                print(f"      ⚠️ {lang.upper()}: {e}")

def main():
    print("🔀 FUSION DES QUESTIONS UNIQUES DANS LES CATÉGORIES TRADUITES")
    print("=" * 70)
    
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    
    if not questions_dir.exists():
        print(f"❌ Dossier non trouvé: {questions_dir}")
        return
    
    # Effectuer les fusions
    successful = 0
    total = len(MERGE_MAPPINGS)
    
    for source, dest in MERGE_MAPPINGS.items():
        if merge_questions(source, dest, questions_dir):
            successful += 1
    
    print("\n" + "=" * 70)
    print("📊 RÉSUMÉ DE LA FUSION")
    print("=" * 70)
    print(f"✅ Fusions réussies: {successful}/{total}")
    
    if successful == total:
        print("\n🎉 Toutes les fusions ont été effectuées avec succès !")
        print("\n📝 NOUVEAUX TOTAUX PAR CATÉGORIE:")
        
        for source, dest in MERGE_MAPPINGS.items():
            dest_path = questions_dir / dest
            if dest_path.exists():
                data = load_json(dest_path)
                if data:
                    questions = extract_questions_list(data)
                    print(f"   ✅ {dest}: {len(questions)} questions")
        
        print("\n💾 SAUVEGARDES:")
        print("   Fichiers originaux → *.pre-merge-backup")
        
        print("\n🌍 TRADUCTIONS:")
        print("   Les fichiers traduits (AR/EN/ES/HI/ZH) ont été mis à jour")
        print("   ⚠️  Note: Les nouvelles questions sont en français dans les fichiers traduits")
        print("   → À traduire manuellement ou via script de traduction")
        
        print("\n🗑️  NETTOYAGE SUGGÉRÉ:")
        print("   Les fichiers sources peuvent maintenant être supprimés:")
        for source in MERGE_MAPPINGS.keys():
            print(f"      rm assets/questions/{source}")
            print(f"      rm assets/questions/{source}.backup")
    
    print("\n✅ Fusion terminée !")

if __name__ == "__main__":
    main()




